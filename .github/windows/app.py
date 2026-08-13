import customtkinter as ctk
import cv2
import numpy as np
import os
import sys
import threading
import shutil
import subprocess
from tkinter import filedialog, messagebox
from PIL import Image
from core import (
    ConfigManager, ProjectManager, GeminiManager,
    AnimationHelper, InteractiveWidgetHelper,
    SetupWizard, TutorialWindow,
    DashboardFrame, SettingsFrame, PublishFrame,
    MaskEditor, WatermarkEditor
)
from core.config_manager import DEFAULT_MODEL_NAME, YOUTUBE_SECRET_FILE
from core.ui_helpers import APP_FONT
from publisher import InstagramPublisher, YouTubePublisher

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


class SmartVideoEditor(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Apollo")
        self.geometry("1220x860")
        self.config_data = ConfigManager.load()
        ProjectManager.init_db()
        self.video_path = None
        self.mask_path = None
        self.output_path = None
        self.project_data = None
        self.mask_frame = None
        self.watermark_frame = None
        self.processing_active = False
        self.ai_active = False
        self.loading_project_to_ui = False
        self.autosave_job = None
        self.publish_active = False
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)
        self.protocol("WM_DELETE_WINDOW", self.on_app_close)
        self.mask_editor = MaskEditor(self)
        self.watermark_editor = WatermarkEditor(self)
        self.settings_handler = SettingsFrame(self)
        self.publish_handler = PublishFrame(self)
        self.dashboard_handler = DashboardFrame(self)
        self.setup_sidebar()
        self.main_container = ctk.CTkFrame(self, fg_color="transparent")
        self.main_container.grid(row=0, column=1, sticky="nsew", padx=10, pady=10)
        self.main_container.grid_rowconfigure(0, weight=1)
        self.main_container.grid_columnconfigure(0, weight=1)
        self.frames = {}
        self.dashboard_handler.setup()
        self.settings_handler.setup()
        self.publish_handler.setup()
        self.show_frame("dashboard")
        self.refresh_project_state()
        InteractiveWidgetHelper.register_inputs(self)
        self.after(300, self.check_first_run)

    def check_first_run(self):
        if not ConfigManager.is_setup_complete():
            self.open_setup_wizard()
        else:
            self.restore_latest_project()
            self.init_publishers()

    def open_setup_wizard(self):
        def on_wizard_complete(updated_config):
            self.config_data = updated_config
            self.settings_handler.reload_ui()
            self.restore_latest_project()
            self.init_publishers()
            self.refresh_project_state()
        SetupWizard(self, self.config_data, on_wizard_complete)

    def init_publishers(self):
        yt_cid = self.config_data.get("youtube_client_id", "")
        yt_csec = self.config_data.get("youtube_client_secret", "")
        self.yt_publisher = YouTubePublisher(client_id=yt_cid, client_secret=yt_csec)
        ig_token = self.config_data.get("instagram_access_token", "")
        ig_uid = self.config_data.get("instagram_user_id", "")
        ig_secret = self.config_data.get("instagram_app_secret", "")
        if ig_token and ig_uid and ig_secret:
            self.ig_publisher = InstagramPublisher(ig_token, ig_uid, ig_secret)
        else:
            self.ig_publisher = None
        self.after(500, self.publish_handler.check_youtube_auth)
        self.after(600, self.publish_handler.check_instagram_token)

    def setup_sidebar(self):
        self.sidebar = ctk.CTkFrame(self, width=220, corner_radius=0)
        self.sidebar.grid(row=0, column=0, sticky="nsew")
        self.sidebar.grid_rowconfigure(6, weight=1)

        from core.config_manager import APP_NAME, APP_VERSION, APP_AUTHOR
        self.title(APP_NAME)

        ctk.CTkLabel(self.sidebar, text=APP_NAME, font=(APP_FONT, 22, "bold")).grid(row=0, column=0, padx=20, pady=(30, 4))
        ctk.CTkLabel(self.sidebar, text=f"v{APP_VERSION}", font=(APP_FONT, 11), text_color="gray60").grid(row=1, column=0, padx=20, pady=(0, 16))
        
        self.btn_nav_dash = ctk.CTkButton(self.sidebar, text="📊  dashboard", font=(APP_FONT, 15), command=lambda: self.show_frame("dashboard"), fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"), anchor="w")
        self.btn_nav_dash.grid(row=2, column=0, padx=12, pady=5, sticky="ew")
        self.btn_nav_publish = ctk.CTkButton(self.sidebar, text="🚀  publish", font=(APP_FONT, 15), command=lambda: self.show_frame("publish"), fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"), anchor="w")
        self.btn_nav_publish.grid(row=3, column=0, padx=12, pady=5, sticky="ew")
        self.btn_nav_set = ctk.CTkButton(self.sidebar, text="⚙️  settings", font=(APP_FONT, 15), command=lambda: self.show_frame("settings"), fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"), anchor="w")
        self.btn_nav_set.grid(row=4, column=0, padx=12, pady=5, sticky="ew")
        self.btn_nav_tutorial = ctk.CTkButton(self.sidebar, text="📖  tutorial", font=(APP_FONT, 15), command=self.open_tutorial_window, fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"), anchor="w")
        self.btn_nav_tutorial.grid(row=5, column=0, padx=12, pady=5, sticky="ew")

        self.sidebar_status_frame = ctk.CTkFrame(self.sidebar, fg_color="transparent")
        self.sidebar_status_frame.grid(row=7, column=0, padx=12, pady=(0, 6), sticky="sew")
        self.lbl_sidebar_gemini = ctk.CTkLabel(self.sidebar_status_frame, text="● gemini", font=(APP_FONT, 11), text_color="gray50", anchor="w")
        self.lbl_sidebar_gemini.pack(fill="x", padx=8, pady=1)
        self.lbl_sidebar_ig = ctk.CTkLabel(self.sidebar_status_frame, text="● instagram", font=(APP_FONT, 11), text_color="gray50", anchor="w")
        self.lbl_sidebar_ig.pack(fill="x", padx=8, pady=1)
        self.lbl_sidebar_cloud = ctk.CTkLabel(self.sidebar_status_frame, text="● cloudinary", font=(APP_FONT, 11), text_color="gray50", anchor="w")
        self.lbl_sidebar_cloud.pack(fill="x", padx=8, pady=1)
        self.lbl_sidebar_yt = ctk.CTkLabel(self.sidebar_status_frame, text="● youtube", font=(APP_FONT, 11), text_color="gray50", anchor="w")
        self.lbl_sidebar_yt.pack(fill="x", padx=8, pady=1)

        self.lbl_sidebar_ip = ctk.CTkLabel(self.sidebar_status_frame, text="🌐 checking ip...", font=(APP_FONT, 10), text_color="gray40", anchor="w")
        self.lbl_sidebar_ip.pack(fill="x", padx=8, pady=(6, 2))

        author_frame = ctk.CTkFrame(self.sidebar, fg_color="transparent")
        author_frame.grid(row=8, column=0, padx=12, pady=(0, 14), sticky="sew")
        ctk.CTkLabel(author_frame, text=f"❤️ {APP_AUTHOR}", font=(APP_FONT, 10), text_color="gray40", anchor="center").pack(fill="x")

        self.after(400, self.update_sidebar_status)
        self.after(500, self.load_ip_info)

    def update_sidebar_status(self):
        if ConfigManager.is_gemini_configured(self.config_data):
            self.lbl_sidebar_gemini.configure(text="● gemini", text_color="#86efac")
        else:
            self.lbl_sidebar_gemini.configure(text="● gemini", text_color="#f87171")
        if ConfigManager.is_instagram_configured(self.config_data):
            self.lbl_sidebar_ig.configure(text="● instagram", text_color="#86efac")
        else:
            self.lbl_sidebar_ig.configure(text="● instagram", text_color="gray50")
        if ConfigManager.is_cloudinary_configured(self.config_data):
            self.lbl_sidebar_cloud.configure(text="● cloudinary", text_color="#86efac")
        else:
            self.lbl_sidebar_cloud.configure(text="● cloudinary", text_color="gray50")
        if ConfigManager.is_youtube_configured(self.config_data):
            self.lbl_sidebar_yt.configure(text="● youtube", text_color="#86efac")
        else:
            self.lbl_sidebar_yt.configure(text="● youtube", text_color="gray50")

    def load_ip_info(self):
        import threading
        def _fetch():
            from core.ui_helpers import IPChecker
            info = IPChecker.get_ip_info()
            self.after(0, lambda: self._apply_ip_info(info))
        threading.Thread(target=_fetch, daemon=True).start()

    def _apply_ip_info(self, info):
        flag = info.get("flag", "🏳️")
        ip = info.get("ip", "unknown")
        country = info.get("country", "unknown")
        city = info.get("city", "")
        location = f"{city}, {country}" if city else country
        self.lbl_sidebar_ip.configure(text=f"{flag} {ip}  ({location})", text_color="#64748b")

    def open_tutorial_window(self):
        TutorialWindow(self)

    def show_frame(self, frame_name):
        for frame in self.frames.values():
            frame.grid_remove()
        if self.mask_frame:
            self.mask_frame.grid_remove()
        if self.watermark_frame:
            self.watermark_frame.grid_remove()
        self.frames[frame_name].grid(row=0, column=0, sticky="nsew")
        self.btn_nav_dash.configure(fg_color="transparent")
        self.btn_nav_set.configure(fg_color="transparent")
        self.btn_nav_publish.configure(fg_color="transparent")
        self.btn_nav_tutorial.configure(fg_color="transparent")
        if frame_name == "dashboard":
            self.btn_nav_dash.configure(fg_color=("gray75", "gray25"))
        elif frame_name == "settings":
            self.btn_nav_set.configure(fg_color=("gray75", "gray25"))
        elif frame_name == "publish":
            self.btn_nav_publish.configure(fg_color=("gray75", "gray25"))
        AnimationHelper.fade_in_widget(self.frames[frame_name])

    def restore_latest_project(self):
        latest = ProjectManager.load_latest(self.config_data)
        if latest:
            self.apply_project(latest, "last project restored automatically.")

    def truncate_path(self, path, max_len=90):
        if not path:
            return ""
        if len(path) <= max_len:
            return path
        return "..." + path[-(max_len - 3):]

    def get_textbox_value(self, textbox):
        return textbox.get("1.0", "end").strip()

    def set_textbox_value(self, textbox, value):
        textbox.delete("1.0", "end")
        if value:
            textbox.insert("1.0", value)

    def set_entry_value(self, entry, value):
        entry.delete(0, "end")
        if value:
            entry.insert(0, value)

    def copy_to_clipboard(self, text, label):
        text = (text or "").strip()
        if not text:
            messagebox.showwarning("Nothing to copy", f"{label} is empty.")
            return
        self.clipboard_clear()
        self.clipboard_append(text)
        self.update()
        self.lbl_progress.configure(text=f"{label} copied to clipboard.")

    def copy_textbox_content(self, textbox, label):
        self.copy_to_clipboard(self.get_textbox_value(textbox), label)

    def copy_entry_content(self, entry, label):
        self.copy_to_clipboard(entry.get().strip(), label)

    def build_instagram_pack_text(self):
        sections = []
        topic = self.ent_topic.get().strip()
        caption = self.get_textbox_value(self.txt_instagram_caption)
        hashtags = self.get_textbox_value(self.txt_instagram_tags)
        if topic:
            sections.append(f"topic:\n{topic}")
        if caption:
            sections.append(f"caption:\n{caption}")
        if hashtags:
            sections.append(f"hashtags:\n{hashtags}")
        return "\n\n".join(sections)

    def build_youtube_pack_text(self):
        sections = []
        title = self.ent_youtube_title.get().strip()
        description = self.get_textbox_value(self.txt_youtube_description)
        hashtags = self.get_textbox_value(self.txt_youtube_tags)
        if title:
            sections.append(f"title:\n{title}")
        if description:
            sections.append(f"description:\n{description}")
        if hashtags:
            sections.append(f"hashtags:\n{hashtags}")
        return "\n\n".join(sections)

    def copy_instagram_pack(self):
        self.copy_to_clipboard(self.build_instagram_pack_text(), "Instagram pack")

    def copy_youtube_pack(self):
        self.copy_to_clipboard(self.build_youtube_pack_text(), "YouTube pack")

    def setup_context_textbox_direction(self):
        try:
            self.after(200, self.apply_context_text_direction)
        except:
            pass

    def apply_context_text_direction(self):
        try:
            base = self.txt_context._textbox
            base.tag_configure("rtl_tag", justify="right")
            base.tag_remove("rtl_tag", "1.0", "end")
            text_content = base.get("1.0", "end").strip()
            if text_content:
                for char in text_content:
                    if '\u0600' <= char <= '\u06FF' or '\uFB50' <= char <= '\uFDFF' or '\uFE70' <= char <= '\uFEFF':
                        base.tag_add("rtl_tag", "1.0", "end")
                        break
        except:
            pass

    def on_context_text_changed(self, event=None):
        self.apply_context_text_direction()
        self.schedule_project_autosave()

    def collect_ui_project_data(self):
        if not self.project_data:
            return
        self.project_data["note_text"] = self.get_textbox_value(self.txt_context)
        self.project_data["identified_topic"] = self.ent_topic.get().strip()
        self.project_data["ai_instagram_caption"] = self.get_textbox_value(self.txt_instagram_caption)
        self.project_data["ai_instagram_hashtags"] = self.get_textbox_value(self.txt_instagram_tags)
        self.project_data["ai_youtube_title"] = self.ent_youtube_title.get().strip()
        self.project_data["ai_youtube_description"] = self.get_textbox_value(self.txt_youtube_description)
        self.project_data["ai_youtube_hashtags"] = self.get_textbox_value(self.txt_youtube_tags)

    def schedule_project_autosave(self, event=None):
        if self.loading_project_to_ui or not self.project_data:
            self.refresh_project_state()
            return
        if self.autosave_job:
            self.after_cancel(self.autosave_job)
        self.autosave_job = self.after(700, self.save_project_snapshot_from_ui)
        self.refresh_project_state()

    def save_project_snapshot_from_ui(self):
        self.autosave_job = None
        if not self.project_data or self.loading_project_to_ui:
            return
        self.collect_ui_project_data()
        ProjectManager.save(self.project_data)
        self.refresh_project_state()

    def apply_project(self, project, progress_text=None):
        self.project_data = project
        self.video_path = project.get("video_path")
        self.mask_path = project.get("mask_path")
        self.output_path = project.get("output_path")
        self.loading_project_to_ui = True
        self.set_textbox_value(self.txt_context, project.get("note_text", ""))
        self.after(100, self.apply_context_text_direction)
        self.set_entry_value(self.ent_topic, project.get("identified_topic", ""))
        self.set_textbox_value(self.txt_instagram_caption, project.get("ai_instagram_caption", ""))
        self.set_textbox_value(self.txt_instagram_tags, project.get("ai_instagram_hashtags", ""))
        self.set_entry_value(self.ent_youtube_title, project.get("ai_youtube_title", ""))
        self.set_textbox_value(self.txt_youtube_description, project.get("ai_youtube_description", ""))
        self.set_textbox_value(self.txt_youtube_tags, project.get("ai_youtube_hashtags", ""))
        self.loading_project_to_ui = False
        if os.path.exists(self.output_path):
            self.progress_bar.set(1)
        else:
            self.progress_bar.set(0)
        if progress_text:
            self.lbl_progress.configure(text=progress_text)
        elif os.path.exists(self.output_path):
            self.lbl_progress.configure(text="project loaded. existing final export found.")
        else:
            self.lbl_progress.configure(text="project loaded and ready.")
        self.show_frame("dashboard")
        self.refresh_project_state()
        if hasattr(self, "ent_pub_yt_title"):
            self.publish_handler.sync_fields_from_project()

    def refresh_project_state(self):
        has_project = self.project_data is not None and self.video_path is not None
        has_mask = has_project and self.mask_path and os.path.exists(self.mask_path)
        has_wm = has_project and self.project_data.get("wm_path") and os.path.exists(self.project_data.get("wm_path", ""))
        has_output = has_project and self.output_path and os.path.exists(self.output_path)
        has_ai = has_project and any([self.project_data.get("identified_topic", "").strip(), self.project_data.get("ai_instagram_caption", "").strip(), self.project_data.get("ai_youtube_title", "").strip()])
        note_ready = bool(self.get_textbox_value(self.txt_context).strip()) if hasattr(self, "txt_context") else False
        busy = self.processing_active or self.ai_active

        if has_project:
            vname = os.path.basename(self.video_path)
            self.lbl_video.configure(text=f"🎬  {vname}", text_color="#e2e8f0")
            pdir = os.path.basename(self.project_data.get("project_dir", ""))
            self.lbl_project.configure(text=f"📂  {pdir}", text_color="#94a3b8")
            if has_output:
                self.lbl_output.configure(text="📦  export ready ✓", text_color="#86efac")
            else:
                self.lbl_output.configure(text="📦  not exported", text_color="#475569")
        else:
            self.lbl_video.configure(text="no file loaded", text_color="#94a3b8")
            self.lbl_project.configure(text="📂  no project", text_color="#475569")
            self.lbl_output.configure(text="📦  no export", text_color="#475569")

        indicators = []
        if has_mask:
            indicators.append("🎭")
        if has_wm:
            indicators.append("💧")
        if has_output:
            indicators.append("⚡")
        if has_ai:
            indicators.append("✨")

        if busy:
            self.lbl_status.configure(text="⏳ processing...", text_color="#fbbf24")
        elif indicators:
            self.lbl_status.configure(text="  ".join(indicators), text_color="#86efac")
        elif has_project:
            self.lbl_status.configure(text="● ready", text_color="#3b82f6")
        else:
            self.lbl_status.configure(text="● idle", text_color="#475569")

        self.btn_open_project.configure(state="normal" if has_project and not busy else "disabled")
        self.btn_reload_video.configure(state="normal" if not busy else "disabled")
        self.btn_step1.configure(state="normal" if not busy else "disabled")
        self.btn_step2.configure(state="normal" if has_project and not busy else "disabled")
        self.btn_step3.configure(state="normal" if has_project and not busy else "disabled")
        self.btn_step4.configure(state="normal" if has_project and not busy else "disabled")
        self.btn_step5.configure(state="normal" if has_project and note_ready and not busy else "disabled")

    def select_video(self):
        file_path = filedialog.askopenfilename(title="Select video", filetypes=[("Video Files", "*.mp4 *.avi *.mov *.mkv *.webm")])
        if file_path:
            self.save_project_snapshot_from_ui()
            project = ProjectManager.load_or_create(file_path, self.config_data)
            self.apply_project(project, "video selected. project state restored.")

    def open_project_folder(self):
        if not self.project_data:
            return
        project_dir = self.project_data.get("project_dir")
        if not project_dir:
            return
        os.makedirs(project_dir, exist_ok=True)
        try:
            if os.name == "nt":
                os.startfile(project_dir)
            elif sys.platform == "darwin":
                subprocess.run(["open", project_dir], check=False)
            else:
                subprocess.run(["xdg-open", project_dir], check=False)
        except Exception as e:
            messagebox.showerror("Open folder failed", str(e))

    def open_mask_editor(self):
        self.mask_editor.open()

    def open_watermark_editor(self):
        self.watermark_editor.open()

    def start_processing(self):
        if not self.project_data:
            return
        self.save_project_snapshot_from_ui()
        self.processing_active = True
        self.progress_bar.set(0)
        self.lbl_progress.configure(text="processing video and enhancing quality...")
        self.refresh_project_state()
        threading.Thread(target=self.process_video_thread, daemon=True).start()

    def find_ffmpeg(self):
        candidates = [
            os.path.join(BASE_DIR, "ffmpeg.exe"),
            os.path.join(BASE_DIR, "ffmpeg", "bin", "ffmpeg.exe"),
            shutil.which("ffmpeg")
        ]
        for candidate in candidates:
            if candidate and os.path.exists(candidate):
                return candidate
        return shutil.which("ffmpeg")

    def finalize_output_with_audio(self, silent_video_path):
        final_output = self.output_path
        ffmpeg_path = self.find_ffmpeg()
        if os.path.exists(final_output):
            try:
                os.remove(final_output)
            except:
                pass
        if ffmpeg_path:
            video_filter = (
                "scale=1080:1920:force_original_aspect_ratio=decrease,"
                "pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black,"
                "setsar=1"
            )
            cmd = [
                ffmpeg_path, "-y",
                "-i", silent_video_path,
                "-i", self.video_path,
                "-map", "0:v:0", "-map", "1:a:0?",
                "-vf", video_filter,
                "-c:v", "libx264", "-profile:v", "high", "-level", "4.2",
                "-pix_fmt", "yuv420p", "-preset", "medium", "-crf", "20",
                "-r", "30", "-g", "60",
                "-c:a", "aac", "-b:a", "128k", "-ar", "48000", "-ac", "2",
                "-movflags", "+faststart", "-shortest",
                final_output
            ]
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0 and os.path.exists(final_output):
                return final_output
            else:
                error_msg = result.stderr[-800:] if result.stderr else "unknown ffmpeg error"
                raise RuntimeError(f"ffmpeg encoding failed:\n{error_msg}")
        shutil.copyfile(silent_video_path, final_output)
        return final_output

    def process_video_thread(self):
        final_output = None
        error_text = None
        try:
            cap = cv2.VideoCapture(self.video_path)
            if not cap.isOpened():
                raise RuntimeError("could not open the selected video")
            mask_img = None
            if self.mask_path and os.path.exists(self.mask_path):
                mask_img = cv2.imread(self.mask_path, 0)
            fps = cap.get(cv2.CAP_PROP_FPS)
            if not fps or fps <= 0:
                fps = 30
            orig_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            orig_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            if total_frames <= 0:
                total_frames = 1
            if mask_img is not None:
                mask_img = cv2.resize(mask_img, (orig_w, orig_h), interpolation=cv2.INTER_NEAREST)
            scale_factor = 2
            new_w = orig_w * scale_factor
            new_h = orig_h * scale_factor
            silent_output_path = ProjectManager.build_paths(self.video_path)["silent_output_path"]
            os.makedirs(self.project_data["project_dir"], exist_ok=True)
            fourcc = cv2.VideoWriter_fourcc(*"mp4v")
            out = cv2.VideoWriter(silent_output_path, fourcc, fps, (new_w, new_h))
            sharpen_kernel = np.array([[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]])
            sharpness_strength = 0.5
            wm_rgba = None
            final_wm_x = 0
            final_wm_y = 0
            wm_path = self.project_data.get("wm_path", "")
            if wm_path and os.path.exists(wm_path):
                wm_pil = Image.open(wm_path).convert("RGBA")
                wm_scale = float(self.project_data.get("wm_scale", 1.0))
                target_w = int(wm_pil.width * wm_scale * scale_factor)
                target_h = int(wm_pil.height * wm_scale * scale_factor)
                if target_w > 0 and target_h > 0:
                    wm_rgba = wm_pil.resize((target_w, target_h), Image.Resampling.LANCZOS)
                    final_wm_x = int(float(self.project_data.get("wm_x", 50.0)) * scale_factor)
                    final_wm_y = int(float(self.project_data.get("wm_y", 50.0)) * scale_factor)
            update_step = max(1, total_frames // 100)
            for i in range(total_frames):
                ret, frame = cap.read()
                if not ret:
                    break
                if mask_img is not None:
                    clean_frame = cv2.inpaint(frame, mask_img, 3, cv2.INPAINT_NS)
                else:
                    clean_frame = frame
                upscaled = cv2.resize(clean_frame, (new_w, new_h), interpolation=cv2.INTER_LANCZOS4)
                sharpened = cv2.filter2D(upscaled, -1, sharpen_kernel)
                final_frame = cv2.addWeighted(sharpened, sharpness_strength, upscaled, 1.0 - sharpness_strength, 0)
                if wm_rgba is not None:
                    frame_pil = Image.fromarray(cv2.cvtColor(final_frame, cv2.COLOR_BGR2RGB)).convert("RGBA")
                    frame_pil.paste(wm_rgba, (final_wm_x, final_wm_y), wm_rgba)
                    final_frame = cv2.cvtColor(np.array(frame_pil), cv2.COLOR_RGBA2BGR)
                out.write(final_frame)
                if i % update_step == 0 or i == total_frames - 1:
                    progress_val = (i + 1) / total_frames
                    self.after(0, lambda p=progress_val: self.update_progress_ui(p, f"processing frames... {int(p * 100)}%"))
            cap.release()
            out.release()
            self.after(0, lambda: self.update_progress_ui(0.96, "merging original audio..."))
            final_output = self.finalize_output_with_audio(silent_output_path)
            self.project_data["output_path"] = final_output
            self.project_data["status"] = "processed"
            ProjectManager.save(self.project_data)
        except Exception as e:
            error_text = str(e)
        self.after(0, lambda: self.finish_processing_ui(final_output, error_text))

    def update_progress_ui(self, progress_value, text):
        self.progress_bar.set(progress_value)
        self.lbl_progress.configure(text=text)

    def finish_processing_ui(self, final_output, error_text):
        self.processing_active = False
        if error_text:
            self.lbl_progress.configure(text="processing failed.")
            messagebox.showerror("Processing failed", error_text)
        else:
            self.progress_bar.set(1)
            self.lbl_progress.configure(text=f"done. final export saved to\n{final_output}")
            messagebox.showinfo("Processing complete", "Video processing completed successfully.")
        self.refresh_project_state()

    def start_ai_generation(self):
        if not self.project_data:
            return
        if not ConfigManager.is_gemini_configured(self.config_data):
            messagebox.showwarning("Gemini not configured", "Please add at least one gemini api key in settings.")
            self.show_frame("settings")
            return
        self.save_project_snapshot_from_ui()
        description = self.project_data.get("note_text", "").strip()
        if not description:
            messagebox.showwarning("Missing context", "Please write a short video description first.")
            return
        language = "english"
        if hasattr(self, "opt_ai_language"):
            language = self.opt_ai_language.get()
        self.ai_active = True
        self.lbl_progress.configure(text=f"generating ai content in {language}...")
        self.refresh_project_state()
        threading.Thread(target=self.generate_ai_thread, args=(description, language), daemon=True).start()

    def generate_ai_thread(self, description, language="english"):
        result = None
        error_text = None
        try:
            result = GeminiManager.generate_social_pack(self.config_data, description, self.video_path, language)
            self.project_data["identified_topic"] = result.get("identified_topic", "")
            self.project_data["ai_instagram_caption"] = result.get("instagram_caption", "")
            self.project_data["ai_instagram_hashtags"] = result.get("instagram_hashtags", "")
            self.project_data["ai_youtube_title"] = result.get("youtube_title", "")
            self.project_data["ai_youtube_description"] = result.get("youtube_description", "")
            self.project_data["ai_youtube_hashtags"] = result.get("youtube_hashtags", "")
            self.project_data["status"] = "ai_ready"
            ProjectManager.save(self.project_data)
        except Exception as e:
            error_text = str(e)
        self.after(0, lambda: self.finish_ai_ui(result, error_text))

    def finish_ai_ui(self, result, error_text):
        self.ai_active = False
        if error_text:
            self.lbl_progress.configure(text="ai generation failed.")
            messagebox.showerror("AI generation failed", error_text)
        else:
            self.loading_project_to_ui = True
            self.set_entry_value(self.ent_topic, self.project_data.get("identified_topic", ""))
            self.set_textbox_value(self.txt_instagram_caption, self.project_data.get("ai_instagram_caption", ""))
            self.set_textbox_value(self.txt_instagram_tags, self.project_data.get("ai_instagram_hashtags", ""))
            self.set_entry_value(self.ent_youtube_title, self.project_data.get("ai_youtube_title", ""))
            self.set_textbox_value(self.txt_youtube_description, self.project_data.get("ai_youtube_description", ""))
            self.set_textbox_value(self.txt_youtube_tags, self.project_data.get("ai_youtube_hashtags", ""))
            self.loading_project_to_ui = False
            self.lbl_progress.configure(text="ai caption and hashtags generated successfully.")
            messagebox.showinfo("AI complete", "Caption and hashtag pack was generated successfully.")
        self.refresh_project_state()

    def on_app_close(self):
        try:
            self.save_project_snapshot_from_ui()
        except:
            pass
        self.destroy()


if __name__ == "__main__":
    import traceback
    try:
        app = SmartVideoEditor()
        app.mainloop()
    except Exception:
        error_text = traceback.format_exc()
        error_file = os.path.join(BASE_DIR, "startup_error.log")
        with open(error_file, "w", encoding="utf-8") as f:
            f.write(error_text)
        print(error_text)
        try:
            messagebox.showerror("Startup Error", error_text)
        except:
            pass
        input("press enter to exit...")