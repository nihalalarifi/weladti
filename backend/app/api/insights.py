from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from ..database import get_db
from ..models import User, HealthRecord, ChatMessage
from ..schemas.prediction import ChatRequest, ChatResponse
from ..services.gemini_service import chat_with_ai, generate_weekly_insights
from .auth import get_current_user

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Load conversation history
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.user_id == current_user.id)
        .order_by(desc(ChatMessage.created_at))
        .limit(6)
    )
    history = [
        {"role": m.role, "content": m.content}
        for m in reversed(result.scalars().all())
    ]

    reply = await chat_with_ai(request.message, history, request.language)

    # Save messages
    user_msg = ChatMessage(user_id=current_user.id, role="user", content=request.message)
    ai_msg = ChatMessage(user_id=current_user.id, role="assistant", content=reply, is_medical_advice=True)
    db.add(user_msg)
    db.add(ai_msg)
    await db.commit()

    return ChatResponse(reply=reply, is_medical_advice=True)


@router.get("/weekly-summary")
async def weekly_summary(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(HealthRecord)
        .where(HealthRecord.user_id == current_user.id)
        .order_by(desc(HealthRecord.recorded_at))
        .limit(7)
    )
    records = [
        {"systolic_bp": r.systolic_bp, "weight_kg": r.weight_kg, "recorded_at": str(r.recorded_at)}
        for r in result.scalars().all()
    ]

    user_profile = {
        "full_name": current_user.full_name,
        "gestational_week": records[0].get("gestational_week", 28) if records else 28,
    }

    summary = await generate_weekly_insights(records, user_profile)
    return {"summary": summary, "records_analyzed": len(records)}
