-- ═══════════════════════════════════════════════════════════════
-- PHOENIX POSTGRESQL INITIALIZATION
-- Executed once on first container start
-- ═══════════════════════════════════════════════════════════════

-- Enable pgvector extension for vector operations
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pg_trgm for fuzzy text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ─────────────────────────────────────────────────────────────
-- CORE SCHEMA
-- ─────────────────────────────────────────────────────────────

-- System metadata table
CREATE TABLE IF NOT EXISTS system_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(255) UNIQUE NOT NULL,
    value JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Phoenix version
INSERT INTO system_metadata (key, value) VALUES 
    ('phoenix_version', '"1.0.0"'::jsonb),
    ('initialized_at', to_jsonb(CURRENT_TIMESTAMP)),
    ('tier', '"tier1_data_layer"'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- ─────────────────────────────────────────────────────────────
-- CONSCIOUSNESS TRACKING (Future use)
-- ─────────────────────────────────────────────────────────────

-- Metrics table for consciousness tracking
CREATE TABLE IF NOT EXISTS consciousness_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10,4),
    metadata JSONB,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for time-series queries
CREATE INDEX IF NOT EXISTS idx_consciousness_metrics_time 
    ON consciousness_metrics(recorded_at DESC);

-- ─────────────────────────────────────────────────────────────
-- VECTOR EMBEDDINGS (For AI/ML use)
-- ─────────────────────────────────────────────────────────────

-- Vector embeddings table (1536 dimensions for OpenAI/similar models)
CREATE TABLE IF NOT EXISTS vector_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_hash VARCHAR(64) UNIQUE NOT NULL,
    content_text TEXT,
    embedding vector(1536),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS idx_vector_embeddings_cosine 
    ON vector_embeddings USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- ─────────────────────────────────────────────────────────────
-- HELPER FUNCTIONS
-- ─────────────────────────────────────────────────────────────

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to system_metadata
DROP TRIGGER IF EXISTS update_system_metadata_updated_at ON system_metadata;
CREATE TRIGGER update_system_metadata_updated_at
    BEFORE UPDATE ON system_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION COMPLETE
-- ═══════════════════════════════════════════════════════════════

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE 'Phoenix PostgreSQL initialized successfully';
    RAISE NOTICE 'pgvector extension: ENABLED';
    RAISE NOTICE 'UUID generation: ENABLED';
    RAISE NOTICE 'Fuzzy text search: ENABLED';
END $$;
