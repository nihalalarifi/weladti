from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from typing import List
from ..database import get_db
from ..models import User, HealthRecord
from ..schemas.health import HealthRecordCreate, HealthRecordResponse
from .auth import get_current_user

router = APIRouter()


@router.post("/records", response_model=HealthRecordResponse)
async def create_health_record(
    data: HealthRecordCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Calculate BMI if weight and height available
    bmi = None
    if data.weight_kg and current_user.height_cm:
        h = current_user.height_cm / 100
        bmi = round(data.weight_kg / (h * h), 1)

    record = HealthRecord(
        user_id=current_user.id,
        bmi=bmi,
        **data.model_dump(),
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)
    return record


@router.get("/records", response_model=List[HealthRecordResponse])
async def get_health_records(
    limit: int = 30,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(HealthRecord)
        .where(HealthRecord.user_id == current_user.id)
        .order_by(desc(HealthRecord.recorded_at))
        .limit(limit)
    )
    return result.scalars().all()


@router.get("/records/latest", response_model=HealthRecordResponse)
async def get_latest_record(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(HealthRecord)
        .where(HealthRecord.user_id == current_user.id)
        .order_by(desc(HealthRecord.recorded_at))
        .limit(1)
    )
    record = result.scalar_one_or_none()
    if not record:
        raise HTTPException(status_code=404, detail="No health records found")
    return record


@router.get("/dashboard")
async def get_dashboard_data(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Aggregated dashboard data — last 7 days trend."""
    result = await db.execute(
        select(HealthRecord)
        .where(HealthRecord.user_id == current_user.id)
        .order_by(desc(HealthRecord.recorded_at))
        .limit(14)
    )
    records = result.scalars().all()

    bp_trend = [
        {
            "date": r.recorded_at.strftime("%m/%d"),
            "systolic": r.systolic_bp,
            "diastolic": r.diastolic_bp,
        }
        for r in records
        if r.systolic_bp and r.diastolic_bp
    ][:7]

    weight_trend = [
        {
            "date": r.recorded_at.strftime("%m/%d"),
            "weight": r.weight_kg,
        }
        for r in records
        if r.weight_kg
    ][:7]

    latest = records[0] if records else None

    return {
        "bp_trend": list(reversed(bp_trend)),
        "weight_trend": list(reversed(weight_trend)),
        "latest_vitals": {
            "systolic_bp": latest.systolic_bp if latest else None,
            "diastolic_bp": latest.diastolic_bp if latest else None,
            "heart_rate": latest.heart_rate if latest else None,
            "weight_kg": latest.weight_kg if latest else None,
            "bmi": latest.bmi if latest else None,
            "body_water_pct": latest.body_water_pct if latest else None,
        } if latest else {},
        "total_records": len(records),
    }
