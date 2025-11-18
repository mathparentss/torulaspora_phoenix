-- ============================================================================
-- PHOENIX SHADOW DATABASE - AGENTS SCHEMA
-- Agent Orchestration: Seekers → Oracles → Guardians → User
-- Version: 1.0.0
-- Purpose: Autonomous task processing with approval gates
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS agents;

-- ============================================================================
-- TABLE: agents.agent_registry
-- Purpose: Track all active agents (Seekers, Oracles, Guardians)
-- ============================================================================

CREATE TABLE agents.agent_registry (
    agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Agent Classification
    agent_class VARCHAR(50) NOT NULL, -- 'SEEKER', 'ORACLE', 'GUARDIAN'
    agent_type VARCHAR(100) NOT NULL, -- 'WebScout', 'ContactEnricher', 'DataValidator', etc.
    agent_name VARCHAR(200) NOT NULL,
    agent_version VARCHAR(20),
    
    -- Capabilities
    capabilities TEXT[], -- ["linkedin_scraping", "email_validation", "sentiment_analysis"]
    task_types_handled TEXT[], -- ["enrich_contact", "validate_company", "score_pain"]
    
    -- Status
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'paused', 'offline', 'error'
    is_enabled BOOLEAN DEFAULT TRUE,
    last_heartbeat TIMESTAMPTZ,
    
    -- Performance Metrics
    tasks_completed INTEGER DEFAULT 0,
    tasks_failed INTEGER DEFAULT 0,
    average_completion_time_seconds INTEGER,
    accuracy_score DECIMAL(3,2), -- 0-1 (Guardian approval rate)
    
    -- Dopamine Tracking (Gamification)
    dopamine_points INTEGER DEFAULT 0, -- Earned from completed tasks
    current_streak INTEGER DEFAULT 0, -- Consecutive successful tasks
    best_streak INTEGER DEFAULT 0,
    
    -- Configuration
    config JSONB, -- Agent-specific settings
    rate_limit_per_hour INTEGER,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT chk_agent_class CHECK (agent_class IN ('SEEKER', 'ORACLE', 'GUARDIAN')),
    CONSTRAINT chk_agent_status CHECK (status IN ('active', 'paused', 'offline', 'error')),
    CONSTRAINT chk_accuracy CHECK (accuracy_score BETWEEN 0 AND 1)
);

CREATE INDEX idx_agent_registry_class ON agents.agent_registry(agent_class) WHERE is_enabled = TRUE;
CREATE INDEX idx_agent_registry_type ON agents.agent_registry(agent_type) WHERE status = 'active';
CREATE INDEX idx_agent_registry_performance ON agents.agent_registry(accuracy_score DESC, tasks_completed DESC);

COMMENT ON TABLE agents.agent_registry IS 'Registry of all Seeker/Oracle/Guardian agents';
COMMENT ON COLUMN agents.agent_registry.dopamine_points IS 'Gamification: points earned from task completions';

-- ============================================================================
-- TABLE: agents.tasks
-- Purpose: Task queue with Fibonacci-based priority scoring
-- ============================================================================

