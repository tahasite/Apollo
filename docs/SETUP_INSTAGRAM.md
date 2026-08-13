
# 📸 Instagram API Setup Guide

Connect your Instagram Business account to publish Reels automatically from Apollo.

---

## ⚠️ Important Requirements

Before starting, you **must** have:

- ✅ Instagram **Business** or **Creator** account (Personal accounts don't work)
- ✅ Facebook Page connected to your Instagram
- ✅ Meta Developer account (free)
- ✅ ~10 minutes for setup

---

## 🔄 How It Works

```
Your Instagram Account
        ↓
   Facebook Page
        ↓
  Meta Developer App
        ↓
   Instagram API
        ↓
      Apollo
```

---

## 🚀 Step-by-Step Setup

### Step 1: Convert to Business/Creator Account

**If you already have a Business account, skip this step.**

1. Open Instagram app
2. Go to **Settings** → **Account**
3. Tap **"Switch to Professional Account"**
4. Choose **Business** or **Creator**
5. Follow the setup

### Step 2: Connect to Facebook Page

1. In Instagram settings → **Account**
2. Tap **"Linked Accounts"** → **Facebook**
3. Connect to an existing Facebook Page or create one

### Step 3: Create Meta Developer Account

1. Go to: **[https://developers.facebook.com/](https://developers.facebook.com/)**
2. Click **"Get Started"** (top right)
3. Log in with your Facebook account
4. Complete the developer registration
5. Verify your email and phone

### Step 4: Create Meta App

1. Go to **My Apps** → **Create App**
2. Select use case: **Other**
3. App type: **Business**
4. Fill in:
   - **App name:** `Apollo-YourName` (any name)
   - **App contact email:** your email
   - **Business account:** select or create one
5. Click **Create app**

### Step 5: Add Instagram API

1. In your app dashboard, scroll to **"Add products to your app"**
2. Find **"Instagram"** or **"Instagram Graph API"**
3. Click **"Set up"**
4. If asked for use case, select: **"Manage messaging & content on Instagram"**

### Step 6: Configure Permissions

Required permissions:

- ✅ `instagram_business_basic`
- ✅ `instagram_business_content_publish`

Optional (for advanced features):

- `instagram_business_manage_comments`
- `instagram_business_manage_messages`

### Step 7: Add Yourself as Instagram Tester

1. Go to **App Roles** → **Instagram Testers** (or **Roles**)
2. Click **"Add Instagram Tester"**
3. Enter your Instagram username (e.g., `@yourusername`)
4. Click **Submit**

### Step 8: Accept Tester Invitation

**On Instagram:**

1. Open Instagram
2. Go to **Settings** → **Apps and Websites** → **Tester Invitations**
3. Accept the invitation from your Apollo app

**⚠️ Without accepting this, tokens won't work!**

### Step 9: Generate Access Token

1. Back in Meta Developer Console
2. Go to **Instagram API Setup** → **Generate Access Tokens**
3. Select your Instagram account
4. Click **Generate Token**
5. Authorize the app
6. **Copy** the access token (starts with `IGAA...`)

### Step 10: Get Business Account ID

Method 1 - From Instagram API Setup page:

- Your **Instagram Business Account ID** is displayed (e.g., `17841442678955842`)

Method 2 - Using Graph API Explorer:

1. Go to [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Query: `me/accounts?fields=id,name,instagram_business_account`
3. Find `instagram_business_account.id` in response

### Step 11: Get App Secret

1. In Meta App Dashboard → **App Settings** → **Basic**
2. Find **"App Secret"**
3. Click **"Show"** and enter your Facebook password
4. Copy the secret (32 characters)

### Step 12: Add to Apollo

**In Apollo:**

1. Open **Settings** (⚙️)
2. Find **📸 Instagram API** section
3. Fill in:
   - **Access Token:** paste your `IGAA...` token
   - **Business Account ID:** paste your account ID
   - **App Secret:** paste your app secret
4. Click **💾 Save all settings**
5. Click **"Test Instagram connection"** to verify

---

## 🧪 Test Your Setup

In Apollo Settings:

1. Fill in all Instagram fields
2. Click **"Test Instagram Connection"**
3. Should show: **"✓ connected as @yourusername"**

If test fails, see [Troubleshooting](#-troubleshooting) below.

---

## 📊 API Limits

### Development Mode (Default)

- ✅ **25 posts per day** per account
- ✅ **1000 requests per hour**
- ✅ Only test users can use the app

**Perfect for personal use.**

### Live Mode (for public apps)

Requires App Review process. Not needed for personal use.

---

## 🎥 Video Requirements

For Instagram Reels:

| Property     | Requirement                                |
| ------------ | ------------------------------------------ |
| Format       | MP4 (H.264 codec)                          |
| Aspect Ratio | 9:16 (vertical)                            |
| Resolution   | 720x1280 or higher (1080x1920 recommended) |
| Duration     | 3 seconds to 90 seconds                    |
| File Size    | Max 100 MB                                 |
| Frame Rate   | 23-60 FPS                                  |
| Audio        | AAC codec, 128 kbps                        |

Apollo automatically formats videos to meet these requirements.

---

## 🐛 Troubleshooting

### ❌ "Application does not have permission"

**Solution:**

1. Check permissions granted during OAuth
2. Ensure `instagram_business_content_publish` is enabled
3. Regenerate access token

### ❌ "The user is not an Instagram Business"

**Solution:**

1. Convert Instagram to Business/Creator account
2. Reconnect to Facebook Page
3. Wait 24 hours after conversion
4. Regenerate token

### ❌ "Invalid OAuth access token"

**Cause:** Token expired or revoked.

**Solution:**

1. Generate new token in Meta Developer Console
2. Update in Apollo Settings
3. Save settings

### ❌ "API access blocked"

**Causes:**

- IP address blocked by Meta
- Rate limit exceeded
- Account under review

**Solutions:**

1. Wait 15-30 minutes
2. Try without VPN
3. Check account status in Instagram
4. Regenerate token

### ❌ "The user has not accepted the invitation"

**Solution:**

1. Open Instagram app
2. Settings → Apps and Websites → **Tester Invitations**
3. Accept the invitation
4. Wait 5 minutes and try again

### ❌ Video upload fails

**Solutions:**

1. Ensure video meets [requirements](#-video-requirements)
2. Check Cloudinary is configured (Apollo needs it)
3. Try shorter video (under 60 seconds)
4. Verify video is not corrupted

---

## 🔒 Security Best Practices

- ✅ **Never share** your Access Token
- ✅ **Never share** your App Secret
- ✅ **Never commit** to Git repositories
- ✅ **Rotate tokens** every 60 days
- ✅ **Use long-lived tokens** for permanence
- ✅ **Revoke unused** apps regularly

### Extending Token Lifetime

Access tokens expire after 60 days. Apollo automatically exchanges short-lived tokens for long-lived ones.

Manual extension:

```
GET https://graph.instagram.com/access_token
?grant_type=ig_exchange_token
&client_secret={app-secret}
&access_token={short-lived-token}
```

---

## 📱 App Review (for Public Distribution)

**For personal use, Development Mode is enough.**

If you want to distribute Apollo publicly:

1. Complete Meta App Review process
2. Provide business verification documents
3. Submit permissions for review
4. Wait for approval (2-4 weeks)

Details: [Meta App Review](https://developers.facebook.com/docs/app-review)

---

## 📚 Additional Resources

- [Instagram Graph API Docs](https://developers.facebook.com/docs/instagram-api)
- [Meta for Developers](https://developers.facebook.com/)
- [Instagram Content Publishing](https://developers.facebook.com/docs/instagram-api/guides/content-publishing)
- [Rate Limits](https://developers.facebook.com/docs/graph-api/overview/rate-limiting)

---

## 💬 Need Help?

Contact us: **[@main_admin_tahasite](https://t.me/main_admin_tahasite)** on Telegram

**Response time:** Usually within 24 hours

---

<div align="center">
