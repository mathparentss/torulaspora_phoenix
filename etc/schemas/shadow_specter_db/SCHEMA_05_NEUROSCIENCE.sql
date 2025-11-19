-- ============================================================================
-- PHOENIX SHADOW DATABASE - NEUROSCIENCE SCHEMA
-- Human Behavior Modeling: Trust Evolution + Hormone Cascades + Influence
-- Version: 1.0.0
-- Purpose: Predict relationship strength, champion emergence, deal risk
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS neuroscience;

-- ============================================================================
-- TABLE: neuroscience.trust_model
-- Purpose: Bayesian trust scores for each contact
-- ============================================================================

CREATE TABLE neuroscience.trust_model (
    trust_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL UNIQUE REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    
    -- Current Trust State
    trust_score DECIMAL(4,3) DEFAULT 0.500 CHECK (trust_score BETWEEN 0 AND 1),
    confidence_level DECIMAL(4,3) DEFAULT 0.100 CHECK (confidence_level BETWEEN 0 AND 1),
    
    -- Bayesian Update Parameters
    prior_trust DECIMAL(4,3) DEFAULT 0.500,
    evidence_weight DECIMAL(5,2) DEFAULT 1.0,
    total_interactions INTEGER DEFAULT 0,
    positive_interactions INTEGER DEFAULT 0,
    negative_interactions INTEGER DEFAULT 0,
    
    -- Trust Velocity (rate of change)
    trust_velocity DECIMAL(5,3), -- Change per week (-1 to +1)
    trust_acceleration DECIMAL(5,3), -- Second derivative
    
    -- Predictive
    predicted_trust_30d DECIMAL(4,3), -- Where will trust be in 30 days?
    champion_probability DECIMAL(4,3), -- Likelihood of becoming champion (0-1)
    
    -- Last Update
    last_interaction_date DATE,
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Model Version
    model_version VARCHAR(10) DEFAULT '1.0'
);

CREATE INDEX idx_trust_contact ON neuroscience.trust_model(contact_id);
CREATE INDEX idx_trust_score ON neuroscience.trust_model(trust_score DESC);
CREATE INDEX idx_trust_champion_prob ON neuroscience.trust_model(champion_probability DESC) WHERE champion_probability > 0.5;
CREATE INDEX idx_trust_velocity ON neuroscience.trust_model(trust_velocity DESC);

COMMENT ON TABLE neuroscience.trust_model IS 'Bayesian trust scores with velocity tracking';
COMMENT ON COLUMN neuroscience.trust_model.trust_velocity IS 'Trust change rate per week (-1 to +1)';
COMMENT ON COLUMN neuroscience.trust_model.champion_probability IS 'ML-predicted likelihood of becoming champion';

-- ============================================================================
-- TABLE: neuroscience.trust_snapshots
-- Purpose: Historical trust evolution (daily/weekly snapshots)
-- ============================================================================

CREATE TABLE neuroscience.trust_snapshots (
    snapshot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    
    snapshot_date DATE NOT NULL,
    trust_score DECIMAL(4,3) NOT NULL,
    confidence_level DECIMAL(4,3),
    total_interactions INTEGER,
    
    -- Delta from previous snapshot
    trust_delta DECIMAL(5,3),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (contact_id, snapshot_date)
);

CREATE INDEX idx_trust_snapshots_contact ON neuroscience.trust_snapshots(contact_id, snapshot_date DESC);
CREATE INDEX idx_trust_snapshots_date ON neuroscience.trust_snapshots(snapshot_date DESC);

COMMENT ON TABLE neuroscience.trust_snapshots IS 'Historical trust evolution for trend analysis';

-- ============================================================================
-- TABLE: neuroscience.hormone_events
-- Purpose: Track hormone cascade triggers from interactions
-- ============================================================================

