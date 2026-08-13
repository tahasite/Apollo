import os
import json
import urllib.request
import urllib.error
from core.config_manager import ConfigManager, DEFAULT_MODEL_NAME


class GeminiManager:
    @staticmethod
    def cleanup_json_text(text):
        cleaned = text.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.replace("```json", "").replace("```", "").strip()
        start = cleaned.find("{")
        end = cleaned.rfind("}")
        if start != -1 and end != -1:
            cleaned = cleaned[start:end + 1]
        return cleaned

    @staticmethod
    def normalize_hashtags(value):
        if isinstance(value, list):
            raw_items = [str(item).strip() for item in value if str(item).strip()]
        elif isinstance(value, str):
            prepared = value.replace(",", " ").replace("\n", " ").replace("\t", " ")
            raw_items = [item.strip() for item in prepared.split(" ") if item.strip()]
        else:
            raw_items = []
        tags = []
        seen = set()
        for item in raw_items:
            tag = item.strip()
            if not tag:
                continue
            if not tag.startswith("#"):
                tag = f"#{tag}"
            tag = "#" + tag[1:].replace(" ", "").replace("#", "")
            if len(tag) > 1:
                low = tag.lower()
                if low not in seen:
                    seen.add(low)
                    tags.append(tag)
        return " ".join(tags)

    @staticmethod
    def build_prompt(description, video_path, language="english"):
        filename = os.path.basename(video_path) if video_path else ""
        return f"""You are an expert social media strategist for mma, ufc, combat sports edits, instagram reels, and youtube shorts.

Your task:
1. Infer the most likely fighters, event, promotion, and searchable context from the user description and the filename.
2. If the match is recognizable, use the likely real event context naturally.
3. Create a high engagement instagram reel caption with strong hook energy.
4. Create an seo friendly youtube shorts package.
5. Use plenty of relevant emojis naturally throughout all text fields. every line should have at least 1-2 emojis.
6. Keep it clean, viral, and realistic.
7. Write ALL output text in {language} language. hashtags should also be in {language} where possible.
8. The user may describe the video in any language. always produce output in {language} regardless of input language.

Return valid json only with this exact structure:
{{
  "identified_topic": "short clear topic summary with emojis",
  "instagram_caption": "2 to 5 short lines with emojis, punchy and scroll stopping",
  "instagram_hashtags": ["12 to 18 relevant hashtags"],
  "youtube_title": "seo friendly shorts title under 100 characters with emojis",
  "youtube_description": "2 to 4 short lines with emojis, energy and context",
  "youtube_hashtags": ["8 to 12 strong hashtags"]
}}

Video filename:
{filename}

User description:
{description}"""

    @staticmethod
    def call_api(api_key, model_name, prompt):
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "temperature": 0.8,
                "topP": 0.95,
                "responseMimeType": "application/json"
            }
        }
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=45) as response:
            raw = response.read().decode("utf-8")
        data = json.loads(raw)
        candidates = data.get("candidates", [])
        if not candidates:
            raise RuntimeError("empty gemini response")
        parts = candidates[0].get("content", {}).get("parts", [])
        if not parts:
            raise RuntimeError("missing response parts")
        text = parts[0].get("text", "").strip()
        if not text:
            raise RuntimeError("empty text payload from gemini")
        cleaned = GeminiManager.cleanup_json_text(text)
        parsed = json.loads(cleaned)
        result = {
            "identified_topic": str(parsed.get("identified_topic", "")).strip(),
            "instagram_caption": str(parsed.get("instagram_caption", "")).strip(),
            "instagram_hashtags": GeminiManager.normalize_hashtags(parsed.get("instagram_hashtags", [])),
            "youtube_title": str(parsed.get("youtube_title", "")).strip(),
            "youtube_description": str(parsed.get("youtube_description", "")).strip(),
            "youtube_hashtags": GeminiManager.normalize_hashtags(parsed.get("youtube_hashtags", []))
        }
        return result

    @staticmethod
    def generate_social_pack(config, description, video_path, language="english"):
        keys = ConfigManager.normalize_api_keys(config.get("gemini_api_keys", []))
        if not keys:
            raise RuntimeError("no gemini api keys available. please add at least one key in settings.")
        model_name = config.get("gemini_model", DEFAULT_MODEL_NAME) or DEFAULT_MODEL_NAME
        start_index = int(config.get("gemini_key_index", 0)) % len(keys)
        prompt = GeminiManager.build_prompt(description, video_path, language)
        errors = []
        for step in range(len(keys)):
            idx = (start_index + step) % len(keys)
            key = keys[idx]
            try:
                result = GeminiManager.call_api(key, model_name, prompt)
                config["gemini_key_index"] = (idx + 1) % len(keys)
                ConfigManager.save(config)
                return result
            except Exception as e:
                errors.append(f"key {idx + 1}: {str(e)}")
        raise RuntimeError("all gemini api keys failed\n" + "\n".join(errors))