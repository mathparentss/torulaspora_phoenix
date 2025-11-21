# PHOENIX EXPENSE EMPIRE SAAS V1 — IMMUTABLE BATTLE PLAN
**Architect**: Supreme Greyhat PhD Systems Architect
**Date**: 2025-11-19
**Mission**: Birth the first revenue spore — 10 free receipts/month → $100M heat empire
**Target**: Production deployment in 5 surgical phases

---

## 1. TECHNICAL DEBT RESOLUTION PLAN

### TD-1: GRAFANA DATASOURCE HARDCODED PASSWORD [CRITICAL]

**File**: `/opt/phoenix/etc/observability/grafana/datasources/datasources.yml`

**Current (Lines 24-25)**:
```yaml
secureJsonData:
  password: PhoenixDB_2025_Secure!
```

**Patch**:
```yaml
secureJsonData:
  password: ${GRAFANA_DB_PASSWORD}
```

**Additional**: Create read-only database user

**New SQL**: `/opt/phoenix/etc/schemas/grafana_reader_user.sql`
```sql
-- Create read-only user for Grafana datasource
CREATE USER grafana_reader WITH PASSWORD '${GRAFANA_DB_PASSWORD}';

-- Grant connect to database
GRANT CONNECT ON DATABASE phoenix_core TO grafana_reader;

-- Grant usage on all schemas
GRANT USAGE ON SCHEMA core, events, agents, neuroscience TO grafana_reader;

-- Grant SELECT on all existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA core, events, agents, neuroscience TO grafana_reader;

-- Grant SELECT on future tables (auto-grant)
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT SELECT ON TABLES TO grafana_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA events GRANT SELECT ON TABLES TO grafana_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA agents GRANT SELECT ON TABLES TO grafana_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA neuroscience GRANT SELECT ON TABLES TO grafana_reader;
```

**Environment Variable Addition** (`/opt/phoenix/etc/compose/.env`):
```bash
# Grafana Database Reader (read-only PostgreSQL user)
GRAFANA_DB_PASSWORD=<GENERATE_WITH_openssl_rand_-base64_32>
```

---

### TD-2: PYTHON ENVIRONMENT VARIABLE SYNTAX [CRITICAL]

**File 1**: `/opt/phoenix/srv/agents/task_board_api.py`

**Current (Line 18)**:
```python
password="${POSTGRES_PASSWORD}!"
```

**Patch**:
```python
password=os.getenv('POSTGRES_PASSWORD')
```

**File 2**: `/opt/phoenix/srv/crewai/agents/alpha_1_data_miner.py`

**Current (Line 13)**:
```python
password="${POSTGRES_PASSWORD}!"
```

**Patch**:
```python
password=os.getenv('POSTGRES_PASSWORD')
```

**Required Import** (add to top of both files if missing):
```python
import os
```

---

### TD-3: CADVISOR OVERPRIVILEGED [CRITICAL]

**File**: `/opt/phoenix/etc/compose/docker-compose.tier4.yml`

**Current (Line 74)**:
```yaml
cadvisor:
  image: gcr.io/cadvisor/cadvisor:latest
  privileged: true
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:ro
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
```

**Patch**:
```yaml
cadvisor:
  image: gcr.io/cadvisor/cadvisor:latest
  cap_add:
    - SYS_PTRACE
  security_opt:
    - no-new-privileges:true
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:ro
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
```

---

### TD-4: RESURRECTION SCRIPT PYTHON VENV CHECK [HIGH]

**File**: `/opt/phoenix/sbin/phoenix-resurrect`

**Insert after line 55** (after Step 5: Restore Git repository):
```bash
# ============================================================================
# STEP 5.5: VALIDATE PYTHON VIRTUAL ENVIRONMENT
# ============================================================================
echo "[5.5] Validating Python virtual environment..."

VENV_PATH="/opt/phoenix/phoenix.venv"
REQUIREMENTS="/opt/phoenix/lib/python/requirements.txt"

if [ ! -d "$VENV_PATH" ]; then
  echo "  ⚠️  Virtual environment not found. Creating..."
  sudo -u $SUDO_USER python3 -m venv "$VENV_PATH"
fi

if [ ! -f "$VENV_PATH/bin/activate" ]; then
  echo "  ❌ Virtual environment corrupted. Recreating..."
  rm -rf "$VENV_PATH"
  sudo -u $SUDO_USER python3 -m venv "$VENV_PATH"
fi

if [ -f "$REQUIREMENTS" ]; then
  echo "  📦 Installing Python dependencies..."
  sudo -u $SUDO_USER "$VENV_PATH/bin/pip" install --quiet --upgrade pip
  sudo -u $SUDO_USER "$VENV_PATH/bin/pip" install --quiet -r "$REQUIREMENTS"
  echo "  ✅ Python environment validated ($(sudo -u $SUDO_USER "$VENV_PATH/bin/pip" list --format=freeze | wc -l) packages)"
else
  echo "  ⚠️  requirements.txt not found. Skipping dependency install."
fi
```

---

### TD-5: OLLAMA MODEL VERIFICATION [HIGH]

**File**: `/opt/phoenix/bin/phoenix-essential-models.sh`

**Current (Lines 1-18)**:
```bash
#!/bin/bash
for model in qwen2.5-coder:7b llama3.1:8b nomic-embed-text llava:13b gemma2:9b dolphin-phi; do
  docker exec phoenix_ollama ollama pull "$model"
done
```

