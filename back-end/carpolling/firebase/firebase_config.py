import logging
from pathlib import Path

import firebase_admin
from firebase_admin import credentials

logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent

SERVICE_ACCOUNT_KEY_PATH = BASE_DIR / "firebase" / "serviceAccountKey.json"


def init_firebase():
    """Initialize the Firebase Admin SDK once.

    Guarded so a missing/invalid service account key does not crash the
    server at startup — notification sends simply become no-ops (they are
    already wrapped in try/except via safe_send_notification).
    """
    if firebase_admin._apps:
        return True

    if not SERVICE_ACCOUNT_KEY_PATH.exists():
        logger.warning(
            "Firebase service account key not found at %s — "
            "push notifications are disabled.",
            SERVICE_ACCOUNT_KEY_PATH,
        )
        return False

    try:
        cred = credentials.Certificate(str(SERVICE_ACCOUNT_KEY_PATH))
        firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized.")
        return True
    except Exception as e:  # noqa: BLE001
        logger.exception("Failed to initialize Firebase Admin SDK: %s", e)
        return False
