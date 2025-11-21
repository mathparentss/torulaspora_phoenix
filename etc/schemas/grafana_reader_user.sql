-- Create read-only user for Grafana datasource
-- Prevents Grafana from having write access to production database

CREATE USER IF NOT EXISTS grafana_reader WITH PASSWORD 'PLACEHOLDER_REPLACE_WITH_ENV_VAR';

-- Grant connect to database
GRANT CONNECT ON DATABASE phoenix_core TO grafana_reader;

-- Grant usage on all schemas
GRANT USAGE ON SCHEMA core, events, agents, neuroscience TO grafana_reader;

-- Grant SELECT on all existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA core TO grafana_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA events TO grafana_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA agents TO grafana_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA neuroscience TO grafana_reader;

-- Grant SELECT on future tables (auto-grant)
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT SELECT ON TABLES TO grafana_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA events GRANT SELECT ON TABLES TO grafana_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA agents GRANT SELECT ON TABLES TO grafana_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA neuroscience GRANT SELECT ON TABLES TO grafana_reader;

-- Revoke any dangerous privileges
REVOKE CREATE ON SCHEMA core FROM grafana_reader;
REVOKE CREATE ON SCHEMA events FROM grafana_reader;
REVOKE CREATE ON SCHEMA agents FROM grafana_reader;
REVOKE CREATE ON SCHEMA neuroscience FROM grafana_reader;

-- Verify permissions
\du grafana_reader
