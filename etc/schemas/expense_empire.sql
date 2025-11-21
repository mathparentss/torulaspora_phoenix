-- ============================================================================
-- EXPENSE EMPIRE SAAS v1 — COMPLETE DATABASE SCHEMA
-- Phoenix Battlestack — Multi-Tenant Receipt Processing SaaS
-- Phases 1-5 Combined Schema (2025-11-19)
-- ============================================================================

-- Create receipts schema
CREATE SCHEMA IF NOT EXISTS receipts;

-- ============================================================================
-- PHASE 1: FOUNDATION — USER AUTHENTICATION & AUDIT
-- ============================================================================

-- Users table (multi-tenant ready)
CREATE TABLE receipts.users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,  -- bcrypt with cost 12
  full_name TEXT,
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro', 'enterprise')),
  monthly_receipt_limit INTEGER DEFAULT 10,
  receipts_uploaded_this_month INTEGER DEFAULT 0,
  month_reset_date DATE DEFAULT date_trunc('month', CURRENT_DATE) + INTERVAL '1 month',
  is_heat_donor BOOLEAN DEFAULT FALSE,  -- Future: 20% compute donation flag
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_users_email ON receipts.users(email) WHERE is_deleted = FALSE;
CREATE INDEX idx_users_subscription_tier ON receipts.users(subscription_tier);

