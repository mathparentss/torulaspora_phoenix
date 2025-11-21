"""
Configuration module for Expense Empire SaaS
Loads environment variables and provides app-wide settings
"""
import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings from environment variables"""

    # Database
    POSTGRES_HOST: str = "phoenix_postgres"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "phoenix_core"
    POSTGRES_USER: str = "phoenix"
    POSTGRES_PASSWORD: str

    # Redis
    REDIS_HOST: str = "phoenix_redis"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: str

    # JWT Authentication
    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRY_HOURS: int = 24

    # Ollama AI
    OLLAMA_HOST: str = "http://phoenix_ollama:11434"
    OLLAMA_PRIMARY_MODEL: str = "llava:34b"
    OLLAMA_FALLBACK_MODEL: str = "llava:13b"

    # File Storage
    UPLOAD_DIR: str = "/var/receipts_data"
    MAX_FILE_SIZE_MB: int = 10
    ALLOWED_EXTENSIONS: str = "png,jpg,jpeg,pdf"

    # Freemium Limits
    FREE_TIER_MONTHLY_LIMIT: int = 10
    FREE_TIER_TTL_DAYS: int = 7

    # System
    LOG_LEVEL: str = "INFO"

    @property
    def database_url(self) -> str:
        """PostgreSQL connection string"""
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    @property
    def allowed_extensions_list(self) -> list[str]:
        """Parse allowed extensions"""
        return self.ALLOWED_EXTENSIONS.split(',')

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