**Patch (Complete Replacement)**:
```bash
#!/bin/bash
set -euo pipefail

MODELS=(
  "qwen2.5-coder:7b"
  "llama3.1:8b"
  "nomic-embed-text"
  "llava:13b"
  "gemma2:9b"
  "dolphin-phi"
)

echo "================================================"
echo "PHOENIX ESSENTIAL MODELS — PULL + VERIFICATION"
echo "================================================"

FAILED_MODELS=()

for model in "${MODELS[@]}"; do
  echo ""
  echo "📥 Pulling $model..."

  if docker exec phoenix_ollama ollama pull "$model" 2>&1 | tee /tmp/ollama_pull.log; then
    # Verify model exists in list
    if docker exec phoenix_ollama ollama list | grep -q "^${model%%:*}"; then
      echo "  ✅ $model verified and ready"
    else
      echo "  ❌ $model pull succeeded but not found in list"
      FAILED_MODELS+=("$model")
    fi
  else
    echo "  ❌ $model pull FAILED"
    FAILED_MODELS+=("$model")
  fi
done

echo ""
echo "================================================"
echo "SUMMARY"
echo "================================================"
echo "Total models: ${#MODELS[@]}"
echo "Failed: ${#FAILED_MODELS[@]}"

if [ ${#FAILED_MODELS[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  FAILED MODELS:"
  for model in "${FAILED_MODELS[@]}"; do
    echo "  - $model"
  done
  exit 1
else
  echo "✅ All models verified successfully"
fi
```

---

### TD-6: QDRANT HEALTHCHECK [HIGH]

**File**: `/opt/phoenix/etc/compose/docker-compose.tier2.yml`

**Current (Lines 76-83)**:
```yaml
# Health check disabled - Qdrant container doesn't include curl/wget
# Service health verified via external monitoring
```

**Patch (Replace commented section)**:
```yaml
healthcheck:
  test: ["CMD-SHELL", "timeout 5 bash -c '</dev/tcp/localhost/6333' || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 10s
```

**Alternative (if bash not available in container)**:
```yaml
healthcheck:
  test: ["CMD-SHELL", "nc -z localhost 6333 || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 10s
```

---

### TD-7: WSL2-SPECIFIC CODE REMOVAL [HIGH]

**File 1**: `/opt/phoenix/lib/phoenix-functions.sh`

**Current (Lines 54, 56, 60)**:
```bash
cmd.exe /c start http://localhost:9000
cmd.exe /c start http://localhost:3000
cmd.exe /c start http://localhost:8080
```

**Patch (Create cross-platform function at top of file)**:
```bash
# Cross-platform browser launcher
open_browser() {
  local url="$1"

  if command -v cmd.exe &>/dev/null; then
    # WSL2 Windows host
    cmd.exe /c start "$url" 2>/dev/null
  elif command -v xdg-open &>/dev/null; then
    # Linux with X11/Wayland
    xdg-open "$url" 2>/dev/null &
  elif command -v open &>/dev/null; then
    # macOS
    open "$url" 2>/dev/null
  else
    # Fallback: just display URL
    echo "🌐 Open manually: $url"
  fi
}
```

**Then replace all instances**:
```bash
# OLD: cmd.exe /c start http://localhost:9000
# NEW:
open_browser "http://localhost:9000"

# OLD: cmd.exe /c start http://localhost:3000
# NEW:
open_browser "http://localhost:3000"

# OLD: cmd.exe /c start http://localhost:8080
# NEW:
open_browser "http://localhost:8080"
```

**File 2**: `/opt/phoenix/backup-and-remove-old-phoenix.sh`

**Current (Line 28)**:
```bash
SOURCE="/mnt/c/dev/phoenix"
```

**Patch**: Remove entire file from production use (archival script only, not for bare metal)

**File 3**: `/opt/phoenix/sbin/phoenix-boot.sh`

**Current (Lines 16, 21, 26, 31)** - Contains hardcoded `/mnt/c/dev/phoenix` paths

**Patch**: Replace with dynamic path detection:
```bash
#!/bin/bash
set -euo pipefail

# Detect Phoenix root dynamically
PHOENIX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PHOENIX_ROOT/etc/compose"

# Rest of script uses $PHOENIX_ROOT instead of hardcoded path
```

---

### TD-8: DOCKER VOLUME SYNTAX ERROR [CRITICAL - DISCOVERED]

**Files**: All tier compose files

**Current Pattern (INVALID YAML)**:
```yaml
volumes:
  postgres_data:
    external: true
```

**Should be**:
```yaml
volumes:
  postgres_data:
    external: true
```

**ACTION**: This appears correct in current files based on reconnaissance. If errors occur, verify indentation is exactly 2 spaces (not tabs).

---

## 2. EXPENSE EMPIRE 5-PHASE BATTLE PLAN

### PHASE 1: FOUNDATION — DEBT EXTERMINATION + AUTH INFRASTRUCTURE
**Duration**: 2 days
**Outcome**: Zero technical debt, production-ready auth system

**Tasks**:
1. Apply all 7 technical debt patches (TD-1 through TD-7)
2. Create `receipts` schema with multi-tenancy architecture
3. Implement JWT authentication middleware
4. Build user registration + login endpoints
5. Create `phoenix_receipts` Docker service skeleton
6. Deploy Tier 5 (SaaS layer) with nginx reverse proxy

**Deliverables**:
- ✅ All technical debt resolved
- ✅ Users can register and authenticate
- ✅ JWT tokens issued with 24h expiry
- ✅ Passwords hashed with bcrypt (cost factor 12)
- ✅ API returns 401 for unauthenticated requests

**Schema Changes**:
```sql
-- New schema: receipts
CREATE SCHEMA receipts;

-- Users table (multi-tenant ready)
CREATE TABLE receipts.users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,  -- bcrypt with cost 12
  full_name TEXT,
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro', 'enterprise')),
  monthly_receipt_limit INTEGER DEFAULT 10,
  receipts_uploaded_this_month INTEGER DEFAULT 0,
  month_reset_date DATE DEFAULT date_trunc('month', CURRENT_DATE) + INTERVAL '1 month',
  is_heat_donor BOOLEAN DEFAULT FALSE,  -- Future: 20% compute donation flag
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE
);

-- Audit log for all user actions
CREATE TABLE receipts.audit_log (
  audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES receipts.users(user_id),
  action TEXT NOT NULL,  -- 'login', 'upload', 'export', 'delete'
  resource_type TEXT,    -- 'receipt', 'user', 'category'
  resource_id UUID,
  ip_address INET,
  user_agent TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_user_id ON receipts.audit_log(user_id);
CREATE INDEX idx_audit_created_at ON receipts.audit_log(created_at DESC);
```

