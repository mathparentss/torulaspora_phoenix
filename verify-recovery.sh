#!/usr/bin/env bash
#
# PHOENIX PHASE 1.5 — RECOVERY VERIFICATION SCRIPT
# Verifies all critical files were recovered successfully
# Usage: ./verify-recovery.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check() {
    if [[ -e "$1" ]]; then
        echo -e "${GREEN}✅${NC} $2"
        return 0
    else
        echo -e "${RED}❌${NC} $2 (MISSING: $1)"
        return 1
    fi
}

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  PHOENIX RECOVERY VERIFICATION"
echo "═══════════════════════════════════════════════════════════"
echo ""

FAILURES=0

echo -e "${BLUE}[1] Documentation Files${NC}"
check "/opt/phoenix/share/docs/CLAUDE_ROOT.md" "CLAUDE.md (root)" || ((FAILURES++))
check "/opt/phoenix/share/docs/TIER0_OPTIMIZATION_REPORT.md" "TIER0_OPTIMIZATION_REPORT.md" || ((FAILURES++))
check "/opt/phoenix/.archive/snapshots/tree-20251118.md.gz" "tree.md snapshot (compressed)" || ((FAILURES++))

echo ""
echo -e "${BLUE}[2] Claude Code Configuration${NC}"
check "/opt/phoenix/.claude" ".claude/ directory" || ((FAILURES++))
check "/opt/phoenix/.claude/CLAUDE.md" ".claude/CLAUDE.md" || ((FAILURES++))
check "/opt/phoenix/.claude/settings.local.json" ".claude/settings.local.json" || ((FAILURES++))

echo ""
echo -e "${BLUE}[3] Deployment Scripts${NC}"
check "/opt/phoenix/sbin/legacy" "Legacy scripts directory" || ((FAILURES++))
if [[ -d "/opt/phoenix/sbin/legacy" ]]; then
    SCRIPT_COUNT=$(ls /opt/phoenix/sbin/legacy/*.sh 2>/dev/null | wc -l)
    echo -e "${GREEN}✅${NC} $SCRIPT_COUNT tier deployment scripts recovered"
fi

echo ""
echo -e "${BLUE}[4] Strategic Documentation${NC}"
check "/opt/phoenix/.archive/strategic/phoenix-architect-council.agent" "Strategic planning docs" || ((FAILURES++))

echo ""
echo -e "${BLUE}[5] Auxiliary Configs${NC}"
check "/opt/phoenix/etc/n8n" "n8n config directory" || ((FAILURES++))
check "/opt/phoenix/etc/vpn" "VPN config directory" || ((FAILURES++))

echo ""
echo -e "${BLUE}[6] Core Migration Files (Sanity Check)${NC}"
check "/opt/phoenix/etc/schemas/shadow_specter_db/SCHEMA_01_CORE.sql" "Shadow DB Schema 01" || ((FAILURES++))
check "/opt/phoenix/etc/compose/docker-compose.tier1.yml" "Docker Compose Tier 1" || ((FAILURES++))
check "/opt/phoenix/lib/phoenix-functions.sh" "Phoenix shell functions" || ((FAILURES++))
check "/opt/phoenix/share/dotfiles/bashrc-phoenix" "Bashrc" || ((FAILURES++))

echo ""
echo -e "${BLUE}[7] Git Repository${NC}"
check "/opt/phoenix/.git" "Git repository" || ((FAILURES++))

if [[ -d "/opt/phoenix/.git" ]]; then
    cd /opt/phoenix
    COMMITS=$(git log --oneline | wc -l)
    echo -e "${GREEN}✅${NC} Git history intact ($COMMITS commits)"

    UNSTAGED=$(git status --short | grep -v "^??" | wc -l)
    UNTRACKED=$(git status --short | grep "^??" | wc -l)
    echo -e "${GREEN}✅${NC} Git status: $UNSTAGED modified, $UNTRACKED untracked"
fi

echo ""
echo -e "${BLUE}[8] File Permissions${NC}"
ENV_PERMS=$(stat -c "%a" /opt/phoenix/etc/compose/.env 2>/dev/null || echo "???")
if [[ "$ENV_PERMS" == "600" ]]; then
    echo -e "${GREEN}✅${NC} .env permissions: $ENV_PERMS (secure)"
elif [[ "$ENV_PERMS" == "644" ]]; then
    echo -e "${RED}⚠️${NC} .env permissions: $ENV_PERMS (INSECURE - should be 600)"
    echo "    Fix with: chmod 600 /opt/phoenix/etc/compose/.env"
else
    echo -e "${RED}❌${NC} .env permissions: $ENV_PERMS (unexpected)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"

if [[ $FAILURES -eq 0 ]]; then
    echo -e "${GREEN}  ✅ ALL CHECKS PASSED${NC}"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Recovery complete! Safe to proceed with:"
    echo "  1. git commit (recovered files)"
    echo "  2. tar backup (/mnt/c/dev/phoenix)"
    echo "  3. rm -rf /mnt/c/dev/phoenix"
    echo ""
    exit 0
else
    echo -e "${RED}  ❌ $FAILURES CHECKS FAILED${NC}"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Some files are missing. Review failures above."
    echo "Re-run recovery script: sudo /opt/phoenix/recover-missing-files.sh"
    echo ""
    exit 1
fi