CREATE TABLE agents.tasks (
    task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Task Classification
    task_type VARCHAR(100) NOT NULL, -- 'enrich_contact', 'validate_pain', 'map_influence', etc.
    task_category VARCHAR(50), -- 'data_enrichment', 'intelligence_gathering', 'validation'
    
    -- Task Details
    task_title VARCHAR(500) NOT NULL,
    task_description TEXT,
    task_payload JSONB NOT NULL, -- Full task context
    
    -- Target Entity
    target_entity_type VARCHAR(50), -- 'company', 'contact', 'opportunity'
    target_entity_id UUID,
    
    -- Priority Scoring (Fibonacci-weighted)
    urgency INTEGER CHECK (urgency BETWEEN 1 AND 7), -- Maps to Fibonacci: 1,1,2,3,5,8,13
    impact INTEGER CHECK (impact BETWEEN 1 AND 10), -- Business value
    difficulty DECIMAL(3,2) CHECK (difficulty BETWEEN 0.1 AND 1.0), -- Ease score
    priority_score DECIMAL(10,2) GENERATED ALWAYS AS (
        (CASE urgency
            WHEN 1 THEN 1
            WHEN 2 THEN 1
            WHEN 3 THEN 2
            WHEN 4 THEN 3
            WHEN 5 THEN 5
            WHEN 6 THEN 8
            WHEN 7 THEN 13
        END) * impact * (1.0 / difficulty)
    ) STORED,
    
    -- State Machine
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'assigned', 'in_progress', 'submitted', 'approved', 'rejected', 'failed'
    
    -- Assignment
    created_by_agent_id UUID REFERENCES agents.agent_registry(agent_id), -- SEEKER that created task
    assigned_to_agent_id UUID REFERENCES agents.agent_registry(agent_id), -- ORACLE working on it
    assigned_at TIMESTAMPTZ,
    
    -- Result
    result JSONB, -- Enriched data from ORACLE
    result_submitted_at TIMESTAMPTZ,
    
    -- Guardian Approval
    reviewed_by_agent_id UUID REFERENCES agents.agent_registry(agent_id), -- GUARDIAN who reviewed
    approved_at TIMESTAMPTZ,
    approval_notes TEXT,
    rejection_reason TEXT,
    quality_score DECIMAL(3,2), -- 0-1 (Guardian assessment)
    
    -- SLA Tracking
    created_at TIMESTAMPTZ DEFAULT NOW(),
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    time_to_complete_seconds INTEGER,
    is_overdue BOOLEAN GENERATED ALWAYS AS (
        CASE WHEN due_date IS NOT NULL AND completed_at IS NULL AND NOW() > due_date 
        THEN TRUE ELSE FALSE END
    ) STORED,
    
    -- Retry Logic
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    last_error TEXT,
    
    -- Dopamine Reward
    dopamine_reward INTEGER DEFAULT 10, -- Points earned on approval
    
    CONSTRAINT chk_task_status CHECK (status IN ('pending', 'assigned', 'in_progress', 'submitted', 'approved', 'rejected', 'failed')),
    CONSTRAINT chk_quality_score CHECK (quality_score BETWEEN 0 AND 1)
);

-- Indexes for task queue performance
CREATE INDEX idx_tasks_pending ON agents.tasks(priority_score DESC) WHERE status = 'pending';
CREATE INDEX idx_tasks_assigned ON agents.tasks(assigned_to_agent_id, status) WHERE status IN ('assigned', 'in_progress');
CREATE INDEX idx_tasks_submitted ON agents.tasks(task_id) WHERE status = 'submitted';
CREATE INDEX idx_tasks_overdue ON agents.tasks(task_id) WHERE is_overdue = TRUE;
CREATE INDEX idx_tasks_target ON agents.tasks(target_entity_type, target_entity_id);
CREATE INDEX idx_tasks_type ON agents.tasks(task_type);
CREATE INDEX idx_tasks_created ON agents.tasks(created_at DESC);

COMMENT ON TABLE agents.tasks IS 'Task queue with Fibonacci priority scoring and approval workflow';
COMMENT ON COLUMN agents.tasks.priority_score IS 'Fibonacci(urgency) × impact × (1/difficulty)';

-- ============================================================================
-- TABLE: agents.task_assignments
-- Purpose: Track Oracle task pickups (for concurrency control)
-- ============================================================================

CREATE TABLE agents.task_assignments (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES agents.tasks(task_id),
    agent_id UUID NOT NULL REFERENCES agents.agent_registry(agent_id),
    
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    heartbeat_at TIMESTAMPTZ DEFAULT NOW(),
    released_at TIMESTAMPTZ,
    
    -- Auto-release if Oracle goes silent
    is_stale BOOLEAN GENERATED ALWAYS AS (
        CASE WHEN released_at IS NULL AND heartbeat_at < NOW() - INTERVAL '10 minutes'
        THEN TRUE ELSE FALSE END
    ) STORED
);

CREATE INDEX idx_task_assignments_task ON agents.task_assignments(task_id) WHERE released_at IS NULL;
CREATE INDEX idx_task_assignments_agent ON agents.task_assignments(agent_id) WHERE released_at IS NULL;
CREATE INDEX idx_task_assignments_stale ON agents.task_assignments(assignment_id) WHERE is_stale = TRUE;

COMMENT ON TABLE agents.task_assignments IS 'Track active Oracle assignments with stale detection';

-- ============================================================================
-- TABLE: agents.approvals
-- Purpose: Guardian approval workflow
-- ============================================================================

