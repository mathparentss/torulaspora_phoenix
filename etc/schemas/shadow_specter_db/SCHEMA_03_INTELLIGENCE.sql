-- ============================================================================
-- PHOENIX SHADOW DATABASE - INTELLIGENCE SCHEMA
-- MEDDPIC Qualification + Competitive Intel + Strategic Data
-- Version: 1.0.0
-- Purpose: Enforce sales methodology, capture strategic intelligence
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS intelligence;

-- ============================================================================
-- TABLE: intelligence.meddpic_data
-- Purpose: 8-dimension MEDDPIC qualification framework
-- ============================================================================

CREATE TABLE intelligence.meddpic_data (
    -- ========== PRIMARY KEY ==========
    meddpic_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- ========== RELATIONSHIPS ==========
    opportunity_id UUID NOT NULL UNIQUE REFERENCES core.opportunities(opportunity_id) ON DELETE CASCADE,
    company_id UUID REFERENCES core.companies(company_id),
    
    -- ========== M: METRICS (Economic Impact Quantified) ==========
    metrics_defined BOOLEAN DEFAULT FALSE,
    current_state_metrics JSONB, -- {"annual_cost": 500000, "waste_percent": 15, "lead_time_days": 30}
    desired_state_metrics JSONB, -- {"target_cost": 425000, "target_waste": 8, "target_lead_time": 20}
    economic_impact_annual DECIMAL(15,2), -- Projected annual value
    roi_calculation JSONB, -- {"investment": 50000, "annual_return": 75000, "payback_months": 8}
    cost_of_inaction DECIMAL(15,2), -- What does doing nothing cost?
    
    -- ========== E: ECONOMIC BUYER (Budget Authority) ==========
    economic_buyer_identified BOOLEAN DEFAULT FALSE,
    economic_buyer_contact_id UUID REFERENCES core.contacts(contact_id),
    economic_buyer_title VARCHAR(200),
    budget_confirmed BOOLEAN DEFAULT FALSE,
    budget_amount DECIMAL(15,2),
    budget_timing VARCHAR(100), -- "Q1 2026", "Fiscal Year 2026", "Available Now"
    budget_source VARCHAR(100), -- "CAPEX", "OPEX", "Project Budget", "Discretionary"
    approval_authority_level VARCHAR(100), -- "$0-50K", "$50-250K", "$250K-1M", ">$1M"
    
    -- ========== D: DECISION CRITERIA (What They Evaluate) ==========
    decision_criteria_documented BOOLEAN DEFAULT FALSE,
    evaluation_criteria JSONB, -- [{"criterion": "Price", "weight": 30, "our_score": 8}, {...}]
    must_have_requirements TEXT[], -- ["ISO 22000 Certified", "Local Support", "EDI Integration"]
    nice_to_have_requirements TEXT[],
    deal_breakers TEXT[], -- What would kill the deal?
    scoring_methodology TEXT, -- How do they score vendors?
    
    -- ========== D: DECISION PROCESS (How They Buy) ==========
    decision_process_mapped BOOLEAN DEFAULT FALSE,
    decision_stages JSONB, -- [{"stage": "RFP", "owner": "Procurement", "duration_days": 14}, {...}]
    decision_makers JSONB, -- [{"name": "John CFO", "role": "Final Approver", "influence": "high"}, {...}]
    decision_timeline JSONB, -- {"rfp_due": "2025-12-01", "vendor_selection": "2025-12-15", "contract_start": "2026-01-01"}
    approval_workflow TEXT, -- Description of approval chain
    committee_involved BOOLEAN, -- Is there a buying committee?
    committee_members TEXT[],
    
    -- ========== P: PAPER PROCESS (Legal/Procurement) ==========
    paper_process_understood BOOLEAN DEFAULT FALSE,
    contract_template_required BOOLEAN,
    legal_review_required BOOLEAN,
    procurement_involvement VARCHAR(50), -- "None", "Advisory", "Lead", "Gatekeeper"
    standard_terms_acceptable BOOLEAN,
    custom_terms_required TEXT[],
    required_insurance JSONB, -- {"general_liability": "2M", "product_liability": "5M"}
    required_certifications TEXT[], -- ["GFSI", "Organic", "Kosher"]
    typical_negotiation_duration_days INTEGER,
    
    -- ========== I: IDENTIFY PAIN (Problem Validation) ==========
    pain_validated BOOLEAN DEFAULT FALSE,
    primary_pain_point VARCHAR(500), -- Most urgent problem
    pain_intensity DECIMAL(3,2), -- 0-1 score
    pain_impact_areas TEXT[], -- ["Cost", "Quality", "Reliability", "Compliance"]
    pain_frequency VARCHAR(50), -- "Daily", "Weekly", "Monthly", "Seasonal"
    consequences_if_unsolved TEXT, -- What happens if they don't fix this?
    pain_owner_contact_id UUID REFERENCES core.contacts(contact_id), -- Who feels this pain most?
    pain_timeline VARCHAR(100), -- How urgent? "Immediate", "This Quarter", "This Year"
    
    -- ========== C: CHAMPION (Internal Advocate) ==========
    champion_engaged BOOLEAN DEFAULT FALSE,
    champion_contact_id UUID REFERENCES core.contacts(contact_id),
    champion_strength VARCHAR(50), -- "Weak", "Developing", "Strong", "Executive"
    champion_credibility VARCHAR(50), -- "Low", "Medium", "High" (within their org)
    champion_motivation TEXT, -- Why are they helping us?
    champion_actions_taken TEXT[], -- ["Introduced us to VP", "Shared internal docs", "Attended demos"]
    champion_risks TEXT[], -- ["New to role", "Limited influence", "Competing priorities"]
    backup_champion_contact_id UUID REFERENCES core.contacts(contact_id),
    
    -- ========== C: COMPETITION (Competitive Landscape) ==========
    competition_mapped BOOLEAN DEFAULT FALSE,
    competitors TEXT[], -- ["Ingredion", "Cargill", "ADM", "Status Quo"]
    incumbent_vendor VARCHAR(200),
    incumbent_relationship_strength VARCHAR(50), -- "Weak", "Moderate", "Strong", "Entrenched"
    our_competitive_position VARCHAR(50), -- "Leading", "Tied", "Behind"
    our_differentiation TEXT[], -- What makes us different/better?
    competitor_strengths JSONB, -- [{"competitor": "Ingredion", "strengths": ["Price", "Brand"]}]
    competitor_weaknesses JSONB,
    why_change_now TEXT, -- Why would they switch from incumbent?
    
    -- ========== COMPLETENESS SCORING ==========
    completeness_score DECIMAL(5,2) DEFAULT 0, -- 0-100%
    last_completeness_check TIMESTAMPTZ,
    blocking_gaps TEXT[], -- What's preventing stage progression?
    
    -- ========== AUDIT ==========
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated_by VARCHAR(100),
    
    -- ========== CONSTRAINTS ==========
    CONSTRAINT chk_pain_intensity CHECK (pain_intensity BETWEEN 0 AND 1),
    CONSTRAINT chk_completeness CHECK (completeness_score BETWEEN 0 AND 100)
);

