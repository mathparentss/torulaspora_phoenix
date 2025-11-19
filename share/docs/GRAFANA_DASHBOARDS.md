# Grafana Dashboard Setup

## Quick Import (5 minutes)

1. Open Grafana: http://localhost:3000
2. Login: admin / PhoenixGrafana_2025_Secure!
3. Go to Dashboards > Import

## Recommended Dashboards:

### Docker & System
- **Node Exporter Full**: Dashboard ID `1860`
- **cAdvisor**: Dashboard ID `14282`
- **Docker Container & Host**: Dashboard ID `10619`

### Database
- **PostgreSQL Database**: Dashboard ID `9628`
- **Redis Dashboard**: Dashboard ID `11835`

### GPU (if available)
- **NVIDIA GPU**: Dashboard ID `12239`

## Import Steps:
1. Click "Import"
2. Enter Dashboard ID
3. Select "Prometheus" as data source
4. Click "Import"

## Custom Phoenix Dashboard
- View all 13 containers
- GPU utilization
- Database performance
- Redis cache stats