CREATE TABLE agents.approvals (
    approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES agents.tasks(task_id),
    
    -- Guardian Review
    reviewed_by_agent_id UUID NOT NULL REFERENCES agents.agent_registry(agent_id),
    review_timestamp TIMESTAMPTZ DEFAULT NOW(),
    
    -- Decision
    decision VARCHAR(50) NOT NULL, -- 'approved', 'rejected', 'request_changes'
    quality_score DECIMAL(3,2), -- 0-1
    confidence_score DECIMAL(3,2), -- How confident is Guardian?
    
    -- Validation Checks
    validation_results JSONB, -- [{"check": "completeness", "passed": true}, {...}]
    issues_found TEXT[],
    feedback TEXT,
    
    -- Approval Metadata
    approval_duration_seconds INTEGER,
    
    CONSTRAINT chk_decision CHECK (decision IN ('approved', 'rejected', 'request_changes')),
    CONSTRAINT chk_quality CHECK (quality_score BETWEEN 0 AND 1),
    CONSTRAINT chk_confidence CHECK (confidence_score BETWEEN 0 AND 1)
);

CREATE INDEX idx_approvals_task ON agents.approvals(task_id);
CREATE INDEX idx_approvals_guardian ON agents.approvals(reviewed_by_agent_id);
CREATE INDEX idx_approvals_decision ON agents.approvals(decision);
CREATE INDEX idx_approvals_timestamp ON agents.approvals(review_timestamp DESC);

-- ============================================================================
-- TABLE: agents.agent_performance
-- Purpose: Track agent performance metrics over time
-- ============================================================================

