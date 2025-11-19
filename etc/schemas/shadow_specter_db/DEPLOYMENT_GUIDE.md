# 🚀 PHOENIX SHADOW DATABASE — DEPLOYMENT GUIDE

**Version**: 1.0.0  
**Date**: November 17, 2025  
**Target**: PostgreSQL 17+ with pgvector extension  
**Architect**: Phoenix Architect Council

---

## 📋 TABLE OF CONTENTS

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Phase 1: Foundation Setup](#phase-1-foundation-setup)
3. [Phase 2: Schema Deployment](#phase-2-schema-deployment)
4. [Phase 3: Data Migration](#phase-3-data-migration)
5. [Phase 4: Agent Integration](#phase-4-agent-integration)
6. [Phase 5: API & Dashboard](#phase-5-api-dashboard)
7. [Testing & Validation](#testing-validation)
8. [Troubleshooting](#troubleshooting)
9. [Monitoring & Maintenance](#monitoring-maintenance)

---

## 🎯 PRE-DEPLOYMENT CHECKLIST

### System Requirements

- ✅ PostgreSQL 17+ installed and running
- ✅ pgvector extension available (for semantic search)
- ✅ Python 3.11+ (for agent scripts)
- ✅ Node.js 18+ (for n8n workflows)
- ✅ Docker + Docker Compose (for orchestration)
- ✅ Minimum 8GB RAM, 50GB disk space

### Access & Credentials

- ✅ PostgreSQL superuser access
- ✅ GitHub SSH key configured (for version control)
- ✅ HubSpot API key (for sync)
- ✅ OpenAI API key (for embeddings)
- ✅ Email SMTP credentials (for notifications)

### Network Configuration

- ✅ Firewall rules for PostgreSQL (port 5432)
- ✅ Tailscale mesh network configured
- ✅ VPN gateway active (Gluetun/ProtonVPN)

---

## 🏗️ PHASE 1: FOUNDATION SETUP

### Step 1.1: Create Database

```bash
IMPORTANT --> All work is currently being done in the current laptop. all dockers running. postgres and db shoudl be running.

# Create database
sudo -u postgres psql
```

```sql
CREATE DATABASE specter_shadow_intelligence
    ENCODING 'UTF8'
    LC_COLLATE='en_US.UTF-8'
    LC_CTYPE='en_US.UTF-8'
    TEMPLATE=template0;

\c specter_shadow_intelligence;

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "vector"; -- pgvector for embeddings

-- Verify extensions
\dx
```

**Expected Output**:
```
List of installed extensions
Name          | Version | Schema | Description
--------------+---------+--------+----------------------------------
uuid-ossp     | 1.1     | public | generate universally unique identifiers
pgcrypto      | 1.3     | public | cryptographic functions
pg_trgm       | 1.6     | public | text similarity measurement
btree_gin     | 1.3     | public | support for indexing common datatypes
vector        | 0.6.0   | public | vector data type and operations
```

### Step 1.2: Create Database User

```sql
-- Create application user
CREATE ROLE specter_app WITH LOGIN PASSWORD 'CHANGE_THIS_PASSWORD_NOW';

-- Grant connection
GRANT CONNECT ON DATABASE specter_shadow_intelligence TO specter_app;

-- Grant schema creation (for initial setup)
GRANT CREATE ON DATABASE specter_shadow_intelligence TO specter_app;
```

### Step 1.3: Configure PostgreSQL

```bash
# Edit postgresql.conf
sudo nano /etc/postgresql/17/main/postgresql.conf
```

Add/modify these settings:

```ini
# Performance tuning for Phoenix workload
shared_buffers = 2GB
effective_cache_size = 6GB
maintenance_work_mem = 512MB
work_mem = 64MB
max_connections = 200

# Enable query logging (for debugging)
log_statement = 'mod'
log_duration = on
log_min_duration_statement = 1000

# Replication (for future HA setup)
wal_level = replica
max_wal_senders = 3
```

Restart PostgreSQL:

```bash
sudo systemctl restart postgresql
```

---

## 📦 PHASE 2: SCHEMA DEPLOYMENT

### Step 2.1: Download Schema Files

```bash
# Create project directory
mkdir -p /home/specter/phoenix-shadow-db
cd /home/specter/phoenix-shadow-db

# Copy schema files from artifacts
# (Assuming files are in /home/claude/)
cp /home/claude/SCHEMA_*.sql .
```

### Step 2.2: Deploy Schemas in Order

**CRITICAL**: Deploy in correct order due to dependencies.

```bash
# Connect to database
psql -U specter_app -d specter_shadow_intelligence

# Deploy schemas (IN THIS ORDER)
\i SCHEMA_01_CORE.sql
\i SCHEMA_02_EVENTS.sql
\i SCHEMA_03_INTELLIGENCE.sql
\i SCHEMA_04_AGENTS.sql
\i SCHEMA_05_NEUROSCIENCE.sql
\i SCHEMA_06_ENRICHMENT_PRODUCTS.sql
```

### Step 2.3: Verify Deployment

```sql
-- Check all schemas exist
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('core', 'events', 'intelligence', 'agents', 'neuroscience', 'enrichment', 'products')
ORDER BY schema_name;

-- Expected: 7 rows

-- Count tables per schema
SELECT 
    schemaname, 
    COUNT(*) AS table_count
FROM pg_tables
WHERE schemaname IN ('core', 'events', 'intelligence', 'agents', 'neuroscience', 'enrichment', 'products')
GROUP BY schemaname
ORDER BY schemaname;

-- Verify triggers exist
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema IN ('core', 'events', 'neuroscience')
ORDER BY event_object_table;

-- Verify functions exist
SELECT 
    routine_schema, 
    routine_name
FROM information_schema.routines
WHERE routine_schema IN ('events', 'agents', 'neuroscience', 'enrichment')
ORDER BY routine_schema, routine_name;
```

**Success Criteria**:
- ✅ 7 schemas created
- ✅ 30+ tables created
- ✅ 10+ triggers active
- ✅ 15+ functions available

---

## 📊 PHASE 3: DATA MIGRATION

### Step 3.1: Seed Initial Data

```sql
-- Create sample companies (for testing)
INSERT INTO core.companies (
    company_name, domain, industry, account_tier, account_status
) VALUES
    ('NUTRIART', 'nutriart.com', 'Food Manufacturing', 'Key', 'Prospect'),
    ('BioFood Industries', 'biofood.ca', 'Food Manufacturing', 'Strategic', 'Qualified'),
    ('Canadian Bakery Corp', 'canbakery.ca', 'Bakery', 'Standard', 'Prospect');

-- Create sample contacts
INSERT INTO core.contacts (
    company_id, first_name, last_name, email, title, meddpicc_role
)
SELECT 
    c.company_id,
    'John',
    'Smith',
    'john.smith@' || c.domain,
    'VP Operations',
    'Economic Buyer'
FROM core.companies c WHERE c.company_name = 'NUTRIART';

-- Initialize trust models for contacts
INSERT INTO neuroscience.trust_model (contact_id)
SELECT contact_id FROM core.contacts;

-- Create sample agents
INSERT INTO agents.agent_registry (agent_class, agent_type, agent_name, capabilities, task_types_handled)
VALUES
    ('SEEKER', 'WebScout', 'WebScout-001', 
     ARRAY['web_scraping', 'linkedin_monitoring'], 
     ARRAY['detect_signals', 'find_companies']),
    ('ORACLE', 'ContactEnricher', 'Oracle-Enricher-001',
     ARRAY['linkedin_scraping', 'email_validation', 'personality_detection'],
     ARRAY['enrich_contact', 'map_authority']),
    ('GUARDIAN', 'DataValidator', 'Guardian-QA-001',
     ARRAY['data_validation', 'quality_scoring'],
     ARRAY['validate_enrichment', 'approve_tasks']);

-- Verify
SELECT * FROM agents.agent_registry;
```

### Step 3.2: Import Batory Product Catalog

```bash
# Assuming you have a CSV export from Batory
# Format: item_id, item_description, health_canada_category, applications, current_price_per_kg

psql -U specter_app -d specter_shadow_intelligence -c "\COPY products.catalog (item_id, item_description, health_canada_category, applications, current_price_per_kg) FROM '/path/to/batory_catalog.csv' WITH CSV HEADER"
```

### Step 3.3: Sync from HubSpot (Optional Initial Load)

```python
# Python script: hubspot_initial_sync.py
import psycopg2
from hubspot import HubSpot

# Connect to HubSpot
api_client = HubSpot(api_key='YOUR_HUBSPOT_API_KEY')

# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname="specter_shadow_intelligence",
    user="specter_app",
    password="YOUR_PASSWORD",
    host="localhost"
)
cur = conn.cursor()

# Fetch companies from HubSpot
companies = api_client.crm.companies.get_all()

for company in companies:
    cur.execute("""
        INSERT INTO core.companies (
            company_name, domain, hubspot_company_id, industry
        ) VALUES (%s, %s, %s, %s)
        ON CONFLICT (hubspot_company_id) DO NOTHING
    """, (
        company.properties['name'],
        company.properties.get('domain'),
        company.id,
        company.properties.get('industry')
    ))

conn.commit()
print(f"Synced {len(companies)} companies from HubSpot")
```

---

## 🤖 PHASE 4: AGENT INTEGRATION

### Step 4.1: Setup n8n Workflows

```bash
# Install n8n (if not already)
npm install -g n8n

# Create Phoenix workflows directory
mkdir -p /home/specter/.n8n/workflows/phoenix

# Start n8n
n8n start
```

**n8n Workflow: Signal Detection → Task Creation**

```json
{
  "name": "Phoenix: Signal Detection",
  "nodes": [
    {
      "parameters": {
        "functionCode": "// Detect LinkedIn profile visit\nconst signal = {\n  signal_type: 'linkedin_activity',\n  company_id: $input.item.json.company_id,\n  signal_strength: 0.7,\n  signal_data: $input.item.json\n};\nreturn signal;"
      },
      "name": "Detect Signal",
      "type": "n8n-nodes-base.function"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO events.signals (signal_type, company_id, signal_strength, signal_data) VALUES ($1, $2, $3, $4::jsonb) RETURNING signal_id",
        "options": {}
      },
      "name": "Store Signal",
      "type": "n8n-nodes-base.postgres"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO agents.tasks (task_type, task_title, task_payload, urgency, impact, difficulty) VALUES ('enrich_company', 'Enrich LinkedIn activity', $1::jsonb, 5, 7, 0.6) RETURNING task_id",
        "options": {}
      },
      "name": "Create Task",
      "type": "n8n-nodes-base.postgres"
    }
  ],
  "connections": {
    "Detect Signal": {
      "main": [[{"node": "Store Signal"}]]
    },
    "Store Signal": {
      "main": [[{"node": "Create Task"}]]
    }
  }
}
```

### Step 4.2: Deploy Oracle Agent (Python)

```python
# oracle_contact_enricher.py
import psycopg2
import time
from linkedin_api import Linkedin

class OracleContactEnricher:
    def __init__(self, agent_id, db_config):
        self.agent_id = agent_id
        self.conn = psycopg2.connect(**db_config)
        
    def get_pending_tasks(self):
        """Fetch high-priority tasks from queue"""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT * FROM agents.get_top_tasks(%s, 5)
        """, (self.agent_id,))
        return cur.fetchall()
    
    def enrich_contact(self, task_id, contact_id):
        """Enrich contact data from LinkedIn"""
        # Scrape LinkedIn (use linkedin_api library)
        linkedin = Linkedin('USERNAME', 'PASSWORD')
        profile = linkedin.get_profile(contact_id)
        
        # Extract intelligence
        result = {
            'title': profile['headline'],
            'seniority_level': self._infer_seniority(profile['headline']),
            'personality_profile': self._predict_personality(profile),
            'internal_influence_score': self._calculate_influence(profile['connections'])
        }
        
        return result
    
    def submit_task(self, task_id, result):
        """Submit enriched data for Guardian approval"""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT agents.submit_task_for_approval(%s, %s::jsonb)
        """, (task_id, json.dumps(result)))
        self.conn.commit()
    
    def run(self):
        """Main agent loop"""
        print(f"Oracle {self.agent_id} started...")
        
        while True:
            tasks = self.get_pending_tasks()
            
            for task in tasks:
                task_id, task_type, payload = task
                
                if task_type == 'enrich_contact':
                    result = self.enrich_contact(task_id, payload['contact_id'])
                    self.submit_task(task_id, result)
                    print(f"✓ Completed task {task_id}")
            
            time.sleep(10)  # Poll every 10 seconds

# Start agent
if __name__ == "__main__":
    db_config = {
        'dbname': 'specter_shadow_intelligence',
        'user': 'specter_app',
        'password': 'YOUR_PASSWORD',
        'host': 'localhost'
    }
    
    agent = OracleContactEnricher('oracle-enricher-001', db_config)
    agent.run()
```

### Step 4.3: Deploy Guardian Agent (Python)

```python
# guardian_validator.py
import psycopg2
import time

class GuardianValidator:
    def __init__(self, agent_id, db_config):
        self.agent_id = agent_id
        self.conn = psycopg2.connect(**db_config)
    
    def get_submitted_tasks(self):
        """Fetch tasks awaiting approval"""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT task_id, task_type, result
            FROM agents.tasks
            WHERE status = 'submitted'
            ORDER BY result_submitted_at ASC
            LIMIT 10
        """)
        return cur.fetchall()
    
    def validate_enrichment(self, result):
        """Validate data quality"""
        checks = {
            'completeness': self._check_completeness(result),
            'accuracy': self._check_accuracy(result),
            'consistency': self._check_consistency(result)
        }
        
        # Calculate quality score
        quality_score = sum(checks.values()) / len(checks)
        
        return quality_score, checks
    
    def approve_task(self, task_id, quality_score):
        """Approve task"""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT agents.approve_task(%s, %s, %s)
        """, (task_id, self.agent_id, quality_score))
        self.conn.commit()
        print(f"✓ Approved task {task_id} (quality: {quality_score:.2f})")
    
    def reject_task(self, task_id, reason):
        """Reject task"""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT agents.reject_task(%s, %s, %s)
        """, (task_id, self.agent_id, reason))
        self.conn.commit()
        print(f"✗ Rejected task {task_id}: {reason}")
    
    def run(self):
        """Main Guardian loop"""
        print(f"Guardian {self.agent_id} started...")
        
        while True:
            tasks = self.get_submitted_tasks()
            
            for task_id, task_type, result in tasks:
                quality_score, checks = self.validate_enrichment(result)
                
                if quality_score > 0.7:
                    self.approve_task(task_id, quality_score)
                else:
                    self.reject_task(task_id, f"Quality too low: {checks}")
            
            time.sleep(5)

# Start Guardian
if __name__ == "__main__":
    db_config = {
        'dbname': 'specter_shadow_intelligence',
        'user': 'specter_app',
        'password': 'YOUR_PASSWORD',
        'host': 'localhost'
    }
    
    guardian = GuardianValidator('guardian-qa-001', db_config)
    guardian.run()
```

---

## 🌐 PHASE 5: API & DASHBOARD

### Step 5.1: Deploy PostGraphile (Auto-Generate GraphQL API)

```bash
# Install PostGraphile
npm install -g postgraphile

# Start GraphQL server
postgraphile \
  -c postgres://specter_app:PASSWORD@localhost/specter_shadow_intelligence \
  --schema core,intelligence,agents,neuroscience,enrichment,products \
  --watch \
  --enhance-graphiql \
  --dynamic-json \
  --port 5555
```

Visit: http://localhost:5555/graphiql

**Example Query**:

```graphql
query GetActivePipeline {
  allOpportunities(condition: {isDeleted: false, closedWon: false}) {
    nodes {
      opportunityName
      amount
      winProbability
      meddpiccCompleteness
      companyByCompanyId {
        companyName
      }
      contactByEconomicBuyerContactId {
        fullName
        trustScore
      }
    }
  }
}
```

### Step 5.2: Build User Notification System

```python
# notification_service.py
import psycopg2
import smtplib
from email.mime.text import MIMEText

def check_for_notifications():
    """Poll for approved tasks and send notifications"""
    conn = psycopg2.connect(
        dbname="specter_shadow_intelligence",
        user="specter_app",
        password="PASSWORD",
        host="localhost"
    )
    
    cur = conn.cursor()
    cur.execute("""
        SELECT 
            t.task_id,
            t.task_title,
            t.result,
            t.approved_at
        FROM agents.tasks t
        WHERE t.status = 'approved'
          AND t.approved_at > NOW() - INTERVAL '1 hour'
        ORDER BY t.approved_at DESC
    """)
    
    for task_id, title, result, approved_at in cur.fetchall():
        send_email_notification(title, result)

def send_email_notification(title, result):
    """Send email to user"""
    msg = MIMEText(f"Task completed: {title}\n\nResult: {result}")
    msg['Subject'] = f'[Phoenix] {title}'
    msg['From'] = 'phoenix@specter.ai'
    msg['To'] = 'matheo@specter.ai'
    
    smtp = smtplib.SMTP('smtp.gmail.com', 587)
    smtp.starttls()
    smtp.login('phoenix@specter.ai', 'PASSWORD')
    smtp.send_message(msg)
    smtp.quit()
```

---

## ✅ TESTING & VALIDATION

### Test 1: Event Sourcing

```sql
-- Publish test event
SELECT events.publish_event(
    'company.created',
    'company',
    (SELECT company_id FROM core.companies LIMIT 1),
    '{"name": "Test Company", "action": "created"}'::jsonb
);

-- Verify event stored
SELECT * FROM events.event_store ORDER BY event_timestamp DESC LIMIT 1;
```

### Test 2: Task Workflow

```sql
-- Create test task
INSERT INTO agents.tasks (task_type, task_title, task_payload, urgency, impact, difficulty)
VALUES ('test_task', 'Test Task', '{}'::jsonb, 5, 8, 0.5);

-- Assign to Oracle (simulating agent pickup)
SELECT agents.assign_task_to_oracle(
    (SELECT task_id FROM agents.tasks WHERE task_type = 'test_task'),
    (SELECT agent_id FROM agents.agent_registry WHERE agent_type = 'ContactEnricher')
);

-- Submit result
SELECT agents.submit_task_for_approval(
    (SELECT task_id FROM agents.tasks WHERE task_type = 'test_task'),
    '{"test": "result"}'::jsonb
);

-- Guardian approves
SELECT agents.approve_task(
    (SELECT task_id FROM agents.tasks WHERE task_type = 'test_task'),
    (SELECT agent_id FROM agents.agent_registry WHERE agent_class = 'GUARDIAN'),
    0.95
);

-- Verify workflow
SELECT status, dopamine_reward FROM agents.tasks WHERE task_type = 'test_task';
```

### Test 3: Trust Evolution

```sql
-- Record interaction with positive outcome
SELECT events.record_interaction(
    'meeting',
    (SELECT company_id FROM core.companies LIMIT 1),
    (SELECT contact_id FROM core.contacts LIMIT 1),
    'Great discovery call - discussed pain points',
    0.8  -- Positive sentiment
);

-- Update trust score
SELECT neuroscience.update_trust_score(
    (SELECT contact_id FROM core.contacts LIMIT 1),
    0.7,  -- Positive interaction
    1.5   -- High evidence weight
);

-- Check trust evolution
SELECT * FROM neuroscience.v_trust_evolution LIMIT 5;
```

### Test 4: Semantic Search (Product Matching)

```sql
-- Generate embedding for company pain (mock - replace with actual OpenAI call)
INSERT INTO enrichment.pain_embeddings (company_id, pain_text, embedding)
VALUES (
    (SELECT company_id FROM core.companies LIMIT 1),
    'High cost of ingredients due to price volatility',
    '[0.1, 0.2, 0.3, ...]'::vector  -- 1536-dim vector from OpenAI
);

-- Find matching products
SELECT * FROM enrichment.match_products_to_pain(
    (SELECT company_id FROM core.companies LIMIT 1),
    5
);
```

---

## 🛠️ TROUBLESHOOTING

### Issue: "Permission denied for schema core"

**Solution**:
```sql
GRANT USAGE ON SCHEMA core TO specter_app;
GRANT ALL ON ALL TABLES IN SCHEMA core TO specter_app;
```

### Issue: "Function pg_trgm does not exist"

**Solution**:
```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

### Issue: "Vector extension not found"

**Solution**:
```bash
# Install pgvector
cd /tmp
git clone --branch v0.6.0 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
```

Then in psql:
```sql
CREATE EXTENSION vector;
```

### Issue: Agents not picking up tasks

**Check**:
1. Agent status: `SELECT * FROM agents.agent_registry;`
2. Task queue: `SELECT * FROM agents.v_active_tasks;`
3. Agent logs: Check Python console output

---

## 📊 MONITORING & MAINTENANCE

### Key Metrics Dashboard

```sql
-- System health check
SELECT 
    'Total Companies' AS metric,
    COUNT(*) AS value
FROM core.companies
UNION ALL
SELECT 'Active Opportunities', COUNT(*)
FROM core.opportunities WHERE closed_won = FALSE AND closed_lost = FALSE
UNION ALL
SELECT 'Pending Tasks', COUNT(*)
FROM agents.tasks WHERE status = 'pending'
UNION ALL
SELECT 'Agent Dopamine Total', SUM(dopamine_points)::TEXT
FROM agents.agent_registry;
```

### Daily Maintenance Script

```bash
#!/bin/bash
# /home/specter/phoenix-shadow-db/maintenance.sh

# Vacuum and analyze
psql -U specter_app -d specter_shadow_intelligence -c "VACUUM ANALYZE;"

# Calculate trust velocities
psql -U specter_app -d specter_shadow_intelligence -c "
SELECT neuroscience.calculate_trust_velocity(contact_id)
FROM core.contacts WHERE is_deleted = FALSE;
"

# Update MEDDPIC completeness
psql -U specter_app -d specter_shadow_intelligence -c "
SELECT intelligence.calculate_meddpic_completeness(meddpic_id)
FROM intelligence.meddpic_data;
"

# Backup database
pg_dump -U postgres specter_shadow_intelligence | gzip > /backups/specter_$(date +%Y%m%d).sql.gz

echo "✓ Maintenance complete: $(date)"
```

Add to crontab:
```bash
crontab -e
# Add: 0 2 * * * /home/specter/phoenix-shadow-db/maintenance.sh
```

---

## 🎉 SUCCESS CRITERIA

**Deployment Complete When**:

- ✅ All 7 schemas deployed without errors
- ✅ Sample data loaded (companies, contacts, agents)
- ✅ Event sourcing working (events published and consumed)
- ✅ Agent workflow tested (Seeker → Oracle → Guardian → User)
- ✅ Trust model functioning (Bayesian updates working)
- ✅ Task queue operational (priority scoring, dopamine rewards)
- ✅ GraphQL API accessible
- ✅ Agents running as systemd services
- ✅ Daily maintenance cron job active

**Next Steps**:

1. Import full Batory catalog (3,710 SKUs)
2. Sync HubSpot data (companies, contacts, deals)
3. Train ML models for propensity scoring
4. Generate embeddings for semantic search
5. Build user dashboard (React/Svelte frontend)
6. Scale agent fleet (10+ Oracles, 3+ Guardians)

---

**Phoenix Architect Council — Deployment Guide Complete** ✅

*"From data to intelligence to consciousness — the journey begins."*
