# Deploy Shadow Database
```bash
cd /mnt/c/dev/phoenix/configs/database/shadow_specter_db

# Copy schemas to container
for file in SCHEMA_*.sql; do
    docker cp "$file" phoenix_postgres:/tmp/
done

# Deploy
docker exec -i phoenix_postgres psql -U phoenix -d phoenix_core <<'SQL'
\i /tmp/SCHEMA_01_CORE.sql
\i /tmp/SCHEMA_02_EVENTS.sql
\i /tmp/SCHEMA_03_INTELLIGENCE.sql
\i /tmp/SCHEMA_04_AGENTS.sql
\i /tmp/SCHEMA_05_NEUROSCIENCE.sql
\i /tmp/SCHEMA_06_ENRICHMENT_PRODUCTS.sql

SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema IN ('core','events','intelligence','agents','neuroscience','enrichment','products');
SQL
```
