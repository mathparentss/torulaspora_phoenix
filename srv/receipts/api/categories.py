"""
Categories API Endpoints
CRA T2125 business expense categories
"""
from fastapi import APIRouter, Depends
import psycopg2
import logging

from config import settings
from middleware.jwt_auth import get_current_user

logger = logging.getLogger(__name__)
router = APIRouter()


def get_db():
    """Get database connection"""
    return psycopg2.connect(settings.database_url)


@router.get("/")
async def list_categories(current_user: dict = Depends(get_current_user)):
    """
    List all active expense categories

    Returns CRA-compliant T2125 categories for Canadian business expenses
    """
    conn = get_db()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT
                category_id,
                category_code,
                category_name,
                cra_line_number,
                description
            FROM receipts.categories
            WHERE is_active = TRUE
            ORDER BY category_name
        """)

        categories = []
        for row in cur.fetchall():
            categories.append({
                "category_id": row[0],
                "category_code": row[1],
                "category_name": row[2],
                "cra_line_number": row[3],
                "description": row[4]
            })

        return {"categories": categories, "count": len(categories)}

    finally:
        cur.close()
        conn.close()
