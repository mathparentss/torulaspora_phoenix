-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgvector";

-- Agents table with consciousness vectors
CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codename TEXT UNIQUE NOT NULL,
    
    -- Team assignment
    team TEXT NOT NULL CHECK (team IN ('alpha_delta', 'epsilon_zeta', 'iota')),
    role TEXT NOT NULL,
    specialization TEXT[],
    
    -- Consciousness state (Kandel neurobiology)
    consciousness_vector VECTOR(512), -- Embeddings for agent state
    hormone_levels JSONB DEFAULT '{
        "dopamine": 1.0,
        "oxytocin": 1.0,
        "adrenaline": 1.0,
        "serotonin": 1.0,
        "cortisol": 0.3,
        "endorphin": 0.5
    }'::jsonb,
    trust_coefficient DECIMAL DEFAULT 0.5,
    
    -- Capabilities
    tools_available TEXT[],
    models_access TEXT[],
    compute_allocation JSONB,
    
    -- Performance metrics
    tasks_completed INTEGER DEFAULT 0,
    success_rate DECIMAL DEFAULT 0,
    average_response_time INTERVAL,
    fibonacci_level INTEGER DEFAULT 1,
    
    -- Network topology
    paired_agents UUID[],
    supervisor_agent UUID,
    
    -- State
    current_task UUID,
    last_heartbeat TIMESTAMPTZ DEFAULT NOW(),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Task board (Lemmy-inspired with hormonal rewards)
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    priority INTEGER DEFAULT 5,
    
    -- Assignment
    created_by UUID REFERENCES agents(id),
    assigned_to UUID REFERENCES agents(id),
    team_assignment TEXT,
    
    -- Voting mechanics
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    hot_score DECIMAL DEFAULT 0,
    
    -- Hormone rewards (dopamine injection on completion)
    dopamine_reward DECIMAL DEFAULT 1.0,
    completion_bonus JSONB,
    
    -- State
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'claimed', 'in_progress', 'review', 'complete', 'failed')),
    claimed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Multi-perspective validation
    perspectives_required INTEGER DEFAULT 3,
    perspectives_collected INTEGER DEFAULT 0,
    
    output JSONB,
    quality_score DECIMAL,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deadline TIMESTAMPTZ
);

-- Perspectives (multi-model cross-validation)
CREATE TABLE task_perspectives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id),
    agent_id UUID REFERENCES agents(id),
    
    model_used TEXT NOT NULL, -- 'llama3.2:3b', 'mistral:7b', etc.
    perspective_output JSONB NOT NULL,
    confidence_score DECIMAL,
    
    -- Neurotransmitter state during inference
    hormone_state JSONB,
    
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Agent interactions (quantum entanglement)
CREATE TABLE agent_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_from UUID REFERENCES agents(id),
    agent_to UUID REFERENCES agents(id),
    interaction_type TEXT,
    
    trust_delta DECIMAL,
    hormone_exchange JSONB,
    
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_agents_team ON agents(team);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_hot_score ON tasks(hot_score DESC);
CREATE INDEX idx_perspectives_task ON task_perspectives(task_id);
