from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.user import User
from app.models.scan import Scan
from app.schemas.user import ScanRequest, ScanResponse, HistoryItem, ProfileResponse
from app.middleware.auth_middleware import get_current_user
from app.services.scan_service import scan_url as do_scan

router = APIRouter()


@router.post("/scan-url", response_model=ScanResponse)
def scan(
    data: ScanRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return do_scan(data.url, current_user.id, data.platform, db)


@router.get("/history", response_model=List[HistoryItem])
def get_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
):
    return (
        db.query(Scan)
        .filter(Scan.user_id == current_user.id)
        .order_by(Scan.created_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )


@router.get("/profile", response_model=ProfileResponse)
def get_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    total = db.query(Scan).filter(Scan.user_id == current_user.id).count()
    scams = db.query(Scan).filter(Scan.user_id == current_user.id, Scan.result == "scam").count()
    safe = db.query(Scan).filter(Scan.user_id == current_user.id, Scan.result == "safe").count()
    return {
        "id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "role": current_user.role,
        "status": current_user.status,
        "created_at": current_user.created_at,
        "scan_count": total,
        "scam_count": scams,
        "safe_count": safe,
    }
