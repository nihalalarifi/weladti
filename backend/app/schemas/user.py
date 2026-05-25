from pydantic import BaseModel, EmailStr
from typing import Optional


class UserProfile(BaseModel):
    id: int
    email: str
    full_name: str
    phone: Optional[str] = None
    role: str
    date_of_birth: Optional[str] = None
    pregnancy_start_date: Optional[str] = None
    due_date: Optional[str] = None
    pre_pregnancy_weight: Optional[float] = None
    height_cm: Optional[float] = None
    blood_type: Optional[str] = None
    gravida: int = 1
    para: int = 0
    has_hypertension_history: bool = False
    had_preeclampsia_before: bool = False
    is_multiple_pregnancy: bool = False
    has_diabetes_history: bool = False
    doctor_name: Optional[str] = None
    profile_complete: bool = False

    class Config:
        from_attributes = True


class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    pregnancy_start_date: Optional[str] = None
    due_date: Optional[str] = None
    pre_pregnancy_weight: Optional[float] = None
    height_cm: Optional[float] = None
    blood_type: Optional[str] = None
    gravida: Optional[int] = None
    para: Optional[int] = None
    has_hypertension_history: Optional[bool] = None
    had_preeclampsia_before: Optional[bool] = None
    is_multiple_pregnancy: Optional[bool] = None
    has_diabetes_history: Optional[bool] = None
    doctor_name: Optional[str] = None
