from fastapi import APIRouter, Depends
from ..models import User
from ..services.smart_scale_service import simulate_smart_scale_reading, get_device_status
from .auth import get_current_user

router = APIRouter()


@router.get("/status")
async def device_status(current_user: User = Depends(get_current_user)):
    return get_device_status()


@router.post("/measure")
async def take_measurement(
    current_user: User = Depends(get_current_user),
):
    """Simulate taking a smart scale measurement."""
    weight = current_user.pre_pregnancy_weight or 70.0
    # Add estimated pregnancy weight gain
    from sqlalchemy.ext.asyncio import AsyncSession
    gestational_week = 28  # default; ideally fetch from latest health record

    return simulate_smart_scale_reading(
        user_weight_kg=weight + gestational_week * 0.4,
        gestational_week=gestational_week,
    )
