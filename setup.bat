@echo off
echo ============================================
echo  ScamGuard - Backend Setup Script (Windows)
echo ============================================

cd /d "%~dp0backend"

echo.
echo [1/5] Creating virtual environment...
python -m venv venv

echo.
echo [2/5] Activating virtual environment...
call venv\Scripts\activate.bat

echo.
echo [3/5] Installing dependencies...
pip install -r requirements.txt

echo.
echo [4/5] Copying .env file...
if not exist .env (
    copy .env.example .env
    echo .env created. Please edit it with your PostgreSQL credentials.
)

echo.
echo [5/5] Training ML model...
python train_model.py

echo.
echo ============================================
echo  Setup complete!
echo  Run: uvicorn app.main:app --reload
echo  Docs: http://localhost:8000/docs
echo ============================================
pause
