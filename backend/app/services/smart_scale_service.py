"""
Smart Scale Integration Service
=================================
Simulates Withings Body Scan device data streaming.
Architecture: replace simulate_reading() with real BLE/API call when hardware is available.

Hardware integration points:
  - Withings Health API: https://developer.withings.com/api-reference
  - Bluetooth LE: Use `bleak` library for direct BLE connection
  - Replace SIMULATED_DEVICE with real device MAC address / API token
"""

import random
import math
from typing import Dict, Any
from datetime import datetime


# ── Device Configuration ──────────────────────────────────────────────────────
DEVICE_CONFIG = {
    "device_model": "Withings Body Scan",
    "connection_type": "simulated",  # "simulated" | "bluetooth" | "withings_api"
    "device_mac": "00:00:00:00:00:00",  # Replace with actual MAC
    "withings_api_token": "YOUR_WITHINGS_TOKEN",  # Replace with actual token
}


def simulate_smart_scale_reading(
    user_weight_kg: float = 72.0,
    gestational_week: int = 28,
    seed: int = None,
) -> Dict[str, Any]:
    """
    Simulate a complete Withings Body Scan reading.

    In production, replace this with:
    1. BLE connection: await BLEScaleClient(DEVICE_CONFIG['device_mac']).read()
    2. Withings API: await WithingsAPIClient(token).get_latest_measurement()
    """
    if seed:
        random.seed(seed)

    # Pregnancy-adjusted body composition
    # Body water increases during pregnancy (normal: 60-65% in 3rd trimester)
    pregnancy_water_factor = 1 + (gestational_week / 40) * 0.08
    body_water_pct = round(random.gauss(58 * pregnancy_water_factor, 2), 1)
    body_water_pct = max(50.0, min(72.0, body_water_pct))

    # Body fat decreases as baby grows (relative %)
    body_fat_pct = round(random.gauss(28 - gestational_week * 0.1, 2), 1)
    body_fat_pct = max(15.0, min(45.0, body_fat_pct))

    fat_mass_kg = round(user_weight_kg * body_fat_pct / 100, 1)
    muscle_mass_kg = round(user_weight_kg * 0.35 + random.gauss(0, 0.5), 1)
    bone_mass_kg = round(user_weight_kg * 0.04 + random.gauss(0, 0.1), 2)

    # Heart rate during pregnancy (normal: 70-100 bpm, increases ~15-20 bpm)
    heart_rate = round(random.gauss(82 + gestational_week * 0.3, 5))
    heart_rate = max(60, min(110, heart_rate))

    # Visceral fat (stays relatively stable during healthy pregnancy)
    visceral_fat = round(random.gauss(3.5, 0.5), 1)
    visceral_fat = max(1.0, min(9.0, visceral_fat))

    # Vascular age (Withings Body Scan measures arterial stiffness)
    vascular_age = random.randint(25, 38)

    # Pulse Wave Velocity (normal: < 9 m/s; elevated in preeclampsia)
    # Slightly elevated in pregnancy
    pwv = round(random.gauss(7.2 + gestational_week * 0.02, 0.5), 1)
    pwv = max(5.0, min(12.0, pwv))

    # Segmental body composition
    return {
        "device": DEVICE_CONFIG["device_model"],
        "connection_type": DEVICE_CONFIG["connection_type"],
        "timestamp": datetime.utcnow().isoformat(),
        "measurements": {
            "weight_kg": round(user_weight_kg + random.gauss(0, 0.1), 1),
            "body_fat_pct": body_fat_pct,
            "fat_mass_kg": fat_mass_kg,
            "muscle_mass_kg": muscle_mass_kg,
            "bone_mass_kg": bone_mass_kg,
            "body_water_pct": body_water_pct,
            "visceral_fat_level": visceral_fat,
            "heart_rate": heart_rate,
            "vascular_age": vascular_age,
            "pulse_wave_velocity": pwv,
            "segmental": {
                "trunk_fat_pct": round(body_fat_pct * 1.1, 1),
                "left_arm_fat_pct": round(body_fat_pct * 0.9, 1),
                "right_arm_fat_pct": round(body_fat_pct * 0.9, 1),
                "left_leg_fat_pct": round(body_fat_pct * 1.05, 1),
                "right_leg_fat_pct": round(body_fat_pct * 1.05, 1),
            },
        },
        "quality_score": random.randint(85, 99),
        "measurement_duration_seconds": random.randint(45, 90),
    }


def get_device_status() -> Dict[str, Any]:
    """Returns simulated device connection status."""
    return {
        "device": DEVICE_CONFIG["device_model"],
        "connected": True,
        "battery_pct": random.randint(60, 100),
        "firmware_version": "2.1.4",
        "last_sync": datetime.utcnow().isoformat(),
        "connection_type": DEVICE_CONFIG["connection_type"],
        "note": "Simulated device — replace with real BLE/API connection",
    }
