-- ============================================================================
-- PHOENIX SHADOW DATABASE - CORE SCHEMA (FIXED)
-- State Projections: Companies, Contacts, Opportunities
-- Version: 1.0.1 - Fixed PostgreSQL compatibility issues
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS core;

-- ============================================================================
-- TABLE: core.companies
-- ============================================================================

CREATE TABLE core.companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Information
    company_name VARCHAR(300) NOT NULL,
    legal_name VARCHAR(300),
    domain VARCHAR(100) UNIQUE,
    website_url TEXT,
    linkedin_url TEXT,
    industry VARCHAR(100),
    
    -- Classification
    company_size VARCHAR(50),
    employee_count INTEGER,
    annual_revenue_range VARCHAR(50),
    estimated_revenue DECIMAL(15,2),
    
    -- Location
    headquarters_address TEXT,
    headquarters_city VARCHAR(100),
    headquarters_province VARCHAR(50),
    headquarters_country VARCHAR(50) DEFAULT 'Canada',
    headquarters_coordinates POINT,
    production_facilities JSONB,
    distribution_centers JSONB,
    
    -- Food Industry Context
    health_canada_categories TEXT[],
    product_categories_manufactured TEXT[],
    target_markets TEXT[],
    regulatory_environment VARCHAR(50),
    certifications TEXT[],
    peak_seasons TEXT[],
    seasonality_pattern VARCHAR(50),
    
    -- Supply Chain Intelligence
    current_suppliers JSONB,
    estimated_annual_ingredient_spend DECIMAL(15,2),
    procurement_type VARCHAR(50),
    decision_process_complexity VARCHAR(20),
    supply_chain_complexity VARCHAR(50),
    purchasing_frequency VARCHAR(50),
    contract_renewal_cycle VARCHAR(50),
    
    -- Pain Points & Opportunities
    primary_pain_points TEXT[],
    pain_intensity_score DECIMAL(3,2),
    strategic_priorities TEXT[],
    innovation_appetite VARCHAR(20),
    
    -- Account Management
    account_tier VARCHAR(50),
    account_priority VARCHAR(20),
    account_status VARCHAR(50),
    relationship_stage VARCHAR(50),
    customer_since DATE,
    last_purchase_date DATE,
    lifetime_value DECIMAL(15,2),
    
    -- Competitive Intelligence
    competitive_displacement_priority VARCHAR(20),
    incumbent_strength VARCHAR(20),
    switching_barriers TEXT[],
    competitive_advantage_opportunities TEXT[],
    
    -- Opportunity Scoring
    win_probability DECIMAL(5,2),
    expected_annual_value DECIMAL(15,2),
    expansion_potential DECIMAL(15,2),
    strategic_value_score DECIMAL(3,2),
    
    -- Intelligence Quality
    data_quality_score DECIMAL(3,2),
    last_intelligence_refresh TIMESTAMPTZ,
    intelligence_sources JSONB,
    data_completeness_percent DECIMAL(5,2),
    
    -- HubSpot Sync
    hubspot_company_id VARCHAR(50) UNIQUE,
    hubspot_owner_id VARCHAR(50),
    hubspot_last_sync TIMESTAMPTZ,
    hubspot_sync_status VARCHAR(20),
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    deletion_reason TEXT,
    
    -- Full-Text Search (FIXED: removed generated column dependency)
    search_vector tsvector,
    
    -- Constraints
    CONSTRAINT chk_company_size CHECK (company_size IN ('<50', '50-250', '250-1000', '1000-5000', '5000+')),
    CONSTRAINT chk_account_tier CHECK (account_tier IN ('Strategic', 'Key', 'Standard', 'Small')),
    CONSTRAINT chk_account_priority CHECK (account_priority IN ('Alpha', 'Beta', 'Gamma', 'Dormant')),
    CONSTRAINT chk_win_probability CHECK (win_probability BETWEEN 0 AND 100),
    CONSTRAINT chk_data_quality CHECK (data_quality_score BETWEEN 0 AND 1),
    CONSTRAINT chk_pain_intensity CHECK (pain_intensity_score BETWEEN 0 AND 1)
);