---

### PHASE 2: FREEMIUM CORE — RECEIPT LIFECYCLE + LIMITS
**Duration**: 3 days
**Outcome**: Users can upload receipts with freemium limits enforced

**Tasks**:
1. Create receipts table with SHA256 deduplication
2. Implement file upload endpoint (multipart/form-data)
3. Build receipt counter middleware (enforces 10/month limit)
4. Create controlled categories table (7 CRA-compliant categories)
5. Implement ephemeral deletion cron (7-day TTL for free tier)
6. Add forensics triggers (track all modifications)

**Deliverables**:
- ✅ Users can upload receipt images (PNG, JPG, PDF)
- ✅ SHA256 prevents duplicate uploads (returns existing receipt)
- ✅ 11th upload attempt blocked with upgrade message
- ✅ Receipts auto-delete 7 days after upload (free tier)
- ✅ All changes logged to audit_log table

**Schema Changes**:
```sql
-- Receipts table
CREATE TABLE receipts.receipts (
  receipt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES receipts.users(user_id),

  -- File metadata
  original_filename TEXT NOT NULL,
  file_hash TEXT UNIQUE NOT NULL,  -- SHA256 for deduplication
  file_size_bytes INTEGER NOT NULL,
  mime_type TEXT NOT NULL CHECK (mime_type IN ('image/png', 'image/jpeg', 'application/pdf')),
  storage_path TEXT NOT NULL,  -- /var/phoenix_receipts_data/{user_id}/{receipt_id}.ext

  -- Extraction status
  extraction_status TEXT DEFAULT 'pending' CHECK (extraction_status IN ('pending', 'processing', 'completed', 'failed', 'manual_review')),
  ai_confidence_score NUMERIC(3,2),  -- 0.00 to 1.00

  -- Extracted fields (Canadian CRA compliance)
  vendor_name TEXT,
  transaction_date DATE,
  total_amount NUMERIC(10,2),
  tax_amount NUMERIC(10,2),
  currency TEXT DEFAULT 'CAD',
  category_id INTEGER REFERENCES receipts.categories(category_id),

  -- Manual override tracking
  manually_edited BOOLEAN DEFAULT FALSE,
  edited_by UUID REFERENCES receipts.users(user_id),
  edited_at TIMESTAMPTZ,

  -- Lifecycle management
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,  -- Free tier: 7 days from upload
  deleted_at TIMESTAMPTZ,  -- Soft delete

  -- AI extraction metadata
  raw_ai_response JSONB,  -- Full Llava response for debugging
  extraction_model TEXT DEFAULT 'llava:34b',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories (CRA T2125 business expense categories)
CREATE TABLE receipts.categories (
  category_id SERIAL PRIMARY KEY,
  category_code TEXT UNIQUE NOT NULL,  -- 'MEALS', 'TRAVEL', 'OFFICE', etc.
  category_name TEXT NOT NULL,
  cra_line_number TEXT,  -- T2125 line reference
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE
);

-- Seed CRA categories
INSERT INTO receipts.categories (category_code, category_name, cra_line_number, description) VALUES
  ('ADVERTISING', 'Advertising', '8521', 'Promotion and marketing expenses'),
  ('MEALS', 'Meals & Entertainment', '8523', 'Business meals (50% deductible)'),
  ('VEHICLE', 'Vehicle Expenses', '9281', 'Fuel, maintenance, insurance'),
  ('TRAVEL', 'Travel', '8523', 'Airfare, hotels, transit'),
  ('OFFICE', 'Office Expenses', '8810', 'Supplies, software, equipment'),
  ('PROFESSIONAL', 'Professional Fees', '8862', 'Legal, accounting, consulting'),
  ('UTILITIES', 'Utilities', '9220', 'Phone, internet, hydro');

-- Forensics trigger
CREATE OR REPLACE FUNCTION receipts.log_receipt_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO receipts.audit_log (user_id, action, resource_type, resource_id, metadata)
    VALUES (
      NEW.user_id,
      'receipt_updated',
      'receipt',
      NEW.receipt_id,
      jsonb_build_object(
        'old_values', to_jsonb(OLD),
        'new_values', to_jsonb(NEW)
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER receipt_audit_trigger
AFTER UPDATE ON receipts.receipts
FOR EACH ROW EXECUTE FUNCTION receipts.log_receipt_changes();

-- Ephemeral deletion function (cron job calls this)
CREATE OR REPLACE FUNCTION receipts.delete_expired_receipts()
RETURNS TABLE(deleted_count INTEGER) AS $$
DECLARE
  count INTEGER;
BEGIN
  WITH deleted AS (
    UPDATE receipts.receipts
    SET deleted_at = NOW()
    WHERE expires_at < NOW()
      AND deleted_at IS NULL
      AND user_id IN (SELECT user_id FROM receipts.users WHERE subscription_tier = 'free')
    RETURNING receipt_id
  )
  SELECT COUNT(*)::INTEGER INTO count FROM deleted;

  RETURN QUERY SELECT count;
END;
$$ LANGUAGE plpgsql;
```

**Cron Job** (runs daily via docker-compose healthcheck or external cron):
```bash
# Add to phoenix_receipts service startup script
# /opt/phoenix/srv/receipts/cron/daily_cleanup.sh
#!/bin/bash
docker exec phoenix_postgres psql -U phoenix -d phoenix_core -c "SELECT receipts.delete_expired_receipts();"
```

---

### PHASE 3: AI ORACLE — PHD-LEVEL LLAVA:34B EXTRACTION
**Duration**: 4 days
**Outcome**: PhD-level receipt understanding with 95%+ accuracy

