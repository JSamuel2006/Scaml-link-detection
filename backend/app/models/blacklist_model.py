from sqlalchemy import Column, Integer, String, DateTime, func
from app.database import Base


class BlacklistURL(Base):
    __tablename__ = "blacklist"

    id = Column(Integer, primary_key=True, index=True)
    url = Column(String(2000), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
