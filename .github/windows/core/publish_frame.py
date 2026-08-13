import os
import threading
import customtkinter as ctk
from datetime import datetime
from tkinter import messagebox
from core.config_manager import ConfigManager
from core.ui_helpers import AnimationHelper, APP_FONT


class PublishFrame:
    def __init__(self, app):
        self.app = app

    def setup(self):
        app = self.app
        frame = ctk.CTkFrame(app.main_container, fg_color="transparent")
        app.frames["publish"] = frame
        content = ctk.CTkScrollableFrame(frame, fg_color="transparent")
        content.pack(fill="both", expand=True)
        ctk.CTkLabel(content, text="publish center", font=(APP_FONT, 28, "bold")).pack(anchor="w", padx=20, pady=(16, 4))
        app.lbl_publish_project = ctk.CTkLabel(content, text="no project loaded", font=(APP_FONT, 13), text_color="gray80", anchor="w")
        app.lbl_publish_project.pack(anchor="w", padx=20, pady=(0, 16))

        config_warning = ctk.CTkFrame(content, fg_color="#1e1b4b")
        config_warning.pack(fill="x", padx=20, pady=(0, 14))
        app.lbl_pub_config_warning = ctk.CTkLabel(config_warning, text="", font=(APP_FONT, 12), text_color="#fbbf24", anchor="w", wraplength=700, justify="left")
        app.lbl_pub_config_warning.pack(fill="x", padx=16, pady=10)
        app._pub_config_warning_frame = config_warning

        yt_card = ctk.CTkFrame(content)
        yt_card.pack(fill="x", padx=20, pady=(0, 14))
        yt_header = ctk.CTkFrame(yt_card, fg_color="transparent")
        yt_header.pack(fill="x", padx=20, pady=(16, 10))
        ctk.CTkLabel(yt_header, text="▶️  youtube shorts", font=(APP_FONT, 18, "bold")).pack(side="left")
        app.lbl_yt_auth = ctk.CTkLabel(yt_header, text="not connected", font=(APP_FONT, 13), text_color="#f87171")
        app.lbl_yt_auth.pack(side="right")
        yt_auth_row = ctk.CTkFrame(yt_card, fg_color="transparent")
        yt_auth_row.pack(fill="x", padx=20, pady=(0, 10))
        app.btn_yt_connect = ctk.CTkButton(yt_auth_row, text="connect youtube account", font=(APP_FONT, 14), command=self.connect_youtube, width=220)
        app.btn_yt_connect.pack(side="left", padx=(0, 10))
        app.btn_yt_disconnect = ctk.CTkButton(yt_auth_row, text="disconnect", font=(APP_FONT, 14), command=self.disconnect_youtube, fg_color="#b30000", hover_color="#800000", width=120)
        app.btn_yt_disconnect.pack(side="left")

        ctk.CTkLabel(yt_card, text="title", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(4, 4))
        app.ent_pub_yt_title = ctk.CTkEntry(yt_card, font=(APP_FONT, 14))
        app.ent_pub_yt_title.pack(fill="x", padx=20, pady=(0, 10))

        ctk.CTkLabel(yt_card, text="description", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.txt_pub_yt_desc = ctk.CTkTextbox(yt_card, height=100, font=(APP_FONT, 14))
        app.txt_pub_yt_desc.pack(fill="x", padx=20, pady=(0, 10))

        ctk.CTkLabel(yt_card, text="hashtags", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.txt_pub_yt_tags = ctk.CTkTextbox(yt_card, height=60, font=(APP_FONT, 14))
        app.txt_pub_yt_tags.pack(fill="x", padx=20, pady=(0, 10))

        yt_privacy_row = ctk.CTkFrame(yt_card, fg_color="transparent")
        yt_privacy_row.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(yt_privacy_row, text="privacy", font=(APP_FONT, 14)).pack(side="left", padx=(0, 10))
        app.opt_yt_privacy = ctk.CTkOptionMenu(yt_privacy_row, values=["private", "unlisted", "public"], font=(APP_FONT, 14))
        app.opt_yt_privacy.set("private")
        app.opt_yt_privacy.pack(side="left")

        app.btn_yt_publish = ctk.CTkButton(yt_card, text="upload to youtube shorts", font=(APP_FONT, 16), height=46, command=self.start_youtube_publish, fg_color="#ff0000", hover_color="#cc0000")
        app.btn_yt_publish.pack(fill="x", padx=20, pady=(4, 18))

        ig_card = ctk.CTkFrame(content)
        ig_card.pack(fill="x", padx=20, pady=(0, 14))
        ig_header = ctk.CTkFrame(ig_card, fg_color="transparent")
        ig_header.pack(fill="x", padx=20, pady=(16, 10))
        ctk.CTkLabel(ig_header, text="📸  instagram reels", font=(APP_FONT, 18, "bold")).pack(side="left")
        app.lbl_ig_auth = ctk.CTkLabel(ig_header, text="checking...", font=(APP_FONT, 13), text_color="#fbbf24")
        app.lbl_ig_auth.pack(side="right")

        ctk.CTkLabel(ig_card, text="caption and hashtags", font=(APP_FONT, 14, "bold")).pack(anchor="w", padx=20, pady=(0, 4))
        app.txt_pub_ig_caption = ctk.CTkTextbox(ig_card, height=160, font=(APP_FONT, 14))
        app.txt_pub_ig_caption.pack(fill="x", padx=20, pady=(0, 10))

        ctk.CTkLabel(ig_card, text="note: video is uploaded to cloudinary temporarily, then instagram fetches it. auto delete after publish.", font=(APP_FONT, 12), text_color="#7dd3fc", anchor="w", wraplength=600, justify="left").pack(fill="x", padx=20, pady=(0, 8))

        app.btn_ig_publish = ctk.CTkButton(ig_card, text="publish to instagram reels", font=(APP_FONT, 16), height=46, command=self.start_instagram_publish, fg_color="#8b5cf6", hover_color="#6d28d9")
        app.btn_ig_publish.pack(fill="x", padx=20, pady=(4, 18))

        pub_log_header = ctk.CTkFrame(content, fg_color="transparent")
        pub_log_header.pack(fill="x", padx=20, pady=(0, 6))
        ctk.CTkLabel(pub_log_header, text="publish log", font=(APP_FONT, 16, "bold")).pack(side="left")
        ctk.CTkButton(pub_log_header, text="clear log", width=100, command=self.clear_publish_log).pack(side="right", padx=(0, 6))
        ctk.CTkButton(pub_log_header, text="copy log", width=100, command=self.copy_publish_log).pack(side="right", padx=(0, 6))
        app.txt_pub_log = ctk.CTkTextbox(content, height=180, font=("Consolas", 12))
        app.txt_pub_log.pack(fill="x", padx=20, pady=(0, 20))

        app.pub_progress_bar = ctk.CTkProgressBar(content, height=12)
        app.pub_progress_bar.pack(fill="x", padx=20, pady=(0, 6))
        app.pub_progress_bar.set(0)
        app.lbl_pub_progress = ctk.CTkLabel(content, text="ready", font=(APP_FONT, 13), text_color="gray85", anchor="w")
        app.lbl_pub_progress.pack(fill="x", padx=20, pady=(0, 20))

        from core.config_manager import APP_AUTHOR
        footer = ctk.CTkFrame(content, fg_color="transparent")
        footer.pack(fill="x", padx=20, pady=(0, 10))
        ctk.CTkLabel(footer, text=f"crafted with ❤️ by {APP_AUTHOR}", font=(APP_FONT, 10), text_color="gray40").pack(side="right")

    def update_config_warning(self):
        app = self.app
        warnings = []
        if not ConfigManager.is_youtube_configured(app.config_data):
            warnings.append("⚠️ youtube: client secret json not found. go to settings to configure.")
        if not ConfigManager.is_instagram_configured(app.config_data):
            warnings.append("⚠️ instagram: not configured. go to settings to add access token and account id.")
        if not ConfigManager.is_cloudinary_configured(app.config_data):
            warnings.append("⚠️ cloudinary: not configured. required for instagram publishing. go to settings.")
        if warnings:
            app.lbl_pub_config_warning.configure(text="\n".join(warnings))
            app._pub_config_warning_frame.pack(fill="x", padx=20, pady=(0, 14))
        else:
            app._pub_config_warning_frame.pack_forget()

    def pub_log(self, message):
        app = self.app
        timestamp = datetime.now().strftime("%H:%M:%S")
        app.txt_pub_log.insert("end", f"[{timestamp}] {message}\n")
        app.txt_pub_log.see("end")

    def clear_publish_log(self):
        self.app.txt_pub_log.delete("1.0", "end")

    def copy_publish_log(self):
        app = self.app
        log_content = app.get_textbox_value(app.txt_pub_log)
        app.copy_to_clipboard(log_content, "Publish log")

    def check_youtube_auth(self):
        app = self.app
        if not hasattr(app, "yt_publisher") or not app.yt_publisher:
            app.lbl_yt_auth.configure(text="not configured", text_color="gray50")
            return
        try:
            if app.yt_publisher.is_authenticated():
                app.lbl_yt_auth.configure(text="connected ✓", text_color="#86efac")
            else:
                if ConfigManager.is_youtube_configured(app.config_data):
                    app.lbl_yt_auth.configure(text="not connected", text_color="#f87171")
                else:
                    app.lbl_yt_auth.configure(text="not configured", text_color="gray50")
        except:
            app.lbl_yt_auth.configure(text="not connected", text_color="#f87171")
        self.update_config_warning()

    def check_instagram_token(self):
        app = self.app
        if not hasattr(app, "ig_publisher") or not app.ig_publisher:
            app.lbl_ig_auth.configure(text="not configured", text_color="gray50")
            self.update_config_warning()
            return

        def _check():
            username = None
            error_text = None
            try:
                data = app.ig_publisher.verify_token()
                username = data.get("username", "unknown")
            except Exception as e:
                error_text = str(e)
            app.after(0, lambda: self._ig_check_done(username, error_text))

        threading.Thread(target=_check, daemon=True).start()

    def _ig_check_done(self, username, error_text):
        app = self.app
        if error_text:
            app.lbl_ig_auth.configure(text="token error", text_color="#f87171")
            self.pub_log(f"instagram token check failed: {error_text}")
        else:
            app.lbl_ig_auth.configure(text=f"connected as @{username} ✓", text_color="#86efac")
            self.pub_log(f"instagram token verified for @{username}.")
        self.update_config_warning()

    def connect_youtube(self):
        app = self.app
        if app.publish_active:
            return
        if not ConfigManager.is_youtube_configured(app.config_data):
            messagebox.showwarning("YouTube not configured", "Please select a YouTube client secret JSON file in settings first.")
            app.show_frame("settings")
            return
        app.publish_active = True
        app.lbl_yt_auth.configure(text="authenticating...", text_color="#fbbf24")
        self.pub_log("opening browser for youtube authentication...")
        threading.Thread(target=self._connect_youtube_thread, daemon=True).start()

    def _connect_youtube_thread(self):
        app = self.app
        error_text = None
        try:
            app.yt_publisher.authenticate()
        except Exception as e:
            error_text = str(e)
        app.after(0, lambda: self._connect_youtube_done(error_text))

    def _connect_youtube_done(self, error_text):
        app = self.app
        app.publish_active = False
        if error_text:
            app.lbl_yt_auth.configure(text="auth failed", text_color="#f87171")
            self.pub_log(f"youtube auth failed: {error_text}")
            messagebox.showerror("YouTube Auth Failed", error_text)
        else:
            app.lbl_yt_auth.configure(text="connected ✓", text_color="#86efac")
            self.pub_log("youtube account connected successfully.")
            AnimationHelper.pulse_button(app.btn_yt_publish)

    def disconnect_youtube(self):
        app = self.app
        if hasattr(app, "yt_publisher") and app.yt_publisher:
            app.yt_publisher.revoke_token()
        app.lbl_yt_auth.configure(text="not connected", text_color="#f87171")
        self.pub_log("youtube account disconnected.")

    def sync_fields_from_project(self):
        app = self.app
        if not app.project_data:
            app.lbl_publish_project.configure(text="no project loaded")
            return
        video_name = os.path.basename(app.project_data.get("video_path", ""))
        app.lbl_publish_project.configure(text=f"project: {video_name}")
        yt_title = app.project_data.get("ai_youtube_title", "")
        yt_desc = app.project_data.get("ai_youtube_description", "")
        yt_tags = app.project_data.get("ai_youtube_hashtags", "")
        ig_caption = app.project_data.get("ai_instagram_caption", "")
        ig_tags = app.project_data.get("ai_instagram_hashtags", "")
        ig_full = (ig_caption + "\n\n" + ig_tags).strip()
        app.set_entry_value(app.ent_pub_yt_title, yt_title)
        app.set_textbox_value(app.txt_pub_yt_desc, yt_desc)
        app.set_textbox_value(app.txt_pub_yt_tags, yt_tags)
        app.set_textbox_value(app.txt_pub_ig_caption, ig_full)
        self.update_config_warning()

    def start_youtube_publish(self):
        app = self.app
        if app.publish_active:
            return
        if not app.project_data:
            messagebox.showwarning("No project", "Please load a video project first.")
            return
        if not ConfigManager.is_youtube_configured(app.config_data):
            messagebox.showwarning("YouTube not configured", "Please configure YouTube API in settings first.")
            app.show_frame("settings")
            return
        if not hasattr(app, "yt_publisher") or not app.yt_publisher:
            messagebox.showwarning("YouTube not ready", "YouTube publisher is not initialized. Please check settings.")
            return
        output_path = app.project_data.get("output_path", "")
        if not output_path or not os.path.exists(output_path):
            messagebox.showwarning("No export", "Please process the video first to create the final export.")
            return
        title = app.ent_pub_yt_title.get().strip()
        if not title:
            messagebox.showwarning("Missing title", "Please enter a youtube title.")
            return
        description = app.get_textbox_value(app.txt_pub_yt_desc)
        tags = app.get_textbox_value(app.txt_pub_yt_tags)
        privacy = app.opt_yt_privacy.get()
        app.publish_active = True
        app.pub_progress_bar.set(0)
        app.lbl_pub_progress.configure(text="preparing youtube upload...")
        self.pub_log(f"starting youtube upload. title: {title}. privacy: {privacy}.")
        threading.Thread(
            target=self._youtube_publish_thread,
            args=(output_path, title, description, tags, privacy),
            daemon=True
        ).start()

    def _youtube_publish_thread(self, output_path, title, description, tags, privacy):
        app = self.app
        video_id = None
        error_text = None
        try:
            def progress(value, text):
                app.after(0, lambda v=value, t=text: self._pub_progress_update(v, t))
            video_id = app.yt_publisher.upload_short(output_path, title, description, tags, privacy, progress_callback=progress)
        except Exception as e:
            error_text = str(e)
        app.after(0, lambda: self._youtube_publish_done(video_id, error_text))

    def _youtube_publish_done(self, video_id, error_text):
        app = self.app
        app.publish_active = False
        if error_text:
            self.pub_log(f"youtube upload failed: {error_text}")
            app.lbl_pub_progress.configure(text="youtube upload failed.")
            messagebox.showerror("YouTube Upload Failed", error_text)
        else:
            self.pub_log(f"youtube upload complete. video id: {video_id}")
            self.pub_log(f"video url: https://youtube.com/shorts/{video_id}")
            app.lbl_pub_progress.configure(text=f"youtube upload complete. id: {video_id}")
            app.pub_progress_bar.set(1)
            messagebox.showinfo("YouTube Upload Complete", f"Video uploaded successfully.\n\nvideo id: {video_id}\n\nhttps://youtube.com/shorts/{video_id}")

    def start_instagram_publish(self):
        app = self.app
        if app.publish_active:
            return
        if not app.project_data:
            messagebox.showwarning("No project", "Please load a video project first.")
            return
        if not ConfigManager.is_instagram_configured(app.config_data):
            messagebox.showwarning("Instagram not configured", "Please configure Instagram API in settings first.")
            app.show_frame("settings")
            return
        if not ConfigManager.is_cloudinary_configured(app.config_data):
            messagebox.showwarning("Cloudinary not configured", "Cloudinary is required for Instagram publishing.\nPlease configure it in settings.")
            app.show_frame("settings")
            return
        if not hasattr(app, "ig_publisher") or not app.ig_publisher:
            messagebox.showwarning("Instagram not ready", "Instagram publisher is not initialized. Please check settings and save.")
            return
        output_path = app.project_data.get("output_path", "")
        if not output_path or not os.path.exists(output_path):
            messagebox.showwarning("No export", "Please process the video first to create the final export.")
            return
        caption = app.get_textbox_value(app.txt_pub_ig_caption)
        if not caption:
            messagebox.showwarning("Missing caption", "Please enter a caption for instagram.")
            return
        app.publish_active = True
        app.pub_progress_bar.set(0)
        app.lbl_pub_progress.configure(text="preparing instagram publish...")
        self.pub_log("starting instagram reel publish. this may take several minutes.")
        cloud_name = app.config_data.get("cloudinary_cloud_name", "")
        cloud_key = app.config_data.get("cloudinary_api_key", "")
        cloud_secret = app.config_data.get("cloudinary_api_secret", "")
        threading.Thread(
            target=self._instagram_publish_thread,
            args=(output_path, caption, cloud_name, cloud_key, cloud_secret),
            daemon=True
        ).start()

    def _instagram_publish_thread(self, output_path, caption, cloud_name, cloud_key, cloud_secret):
        app = self.app
        media_id = None
        error_text = None
        try:
            def progress(value, text):
                app.after(0, lambda v=value, t=text: self._pub_progress_update(v, t))
            media_id = app.ig_publisher.publish_reel(
                output_path, caption,
                cloud_name, cloud_key, cloud_secret,
                progress_callback=progress
            )
        except Exception as e:
            error_text = str(e)
        app.after(0, lambda: self._instagram_publish_done(media_id, error_text))

    def _instagram_publish_done(self, media_id, error_text):
        app = self.app
        app.publish_active = False
        if error_text:
            self.pub_log(f"instagram publish failed: {error_text}")
            app.lbl_pub_progress.configure(text="instagram publish failed.")
            messagebox.showerror("Instagram Publish Failed", error_text)
        else:
            self.pub_log(f"instagram reel published. media id: {media_id}")
            app.lbl_pub_progress.configure(text=f"instagram reel published. media id: {media_id}")
            app.pub_progress_bar.set(1)
            messagebox.showinfo("Instagram Published", f"Reel published successfully.\n\nmedia id: {media_id}")

    def _pub_progress_update(self, value, text):
        app = self.app
        app.pub_progress_bar.set(value)
        app.lbl_pub_progress.configure(text=text)
        self.pub_log(text)