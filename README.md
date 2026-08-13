# Apollo
<div align="center">

<img src="apollo.ico" width="120" alt="Apollo Logo"/>

# 🎬 Apollo

### Professional Video Editor & Auto Publisher

**Remove watermarks · Add branding · Generate AI captions · Auto publish to Instagram Reels & YouTube Shorts**

[![Version](https://img.shields.io/badge/version-2.0.0-blue)]()
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-brightgreen)]()
[![License](https://img.shields.io/badge/license-MIT-orange)]()
[![Telegram](https://img.shields.io/badge/support-@main__admin__tahasite-blue?logo=telegram)](https://t.me/main_admin_tahasite)

[Download](#-download) · [Features](#-features) · [Setup](#-quick-start) · [Documentation](#-documentation) · [Support](#-support)

</div>

---

## ✨ Features

- 🎭 **Smart Watermark Removal** — Paint over unwanted areas with inpainting
- 💧 **Custom Watermark Overlay** — Add your branding with drag & scale controls
- ✨ **AI Caption Generator** — Powered by Google Gemini, supports 14+ languages
- 📸 **Instagram Auto Publish** — Direct upload to Reels with hashtags
- ▶️ **YouTube Shorts Upload** — OAuth-based one-click publishing
- ⚡ **Video Enhancement** — Upscale and sharpen automatically
- 🌐 **Cross-Platform** — Windows desktop app + Android mobile app
- 🎨 **Modern UI** — Beautiful dark theme with smooth animations

---

## 📱 Screenshots

<div align="center">
<img src="docs/screenshots/dashboard.png" width="45%"/>
<img src="docs/screenshots/setup_wizard.png" width="45%"/>
</div>

---

## 📥 Download

### 🖥️ Windows

Download the latest installer from [**Releases**](../../releases/latest):
- `Apollo_Setup_2.0.0.exe` — Full installer with all dependencies

### 📱 Android

Download the APK from [**Releases**](../../releases/latest):
- `apollo-release.apk` — For all Android devices (API 24+)

---

## 🚀 Quick Start

### Windows Installation

1. Download `Apollo_Setup_2.0.0.exe` from Releases
2. Run the installer and follow the wizard
3. Launch Apollo from Desktop or Start Menu
4. Complete the setup wizard with your API keys

### Android Installation

1. Download `apollo-release.apk` from Releases
2. Enable "Install from unknown sources" in Android settings
3. Install the APK
4. Launch Apollo and complete setup

---

## 🔧 Building from Source

### Prerequisites

**For Windows (Python):**
- Python 3.11 ([download](https://www.python.org/downloads/release/python-3119/))
- FFmpeg ([download](https://ffmpeg.org/download.html))
- Inno Setup 6+ (optional, for installer) ([download](https://jrsoftware.org/isdl.php))

**For Android (Flutter):**
- Flutter SDK 3.19+ ([install](https://docs.flutter.dev/get-started/install))
- Android Studio ([download](https://developer.android.com/studio))
- Android SDK 36
- JDK 17

---

### 🖥️ Build Windows Version

```bash
# Clone the repo
git clone https://github.com/YOUR-USERNAME/apollo.git
cd apollo/windows

# Run auto installer
install.bat

# Or manually
python -m venv venv311
venv311\Scripts\activate
pip install -r requirements.txt

# Run in development
python app.py

# Build EXE
build.bat

# Build installer (requires Inno Setup)
"C:\Program Files (x86)\Inno Setup 6\Compil32.exe" /cc installer.iss
