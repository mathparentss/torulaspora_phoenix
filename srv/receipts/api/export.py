"""
Export API Endpoints
Excel export with CRA T2125 template (Phase 4 implementation)
"""
from fastapi import APIRouter, Depends, HTTPException
import logging

from middleware.jwt_auth import get_current_user

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/excel")
async def export_to_excel(
    year: int = None,
    current_user: dict = Depends(get_current_user)
):
    """
    Export receipts to Excel with CRA T2125 format

    Phase 1: Placeholder
    Phase 4: Full implementation with openpyxl and T2125 template
    """
    raise HTTPException(
        status_code=501,
        detail="Excel export will be implemented in Phase 4"
    )
