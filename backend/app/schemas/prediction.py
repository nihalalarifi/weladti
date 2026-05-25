from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime


class PredictionResponse(BaseModel):
    id: int
    user_id: int
    health_record_id: Optional[int] = None
    preeclampsia_risk_score: float
    preeclampsia_risk_level: str
    abnormal_weight_gain_risk: float
    fluid_retention_risk: float
    gestational_diabetes_risk: float
    alerts: List[Dict[str, Any]]
    recommendations: List[str]
    ai_report_ar: Optional[str] = None
    ai_report_en: Optional[str] = None
    model_version: str
    confidence: float
    created_at: datetime

    class Config:
        from_attributes = True


class ChatRequest(BaseModel):
    message: str
    language: str = "ar"  # ar | en


class ChatResponse(BaseModel):
    reply: str
    is_medical_advice: bool = False
