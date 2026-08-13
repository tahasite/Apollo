<div align="center">

<img src="https://github.com/tahasite/Apollo/blob/main/Apollo.ico" width="120" alt="Apollo Logo"/>

# 🎬 Apollo

### Professional Video Editor & Auto Publisher

**Remove watermarks · Add branding · Generate AI captions · Auto publish to Instagram Reels & YouTube Shorts**

[![Version](https://img.shields.io/badge/version-2.0.0-blue)]()
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-brightgreen)]()
[![License](https://img.shields.io/badge/license-MIT-orange)]()
[![Python](https://img.shields.io/badge/python-3.11-yellow?logo=python)]()
[![Flutter](https://img.shields.io/badge/flutter-3.19+-blue?logo=flutter)]()
[![Telegram](https://img.shields.io/badge/support-@main__admin__tahasite-blue?logo=telegram)](https://t.me/main_admin_tahasite)

[Download](#-download) · [Features](#-features) · [Quick Start](#-quick-start) · [Documentation](#-documentation) · [Support](#-support)

</div>

---

## 📖 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Download](#-download)
- [Quick Start](#-quick-start)
- [Building from Source](#-building-from-source)
- [API Setup Guide](#-api-setup-guide)
- [Documentation](#-documentation)
- [How It Works](#-how-it-works)
- [Tech Stack](#-tech-stack)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)
- [Acknowledgments](#-acknowledgments)

---

## ✨ Features

### 🎨 Video Editing
- 🎭 **Smart Watermark Removal** — Paint over unwanted areas with intelligent inpainting
- 💧 **Custom Watermark Overlay** — Add your branding with drag & scale controls
- ⚡ **Video Enhancement** — Upscale and sharpen automatically
- 🎬 **Frame-perfect Preview** — See changes before rendering

### 🤖 AI-Powered Content
- ✨ **AI Caption Generator** — Powered by Google Gemini
- 🌍 **14+ Languages Support** — English, Persian, Arabic, Turkish, Spanish, French, German, Portuguese, Chinese, Japanese, Korean, Russian, Hindi, Indonesian
- 🏷️ **Smart Hashtag Generation** — SEO-optimized tags for each platform
- 📝 **Topic Identification** — Automatic content analysis

### 🚀 Publishing
- 📸 **Instagram Auto Publish** — Direct upload to Reels with captions & hashtags
- ▶️ **YouTube Shorts Upload** — OAuth-based one-click publishing
- 🔒 **Privacy Controls** — Choose between private, unlisted, or public
- 📊 **Publishing Logs** — Track every step of the upload process

### 💎 Experience
- 🎨 **Modern Dark UI** — Beautiful design with smooth animations
- 🌐 **Cross-Platform** — Windows desktop + Android mobile
- 🔧 **Setup Wizard** — Easy first-time configuration
- 📚 **In-App Tutorials** — Step-by-step guides for every API
- 🌍 **IP Checker** — Know your outgoing IP for API compatibility
- 💾 **Auto-Save** — Never lose your work

---

## 📱 Screenshots

<div align="center">

### 🖥️ Windows Version
<img src="docs/screenshots/windows_dashboard.png" width="80%"/>

### 📱 Android Version
<table>
<tr>
<td><img src="docs/screenshots/mobile_splash.png" width="200"/></td>
<td><img src="docs/screenshots/mobile_dashboard.png" width="200"/></td>
<td><img src="docs/screenshots/mobile_settings.png" width="200"/></td>
</tr>
<tr>
<td align="center">Splash Screen</td>
<td align="center">Dashboard</td>
<td align="center">Settings</td>
</tr>
</table>

</div>

---

## 📥 Download

### 🖥️ Windows

Download the latest installer from [**Releases**](../../releases/latest):

| File | Description | Size |
|------|-------------|------|
| `Apollo_Setup_2.0.0.exe` | Full installer with all dependencies | ~150 MB |

**System Requirements:**
- Windows 10 or 11 (64-bit)
- 4 GB RAM minimum (8 GB recommended)
- 500 MB free disk space
- Internet connection

### 📱 Android

Download the APK from [**Releases**](../../releases/latest):

| File | Best For | Size |
|------|----------|------|
| `apollo-arm64-v8a.apk` | Modern devices (recommended) | ~40 MB |
| `apollo-armeabi-v7a.apk` | Older 32-bit devices | ~35 MB |
| `apollo-x86_64.apk` | Emulators | ~45 MB |

**System Requirements:**
- Android 7.0 (API 24) or higher
- 2 GB RAM minimum
- 200 MB free storage
- Internet connection

---

## 🚀 Quick Start

### Windows Installation

1. **Download** `Apollo_Setup_2.0.0.exe` from Releases
2. **Run** the installer
3. **Choose** installation directory
4. **Select** shortcut options (Desktop / Start Menu)
5. **Launch** Apollo from Desktop or Start Menu
6. **Complete** the setup wizard with your API keys

### Android Installation

1. **Download** `apollo-arm64-v8a.apk` from Releases
2. **Enable** "Install from unknown sources" in Android settings
3. **Open** the downloaded APK file
4. **Install** and grant necessary permissions
5. **Launch** Apollo and complete setup wizard

### First-Time Setup

When you first open Apollo, a setup wizard will guide you through:

1. **Welcome** — Introduction to features
2. **Gemini AI** — Add your API key for AI content
3. **Instagram** — Configure your Business account (optional)
4. **Cloudinary** — Set up video hosting for Instagram
5. **YouTube** — Upload OAuth credentials
6. **Finish** — Review and start using Apollo

You can skip steps and configure them later from Settings.

---

## 🔧 Building from Source

### Prerequisites

**For Windows Development:**
- [Python 3.11](https://www.python.org/downloads/release/python-3119/)
- [Git](https://git-scm.com/downloads)
- [FFmpeg](https://ffmpeg.org/download.html) (add to PATH or place in project folder)
- [Inno Setup 6+](https://jrsoftware.org/isdl.php) (optional, for building installer)

**For Android Development:**
- [Flutter SDK 3.19+](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio)
- Android SDK 36
- [JDK 17](https://www.oracle.com/java/technologies/downloads/#java17)
- Android device or emulator (API 24+)

---

### 🖥️ Build Windows Version

#### Step 1: Clone the repository

```bash
git clone https://github.com/YOUR-USERNAME/apollo.git
cd apollo/windows
```

#### Step 2: Setup Python environment

**Using auto-installer (recommended):**
```bash
install.bat
```

**Or manually:**
```bash
python -m venv venv311
venv311\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
```

#### Step 3: Add FFmpeg

Download [FFmpeg](https://ffmpeg.org/download.html) and place `ffmpeg.exe` in the `windows` folder.

#### Step 4: Run in development

```bash
python app.py
```

#### Step 5: Build EXE

```bash
build.bat
```

Output: `dist/Apollo/Apollo.exe`

#### Step 6: Build Installer (optional)

```bash
"C:\Program Files (x86)\Inno Setup 6\Compil32.exe" /cc installer.iss
```

Output: `installer_output/Apollo_Setup_2.0.0.exe`

---

### 📱 Build Android Version

#### Step 1: Navigate to mobile folder

```bash
cd apollo/mobile
```

#### Step 2: Install Flutter dependencies

```bash
flutter pub get
```

#### Step 3: Verify Flutter setup

```bash
flutter doctor
```

Resolve any issues shown before proceeding.

#### Step 4: Run in development

Connect an Android device via USB (with USB debugging enabled) or start an emulator, then:

```bash
flutter run
```

#### Step 5: Build Release APK

**Split by ABI (recommended, smaller files):**
```bash
flutter build apk --release --split-per-abi
```

**Single APK (larger but universal):**
```bash
flutter build apk --release
```

**App Bundle for Play Store:**
```bash
flutter build appbundle --release
```

Output location: `build/app/outputs/flutter-apk/`

---

## 🔑 API Setup Guide

Apollo requires 4 API integrations. All are **free** for personal use.

| Service | Purpose | Required | Guide |
|---------|---------|----------|-------|
| 🤖 **Google Gemini** | AI captions & hashtags | Yes | [Setup Guide](docs/SETUP_GEMINI.md) |
| 📸 **Instagram** | Publish reels | Optional | [Setup Guide](docs/SETUP_INSTAGRAM.md) |
| ☁️ **Cloudinary** | Video hosting (for Instagram) | Optional | [Setup Guide](docs/SETUP_CLOUDINARY.md) |
| ▶️ **YouTube** | Upload shorts | Optional | [Setup Guide](docs/SETUP_YOUTUBE.md) |

### Quick Overview

<details>
<summary><b>🤖 Google Gemini AI (2 minutes)</b></summary>

1. Visit [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Sign in with Google account
3. Click "Create API key"
4. Copy the key (starts with `AIzaSy...`)
5. Paste in Apollo Settings → Gemini AI

**Free tier:** 1500 requests/day - more than enough for personal use
</details>

<details>
<summary><b>📸 Instagram API (10 minutes)</b></summary>

**Requirements:**
- Instagram Business or Creator account
- Facebook Page connected to Instagram
- Meta Developer account

**Steps:**
1. Create Meta App at [developers.facebook.com](https://developers.facebook.com/)
2. Add Instagram API use case
3. Add yourself as Instagram Tester
4. Generate Access Token
5. Copy: Access Token, Business Account ID, App Secret

See [full guide](docs/SETUP_INSTAGRAM.md) for detailed steps.
</details>

<details>
<summary><b>☁️ Cloudinary (3 minutes)</b></summary>

1. Sign up free at [cloudinary.com](https://cloudinary.com/)
2. Go to Dashboard
3. Copy: Cloud Name, API Key, API Secret
4. Paste in Apollo Settings → Cloudinary

**Free tier:** 25 GB storage + 25 GB bandwidth/month
</details>

<details>
<summary><b>▶️ YouTube API (10 minutes)</b></summary>

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project
3. Enable YouTube Data API v3
4. Configure OAuth Consent Screen
5. Add yourself as Test User
6. Create OAuth Client (Desktop app for Windows, Android for mobile)
7. Download JSON file
8. Upload in Apollo Settings → YouTube

See [full guide](docs/SETUP_YOUTUBE.md) for detailed steps.
</details>

---

## 📖 Documentation

### User Guides
- [Windows User Guide](docs/WINDOWS_GUIDE.md)
- [Android User Guide](docs/ANDROID_GUIDE.md)

### API Setup
- [Gemini AI Setup](docs/SETUP_GEMINI.md)
- [Instagram Setup](docs/SETUP_INSTAGRAM.md)
- [Cloudinary Setup](docs/SETUP_CLOUDINARY.md)
- [YouTube Setup](docs/SETUP_YOUTUBE.md)

### Developer
- [Development Guide](docs/DEVELOPMENT.md)
- [Contributing](docs/CONTRIBUTING.md)
- [Architecture](docs/ARCHITECTURE.md)

### Reference
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

---

## 💡 How It Works

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│ Video File  │───▶│ Mask Editor  │───▶│  Watermark   │
└─────────────┘    └──────────────┘    └──────────────┘
                                              │
                                              ▼
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│  Instagram  │◀───│   Publish    │◀───│    Render    │
│   YouTube   │    │              │    │              │
└─────────────┘    └──────────────┘    └──────────────┘
                          ▲
                          │
                   ┌──────────────┐
                   │  AI Content  │
                   │  (Gemini)    │
                   └──────────────┘
```

### Workflow

1. **Import Video** — Select video file from device
2. **Mask Editor** *(optional)* — Paint over watermarks or unwanted objects
3. **Watermark** *(optional)* — Add your branding image with drag & scale
4. **Render** — Process video with mask removal + watermark + enhancement
5. **AI Generate** *(optional)* — Get captions and hashtags in your language
6. **Publish** — One-click upload to Instagram Reels or YouTube Shorts

---

## 🛠️ Tech Stack

### Windows Version
| Technology | Purpose |
|------------|---------|
| Python 3.11 | Core language |
| CustomTkinter | Modern UI framework |
| OpenCV | Video/image processing |
| FFmpeg | Video encoding |
| SQLite | Project storage |
| PyInstaller | Executable packaging |
| Inno Setup | Installer creation |

### Android Version
| Technology | Purpose |
|------------|---------|
| Flutter 3.19+ | Cross-platform framework |
| Dart 3 | Programming language |
| Provider | State management |
| SQLite | Local database |
| Video Compress | Video processing |
| Google Sign-In | YouTube OAuth |

### APIs & Services
| Service | Usage |
|---------|-------|
| Google Gemini AI | Content generation |
| Instagram Graph API | Reel publishing |
| YouTube Data API v3 | Video upload |
| Cloudinary | Media hosting |
| IP-API | Location detection |

---

## 🐛 Troubleshooting

### Windows Issues

<details>
<summary><b>❌ "API access blocked" from Instagram</b></summary>

**Causes:**
- Instagram/Meta has blocked your current IP
- Token expired or invalid
- Rate limit reached

**Solutions:**
1. Regenerate Instagram Access Token
2. Wait 15 minutes and try again
3. Try without VPN/proxy
4. Verify Business Account ID is correct
5. Check if account is Business/Creator type
</details>

<details>
<summary><b>❌ "youtube_client_secret.json not found"</b></summary>

**Solution:**
1. Download OAuth JSON from Google Cloud Console
2. Go to Apollo Settings → YouTube
3. Click "Select client secret json"
4. Choose the downloaded file
</details>

<details>
<summary><b>❌ Rendering fails with FFmpeg error</b></summary>

**Solutions:**
1. Ensure `ffmpeg.exe` is in the Apollo installation folder
2. Try a shorter video (under 60 seconds)
3. Check available disk space (need 2-3x video size)
4. Verify video codec is supported (mp4 recommended)
</details>

<details>
<summary><b>❌ Python 3.14 detected error</b></summary>

**Solution:**
Apollo requires Python 3.11. Install it from:
[Python 3.11 Download](https://www.python.org/downloads/release/python-3119/)

Ensure `venv311` uses Python 3.11 with:
```bash
py -3.11 -m venv venv311
```
</details>

### Android Issues

<details>
<summary><b>❌ Google Sign-In error 10 (DEVELOPER_ERROR)</b></summary>

**Cause:** SHA-1 fingerprint not registered

**Solution:**
1. Get SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy the SHA1 from "Variant: debug"
3. Add to Google Cloud Console → Credentials → OAuth Android client
4. Package name: `com.tahasite.apollo`
</details>

<details>
<summary><b>❌ App crashes on startup</b></summary>

**Solutions:**
1. Ensure Android version is 7.0+ (API 24+)
2. Clear app data and cache
3. Reinstall the APK
4. Check if all permissions are granted
</details>

<details>
<summary><b>❌ Video rendering takes too long</b></summary>

**Solutions:**
- Use shorter videos (under 60 seconds recommended)
- Close other apps to free RAM
- Use a device with better specs
- Reduce video quality/resolution
</details>

### Common Issues

<details>
<summary><b>❌ AI generation fails</b></summary>

**Solutions:**
1. Verify Gemini API key is valid
2. Check internet connection
3. Try a different Gemini model
4. Add multiple API keys for rotation
5. Check daily quota (1500 requests/day free)
</details>

<details>
<summary><b>❌ Cloudinary upload fails</b></summary>

**Solutions:**
1. Verify Cloud Name, API Key, API Secret
2. Check monthly bandwidth usage
3. Ensure video is under 100 MB
4. Try smaller video first
</details>

---

## 🗺️ Roadmap

### Version 2.1 (Q4 2026)
- [ ] TikTok publishing support
- [ ] Twitter/X video upload
- [ ] Scheduled posting
- [ ] Multiple watermarks per video

### Version 2.2 (Q1 2027)
- [ ] Video trimming/cutting
- [ ] Audio replacement
- [ ] Text overlay editor
- [ ] Filter presets

### Version 3.0 (Q2 2027)
- [ ] macOS support
- [ ] iOS support
- [ ] Batch processing
- [ ] Cloud sync across devices
- [ ] Team collaboration

### Community Requests
Vote on features in [Discussions](../../discussions) or [suggest new ones](../../issues/new)!

---

## 🤝 Contributing

Contributions are welcome and greatly appreciated! Every contribution helps make Apollo better.

### How to Contribute

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Types of Contributions

- 🐛 **Bug Reports** — [Open an issue](../../issues/new?template=bug_report.md)
- 💡 **Feature Requests** — [Suggest ideas](../../issues/new?template=feature_request.md)
- 📖 **Documentation** — Improve docs and guides
- 🌍 **Translations** — Help translate the app
- 💻 **Code** — Submit pull requests
- ⭐ **Star** the repo to show support

### Development Guidelines

- Follow existing code style
- Write clear commit messages
- Update documentation for new features
- Test on both Windows and Android
- Ensure no sensitive data is committed

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for detailed guidelines.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

### What this means:

✅ **You can:**
- Use commercially
- Modify
- Distribute
- Use privately

⚠️ **You must:**
- Include the license
- Include copyright notice

❌ **No warranty:**
- The software is provided "as is"

---

## 💬 Support

Need help? Have questions? Want to request features?

<div align="center">

### 📞 Contact & Support

[![Telegram](https://img.shields.io/badge/Telegram-@main__admin__tahasite-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/main_admin_tahasite)

**Direct Contact:** [@main_admin_tahasite](https://t.me/main_admin_tahasite)

**Response Time:** Usually within 24 hours

</div>

### Getting Help

- 📚 Check the [Documentation](docs/) first
- 🔍 Search [existing issues](../../issues)
- 💬 Ask in [Discussions](../../discussions)
- 🐛 [Report bugs](../../issues/new?template=bug_report.md)
- 💡 [Request features](../../issues/new?template=feature_request.md)
- 📱 Contact directly: [@main_admin_tahasite](https://t.me/main_admin_tahasite)

### Support the Project

If Apollo helped you, please:

- ⭐ **Star** this repository
- 🐦 **Share** on social media
- 📝 **Write** about your experience
- 🤝 **Contribute** code or documentation
- 💬 **Tell** your friends

---

## ⭐ Acknowledgments

Special thanks to:

- [Google Gemini](https://ai.google.dev/) — AI content generation
- [Meta for Developers](https://developers.facebook.com/) — Instagram Graph API
- [YouTube API](https://developers.google.com/youtube) — Video upload capability
- [Cloudinary](https://cloudinary.com/) — Media hosting service
- [FFmpeg](https://ffmpeg.org/) — Video processing engine
- [Flutter](https://flutter.dev/) — Cross-platform framework
- [CustomTkinter](https://customtkinter.tomschimansky.com/) — Modern Python UI
- [OpenCV](https://opencv.org/) — Computer vision library

### Contributors

<!-- ALL-CONTRIBUTORS-LIST:START -->
<a href="../../graphs/contributors">
  <img src="https://contrib.rocks/image?repo=YOUR-USERNAME/apollo" />
</a>
<!-- ALL-CONTRIBUTORS-LIST:END -->

Thanks to all our amazing contributors! 🎉

---

## 📊 Stats

<div align="center">

![GitHub stars](https://img.shields.io/github/stars/YOUR-USERNAME/apollo?style=social)
![GitHub forks](https://img.shields.io/github/forks/YOUR-USERNAME/apollo?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/YOUR-USERNAME/apollo?style=social)

![GitHub issues](https://img.shields.io/github/issues/YOUR-USERNAME/apollo)
![GitHub pull requests](https://img.shields.io/github/issues-pr/YOUR-USERNAME/apollo)
![GitHub last commit](https://img.shields.io/github/last-commit/YOUR-USERNAME/apollo)

![GitHub downloads](https://img.shields.io/github/downloads/YOUR-USERNAME/apollo/total)
![GitHub release](https://img.shields.io/github/v/release/YOUR-USERNAME/apollo)

</div>

---

## 🔐 Security

Found a security vulnerability? Please **do not** open a public issue.

Contact directly: [@main_admin_tahasite](https://t.me/main_admin_tahasite)

We take security seriously and will respond promptly to any reports.

### Security Best Practices

- 🔒 Never share your API keys
- 🔒 Never commit `config.json` or token files
- 🔒 Use strong passwords for your accounts
- 🔒 Enable 2FA on Google, Meta, and other accounts
- 🔒 Regularly rotate your API keys

---

## 📱 Follow the Project

Stay updated with the latest news, features, and releases:

- 💬 **Telegram:** [@main_admin_tahasite](https://t.me/main_admin_tahasite)
- ⭐ **GitHub:** Star this repository
- 👁️ **Watch:** Get notified of new releases

---

## 🎯 FAQ

<details>
<summary><b>Is Apollo free?</b></summary>

Yes! Apollo is 100% free and open-source. All required APIs offer generous free tiers.
</details>

<details>
<summary><b>Do I need a paid subscription?</b></summary>

No. Google Gemini, Instagram, YouTube, and Cloudinary all provide free tiers that are sufficient for personal use.
</details>

<details>
<summary><b>Can I use it commercially?</b></summary>

Yes, the MIT license allows commercial use. However, ensure you comply with each platform's API terms of service.
</details>

<details>
<summary><b>Is my data safe?</b></summary>

Yes. Apollo runs entirely on your device. Your API keys and videos never leave your computer/phone except when uploading to your own accounts.
</details>

<details>
<summary><b>Does Apollo work offline?</b></summary>

Partially. Video editing works offline, but AI generation and publishing require internet.
</details>

<details>
<summary><b>Can I request custom features?</b></summary>

Yes! Open an issue or contact [@main_admin_tahasite](https://t.me/main_admin_tahasite) on Telegram.
</details>

<details>
<summary><b>How do I update Apollo?</b></summary>

Check the [Releases](../../releases) page for new versions. Download and install the latest version.
</details>

<details>
<summary><b>Will there be an iOS version?</b></summary>

Planned for Version 3.0 (Q2 2027). Contributions welcome!
</details>

---

<div align="center">

### 🌟 Made with ❤️ by [tahasite](https://t.me/main_admin_tahasite)

**If Apollo helped you, please give it a ⭐ on GitHub!**

[⬆ Back to Top](#-apollo)

</div>