CREATE TABLE neuroscience.hormone_events (
    hormone_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    contact_id UUID REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    interaction_id UUID REFERENCES events.interactions(interaction_id),
    
    -- Hormone Type
    hormone_type VARCHAR(50) NOT NULL, -- 'oxytocin', 'dopamine', 'cortisol', 'serotonin'
    trigger_event VARCHAR(200) NOT NULL, -- 'value_provided', 'milestone_achieved', 'deal_stalled'
    
    -- Intensity
    intensity DECIMAL(3,2) CHECK (intensity BETWEEN 0 AND 1),
    
    -- Expected Impact
    trust_impact_predicted DECIMAL(4,3), -- Expected trust change
    engagement_impact_predicted DECIMAL(4,3),
    
    -- Timestamp
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT chk_hormone_type CHECK (hormone_type IN ('oxytocin', 'dopamine', 'cortisol', 'serotonin'))
);

CREATE INDEX idx_hormone_events_contact ON neuroscience.hormone_events(contact_id, triggered_at DESC);
CREATE INDEX idx_hormone_events_type ON neuroscience.hormone_events(hormone_type);
CREATE INDEX idx_hormone_events_recent ON neuroscience.hormone_events(triggered_at DESC);

COMMENT ON TABLE neuroscience.hormone_events IS 'Hormone cascade triggers (oxytocin/dopamine/cortisol)';
COMMENT ON COLUMN neuroscience.hormone_events.hormone_type IS 'oxytocin=bonding, dopamine=reward, cortisol=stress';

-- ============================================================================
-- TABLE: neuroscience.relationship_debt
-- Purpose: Track value provided without asking for return (reciprocity)
-- ============================================================================