-- Trigger to maintain search_vector
CREATE OR REPLACE FUNCTION core.update_company_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('english',
        COALESCE(NEW.company_name, '') || ' ' ||
        COALESCE(NEW.legal_name, '') || ' ' ||
        COALESCE(NEW.industry, '') || ' ' ||
        COALESCE(array_to_string(NEW.health_canada_categories, ' '), '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE TRIGGER trg_company_search_vector
    BEFORE INSERT OR UPDATE OF company_name, legal_name, industry, health_canada_categories
    ON core.companies
    FOR EACH ROW
    EXECUTE FUNCTION core.update_company_search_vector();

-- Indexes
CREATE INDEX idx_companies_name_gin ON core.companies USING gin(search_vector);
CREATE INDEX idx_companies_domain ON core.companies(domain) WHERE domain IS NOT NULL;
CREATE INDEX idx_companies_health_canada_gin ON core.companies USING gin(health_canada_categories);
CREATE INDEX idx_companies_tier_priority ON core.companies(account_tier, account_priority) WHERE is_deleted = FALSE;
CREATE INDEX idx_companies_status ON core.companies(account_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_companies_hubspot ON core.companies(hubspot_company_id) WHERE hubspot_company_id IS NOT NULL;
CREATE INDEX idx_companies_updated ON core.companies(updated_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_companies_active ON core.companies(company_id) WHERE is_deleted = FALSE;

COMMENT ON TABLE core.companies IS 'Company master data (state projection)';

-- ============================================================================
-- TABLE: core.contacts
-- ============================================================================

CREATE TABLE core.contacts (
    contact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationships
    company_id UUID NOT NULL REFERENCES core.companies(company_id) ON DELETE CASCADE,
    reports_to_contact_id UUID REFERENCES core.contacts(contact_id),
    
    -- Basic Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(200), -- Regular column, computed by trigger
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    mobile_phone VARCHAR(50),
    title VARCHAR(200),
    department VARCHAR(100),
    seniority_level VARCHAR(50),
    job_function VARCHAR(100),
    
    -- Contact Channels
    linkedin_url TEXT,
    twitter_handle VARCHAR(100),
    preferred_language VARCHAR(10),
    timezone VARCHAR(50),
    best_contact_time VARCHAR(50),
    preferred_contact_method VARCHAR(50),
    
    -- Personality & Communication
    personality_profile VARCHAR(200),
    disc_profile VARCHAR(10),
    myers_briggs VARCHAR(10),
    enneagram_type VARCHAR(50),
    communication_style VARCHAR(50),
    decision_making_style VARCHAR(50),
    response_pattern VARCHAR(50),
    interaction_preferences JSONB,
    
    -- MEDDPIC Role
    meddpicc_role VARCHAR(50),
    decision_authority VARCHAR(50),
    budget_authority BOOLEAN,
    technical_authority BOOLEAN,
    
    -- Champion Analysis
    champion_potential VARCHAR(50),
    champion_strength VARCHAR(50),
    champion_indicators JSONB,
    internal_influence_score DECIMAL(3,2),
    
    -- Relationship Metrics
    relationship_strength DECIMAL(3,2) CHECK (relationship_strength BETWEEN 0 AND 1),
    engagement_level VARCHAR(50),
    trust_score DECIMAL(3,2),
    relationship_debt DECIMAL(5,2),
    last_meaningful_interaction TIMESTAMPTZ,
    interaction_frequency VARCHAR(50),
    
    -- Pain & Needs
    pain_points_identified TEXT[],
    personal_motivations TEXT[],
    objections_raised TEXT[],
    buying_signals TEXT[],
    
    -- Intelligence Quality
    linkedin_profile_quality VARCHAR(20),
    data_quality_score DECIMAL(3,2),
    last_intelligence_update TIMESTAMPTZ,
    intelligence_sources JSONB,
    
    -- HubSpot Sync
    hubspot_contact_id VARCHAR(50) UNIQUE,
    hubspot_owner_id VARCHAR(50),
    hubspot_last_sync TIMESTAMPTZ,
    hubspot_sync_status VARCHAR(20),
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    
    -- Full-Text Search
    search_vector tsvector,
    
    -- Constraints
    CONSTRAINT chk_seniority CHECK (seniority_level IN ('C-Level', 'VP', 'Director', 'Manager', 'Individual Contributor')),
    CONSTRAINT chk_meddpicc_role CHECK (meddpicc_role IN ('Economic Buyer', 'Champion', 'Technical Influencer', 'Gatekeeper', 'User', 'Blocker', 'Unknown')),
    CONSTRAINT chk_engagement CHECK (engagement_level IN ('Cold', 'Aware', 'Interested', 'Evaluating', 'Decided', 'Advocate')),
    CONSTRAINT chk_trust_score CHECK (trust_score BETWEEN 0 AND 1)
);

-- Trigger to maintain full_name
CREATE OR REPLACE FUNCTION core.update_contact_full_name()
RETURNS TRIGGER AS $$
BEGIN
    NEW.full_name := TRIM(COALESCE(NEW.first_name, '') || ' ' || COALESCE(NEW.last_name, ''));
    NEW.search_vector := to_tsvector('english',
        COALESCE(NEW.full_name, '') || ' ' ||
        COALESCE(NEW.title, '') || ' ' ||
        COALESCE(NEW.email, '') || ' ' ||
        COALESCE(NEW.department, '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE TRIGGER trg_contact_full_name
    BEFORE INSERT OR UPDATE OF first_name, last_name, title, email, department
    ON core.contacts
    FOR EACH ROW
    EXECUTE FUNCTION core.update_contact_full_name();

-- Indexes
CREATE INDEX idx_contacts_company ON core.contacts(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_contacts_email ON core.contacts(email) WHERE email IS NOT NULL;
CREATE INDEX idx_contacts_name_gin ON core.contacts USING gin(search_vector);
CREATE INDEX idx_contacts_meddpicc_role ON core.contacts(meddpicc_role) WHERE is_deleted = FALSE;
CREATE INDEX idx_contacts_champion ON core.contacts(champion_strength) WHERE champion_strength IN ('Strong', 'Executive Champion');

COMMENT ON TABLE core.contacts IS 'Contact master data (state projection)';

-- ============================================================================
-- TABLE: core.opportunities
-- ============================================================================

CREATE TABLE core.opportunities (
    opportunity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationships
    company_id UUID NOT NULL REFERENCES core.companies(company_id) ON DELETE CASCADE,
    primary_contact_id UUID REFERENCES core.contacts(contact_id),
    economic_buyer_contact_id UUID REFERENCES core.contacts(contact_id),
    champion_contact_id UUID REFERENCES core.contacts(contact_id),
    
    -- Basic Information
    opportunity_name VARCHAR(300) NOT NULL,
    description TEXT,
    opportunity_type VARCHAR(50),
    
    -- Pipeline Stage
    stage VARCHAR(100) NOT NULL,
    stage_order INTEGER,
    probability DECIMAL(5,2),
    win_probability DECIMAL(5,2),
    
    -- Financial
    amount DECIMAL(15,2) NOT NULL,
    weighted_value DECIMAL(15,2), -- Computed by trigger
    annual_recurring_value DECIMAL(15,2),
    total_contract_value DECIMAL(15,2),
    margin_percent DECIMAL(5,2),
    
    -- Timeline
    created_date DATE DEFAULT CURRENT_DATE,
    close_date DATE,
    actual_close_date DATE,
    first_contact_date DATE,
    discovery_start_date DATE,
    proposal_submitted_date DATE,
    
    -- Velocity Tracking
    days_in_current_stage INTEGER, -- Maintained by trigger
    days_since_created INTEGER, -- Computed field
    deal_velocity_score DECIMAL(5,2),
    average_days_per_stage DECIMAL(5,2),
    is_stalled BOOLEAN DEFAULT FALSE, -- Maintained by trigger
    
    -- MEDDPIC Tracking
    meddpicc_completeness DECIMAL(5,2),
    metrics_defined BOOLEAN DEFAULT FALSE,
    economic_buyer_identified BOOLEAN DEFAULT FALSE,
    decision_criteria_documented BOOLEAN DEFAULT FALSE,
    decision_process_mapped BOOLEAN DEFAULT FALSE,
    paper_process_understood BOOLEAN DEFAULT FALSE,
    pain_validated BOOLEAN DEFAULT FALSE,
    champion_engaged BOOLEAN DEFAULT FALSE,
    competition_mapped BOOLEAN DEFAULT FALSE,
    
    -- Risk Assessment
    risk_level VARCHAR(20),
    risk_factors TEXT[],
    blockers TEXT[],
    next_best_actions TEXT[],
    
    -- Competitive Landscape
    competitors TEXT[],
    competitive_position VARCHAR(50),
    our_advantages TEXT[],
    competitor_advantages TEXT[],
    
    -- Outcome
    closed_won BOOLEAN DEFAULT FALSE,
    closed_lost BOOLEAN DEFAULT FALSE,
    loss_reason VARCHAR(100),
    loss_details TEXT,
    won_reason VARCHAR(100),
    
    -- Assignment
    owner_user_id VARCHAR(100),
    owner_name VARCHAR(200),
    support_team_ids TEXT[],
    
    -- Intelligence Sources
    source VARCHAR(50),
    campaign_name VARCHAR(200),
    lead_source_details JSONB,
    
    -- HubSpot Sync
    hubspot_deal_id VARCHAR(50) UNIQUE,
    hubspot_owner_id VARCHAR(50),
    hubspot_last_sync TIMESTAMPTZ,
    hubspot_sync_status VARCHAR(20),
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    
    -- Full-Text Search
    search_vector tsvector,
    
    -- Constraints
    CONSTRAINT chk_opportunity_type CHECK (opportunity_type IN ('New Business', 'Expansion', 'Renewal', 'Cross-Sell', 'Upsell')),
    CONSTRAINT chk_probability CHECK (probability BETWEEN 0 AND 100),
    CONSTRAINT chk_win_probability CHECK (win_probability BETWEEN 0 AND 100),
    CONSTRAINT chk_meddpicc_completeness CHECK (meddpicc_completeness BETWEEN 0 AND 100),
    CONSTRAINT chk_risk_level CHECK (risk_level IN ('Low', 'Medium', 'High', 'Critical')),
    CONSTRAINT chk_competitive_position CHECK (competitive_position IN ('Leading', 'Tied', 'Behind', 'Unknown')),
    CONSTRAINT chk_close_logic CHECK (
        (closed_won = FALSE AND closed_lost = FALSE) OR
        (closed_won = TRUE AND closed_lost = FALSE) OR
        (closed_won = FALSE AND closed_lost = TRUE)
    )
);

-- Trigger to maintain computed fields
CREATE OR REPLACE FUNCTION core.update_opportunity_fields()
RETURNS TRIGGER AS $$
BEGIN
    NEW.weighted_value := NEW.amount * COALESCE(NEW.win_probability, 0) / 100;
    NEW.days_since_created := CURRENT_DATE - NEW.created_date;
    NEW.search_vector := to_tsvector('english',
        COALESCE(NEW.opportunity_name, '') || ' ' ||
        COALESCE(NEW.description, '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE TRIGGER trg_opportunity_fields
    BEFORE INSERT OR UPDATE
    ON core.opportunities
    FOR EACH ROW
    EXECUTE FUNCTION core.update_opportunity_fields();

-- Indexes
CREATE INDEX idx_opportunities_company ON core.opportunities(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_opportunities_stage ON core.opportunities(stage, stage_order) WHERE is_deleted = FALSE;
CREATE INDEX idx_opportunities_active ON core.opportunities(opportunity_id) WHERE is_deleted = FALSE AND closed_won = FALSE AND closed_lost = FALSE;

COMMENT ON TABLE core.opportunities IS 'Deal pipeline state projection';

-- ============================================================================
-- VIEWS
-- ============================================================================

CREATE VIEW core.v_active_pipeline AS
SELECT 
    o.opportunity_id,
    o.opportunity_name,
    c.company_name,
    o.stage,
    o.amount,
    o.win_probability,
    o.weighted_value,
    o.close_date,
    o.meddpicc_completeness,
    o.days_in_current_stage,
    o.risk_level,
    o.owner_name
FROM core.opportunities o
JOIN core.companies c ON c.company_id = o.company_id
WHERE o.is_deleted = FALSE
  AND o.closed_won = FALSE
  AND o.closed_lost = FALSE;

-- ============================================================================
-- GRANTS (FIXED: using phoenix role)
-- ============================================================================

GRANT USAGE ON SCHEMA core TO phoenix;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA core TO phoenix;
GRANT SELECT ON ALL TABLES IN SCHEMA core TO phoenix;

-- ============================================================================
-- END OF CORE SCHEMA (FIXED)
-- ============================================================================
