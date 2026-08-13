import os
import json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_FILE = os.path.join(BASE_DIR, "config.json")
SETUP_FLAG_FILE = os.path.join(BASE_DIR, ".setup_complete")
YOUTUBE_SECRET_FILE = os.path.join(BASE_DIR, "youtube_client_secret.json")
TOKENS_DIR = os.path.join(BASE_DIR, "tokens")
DEFAULT_MODEL_NAME = "gemini-3.1-flash-lite"
APP_NAME = "Apollo"
APP_VERSION = "2.0.0"
APP_AUTHOR = "tahasite"

os.makedirs(TOKENS_DIR, exist_ok=True)


class ConfigManager:
    @staticmethod
    def normalize_api_keys(raw_value):
        if isinstance(raw_value, list):
            keys = [str(item).strip() for item in raw_value if str(item).strip()]
        elif isinstance(raw_value, str):
            temp = raw_value.replace(",", "\n")
            keys = [line.strip() for line in temp.splitlines() if line.strip()]
        else:
            keys = []
        return keys

    @staticmethod
    def default_config():
        return {
            "gemini_api_keys": [],
            "gemini_model": DEFAULT_MODEL_NAME,
            "gemini_key_index": 0,
            "instagram_access_token": "",
            "instagram_user_id": "",
            "instagram_app_secret": "",
            "cloudinary_cloud_name": "",
            "cloudinary_api_key": "",
            "cloudinary_api_secret": "",
            "youtube_client_id": "",
            "youtube_client_secret": "",
            "youtube_json_path": "",
            "wm_path": "",
            "wm_scale": 1.0,
            "wm_x": 50.0,
            "wm_y": 50.0
        }

    @staticmethod
    def load():
        config = ConfigManager.default_config()
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                    loaded = json.load(f)
                if "api_keys" in loaded and not loaded.get("gemini_api_keys"):
                    loaded["gemini_api_keys"] = loaded.pop("api_keys", [])
                if "api_key" in loaded and loaded.get("api_key") and not loaded.get("gemini_api_keys"):
                    loaded["gemini_api_keys"] = [loaded.get("api_key", "").strip()]
                if "model_name" in loaded and not loaded.get("gemini_model"):
                    loaded["gemini_model"] = loaded.pop("model_name", DEFAULT_MODEL_NAME)
                config.update(loaded)
            except:
                pass
        config["gemini_api_keys"] = ConfigManager.normalize_api_keys(config.get("gemini_api_keys", []))
        if not config["gemini_model"]:
            config["gemini_model"] = DEFAULT_MODEL_NAME
        try:
            config["wm_scale"] = float(config.get("wm_scale", 1.0))
        except:
            config["wm_scale"] = 1.0
        try:
            config["wm_x"] = float(config.get("wm_x", 50.0))
        except:
            config["wm_x"] = 50.0
        try:
            config["wm_y"] = float(config.get("wm_y", 50.0))
        except:
            config["wm_y"] = 50.0
        try:
            config["gemini_key_index"] = int(config.get("gemini_key_index", 0))
        except:
            config["gemini_key_index"] = 0
        return config

    @staticmethod
    def save(config_data):
        payload = {}
        for key, default_val in ConfigManager.default_config().items():
            val = config_data.get(key, default_val)
            if key == "gemini_api_keys":
                val = ConfigManager.normalize_api_keys(val)
            elif isinstance(default_val, float):
                try:
                    val = float(val)
                except:
                    val = default_val
            elif isinstance(default_val, int):
                try:
                    val = int(val)
                except:
                    val = default_val
            payload[key] = val
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=4)

    @staticmethod
    def is_instagram_configured(config):
        return bool(
            config.get("instagram_access_token", "").strip()
            and config.get("instagram_user_id", "").strip()
            and config.get("instagram_app_secret", "").strip()
        )

    @staticmethod
    def is_cloudinary_configured(config):
        return bool(
            config.get("cloudinary_cloud_name", "").strip()
            and config.get("cloudinary_api_key", "").strip()
            and config.get("cloudinary_api_secret", "").strip()
        )

    @staticmethod
    def is_youtube_configured(config):
        return os.path.exists(YOUTUBE_SECRET_FILE)

    @staticmethod
    def is_gemini_configured(config):
        keys = ConfigManager.normalize_api_keys(config.get("gemini_api_keys", []))
        return len(keys) > 0

    @staticmethod
    def is_setup_complete():
        return os.path.exists(SETUP_FLAG_FILE)

    @staticmethod
    def mark_setup_complete():
        with open(SETUP_FLAG_FILE, "w") as f:
            f.write("1")