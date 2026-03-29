import pickle
import os
from app.ml.features import extract_features

_BASE = os.path.dirname(__file__)
MODEL_PATH = os.path.abspath(os.path.join(_BASE, "..", "..", "ml_models", "rf_model.pkl"))

_model = None


def load_model() -> None:
    global _model
    try:
        with open(MODEL_PATH, "rb") as f:
            _model = pickle.load(f)
        print(f"✅ ML model loaded from {MODEL_PATH}")
    except FileNotFoundError:
        print(f"⚠️  Model not found at {MODEL_PATH}. Run train_model.py first.")
        _model = None
    except Exception as e:
        print(f"⚠️  Error loading model: {e}")
        _model = None


def _heuristic_score(url: str) -> float:
    """Fallback scoring when model is unavailable."""
    features = extract_features(url)
    # keyword_count, has_ip, has_suspicious_tld, is_https carry heavy weight
    score = (
        features[7] * 12 +   # keyword_count
        features[6] * 40 +   # has_ip
        features[13] * 30 +  # has_suspicious_tld
        (1 - features[5]) * 15 +  # not https
        features[2] * 20 +   # has_at
        features[3] * 5      # has_dash
    )
    return min(100.0, round(score, 2))


def predict_url(url: str) -> tuple[float, int]:
    """
    Returns (risk_score_percent, label)
    label: 1 = scam, 0 = safe
    """
    global _model
    if _model is None:
        load_model()

    if _model is None:
        score = _heuristic_score(url)
        label = 1 if score > 70 else 0
        return score, label

    features = extract_features(url)
    proba = _model.predict_proba([features])[0]
    score = round(float(proba[1]) * 100, 2)
    label = 1 if score > 70 else 0
    return score, label


# Attempt load at import time
load_model()
