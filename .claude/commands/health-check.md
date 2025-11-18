# Stack Health Check
```bash
docker ps --filter name=phoenix_ --format "{{.Names}}: {{.Status}}" | grep -E "healthy|up"
docker exec phoenix_postgres psql -U phoenix -d phoenix_core -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='core';"
docker exec phoenix_redis redis-cli PING
curl -s http://localhost:6333/collections | jq '.result.collections | length'
```
