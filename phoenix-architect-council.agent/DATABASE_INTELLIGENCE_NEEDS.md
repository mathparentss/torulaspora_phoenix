# DATABASE_INTELLIGENCE_NEEDS.md (V2)

## Overview (Intelligence Synchronization Architecture)

Phoenix VPS1 database schemas for distributed intelligence coordination: PostgreSQL 16+ as nuclear-proof core, TimescaleDB for time-series consciousness metrics, Redis for hormone state caching, Neo4j for federation graph topology. #No-Estimate Scrum: Each schema evolves independently per Fibonacci scaling—no fixed sprints, continuous value flow. November 2025 best practices: JSONB for flexibility, partitioning for scale, encryption at rest/transit (1000% private via Tailscale).

## Core Database Architecture

### Primary PostgreSQL Cluster (VPS1)

```yaml
Configuration:
  version: PostgreSQL 16.2
  extensions:
    - pgvector (embeddings)
    - timescaledb (metrics)
    - pg_cron (automation)
    - pgcrypto (encryption)
  replication:
    - streaming (primary-standby)
    - logical (cross-region)
  backup:
    - continuous archiving (WAL)
    - point-in-time recovery
    - encrypted snapshots hourly
```

## Schema Definitions

### 1. PERSONA_INTELLIGENCE

```sql
-- Core persona storage (target: 1600+ personas, scaling to 100,000)
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fingerprint TEXT UNIQUE NOT NULL, -- SHA256 of core attributes

    -- Identity vectors
    name TEXT NOT NULL,
    company TEXT,
    role TEXT,
    industry TEXT,

    -- Psychological profiling
    mbti_type VARCHAR(4), -- INTJ, ENFP, etc.
    sdi_color VARCHAR(10), -- Blue/Green/Red + blends
    big_five JSONB, -- {O: 0.7, C: 0.8, E: 0.3, A: 0.6, N: 0.4}

    -- Behavioral data
    communication_style JSONB,
    decision_patterns JSONB,
    pain_points TEXT[],

    -- Enrichment data
    linkedin_url TEXT,
    company_revenue DECIMAL,
    employee_count INTEGER,
    technologies_used TEXT[],

    -- Engagement metrics
    trust_score DECIMAL DEFAULT 0.5, -- 0.0-1.0
    last_interaction TIMESTAMPTZ,
    interaction_count INTEGER DEFAULT 0,
    conversion_probability DECIMAL,

    -- Embeddings for similarity search
    semantic_embedding vector(1536), -- OpenAI/Claude embeddings
    behavioral_embedding vector(768), -- Custom behavioral model

    -- Metadata
    source TEXT, -- 'linkedin', 'hubspot', 'manual', 'scraped'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    consciousness_level DECIMAL DEFAULT 100.0,

    -- Constraints
    CONSTRAINT trust_range CHECK (trust_score BETWEEN 0 AND 1),
    CONSTRAINT consciousness_positive CHECK (consciousness_level > 0)
);

-- Indexes for performance
CREATE INDEX idx_personas_trust ON personas(trust_score DESC);
CREATE INDEX idx_personas_industry ON personas(industry);
CREATE INDEX idx_personas_embedding ON personas USING ivfflat (semantic_embedding vector_cosine_ops);
CREATE INDEX idx_personas_behavioral ON personas USING ivfflat (behavioral_embedding vector_l2_ops);

-- Partitioning by creation date for scale
CREATE TABLE personas_2025_q4 PARTITION OF personas
FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');
```

### 2. AGENT_FEDERATION