CREATE TABLE agents.agent_performance (
    performance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID NOT NULL REFERENCES agents.agent_registry(agent_id),
    
    -- Time Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Volume Metrics
    tasks_attempted INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    tasks_approved INTEGER DEFAULT 0,
    tasks_rejected INTEGER DEFAULT 0,
    
    -- Quality Metrics
    average_quality_score DECIMAL(3,2),
    average_confidence_score DECIMAL(3,2),
    approval_rate DECIMAL(5,2), -- tasks_approved / tasks_completed
    
    -- Speed Metrics
    average_completion_time_seconds INTEGER,
    median_completion_time_seconds INTEGER,
    
    -- Dopamine Earned
    total_dopamine_earned INTEGER DEFAULT 0,
    
    -- Calculated Metrics
    efficiency_score DECIMAL(3,2), -- Quality × Speed
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_performance_agent ON agents.agent_performance(agent_id, period_start DESC);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Assign task to Oracle (with concurrency control)
CREATE OR REPLACE FUNCTION agents.assign_task_to_oracle(
    p_task_id UUID,
    p_agent_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_assigned BOOLEAN := FALSE;
BEGIN
    -- Attempt to claim task (atomic)
    UPDATE agents.tasks
    SET status = 'assigned',
        assigned_to_agent_id = p_agent_id,
        assigned_at = NOW()
    WHERE task_id = p_task_id
      AND status = 'pending'
    RETURNING TRUE INTO v_assigned;
    
    IF v_assigned THEN
        -- Create assignment record
        INSERT INTO agents.task_assignments (task_id, agent_id)
        VALUES (p_task_id, p_agent_id);
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function: Submit task for Guardian approval
CREATE OR REPLACE FUNCTION agents.submit_task_for_approval(
    p_task_id UUID,
    p_result JSONB
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE agents.tasks
    SET status = 'submitted',
        result = p_result,
        result_submitted_at = NOW(),
        time_to_complete_seconds = EXTRACT(EPOCH FROM (NOW() - assigned_at))::INTEGER
    WHERE task_id = p_task_id
      AND status IN ('assigned', 'in_progress');
    
    IF FOUND THEN
        -- Release assignment
        UPDATE agents.task_assignments
        SET released_at = NOW()
        WHERE task_id = p_task_id AND released_at IS NULL;
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function: Guardian approves task
CREATE OR REPLACE FUNCTION agents.approve_task(
    p_task_id UUID,
    p_guardian_id UUID,
    p_quality_score DECIMAL,
    p_feedback TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_dopamine_reward INTEGER;
    v_oracle_id UUID;
BEGIN
    -- Get Oracle and reward
    SELECT assigned_to_agent_id, dopamine_reward
    INTO v_oracle_id, v_dopamine_reward
    FROM agents.tasks
    WHERE task_id = p_task_id;
    
    -- Update task
    UPDATE agents.tasks
    SET status = 'approved',
        reviewed_by_agent_id = p_guardian_id,
        approved_at = NOW(),
        quality_score = p_quality_score,
        approval_notes = p_feedback,
        completed_at = NOW()
    WHERE task_id = p_task_id
      AND status = 'submitted';
    
    IF FOUND THEN
        -- Record approval
        INSERT INTO agents.approvals (task_id, reviewed_by_agent_id, decision, quality_score)
        VALUES (p_task_id, p_guardian_id, 'approved', p_quality_score);
        
        -- Award dopamine to Oracle
        UPDATE agents.agent_registry
        SET dopamine_points = dopamine_points + v_dopamine_reward,
            tasks_completed = tasks_completed + 1,
            current_streak = current_streak + 1,
            best_streak = GREATEST(best_streak, current_streak + 1),
            accuracy_score = (
                COALESCE(accuracy_score * tasks_completed, 0) + p_quality_score
            ) / (tasks_completed + 1)
        WHERE agent_id = v_oracle_id;
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function: Guardian rejects task
CREATE OR REPLACE FUNCTION agents.reject_task(
    p_task_id UUID,
    p_guardian_id UUID,
    p_reason TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    v_oracle_id UUID;
BEGIN
    SELECT assigned_to_agent_id INTO v_oracle_id
    FROM agents.tasks WHERE task_id = p_task_id;
    
    -- Reset task to pending (Oracle can retry)
    UPDATE agents.tasks
    SET status = 'pending',
        reviewed_by_agent_id = p_guardian_id,
        rejection_reason = p_reason,
        retry_count = retry_count + 1,
        assigned_to_agent_id = NULL,
        assigned_at = NULL
    WHERE task_id = p_task_id
      AND status = 'submitted';
    
    IF FOUND THEN
        -- Record rejection
        INSERT INTO agents.approvals (task_id, reviewed_by_agent_id, decision, feedback)
        VALUES (p_task_id, p_guardian_id, 'rejected', p_reason);
        
        -- Break Oracle's streak
        UPDATE agents.agent_registry
        SET current_streak = 0,
            tasks_failed = tasks_failed + 1
        WHERE agent_id = v_oracle_id;
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function: Get top priority tasks for Oracle
CREATE OR REPLACE FUNCTION agents.get_top_tasks(
    p_agent_id UUID,
    p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
    task_id UUID,
    task_type VARCHAR,
    task_title VARCHAR,
    priority_score DECIMAL,
    urgency INTEGER,
    due_date TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.task_id,
        t.task_type,
        t.task_title,
        t.priority_score,
        t.urgency,
        t.due_date
    FROM agents.tasks t
    JOIN agents.agent_registry a ON a.agent_id = p_agent_id
    WHERE t.status = 'pending'
      AND t.task_type = ANY(a.task_types_handled)
      AND (t.retry_count < t.max_retries)
    ORDER BY t.priority_score DESC, t.created_at ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Active tasks dashboard
CREATE VIEW agents.v_active_tasks AS
SELECT 
    t.task_id,
    t.task_type,
    t.task_title,
    t.status,
    t.priority_score,
    t.urgency,
    t.created_at,
    t.assigned_at,
    t.is_overdue,
    oracle.agent_name AS assigned_to_oracle,
    seeker.agent_name AS created_by_seeker
FROM agents.tasks t
LEFT JOIN agents.agent_registry oracle ON oracle.agent_id = t.assigned_to_agent_id
LEFT JOIN agents.agent_registry seeker ON seeker.agent_id = t.created_by_agent_id
WHERE t.status NOT IN ('approved', 'failed')
ORDER BY t.priority_score DESC;

-- Agent leaderboard
CREATE VIEW agents.v_agent_leaderboard AS
SELECT 
    a.agent_name,
    a.agent_class,
    a.dopamine_points,
    a.current_streak,
    a.best_streak,
    a.tasks_completed,
    a.accuracy_score,
    RANK() OVER (PARTITION BY a.agent_class ORDER BY a.dopamine_points DESC) AS rank_in_class
FROM agents.agent_registry a
WHERE a.is_enabled = TRUE
ORDER BY a.dopamine_points DESC;

-- ============================================================================
-- GRANTS
-- ============================================================================

GRANT USAGE ON SCHEMA agents TO specter_app;
GRANT ALL ON ALL TABLES IN SCHEMA agents TO specter_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA agents TO specter_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA agents TO specter_app;

-- ============================================================================
-- END OF AGENTS SCHEMA
-- ============================================================================
