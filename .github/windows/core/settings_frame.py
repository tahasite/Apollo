import os
import json
import shutil
import threading
import customtkinter as ctk
from tkinter import filedialog, messagebox
from core.config_manager import ConfigManager, DEFAULT_MODEL_NAME, YOUTUBE_SECRET_FILE
from core.ui_helpers import APP_FONT
from publisher import InstagramPublisher


class SettingsFrame:
    def __init__(self, app):
        self.app = app

    def setup(self):
        app = self.app
        frame = ctk.CTkFrame(app.main_container, fg_color="transparent")
        app.frames["settings"] = frame
        content = ctk.CTkScrollableFrame(frame, fg_color="transparent")
        content.pack(fill="both", expand=True)
        ctk.CTkLabel(content, text="system settings", font=(APP_FONT, 28, "bold")).pack(anchor="w", padx=20, pady=(18, 16))

        gemini_card = ctk.CTkFrame(content)
        gemini_card.pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(gemini_card, text="🤖  gemini ai", font=(APP_FONT, 18, "bold")).pack(anchor="w", padx=20, pady=(16, 8))
        ctk.CTkLabel(gemini_card, text="api keys (one per line)", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.txt_set_gemini_keys = ctk.CTkTextbox(gemini_card, height=100, font=("Consolas", 13))
        app.txt_set_gemini_keys.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(gemini_card, text="get keys: https://aistudio.google.com/apikey", font=(APP_FONT, 11), text_color="#22d3ee").pack(anchor="w", padx=20, pady=(0, 8))
        ctk.CTkLabel(gemini_card, text="model name", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(4, 4))
        app.ent_set_gemini_model = ctk.CTkEntry(gemini_card, font=(APP_FONT, 14))
        app.ent_set_gemini_model.pack(fill="x", padx=20, pady=(0, 6))
        ctk.CTkLabel(gemini_card, text=f"default: {DEFAULT_MODEL_NAME}  |  browse: https://ai.google.dev/gemini-api/docs/models", font=(APP_FONT, 11), text_color="gray60").pack(anchor="w", padx=20, pady=(0, 16))

        ig_card = ctk.CTkFrame(content)
        ig_card.pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(ig_card, text="📸  instagram api", font=(APP_FONT, 18, "bold")).pack(anchor="w", padx=20, pady=(16, 8))
        ctk.CTkLabel(ig_card, text="access token", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.txt_set_ig_token = ctk.CTkTextbox(ig_card, height=60, font=("Consolas", 12))
        app.txt_set_ig_token.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(ig_card, text="instagram business account id", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.ent_set_ig_user_id = ctk.CTkEntry(ig_card, font=(APP_FONT, 14))
        app.ent_set_ig_user_id.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(ig_card, text="app secret", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.ent_set_ig_secret = ctk.CTkEntry(ig_card, font=(APP_FONT, 14), show="•")
        app.ent_set_ig_secret.pack(fill="x", padx=20, pady=(0, 10))
        ig_test_row = ctk.CTkFrame(ig_card, fg_color="transparent")
        ig_test_row.pack(fill="x", padx=20, pady=(0, 16))
        app.btn_test_ig = ctk.CTkButton(ig_test_row, text="test instagram connection", font=(APP_FONT, 13), command=self.test_instagram_connection, width=220, fg_color="#8b5cf6", hover_color="#6d28d9")
        app.btn_test_ig.pack(side="left", padx=(0, 10))
        app.lbl_test_ig_result = ctk.CTkLabel(ig_test_row, text="", font=(APP_FONT, 12), text_color="gray60")
        app.lbl_test_ig_result.pack(side="left")

        cloud_card = ctk.CTkFrame(content)
        cloud_card.pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(cloud_card, text="☁️  cloudinary", font=(APP_FONT, 18, "bold")).pack(anchor="w", padx=20, pady=(16, 8))
        ctk.CTkLabel(cloud_card, text="cloud name", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.ent_set_cloud_name = ctk.CTkEntry(cloud_card, font=(APP_FONT, 14))
        app.ent_set_cloud_name.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(cloud_card, text="api key", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.ent_set_cloud_key = ctk.CTkEntry(cloud_card, font=(APP_FONT, 14))
        app.ent_set_cloud_key.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(cloud_card, text="api secret", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.ent_set_cloud_secret = ctk.CTkEntry(cloud_card, font=(APP_FONT, 14), show="•")
        app.ent_set_cloud_secret.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(cloud_card, text="free account: https://cloudinary.com/", font=(APP_FONT, 11), text_color="#22d3ee").pack(anchor="w", padx=20, pady=(0, 16))

        yt_card = ctk.CTkFrame(content)
        yt_card.pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(yt_card, text="▶️  youtube api", font=(APP_FONT, 18, "bold")).pack(anchor="w", padx=20, pady=(16, 8))
        yt_file_row = ctk.CTkFrame(yt_card, fg_color="transparent")
        yt_file_row.pack(fill="x", padx=20, pady=(0, 8))
        app.btn_set_yt_json = ctk.CTkButton(yt_file_row, text="select client secret json", font=(APP_FONT, 13), command=self.pick_youtube_json, width=220, fg_color="#dc2626", hover_color="#b91c1c")
        app.btn_set_yt_json.pack(side="left", padx=(0, 10))
        app.lbl_set_yt_file = ctk.CTkLabel(yt_file_row, text="", font=(APP_FONT, 12), text_color="gray60")
        app.lbl_set_yt_file.pack(side="left")
        ctk.CTkLabel(yt_card, text="after selecting the file, connect your account from the publish page.", font=(APP_FONT, 12), text_color="gray60").pack(anchor="w", padx=20, pady=(0, 16))

        wm_card = ctk.CTkFrame(content)
        wm_card.pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(wm_card, text="🎨  default watermark", font=(APP_FONT, 18, "bold")).pack(anchor="w", padx=20, pady=(16, 8))
        app.lbl_set_default_wm = ctk.CTkLabel(wm_card, text="", font=(APP_FONT, 13), text_color="gray80", anchor="w")
        app.lbl_set_default_wm.pack(fill="x", padx=20, pady=(0, 10))
        wm_action_row = ctk.CTkFrame(wm_card, fg_color="transparent")
        wm_action_row.pack(fill="x", padx=20, pady=(0, 16))
        ctk.CTkButton(wm_action_row, text="choose watermark", font=(APP_FONT, 13), command=self.pick_default_watermark, width=160).pack(side="left", padx=(0, 10))
        ctk.CTkButton(wm_action_row, text="clear", font=(APP_FONT, 13), command=self.clear_default_watermark, fg_color="#b30000", hover_color="#800000", width=80).pack(side="left")

        btn_row = ctk.CTkFrame(content, fg_color="transparent")
        btn_row.pack(fill="x", padx=20, pady=(6, 20))
        ctk.CTkButton(btn_row, text="💾  save all settings", font=(APP_FONT, 15, "bold"), command=self.save_settings, fg_color="green", hover_color="darkgreen", height=44).pack(side="left", padx=(0, 10))
        ctk.CTkButton(btn_row, text="reset defaults", font=(APP_FONT, 14), command=self.reset_settings, fg_color="#b30000", hover_color="#800000", height=44).pack(side="left", padx=(0, 10))
        ctk.CTkButton(btn_row, text="run setup wizard", font=(APP_FONT, 14), command=app.open_setup_wizard, fg_color="#8b5cf6", hover_color="#6d28d9", height=44).pack(side="left")

        from core.config_manager import APP_AUTHOR
        from core.ui_helpers import IPChecker

        ip_card = ctk.CTkFrame(content)
        ip_card.pack(fill="x", padx=20, pady=(0, 14))
        ctk.CTkLabel(ip_card, text="🌐  network info", font=(APP_FONT, 18, "bold")).pack(anchor="w", padx=20, pady=(16, 8))
        app.lbl_settings_ip = ctk.CTkLabel(ip_card, text="checking your ip address...", font=(APP_FONT, 13), text_color=TEXT_SECONDARY if 'TEXT_SECONDARY' in dir() else "#94a3b8", anchor="w")
        app.lbl_settings_ip.pack(fill="x", padx=20, pady=(0, 6))
        app.lbl_settings_location = ctk.CTkLabel(ip_card, text="", font=(APP_FONT, 12), text_color="#64748b", anchor="w")
        app.lbl_settings_location.pack(fill="x", padx=20, pady=(0, 6))
        app.lbl_settings_isp = ctk.CTkLabel(ip_card, text="", font=(APP_FONT, 12), text_color="#64748b", anchor="w")
        app.lbl_settings_isp.pack(fill="x", padx=20, pady=(0, 6))
        ctk.CTkLabel(ip_card, text="this is the ip address used for all api connections (instagram, youtube, etc)", font=(APP_FONT, 11), text_color="#475569").pack(anchor="w", padx=20, pady=(0, 6))
        ctk.CTkButton(ip_card, text="🔄 refresh ip", font=(APP_FONT, 12), command=self.refresh_ip_info, width=120, height=30, fg_color="#334155", hover_color="#475569", corner_radius=6).pack(anchor="w", padx=20, pady=(0, 14))

        footer = ctk.CTkFrame(content, fg_color="transparent")
        footer.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(footer, text=f"crafted with ❤️ by {APP_AUTHOR}", font=(APP_FONT, 10), text_color="gray40").pack(side="right")

        app.after(800, self.load_ip_for_settings)

        self.reload_ui()

    def reload_ui(self):
        app = self.app
        app.set_textbox_value(app.txt_set_gemini_keys, "\n".join(app.config_data.get("gemini_api_keys", [])))
        app.set_entry_value(app.ent_set_gemini_model, app.config_data.get("gemini_model", DEFAULT_MODEL_NAME))
        app.set_textbox_value(app.txt_set_ig_token, app.config_data.get("instagram_access_token", ""))
        app.set_entry_value(app.ent_set_ig_user_id, app.config_data.get("instagram_user_id", ""))
        app.set_entry_value(app.ent_set_ig_secret, app.config_data.get("instagram_app_secret", ""))
        app.set_entry_value(app.ent_set_cloud_name, app.config_data.get("cloudinary_cloud_name", ""))
        app.set_entry_value(app.ent_set_cloud_key, app.config_data.get("cloudinary_api_key", ""))
        app.set_entry_value(app.ent_set_cloud_secret, app.config_data.get("cloudinary_api_secret", ""))
        if os.path.exists(YOUTUBE_SECRET_FILE):
            app.lbl_set_yt_file.configure(text="youtube_client_secret.json found ✓", text_color="#86efac")
        else:
            app.lbl_set_yt_file.configure(text="no file selected", text_color="gray60")
        wm_path = app.config_data.get("wm_path", "")
        if wm_path and os.path.exists(wm_path):
            app.lbl_set_default_wm.configure(text=app.truncate_path(wm_path, 90))
        else:
            app.lbl_set_default_wm.configure(text="not set")
        app.update_sidebar_status()
        if hasattr(app, "lbl_model"):
            app.lbl_model.configure(text=f"model: {app.config_data.get('gemini_model', DEFAULT_MODEL_NAME)}")

    def save_settings(self):
        app = self.app
        keys_text = app.get_textbox_value(app.txt_set_gemini_keys)
        app.config_data["gemini_api_keys"] = ConfigManager.normalize_api_keys(keys_text)
        model = app.ent_set_gemini_model.get().strip()
        app.config_data["gemini_model"] = model if model else DEFAULT_MODEL_NAME
        app.config_data["instagram_access_token"] = app.get_textbox_value(app.txt_set_ig_token)
        app.config_data["instagram_user_id"] = app.ent_set_ig_user_id.get().strip()
        app.config_data["instagram_app_secret"] = app.ent_set_ig_secret.get().strip()
        app.config_data["cloudinary_cloud_name"] = app.ent_set_cloud_name.get().strip()
        app.config_data["cloudinary_api_key"] = app.ent_set_cloud_key.get().strip()
        app.config_data["cloudinary_api_secret"] = app.ent_set_cloud_secret.get().strip()
        ConfigManager.save(app.config_data)
        app.init_publishers()
        app.update_sidebar_status()
        self.reload_ui()
        messagebox.showinfo("Settings saved", "All settings were saved successfully.")

    def reset_settings(self):
        app = self.app
        wm_path = app.config_data.get("wm_path", "")
        app.config_data = ConfigManager.default_config()
        app.config_data["wm_path"] = wm_path
        ConfigManager.save(app.config_data)
        self.reload_ui()
        app.init_publishers()
        messagebox.showinfo("Defaults restored", "All settings were reset to defaults.")

    def pick_youtube_json(self):
        app = self.app
        file_path = filedialog.askopenfilename(
            title="Select YouTube Client Secret JSON",
            filetypes=[("JSON Files", "*.json")]
        )
        if file_path:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if "installed" not in data and "web" not in data:
                    messagebox.showwarning("Invalid File", "This does not look like a valid Google OAuth client secret file.")
                    return
                shutil.copy2(file_path, YOUTUBE_SECRET_FILE)
                if "installed" in data:
                    client_info = data["installed"]
                elif "web" in data:
                    client_info = data["web"]
                else:
                    client_info = {}
                app.config_data["youtube_client_id"] = client_info.get("client_id", "")
                app.config_data["youtube_client_secret"] = client_info.get("client_secret", "")
                app.config_data["youtube_json_path"] = YOUTUBE_SECRET_FILE
                ConfigManager.save(app.config_data)
                app.lbl_set_yt_file.configure(text=f"file loaded: {os.path.basename(file_path)} ✓", text_color="#86efac")
                app.update_sidebar_status()
                app.init_publishers()
            except Exception as e:
                messagebox.showerror("File Error", f"could not read json file:\n{str(e)}")

    def test_instagram_connection(self):
        app = self.app
        token = app.get_textbox_value(app.txt_set_ig_token)
        uid = app.ent_set_ig_user_id.get().strip()
        secret = app.ent_set_ig_secret.get().strip()
        if not token or not uid or not secret:
            app.lbl_test_ig_result.configure(text="fill all fields first", text_color="#f87171")
            return
        app.lbl_test_ig_result.configure(text="testing...", text_color="#fbbf24")
        app.btn_test_ig.configure(state="disabled")

        def _test():
            error_text = None
            username = None
            try:
                pub = InstagramPublisher(token, uid, secret)
                data = pub.verify_token()
                username = data.get("username", "unknown")
            except Exception as e:
                error_text = str(e)
            app.after(0, lambda: self._test_ig_done(username, error_text))

        threading.Thread(target=_test, daemon=True).start()

    def _test_ig_done(self, username, error_text):
        app = self.app
        app.btn_test_ig.configure(state="normal")
        if error_text:
            app.lbl_test_ig_result.configure(text=f"failed: {error_text[:60]}", text_color="#f87171")
        else:
            app.lbl_test_ig_result.configure(text=f"connected as @{username} ✓", text_color="#86efac")

    def pick_default_watermark(self):
        app = self.app
        file_path = filedialog.askopenfilename(title="Choose default watermark", filetypes=[("Image Files", "*.png")])
        if file_path:
            app.config_data["wm_path"] = file_path
            ConfigManager.save(app.config_data)
            app.lbl_set_default_wm.configure(text=app.truncate_path(file_path, 90))

    def clear_default_watermark(self):
        app = self.app
        app.config_data["wm_path"] = ""
        app.config_data["wm_scale"] = 1.0
        app.config_data["wm_x"] = 50.0
        app.config_data["wm_y"] = 50.0
        ConfigManager.save(app.config_data)
        app.lbl_set_default_wm.configure(text="not set")

    def load_ip_for_settings(self):
        import threading
        def _fetch():
            from core.ui_helpers import IPChecker
            info = IPChecker.get_ip_info()
            self.app.after(0, lambda: self._apply_ip_settings(info))
        threading.Thread(target=_fetch, daemon=True).start()

    def _apply_ip_settings(self, info):
        app = self.app
        flag = info.get("flag", "🏳️")
        ip = info.get("ip", "unknown")
        country = info.get("country", "unknown")
        city = info.get("city", "")
        isp = info.get("isp", "")
        location = f"{city}, {country}" if city else country
        if hasattr(app, "lbl_settings_ip"):
            app.lbl_settings_ip.configure(text=f"{flag}  ip: {ip}")
        if hasattr(app, "lbl_settings_location"):
            app.lbl_settings_location.configure(text=f"📍  location: {location}")
        if hasattr(app, "lbl_settings_isp"):
            app.lbl_settings_isp.configure(text=f"🏢  isp: {isp}")

    def refresh_ip_info(self):
        app = self.app
        if hasattr(app, "lbl_settings_ip"):
            app.lbl_settings_ip.configure(text="🔄 refreshing...")
        self.load_ip_for_settings()
        if hasattr(app, "load_ip_info"):
            app.load_ip_info()