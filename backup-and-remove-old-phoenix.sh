#!/usr/bin/env bash
#
# PHOENIX PHASE 1.5 — BACKUP & CLEANUP SCRIPT
# Creates tar backup of /mnt/c/dev/phoenix and optionally removes it
# Usage: sudo ./backup-and-remove-old-phoenix.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[BACKUP]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use sudo)"
    exit 1
fi

SOURCE="/mnt/c/dev/phoenix"
BACKUP_DIR="/opt/phoenix/.archive/migration-backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="phoenix_backup_${TIMESTAMP}.tar.gz"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  PHOENIX BACKUP & CLEANUP"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Verify source exists
if [[ ! -d "$SOURCE" ]]; then
    error "Source directory $SOURCE does not exist!"
    exit 1
fi

# Create backup directory
log "Creating backup directory..."
mkdir -p "$BACKUP_DIR"
chown phoenix:phoenix "$BACKUP_DIR"

# Calculate source size
SOURCE_SIZE=$(du -sh "$SOURCE" | cut -f1)
log "Source directory size: $SOURCE_SIZE"

# Create tar backup
log "Creating tar backup (this may take a few minutes)..."
log "Excluding: data/, logs/, phoenix.venv/, .git/"

cd /mnt/c/dev
tar \
  --exclude='phoenix/data' \
  --exclude='phoenix/logs' \
  --exclude='phoenix/phoenix.venv' \
  --exclude='phoenix/.git' \
  --exclude='phoenix/.git/*' \
  -czf "${BACKUP_FILE}" \
  phoenix/

if [[ $? -eq 0 ]]; then
    success "Tar backup created: ${BACKUP_FILE}"
else
    error "Tar backup FAILED!"
    exit 1
fi

# Move backup to archive
log "Moving backup to $BACKUP_DIR..."
mv "${BACKUP_FILE}" "$BACKUP_DIR/"
chown phoenix:phoenix "$BACKUP_DIR/${BACKUP_FILE}"

BACKUP_SIZE=$(du -sh "$BACKUP_DIR/${BACKUP_FILE}" | cut -f1)
success "Backup stored: $BACKUP_DIR/${BACKUP_FILE} ($BACKUP_SIZE)"

# Verify backup
log "Verifying backup integrity..."
FILE_COUNT=$(tar -tzf "$BACKUP_DIR/${BACKUP_FILE}" | wc -l)
success "Backup contains $FILE_COUNT files"

# Show sample of backup contents
log "Sample backup contents (first 20 files):"
tar -tzf "$BACKUP_DIR/${BACKUP_FILE}" | head -20

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  BACKUP COMPLETE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Backup location: $BACKUP_DIR/${BACKUP_FILE}"
echo "Backup size: $BACKUP_SIZE"
echo "File count: $FILE_COUNT files"
echo ""

# Prompt for deletion
warn "⚠️  DELETION PROMPT ⚠️"
echo ""
echo "The old Phoenix location can now be safely removed."
echo "Source: $SOURCE"
echo "Backup: $BACKUP_DIR/${BACKUP_FILE}"
echo ""
read -p "Do you want to DELETE /mnt/c/dev/phoenix now? (Type 'DELETE' to confirm): " CONFIRM

if [[ "$CONFIRM" == "DELETE" ]]; then
    log "Removing /mnt/c/dev/phoenix..."
    rm -rf "$SOURCE"

    if [[ ! -d "$SOURCE" ]]; then
        success "/mnt/c/dev/phoenix successfully removed!"
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        echo "  CLEANUP COMPLETE — PHOENIX NOW LIVES AT /opt/phoenix"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "Backup preserved at: $BACKUP_DIR/${BACKUP_FILE}"
        echo "Git repository: /opt/phoenix/.git"
        echo "Working directory: cd /opt/phoenix"
        echo ""
    else
        error "Deletion failed! $SOURCE still exists."
        exit 1
    fi
else
    warn "Deletion cancelled. /mnt/c/dev/phoenix preserved."
    echo "To delete manually later:"
    echo "  sudo rm -rf /mnt/c/dev/phoenix"
fi

echo ""
