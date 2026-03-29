from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, func
from app.database import Base


class Scan(Base):
    __tablename__ = "scans"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    url = Column(String(2000), nullable=False)
    result = Column(String(20), nullable=False)   # "safe" | "suspicious" | "scam"
    score = Column(Float, nullable=False, default=0.0)
    platform = Column(String(50), default="manual")  # whatsapp|instagram|telegram|sms|manual
    created_at = Column(DateTime(timezone=True), server_default=func.now())
