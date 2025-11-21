"""
Expense Empire SaaS v1 — FastAPI Main Application
Phoenix Battlestack Revenue Spore #1
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging

from config import settings
from api import auth, receipts, categories, export
from middleware.audit_log import audit_middleware

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Expense Empire",
    description="AI-powered receipt processing for Canadian business owners",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware (localhost only in Phase 1)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://127.0.0.1"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Audit logging middleware
@app.middleware("http")
async def audit_log_middleware(request: Request, call_next):
    return await audit_middleware(request, call_next)

# Include routers
app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(receipts.router, prefix="/api/receipts", tags=["Receipts"])
app.include_router(categories.router, prefix="/api/categories", tags=["Categories"])
app.include_router(export.router, prefix="/api/export", tags=["Export"])

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for Docker healthcheck"""
    return {"status": "healthy", "service": "expense_empire"}

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Expense Empire",
        "version": "1.0.0",
        "status": "operational",
        "docs": "/docs"
    }

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error. Please try again later."}
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level=settings.LOG_LEVEL.lower())
