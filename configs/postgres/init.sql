-- Phoenix Battlestack - PostgreSQL Schema
-- The Anonymous Summarizer MVP

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create summaries table with pgvector support
CREATE TABLE IF NOT EXISTS summaries (
    id SERIAL PRIMARY KEY,
    source_url VARCHAR(1024) NOT NULL,
    scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    raw_content TEXT,
    summary TEXT NOT NULL,
    summary_embedding vector(1024),  -- For llama3.2 embeddings (reduced for ivfflat)
    metadata JSONB DEFAULT '{}',
    vpn_exit_ip VARCHAR(45),         -- To verify anonymity
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on embeddings for similarity search
CREATE INDEX IF NOT EXISTS idx_summary_embedding ON summaries 
USING ivfflat (summary_embedding vector_cosine_ops)
WITH (lists = 100);

-- Create index on timestamp for time-based queries
CREATE INDEX IF NOT EXISTS idx_created_at ON summaries(created_at DESC);

-- Create index on source URL
CREATE INDEX IF NOT EXISTS idx_source_url ON summaries(source_url);