**Tasks**:
1. Design Llava:34b prompt engineering (receipts are sacred documents)
2. Implement fallback cascade (Llava:34b → Llava:13b → manual review)
3. Build confidence scoring algorithm (0.00-1.00)
4. Create manual review queue (receipts with confidence < 0.85)
5. Implement field normalization (vendor aliases, date parsing)
6. Add vendor learning system (user corrections train future extractions)

**Deliverables**:
- ✅ Receipt uploaded → Llava:34b extracts fields within 5 seconds
- ✅ Confidence ≥ 0.85 → auto-approved
- ✅ Confidence < 0.85 → manual review queue
- ✅ User corrections stored and learned from
- ✅ Vendor name normalization (e.g., "TIMHORTONS" → "Tim Hortons")

**Llava Prompt Template**:
```python
LLAVA_RECEIPT_PROMPT = """You are a PhD-level forensic accountant analyzing a receipt image for Canadian CRA tax compliance.

Extract the following fields with EXTREME precision. If uncertain, return null for that field.

Required fields:
1. vendor_name: Official business name (normalized, title case)
2. transaction_date: YYYY-MM-DD format (if month/year only, use first of month)
3. total_amount: Total paid (numeric only, no currency symbols)
4. tax_amount: GST/HST/PST total (if itemized separately, sum all taxes)
5. currency: Currency code (default CAD if not specified)
6. category: Best match from [ADVERTISING, MEALS, VEHICLE, TRAVEL, OFFICE, PROFESSIONAL, UTILITIES]

Quality requirements:
- If receipt is blurry/unreadable, set confidence to 0.00
- If date is ambiguous (handwritten, smudged), flag for manual review
- If amount has multiple interpretations, choose the TOTAL line
- Ignore tips/gratuity unless explicitly included in total

Return ONLY valid JSON:
{
  "vendor_name": "string or null",
  "transaction_date": "YYYY-MM-DD or null",
  "total_amount": 123.45 or null,
  "tax_amount": 12.34 or null,
  "currency": "CAD",
  "category": "OFFICE",
  "confidence": 0.95,
  "reasoning": "Clear receipt, all fields legible, standard format"
}

Analyze this receipt now:
"""
```

**Python Implementation** (`/opt/phoenix/srv/receipts/ai/llava_extractor.py`):
```python
import aiohttp
import json
from typing import Optional, Dict, Any

async def extract_receipt_fields(image_path: str) -> Dict[str, Any]:
    """Extract receipt fields using Llava:34b with fallback cascade."""

    # Try Llava:34b first (primary)
    result = await _call_llava_model("llava:34b", image_path)

    if result and result.get('confidence', 0) >= 0.85:
        return result

    # Fallback to Llava:13b (faster, lower quality)
    result = await _call_llava_model("llava:13b", image_path)

    if result and result.get('confidence', 0) >= 0.70:
        return result

    # Manual review required
    return {
        "extraction_status": "manual_review",
        "confidence": result.get('confidence', 0) if result else 0,
        "reason": "Low confidence extraction"
    }

async def _call_llava_model(model: str, image_path: str) -> Optional[Dict]:
    """Call Ollama Llava model via HTTP API."""

    with open(image_path, 'rb') as f:
        image_base64 = base64.b64encode(f.read()).decode()

    payload = {
        "model": model,
        "prompt": LLAVA_RECEIPT_PROMPT,
        "images": [image_base64],
        "stream": False,
        "options": {
            "temperature": 0.1,  # Low temp for deterministic extraction
            "top_p": 0.9
        }
    }

    async with aiohttp.ClientSession() as session:
        async with session.post(
            "http://phoenix_ollama:11434/api/generate",
            json=payload,
            timeout=aiohttp.ClientTimeout(total=60)
        ) as resp:
            if resp.status != 200:
                return None

            data = await resp.json()

            try:
                # Parse JSON response from Llava
                extracted = json.loads(data['response'])
                extracted['model_used'] = model
                return extracted
            except json.JSONDecodeError:
                # Llava didn't return valid JSON
                return {
                    "extraction_status": "failed",
                    "confidence": 0.0,
                    "raw_response": data['response']
                }
```

---

### PHASE 4: GENIUS UX — HTMX DRAG-DROP + CANADIAN EXCEL EXPORT
**Duration**: 3 days
**Outcome**: Seamless UX with zero JavaScript frameworks

**Tasks**:
1. Build HTMX drag-and-drop upload zone
2. Implement real-time progress indicators (htmx:sse)
3. Create receipt grid view (sortable, filterable)
4. Build one-click Excel export with openpyxl
5. Design Canadian CRA T2125 auto-fill template
6. Add receipt detail modal (click to edit/review)

**Deliverables**:
- ✅ Drag receipt image → instant upload with progress bar
- ✅ Grid shows all receipts with status badges (✅ processed, ⏳ processing, ⚠️ review)
- ✅ Click "Export to Excel" → T2125-ready workbook downloads
- ✅ Click receipt → modal with edit form (vendor, date, amount, category)
- ✅ All interactions < 200ms perceived latency

**HTML Template** (`/opt/phoenix/srv/receipts/templates/upload.html`):
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Expense Empire — Upload Receipts</title>
  <script src="https://unpkg.com/htmx.org@1.9.10"></script>
  <style>
    .drop-zone {
      border: 2px dashed #3b82f6;
      border-radius: 8px;
      padding: 3rem;
      text-align: center;
      transition: all 0.3s;
    }
    .drop-zone.dragging {
      background: #dbeafe;
      border-color: #1d4ed8;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Expense Empire</h1>
    <p>You've used <strong>{{ receipts_this_month }}</strong> of <strong>{{ monthly_limit }}</strong> receipts this month.</p>

    <div
      id="drop-zone"
      class="drop-zone"
      hx-post="/api/receipts/upload"
      hx-encoding="multipart/form-data"
      hx-target="#receipt-grid"
      hx-swap="afterbegin"
    >
      <p>📸 Drag receipt here or click to upload</p>
      <input type="file" name="file" accept="image/*,application/pdf" multiple style="display:none">
    </div>

    <div id="receipt-grid" hx-get="/api/receipts/list" hx-trigger="load">
      <!-- Receipts load here -->
    </div>
  </div>

  <script>
    // Drag-and-drop enhancement
    const dropZone = document.getElementById('drop-zone');
    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault();
      dropZone.classList.add('dragging');
    });
    dropZone.addEventListener('dragleave', () => {
      dropZone.classList.remove('dragging');
    });
  </script>
