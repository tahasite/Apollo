
# ☁️ Cloudinary Setup Guide

Cloudinary is a free media hosting service used by Apollo to temporarily host videos for Instagram publishing.

---

## 🤔 Why Do I Need Cloudinary?

Instagram's API requires a **public URL** to fetch your video (it doesn't accept direct file uploads).

**The flow:**

```
Your Device → Upload to Cloudinary → Get URL → Instagram fetches → Auto-deleted
```

Apollo **automatically deletes** videos from Cloudinary after successful publish.

---

## 📋 Prerequisites

- Email address
- 3 minutes of your time

**No credit card required!**

---

## 🚀 Quick Setup

### Step 1: Create Free Account

Go to: **[https://cloudinary.com/](https://cloudinary.com/)**

1. Click **"Sign Up For Free"** (top right)
2. Choose **"Programmable Media"**
3. Fill in details:
   - Full name
   - Email
   - Password
4. Click **"Create Account"**
5. Verify your email

### Step 2: Complete Registration

1. Select your role: **Developer**
2. Company/Project name: `Apollo` (or your choice)
3. Skip the survey questions
4. Click **"Continue"**

### Step 3: Get Your Credentials

1. You'll land on the **Dashboard**
2. Look for **"Product Environment Credentials"** section
3. You'll see three important values:

| Credential | Example                                         |
| ---------- | ----------------------------------------------- |
| Cloud Name | `dxxxxxxxx` or `apollo-user`                |
| API Key    | `123456789012345`                             |
| API Secret | `abc***DEFghij***klm` (click "Reveal" to see) |

### Step 4: Add to Apollo

**In Apollo:**

1. Open **Settings** (⚙️)
2. Find **☁️ Cloudinary** section
3. Fill in:
   - **Cloud Name:** paste your cloud name
   - **API Key:** paste your API key
   - **API Secret:** paste your API secret (click 👁 to see)
4. Click **💾 Save all settings**

---

## 💰 Free Tier Limits

Cloudinary's free tier is **very generous**:

| Feature         | Free Limit   |
| --------------- | ------------ |
| Storage         | 25 GB        |
| Bandwidth       | 25 GB/month  |
| Transformations | 25,000/month |
| API Calls       | Unlimited    |

### Reality Check

For Apollo usage:

- Average reel: ~15 MB
- **You can publish ~1,600 reels per month for FREE**
- Since Apollo auto-deletes, storage stays minimal

**More than enough for personal and small business use!**

---

## 🔄 How Apollo Uses Cloudinary

### Upload Flow

1. User clicks "Publish to Instagram"
2. Apollo uploads video to Cloudinary (encrypted)
3. Cloudinary returns a temporary public URL
4. Apollo sends URL to Instagram API
5. Instagram fetches video from URL
6. Instagram processes video (30-60 seconds)
7. **Apollo automatically deletes video from Cloudinary**
8. User's storage stays clean

### Security

- ✅ Videos are only accessible via unique URL
- ✅ URLs are temporary
- ✅ Auto-deletion after publish
- ✅ Cloudinary uses HTTPS encryption
- ✅ Your credentials stay on your device

---

## 📊 Monitor Your Usage

### Dashboard

Go to [Cloudinary Dashboard](https://cloudinary.com/console) to see:

- **Storage used** (should be near 0 if Apollo auto-deletes)
- **Bandwidth this month**
- **Total transformations**
- **Recent uploads**

### Usage Alerts

Set up alerts to avoid surprises:

1. **Settings** → **Notifications**
2. Enable **"Usage warnings"**
3. Set threshold: **80%**

---

## 🎥 Supported Formats

Cloudinary accepts these video formats:

- **Best:** MP4 (H.264 + AAC)
- Also: MOV, AVI, WEBM, MKV, WMV, FLV
- Max file size: 100 MB (free tier)

Apollo outputs MP4 by default, so no issues.

---

## 🐛 Troubleshooting

### ❌ "Invalid API key"

**Solution:**

1. Verify you copied the entire key
2. Check for extra spaces
3. Regenerate credentials in Dashboard → Settings

### ❌ "Cloud name not found"

**Solution:**

1. Verify cloud name spelling (case-sensitive)
2. Copy from Dashboard exactly
3. Don't include quotes or spaces

### ❌ "Upload failed - size exceeded"

**Cause:** Video too large (over 100 MB).

**Solution:**

1. Use shorter videos (under 60 seconds)
2. Reduce video quality in Apollo settings
3. Upgrade to paid Cloudinary plan for larger files

### ❌ "Bandwidth limit exceeded"

**Cause:** Used 25 GB this month.

**Solutions:**

1. Wait until next month (resets on the 1st)
2. Delete old videos from Cloudinary
3. Upgrade to paid plan

### ❌ "Rate limit exceeded"

**Solution:**

1. Wait 1-2 minutes
2. Try again
3. Contact Cloudinary support if persistent

---

## 🔒 Security Best Practices

- ✅ **Never share** your API Secret
- ✅ **Never commit** credentials to Git
- ✅ **Rotate credentials** every few months
- ✅ **Monitor usage** for suspicious activity
- ✅ **Delete old assets** manually if needed

### If Credentials Are Compromised

1. Go to [Dashboard](https://cloudinary.com/console)
2. **Settings** → **Security**
3. Click **"Regenerate API Secret"**
4. Update credentials in Apollo
5. Save settings

---

## 🎨 Advanced Features (Optional)

Cloudinary offers many features Apollo doesn't use, but you can explore:

- Auto video optimization
- Image transformations
- CDN delivery
- Video streaming
- AI-powered tagging

Learn more: [Cloudinary Docs](https://cloudinary.com/documentation)

---

## 📚 Additional Resources

- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Video Management Guide](https://cloudinary.com/documentation/video_management)
- [API Reference](https://cloudinary.com/documentation/admin_api)
- [Support Center](https://support.cloudinary.com/)
- [Community Forum](https://community.cloudinary.com/)

---

## 💬 Need Help?

Contact us: **[@main_admin_tahasite](https://t.me/main_admin_tahasite)** on Telegram

**Response time:** Usually within 24 hours

---

<div align="center">
