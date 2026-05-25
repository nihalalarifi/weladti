"""
Gemini AI Service — Arabic medical report generation + health chatbot
"""

import google.generativeai as genai
from ..config import settings
from typing import Dict, Any, Optional

_configured = False


def _configure():
    global _configured
    if not _configured:
        genai.configure(api_key=settings.GEMINI_API_KEY)
        _configured = True


SYSTEM_PROMPT_AR = """أنتِ مساعدة صحية ذكية متخصصة في صحة الحوامل، اسمك "نور" من تطبيق ولادتي.
مهمتكِ تقديم معلومات طبية موثوقة وداعمة عاطفياً للأم الحامل.
التزمي دائماً بـ:
- الردود باللغة العربية الفصيحة البسيطة
- التعامل بلطف وتعاطف مع الأم
- التوضيح أنكِ لا تُعوضين الطبيب عند الأعراض الخطيرة
- تقديم نصائح عملية قائمة على الأدلة العلمية
- الإشارة للطبيب عند أي أعراض تسمم حمل (ضغط مرتفع، تورم، صداع، اضطرابات بصرية)
"""

SYSTEM_PROMPT_EN = """You are "Nour", a caring AI health assistant for pregnant women in the Weladti app.
Always:
- Be warm, empathetic, and supportive
- Provide evidence-based pregnancy health information
- Remind users that you complement, not replace, their doctor
- Urgently refer to emergency care for preeclampsia signs (high BP, swelling, headache, vision changes)
"""


async def generate_medical_report(
    prediction_data: Dict[str, Any],
    user_profile: Dict[str, Any],
    language: str = "ar",
) -> str:
    """Generate a personalized medical report using Gemini."""
    _configure()

    risk_level = prediction_data.get("preeclampsia_risk_level", "low")
    risk_score = prediction_data.get("preeclampsia_risk_score", 0)
    alerts = prediction_data.get("alerts", [])
    gestational_week = user_profile.get("gestational_week", "غير محدد")
    name = user_profile.get("full_name", "الأم")

    if language == "ar":
        prompt = f"""أنشئ تقريراً طبياً شاملاً وداعماً باللغة العربية للأم الحامل.

المعطيات:
- اسم الأم: {name}
- الأسبوع الحملي: {gestational_week}
- مستوى خطر تسمم الحمل: {risk_level} ({risk_score:.0%})
- ضغط الدم: {user_profile.get('systolic_bp', 'غير متاح')}/{user_profile.get('diastolic_bp', 'غير متاح')} mmHg
- الوزن الحالي: {user_profile.get('weight_kg', 'غير متاح')} كغ
- التنبيهات: {len(alerts)} تنبيه نشط

اكتبي تقريراً يتضمن:
1. ملخص الحالة الصحية
2. تفسير نتائج تسمم الحمل
3. الأعراض التي يجب الانتباه لها
4. توصيات عملية (3-5 نقاط)
5. متى يجب التواصل مع الطبيب
6. كلمة تشجيعية للأم

اجعل التقرير دافئاً وواضحاً ومفهوماً لغير المتخصصين."""
    else:
        prompt = f"""Generate a comprehensive, supportive medical report for a pregnant woman.

Data:
- Name: {name}
- Gestational week: {gestational_week}
- Preeclampsia risk: {risk_level} ({risk_score:.0%})
- Blood pressure: {user_profile.get('systolic_bp', 'N/A')}/{user_profile.get('diastolic_bp', 'N/A')} mmHg
- Current weight: {user_profile.get('weight_kg', 'N/A')} kg
- Active alerts: {len(alerts)}

Include: health summary, risk interpretation, warning signs, 3-5 recommendations, when to call doctor, encouraging closing note."""

    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return _fallback_report(risk_level, language)


async def chat_with_ai(
    message: str,
    conversation_history: list,
    language: str = "ar",
) -> str:
    """Health chatbot powered by Gemini."""
    _configure()

    system_prompt = SYSTEM_PROMPT_AR if language == "ar" else SYSTEM_PROMPT_EN

    history_text = ""
    for msg in conversation_history[-6:]:  # Last 6 messages for context
        role = "المستخدمة" if msg["role"] == "user" else "نور"
        history_text += f"{role}: {msg['content']}\n"

    full_prompt = f"{system_prompt}\n\nسياق المحادثة:\n{history_text}\nالمستخدمة: {message}\nnour:"

    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        response = model.generate_content(full_prompt)
        return response.text
    except Exception as e:
        if language == "ar":
            return "أعتذر، حدث خطأ في الاتصال. يُرجى المحاولة لاحقاً. إذا كانت لديك أعراض مقلقة، تواصلي مع طبيبك فوراً."
        return "Sorry, there was a connection error. Please try again. If you have concerning symptoms, contact your doctor immediately."


async def generate_weekly_insights(
    health_records: list,
    user_profile: Dict[str, Any],
) -> str:
    """Generate weekly pregnancy health insights."""
    _configure()

    gestational_week = user_profile.get("gestational_week", 28)
    name = user_profile.get("full_name", "الأم")
    recent_bp = health_records[-1].get("systolic_bp") if health_records else None

    prompt = f"""أنشئي ملخصاً أسبوعياً للصحة الحملية باللغة العربية:

الأسبوع الحملي: {gestational_week}
آخر قراءة ضغط: {recent_bp} mmHg
عدد القراءات هذا الأسبوع: {len(health_records)}

اكتبي:
1. ماذا يحدث في هذا الأسبوع من الحمل (نمو الجنين)
2. تحليل القراءات الصحية للأسبوع
3. 3 نصائح مهمة لهذا الأسبوع
4. ما يجب الاستعداد له الأسبوع القادم
اجعلي الأسلوب ودوداً ومشجعاً"""

    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        response = model.generate_content(prompt)
        return response.text
    except Exception:
        return f"أنتِ في الأسبوع {gestational_week} من الحمل. استمري في قياس ضغط الدم يومياً وحضور مواعيد متابعة الحمل. أنتِ تقومين بعمل رائع!"


def _fallback_report(risk_level: str, language: str) -> str:
    """Fallback when Gemini is unavailable."""
    if language == "ar":
        if risk_level == "low":
            return "تقرير صحتك: مستوى الخطر منخفض. استمري في متابعة الحمل بانتظام وقياس ضغط الدم يومياً."
        elif risk_level == "moderate":
            return "تقرير صحتك: هناك مؤشرات تستدعي الانتباه. يُنصح بزيارة طبيبك قريباً ومراقبة ضغط الدم بعناية."
        else:
            return "تقرير صحتك: المؤشرات تستدعي اهتماماً طبياً فورياً. تواصلي مع طبيبك اليوم."
    return f"Your health report: Risk level is {risk_level}. Please consult your healthcare provider."