</body>
</html>
```

**Excel Export** (`/opt/phoenix/srv/receipts/export/excel_generator.py`):
```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment
from datetime import datetime

def generate_cra_t2125_export(user_id: str, year: int) -> bytes:
    """Generate T2125-ready Excel workbook with categorized expenses."""

    wb = Workbook()
    ws = wb.active
    ws.title = f"Business Expenses {year}"

    # Header styling
    header_fill = PatternFill(start_color="1F4788", end_color="1F4788", fill_type="solid")
    header_font = Font(color="FFFFFF", bold=True)

    # Headers
    headers = ["Date", "Vendor", "Category", "Amount", "Tax", "Total", "CRA Line"]
    for col, header in enumerate(headers, 1):
        cell = ws.cell(1, col, header)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="center")

    # Fetch receipts from database
    receipts = fetch_user_receipts(user_id, year)

    # Populate rows
    row = 2
    for receipt in receipts:
        ws.cell(row, 1, receipt['transaction_date'].strftime('%Y-%m-%d'))
        ws.cell(row, 2, receipt['vendor_name'])
        ws.cell(row, 3, receipt['category_name'])
        ws.cell(row, 4, receipt['total_amount'] - receipt['tax_amount'])
        ws.cell(row, 5, receipt['tax_amount'])
        ws.cell(row, 6, receipt['total_amount'])
        ws.cell(row, 7, receipt['cra_line_number'])
        row += 1

    # Summary sheet
    summary = wb.create_sheet("T2125 Summary")
    summary['A1'] = "CRA T2125 Expense Summary"
    summary['A1'].font = Font(size=14, bold=True)

    # Group by category
    category_totals = {}
    for receipt in receipts:
        cat = receipt['category_name']
        category_totals[cat] = category_totals.get(cat, 0) + receipt['total_amount']

    summary['A3'] = "Category"
    summary['B3'] = "Total"
    summary['C3'] = "CRA Line"

    row = 4
    for category, total in sorted(category_totals.items()):
        summary.cell(row, 1, category)
        summary.cell(row, 2, f"${total:,.2f}")
        summary.cell(row, 3, get_cra_line(category))
        row += 1

    # Save to bytes
    from io import BytesIO
    output = BytesIO()
    wb.save(output)
    output.seek(0)
    return output.read()