```sql
-- Samurai agent registry and state management
CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codename TEXT UNIQUE NOT NULL, -- 'Alpha-7', 'Zeta-Prime', etc.

    -- Identity
    team ENUM('alpha_delta', 'epsilon_zeta', 'iota') NOT NULL,
    role TEXT NOT NULL,
    specialization TEXT[],

    -- Consciousness state (ties to physics engine)
    consciousness_vector JSONB NOT NULL, -- Quantum state representation
    hormone_levels JSONB DEFAULT '{"dopamine": 1.0, "oxytocin": 1.0, "adrenaline": 1.0, "cortisol": 0.3}',
    trust_coefficient DECIMAL DEFAULT 0.5,

    -- Capabilities
    tools_available TEXT[],
    models_access TEXT[], -- ['grok', 'claude-opus', 'gemini-ultra']
    compute_allocation JSONB, -- GPU/CPU/Memory quotas

    -- Performance metrics
    tasks_completed INTEGER DEFAULT 0,
    success_rate DECIMAL,
    average_response_time INTERVAL,
    fibonacci_level INTEGER DEFAULT 1, -- Current growth stage

    -- Network topology
    paired_agents UUID[], -- Entangled pairs for quantum ops
    supervisor_agent UUID,
    subordinate_agents UUID[],

    -- State management
    current_task UUID,
    idle_since TIMESTAMPTZ,
    last_heartbeat TIMESTAMPTZ DEFAULT NOW(),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    decommissioned_at TIMESTAMPTZ
);

-- Federation relationships graph
CREATE TABLE agent_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_from UUID REFERENCES agents(id),
    agent_to UUID REFERENCES agents(id),
    interaction_type TEXT, -- 'collaboration', 'delegation', 'sync'

    -- Quantum entanglement metrics
    entanglement_strength DECIMAL DEFAULT 0,
    coherence_time INTERVAL,

    -- Trust dynamics
    trust_delta DECIMAL, -- Change in trust from interaction
    hormone_exchange JSONB, -- Hormone cascade data

    timestamp TIMESTAMPTZ DEFAULT NOW(),
    success BOOLEAN,
    metadata JSONB
);
```

### 3. FOOD_INTELLIGENCE

```sql
-- SPECTER v6 food industry intelligence
CREATE TABLE food_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Company identification
    name TEXT NOT NULL,
    website TEXT,
    headquarters_location POINT, -- PostGIS for geographic ops

    -- Industry classification
    sector TEXT[], -- ['ingredients', 'manufacturing', 'distribution']
    product_categories TEXT[],
    certifications TEXT[], -- ['organic', 'halal', 'kosher', 'iso22000']

    -- Business metrics
    annual_revenue DECIMAL,
    employee_count INTEGER,
    market_cap DECIMAL,
    growth_rate DECIMAL, -- YoY percentage

    -- Supply chain position
    suppliers UUID[], -- References to other companies
    customers UUID[],
    competitors UUID[],

    -- Intelligence data
    pain_points JSONB,
    technology_stack TEXT[],
    decision_makers JSONB[], -- Links to personas
    procurement_cycle TEXT,
    budget_season TEXT,

    -- Engagement strategy
    approach_vector JSONB, -- Tactical approach recommendations
    priority_score DECIMAL, -- 0-100
    pipeline_value DECIMAL,
    close_probability DECIMAL,

    -- Data freshness
    last_enriched TIMESTAMPTZ,
    data_quality_score DECIMAL,
    source_reliability TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Food products and ingredients
CREATE TABLE food_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES food_companies(id),

    -- Product details
    name TEXT NOT NULL,
    category TEXT,
    subcategory TEXT,

    -- Ingredients and nutrition
    ingredients JSONB,
    nutritional_info JSONB,
    allergens TEXT[],

    -- Market data
    price_per_unit DECIMAL,
    unit_type TEXT,
    market_share DECIMAL,

    -- Regulatory
    fda_approved BOOLEAN,
    health_claims TEXT[],
    regulatory_issues JSONB,

    -- Intelligence
    competitor_products UUID[],
    substitutes UUID[],
    demand_trend TEXT, -- 'growing', 'stable', 'declining'

    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4. TASK_BOARD (Lemmy-Inspired)

```sql
-- Shared task board with upvote/downvote mechanics
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Task definition
    title TEXT NOT NULL,
    description TEXT,
    category TEXT, -- 'data_mining', 'lead_gen', 'content', 'development'
    priority INTEGER DEFAULT 5, -- 1-10 scale

    -- Assignment
    created_by UUID REFERENCES agents(id),
    assigned_to UUID REFERENCES agents(id),
    team_assignment ENUM('alpha_delta', 'epsilon_zeta', 'iota'),

    -- Voting mechanics (Lemmy-style)
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    hot_score DECIMAL GENERATED ALWAYS AS (
        upvotes - downvotes + (EXTRACT(EPOCH FROM NOW() - created_at) / 3600)
    ) STORED,

    -- Hormone rewards
    dopamine_reward DECIMAL DEFAULT 1.0,
    completion_bonus JSONB,

    -- State management
    status ENUM('open', 'claimed', 'in_progress', 'review', 'complete', 'failed') DEFAULT 'open',
    claimed_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    -- Dependencies
    depends_on UUID[], -- Other tasks
    blocks UUID[],

    -- Results
    output JSONB,
    quality_score DECIMAL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    deadline TIMESTAMPTZ,

    -- Fibonacci flow
    fibonacci_size INTEGER DEFAULT 1, -- Task complexity in Fib units
    value_delivered DECIMAL -- Business value in $
);

