import os
from urllib.parse import urlparse

_blacklist: set = set()

BLACKLIST_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", "data", "blacklist.txt"
)


def load_blacklist() -> None:
    global _blacklist
    try:
        path = os.path.abspath(BLACKLIST_PATH)
        with open(path, "r", encoding="utf-8") as f:
            entries = [line.strip().lower() for line in f if line.strip() and not line.startswith("#")]
        _blacklist = set(entries)
        print(f"✅ Blacklist loaded: {len(_blacklist)} entries")
    except FileNotFoundError:
        print(f"⚠️  Blacklist file not found at {BLACKLIST_PATH}")
        _blacklist = set()
    except Exception as e:
        print(f"⚠️  Error loading blacklist: {e}")
        _blacklist = set()


def is_blacklisted(url: str) -> bool:
    url_lower = url.lower().strip()
    if url_lower in _blacklist:
        return True
    try:
        parsed = urlparse(url_lower)
        domain = parsed.netloc.split(":")[0]  # strip port
        if domain in _blacklist:
            return True
        if domain.startswith("www."):
            domain = domain[4:]
        if domain in _blacklist:
            return True
    except Exception:
        pass
    return False


def add_to_blacklist(url: str) -> None:
    _blacklist.add(url.lower().strip())


# Load on import
load_blacklist()
