import os
import json
import shutil
import customtkinter as ctk
from tkinter import filedialog, messagebox
from core.config_manager import ConfigManager, DEFAULT_MODEL_NAME, YOUTUBE_SECRET_FILE, APP_NAME, APP_VERSION, APP_AUTHOR
from core.ui_helpers import AnimationHelper, InteractiveWidgetHelper, APP_FONT

APP_VERSION = "2.0.0"


class TutorialWindow(ctk.CTkToplevel):
    def __init__(self, parent):
        super().__init__(parent)
        self.title("tutorials and guides")
        self.geometry("820x650")
        self.transient(parent)
        self.grab_set()
        tabs = ctk.CTkTabview(self)
        tabs.pack(fill="both", expand=True, padx=16, pady=16)
        self.build_gemini_tab(tabs.add("gemini ai"))
        self.build_instagram_tab(tabs.add("instagram"))
        self.build_cloudinary_tab(tabs.add("cloudinary"))
        self.build_youtube_tab(tabs.add("youtube"))
        InteractiveWidgetHelper.register_inputs(self)

    def add_guide_text(self, parent, text):
        textbox = ctk.CTkTextbox(parent, font=("Consolas", 13), wrap="word")
        textbox.pack(fill="both", expand=True, padx=10, pady=10)
        textbox.insert("1.0", text)
        textbox.configure(state="disabled")

    def build_gemini_tab(self, tab):
        guide = """GEMINI AI API KEY SETUP GUIDE
========================================

gemini is the ai engine used to generate captions, hashtags,
and social media content for your videos.

STEP 1: GO TO GOOGLE AI STUDIO
  open your browser and navigate to:
  https://aistudio.google.com/apikey

STEP 2: SIGN IN
  sign in with your google account.

STEP 3: CREATE API KEY
  click "create api key" button.
  select or create a google cloud project.
  copy the generated api key.

STEP 4: PASTE IN APP
  go to settings > gemini api keys.
  paste your key. one key per line.
  you can add multiple keys for rotation.

MODEL SELECTION:
  default model: gemini-2.0-flash-lite
  you can change the model in settings.
  browse available models at:
  https://ai.google.dev/gemini-api/docs/models

TIPS:
  - free tier has generous limits.
  - add 2-3 keys for uninterrupted usage.
  - the app rotates keys automatically on errors.
  - if a key hits rate limit, the next key is used."""
        self.add_guide_text(tab, guide)

    def build_instagram_tab(self, tab):
        guide = """INSTAGRAM API SETUP GUIDE
========================================

to publish reels automatically, you need an instagram
business or creator account connected to meta api.

PREREQUISITES:
  1. instagram business or creator account
     (personal accounts do not support api publishing)
  2. facebook page connected to instagram account
  3. meta developer account at:
     https://developers.facebook.com/

STEP 1: CREATE META APP
  go to: https://developers.facebook.com/
  click: my apps > create app
  select: business
  name your app (example: AutoPoster-IG)

STEP 2: ADD INSTAGRAM API
  in app dashboard > use cases
  select: content management
  add: manage messaging & content on instagram

STEP 3: CONFIGURE PERMISSIONS
  required permissions:
    instagram_business_basic
    instagram_business_content_publish

STEP 4: ADD INSTAGRAM TESTER
  go to: app > roles > instagram testers
  click: add instagram tester
  enter your instagram username

  IMPORTANT: accept the invitation in instagram:
  instagram > settings > apps and websites > tester invitations

STEP 5: GENERATE ACCESS TOKEN
  go to: instagram api setup > generate access tokens
  select your instagram account
  you will receive:
    - instagram username
    - instagram business account id
    - access token

STEP 6: PASTE IN APP
  go to settings and enter:
    - access token
    - instagram business account id
    - app secret (found in app settings > basic)

NOTES:
  - development mode is fine for personal use.
  - access token may expire. regenerate if errors occur.
  - app secret is found in meta app > settings > basic.
  - never share your access token or app secret."""
        self.add_guide_text(tab, guide)

    def build_cloudinary_tab(self, tab):
        guide = """CLOUDINARY SETUP GUIDE
========================================

cloudinary is used as a temporary video hosting service.
instagram api requires a public url to fetch your video.
cloudinary provides this url.

the video is automatically deleted after publishing.

STEP 1: CREATE FREE ACCOUNT
  go to: https://cloudinary.com/
  click: sign up for free
  create your account.

STEP 2: GET CREDENTIALS
  after login, go to: dashboard
  you will see:
    - cloud name
    - api key
    - api secret

STEP 3: PASTE IN APP
  go to settings and enter:
    - cloud name
    - api key
    - api secret

FREE TIER LIMITS:
  - 25 gb storage
  - 25 gb bandwidth per month
  - more than enough for reel publishing

NOTES:
  - videos are uploaded temporarily.
  - the app deletes them after instagram fetches the video.
  - no manual cleanup needed."""
        self.add_guide_text(tab, guide)

    def build_youtube_tab(self, tab):
        guide = """YOUTUBE API SETUP GUIDE
========================================

youtube uses oauth2 for authentication.
you need a client secret json file from google cloud console.

STEP 1: GO TO GOOGLE CLOUD CONSOLE
  open: https://console.cloud.google.com/
  sign in with the google account that owns your youtube channel.

STEP 2: CREATE A PROJECT
  click: select a project > new project
  name it (example: youtube-auto-upload)
  click: create

STEP 3: ENABLE YOUTUBE DATA API V3
  go to: apis & services > library
  search: youtube data api v3
  click on it and click: enable

STEP 4: CONFIGURE OAUTH CONSENT SCREEN
  go to: apis & services > oauth consent screen
  (or: google auth platform > branding)

  fill in:
    app name: Smart Video Editor
    user support email: your email
    developer contact email: your email
  save.

STEP 5: ADD TEST USER
  go to: google auth platform > audience
  (or: oauth consent screen > test users)
  click: add users
  enter your youtube channel email.
  save.

STEP 6: CREATE OAUTH CLIENT
  go to: apis & services > credentials
  click: create credentials > oauth client id

  application type: DESKTOP APP (important!)
  name: YouTube Auto Upload Client
  click: create

STEP 7: DOWNLOAD JSON FILE
  click on the oauth client you created.
  click: download json

  in this app, click "select youtube client secret json file"
  the app will copy and rename it automatically.

STEP 8: CONNECT YOUR ACCOUNT
  go to the publish page in the app.
  click: connect youtube account
  your browser will open for authentication.
  sign in and allow access.
  the token is saved automatically.

PERMISSION REQUIRED:
  https://www.googleapis.com/auth/youtube.upload

YOUTUBE SHORTS REQUIREMENTS:
  format: mp4
  aspect ratio: 9:16
  resolution: 1080x1920
  duration: under 3 minutes

COMMON ERRORS:

  "access blocked: this app's request is invalid"
    -> make sure oauth client type is: desktop app

  "403 access_denied"
    -> add your email to test users

  "youtube data api has not been used"
    -> enable the api in google cloud console

NOTES:
  - testing mode is fine for personal use.
  - token refreshes automatically.
  - no need to re-authenticate each time."""
        self.add_guide_text(tab, guide)


