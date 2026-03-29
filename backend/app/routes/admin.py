from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from typing import List
from app.database import get_db
from app.models.user import User
from app.models.scan import Scan
from app.middleware.auth_middleware import get_current_admin

router = APIRouter(prefix="/admin")


@router.get("/stats")
def get_stats(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    total_users = db.query(User).filter(User.role == "user").count()
    total_logins = db.query(func.sum(User.login_count)).scalar() or 0
    active_users = db.query(User).filter(User.role == "user", User.status == "active").count()
    total_scans = db.query(Scan).count()
    total_scams = db.query(Scan).filter(Scan.result == "scam").count()
    total_suspicious = db.query(Scan).filter(Scan.result == "suspicious").count()
    return {
        "total_users": total_users,
        "total_logins": int(total_logins),
        "active_users": active_users,
        "total_scans": total_scans,
        "total_scams": total_scams,
        "total_suspicious": total_suspicious,
    }


@router.get("/users")
def get_users(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    users = db.query(User).filter(User.role == "user").all()
    result = []
    for u in users:
        scan_count = db.query(Scan).filter(Scan.user_id == u.id).count()
        result.append({
            "id": u.id, "name": u.name, "email": u.email,
            "role": u.role, "status": u.status,
            "scan_count": scan_count, "created_at": u.created_at,
            "login_count": u.login_count,
        })
    return result


@router.get("/analytics")
def get_analytics(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    platforms = (
        db.query(Scan.platform, func.count(Scan.id).label("count"))
        .filter(Scan.result == "scam")
        .group_by(Scan.platform)
        .all()
    )
    platform_data = {p: c for p, c in platforms}

    daily_trend = []
    for i in range(6, -1, -1):
        date = (datetime.utcnow() - timedelta(days=i)).date()
        day_start = datetime(date.year, date.month, date.day)
        day_end = day_start + timedelta(days=1)
        total_day = db.query(Scan).filter(Scan.created_at >= day_start, Scan.created_at < day_end).count()
        scam_day = db.query(Scan).filter(
            Scan.created_at >= day_start, Scan.created_at < day_end, Scan.result == "scam"
        ).count()
        daily_trend.append({"date": date.isoformat(), "total": total_day, "scams": scam_day})

    return {"platform_distribution": platform_data, "daily_trend": daily_trend}


@router.get("/reports")
def get_reports(admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    recent_scams = (
        db.query(Scan)
        .filter(Scan.result == "scam")
        .order_by(Scan.created_at.desc())
        .limit(50)
        .all()
    )
    return [
        {"id": s.id, "url": s.url, "score": s.score, "platform": s.platform, "created_at": s.created_at, "user_id": s.user_id}
        for s in recent_scams
    ]


@router.patch("/block-user/{user_id}")
def toggle_block_user(user_id: int, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.role == "admin":
        raise HTTPException(status_code=403, detail="Cannot modify admin accounts")
    user.status = "blocked" if user.status == "active" else "active"
    db.commit()
    return {"message": f"User is now {user.status}", "status": user.status}


@router.delete("/delete-user/{user_id}")
def delete_user(user_id: int, admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.role == "admin":
        raise HTTPException(status_code=403, detail="Cannot delete admin accounts")
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}