-- Audit log for all user actions
CREATE TABLE receipts.audit_log (
  audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES receipts.users(user_id),
  action TEXT NOT NULL,  -- 'login', 'upload', 'export', 'delete'
  resource_type TEXT,    -- 'receipt', 'user', 'category'
  resource_id UUID,
  ip_address INET,
  user_agent TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_user_id ON receipts.audit_log(user_id);
CREATE INDEX idx_audit_created_at ON receipts.audit_log(created_at DESC);
CREATE INDEX idx_audit_action ON receipts.audit_log(action);

-- ============================================================================
-- PHASE 2: FREEMIUM CORE — RECEIPT LIFECYCLE & LIMITS
-- ============================================================================

-- Categories (CRA T2125 business expense categories)
CREATE TABLE receipts.categories (
  category_id SERIAL PRIMARY KEY,
  category_code TEXT UNIQUE NOT NULL,  -- 'MEALS', 'TRAVEL', 'OFFICE', etc.
  category_name TEXT NOT NULL,
  cra_line_number TEXT,  -- T2125 line reference
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed CRA categories
INSERT INTO receipts.categories (category_code, category_name, cra_line_number, description) VALUES
  ('ADVERTISING', 'Advertising', '8521', 'Promotion and marketing expenses'),
  ('MEALS', 'Meals & Entertainment', '8523', 'Business meals (50% deductible)'),
  ('VEHICLE', 'Vehicle Expenses', '9281', 'Fuel, maintenance, insurance'),
  ('TRAVEL', 'Travel', '8523', 'Airfare, hotels, transit'),
  ('OFFICE', 'Office Expenses', '8810', 'Supplies, software, equipment'),
  ('PROFESSIONAL', 'Professional Fees', '8862', 'Legal, accounting, consulting'),
  ('UTILITIES', 'Utilities', '9220', 'Phone, internet, hydro');

-- Receipts table
CREATE TABLE receipts.receipts (
  receipt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES receipts.users(user_id),

  -- File metadata
  original_filename TEXT NOT NULL,
  file_hash TEXT UNIQUE NOT NULL,  -- SHA256 for deduplication
  file_size_bytes INTEGER NOT NULL,
  mime_type TEXT NOT NULL CHECK (mime_type IN ('image/png', 'image/jpeg', 'application/pdf')),
  storage_path TEXT NOT NULL,  -- /var/phoenix_receipts_data/{user_id}/{receipt_id}.ext

  -- Extraction status
  extraction_status TEXT DEFAULT 'pending' CHECK (extraction_status IN ('pending', 'processing', 'completed', 'failed', 'manual_review')),
  ai_confidence_score NUMERIC(3,2),  -- 0.00 to 1.00

  -- Extracted fields (Canadian CRA compliance)
  vendor_name TEXT,
  transaction_date DATE,
  total_amount NUMERIC(10,2),
  tax_amount NUMERIC(10,2),
  currency TEXT DEFAULT 'CAD',
  category_id INTEGER REFERENCES receipts.categories(category_id),

  -- Manual override tracking
  manually_edited BOOLEAN DEFAULT FALSE,
  edited_by UUID REFERENCES receipts.users(user_id),
  edited_at TIMESTAMPTZ,

  -- Lifecycle management
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,  -- Free tier: 7 days from upload
  deleted_at TIMESTAMPTZ,  -- Soft delete

  -- AI extraction metadata
  raw_ai_response JSONB,  -- Full Llava response for debugging
  extraction_model TEXT DEFAULT 'llava:34b',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_receipts_user_id ON receipts.receipts(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_receipts_file_hash ON receipts.receipts(file_hash);
CREATE INDEX idx_receipts_extraction_status ON receipts.receipts(extraction_status);
CREATE INDEX idx_receipts_uploaded_at ON receipts.receipts(uploaded_at DESC);
CREATE INDEX idx_receipts_expires_at ON receipts.receipts(expires_at) WHERE deleted_at IS NULL;

-- Forensics trigger for receipt changes
CREATE OR REPLACE FUNCTION receipts.log_receipt_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO receipts.audit_log (user_id, action, resource_type, resource_id, metadata)
    VALUES (
      NEW.user_id,
      'receipt_updated',
      'receipt',
      NEW.receipt_id,
      jsonb_build_object(
        'old_values', to_jsonb(OLD),
        'new_values', to_jsonb(NEW),
        'changed_fields', (
          SELECT jsonb_object_agg(key, jsonb_build_object('old', old_value, 'new', new_value))
          FROM (
            SELECT key,
                   to_jsonb(OLD) -> key AS old_value,
                   to_jsonb(NEW) -> key AS new_value
            FROM jsonb_object_keys(to_jsonb(OLD)) AS key
            WHERE to_jsonb(OLD) -> key IS DISTINCT FROM to_jsonb(NEW) -> key
          ) AS changes
        )
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER receipt_audit_trigger
AFTER UPDATE ON receipts.receipts
FOR EACH ROW EXECUTE FUNCTION receipts.log_receipt_changes();

-- Ephemeral deletion function (cron job calls this daily)
CREATE OR REPLACE FUNCTION receipts.delete_expired_receipts()
RETURNS TABLE(deleted_count INTEGER) AS $$
DECLARE
  count INTEGER;
BEGIN
  WITH deleted AS (
    UPDATE receipts.receipts
    SET deleted_at = NOW()
    WHERE expires_at < NOW()
      AND deleted_at IS NULL
      AND user_id IN (SELECT user_id FROM receipts.users WHERE subscription_tier = 'free')
    RETURNING receipt_id
  )
  SELECT COUNT(*)::INTEGER INTO count FROM deleted;

  RETURN QUERY SELECT count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PHASE 3: AI ORACLE — VENDOR NORMALIZATION & LEARNING
-- ============================================================================

-- Vendor normalization table (learns from user corrections)
CREATE TABLE receipts.vendor_aliases (
  alias_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raw_vendor_name TEXT NOT NULL,
  normalized_vendor_name TEXT NOT NULL,
  times_seen INTEGER DEFAULT 1,
  last_seen_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vendor_aliases_raw ON receipts.vendor_aliases(raw_vendor_name);
CREATE INDEX idx_vendor_aliases_normalized ON receipts.vendor_aliases(normalized_vendor_name);

-- Function to normalize vendor names
CREATE OR REPLACE FUNCTION receipts.normalize_vendor_name(raw_name TEXT)
RETURNS TEXT AS $$
DECLARE
  normalized TEXT;
BEGIN
  -- Check if we have a known alias
  SELECT normalized_vendor_name INTO normalized
  FROM receipts.vendor_aliases
  WHERE LOWER(raw_vendor_name) = LOWER(raw_name)
  ORDER BY times_seen DESC
  LIMIT 1;

  IF normalized IS NOT NULL THEN
    -- Update times_seen counter
    UPDATE receipts.vendor_aliases
    SET times_seen = times_seen + 1, last_seen_at = NOW()
    WHERE LOWER(raw_vendor_name) = LOWER(raw_name);

    RETURN normalized;
  ELSE
    -- Return original name (title case)
    RETURN initcap(raw_name);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PHASE 5: SLIME EVOLUTION — NEUROTRANSMITTER GAMIFICATION
-- ============================================================================

-- Neurotransmitter gamification table
CREATE TABLE receipts.user_neurotransmitters (
  user_id UUID PRIMARY KEY REFERENCES receipts.users(user_id),

  -- Dopamine (achievement, progress)
  dopamine_score INTEGER DEFAULT 0,
  current_streak_days INTEGER DEFAULT 0,
  longest_streak_days INTEGER DEFAULT 0,
  total_receipts_processed INTEGER DEFAULT 0,
  last_upload_date DATE,

  -- Serotonin (status, comparison)
  percentile_rank INTEGER,  -- Top X% of users
  achievement_badges TEXT[],  -- ['first_upload', 'week_streak', 'power_user']

  -- Oxytocin (social, trust)
  referral_code TEXT UNIQUE DEFAULT substring(md5(random()::text), 1, 8),
  referred_by UUID REFERENCES receipts.users(user_id),
  successful_referrals INTEGER DEFAULT 0,

  -- Heat donor future hook
  heat_donor_opted_in BOOLEAN DEFAULT FALSE,
  heat_donor_since TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_neurotransmitters_referral_code ON receipts.user_neurotransmitters(referral_code);
CREATE INDEX idx_neurotransmitters_percentile ON receipts.user_neurotransmitters(percentile_rank);

-- Trigger to create neurotransmitter record when user is created
CREATE OR REPLACE FUNCTION receipts.create_user_neurotransmitters()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO receipts.user_neurotransmitters (user_id)
  VALUES (NEW.user_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_neurotransmitter_trigger
AFTER INSERT ON receipts.users
FOR EACH ROW EXECUTE FUNCTION receipts.create_user_neurotransmitters();

-- Weekly rewiring function (cron: every Monday 6am)
CREATE OR REPLACE FUNCTION receipts.weekly_neurotransmitter_update()
RETURNS VOID AS $$
BEGIN
  -- Update percentile ranks
  WITH ranked_users AS (
    SELECT
      user_id,
      PERCENT_RANK() OVER (ORDER BY total_receipts_processed DESC) * 100 AS percentile
    FROM receipts.user_neurotransmitters
  )
  UPDATE receipts.user_neurotransmitters u
  SET percentile_rank = r.percentile::INTEGER,
      updated_at = NOW()
  FROM ranked_users r
  WHERE u.user_id = r.user_id;

  -- Award streak badges
  UPDATE receipts.user_neurotransmitters
  SET achievement_badges = array_append(achievement_badges, 'week_warrior'),
      updated_at = NOW()
  WHERE current_streak_days >= 7
    AND NOT ('week_warrior' = ANY(achievement_badges));

  -- Award power user badges (100+ receipts processed)
  UPDATE receipts.user_neurotransmitters
  SET achievement_badges = array_append(achievement_badges, 'power_user'),
      updated_at = NOW()
  WHERE total_receipts_processed >= 100
    AND NOT ('power_user' = ANY(achievement_badges));

  -- Reset monthly receipt counters (first Monday of month)
  IF EXTRACT(DAY FROM CURRENT_DATE) <= 7 THEN
    UPDATE receipts.users
    SET
      receipts_uploaded_this_month = 0,
      month_reset_date = date_trunc('month', CURRENT_DATE) + INTERVAL '1 month',
      updated_at = NOW();
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update streak when receipt is uploaded
CREATE OR REPLACE FUNCTION receipts.update_upload_streak()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE receipts.user_neurotransmitters
  SET
    total_receipts_processed = total_receipts_processed + 1,
    current_streak_days = CASE
      WHEN last_upload_date = CURRENT_DATE - INTERVAL '1 day' THEN current_streak_days + 1
      WHEN last_upload_date = CURRENT_DATE THEN current_streak_days
      ELSE 1
    END,
    longest_streak_days = GREATEST(
      longest_streak_days,
      CASE
        WHEN last_upload_date = CURRENT_DATE - INTERVAL '1 day' THEN current_streak_days + 1
        ELSE current_streak_days
      END
    ),
    last_upload_date = CURRENT_DATE,
    dopamine_score = dopamine_score + 10,  -- +10 dopamine per upload
    updated_at = NOW()
  WHERE user_id = NEW.user_id;

  -- Update user's monthly receipt counter
  UPDATE receipts.users
  SET receipts_uploaded_this_month = receipts_uploaded_this_month + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER receipt_upload_streak_trigger
AFTER INSERT ON receipts.receipts
FOR EACH ROW EXECUTE FUNCTION receipts.update_upload_streak();

-- ============================================================================
-- USEFUL VIEWS
-- ============================================================================

-- View: Active users with neurotransmitter stats
CREATE OR REPLACE VIEW receipts.v_active_users AS
SELECT
  u.user_id,
  u.email,
  u.full_name,
  u.subscription_tier,
  u.receipts_uploaded_this_month,
  u.monthly_receipt_limit,
  u.created_at,
  n.current_streak_days,
  n.total_receipts_processed,
  n.percentile_rank,
  n.achievement_badges,
  n.successful_referrals
FROM receipts.users u
LEFT JOIN receipts.user_neurotransmitters n ON u.user_id = n.user_id
WHERE u.is_deleted = FALSE
ORDER BY n.total_receipts_processed DESC;

-- View: Receipts ready for manual review
CREATE OR REPLACE VIEW receipts.v_manual_review_queue AS
SELECT
  r.receipt_id,
  r.user_id,
  u.email,
  r.original_filename,
  r.ai_confidence_score,
  r.vendor_name,
  r.total_amount,
  r.uploaded_at,
  r.extraction_model
FROM receipts.receipts r
JOIN receipts.users u ON r.user_id = u.user_id
WHERE r.extraction_status = 'manual_review'
  AND r.deleted_at IS NULL
ORDER BY r.uploaded_at ASC;

-- ============================================================================
-- PERMISSIONS & SECURITY
-- ============================================================================

-- Revoke public access
REVOKE ALL ON SCHEMA receipts FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA receipts FROM PUBLIC;

-- Grant access to phoenix user (application user)
GRANT USAGE ON SCHEMA receipts TO phoenix;
GRANT ALL ON ALL TABLES IN SCHEMA receipts TO phoenix;
GRANT ALL ON ALL SEQUENCES IN SCHEMA receipts TO phoenix;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA receipts TO phoenix;

-- ============================================================================
-- SCHEMA VALIDATION & STATS
-- ============================================================================

DO $$
DECLARE
  table_count INTEGER;
  function_count INTEGER;
  trigger_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO table_count
  FROM information_schema.tables
  WHERE table_schema = 'receipts';

  SELECT COUNT(*) INTO function_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE n.nspname = 'receipts';

  SELECT COUNT(*) INTO trigger_count
  FROM information_schema.triggers
  WHERE trigger_schema = 'receipts';

  RAISE NOTICE '============================================';
  RAISE NOTICE 'EXPENSE EMPIRE SCHEMA CREATED SUCCESSFULLY';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Tables: %', table_count;
  RAISE NOTICE 'Functions: %', function_count;
  RAISE NOTICE 'Triggers: %', trigger_count;
  RAISE NOTICE '============================================';
END $$;
