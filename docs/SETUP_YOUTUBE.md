
# ▶️ YouTube API Setup Guide

Connect your YouTube channel to upload Shorts directly from Apollo.

---

## 📋 Prerequisites

- Google account with a YouTube channel
- Google Cloud Console access (free)
- ~10 minutes for setup

---

## 🚀 Step-by-Step Setup

### Step 1: Go to Google Cloud Console

Navigate to: **[https://console.cloud.google.com/](https://console.cloud.google.com/)**

Sign in with the Google account that owns your YouTube channel.

### Step 2: Create a New Project

1. Click the **project dropdown** (top left, next to "Google Cloud")
2. Click **"New Project"**
3. Fill in:
   - **Project name:** `Apollo YouTube` (or any name)
   - **Location:** No organization
4. Click **"Create"**
5. Wait 30 seconds for project to be created
6. Select your new project from the dropdown

### Step 3: Enable YouTube Data API v3

1. Go to **☰ Menu** → **APIs & Services** → **Library**
2. Search: **"YouTube Data API v3"**
3. Click on the result
4. Click **"Enable"** button
5. Wait for it to activate

### Step 4: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. User Type: **External** (unless you have Google Workspace)
3. Click **Create**

**Fill in required fields:**

**App Information:**

- App name: `Apollo`
- User support email: your email
- App logo: (optional)

**App Domain (skip):**

- Application home page: (leave blank)
- Application privacy policy link: (leave blank)
- Application terms of service link: (leave blank)

**Authorized domains (skip)**

**Developer contact information:**

- Email addresses: your email

Click **Save and Continue**

**Scopes:**

- Click **Save and Continue** (we'll add scopes automatically)

**Test users:**

- Click **Add Users**
- Enter your Gmail address (the one with YouTube channel)
- Click **Save and Continue**

**Summary:**

- Review and click **Back to Dashboard**

### Step 5: Create OAuth Client ID

This step is **different for Windows vs Android!**

---

## 🖥️ For Windows

### Step 5A (Windows): Create Desktop Client

1. Go to **APIs & Services** → **Credentials**
2. Click **+ Create Credentials** → **OAuth client ID**
3. Application type: **Desktop app** ⚠️ (very important!)
4. Name: `Apollo Windows`
5. Click **Create**

### Step 6A (Windows): Download JSON

1. Your new client appears in the list
2. Click the **download icon** (⬇) on the right
3. A JSON file downloads (e.g., `client_secret_XXX.json`)
4. Save it somewhere accessible

### Step 7A (Windows): Add to Apollo

**In Apollo (Windows):**

1. Open **Settings** (⚙️)
2. Find **▶️ YouTube API** section
3. Click **"Select client secret JSON"**
4. Choose the downloaded JSON file
5. File is automatically loaded ✓
6. Settings are saved

---

## 📱 For Android

### Step 5B (Android): Get SHA-1 Fingerprint

Before creating OAuth client, you need SHA-1.

**On your development machine:**

```bash
cd apollo/mobile/android
./gradlew signingReport
```

**Look for output like:**

```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: 12:AB:34:CD:56:EF:78:90:12:34:56:78:90:AB:CD:EF:12:34:56:78
```

Copy the **SHA1** value (the whole string with colons).

### Step 6B (Android): Create Android Client

1. Go to **APIs & Services** → **Credentials**
2. Click **+ Create Credentials** → **OAuth client ID**
3. Application type: **Android** ⚠️
4. Name: `Apollo Android`
5. **Package name:** `com.tahasite.apollo`
6. **SHA-1 certificate fingerprint:** paste your SHA1
7. Click **Create**

### Step 7B (Android): No Download Needed

For Android, credentials are automatically handled via Google Sign-In. No file to download.

**In Apollo (Android):**

1. Go to **Publish** tab
2. Click **"Connect YouTube Account"**
3. Sign in with your Google account
4. Grant permissions
5. Done! ✓

---

## 🧪 Test Your Setup

### Windows

1. Open Apollo Settings
2. Verify YouTube shows: **"youtube_client_secret.json found ✓"**
3. Go to **Publish** tab
4. Click **"Connect YouTube Account"**
5. Browser opens → authorize
6. Should return to Apollo with success

### Android

1. Open Apollo
2. Go to **Publish** tab
3. Click **"Connect YouTube Account"**
4. Google Sign-In appears
5. Select your account
6. Grant permissions
7. Should show your email

---

## 📊 API Quotas

### Free Tier

- **10,000 units per day** (resets at midnight PT)
- Video upload = **1,600 units**
- **You can upload ~6 videos per day for FREE**

### Actions Cost

| Action         | Units |
| -------------- | ----- |
| Upload video   | 1,600 |
| Update video   | 50    |
| Delete video   | 50    |
| List videos    | 1     |
| Get video info | 1     |

### Need More?

Request quota increase: [YouTube API Services Support](https://support.google.com/youtube/contact/yt_api_form)

---

## 🎥 YouTube Shorts Requirements

For your video to be detected as a Short:

| Property     | Requirement               |
| ------------ | ------------------------- |
| Format       | MP4                       |
| Aspect Ratio | 9:16 (vertical)           |
| Resolution   | 1080x1920 recommended     |
| Duration     | **Under 3 minutes** |
| Title        | Include`#Shorts`        |
| Frame Rate   | 24-60 FPS                 |

Apollo automatically formats videos for Shorts.

---

## 🔒 Privacy Settings

When uploading, Apollo lets you choose:

- **🔒 Private** — Only you can watch (default, safest)
- **🔗 Unlisted** — Only people with link can watch
- **🌍 Public** — Anyone can watch and find

**Recommendation:** Start with **Private** to test, then switch to **Public**.

---

## 🐛 Troubleshooting

### ❌ Windows: "Access blocked: This app's request is invalid"

**Cause:** OAuth client type is wrong.

**Solution:**

1. Delete the current OAuth client
2. Create a new one
3. **Must select "Desktop app"** (not Web, not Mobile)
4. Download new JSON
5. Re-upload in Apollo

### ❌ Windows: "403 access_denied"

**Cause:** Your email is not in Test Users.

**Solution:**

1. Go to OAuth consent screen
2. **Test users** → **Add users**
3. Add your Gmail
4. Try again

### ❌ Android: "Error 10: DEVELOPER_ERROR"

**Cause:** SHA-1 fingerprint mismatch.

**Solution:**

1. Get correct SHA-1: `./gradlew signingReport`
2. Update in Google Cloud Console
3. Wait 5 minutes for changes to propagate
4. Try again

### ❌ "YouTube Data API has not been used"

**Cause:** API not enabled.

**Solution:**

1. Go to APIs & Services → Library
2. Search "YouTube Data API v3"
3. Click **Enable**

### ❌ "Quota exceeded"

**Cause:** Used 10,000 units today.

**Solution:**

1. Wait until midnight Pacific Time (resets)
2. Request quota increase
3. Use fewer uploads per day

### ❌ Upload fails immediately

**Solutions:**

1. Verify token is not expired
2. Re-authenticate: Disconnect → Connect again
3. Check internet connection
4. Try smaller video file

---

## 🔐 Security Best Practices

- ✅ **Never share** client secret JSON file
- ✅ **Never commit** to Git repositories
- ✅ **Keep test users list** minimal
- ✅ **Revoke unused** OAuth clients
- ✅ **Monitor** API usage in dashboard

### If Credentials Are Compromised

1. Google Cloud Console → **Credentials**
2. Delete compromised OAuth client
3. Create new one
4. Update in Apollo

---

## 🚀 Publishing App to Production

**For personal use, Testing mode is fine!**

If you want to distribute Apollo publicly with your OAuth:

### App Verification Process

1. Complete **OAuth consent screen**
2. Provide:
   - Privacy policy URL
   - Terms of service URL
   - Application homepage
   - Demo video showing usage
3. Submit for verification
4. Wait 2-6 weeks for approval

**Not needed for personal/private use.**

---

## 📱 Multiple Channels?

If you manage multiple YouTube channels:

1. Sign out from Apollo (Disconnect)
2. Sign in with the account owning the target channel
3. Each account can be connected separately

---

## 📚 Additional Resources

- [YouTube API Docs](https://developers.google.com/youtube/v3)
- [Google Cloud Console](https://console.cloud.google.com/)
- [OAuth 2.0 Guide](https://developers.google.com/identity/protocols/oauth2)
- [YouTube Shorts Guide](https://support.google.com/youtube/answer/10059070)
- [API Quotas](https://developers.google.com/youtube/v3/getting-started#quota)

---

## 💬 Need Help?

Contact us: **[@main_admin_tahasite](https://t.me/main_admin_tahasite)** on Telegram

**Response time:** Usually within 24 hours

---

<div align="center">
