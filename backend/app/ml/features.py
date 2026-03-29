import re
import math
from urllib.parse import urlparse

SUSPICIOUS_KEYWORDS = [
    "login", "verify", "bank", "free", "reward", "update", "secure",
    "account", "password", "confirm", "prize", "winner", "urgent",
    "limited", "click", "claim", "suspended", "alert", "validate"
]

SUSPICIOUS_TLDS = [
    ".tk", ".ml", ".ga", ".cf", ".gq", ".xyz", ".top",
    ".click", ".work", ".loan", ".win", ".bid", ".stream"
]


def calculate_entropy(text: str) -> float:
    if not text:
        return 0.0
    freq: dict = {}
    for c in text:
        freq[c] = freq.get(c, 0) + 1
    entropy = 0.0
    n = len(text)
    for count in freq.values():
        p = count / n
        if p > 0:
            entropy -= p * math.log2(p)
    return round(entropy, 4)


def extract_features(url: str) -> list:
    """Extract 14 numerical features from a URL for ML prediction."""
    try:
        parsed = urlparse(url)
        hostname = parsed.hostname or ""
        path = parsed.path or ""

        url_length = len(url)
        num_dots = hostname.count(".")
        has_at = 1 if "@" in url else 0
        has_dash = 1 if "-" in hostname else 0
        digit_count = sum(c.isdigit() for c in url)
        is_https = 1 if parsed.scheme == "https" else 0

        ip_pattern = re.compile(r'^(\d{1,3}\.){3}\d{1,3}$')
        has_ip = 1 if ip_pattern.match(hostname) else 0

        url_lower = url.lower()
        keyword_count = sum(1 for kw in SUSPICIOUS_KEYWORDS if kw in url_lower)

        parts = hostname.split(".")
        num_subdomains = max(0, len(parts) - 2) if hostname else 0

        path_length = len(path)
        num_slashes = path.count("/")
        has_query = 1 if parsed.query else 0
        entropy = calculate_entropy(url)
        has_suspicious_tld = 1 if any(hostname.endswith(t) for t in SUSPICIOUS_TLDS) else 0

        return [
            url_length, num_dots, has_at, has_dash, digit_count,
            is_https, has_ip, keyword_count, num_subdomains, path_length,
            num_slashes, has_query, entropy, has_suspicious_tld
        ]
    except Exception:
        return [0] * 14


FEATURE_NAMES = [
    "url_length", "num_dots", "has_at", "has_dash", "digit_count",
    "is_https", "has_ip", "keyword_count", "num_subdomains", "path_length",
    "num_slashes", "has_query", "entropy", "has_suspicious_tld"
]
