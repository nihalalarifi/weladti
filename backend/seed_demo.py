"""
Weladti — Demo Data Seeder
Resets the database and creates a complete demo account with realistic data.
Run: python seed_demo.py
"""

import asyncio
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from datetime import datetime, timedelta
import random

async def seed():
    from app.database import engine, Base, AsyncSessionLocal
    from app.models import User, HealthRecord, Prediction, ChatMessage
    import bcrypt
    def hash_password(pw): return bcrypt.hashpw(pw.encode(), bcrypt.gensalt()).decode()

    print("🗑️  Dropping and recreating tables...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    print("✅ Tables ready")

    async with AsyncSessionLocal() as db:
        # ── Demo User ─────────────────────────────────────────────────────
        user = User(
            email="demo@weladti.com",
            full_name="سارة الأحمدي",
            hashed_password=hash_password("demo123456"),
            phone="+966501234567",
            role="patient",
            date_of_birth="1995-03-15",
            pregnancy_start_date="2025-09-01",
            due_date="2026-06-08",
            pre_pregnancy_weight=62.0,
            height_cm=162.0,
            blood_type="A+",
            gravida=2,
            para=1,
            has_hypertension_history=False,
            had_preeclampsia_before=False,
            is_multiple_pregnancy=False,
            has_diabetes_history=False,
            doctor_name="د. منى الزهراني",
            profile_complete=True,
        )
        db.add(user)
        await db.flush()  # get user.id

        # ── Health Records (last 14 days) ─────────────────────────────────
        base_date = datetime.utcnow() - timedelta(days=13)
        records = []

        # Simulate a gradual BP rise (clinical realism)
        bp_data = [
            (112, 72), (114, 74), (116, 75), (118, 76),
            (120, 78), (122, 80), (128, 82), (130, 84),
            (134, 86), (138, 88), (142, 91), (145, 92),
            (148, 94), (150, 96),
        ]

        for i, (sys_bp, dia_bp) in enumerate(bp_data):
            gestational_week = 28 + (i // 7)
            weight = 73.5 + i * 0.15 + random.uniform(-0.1, 0.2)
            bmi = round(weight / (1.62 ** 2), 1)

            r = HealthRecord(
                user_id=user.id,
                systolic_bp=float(sys_bp + random.randint(-2, 2)),
                diastolic_bp=float(dia_bp + random.randint(-2, 2)),
                heart_rate=float(random.randint(78, 92)),
                temperature=36.6 + random.uniform(-0.2, 0.3),
                oxygen_saturation=float(random.randint(97, 99)),
                weight_kg=round(weight, 1),
                bmi=bmi,
                body_fat_pct=round(28.5 + i * 0.05, 1),
                muscle_mass_kg=round(23.8 + random.uniform(-0.1, 0.1), 1),
                body_water_pct=round(56.0 + i * 0.3 + random.uniform(-0.5, 0.5), 1),
                visceral_fat_level=round(3.2 + random.uniform(-0.2, 0.2), 1),
                bone_mass_kg=2.8,
                vascular_age=28 + (1 if i > 10 else 0),
                gestational_week=gestational_week,
                fetal_movement_count=random.randint(8, 15),
                has_headache=(i >= 11),
                has_visual_disturbances=(i >= 12),
                has_upper_abdominal_pain=False,
                has_edema=(i >= 10),
                edema_level=(1 if i >= 10 else 0),
                has_proteinuria=(i >= 12),
                urine_protein_level=("1+" if i >= 12 else None),
                data_source=("smart_scale" if i % 3 == 0 else "manual"),
                notes=_notes(i),
                recorded_at=base_date + timedelta(days=i, hours=random.randint(7, 9)),
            )
            db.add(r)
            records.append(r)

        await db.flush()

        # ── AI Predictions (last 3 days) ──────────────────────────────────
        risk_progression = [
            ("moderate", 0.32, "يُنصح بمراقبة ضغط الدم بعناية"),
            ("high",     0.61, "يجب مراجعة الطبيب خلال 24 ساعة"),
            ("high",     0.68, "توجد أعراض تستدعي الاهتمام الطبي"),
        ]

        for idx, (level, score, note) in enumerate(risk_progression):
            rec = records[-(3 - idx)]
            pred = Prediction(
                user_id=user.id,
                health_record_id=rec.id,
                preeclampsia_risk_score=score,
                preeclampsia_risk_level=level,
                abnormal_weight_gain_risk=0.35 + idx * 0.05,
                fluid_retention_risk=0.42 + idx * 0.08,
                gestational_diabetes_risk=0.12,
                alerts=_alerts(level, score),
                recommendations=[
                    "قيسي ضغط الدم مرتين يومياً في نفس الوقت",
                    "راقبي التورم في الوجه والأطراف",
                    "تجنّبي الملح والأطعمة المصنّعة",
                    "اتصلي بطبيبك إذا تجاوز الضغط 140/90",
                    "التزمي بالراحة التامة وتجنّبي المجهود",
                ],
                ai_report_ar=_sample_report(level, score),
                model_version="1.0.0",
                confidence=0.82 + idx * 0.02,
                created_at=base_date + timedelta(days=11 + idx),
            )
            db.add(pred)

        # ── Chat Messages ─────────────────────────────────────────────────
        chats = [
            ("user",      "ما هي أعراض تسمم الحمل التي يجب أن أنتبه لها؟"),
            ("assistant", "أعراض تسمم الحمل الرئيسية تشمل: ارتفاع ضغط الدم فوق 140/90، تورم مفاجئ في الوجه والأيدي والقدمين، صداع شديد لا يستجيب للمسكنات، اضطرابات في الرؤية كالرؤية الضبابية أو رؤية بقع، وألم في الجزء العلوي من البطن. إذا لاحظتِ أياً من هذه الأعراض يجب التواصل مع طبيبك فوراً. 💗"),
            ("user",      "ضغط دمي اليوم كان 145/93، هل هذا خطير؟"),
            ("assistant", "قراءة 145/93 تُعدّ مرتفعة وتحتاج انتباهاً طبياً. هذا المستوى يقع في نطاق 'ارتفاع ضغط الدم الحملي'. أنصحكِ بـ:\n1. إعادة القياس بعد 15 دقيقة في وضع الجلوس\n2. الاسترخاء التام وتجنّب الإجهاد\n3. التواصل مع طبيبتك اليوم لإخبارها بالقراءة\n4. الذهاب للطوارئ فوراً إذا تجاوز 160/110\nأنتِ تتصرفين بشكل صحيح بمراقبة ضغطكِ يومياً! 🌸"),
            ("user",      "كيف أقلل التورم في قدميّ؟"),
            ("assistant", "لتقليل تورم القدمين خلال الحمل:\n• ارفعي قدميكِ فوق مستوى القلب عند الجلوس أو الاستلقاء\n• تجنّبي الوقوف لفترات طويلة\n• قللي تناول الملح\n• اشربي 8-10 أكواب ماء يومياً\n• المشي الخفيف يساعد الدورة الدموية\n• ارتدي جوارب ضاغطة طبية\nإذا كان التورم مفاجئاً أو في الوجه، تواصلي مع طبيبتك فوراً. 💙"),
        ]

        base_chat = datetime.utcnow() - timedelta(days=3)
        for i, (role, content) in enumerate(chats):
            db.add(ChatMessage(
                user_id=user.id,
                role=role,
                content=content,
                is_medical_advice=(role == "assistant"),
                created_at=base_chat + timedelta(hours=i * 2),
            ))

        await db.commit()

    print("\n" + "="*50)
    print("✅  Demo account created successfully!")
    print("="*50)
    print(f"  📧 Email:    demo@weladti.com")
    print(f"  🔑 Password: demo123456")
    print(f"  👤 Name:     سارة الأحمدي")
    print(f"  🤰 Week:     الأسبوع 30 من الحمل")
    print(f"  📊 Records:  14 health records")
    print(f"  🤖 Risk:     High — للعرض التوضيحي")
    print("="*50 + "\n")


def _notes(i):
    notes = [
        None, "شعرت بتعب خفيف صباحاً", None,
        "استيقظت مبكراً، قياس قبل الإفطار", None, None,
        "بعد يوم عمل طويل", None, "قياس مسائي",
        "لاحظت انتفاخاً خفيفاً في الكاحلين",
        "تورم ملحوظ في القدمين والكاحلين",
        "صداع خفيف في الصباح",
        "استمر الصداع، ذهبت للطبيبة",
        "بعد راحة تامة — الضغط لا يزال مرتفعاً",
    ]
    return notes[i]


def _alerts(level, score):
    alerts = []
    if score >= 0.6:
        alerts.append({
            "severity": "high",
            "icon": "⚠️",
            "title_ar": "ارتفاع ضغط الدم",
            "title_en": "High Blood Pressure",
            "message_ar": "ضغط الدم مرتفع — يُنصح بمراجعة طبيبك",
            "message_en": "Blood pressure elevated — consult your doctor",
        })
    alerts.append({
        "severity": "moderate",
        "icon": "💧",
        "title_ar": "احتباس سوائل",
        "title_en": "Fluid Retention",
        "message_ar": "نسبة الماء في الجسم مرتفعة — راقبي التورم",
        "message_en": "Elevated body water — monitor swelling",
    })
    return alerts


def _sample_report(level, score):
    return f"""تقرير صحة الحمل — سارة الأحمدي
الأسبوع الحملي: 30

📊 ملخص الحالة:
بناءً على القراءات الأخيرة، يُشير التحليل الذكي إلى مستوى خطر {"مرتفع" if level == "high" else "متوسط"} لتسمم الحمل بنسبة {score:.0%}.

🩺 النتائج الرئيسية:
• ضغط الدم: يُظهر ارتفاعاً تدريجياً خلال الأسبوعين الماضيين
• نسبة الماء في الجسم: مرتفعة قليلاً مع وجود تورم ملحوظ
• الوزن: زيادة أعلى من المعدل المتوقع لهذه المرحلة

⚠️ الأعراض المسجّلة:
صداع متكرر، تورم في الأطراف، بروتين في البول

📋 التوصيات:
1. مراجعة الطبيبة في أقرب وقت ممكن
2. قياس ضغط الدم كل 6 ساعات وتسجيله
3. الراحة التامة وتجنب الإجهاد البدني والنفسي
4. التوجه للطوارئ فوراً إذا تجاوز الضغط 160/110

💝 كلمة دعم:
أنتِ تقومين بعمل رائع بمراقبة صحتك بانتظام. هذا الاهتمام المبكر هو أهم خطوة لحماية صحتكِ وصحة طفلكِ."""


if __name__ == "__main__":
    asyncio.run(seed())
