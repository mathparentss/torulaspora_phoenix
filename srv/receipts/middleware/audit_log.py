"""
Audit Log Middleware
Logs all API requests to the database for forensics and compliance
"""
import psycopg2
from fastapi import Request, Response
from datetime import datetime
import logging
import json

from config import settings

logger = logging.getLogger(__name__)


async def audit_middleware(request: Request, call_next):
    """Log all requests to audit_log table"""

    # Extract user_id from JWT if present
    user_id = None
    if "authorization" in request.headers:
        try:
            from middleware.jwt_auth import verify_jwt_token
            token = request.headers["authorization"].split()[1]
            payload = verify_jwt_token(token)
            user_id = payload.get("sub")
        except:
            pass  # Continue without user_id if token invalid

    # Process request
    response = await call_next(request)

    # Log to database (async in background to not block response)
    try:
        conn = psycopg2.connect(settings.database_url)
        cur = conn.cursor()

        action = f"{request.method} {request.url.path}"
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        # Determine resource type from path
        resource_type = None
        if "/receipts/" in request.url.path:
            resource_type = "receipt"
        elif "/users/" in request.url.path:
            resource_type = "user"
        elif "/auth/" in request.url.path:
            resource_type = "auth"

        metadata = {
            "method": request.method,
            "path": str(request.url.path),
            "status_code": response.status_code,
            "query_params": dict(request.query_params),
        }

        cur.execute("""
            INSERT INTO receipts.audit_log
            (user_id, action, resource_type, ip_address, user_agent, metadata)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (user_id, action, resource_type, ip_address, user_agent, json.dumps(metadata)))

        conn.commit()
        cur.close()
        conn.close()

    except Exception as e:
        logger.error(f"Audit logging failed: {e}")
        # Don't fail the request if audit logging fails

    return response
