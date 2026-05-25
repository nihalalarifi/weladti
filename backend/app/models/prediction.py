from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base


class Prediction(Base):
    __tablename__ = "predictions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    health_record_id = Column(Integer, ForeignKey("health_records.id"), nullable=True)

    # Preeclampsia Risk
    preeclampsia_risk_score = Column(Float, nullable=False)     # 0.0 - 1.0
    preeclampsia_risk_level = Column(String(20), nullable=False) # low/moderate/high/critical

    # Other Risk Indicators
    abnormal_weight_gain_risk = Column(Float, default=0.0)
    fluid_retention_risk = Column(Float, default=0.0)
    gestational_diabetes_risk = Column(Float, default=0.0)

    # Alerts
    alerts = Column(JSON, default=list)
    recommendations = Column(JSON, default=list)

    # AI Report (Gemini generated)
    ai_report_ar = Column(Text, nullable=True)
    ai_report_en = Column(Text, nullable=True)

    # Model info
    model_version = Column(String(20), default="1.0.0")
    confidence = Column(Float, default=0.0)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="predictions")
    health_record = relationship("HealthRecord", back_populates="prediction")
