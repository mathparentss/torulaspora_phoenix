"""
JWT Authentication Middleware
Validates JWT tokens and extracts user information
"""
from fastapi import HTTPException, Depends, Header
from datetime import datetime, timedelta
import jwt
import logging

from config import settings

logger = logging.getLogger(__name__)


def create_jwt_token(user_id: str, email: str, tier: str) -> str:
    """Create a new JWT token for authenticated user"""
    payload = {
        "sub": user_id,
        "email": email,
        "tier": tier,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=settings.JWT_EXPIRY_HOURS),
    }
    token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return token


def verify_jwt_token(token: str) -> dict:
    """Verify JWT token and return payload"""
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM]
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


async def get_current_user(authorization: str = Header(None)) -> dict:
    """Dependency to get current authenticated user from JWT token"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    try:
        # Extract token from "Bearer <token>" format
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authentication scheme")

        payload = verify_jwt_token(token)
        return payload

    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid authorization header format")
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise HTTPException(status_code=401, detail="Could not validate credentials")