```

---

### PHASE 5: SLIME EVOLUTION — NEUROTRANSMITTER GAMIFICATION
**Duration**: 2 days
**Outcome**: Users become addicted, viral loop activated

**Tasks**:
1. Create neurotransmitter tracking table (dopamine, serotonin, oxytocin)
2. Implement weekly behavior rewiring (nudges, streaks, achievements)
3. Add heat donor flag (future: 20% compute donation checkbox)
4. Build referral system (invite friends → both get +10 receipts)
5. Create progress dashboard (receipts processed, money organized, time saved)

**Deliverables**:
- ✅ User sees "🔥 7-day streak!" badge after 7 consecutive days of uploads
- ✅ Dopamine spike: "✨ You've organized $12,450 in expenses this year!"
- ✅ Heat donor checkbox: "Donate 20% of idle compute to heat cold homes (coming soon)"
- ✅ Referral link: "Invite friends → you both get +10 receipts/month"

**Schema Changes**:
```sql
-- Neurotransmitter gamification
CREATE TABLE receipts.user_neurotransmitters (
  user_id UUID PRIMARY KEY REFERENCES receipts.users(user_id),

  -- Dopamine (achievement, progress)
  dopamine_score INTEGER DEFAULT 0,
  current_streak_days INTEGER DEFAULT 0,
  longest_streak_days INTEGER DEFAULT 0,
  total_receipts_processed INTEGER DEFAULT 0,

  -- Serotonin (status, comparison)
  percentile_rank INTEGER,  -- Top X% of users
  achievement_badges TEXT[],  -- ['first_upload', 'week_streak', 'power_user']

  -- Oxytocin (social, trust)
  referral_code TEXT UNIQUE DEFAULT substring(md5(random()::text), 1, 8),
  referred_by UUID REFERENCES receipts.users(user_id),
  successful_referrals INTEGER DEFAULT 0,

  -- Heat donor future hook
  heat_donor_opted_in BOOLEAN DEFAULT FALSE,
  heat_donor_since TIMESTAMPTZ,

  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Weekly rewiring function (cron: every Monday 6am)
CREATE OR REPLACE FUNCTION receipts.weekly_neurotransmitter_update()
RETURNS VOID AS $$
BEGIN
  -- Update percentile ranks
  WITH ranked_users AS (
    SELECT
      user_id,
      PERCENT_RANK() OVER (ORDER BY total_receipts_processed DESC) * 100 AS percentile
    FROM receipts.user_neurotransmitters
  )
  UPDATE receipts.user_neurotransmitters u
  SET percentile_rank = r.percentile::INTEGER
  FROM ranked_users r
  WHERE u.user_id = r.user_id;

  -- Award streak badges
  UPDATE receipts.user_neurotransmitters
  SET achievement_badges = array_append(achievement_badges, 'week_warrior')
  WHERE current_streak_days >= 7
    AND NOT ('week_warrior' = ANY(achievement_badges));

  -- Reset monthly receipt counters (first Monday of month)
  IF EXTRACT(DAY FROM CURRENT_DATE) <= 7 THEN
    UPDATE receipts.users
    SET
      receipts_uploaded_this_month = 0,
      month_reset_date = date_trunc('month', CURRENT_DATE) + INTERVAL '1 month';
  END IF;
END;
$$ LANGUAGE plpgsql;
```

---

## 3. COMPLETE FILE MANIFEST

### Files to CREATE (27 new files)

```
/opt/phoenix/
├── etc/
│   ├── schemas/
│   │   ├── grafana_reader_user.sql                    [TD-1 fix]
│   │   └── expense_empire.sql                         [All Phase 1-5 schemas combined]
│   ├── compose/
│   │   └── docker-compose.tier5-saas.yml              [Phase 1: nginx + receipts API]
│   └── nginx/
│       ├── nginx.conf                                 [Phase 1: Reverse proxy config]
│       └── ssl/                                       [Future: Let's Encrypt certs]
│
├── srv/
│   └── receipts/                                      [New microservice]
│       ├── main.py                                    [Phase 1: FastAPI app entry]
│       ├── config.py                                  [Phase 1: Environment config]
│       ├── requirements.txt                           [Phase 1: Python deps]
│       │
│       ├── api/                                       [Phase 1-4: API endpoints]
│       │   ├── __init__.py
│       │   ├── auth.py                                [Phase 1: JWT auth, register, login]
│       │   ├── receipts.py                            [Phase 2: Upload, list, delete]
│       │   ├── categories.py                          [Phase 2: Category management]
│       │   └── export.py                              [Phase 4: Excel export]
│       │
│       ├── models/                                    [Phase 1-2: Data models]
│       │   ├── __init__.py
│       │   ├── user.py                                [Phase 1: User Pydantic model]
│       │   ├── receipt.py                             [Phase 2: Receipt model]
│       │   └── category.py                            [Phase 2: Category model]
│       │
│       ├── middleware/                                [Phase 1: Security]
│       │   ├── __init__.py
│       │   ├── jwt_auth.py                            [Phase 1: JWT validation decorator]
│       │   ├── rate_limit.py                          [Phase 1: 100 req/min per user]
│       │   └── audit_log.py                           [Phase 1: Auto-log all requests]
│       │
│       ├── ai/                                        [Phase 3: AI extraction]
│       │   ├── __init__.py
│       │   ├── llava_extractor.py                     [Phase 3: Llava:34b integration]
│       │   ├── prompt_templates.py                    [Phase 3: Prompt engineering]
│       │   └── confidence_scoring.py                  [Phase 3: 0.00-1.00 scoring]
│       │
│       ├── export/                                    [Phase 4: Excel generation]
│       │   ├── __init__.py
│       │   ├── excel_generator.py                     [Phase 4: T2125 export]
│       │   └── templates/t2125_template.xlsx          [Phase 4: Excel template]
│       │
│       ├── templates/                                 [Phase 4: HTMX UI]
│       │   ├── base.html
│       │   ├── upload.html                            [Phase 4: Drag-drop upload]
│       │   ├── receipts_list.html                     [Phase 4: Grid view]
│       │   └── receipt_detail.html                    [Phase 4: Edit modal]
│       │
│       ├── cron/                                      [Phase 2+5: Background jobs]
│       │   ├── daily_cleanup.sh                       [Phase 2: Delete expired receipts]
│       │   └── weekly_rewiring.sh                     [Phase 5: Neurotransmitter updates]
│       │
│       └── tests/                                     [Phase 1-5: Test coverage]
│           ├── test_auth.py
│           ├── test_receipts.py
│           └── test_ai_extraction.py
│
└── var/
    └── phoenix_receipts_data/                         [Phase 2: Receipt file storage]
        └── {user_id}/                                 [User-isolated directories]
            └── {receipt_id}.{ext}                     [Actual image files]
```

### Files to MODIFY (11 existing files)

```
TECHNICAL DEBT FIXES:
1. /opt/phoenix/etc/observability/grafana/datasources/datasources.yml    [TD-1]
2. /opt/phoenix/srv/agents/task_board_api.py                             [TD-2]
3. /opt/phoenix/srv/crewai/agents/alpha_1_data_miner.py                  [TD-2]
4. /opt/phoenix/etc/compose/docker-compose.tier4.yml                     [TD-3]
5. /opt/phoenix/sbin/phoenix-resurrect                                   [TD-4]
6. /opt/phoenix/bin/phoenix-essential-models.sh                          [TD-5]
7. /opt/phoenix/etc/compose/docker-compose.tier2.yml                     [TD-6]
8. /opt/phoenix/lib/phoenix-functions.sh                                 [TD-7]
9. /opt/phoenix/sbin/phoenix-boot.sh                                     [TD-7]

ENVIRONMENT UPDATES:
10. /opt/phoenix/etc/compose/.env                                        [Add GRAFANA_DB_PASSWORD, JWT_SECRET]

SHELL FUNCTIONS:
11. /opt/phoenix/share/dotfiles/bashrc-phoenix                           [Add ph-receipts command]
```

---

## 4. SECURITY & FORENSICS MODEL

### 4.1 JWT Authentication Flow

```
┌─────────┐                  ┌──────────────┐                  ┌──────────┐
│ Browser │                  │ phoenix_     │                  │ postgres │
│         │                  │ receipts API │                  │          │
└────┬────┘                  └──────┬───────┘                  └────┬─────┘
     │                              │                                │
     │  POST /auth/register         │                                │
     ├─────────────────────────────>│ bcrypt.hashpw(password, 12)   │
     │  {email, password}           ├───────────────────────────────>│
     │                              │ INSERT INTO users              │
     │                              │<───────────────────────────────┤
     │  201 Created                 │                                │
     │<─────────────────────────────┤                                │
     │                              │                                │
     │  POST /auth/login            │                                │
     ├─────────────────────────────>│ SELECT password_hash           │
     │  {email, password}           ├───────────────────────────────>│
     │                              │<───────────────────────────────┤
     │                              │ bcrypt.checkpw(password, hash) │
     │                              │ jwt.encode({user_id, exp})     │
     │  200 OK                      │                                │
     │  {access_token, expires_in}  │                                │
     │<─────────────────────────────┤                                │
     │                              │                                │
     │  GET /api/receipts/list      │                                │
     │  Authorization: Bearer <JWT> │                                │
     ├─────────────────────────────>│ jwt.decode(token)              │
     │                              │ verify exp > now()             │
     │                              │ SELECT * FROM receipts         │
     │                              │ WHERE user_id = {decoded.sub}  │
     │                              ├───────────────────────────────>│
     │                              │<───────────────────────────────┤
     │  200 OK                      │                                │
     │  [{receipt_1}, {receipt_2}]  │                                │
     │<─────────────────────────────┤                                │
```

### 4.2 JWT Token Structure

```python
# JWT Payload (issued by /auth/login)
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",  # user_id
  "email": "user@example.com",
  "tier": "free",                                 # subscription_tier
  "iat": 1700000000,                              # issued_at (Unix timestamp)
  "exp": 1700086400,                              # expires_at (24h later)
  "jti": "unique-token-id"                        # JWT ID for revocation
}

# Signed with HS256 algorithm
# Secret key: ${JWT_SECRET} (64-char random string in .env)
```

### 4.3 Password Security (bcrypt)

```python
import bcrypt

# Registration
password = "user_input_password"
salt = bcrypt.gensalt(rounds=12)  # Cost factor 12 (2^12 = 4096 iterations)
password_hash = bcrypt.hashpw(password.encode(), salt)
# Store password_hash in database (60-char string)

# Login validation
stored_hash = fetch_from_db(email)
if bcrypt.checkpw(password.encode(), stored_hash.encode()):
    # Issue JWT token
    pass
else:
    # Return 401 Unauthorized
    pass
```

**Cost Factor Rationale**:
- Cost 12 = ~250ms per hash on modern CPU
- Prevents brute-force attacks (10,000 attempts = 42 minutes)
- Balances security vs user experience

### 4.4 Audit Trail — Forensics Triggers

**Every API request logged**:
```sql
-- Automatically logged by middleware
INSERT INTO receipts.audit_log (user_id, action, ip_address, user_agent, metadata)
VALUES (
  '550e8400-e29b-41d4-a716-446655440000',
  'receipt_uploaded',
  '192.168.1.100',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  '{"filename": "starbucks_receipt.jpg", "file_size": 245678}'
);
```

**Database-level triggers** (automatic on UPDATE):
```sql
-- Already created in Phase 2
CREATE TRIGGER receipt_audit_trigger
AFTER UPDATE ON receipts.receipts
FOR EACH ROW EXECUTE FUNCTION receipts.log_receipt_changes();
```

**Forensics Query Examples**:
```sql
-- Who deleted receipts in the last 24 hours?
SELECT user_id, COUNT(*) as deleted_count
FROM receipts.audit_log
WHERE action = 'receipt_deleted'
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY user_id;

-- Suspicious login activity (5+ failed attempts)
SELECT ip_address, COUNT(*) as failed_logins
FROM receipts.audit_log
WHERE action = 'login_failed'
  AND created_at > NOW() - INTERVAL '1 hour'
GROUP BY ip_address
HAVING COUNT(*) >= 5;

-- Data exfiltration detection (>100 receipts exported in 1 hour)
SELECT user_id, COUNT(*) as export_count
FROM receipts.audit_log
WHERE action = 'receipts_exported'
  AND created_at > NOW() - INTERVAL '1 hour'
GROUP BY user_id
HAVING COUNT(*) > 100;
```

### 4.5 Rate Limiting (Middleware)

```python
# /opt/phoenix/srv/receipts/middleware/rate_limit.py
from fastapi import HTTPException
from datetime import datetime, timedelta
import redis

redis_client = redis.Redis(
    host='phoenix_redis',
    port=6379,
    password=os.getenv('REDIS_PASSWORD'),
    decode_responses=True
)

async def rate_limit_middleware(user_id: str, endpoint: str):
    """Enforce 100 requests/minute per user per endpoint."""

    key = f"rate_limit:{user_id}:{endpoint}"
    current_count = redis_client.get(key)

    if current_count and int(current_count) >= 100:
        raise HTTPException(
            status_code=429,
            detail="Rate limit exceeded. Try again in 60 seconds."
        )

    # Increment counter with 60-second TTL
    pipe = redis_client.pipeline()
    pipe.incr(key)
    pipe.expire(key, 60)
    pipe.execute()
```

### 4.6 Security Checklist

**OWASP Top 10 Mitigations**:
- ✅ **A01: Broken Access Control** → JWT validation on all endpoints, user_id in WHERE clauses
- ✅ **A02: Cryptographic Failures** → bcrypt for passwords, JWT HS256 signing
- ✅ **A03: Injection** → Parameterized SQL queries (psycopg2 placeholders)
- ✅ **A04: Insecure Design** → Multi-tenancy by design (user_id foreign keys)
- ✅ **A05: Security Misconfiguration** → All services localhost-bound, strong passwords
- ✅ **A06: Vulnerable Components** → Python dependencies pinned in requirements.txt
- ✅ **A07: Identification Failures** → JWT expiry (24h), rate limiting
- ✅ **A08: Data Integrity Failures** → Audit log triggers, SHA256 file hashing
- ✅ **A09: Logging Failures** → Comprehensive audit_log table
- ✅ **A10: SSRF** → No user-supplied URLs, file uploads validated by MIME type

---

## 5. DOCKER-COMPOSE ADDITIONS

### New File: `/opt/phoenix/etc/compose/docker-compose.tier5-saas.yml`

```yaml
version: '3.8'

services:
  # ============================================================================
  # NGINX — Reverse Proxy + SSL Termination
  # ============================================================================
  phoenix_nginx:
    image: nginx:1.25-alpine
    container_name: phoenix_nginx
    restart: unless-stopped
    ports:
      - "127.0.0.1:80:80"
      - "127.0.0.1:443:443"
    volumes:
      - /opt/phoenix/etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - /opt/phoenix/etc/nginx/ssl:/etc/nginx/ssl:ro
    networks:
      - phoenix_tier3
    depends_on:
      - phoenix_receipts_api
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ============================================================================
  # EXPENSE EMPIRE — FastAPI Receipt Processing Service
  # ============================================================================
  phoenix_receipts_api:
    build:
      context: /opt/phoenix/srv/receipts
      dockerfile: Dockerfile
    container_name: phoenix_receipts
    restart: unless-stopped
    ports:
      - "127.0.0.1:8000:8000"
    environment:
      # Database
      POSTGRES_HOST: phoenix_postgres
      POSTGRES_PORT: 5432
      POSTGRES_DB: phoenix_core
      POSTGRES_USER: phoenix
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}

      # Redis
      REDIS_HOST: phoenix_redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASSWORD}

      # JWT Authentication
      JWT_SECRET: ${JWT_SECRET}
      JWT_ALGORITHM: HS256
      JWT_EXPIRY_HOURS: 24

      # Ollama AI
      OLLAMA_HOST: http://phoenix_ollama:11434
      OLLAMA_PRIMARY_MODEL: llava:34b
      OLLAMA_FALLBACK_MODEL: llava:13b

      # File Storage
      UPLOAD_DIR: /var/receipts_data
      MAX_FILE_SIZE_MB: 10
      ALLOWED_EXTENSIONS: png,jpg,jpeg,pdf

      # Freemium Limits
      FREE_TIER_MONTHLY_LIMIT: 10
      FREE_TIER_TTL_DAYS: 7

      # System
      TZ: America/New_York
      LOG_LEVEL: INFO
    volumes:
      - /opt/phoenix/var/phoenix_receipts_data:/var/receipts_data
    networks:
      - phoenix_tier1  # Access to postgres, redis
      - phoenix_tier2  # Access to ollama
      - phoenix_tier3  # Access to nginx
    depends_on:
      - phoenix_postgres
      - phoenix_redis
      - phoenix_ollama
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4

