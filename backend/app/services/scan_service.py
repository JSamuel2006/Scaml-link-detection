from sqlalchemy.orm import Session
from app.models.scan import Scan
from app.ml.blacklist import is_blacklisted
from app.ml.model import predict_url


def scan_url(url: str, user_id: int, platform: str, db: Session) -> dict:
    """
    Hybrid detection:
      1. Blacklist check  → instant SCAM if matched
      2. RandomForest ML  → probabilistic score
    Returns scan result dict and persists to DB.
    """
    blacklisted = is_blacklisted(url)

    if blacklisted:
        score = 100.0
        result = "scam"
    else:
        score, _ = predict_url(url)
        if score > 70:
            result = "scam"
        elif score >= 40:
            result = "suspicious"
        else:
            result = "safe"

    scan = Scan(
        user_id=user_id,
        url=url,
        result=result,
        score=score,
        platform=platform,
    )
    db.add(scan)
    db.commit()
    db.refresh(scan)

    return {
        "url": url,
        "result": result,
        "score": score,
        "scan_id": scan.id,
        "blacklisted": blacklisted,
    }