class SetupWizard(ctk.CTkToplevel):
    def __init__(self, parent, config_data, on_complete):
        super().__init__(parent)
        self.title("welcome to Apollo")
        self.geometry("750x620")
        self.resizable(False, False)
        self.transient(parent)
        self.grab_set()
        self.config_data = config_data
        self.on_complete = on_complete
        self.current_step = 0
        self.steps = []
        self.container = ctk.CTkFrame(self, fg_color="transparent")
        self.container.pack(fill="both", expand=True, padx=30, pady=20)
        self.step_container = ctk.CTkFrame(self.container, fg_color="transparent")
        self.step_container.pack(fill="both", expand=True)
        self.nav_frame = ctk.CTkFrame(self.container, fg_color="transparent", height=60)
        self.nav_frame.pack(fill="x", pady=(10, 0))
        self.btn_back = ctk.CTkButton(self.nav_frame, text="back", font=(APP_FONT, 14), width=120, command=self.go_back, state="disabled", fg_color="gray30", hover_color="gray40")
        self.btn_back.pack(side="left", padx=(0, 10))
        self.lbl_step_indicator = ctk.CTkLabel(self.nav_frame, text="", font=(APP_FONT, 13), text_color="gray70")
        self.lbl_step_indicator.pack(side="left", expand=True)
        self.btn_next = ctk.CTkButton(self.nav_frame, text="next", font=(APP_FONT, 15, "bold"), width=140, command=self.go_next, fg_color="#2563eb", hover_color="#1d4ed8")
        self.btn_next.pack(side="right")
        self.btn_tutorial = ctk.CTkButton(self.nav_frame, text="tutorial", font=(APP_FONT, 14), width=120, command=self.open_tutorial, fg_color="#8b5cf6", hover_color="#6d28d9")
        self.btn_tutorial.pack(side="right", padx=(0, 10))
        self.build_steps()
        self.show_step(0)
        self.protocol("WM_DELETE_WINDOW", self.on_close)

    def build_steps(self):
        self.steps = [
            self.build_welcome_step,
            self.build_gemini_step,
            self.build_instagram_step,
            self.build_cloudinary_step,
            self.build_youtube_step,
            self.build_finish_step
        ]

    def clear_step_container(self):
        for child in self.step_container.winfo_children():
            child.destroy()

    def show_step(self, index):
        self.current_step = index
        self.clear_step_container()
        self.steps[index]()
        total = len(self.steps)
        self.lbl_step_indicator.configure(text=f"step {index + 1} of {total}")
        self.btn_back.configure(state="normal" if index > 0 else "disabled")
        if index == total - 1:
            self.btn_next.configure(text="finish setup")
        else:
            self.btn_next.configure(text="next")
        InteractiveWidgetHelper.register_inputs(self.step_container)
        AnimationHelper.fade_in_widget(self.step_container)

    def go_next(self):
        self.save_current_step_data()
        if self.current_step < len(self.steps) - 1:
            self.show_step(self.current_step + 1)
        else:
            self.finish_setup()

    def go_back(self):
        self.save_current_step_data()
        if self.current_step > 0:
            self.show_step(self.current_step - 1)

    def save_current_step_data(self):
        if self.current_step == 1:
            if hasattr(self, "wiz_gemini_keys"):
                keys_text = self.wiz_gemini_keys.get("1.0", "end").strip()
                self.config_data["gemini_api_keys"] = ConfigManager.normalize_api_keys(keys_text)
            if hasattr(self, "wiz_gemini_model"):
                model = self.wiz_gemini_model.get().strip()
                self.config_data["gemini_model"] = model if model else DEFAULT_MODEL_NAME
        elif self.current_step == 2:
            if hasattr(self, "wiz_ig_token"):
                self.config_data["instagram_access_token"] = self.wiz_ig_token.get("1.0", "end").strip()
            if hasattr(self, "wiz_ig_user_id"):
                self.config_data["instagram_user_id"] = self.wiz_ig_user_id.get().strip()
            if hasattr(self, "wiz_ig_app_secret"):
                self.config_data["instagram_app_secret"] = self.wiz_ig_app_secret.get().strip()
        elif self.current_step == 3:
            if hasattr(self, "wiz_cloud_name"):
                self.config_data["cloudinary_cloud_name"] = self.wiz_cloud_name.get().strip()
            if hasattr(self, "wiz_cloud_key"):
                self.config_data["cloudinary_api_key"] = self.wiz_cloud_key.get().strip()
            if hasattr(self, "wiz_cloud_secret"):
                self.config_data["cloudinary_api_secret"] = self.wiz_cloud_secret.get().strip()

    def build_welcome_step(self):
        f = self.step_container
        lbl_emoji = ctk.CTkLabel(f, text="🎬", font=(APP_FONT, 72))
        lbl_emoji.pack(pady=(20, 8))
        lbl_title = ctk.CTkLabel(f, text="", font=(APP_FONT, 30, "bold"))
        lbl_title.pack(pady=(0, 6))
        AnimationHelper.typewriter_label(lbl_title, f"welcome to {APP_NAME}", speed=40)
        desc_text = (
            f"{APP_NAME} is a professional video editing and publishing tool.\n\n"
            "features:\n"
            "  •  remove watermarks from video clips\n"
            "  •  add your own custom watermark\n"
            "  •  generate ai captions and hashtags\n"
            "  •  publish directly to instagram reels\n"
            "  •  upload to youtube shorts\n"
            "  •  upscale and enhance video quality\n\n"
            "this setup wizard will help you configure\n"
            "the required api keys and services."
        )
        ctk.CTkLabel(f, text=desc_text, font=(APP_FONT, 14), text_color="gray80", justify="left", anchor="w").pack(fill="x", padx=40, pady=(0, 14))
        bottom = ctk.CTkFrame(f, fg_color="transparent")
        bottom.pack(fill="x", padx=40, pady=(6, 0))
        ctk.CTkLabel(bottom, text=f"v{APP_VERSION}", font=(APP_FONT, 12), text_color="gray60").pack(side="left")
        ctk.CTkLabel(bottom, text=f"crafted with ❤️ by {APP_AUTHOR}", font=(APP_FONT, 11), text_color="gray50").pack(side="right")

    def build_gemini_step(self):
        f = self.step_container
        ctk.CTkLabel(f, text="🤖  gemini ai configuration", font=(APP_FONT, 22, "bold")).pack(anchor="w", padx=20, pady=(20, 6))
        ctk.CTkLabel(f, text="add your google gemini api keys. one key per line.\nmultiple keys enable automatic rotation on errors.", font=(APP_FONT, 13), text_color="gray80", justify="left").pack(anchor="w", padx=20, pady=(0, 10))
        ctk.CTkLabel(f, text="get your api key from: https://aistudio.google.com/apikey", font=(APP_FONT, 12), text_color="#22d3ee").pack(anchor="w", padx=20, pady=(0, 10))
        ctk.CTkLabel(f, text="api keys", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_gemini_keys = ctk.CTkTextbox(f, height=120, font=("Consolas", 13))
        self.wiz_gemini_keys.pack(fill="x", padx=20, pady=(0, 12))
        existing_keys = self.config_data.get("gemini_api_keys", [])
        if existing_keys:
            self.wiz_gemini_keys.insert("1.0", "\n".join(existing_keys))
        ctk.CTkLabel(f, text="model name", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_gemini_model = ctk.CTkEntry(f, font=(APP_FONT, 14))
        self.wiz_gemini_model.pack(fill="x", padx=20, pady=(0, 6))
        current_model = self.config_data.get("gemini_model", DEFAULT_MODEL_NAME) or DEFAULT_MODEL_NAME
        self.wiz_gemini_model.insert(0, current_model)
        ctk.CTkLabel(f, text=f"default: {DEFAULT_MODEL_NAME}\nbrowse models: https://ai.google.dev/gemini-api/docs/models", font=(APP_FONT, 12), text_color="gray60", justify="left").pack(anchor="w", padx=20, pady=(0, 10))

    def build_instagram_step(self):
        f = self.step_container
        ctk.CTkLabel(f, text="📸  instagram api configuration", font=(APP_FONT, 22, "bold")).pack(anchor="w", padx=20, pady=(20, 6))
        ctk.CTkLabel(f, text="configure your instagram business account for reel publishing.\nthis is optional. you can skip and configure later in settings.", font=(APP_FONT, 13), text_color="gray80", justify="left").pack(anchor="w", padx=20, pady=(0, 14))
        ctk.CTkLabel(f, text="access token", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_ig_token = ctk.CTkTextbox(f, height=70, font=("Consolas", 12))
        self.wiz_ig_token.pack(fill="x", padx=20, pady=(0, 10))
        existing_token = self.config_data.get("instagram_access_token", "")
        if existing_token:
            self.wiz_ig_token.insert("1.0", existing_token)
        ctk.CTkLabel(f, text="instagram business account id", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_ig_user_id = ctk.CTkEntry(f, font=(APP_FONT, 14))
        self.wiz_ig_user_id.pack(fill="x", padx=20, pady=(0, 10))
        existing_uid = self.config_data.get("instagram_user_id", "")
        if existing_uid:
            self.wiz_ig_user_id.insert(0, existing_uid)
        ctk.CTkLabel(f, text="app secret", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_ig_app_secret = ctk.CTkEntry(f, font=(APP_FONT, 14), show="•")
        self.wiz_ig_app_secret.pack(fill="x", padx=20, pady=(0, 10))
        existing_secret = self.config_data.get("instagram_app_secret", "")
        if existing_secret:
            self.wiz_ig_app_secret.insert(0, existing_secret)

    def build_cloudinary_step(self):
        f = self.step_container
        ctk.CTkLabel(f, text="☁️  cloudinary configuration", font=(APP_FONT, 22, "bold")).pack(anchor="w", padx=20, pady=(20, 6))
        ctk.CTkLabel(f, text="cloudinary is used as a temporary video host for instagram publishing.\ninstagram api requires a public url to fetch your video.\nfree tier: https://cloudinary.com/", font=(APP_FONT, 13), text_color="gray80", justify="left").pack(anchor="w", padx=20, pady=(0, 14))
        ctk.CTkLabel(f, text="cloud name", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_cloud_name = ctk.CTkEntry(f, font=(APP_FONT, 14))
        self.wiz_cloud_name.pack(fill="x", padx=20, pady=(0, 10))
        existing = self.config_data.get("cloudinary_cloud_name", "")
        if existing:
            self.wiz_cloud_name.insert(0, existing)
        ctk.CTkLabel(f, text="api key", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_cloud_key = ctk.CTkEntry(f, font=(APP_FONT, 14))
        self.wiz_cloud_key.pack(fill="x", padx=20, pady=(0, 10))
        existing = self.config_data.get("cloudinary_api_key", "")
        if existing:
            self.wiz_cloud_key.insert(0, existing)
        ctk.CTkLabel(f, text="api secret", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(6, 4))
        self.wiz_cloud_secret = ctk.CTkEntry(f, font=(APP_FONT, 14), show="•")
        self.wiz_cloud_secret.pack(fill="x", padx=20, pady=(0, 10))
        existing = self.config_data.get("cloudinary_api_secret", "")
        if existing:
            self.wiz_cloud_secret.insert(0, existing)

    def build_youtube_step(self):
        f = self.step_container
        ctk.CTkLabel(f, text="▶️  youtube api configuration", font=(APP_FONT, 22, "bold")).pack(anchor="w", padx=20, pady=(20, 6))
        ctk.CTkLabel(f, text="youtube uses oauth2 for authentication.\nyou need a client secret json file from google cloud console.\nclick the button below to select your json file.", font=(APP_FONT, 13), text_color="gray80", justify="left").pack(anchor="w", padx=20, pady=(0, 14))
        if os.path.exists(YOUTUBE_SECRET_FILE):
            self.lbl_wiz_yt_file = ctk.CTkLabel(f, text="youtube_client_secret.json found ✓", font=(APP_FONT, 13), text_color="#86efac")
        else:
            self.lbl_wiz_yt_file = ctk.CTkLabel(f, text="no file selected", font=(APP_FONT, 13), text_color="gray60")
        self.lbl_wiz_yt_file.pack(anchor="w", padx=20, pady=(0, 10))
        ctk.CTkButton(f, text="select youtube client secret json file", font=(APP_FONT, 14), command=self.pick_youtube_json, height=42, fg_color="#dc2626", hover_color="#b91c1c").pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(f, text="after selecting the file, the app will copy and rename it automatically.\nyou will authenticate your youtube account later from the publish page.", font=(APP_FONT, 12), text_color="gray60", justify="left").pack(anchor="w", padx=20, pady=(0, 10))

    def pick_youtube_json(self):
        file_path = filedialog.askopenfilename(
            title="Select YouTube Client Secret JSON",
            filetypes=[("JSON Files", "*.json")],
            parent=self
        )
        if file_path:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if "installed" not in data and "web" not in data:
                    messagebox.showwarning("Invalid File", "This does not look like a valid Google OAuth client secret file.", parent=self)
                    return
                shutil.copy2(file_path, YOUTUBE_SECRET_FILE)
                if "installed" in data:
                    client_info = data["installed"]
                elif "web" in data:
                    client_info = data["web"]
                else:
                    client_info = {}
                self.config_data["youtube_client_id"] = client_info.get("client_id", "")
                self.config_data["youtube_client_secret"] = client_info.get("client_secret", "")
                self.config_data["youtube_json_path"] = YOUTUBE_SECRET_FILE
                self.lbl_wiz_yt_file.configure(text=f"file loaded: {os.path.basename(file_path)} ✓", text_color="#86efac")
                AnimationHelper.pulse_button(self.btn_next)
            except Exception as e:
                messagebox.showerror("File Error", f"could not read json file:\n{str(e)}", parent=self)

    def build_finish_step(self):
        f = self.step_container
        ctk.CTkLabel(f, text="✅", font=(APP_FONT, 64)).pack(pady=(30, 10))
        lbl_done = ctk.CTkLabel(f, text="", font=(APP_FONT, 26, "bold"))
        lbl_done.pack(pady=(0, 16))
        AnimationHelper.typewriter_label(lbl_done, "setup complete!", speed=50)
        gemini_ok = len(ConfigManager.normalize_api_keys(self.config_data.get("gemini_api_keys", []))) > 0
        ig_ok = bool(self.config_data.get("instagram_access_token", "").strip() and self.config_data.get("instagram_user_id", "").strip())
        cloud_ok = bool(self.config_data.get("cloudinary_cloud_name", "").strip() and self.config_data.get("cloudinary_api_key", "").strip())
        yt_ok = os.path.exists(YOUTUBE_SECRET_FILE)
        status_lines = [
            f"{'✅' if gemini_ok else '⚠️'}  gemini ai: {'configured' if gemini_ok else 'not configured'}",
            f"{'✅' if ig_ok else '⚠️'}  instagram: {'configured' if ig_ok else 'not configured'}",
            f"{'✅' if cloud_ok else '⚠️'}  cloudinary: {'configured' if cloud_ok else 'not configured'}",
            f"{'✅' if yt_ok else '⚠️'}  youtube: {'configured' if yt_ok else 'not configured'}"
        ]
        ctk.CTkLabel(f, text="\n".join(status_lines), font=(APP_FONT, 15), justify="left", anchor="w").pack(fill="x", padx=60, pady=(0, 20))
        ctk.CTkLabel(f, text="you can change all settings later from the settings page.\nclick finish setup to start using the app.", font=(APP_FONT, 13), text_color="gray70", justify="left").pack(anchor="w", padx=60, pady=(0, 6))
        ctk.CTkLabel(f, text=f"crafted with ❤️ by {APP_AUTHOR}", font=(APP_FONT, 11), text_color="gray50").pack(pady=(10, 0))
        
    def finish_setup(self):
        self.save_current_step_data()
        ConfigManager.save(self.config_data)
        ConfigManager.mark_setup_complete()
        self.grab_release()
        self.destroy()
        if self.on_complete:
            self.on_complete(self.config_data)

    def on_close(self):
        self.save_current_step_data()
        ConfigManager.save(self.config_data)
        ConfigManager.mark_setup_complete()
        self.grab_release()
        self.destroy()
        if self.on_complete:
            self.on_complete(self.config_data)

    def open_tutorial(self):
        TutorialWindow(self)