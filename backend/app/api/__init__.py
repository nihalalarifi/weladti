from fastapi import APIRouter
from .auth import router as auth_router
from .health import router as health_router
from .predictions import router as predictions_router
from .smart_scale import router as scale_router
from .insights import router as insights_router

api_router = APIRouter()
api_router.include_router(auth_router, prefix="/auth", tags=["Authentication"])
api_router.include_router(health_router, prefix="/health", tags=["Health Records"])
api_router.include_router(predictions_router, prefix="/predictions", tags=["AI Predictions"])
api_router.include_router(scale_router, prefix="/scale", tags=["Smart Scale"])
api_router.include_router(insights_router, prefix="/insights", tags=["AI Insights"])
