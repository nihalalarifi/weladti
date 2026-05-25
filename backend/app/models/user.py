from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    phone = Column(String(20), nullable=True)
    role = Column(String(20), default="patient")  # patient | doctor

    # Pregnancy Profile
    date_of_birth = Column(String(20), nullable=True)
    pregnancy_start_date = Column(String(20), nullable=True)
    due_date = Column(String(20), nullable=True)
    pre_pregnancy_weight = Column(Float, nullable=True)
    height_cm = Column(Float, nullable=True)
    blood_type = Column(String(5), nullable=True)
    gravida = Column(Integer, default=1)       # number of pregnancies
    para = Column(Integer, default=0)          # number of deliveries
    has_hypertension_history = Column(Boolean, default=False)
    had_preeclampsia_before = Column(Boolean, default=False)
    is_multiple_pregnancy = Column(Boolean, default=False)
    has_diabetes_history = Column(Boolean, default=False)
    doctor_name = Column(String(255), nullable=True)
    doctor_id = Column(Integer, nullable=True)

    # Meta
    profile_complete = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    health_records = relationship("HealthRecord", back_populates="user", cascade="all, delete")
    predictions = relationship("Prediction", back_populates="user", cascade="all, delete")
    chat_messages = relationship("ChatMessage", back_populates="user", cascade="all, delete")