CREATE TABLE neuroscience.relationship_debt (
    debt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    contact_id UUID NOT NULL REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    interaction_id UUID REFERENCES events.interactions(interaction_id),
    
    -- Debt Details
    interaction_type VARCHAR(100) NOT NULL, -- 'value_provided', 'favor_given', 'insight_shared'
    debt_value DECIMAL(5,2) NOT NULL CHECK (debt_value >= 0), -- Weighted value (0-10 scale)
    perceived_value DECIMAL(3,2), -- 0-1 (how valuable to them?)
    
    -- Reciprocity
    reciprocity_expected BOOLEAN DEFAULT FALSE, -- Did we ask for something back?
    reciprocity_fulfilled BOOLEAN DEFAULT FALSE,
    reciprocity_date DATE,
    
    -- Context
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_relationship_debt_contact ON neuroscience.relationship_debt(contact_id, created_at DESC);
CREATE INDEX idx_relationship_debt_unfulfilled ON neuroscience.relationship_debt(contact_id, debt_value DESC) 
    WHERE reciprocity_expected = FALSE OR reciprocity_fulfilled = FALSE;

COMMENT ON TABLE neuroscience.relationship_debt IS 'Value provided without asking for return (builds leverage)';
COMMENT ON COLUMN neuroscience.relationship_debt.debt_value IS 'Weighted value provided (0-10 scale)';

-- ============================================================================
-- TABLE: neuroscience.influence_graph
-- Purpose: Stakeholder influence mapping (who influences whom)
-- ============================================================================

CREATE TABLE neuroscience.influence_graph (
    edge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Graph Edges
    contact_id UUID NOT NULL REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    influences_contact_id UUID NOT NULL REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    
    -- Influence Strength
    influence_strength DECIMAL(3,2) CHECK (influence_strength BETWEEN 0 AND 1),
    influence_type VARCHAR(50), -- 'reports_to', 'peer', 'mentor', 'gatekeeper', 'blocker'
    
    -- Evidence
    evidence_source VARCHAR(200), -- 'org_chart', 'meeting_observation', 'contact_confirmed'
    evidence_confidence DECIMAL(3,2) CHECK (evidence_confidence BETWEEN 0 AND 1),
    
    -- Bidirectional?
    is_mutual BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_validated TIMESTAMPTZ,
    
    CONSTRAINT chk_no_self_influence CHECK (contact_id != influences_contact_id)
);

CREATE INDEX idx_influence_from ON neuroscience.influence_graph(contact_id);
CREATE INDEX idx_influence_to ON neuroscience.influence_graph(influences_contact_id);
CREATE INDEX idx_influence_strength ON neuroscience.influence_graph(influence_strength DESC);
CREATE INDEX idx_influence_type ON neuroscience.influence_graph(influence_type);

COMMENT ON TABLE neuroscience.influence_graph IS 'Directed graph of stakeholder influence';
COMMENT ON COLUMN neuroscience.influence_graph.influence_strength IS 'How much does A influence B? (0-1)';

-- ============================================================================
-- TABLE: neuroscience.stakeholder_centrality
-- Purpose: Calculate champion potential via network centrality
-- ============================================================================

CREATE TABLE neuroscience.stakeholder_centrality (
    centrality_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    company_id UUID REFERENCES core.companies(company_id),
    
    -- Centrality Scores (graph algorithms)
    degree_centrality DECIMAL(5,3), -- How many connections?
    betweenness_centrality DECIMAL(5,3), -- Bridge between groups?
    closeness_centrality DECIMAL(5,3), -- Distance to all others?
    eigenvector_centrality DECIMAL(5,3), -- Connected to important people?
    
    -- Composite Score
    champion_centrality_score DECIMAL(5,3), -- Weighted combination
    
    -- Pathfinding
    hops_to_economic_buyer INTEGER, -- How far from decision maker?
    path_to_economic_buyer JSONB, -- [contact_id1, contact_id2, ...]
    
    -- Calculation Metadata
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    graph_version VARCHAR(20),
    
    UNIQUE (contact_id, calculated_at)
);

CREATE INDEX idx_centrality_contact ON neuroscience.stakeholder_centrality(contact_id, calculated_at DESC);
CREATE INDEX idx_centrality_champion_score ON neuroscience.stakeholder_centrality(champion_centrality_score DESC);
CREATE INDEX idx_centrality_hops ON neuroscience.stakeholder_centrality(hops_to_economic_buyer ASC) WHERE hops_to_economic_buyer IS NOT NULL;

COMMENT ON TABLE neuroscience.stakeholder_centrality IS 'Network centrality scores for champion identification';
COMMENT ON COLUMN neuroscience.stakeholder_centrality.champion_centrality_score IS 'Composite centrality score (higher = better champion potential)';

-- ============================================================================
-- TABLE: neuroscience.engagement_timeline
-- Purpose: Track interaction frequency and intensity over time
-- ============================================================================

CREATE TABLE neuroscience.engagement_timeline (
    timeline_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES core.contacts(contact_id) ON DELETE CASCADE,
    
    -- Time Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Engagement Metrics
    interaction_count INTEGER DEFAULT 0,
    total_duration_minutes INTEGER DEFAULT 0,
    
    -- Interaction Types
    meetings INTEGER DEFAULT 0,
    calls INTEGER DEFAULT 0,
    emails INTEGER DEFAULT 0,
    
    -- Sentiment
    average_sentiment DECIMAL(3,2), -- -1 to +1
    positive_interactions INTEGER DEFAULT 0,
    negative_interactions INTEGER DEFAULT 0,
    
    -- Frequency
    days_between_interactions DECIMAL(5,2), -- Average gap
    engagement_velocity DECIMAL(5,3), -- Increasing/decreasing frequency
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE (contact_id, period_start, period_end)
);

CREATE INDEX idx_engagement_contact ON neuroscience.engagement_timeline(contact_id, period_start DESC);
CREATE INDEX idx_engagement_velocity ON neuroscience.engagement_timeline(engagement_velocity DESC);

COMMENT ON TABLE neuroscience.engagement_timeline IS 'Interaction frequency and intensity over time';

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Update trust score (Bayesian update)
CREATE OR REPLACE FUNCTION neuroscience.update_trust_score(
    p_contact_id UUID,
    p_interaction_outcome DECIMAL, -- -1.0 to +1.0
    p_evidence_weight DECIMAL DEFAULT 1.0
) RETURNS DECIMAL AS $$
DECLARE
    v_prior_trust DECIMAL;
    v_current_weight DECIMAL;
    v_new_trust DECIMAL;
    v_trust_delta DECIMAL;
BEGIN
    -- Get current trust
    SELECT trust_score, evidence_weight INTO v_prior_trust, v_current_weight
    FROM neuroscience.trust_model
    WHERE contact_id = p_contact_id;
    
    -- If no record exists, create one
    IF v_prior_trust IS NULL THEN
        INSERT INTO neuroscience.trust_model (contact_id, trust_score, prior_trust)
        VALUES (p_contact_id, 0.5, 0.5);
        v_prior_trust := 0.5;
        v_current_weight := 1.0;
    END IF;
    
    -- Bayesian update: (prior × weight + new_evidence) / (weight + 1)
    v_new_trust := (v_prior_trust * v_current_weight + p_interaction_outcome) / (v_current_weight + p_evidence_weight);
    v_new_trust := GREATEST(0, LEAST(1, v_new_trust)); -- Clamp to [0,1]
    
    v_trust_delta := v_new_trust - v_prior_trust;
    
    -- Update trust model
    UPDATE neuroscience.trust_model
    SET trust_score = v_new_trust,
        prior_trust = v_prior_trust,
        evidence_weight = v_current_weight + p_evidence_weight,
        total_interactions = total_interactions + 1,
        positive_interactions = positive_interactions + CASE WHEN p_interaction_outcome > 0 THEN 1 ELSE 0 END,
        negative_interactions = negative_interactions + CASE WHEN p_interaction_outcome < 0 THEN 1 ELSE 0 END,
        last_interaction_date = CURRENT_DATE,
        last_updated_at = NOW()
    WHERE contact_id = p_contact_id;
    
    -- Create snapshot
    INSERT INTO neuroscience.trust_snapshots (contact_id, snapshot_date, trust_score, trust_delta, total_interactions)
    VALUES (p_contact_id, CURRENT_DATE, v_new_trust, v_trust_delta, 
            (SELECT total_interactions FROM neuroscience.trust_model WHERE contact_id = p_contact_id))
    ON CONFLICT (contact_id, snapshot_date) DO UPDATE
    SET trust_score = EXCLUDED.trust_score,
        trust_delta = EXCLUDED.trust_delta,
        total_interactions = EXCLUDED.total_interactions;
    
    RETURN v_new_trust;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION neuroscience.update_trust_score IS 'Bayesian trust update: (prior × weight + evidence) / (weight + 1)';

-- Function: Calculate trust velocity
CREATE OR REPLACE FUNCTION neuroscience.calculate_trust_velocity(p_contact_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_velocity DECIMAL;
BEGIN
    -- Linear regression on last 30 days of snapshots
    SELECT 
        COALESCE(
            REGR_SLOPE(trust_score, EXTRACT(EPOCH FROM snapshot_date - MIN(snapshot_date) OVER ())::NUMERIC),
            0
        ) * 604800 -- Convert to per-week
    INTO v_velocity
    FROM neuroscience.trust_snapshots
    WHERE contact_id = p_contact_id
      AND snapshot_date > CURRENT_DATE - INTERVAL '30 days';
    
    -- Update trust model
    UPDATE neuroscience.trust_model
    SET trust_velocity = v_velocity
    WHERE contact_id = p_contact_id;
    
    RETURN v_velocity;
END;
$$ LANGUAGE plpgsql;

-- Function: Trigger hormone event
CREATE OR REPLACE FUNCTION neuroscience.trigger_hormone(
    p_contact_id UUID,
    p_hormone_type VARCHAR,
    p_trigger_event VARCHAR,
    p_intensity DECIMAL DEFAULT 0.5
) RETURNS UUID AS $$
DECLARE
    v_hormone_event_id UUID;
    v_trust_impact DECIMAL;
BEGIN
    -- Calculate expected trust impact based on hormone type
    v_trust_impact := CASE p_hormone_type
        WHEN 'oxytocin' THEN p_intensity * 0.15 -- Bonding boosts trust
        WHEN 'dopamine' THEN p_intensity * 0.10 -- Reward reinforces
        WHEN 'cortisol' THEN p_intensity * -0.05 -- Stress damages trust
        ELSE 0
    END;
    
    -- Record hormone event
    INSERT INTO neuroscience.hormone_events (
        contact_id, hormone_type, trigger_event, intensity, trust_impact_predicted
    ) VALUES (
        p_contact_id, p_hormone_type, p_trigger_event, p_intensity, v_trust_impact
    )
    RETURNING hormone_event_id INTO v_hormone_event_id;
    
    RETURN v_hormone_event_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Calculate relationship debt total
CREATE OR REPLACE FUNCTION neuroscience.get_relationship_debt(p_contact_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_total_debt DECIMAL;
BEGIN
    SELECT COALESCE(SUM(debt_value), 0)
    INTO v_total_debt
    FROM neuroscience.relationship_debt
    WHERE contact_id = p_contact_id
      AND (reciprocity_expected = FALSE OR reciprocity_fulfilled = FALSE);
    
    RETURN v_total_debt;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Trust evolution dashboard
CREATE VIEW neuroscience.v_trust_evolution AS
SELECT 
    tm.contact_id,
    c.full_name,
    c.title,
    comp.company_name,
    tm.trust_score,
    tm.trust_velocity,
    tm.champion_probability,
    tm.total_interactions,
    tm.last_interaction_date,
    neuroscience.get_relationship_debt(tm.contact_id) AS relationship_debt
FROM neuroscience.trust_model tm
JOIN core.contacts c ON c.contact_id = tm.contact_id
JOIN core.companies comp ON comp.company_id = c.company_id
WHERE c.is_deleted = FALSE
ORDER BY tm.trust_score DESC;

-- High-potential champions
CREATE VIEW neuroscience.v_champion_candidates AS
SELECT 
    tm.contact_id,
    c.full_name,
    c.title,
    comp.company_name,
    tm.trust_score,
    tm.trust_velocity,
    tm.champion_probability,
    sc.champion_centrality_score,
    sc.hops_to_economic_buyer,
    neuroscience.get_relationship_debt(tm.contact_id) AS relationship_debt,
    CASE 
        WHEN tm.trust_score > 0.8 AND sc.champion_centrality_score > 0.7 THEN 'Tier 1 - High'
        WHEN tm.trust_score > 0.6 AND sc.champion_centrality_score > 0.5 THEN 'Tier 2 - Medium'
        WHEN tm.trust_score > 0.5 THEN 'Tier 3 - Developing'
        ELSE 'Tier 4 - Low'
    END AS champion_tier
FROM neuroscience.trust_model tm
JOIN core.contacts c ON c.contact_id = tm.contact_id
JOIN core.companies comp ON comp.company_id = c.company_id
LEFT JOIN LATERAL (
    SELECT * FROM neuroscience.stakeholder_centrality sc2
    WHERE sc2.contact_id = tm.contact_id
    ORDER BY sc2.calculated_at DESC LIMIT 1
) sc ON TRUE
WHERE c.is_deleted = FALSE
  AND tm.champion_probability > 0.3
ORDER BY tm.champion_probability DESC, tm.trust_score DESC;

-- ============================================================================
-- GRANTS
-- ============================================================================

GRANT USAGE ON SCHEMA neuroscience TO specter_app;
GRANT ALL ON ALL TABLES IN SCHEMA neuroscience TO specter_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA neuroscience TO specter_app;

-- ============================================================================
-- END OF NEUROSCIENCE SCHEMA
-- ============================================================================
