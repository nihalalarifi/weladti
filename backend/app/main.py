"""
 ██╗    ██╗███████╗██╗      █████╗ ██████╗ ████████╗██╗
 ██║    ██║██╔════╝██║     ██╔══██╗██╔══██╗╚══██╔══╝██║
 ██║ █╗ ██║█████╗  ██║     ███████║██║  ██║   ██║   ██║
 ██║███╗██║██╔══╝  ██║     ██╔══██║██║  ██║   ██║   ██║
 ╚███╔███╔╝███████╗███████╗██║  ██║██████╔╝   ██║   ██║
  ╚══╝╚══╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝  ╚═╝

Weladti (ولادتي) — AI Pregnancy Health Platform
FastAPI Backend v1.0.0
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from .database import init_db
from .api import api_router
from .ml.model import get_model
from .config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🌸 Starting Weladti API...")
    await init_db()
    print("✅ Database initialized")
    get_model()  # Pre-load ML model
    print("🤖 AI model loaded")
    print(f"🚀 Weladti API ready on http://0.0.0.0:8000")
    yield
    # Shutdown
    print("👋 Weladti API shutting down...")


app = FastAPI(
    title="Weladti API — ولادتي",
    description="AI-powered pregnancy health monitoring platform",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS — allow Flutter app & local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount all API routes under /api/v1
app.include_router(api_router, prefix="/api/v1")


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "app": "Weladti",
        "version": "1.0.0",
        "message": "ولادتي — منصة صحة الحمل الذكية",
    }


@app.get("/")
async def root():
    return {
        "app": "Weladti — ولادتي",
        "description": "AI Pregnancy Health Platform",
        "docs": "/docs",
        "health": "/health",
        "api": "/api/v1",
    }