networks:
  phoenix_tier1:
    external: true
  phoenix_tier2:
    external: true
  phoenix_tier3:
    external: true
```

### Dockerfile: `/opt/phoenix/srv/receipts/Dockerfile`

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies for PDF/image processing
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    poppler-utils \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 phoenix && chown -R phoenix:phoenix /app
USER phoenix

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### Python Dependencies: `/opt/phoenix/srv/receipts/requirements.txt`

```
# FastAPI Framework
fastapi==0.115.0
uvicorn[standard]==0.32.0
python-multipart==0.0.12

# Database
psycopg2-binary==2.9.11
asyncpg==0.30.0

# Redis
redis==5.2.0

# Authentication
pyjwt==2.10.1
bcrypt==4.2.1
passlib==1.7.4

# AI/ML
aiohttp==3.11.10
pillow==11.0.0

# Excel Export
openpyxl==3.1.5

# Utilities
python-dotenv==1.0.1
pydantic==2.10.3
pydantic-settings==2.6.1
```

### Nginx Config: `/opt/phoenix/etc/nginx/nginx.conf`

```nginx
events {
  worker_connections 1024;
}

http {
  upstream receipts_backend {
    server phoenix_receipts:8000;
  }

  # Rate limiting: 100 req/min per IP
  limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;

  server {
    listen 80;
    server_name localhost;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Health check (no rate limit)
    location /health {
      proxy_pass http://receipts_backend/health;
    }

    # API endpoints (rate limited)
    location /api/ {
      limit_req zone=api_limit burst=20 nodelay;

      proxy_pass http://receipts_backend;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      # Increase timeout for AI processing
      proxy_read_timeout 120s;
      proxy_send_timeout 120s;
    }

    # Frontend (HTMX templates)
    location / {
      proxy_pass http://receipts_backend;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
    }
  }
}
```

### Environment Variables to Add: `/opt/phoenix/etc/compose/.env`

```bash
# Expense Empire SaaS (Tier 5)
JWT_SECRET=<GENERATE_WITH_openssl_rand_-hex_32>
GRAFANA_DB_PASSWORD=<GENERATE_WITH_openssl_rand_-base64_32>
```

---

## EXECUTION TIMELINE

```
DAY 1-2:   Phase 1 (Foundation)
  - Fix all 7 technical debt items
  - Create receipts schema
  - Build JWT auth system
  - Deploy Tier 5 infrastructure