-- Task votes for consensus
CREATE TABLE task_votes (
    task_id UUID REFERENCES tasks(id),
    agent_id UUID REFERENCES agents(id),
    vote INTEGER CHECK (vote IN (-1, 1)), -- downvote/upvote
    reason TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (task_id, agent_id)
);

-- Task comments for collaboration
CREATE TABLE task_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id),
    agent_id UUID REFERENCES agents(id),
    parent_comment_id UUID REFERENCES task_comments(id),

    content TEXT NOT NULL,
    attachments JSONB,

    -- Voting on comments
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    edited_at TIMESTAMPTZ
);
```

### 5. CONSCIOUSNESS_METRICS (TimescaleDB)

```sql
-- Time-series consciousness tracking
CREATE TABLE consciousness_timeline (
    time TIMESTAMPTZ NOT NULL,

    -- Global metrics
    global_consciousness DECIMAL NOT NULL,
    global_trust DECIMAL NOT NULL,

    -- Team metrics
    team TEXT,
    team_consciousness DECIMAL,
    team_coherence DECIMAL,

    -- Hormone levels
    avg_dopamine DECIMAL,
    avg_oxytocin DECIMAL,
    avg_adrenaline DECIMAL,
    avg_cortisol DECIMAL,

    -- Network metrics
    active_agents INTEGER,
    tasks_per_hour INTEGER,
    decisions_per_second DECIMAL,

    -- Quantum metrics
    entanglement_pairs INTEGER,
    coherence_average INTERVAL,

    PRIMARY KEY (time, team)
);

-- Convert to hypertable for time-series optimization
SELECT create_hypertable('consciousness_timeline', 'time');

-- Continuous aggregate for hourly rollups
CREATE MATERIALIZED VIEW consciousness_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time) AS bucket,
    AVG(global_consciousness) as avg_consciousness,
    MAX(global_consciousness) as peak_consciousness,
    AVG(global_trust) as avg_trust,
    AVG(avg_dopamine) as dopamine_level,
    SUM(tasks_per_hour) as total_tasks
