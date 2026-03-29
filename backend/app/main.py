from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

from app.database import engine, Base, get_db
from app.routes import auth, user, admin
from app.ml.blacklist import load_blacklist
from app.ml.model import load_model

# Create all DB tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Scam Link Detection API",
    description="""
## AI-Powered Scam Link Detection System

Hybrid detection using **Blacklist** + **RandomForest ML model**.

### Features
- 🔐 JWT Authentication (User + Admin roles)
- 🧠 ML-based URL risk scoring
- 📋 Blacklist matching
- 📊 Admin analytics & user management
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(user.router, tags=["User"])
app.include_router(admin.router, tags=["Admin"])


@app.on_event("startup")
async def startup_event():
    load_blacklist()
    load_model()

    # Seed default admin account
    db = next(get_db())
    try:
        from app.models.user import User
        from app.services.auth_service import hash_password
        if not db.query(User).filter(User.role == "admin").first():
            db.add(User(
                name="Admin",
                email="admin@scamdetector.com",
                password=hash_password("Admin@123"),
                role="admin",
                status="active",
            ))
            db.commit()
            print("✅ Default admin created: admin@scamdetector.com / Admin@123")
    finally:
        db.close()


@app.get("/", tags=["Health"])
def health_check():
    return {"status": "ok", "service": "Scam Link Detection API", "version": "1.0.0"}