DAY 3-5:   Phase 2 (Freemium Core)
  - Receipt upload endpoints
  - File storage + deduplication
  - Freemium limits enforcement
  - Ephemeral deletion cron

DAY 6-9:   Phase 3 (AI Oracle)
  - Llava:34b integration
  - Prompt engineering
  - Confidence scoring
  - Manual review queue

DAY 10-12: Phase 4 (Genius UX)
  - HTMX drag-drop UI
  - Receipt grid view
  - Excel export with T2125 template
  - Edit modal

DAY 13-14: Phase 5 (Slime Evolution)
  - Neurotransmitter gamification
  - Streak tracking
  - Referral system
  - Heat donor flag

DAY 15:    Testing + Production Launch
  - End-to-end testing
  - Load testing (100 concurrent users)
  - Security audit
  - Deploy to production
```

---

## SUCCESS METRICS

**Phase 1**: User can register, login, receive JWT token (100% auth success rate)
**Phase 2**: User can upload 10 receipts, 11th blocked, all delete after 7 days (0 data leaks)
**Phase 3**: 95%+ receipts extracted with confidence ≥ 0.85 (manual review < 5%)
**Phase 4**: Users export Excel in < 3 seconds (avg 1.2s)
**Phase 5**: 30%+ users return weekly (dopamine hooks working)

---

## PLAN COMPLETE — ETCHING INTO Claude_SaaS.md AUTHORIZED — AWAITING EXECUTION ORDER