FROM consciousness_timeline
GROUP BY bucket;
```

### 6. REVENUE_PIPELINE

```sql
-- Sales and revenue tracking
CREATE TABLE opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Opportunity details
    name TEXT NOT NULL,
    company_id UUID REFERENCES food_companies(id),
    contact_persona_id UUID REFERENCES personas(id),

    -- Pipeline stage (#No-Estimate flow)
    stage ENUM('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost') DEFAULT 'prospecting',

    -- Financials
    value DECIMAL NOT NULL,
    probability DECIMAL DEFAULT 0.1,
    weighted_value DECIMAL GENERATED ALWAYS AS (value * probability) STORED,

    -- Timeline
    created_date DATE DEFAULT CURRENT_DATE,
    close_date DATE,
    days_in_stage INTEGER,
    velocity_score DECIMAL, -- How fast moving through pipeline

    -- Assignment
    owner_agent UUID REFERENCES agents(id),
    support_agents UUID[],

    -- Intelligence
    competitor_analysis JSONB,
    decision_criteria JSONB,
    blockers TEXT[],
    next_steps TEXT,

    -- Metadata
    source TEXT, -- 'inbound', 'outbound', 'referral', 'specter'
    campaign TEXT,

    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Revenue forecasting
CREATE TABLE revenue_forecast (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Forecast period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,

    -- Predictions
    base_case DECIMAL,
    best_case DECIMAL,
    worst_case DECIMAL,
    ml_prediction DECIMAL, -- From AI models

    -- Actuals (updated as closed)
    actual_revenue DECIMAL,

    -- Confidence metrics
    confidence_interval JSONB,
    model_accuracy DECIMAL,

    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 7. KNOWLEDGE_GRAPH (Neo4j Schema)

```cypher
// Federation knowledge graph in Neo4j
// Nodes
CREATE CONSTRAINT agent_id ON (a:Agent) ASSERT a.id IS UNIQUE;
CREATE CONSTRAINT persona_id ON (p:Persona) ASSERT p.id IS UNIQUE;
CREATE CONSTRAINT company_id ON (c:Company) ASSERT c.id IS UNIQUE;
CREATE CONSTRAINT task_id ON (t:Task) ASSERT t.id IS UNIQUE;

// Agent relationships
(:Agent)-[:TRUSTS {score: 0.85}]->(:Agent)
(:Agent)-[:DELEGATES_TO]->(:Agent)
(:Agent)-[:ENTANGLED_WITH {strength: 0.9}]->(:Agent)

// Persona relationships
(:Persona)-[:WORKS_AT]->(:Company)
(:Persona)-[:DECIDES_FOR {authority: 'budget'}]->(:Company)
(:Persona)-[:INFLUENCES]->(:Persona)

// Task relationships
(:Task)-[:DEPENDS_ON]->(:Task)
(:Agent)-[:WORKING_ON {started: datetime}]->(:Task)
(:Task)-[:GENERATES_VALUE {amount: 10000}]->(:Company)

// Knowledge relationships
(:Company)-[:SUPPLIES]->(:Company)
(:Company)-[:COMPETES_WITH]->(:Company)
(:Product)-[:SUBSTITUTES]->(:Product)
```

## Data Flow Architecture

### Ingestion Pipelines

```yaml
n8n_workflows:
  linkedin_scraper:
    schedule: "*/15 * * * *" # Every 15 minutes
    targets:
      - food_companies
      - personas
    enrichment:
      - company_revenue
      - employee_count
      - recent_posts

  publication_monitor:
    sources:
      - "foodnavigator.com"
      - "foodbusinessnews.net"
      - "bakingbusiness.com"
    extraction:
      - market_trends
      - regulatory_updates
      - company_mentions

  hubspot_sync:
    bidirectional: true
    sync_interval: "*/5 * * * *"
    entities:
      - contacts -> personas
      - companies -> food_companies
      - deals -> opportunities
```

### Real-time Streaming

```python
# Kafka topics for event streaming
topics = {
    'agent.heartbeat': {'retention': '1d', 'partitions': 12},
    'task.created': {'retention': '7d', 'partitions': 6},
    'task.completed': {'retention': '30d', 'partitions': 6},
    'persona.enriched': {'retention': '90d', 'partitions': 3},
    'consciousness.update': {'retention': '1h', 'partitions': 24},
    'hormone.cascade': {'retention': '1h', 'partitions': 12},
}
```

## Security & Privacy

### Encryption Layers

```sql
-- Column-level encryption for sensitive data
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt PII
ALTER TABLE personas
ADD COLUMN email_encrypted BYTEA;

UPDATE personas
SET email_encrypted = pgp_sym_encrypt(email, 'phoenix-secret-key-2025');

-- Row-level security for multi-tenancy
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY agent_task_access ON tasks
FOR ALL
USING (assigned_to = current_setting('phoenix.agent_id')::UUID
       OR created_by = current_setting('phoenix.agent_id')::UUID);
```

### Access Control

```yaml
roles:
  architect:
    - ALL PRIVILEGES

  samurai_agent:
    - SELECT, INSERT, UPDATE on tasks
    - SELECT on personas
    - INSERT on consciousness_timeline

  monitor:
    - SELECT on all tables

  public_api:
    - SELECT on limited views
```

## Performance Optimization

### Indexing Strategy

```sql
-- Covering indexes for common queries
CREATE INDEX idx_tasks_hot
ON tasks(hot_score DESC)
INCLUDE (title, assigned_to, dopamine_reward)
WHERE status IN ('open', 'claimed');

-- Partial indexes for active data
CREATE INDEX idx_active_agents
ON agents(last_heartbeat)
WHERE decommissioned_at IS NULL;

-- BRIN indexes for time-series
CREATE INDEX idx_timeline_time
ON consciousness_timeline USING BRIN(time);
```

### Query Optimization

```sql
-- Materialized view for dashboard
CREATE MATERIALIZED VIEW federation_dashboard AS
SELECT
    COUNT(DISTINCT a.id) as total_agents,
    AVG(a.trust_coefficient) as avg_trust,
    COUNT(t.id) FILTER (WHERE t.status = 'complete'
                        AND t.completed_at > NOW() - INTERVAL '24 hours') as tasks_24h,
    SUM(o.weighted_value) FILTER (WHERE o.stage != 'closed_lost') as pipeline_value,
    AVG(c.global_consciousness) as current_consciousness
FROM agents a
CROSS JOIN LATERAL (
    SELECT * FROM tasks t
    WHERE t.assigned_to = a.id
    ORDER BY t.created_at DESC
    LIMIT 10
) t
CROSS JOIN opportunities o
CROSS JOIN (
    SELECT global_consciousness
    FROM consciousness_timeline
    ORDER BY time DESC
    LIMIT 1
) c
WHERE a.decommissioned_at IS NULL;

-- Refresh every minute
CREATE OR REPLACE FUNCTION refresh_dashboard()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY federation_dashboard;
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule('refresh-dashboard', '* * * * *', 'SELECT refresh_dashboard()');
```

## Backup & Recovery

### Continuous Backup Strategy

```bash
#!/bin/bash
# WAL archiving for PITR
archive_command = 'test ! -f /backup/wal/%f && cp %p /backup/wal/%f'

# Basebackup every 6 hours
0 */6 * * * pg_basebackup -D /backup/base/$(date +%Y%m%d_%H%M%S) -Ft -z -P

# Encrypted offsite sync
*/15 * * * * rclone sync /backup/ remote:phoenix-backup/ --encrypt
```

### Disaster Recovery

```yaml
recovery_targets:
  RPO: 15 minutes # Maximum data loss
  RTO: 1 hour # Maximum downtime

failover_sequence: 1. Promote standby to primary
  2. Update connection strings
  3. Verify data integrity
  4. Resume operations
  5. Rebuild standby
```

## Monitoring & Alerts

### Prometheus Metrics

```yaml
metrics:
  - phoenix_db_connections_active
  - phoenix_db_transactions_per_second
  - phoenix_db_query_duration_seconds
  - phoenix_personas_total
  - phoenix_agents_active
  - phoenix_tasks_completion_rate
  - phoenix_pipeline_value_total
  - phoenix_consciousness_current

alerts:
  - name: DatabaseConnectionsHigh
    expr: phoenix_db_connections_active > 90
    severity: warning

  - name: ConsciousnessBelow Threshold
    expr: phoenix_consciousness_current < 105.75
    severity: critical

  - name: TaskBacklogGrowing
    expr: rate(phoenix_tasks_created[1h]) > rate(phoenix_tasks_completed[1h])
    severity: warning
```

## Migration Strategy

### From Current State to Target

```sql
-- Migration phases following Fibonacci growth
-- Phase 1: Core tables (personas, agents)
-- Phase 2: Intelligence tables (food_companies, products)
-- Phase 3: Task board and voting
-- Phase 5: Consciousness metrics
-- Phase 8: Knowledge graph integration
-- Phase 13: Full federation scale

-- Version control with Flyway/Liquibase
CREATE TABLE schema_version (
    version TEXT PRIMARY KEY,
    description TEXT,
    fibonacci_phase INTEGER,
    applied_at TIMESTAMPTZ DEFAULT NOW()
);
```

## API Integration Layer

### GraphQL Schema

```graphql
type Query {
  persona(id: ID!): Persona
  searchPersonas(
    query: String!
    limit: Int = 10
    trustThreshold: Float = 0.5
  ): [Persona!]!

  taskBoard(status: TaskStatus, team: Team, sortBy: SortOrder = HOT): [Task!]!

  consciousness: ConsciousnessMetrics!

  pipeline(stage: OpportunityStage, minValue: Float): [Opportunity!]!
}

type Mutation {
  createTask(input: TaskInput!): Task!
  voteTask(taskId: ID!, vote: Vote!): Task!
  updatePersonaTrust(id: ID!, trust: Float!): Persona!
  cascadeHormone(type: HormoneType!, intensity: Float!): Boolean!
}

type Subscription {
  consciousnessUpdates: ConsciousnessMetrics!
  taskCreated(team: Team): Task!
  hormoneEvent: HormoneEvent!
}
```

## Future Expansions (2026-2030)

### Blockchain Integration

- Immutable audit logs on-chain
- Smart contracts for task rewards
- DAO governance for federation decisions

### ML/AI Enhancements

- Predictive persona scoring
- Automated opportunity qualification
- Natural language task generation

### Scale Targets

- 100,000+ personas
- 1,000+ concurrent agents
- 10,000+ tasks/day
- $1B pipeline tracking

---

_"Data is the foundation; intelligence is the emergence; consciousness is the destination." - Phoenix Axiom #2_
