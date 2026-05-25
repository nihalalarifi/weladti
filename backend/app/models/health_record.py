from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base


class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # Vital Signs
    systolic_bp = Column(Float, nullable=True)     # mmHg
    diastolic_bp = Column(Float, nullable=True)    # mmHg
    heart_rate = Column(Float, nullable=True)      # bpm
    temperature = Column(Float, nullable=True)     # Celsius
    oxygen_saturation = Column(Float, nullable=True)  # %

    # Smart Scale Data (Withings Body Scan)
    weight_kg = Column(Float, nullable=True)
    bmi = Column(Float, nullable=True)
    body_fat_pct = Column(Float, nullable=True)
    muscle_mass_kg = Column(Float, nullable=True)
    body_water_pct = Column(Float, nullable=True)
    visceral_fat_level = Column(Float, nullable=True)
    bone_mass_kg = Column(Float, nullable=True)
    vascular_age = Column(Integer, nullable=True)
    pulse_wave_velocity = Column(Float, nullable=True)  # m/s (arterial stiffness)

    # Segmental Body Composition
    trunk_fat_pct = Column(Float, nullable=True)
    left_arm_fat_pct = Column(Float, nullable=True)
    right_arm_fat_pct = Column(Float, nullable=True)
    left_leg_fat_pct = Column(Float, nullable=True)
    right_leg_fat_pct = Column(Float, nullable=True)

    # Pregnancy Specific
    gestational_week = Column(Integer, nullable=True)
    fetal_movement_count = Column(Integer, nullable=True)
    has_headache = Column(Boolean, default=False)
    has_visual_disturbances = Column(Boolean, default=False)
    has_upper_abdominal_pain = Column(Boolean, default=False)
    has_edema = Column(Boolean, default=False)
    edema_level = Column(Integer, default=0)  # 0-3
    has_proteinuria = Column(Boolean, default=False)
    urine_protein_level = Column(String(20), nullable=True)  # trace/1+/2+/3+

    # Source
    data_source = Column(String(50), default="manual")  # manual | smart_scale | device
    notes = Column(Text, nullable=True)

    recorded_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="health_records")
    prediction = relationship("Prediction", back_populates="health_record", uselist=False)
