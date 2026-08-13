
# 🤖 Gemini AI Setup Guide

Gemini is Google's AI model used by Apollo to generate captions, hashtags, and social media content for your videos.

---

## 📋 Prerequisites

- A Google account
- Internet connection
- 2 minutes of your time

---

## 🚀 Quick Setup

### Step 1: Open Google AI Studio

Navigate to: **[https://aistudio.google.com/apikey](https://aistudio.google.com/apikey)**

### Step 2: Sign In

Sign in with your Google account. If you don't have one, create it for free.

### Step 3: Create API Key

1. Click the **"Create API key"** button (top right)
2. Select an existing Google Cloud project OR click **"Create API key in new project"**
3. Wait a few seconds for the key to generate

### Step 4: Copy the Key

- Your key will look like: `AIzaSyB6iQ65eP7TbcgjX9t2Q8W7TZve95EGgCA`
- Click the **copy icon** next to the key
- **⚠️ Keep it secret!** Never share this key publicly

### Step 5: Add to Apollo

**In Apollo:**

1. Open **Settings** (⚙️ tab)
2. Find the **🤖 Gemini AI** section
3. Paste your key in the **"API keys"** field
4. Click **💾 Save all settings**

---

## 🎯 Pro Tips

### Multiple API Keys for Rotation

Apollo supports **multiple API keys** with automatic rotation:

- Paste **2-3 keys**, one per line
- If one key hits rate limit, Apollo automatically uses the next
- Prevents interruptions during heavy usage

Example:

```
AIzaSyB6iQ65eP7TbcgjX9t2Q8W7TZve95EGgCA
AIzaSyAeWvR9vaTkFcnPlVNyfQiISbCVNzow8xE
AIzaSyCTCrbkA1F31TCdHvZeVae1gmreLMMmwe8
```

### Choosing a Model

**Default:** `gemini-2.0-flash-lite`

**Available models:**

- `gemini-2.0-flash-lite` — Fastest, cheapest (recommended)
- `gemini-2.0-flash` — Balanced speed and quality
- `gemini-1.5-pro` — Highest quality (slower)

Browse all models: [https://ai.google.dev/gemini-api/docs/models](https://ai.google.dev/gemini-api/docs/models)

To change model:

1. Settings → Gemini AI
2. Change **"Model name"** field
3. Save settings

---

## 💰 Pricing

### Free Tier (Perfect for Personal Use)

| Feature             | Limit     |
| ------------------- | --------- |
| Requests per minute | 15        |
| Requests per day    | 1,500     |
| Tokens per minute   | 1,000,000 |

**Reality:** With Apollo generating ~500 tokens per video, you can process **~2,000 videos per day** for FREE.

### Need More?

If you need higher limits, upgrade to paid tier at [Google AI pricing](https://ai.google.dev/pricing).

---

## 🌍 Supported Languages

Apollo generates content in 14+ languages:

- 🇺🇸 English
- 🇮🇷 Persian (فارسی)
- 🇸🇦 Arabic (العربية)
- 🇹🇷 Turkish (Türkçe)
- 🇪🇸 Spanish (Español)
- 🇫🇷 French (Français)
- 🇩🇪 German (Deutsch)
- 🇵🇹 Portuguese (Português)
- 🇨🇳 Chinese (中文)
- 🇯🇵 Japanese (日本語)
- 🇰🇷 Korean (한국어)
- 🇷🇺 Russian (Русский)
- 🇮🇳 Hindi (हिन्दी)
- 🇮🇩 Indonesian

Change output language in Dashboard → AI Content Studio.

---

## 🐛 Troubleshooting

### ❌ "API key not valid"

**Cause:** Key is incorrect or was revoked.

**Solution:**

1. Verify you copied the entire key
2. Generate a new key at [AI Studio](https://aistudio.google.com/apikey)
3. Remove any spaces or line breaks
4. Save settings again

### ❌ "Quota exceeded"

**Cause:** You've hit the daily/minute limit.

**Solution:**

1. Wait 1 minute (for per-minute limit)
2. Wait until tomorrow (for daily limit)
3. Add more API keys for rotation
4. Upgrade to paid tier

### ❌ "All gemini api keys failed"

**Cause:** All your keys have issues.

**Solution:**

1. Test each key individually
2. Generate new keys
3. Check internet connection
4. Verify Google Cloud project is active

### ❌ Empty response from AI

**Cause:** Content filter triggered or model overloaded.

**Solution:**

1. Try different description text
2. Change to another model
3. Retry after a few minutes

---

## 🔒 Security Best Practices

- ✅ **Never commit** API keys to Git
- ✅ **Never share** keys publicly
- ✅ **Rotate keys** every few months
- ✅ **Revoke unused** keys immediately
- ✅ **Use separate keys** for different apps

If you accidentally exposed a key:

1. Go to [AI Studio](https://aistudio.google.com/apikey)
2. Click the trash icon next to compromised key
3. Generate a new one

---

## 📚 Additional Resources

- [Official Gemini Docs](https://ai.google.dev/docs)
- [API Reference](https://ai.google.dev/api)
- [Model Comparison](https://ai.google.dev/gemini-api/docs/models)
- [Google Cloud Console](https://console.cloud.google.com/)

---

## 💬 Need Help?

Contact us: **[@main_admin_tahasite](https://t.me/main_admin_tahasite)** on Telegram

**Response time:** Usually within 24 hours

---

<div align="center">
