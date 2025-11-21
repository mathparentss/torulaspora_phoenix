"""
Receipts API Endpoints
Upload, list, and manage receipts (Phase 2+ implementation)
"""
from fastapi import APIRouter, Depends, HTTPException
import psycopg2
import logging

from config import settings
from middleware.jwt_auth import get_current_user

logger = logging.getLogger(__name__)
router = APIRouter()


def get_db():
    """Get database connection"""
    return psycopg2.connect(settings.database_url)


@router.get("/list")
async def list_receipts(current_user: dict = Depends(get_current_user)):
    """
    List all receipts for current user

    Phase 1: Basic stub
    Phase 2: Full implementation with pagination, filtering
    """
    conn = get_db()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT
                receipt_id,
                original_filename,
                vendor_name,
                transaction_date,
                total_amount,
                extraction_status,
                uploaded_at
            FROM receipts.receipts
            WHERE user_id = %s AND deleted_at IS NULL
            ORDER BY uploaded_at DESC
            LIMIT 50
        """, (current_user["sub"],))

        receipts = []
        for row in cur.fetchall():
            receipts.append({
                "receipt_id": str(row[0]),
                "filename": row[1],
                "vendor": row[2],
                "date": row[3].isoformat() if row[3] else None,
                "amount": float(row[4]) if row[4] else None,
                "status": row[5],
                "uploaded_at": row[6].isoformat()
            })

        return {"receipts": receipts, "count": len(receipts)}

    finally:
        cur.close()
        conn.close()


@router.post("/upload")
async def upload_receipt(current_user: dict = Depends(get_current_user)):
    """
    Upload new receipt

    Phase 1: Placeholder
    Phase 2: Full implementation with file upload, deduplication, AI extraction
    """
    raise HTTPException(status_code=501, detail="Receipt upload will be implemented in Phase 2")


@router.get("/{receipt_id}")
async def get_receipt(receipt_id: str, current_user: dict = Depends(get_current_user)):
    """
    Get single receipt details

    Phase 1: Placeholder
    Phase 2: Full implementation
    """
    raise HTTPException(status_code=501, detail="Receipt details will be implemented in Phase 2")