-- ========== INDEXES ==========
CREATE INDEX idx_meddpic_opportunity ON intelligence.meddpic_data(opportunity_id);
CREATE INDEX idx_meddpic_completeness ON intelligence.meddpic_data(completeness_score);
CREATE INDEX idx_meddpic_incomplete ON intelligence.meddpic_data(meddpic_id) WHERE completeness_score < 75;
CREATE INDEX idx_meddpic_economic_buyer ON intelligence.meddpic_data(economic_buyer_contact_id) WHERE economic_buyer_contact_id IS NOT NULL;
CREATE INDEX idx_meddpic_champion ON intelligence.meddpic_data(champion_contact_id) WHERE champion_contact_id IS NOT NULL;

COMMENT ON TABLE intelligence.meddpic_data IS 'MEDDPICC qualification framework (8 dimensions)';
COMMENT ON COLUMN intelligence.meddpic_data.completeness_score IS '0-100% based on filled criteria (12.5% each)';

-- ============================================================================
-- FUNCTION: Calculate MEDDPIC Completeness
-- ============================================================================

CREATE OR REPLACE FUNCTION intelligence.calculate_meddpic_completeness(p_meddpic_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_score DECIMAL := 0;
    v_rec RECORD;
BEGIN
    SELECT * INTO v_rec FROM intelligence.meddpic_data WHERE meddpic_id = p_meddpic_id;
    
    -- Each dimension worth 12.5% (8 dimensions = 100%)
    IF v_rec.metrics_defined THEN v_score := v_score + 12.5; END IF;
    IF v_rec.economic_buyer_identified THEN v_score := v_score + 12.5; END IF;
    IF v_rec.decision_criteria_documented THEN v_score := v_score + 12.5; END IF;
    IF v_rec.decision_process_mapped THEN v_score := v_score + 12.5; END IF;
    IF v_rec.paper_process_understood THEN v_score := v_score + 12.5; END IF;
    IF v_rec.pain_validated THEN v_score := v_score + 12.5; END IF;
    IF v_rec.champion_engaged THEN v_score := v_score + 12.5; END IF;
    IF v_rec.competition_mapped THEN v_score := v_score + 12.5; END IF;
    
    -- Update the record
    UPDATE intelligence.meddpic_data
    SET completeness_score = v_score,
        last_completeness_check = NOW()
    WHERE meddpic_id = p_meddpic_id;
    
    RETURN v_score;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TABLE: intelligence.competitive_intel
-- Purpose: Competitive intelligence on rivals
-- ============================================================================

CREATE TABLE intelligence.competitive_intel (
    intel_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competitor_name VARCHAR(200) NOT NULL,
    opportunity_id UUID REFERENCES core.opportunities(opportunity_id),
    company_id UUID REFERENCES core.companies(company_id),
    
    -- Competitive Positioning
    strengths TEXT[],
    weaknesses TEXT[],
    pricing_strategy VARCHAR(200),
    typical_discount_percent DECIMAL(5,2),
    relationship_strength VARCHAR(50),
    
    -- Intelligence Details
    intel_source VARCHAR(200), -- "Customer Interview", "LinkedIn", "Industry Report"
    intel_date DATE,
    confidence_level DECIMAL(3,2), -- 0-1
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_competitive_intel_competitor ON intelligence.competitive_intel(competitor_name);
CREATE INDEX idx_competitive_intel_opportunity ON intelligence.competitive_intel(opportunity_id);

-- ============================================================================
-- TABLE: intelligence.meeting_notes
-- Purpose: Structured meeting summaries
-- ============================================================================

CREATE TABLE intelligence.meeting_notes (
    note_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID REFERENCES core.opportunities(opportunity_id),
    interaction_id UUID REFERENCES events.interactions(interaction_id),
    
    meeting_date DATE NOT NULL,
    attendees JSONB, -- [{"name": "John Smith", "title": "VP Ops", "our_team": false}]
    
    -- Structured Content
    agenda TEXT,
    discussion_summary TEXT,
    decisions_made TEXT[],
    action_items JSONB,
    next_meeting_date DATE,
    
    -- Intelligence Extracted
    pain_points_discussed TEXT[],
    objections_raised TEXT[],
    buying_signals TEXT[],
    meddpic_updates JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(100)
);

CREATE INDEX idx_meeting_notes_opportunity ON intelligence.meeting_notes(opportunity_id);
CREATE INDEX idx_meeting_notes_date ON intelligence.meeting_notes(meeting_date DESC);

-- ============================================================================
-- GRANTS
-- ============================================================================

GRANT USAGE ON SCHEMA intelligence TO specter_app;
GRANT ALL ON ALL TABLES IN SCHEMA intelligence TO specter_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA intelligence TO specter_app;

-- ============================================================================
-- END OF INTELLIGENCE SCHEMA
-- ============================================================================
