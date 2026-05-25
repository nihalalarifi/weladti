from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class HealthRecordCreate(BaseModel):
    # Vital Signs
    systolic_bp: Optional[float] = None
    diastolic_bp: Optional[float] = None
    heart_rate: Optional[float] = None
    temperature: Optional[float] = None
    oxygen_saturation: Optional[float] = None

    # Smart Scale Data
    weight_kg: Optional[float] = None
    body_fat_pct: Optional[float] = None
    muscle_mass_kg: Optional[float] = None
    body_water_pct: Optional[float] = None
    visceral_fat_level: Optional[float] = None
    bone_mass_kg: Optional[float] = None
    vascular_age: Optional[int] = None
    pulse_wave_velocity: Optional[float] = None

    # Segmental
    trunk_fat_pct: Optional[float] = None
    left_arm_fat_pct: Optional[float] = None
    right_arm_fat_pct: Optional[float] = None
    left_leg_fat_pct: Optional[float] = None
    right_leg_fat_pct: Optional[float] = None

    # Symptoms
    gestational_week: Optional[int] = None
    fetal_movement_count: Optional[int] = None
    has_headache: bool = False
    has_visual_disturbances: bool = False
    has_upper_abdominal_pain: bool = False
    has_edema: bool = False
    edema_level: int = 0
    has_proteinuria: bool = False
    urine_protein_level: Optional[str] = None

    data_source: str = "manual"
    notes: Optional[str] = None


class HealthRecordResponse(BaseModel):
    id: int
    user_id: int
    systolic_bp: Optional[float] = None
    diastolic_bp: Optional[float] = None
    heart_rate: Optional[float] = None
    temperature: Optional[float] = None
    oxygen_saturation: Optional[float] = None
    weight_kg: Optional[float] = None
    bmi: Optional[float] = None
    body_fat_pct: Optional[float] = None
    muscle_mass_kg: Optional[float] = None
    body_water_pct: Optional[float] = None
    visceral_fat_level: Optional[float] = None
    vascular_age: Optional[int] = None
    gestational_week: Optional[int] = None
    has_headache: bool = False
    has_visual_disturbances: bool = False
    has_upper_abdominal_pain: bool = False
    has_edema: bool = False
    edema_level: int = 0
    has_proteinuria: bool = False
    data_source: str = "manual"
    notes: Optional[str] = None
    recorded_at: datetime

    class Config:
        from_attributes = True
