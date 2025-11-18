-- ============================================================================
-- PHOENIX SHADOW DATABASE - ENRICHMENT + PRODUCTS SCHEMA
-- AI/ML Outputs + Batory Product Catalog
-- Version: 1.0.0
-- Purpose: Machine-generated insights + product recommendations
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS enrichment;
CREATE SCHEMA IF NOT EXISTS products;

-- Enable pgvector extension for semantic search
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================================
-- ENRICHMENT SCHEMA: AI/ML OUTPUTS
-- ============================================================================

-- TABLE: enrichment.pain_embeddings
-- Purpose: Vector embeddings of company pain points for semantic matching
CREATE TABLE enrichment.pain_embeddings (
    embedding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES core.companies(company_id) ON DELETE CASCADE,
    
    -- Pain Description
    pain_text TEXT NOT NULL,
    pain_category VARCHAR(100), -- 'cost', 'quality', 'reliability', 'compliance'
    
    -- Vector Embedding (1536 dimensions for OpenAI ada-002)
    embedding vector(1536) NOT NULL,
    
    -- Metadata
    model_name VARCHAR(100) DEFAULT 'text-embedding-ada-002',
    model_version VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pain_embeddings_company ON enrichment.pain_embeddings(company_id);
CREATE INDEX idx_pain_embeddings_vector ON enrichment.pain_embeddings USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- TABLE: enrichment.solution_embeddings
-- Purpose: Vector embeddings of product solutions
CREATE TABLE enrichment.solution_embeddings (
    embedding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    
    -- Solution Description
    solution_text TEXT NOT NULL,
    solution_category VARCHAR(100),
    
    -- Vector Embedding
    embedding vector(1536) NOT NULL,
    
    -- Metadata
    model_name VARCHAR(100) DEFAULT 'text-embedding-ada-002',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_solution_embeddings_product ON enrichment.solution_embeddings(product_id);
CREATE INDEX idx_solution_embeddings_vector ON enrichment.solution_embeddings USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- TABLE: enrichment.ai_scores
-- Purpose: ML model outputs (propensity to buy, churn risk, etc.)
CREATE TABLE enrichment.ai_scores (
    score_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'company', 'contact', 'opportunity'
    entity_id UUID NOT NULL,
    
    -- Score Details
    score_type VARCHAR(100) NOT NULL, -- 'propensity_to_buy', 'churn_risk', 'lifetime_value'
    score_value DECIMAL(5,3) NOT NULL CHECK (score_value BETWEEN 0 AND 1),
    confidence_interval JSONB, -- {"lower": 0.65, "upper": 0.85}
    
    -- Model Metadata
    model_name VARCHAR(200) NOT NULL,
    model_version VARCHAR(50),
    feature_importance JSONB, -- Which features drove this score?
    
    -- Temporal
    scored_at TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ, -- When does this score expire?
    
    CONSTRAINT chk_entity_type CHECK (entity_type IN ('company', 'contact', 'opportunity'))
);

CREATE INDEX idx_ai_scores_entity ON enrichment.ai_scores(entity_type, entity_id, score_type);
CREATE INDEX idx_ai_scores_type ON enrichment.ai_scores(score_type, score_value DESC);
CREATE INDEX idx_ai_scores_valid ON enrichment.ai_scores(entity_id) WHERE valid_until > NOW();

-- TABLE: enrichment.product_recommendations
-- Purpose: Personalized product suggestions per company
CREATE TABLE enrichment.product_recommendations (
    recommendation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES core.companies(company_id) ON DELETE CASCADE,
    product_id UUID NOT NULL,
    
    -- Recommendation Score
    relevance_score DECIMAL(5,3) CHECK (relevance_score BETWEEN 0 AND 1),
    confidence_score DECIMAL(5,3) CHECK (confidence_score BETWEEN 0 AND 1),
    
    -- Reasoning
    recommendation_reasons TEXT[], -- ["Matches pain point: cost reduction", "Similar to current usage"]
    semantic_similarity DECIMAL(5,3), -- Cosine similarity from embeddings
    
    -- Historical Performance
    times_recommended INTEGER DEFAULT 1,
    times_clicked INTEGER DEFAULT 0,
    times_won INTEGER DEFAULT 0,
    won BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    recommended_at TIMESTAMPTZ DEFAULT NOW(),
    model_version VARCHAR(50)
);

CREATE INDEX idx_product_recs_company ON enrichment.product_recommendations(company_id, relevance_score DESC);
CREATE INDEX idx_product_recs_product ON enrichment.product_recommendations(product_id);
CREATE INDEX idx_product_recs_won ON enrichment.product_recommendations(company_id) WHERE won = TRUE;

-- TABLE: enrichment.sentiment_analysis
-- Purpose: Sentiment tracking from emails/meetings
CREATE TABLE enrichment.sentiment_analysis (
    sentiment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    interaction_id UUID NOT NULL REFERENCES events.interactions(interaction_id) ON DELETE CASCADE,
    
    -- Sentiment Scores
    overall_sentiment DECIMAL(3,2) CHECK (overall_sentiment BETWEEN -1 AND 1),
    confidence DECIMAL(3,2) CHECK (confidence BETWEEN 0 AND 1),
    
    -- Granular Sentiment
    sentiment_breakdown JSONB, -- {"enthusiasm": 0.8, "concern": 0.2, "urgency": 0.6}
    key_phrases TEXT[], -- Phrases that drove sentiment
    
    -- Metadata
    model_name VARCHAR(100),
    analyzed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sentiment_interaction ON enrichment.sentiment_analysis(interaction_id);
CREATE INDEX idx_sentiment_score ON enrichment.sentiment_analysis(overall_sentiment DESC);

-- ============================================================================
-- PRODUCTS SCHEMA: BATORY CATALOG
-- ============================================================================

-- TABLE: products.catalog
-- Purpose: Full Batory product catalog (3,710 SKUs)
CREATE TABLE products.catalog (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Product Info
    item_id VARCHAR(50) UNIQUE NOT NULL, -- Batory internal SKU
    item_description VARCHAR(500),
    
    -- Classification
    health_canada_category VARCHAR(200), -- "Starches", "Maltodextrins", etc.
    product_family VARCHAR(200),
    product_subcategory VARCHAR(200),
    
    -- Applications
    applications TEXT[], -- ["Bakery", "Beverages", "Confectionery"]
    target_markets TEXT[], -- ["Retail", "Foodservice", "Industrial"]
    
    -- Specifications
    cas_number VARCHAR(50),
    chemical_formula VARCHAR(200),
    molecular_weight DECIMAL(10,3),
    appearance TEXT,
    solubility TEXT,
    
    -- Regulatory
    certifications TEXT[], -- ["GFSI", "Organic", "Kosher", "Halal"]
    allergens TEXT[],
    gmo_status VARCHAR(50), -- "Non-GMO", "GMO", "Unknown"
    regulatory_status VARCHAR(100), -- "GRAS", "Food Additive", "Natural"
    
    -- Packaging & Logistics
    packaging_options TEXT[], -- ["25kg bag", "1000kg tote", "bulk tanker"]
    shelf_life_months INTEGER,
    storage_conditions TEXT,
    
    -- Pricing (historical tracking)
    current_price_per_kg DECIMAL(10,2),
    average_cost_current_month DECIMAL(10,2),
    price_trend VARCHAR(50), -- "Increasing", "Stable", "Decreasing"
    currency VARCHAR(3) DEFAULT 'CAD',
    
    -- Availability
    is_active BOOLEAN DEFAULT TRUE,
    is_discontinued BOOLEAN DEFAULT FALSE,
    lead_time_days INTEGER,
    minimum_order_quantity DECIMAL(10,2),
    
    -- Priority (for recommendations)
    priority_code VARCHAR(20), -- "A" (high margin), "B", "C"
    strategic_importance VARCHAR(50), -- "Core", "Growth", "Specialty", "Commodity"
    
    -- Full-Text Search
    search_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', 
            COALESCE(item_description, '') || ' ' ||
            COALESCE(health_canada_category, '') || ' ' ||
            COALESCE(array_to_string(applications, ' '), '')
        )
    ) STORED,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_item_id ON products.catalog(item_id);
CREATE INDEX idx_products_health_canada ON products.catalog(health_canada_category);
CREATE INDEX idx_products_active ON products.catalog(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_search ON products.catalog USING gin(search_vector);
CREATE INDEX idx_products_applications ON products.catalog USING gin(applications);
CREATE INDEX idx_products_priority ON products.catalog(priority_code, strategic_importance);

COMMENT ON TABLE products.catalog IS 'Full Batory product catalog (3,710 SKUs)';
COMMENT ON COLUMN products.catalog.priority_code IS 'A=high margin, B=medium, C=commodity';

-- TABLE: products.health_canada_categories
-- Purpose: Health Canada regulatory category mappings
CREATE TABLE products.health_canada_categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(200) UNIQUE NOT NULL,
    category_code VARCHAR(50),
    
    -- Hierarchy
    parent_category VARCHAR(200),
    category_level INTEGER, -- 1 (top), 2 (sub), 3 (detail)
    
    -- Regulatory
    regulatory_requirements TEXT,
    typical_applications TEXT[],
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_health_canada_name ON products.health_canada_categories(category_name);
CREATE INDEX idx_health_canada_parent ON products.health_canada_categories(parent_category);

-- TABLE: products.product_alternatives
-- Purpose: Product substitution mapping
CREATE TABLE products.product_alternatives (
    alternative_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    primary_product_id UUID NOT NULL REFERENCES products.catalog(product_id),
    alternative_product_id UUID NOT NULL REFERENCES products.catalog(product_id),
    
    -- Substitution Details
    substitution_ratio VARCHAR(50), -- "1:1", "1:1.2", "Consult R&D"
    performance_comparison VARCHAR(50), -- "Equivalent", "Superior", "Acceptable"
    cost_comparison VARCHAR(50), -- "Similar", "Lower", "Higher"
    
    -- Context
    use_case TEXT, -- When to recommend this alternative
    technical_notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT chk_no_self_alternative CHECK (primary_product_id != alternative_product_id)
);

CREATE INDEX idx_product_alternatives_primary ON products.product_alternatives(primary_product_id);
CREATE INDEX idx_product_alternatives_alt ON products.product_alternatives(alternative_product_id);

-- TABLE: products.competitive_products
-- Purpose: Map our products to competitor equivalents
CREATE TABLE products.competitive_products (
    competitive_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    our_product_id UUID NOT NULL REFERENCES products.catalog(product_id),
    
    competitor_name VARCHAR(200) NOT NULL,
    competitor_product_name VARCHAR(500),
    competitor_sku VARCHAR(100),
    
    -- Competitive Analysis
    our_advantages TEXT[],
    their_advantages TEXT[],
    price_comparison VARCHAR(50), -- "We're lower", "Similar", "We're higher"
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_competitive_products_our ON products.competitive_products(our_product_id);
CREATE INDEX idx_competitive_products_competitor ON products.competitive_products(competitor_name);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Find products matching company pain (semantic search)
CREATE OR REPLACE FUNCTION enrichment.match_products_to_pain(
    p_company_id UUID,
    p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
    product_id UUID,
    product_name VARCHAR,
    similarity_score DECIMAL,
    recommendation_reasons TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.product_id,
        p.item_description::VARCHAR,
        (1 - (s.embedding <=> pain.embedding))::DECIMAL AS similarity,
        ARRAY['Semantic match to pain point: ' || pain.pain_text]::TEXT[] AS reasons
    FROM enrichment.pain_embeddings pain
    CROSS JOIN enrichment.solution_embeddings s
    JOIN products.catalog p ON p.product_id = s.product_id
    WHERE pain.company_id = p_company_id
      AND p.is_active = TRUE
    ORDER BY (1 - (s.embedding <=> pain.embedding)) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function: Generate product recommendation
CREATE OR REPLACE FUNCTION enrichment.recommend_product(
    p_company_id UUID,
    p_product_id UUID,
    p_relevance_score DECIMAL,
    p_reasons TEXT[]
) RETURNS UUID AS $$
DECLARE
    v_recommendation_id UUID;
BEGIN
    INSERT INTO enrichment.product_recommendations (
        company_id, product_id, relevance_score, recommendation_reasons
    ) VALUES (
        p_company_id, p_product_id, p_relevance_score, p_reasons
    )
    RETURNING recommendation_id INTO v_recommendation_id;
    
    RETURN v_recommendation_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Top products by priority
CREATE VIEW products.v_priority_products AS
SELECT 
    p.product_id,
    p.item_id,
    p.item_description,
    p.health_canada_category,
    p.applications,
    p.priority_code,
    p.strategic_importance,
    p.current_price_per_kg,
    p.lead_time_days
FROM products.catalog p
WHERE p.is_active = TRUE
  AND p.is_discontinued = FALSE
ORDER BY 
    CASE p.priority_code
        WHEN 'A' THEN 1
        WHEN 'B' THEN 2
        WHEN 'C' THEN 3
        ELSE 4
    END,
    p.strategic_importance;

-- Product recommendations dashboard
CREATE VIEW enrichment.v_product_recommendations AS
SELECT 
    r.recommendation_id,
    c.company_name,
    p.item_description AS product_name,
    r.relevance_score,
    r.confidence_score,
    r.recommendation_reasons,
    r.times_recommended,
    r.times_won,
    r.recommended_at
FROM enrichment.product_recommendations r
JOIN core.companies c ON c.company_id = r.company_id
JOIN products.catalog p ON p.product_id = r.product_id
WHERE r.recommended_at > NOW() - INTERVAL '90 days'
ORDER BY r.relevance_score DESC;

-- ============================================================================
-- GRANTS
-- ============================================================================

GRANT USAGE ON SCHEMA enrichment TO specter_app;
GRANT USAGE ON SCHEMA products TO specter_app;
GRANT ALL ON ALL TABLES IN SCHEMA enrichment TO specter_app;
GRANT ALL ON ALL TABLES IN SCHEMA products TO specter_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA enrichment TO specter_app;

-- ============================================================================
-- END OF ENRICHMENT + PRODUCTS SCHEMA
-- ============================================================================
