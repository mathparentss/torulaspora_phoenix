"""
Authentication API Endpoints
User registration, login, and JWT token management
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
import psycopg2
import bcrypt
import logging

from config import settings
from middleware.jwt_auth import create_jwt_token, get_current_user

logger = logging.getLogger(__name__)
router = APIRouter()


class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str | None = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user_id: str
    email: str


def get_db():
    """Get database connection"""
    return psycopg2.connect(settings.database_url)


@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(user: UserRegister):
    """
    Register a new user

    - Creates user account with bcrypt password hashing (cost factor 12)
    - Returns JWT token for immediate authentication
    - Initializes neurotransmitter gamification record
    """
    conn = get_db()
    cur = conn.cursor()

    try:
        # Hash password with bcrypt (cost factor 12)
        salt = bcrypt.gensalt(rounds=12)
        password_hash = bcrypt.hashpw(user.password.encode(), salt).decode()

        # Insert user
        cur.execute("""
            INSERT INTO receipts.users (email, password_hash, full_name)
            VALUES (%s, %s, %s)
            RETURNING user_id, email, subscription_tier
        """, (user.email, password_hash, user.full_name))

        result = cur.fetchone()
        if not result:
            raise HTTPException(status_code=500, detail="User creation failed")

        user_id, email, tier = result
        conn.commit()

        # Create JWT token
        token = create_jwt_token(str(user_id), email, tier)

        logger.info(f"New user registered: {email}")

        return TokenResponse(
            access_token=token,
            expires_in=settings.JWT_EXPIRY_HOURS * 3600,  # Convert to seconds
            user_id=str(user_id),
            email=email
        )

    except psycopg2.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="Email already registered")
    except Exception as e:
        conn.rollback()
        logger.error(f"Registration error: {e}")
        raise HTTPException(status_code=500, detail="Registration failed")
    finally:
        cur.close()
        conn.close()


@router.post("/login", response_model=TokenResponse)
async def login(credentials: UserLogin):
    """
    Login existing user

    - Validates credentials with bcrypt
    - Returns JWT token with 24h expiry
    - Updates last_login_at timestamp
    """
    conn = get_db()
    cur = conn.cursor()

    try:
        # Get user by email
        cur.execute("""
            SELECT user_id, email, password_hash, subscription_tier
            FROM receipts.users
            WHERE email = %s AND is_deleted = FALSE
        """, (credentials.email,))

        result = cur.fetchone()
        if not result:
            raise HTTPException(status_code=401, detail="Invalid email or password")

        user_id, email, password_hash, tier = result

        # Verify password
        if not bcrypt.checkpw(credentials.password.encode(), password_hash.encode()):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Update last_login_at
        cur.execute("""
            UPDATE receipts.users
            SET last_login_at = NOW(), updated_at = NOW()
            WHERE user_id = %s
        """, (user_id,))
        conn.commit()

        # Create JWT token
        token = create_jwt_token(str(user_id), email, tier)

        logger.info(f"User logged in: {email}")

        return TokenResponse(
            access_token=token,
            expires_in=settings.JWT_EXPIRY_HOURS * 3600,
            user_id=str(user_id),
            email=email
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error: {e}")
        raise HTTPException(status_code=500, detail="Login failed")
    finally:
        cur.close()
        conn.close()


@router.get("/me")
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """
    Get current authenticated user information

    Requires: Valid JWT token in Authorization header
    """
    conn = get_db()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT
                u.user_id,
                u.email,
                u.full_name,
                u.subscription_tier,
                u.monthly_receipt_limit,
                u.receipts_uploaded_this_month,
                u.created_at,
                n.current_streak_days,
                n.total_receipts_processed,
                n.achievement_badges
            FROM receipts.users u
            LEFT JOIN receipts.user_neurotransmitters n ON u.user_id = n.user_id
            WHERE u.user_id = %s AND u.is_deleted = FALSE
        """, (current_user["sub"],))

        result = cur.fetchone()
        if not result:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "user_id": str(result[0]),
            "email": result[1],
            "full_name": result[2],
            "subscription_tier": result[3],
            "monthly_receipt_limit": result[4],
            "receipts_uploaded_this_month": result[5],
            "created_at": result[6].isoformat(),
            "streak_days": result[7] or 0,
            "total_receipts": result[8] or 0,
            "badges": result[9] or []
        }

    finally:
        cur.close()
        conn.close()
