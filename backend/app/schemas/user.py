from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class ScanRequest(BaseModel):
    url: str
    platform: str = "manual"


class ScanResponse(BaseModel):
    url: str
    result: str
    score: float
    scan_id: int
    blacklisted: bool = False


class HistoryItem(BaseModel):
    id: int
    url: str
    result: str
    score: float
    platform: str
    created_at: datetime

    class Config:
        from_attributes = True


class ProfileResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    status: str
    created_at: datetime
    scan_count: int
    scam_count: int
    safe_count: int
