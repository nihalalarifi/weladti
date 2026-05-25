from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from typing import List, Optional
from ..database import get_db
from ..models import User, HealthRecord, Prediction
from ..schemas.prediction import PredictionResponse
from ..ml.model import predict
from ..services.gemini_service import generate_medical_report
from .auth import get_current_user

router = APIRouter()


@router.post("/analyze", response_model=PredictionResponse)
async def analyze_health(
    health_record_id: Optional[int] = None,
    generate_report: bool = False,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Run AI analysis on the latest (or specified) health record."""

    if health_record_id:
        result = await db.execute(
            select(HealthRecord).where(
                HealthRecord.id == health_record_id,
                HealthRecord.user_id == current_user.id,
            )
        )
        record = result.scalar_one_or_none()
        if not record:
            raise HTTPException(status_code=404, detail="Health record not found")
    else:
        result = await db.execute(
            select(HealthRecord)
            .where(HealthRecord.user_id == current_user.id)
            .order_by(desc(HealthRecord.recorded_at))
            .limit(1)
        )
        record = result.scalar_one_or_none()
        if not record:
            raise HTTPException(status_code=404, detail="No health records found. Please add a reading first.")

    # Build feature dict for ML model
    features = {
        "systolic_bp": record.systolic_bp or 115.0,
        "diastolic_bp": record.diastolic_bp or 75.0,
        "heart_rate": record.heart_rate or 80.0,
        "weight_kg": record.weight_kg or current_user.pre_pregnancy_weight or 70.0,
        "pre_pregnancy_weight_kg": current_user.pre_pregnancy_weight or 65.0,
        "height_cm": current_user.height_cm or 163.0,
        "body_water_pct": record.body_water_pct or 55.0,
        "visceral_fat_level": record.visceral_fat_level or 3.0,
        "gestational_week": record.gestational_week or 28,
        "age": _calculate_age(current_user.date_of_birth),
        "has_proteinuria": record.has_proteinuria,
        "edema_level": record.edema_level,
        "has_edema": record.has_edema,
        "has_hypertension_history": current_user.has_hypertension_history,
        "had_preeclampsia_before": current_user.had_preeclampsia_before,
        "is_multiple_pregnancy": current_user.is_multiple_pregnancy,
        "has_diabetes_history": current_user.has_diabetes_history,
        "nulliparous": current_user.para == 0,
        "has_headache": record.has_headache,
        "has_visual_disturbances": record.has_visual_disturbances,
        "has_upper_abdominal_pain": record.has_upper_abdominal_pain,
    }

    prediction_result = predict(features)

    # Generate AI report if requested
    ai_report_ar = None
    ai_report_en = None
    if generate_report:
        user_profile_data = {
            "full_name": current_user.full_name,
            "gestational_week": features["gestational_week"],
            "systolic_bp": features["systolic_bp"],
            "diastolic_bp": features["diastolic_bp"],
            "weight_kg": features["weight_kg"],
        }
        ai_report_ar = await generate_medical_report(prediction_result, user_profile_data, "ar")

    prediction = Prediction(
        user_id=current_user.id,
        health_record_id=record.id,
        preeclampsia_risk_score=prediction_result["preeclampsia_risk_score"],
        preeclampsia_risk_level=prediction_result["preeclampsia_risk_level"],
        abnormal_weight_gain_risk=prediction_result["abnormal_weight_gain_risk"],
        fluid_retention_risk=prediction_result["fluid_retention_risk"],
        gestational_diabetes_risk=prediction_result["gestational_diabetes_risk"],
        alerts=prediction_result["alerts"],
        recommendations=prediction_result["recommendations"],
        ai_report_ar=ai_report_ar,
        confidence=prediction_result["confidence"],
    )
    db.add(prediction)
    await db.commit()
    await db.refresh(prediction)
    return prediction


@router.get("/history", response_model=List[PredictionResponse])
async def get_prediction_history(
    limit: int = 10,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Prediction)
        .where(Prediction.user_id == current_user.id)
        .order_by(desc(Prediction.created_at))
        .limit(limit)
    )
    return result.scalars().all()


@router.get("/latest", response_model=PredictionResponse)
async def get_latest_prediction(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Prediction)
        .where(Prediction.user_id == current_user.id)
        .order_by(desc(Prediction.created_at))
        .limit(1)
    )
    pred = result.scalar_one_or_none()
    if not pred:
        raise HTTPException(status_code=404, detail="No predictions yet")
    return pred


def _calculate_age(dob: Optional[str]) -> int:
    if not dob:
        return 28
    try:
        from datetime import date
        birth = date.fromisoformat(dob)
        today = date.today()
        return today.year - birth.year - ((today.month, today.day) < (birth.month, birth.day))
    except Exception:
        return 28


from typing import Optional
