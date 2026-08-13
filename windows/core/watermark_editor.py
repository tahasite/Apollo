import os
import cv2
import customtkinter as ctk
from tkinter import filedialog, messagebox
from PIL import Image, ImageTk
from core.config_manager import ConfigManager
from core.project_manager import ProjectManager
from core.ui_helpers import APP_FONT

BG_DARK = "#0a0a0f"
BG_CARD = "#12121a"
BG_SURFACE = "#0f0f18"
ACCENT_CYAN = "#06b6d4"
ACCENT_RED = "#ef4444"
ACCENT_GREEN = "#22c55e"
TEXT_PRIMARY = "#f1f5f9"
TEXT_SECONDARY = "#94a3b8"
TEXT_DIM = "#475569"
BORDER_DIM = "#1e1e2e"


class WatermarkEditor:
    def __init__(self, app):
        self.app = app

    def open(self):
        app = self.app
        if not app.project_data:
            messagebox.showwarning("No project", "Please select a video first.")
            return
        current_wm_path = app.project_data.get("wm_path", "")
        if not current_wm_path or not os.path.exists(current_wm_path):
            fallback_path = app.config_data.get("wm_path", "")
            if fallback_path and os.path.exists(fallback_path):
                app.project_data["wm_path"] = fallback_path
                app.project_data["wm_scale"] = float(app.config_data.get("wm_scale", 1.0))
                app.project_data["wm_x"] = float(app.config_data.get("wm_x", 50.0))
                app.project_data["wm_y"] = float(app.config_data.get("wm_y", 50.0))
                ProjectManager.save(app.project_data)
            else:
                file_path = filedialog.askopenfilename(title="Choose watermark image", filetypes=[("Image Files", "*.png")])
                if not file_path:
                    return
                app.project_data["wm_path"] = file_path
                app.config_data["wm_path"] = file_path
                ConfigManager.save(app.config_data)
                ProjectManager.save(app.project_data)
        if app.watermark_frame:
            app.watermark_frame.destroy()
            app.watermark_frame = None
        try:
            app.watermark_frame = ctk.CTkFrame(app.main_container, fg_color=BG_DARK)

            top_bar = ctk.CTkFrame(app.watermark_frame, height=50, fg_color=BG_CARD, corner_radius=0)
            top_bar.pack(fill="x")
            top_bar.pack_propagate(False)

            ctk.CTkLabel(top_bar, text="💧  watermark editor", font=(APP_FONT, 16, "bold"), text_color=TEXT_PRIMARY).pack(side="left", padx=16)

            ctk.CTkButton(top_bar, text="✓ save", font=(APP_FONT, 13, "bold"), command=self.close, fg_color=ACCENT_GREEN, hover_color="#16a34a", width=90, height=32, corner_radius=8).pack(side="right", padx=(4, 14), pady=9)
            ctk.CTkButton(top_bar, text="✕ cancel", font=(APP_FONT, 13), command=self.cancel, fg_color=ACCENT_RED, hover_color="#dc2626", width=90, height=32, corner_radius=8).pack(side="right", padx=4, pady=9)
            ctk.CTkButton(top_bar, text="🖼 change image", font=(APP_FONT, 13), command=self.change_file, fg_color=ACCENT_CYAN, hover_color="#0891b2", width=130, height=32, corner_radius=8).pack(side="right", padx=4, pady=9)

            toolbar = ctk.CTkFrame(app.watermark_frame, height=44, fg_color=BG_SURFACE)
            toolbar.pack(fill="x", padx=6, pady=(4, 0))
            toolbar.pack_propagate(False)

            ctk.CTkLabel(toolbar, text="scale", font=(APP_FONT, 12), text_color=TEXT_SECONDARY).pack(side="left", padx=(14, 6))
            self.slider = ctk.CTkSlider(toolbar, from_=0.01, to=3.0, command=self.change_scale, width=160, height=16, button_color=ACCENT_CYAN, progress_color=ACCENT_CYAN)
            self.slider.set(float(app.project_data.get("wm_scale", 1.0)))
            self.slider.pack(side="left", padx=(0, 10))
            self.lbl_scale = ctk.CTkLabel(toolbar, text="100%", font=(APP_FONT, 11), text_color=TEXT_DIM, width=50)
            self.lbl_scale.pack(side="left")

            sep1 = ctk.CTkFrame(toolbar, width=1, height=24, fg_color=BORDER_DIM)
            sep1.pack(side="left", padx=12)

            ctk.CTkButton(toolbar, text="🔍+", font=(APP_FONT, 13), width=40, height=28, fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=lambda: self.canvas_op("zoom_in")).pack(side="left", padx=2)
            ctk.CTkButton(toolbar, text="🔍−", font=(APP_FONT, 13), width=40, height=28, fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=lambda: self.canvas_op("zoom_out")).pack(side="left", padx=2)
            self.lbl_zoom = ctk.CTkLabel(toolbar, text="100%", font=(APP_FONT, 11), text_color=TEXT_DIM, width=50)
            self.lbl_zoom.pack(side="left", padx=(4, 0))

            sep2 = ctk.CTkFrame(toolbar, width=1, height=24, fg_color=BORDER_DIM)
            sep2.pack(side="left", padx=12)

            pos_frame = ctk.CTkFrame(toolbar, fg_color="transparent")
            pos_frame.pack(side="left", padx=4)
            ctk.CTkLabel(pos_frame, text="pos:", font=(APP_FONT, 11), text_color=TEXT_DIM).pack(side="left")
            self.lbl_pos = ctk.CTkLabel(pos_frame, text="x:50  y:50", font=(APP_FONT, 11), text_color=TEXT_SECONDARY, width=90)
            self.lbl_pos.pack(side="left", padx=(4, 0))

            sep3 = ctk.CTkFrame(toolbar, width=1, height=24, fg_color=BORDER_DIM)
            sep3.pack(side="left", padx=12)

            shortcuts_text = "LMB drag  ·  RMB pan  ·  scroll zoom  ·  Ctrl+0 reset  ·  +/− scale"
            ctk.CTkLabel(toolbar, text=shortcuts_text, font=(APP_FONT, 10), text_color=TEXT_DIM).pack(side="left", padx=8)

            canvas_frame = ctk.CTkFrame(app.watermark_frame, fg_color=BG_DARK, corner_radius=0)
            canvas_frame.pack(fill="both", expand=True, padx=6, pady=6)
            self.canvas = ctk.CTkCanvas(canvas_frame, bg="#0a0a0f", highlightthickness=0)
            self.canvas.pack(fill="both", expand=True)

            self.init_engine()
            for f in app.frames.values():
                f.grid_remove()
            if app.mask_frame:
                app.mask_frame.grid_remove()
            app.watermark_frame.grid(row=0, column=0, sticky="nsew")
        except Exception as e:
            if app.watermark_frame:
                app.watermark_frame.destroy()
                app.watermark_frame = None
            messagebox.showerror("Watermark editor failed", str(e))

    def init_engine(self):
        app = self.app
        cap = cv2.VideoCapture(app.video_path)
        ret, frame = cap.read()
        cap.release()
        if not ret or frame is None:
            raise RuntimeError("could not read the first frame from the selected video")
        self.cv_image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        self.orig_h, self.orig_w = self.cv_image.shape[:2]
        self.bg_image = Image.fromarray(self.cv_image)
        wm_path = app.project_data.get("wm_path", "")
        if not wm_path or not os.path.exists(wm_path):
            raise RuntimeError("watermark file was not found")
        self.wm_image = Image.open(wm_path).convert("RGBA")
        self.scale = float(app.project_data.get("wm_scale", 1.0))
        self.x = float(app.project_data.get("wm_x", 50.0))
        self.y = float(app.project_data.get("wm_y", 50.0))
        self.zoom = 1.0
        self.dragging = False
        self.lbl_scale.configure(text=f"{int(self.scale * 100)}%")
        self.lbl_pos.configure(text=f"x:{int(self.x)}  y:{int(self.y)}")
        self.canvas.bind("<ButtonPress-1>", self.start_drag)
        self.canvas.bind("<B1-Motion>", self.drag)
        self.canvas.bind("<ButtonRelease-1>", self.stop_drag)
        self.canvas.bind("<ButtonPress-3>", lambda e: self.canvas.scan_mark(e.x, e.y))
        self.canvas.bind("<B3-Motion>", lambda e: self.canvas.scan_dragto(e.x, e.y, gain=1))
        self.canvas.bind("<MouseWheel>", self.on_scroll_zoom)
        self.canvas.bind("<Control-0>", lambda e: self.reset_zoom())
        self.canvas.bind("<plus>", lambda e: self.adjust_scale(0.05))
        self.canvas.bind("<equal>", lambda e: self.adjust_scale(0.05))
        self.canvas.bind("<minus>", lambda e: self.adjust_scale(-0.05))
        self.canvas.focus_set()
        self.update_canvas()

    def on_scroll_zoom(self, event):
        if event.delta > 0:
            self.canvas_op("zoom_in")
        else:
            self.canvas_op("zoom_out")

    def reset_zoom(self):
        self.zoom = 1.0
        self.lbl_zoom.configure(text="100%")
        self.update_canvas()

    def adjust_scale(self, delta):
        self.scale = max(0.01, min(5.0, self.scale + delta))
        self.slider.set(self.scale)
        self.lbl_scale.configure(text=f"{int(self.scale * 100)}%")
        self.update_canvas()

    def canvas_op(self, op):
        if op == "zoom_in":
            self.zoom = min(5.0, self.zoom + 0.15)
            self.lbl_zoom.configure(text=f"{int(self.zoom * 100)}%")
        elif op == "zoom_out":
            self.zoom = max(0.15, self.zoom - 0.15)
            self.lbl_zoom.configure(text=f"{int(self.zoom * 100)}%")
        self.update_canvas()

    def change_scale(self, value):
        self.scale = float(value)
        self.lbl_scale.configure(text=f"{int(self.scale * 100)}%")
        self.update_canvas()

    def start_drag(self, event):
        real_x = self.canvas.canvasx(event.x) / self.zoom
        real_y = self.canvas.canvasy(event.y) / self.zoom
        wm_w = int(self.wm_image.width * self.scale)
        wm_h = int(self.wm_image.height * self.scale)
        if wm_w > 0 and wm_h > 0:
            if self.x <= real_x <= self.x + wm_w and self.y <= real_y <= self.y + wm_h:
                self.dragging = True
                self.drag_start_x = self.canvas.canvasx(event.x)
                self.drag_start_y = self.canvas.canvasy(event.y)

    def drag(self, event):
        if self.dragging:
            cx = self.canvas.canvasx(event.x)
            cy = self.canvas.canvasy(event.y)
            dx = cx - self.drag_start_x
            dy = cy - self.drag_start_y
            self.x += dx / self.zoom
            self.y += dy / self.zoom
            self.drag_start_x = cx
            self.drag_start_y = cy
            self.lbl_pos.configure(text=f"x:{int(self.x)}  y:{int(self.y)}")
            self.update_canvas()

    def stop_drag(self, event):
        self.dragging = False

    def update_canvas(self):
        canvas_img = self.bg_image.copy().convert("RGBA")
        current_wm_w = int(self.wm_image.width * self.scale)
        current_wm_h = int(self.wm_image.height * self.scale)
        if current_wm_w > 0 and current_wm_h > 0:
            wm_resized = self.wm_image.resize((current_wm_w, current_wm_h), Image.Resampling.LANCZOS)
            canvas_img.paste(wm_resized, (int(self.x), int(self.y)), wm_resized)
        new_w = int(self.orig_w * self.zoom)
        new_h = int(self.orig_h * self.zoom)
        resized = canvas_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        self.tk_img = ImageTk.PhotoImage(resized)
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, anchor="nw", image=self.tk_img)
        if current_wm_w > 0 and current_wm_h > 0:
            x1 = self.x * self.zoom
            y1 = self.y * self.zoom
            x2 = (self.x + current_wm_w) * self.zoom
            y2 = (self.y + current_wm_h) * self.zoom
            self.canvas.create_rectangle(x1, y1, x2, y2, outline=ACCENT_CYAN, width=2, dash=(6, 3))
        self.canvas.config(scrollregion=self.canvas.bbox("all"))

    def change_file(self):
        app = self.app
        file_path = filedialog.askopenfilename(title="Choose watermark image", filetypes=[("Image Files", "*.png")])
        if file_path:
            app.project_data["wm_path"] = file_path
            app.config_data["wm_path"] = file_path
            ConfigManager.save(app.config_data)
            ProjectManager.save(app.project_data)
            self.wm_image = Image.open(file_path).convert("RGBA")
            self.update_canvas()

    def close(self):
        app = self.app
        if not app.project_data:
            self.cancel()
            return
        app.project_data["wm_scale"] = float(self.scale)
        app.project_data["wm_x"] = float(self.x)
        app.project_data["wm_y"] = float(self.y)
        app.config_data["wm_path"] = app.project_data.get("wm_path", "")
        app.config_data["wm_scale"] = float(self.scale)
        app.config_data["wm_x"] = float(self.x)
        app.config_data["wm_y"] = float(self.y)
        ConfigManager.save(app.config_data)
        app.project_data["status"] = "watermark_ready"
        ProjectManager.save(app.project_data)
        if app.watermark_frame:
            app.watermark_frame.destroy()
            app.watermark_frame = None
        app.show_frame("dashboard")
        app.lbl_progress.configure(text="watermark settings saved successfully.")
        app.refresh_project_state()

    def cancel(self):
        app = self.app
        if app.watermark_frame:
            app.watermark_frame.destroy()
            app.watermark_frame = None
        app.show_frame("dashboard")