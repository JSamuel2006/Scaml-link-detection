#!/usr/bin/env python3
"""
Scam Link Detection – ML Training Script
========================================
Trains a RandomForestClassifier on labeled URL data.
Run from the backend/ directory:
    python train_model.py
"""

import os
import sys
import pickle

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.ml.features import extract_features, FEATURE_NAMES

DATASET_PATH = os.path.join(os.path.dirname(__file__), "data", "dataset.csv")
MODEL_DIR = os.path.join(os.path.dirname(__file__), "ml_models")
MODEL_PATH = os.path.join(MODEL_DIR, "rf_model.pkl")


def main():
    print("=" * 60)
    print("  Scam Link Detection – Model Training")
    print("=" * 60)

    # ── Load dataset ──────────────────────────────────────────────
    print(f"\n📂 Loading dataset: {DATASET_PATH}")
    df = pd.read_csv(DATASET_PATH)
    df.dropna(subset=["url", "label"], inplace=True)
    df["label"] = df["label"].astype(int)
    print(f"   Rows: {len(df)}  |  Safe: {(df.label==0).sum()}  |  Scam: {(df.label==1).sum()}")

    # ── Feature extraction ────────────────────────────────────────
    print("\n🔧 Extracting features …")
    X = np.array([extract_features(str(u)) for u in df["url"]])
    y = df["label"].values
    print(f"   Feature matrix shape: {X.shape}")

    # ── Train / test split ────────────────────────────────────────
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # ── Train model ───────────────────────────────────────────────
    print("\n🚀 Training RandomForestClassifier (100 trees) …")
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=12,
        min_samples_split=5,
        min_samples_leaf=2,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1,
    )
    model.fit(X_train, y_train)

    # ── Evaluate ──────────────────────────────────────────────────
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"\n📊 Accuracy : {acc:.4f}  ({acc*100:.2f}%)")
    print("\n📊 Classification Report:")
    print(classification_report(y_test, y_pred, target_names=["Safe", "Scam"]))
    print("📊 Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred))

    # ── Feature importance ────────────────────────────────────────
    print("\n📊 Feature Importance:")
    for name, imp in sorted(zip(FEATURE_NAMES, model.feature_importances_), key=lambda x: -x[1]):
        bar = "█" * int(imp * 40)
        print(f"  {name:<25} {bar} {imp:.4f}")

    # ── Save model ────────────────────────────────────────────────
    os.makedirs(MODEL_DIR, exist_ok=True)
    with open(MODEL_PATH, "wb") as f:
        pickle.dump(model, f)
    print(f"\n✅ Model saved → {MODEL_PATH}")
    print("=" * 60)


if __name__ == "__main__":
    main()
