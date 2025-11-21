"""
Rate Limiting Middleware
Enforces 100 requests/minute per user per endpoint using Redis
"""
from fastapi import HTTPException
import redis
import logging

from config import settings

logger = logging.getLogger(__name__)

# Redis client
redis_client = redis.Redis(
    host=settings.REDIS_HOST,
    port=settings.REDIS_PORT,
    password=settings.REDIS_PASSWORD,
    decode_responses=True
)


async def rate_limit_check(user_id: str, endpoint: str, limit: int = 100):
    """
    Check if user has exceeded rate limit for this endpoint

    Args:
        user_id: User ID from JWT token
        endpoint: API endpoint path
        limit: Max requests per minute (default 100)

    Raises:
        HTTPException: If rate limit exceeded
    """
    key = f"rate_limit:{user_id}:{endpoint}"

    try:
        current_count = redis_client.get(key)

        if current_count and int(current_count) >= limit:
            raise HTTPException(
                status_code=429,
                detail=f"Rate limit exceeded. Maximum {limit} requests per minute. Try again in 60 seconds."
            )

        # Increment counter with 60-second TTL
        pipe = redis_client.pipeline()
        pipe.incr(key)
        pipe.expire(key, 60)
        pipe.execute()

    except redis.RedisError as e:
        logger.error(f"Redis error in rate limiting: {e}")
        # Don't block request if Redis is down
        pass
