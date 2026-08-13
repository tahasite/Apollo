import os
import cv2
import customtkinter as ctk
from tkinter import messagebox
from PIL import Image, ImageTk, ImageDraw
from core.project_manager import ProjectManager
from core.ui_helpers import APP_FONT

BG_DARK = "#0a0a0f"
BG_CARD = "#12121a"
BG_SURFACE = "#0f0f18"
ACCENT_AMBER = "#f59e0b"
ACCENT_RED = "#ef4444"
ACCENT_GREEN = "#22c55e"
TEXT_PRIMARY = "#f1f5f9"
TEXT_SECONDARY = "#94a3b8"
TEXT_DIM = "#475569"
BORDER_DIM = "#1e1e2e"


class MaskEditor:
    def __init__(self, app):
        self.app = app

    def open(self):
        app = self.app
        if not app.video_path:
            messagebox.showwarning("No video", "Please select a video first.")
            return
        if app.mask_frame:
            app.mask_frame.destroy()
            app.mask_frame = None
        try:
            app.mask_frame = ctk.CTkFrame(app.main_container, fg_color=BG_DARK)

            top_bar = ctk.CTkFrame(app.mask_frame, height=50, fg_color=BG_CARD, corner_radius=0)
            top_bar.pack(fill="x")
            top_bar.pack_propagate(False)

            ctk.CTkLabel(top_bar, text="🎭  mask editor", font=(APP_FONT, 16, "bold"), text_color=TEXT_PRIMARY).pack(side="left", padx=16)

            ctk.CTkButton(top_bar, text="✓ save", font=(APP_FONT, 13, "bold"), command=self.close, fg_color=ACCENT_GREEN, hover_color="#16a34a", width=90, height=32, corner_radius=8).pack(side="right", padx=(4, 14), pady=9)
            ctk.CTkButton(top_bar, text="✕ cancel", font=(APP_FONT, 13), command=self.cancel, fg_color=ACCENT_RED, hover_color="#dc2626", width=90, height=32, corner_radius=8).pack(side="right", padx=4, pady=9)
            ctk.CTkButton(top_bar, text="🗑 clear", font=(APP_FONT, 13), command=lambda: self.canvas_op("clear"), fg_color=BORDER_DIM, hover_color=TEXT_DIM, width=80, height=32, corner_radius=8).pack(side="right", padx=4, pady=9)
            ctk.CTkButton(top_bar, text="↩ undo", font=(APP_FONT, 13), command=lambda: self.canvas_op("undo"), fg_color=BORDER_DIM, hover_color=TEXT_DIM, width=80, height=32, corner_radius=8).pack(side="right", padx=4, pady=9)

            toolbar = ctk.CTkFrame(app.mask_frame, height=44, fg_color=BG_SURFACE)
            toolbar.pack(fill="x", padx=6, pady=(4, 0))
            toolbar.pack_propagate(False)

            ctk.CTkLabel(toolbar, text="brush", font=(APP_FONT, 12), text_color=TEXT_SECONDARY).pack(side="left", padx=(14, 6))
            self.slider = ctk.CTkSlider(toolbar, from_=3, to=120, command=lambda v: self.canvas_op("brush", v), width=160, height=16, button_color=ACCENT_AMBER, progress_color=ACCENT_AMBER)
            self.slider.set(15)
            self.slider.pack(side="left", padx=(0, 10))
            self.lbl_brush_size = ctk.CTkLabel(toolbar, text="15px", font=(APP_FONT, 11), text_color=TEXT_DIM, width=40)
            self.lbl_brush_size.pack(side="left")

            sep1 = ctk.CTkFrame(toolbar, width=1, height=24, fg_color=BORDER_DIM)
            sep1.pack(side="left", padx=12)

            ctk.CTkButton(toolbar, text="🔍+", font=(APP_FONT, 13), width=40, height=28, fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=lambda: self.canvas_op("zoom_in")).pack(side="left", padx=2)
            ctk.CTkButton(toolbar, text="🔍−", font=(APP_FONT, 13), width=40, height=28, fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=lambda: self.canvas_op("zoom_out")).pack(side="left", padx=2)
            self.lbl_zoom = ctk.CTkLabel(toolbar, text="100%", font=(APP_FONT, 11), text_color=TEXT_DIM, width=50)
            self.lbl_zoom.pack(side="left", padx=(4, 0))

            sep2 = ctk.CTkFrame(toolbar, width=1, height=24, fg_color=BORDER_DIM)
            sep2.pack(side="left", padx=12)

            shortcuts_text = "shortcuts:  LMB draw  ·  RMB pan  ·  Ctrl+Z undo  ·  Ctrl+0 reset zoom  ·  [ ] brush size"
            ctk.CTkLabel(toolbar, text=shortcuts_text, font=(APP_FONT, 10), text_color=TEXT_DIM).pack(side="left", padx=8)

            canvas_frame = ctk.CTkFrame(app.mask_frame, fg_color=BG_DARK, corner_radius=0)
            canvas_frame.pack(fill="both", expand=True, padx=6, pady=6)
            self.canvas = ctk.CTkCanvas(canvas_frame, bg="#0a0a0f", highlightthickness=0)
            self.canvas.pack(fill="both", expand=True)

            self.init_engine()
            for f in app.frames.values():
                f.grid_remove()
            if app.watermark_frame:
                app.watermark_frame.grid_remove()
            app.mask_frame.grid(row=0, column=0, sticky="nsew")
        except Exception as e:
            if app.mask_frame:
                app.mask_frame.destroy()
                app.mask_frame = None
            messagebox.showerror("Mask editor failed", str(e))

    def init_engine(self):
        app = self.app
        cap = cv2.VideoCapture(app.video_path)
        ret, frame = cap.read()
        cap.release()
        if not ret or frame is None:
            raise RuntimeError("could not read the first frame from the selected video")
        self.cv_image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        self.orig_h, self.orig_w = self.cv_image.shape[:2]
        if app.mask_path and os.path.exists(app.mask_path):
            try:
                loaded_mask = Image.open(app.mask_path).convert("L")
                if loaded_mask.size != (self.orig_w, self.orig_h):
                    loaded_mask = loaded_mask.resize((self.orig_w, self.orig_h), Image.Resampling.NEAREST)
                self.mask = loaded_mask
            except:
                self.mask = Image.new("L", (self.orig_w, self.orig_h), 0)
        else:
            self.mask = Image.new("L", (self.orig_w, self.orig_h), 0)
        self.brush = 15
        self.zoom = 1.0
        self.history = []
        self.drawing = False
        self.canvas.bind("<ButtonPress-1>", self.start_draw)
        self.canvas.bind("<B1-Motion>", self.draw)
        self.canvas.bind("<ButtonRelease-1>", self.stop_draw)
        self.canvas.bind("<ButtonPress-3>", lambda e: self.canvas.scan_mark(e.x, e.y))
        self.canvas.bind("<B3-Motion>", lambda e: self.canvas.scan_dragto(e.x, e.y, gain=1))
        self.canvas.bind("<MouseWheel>", self.on_scroll_zoom)
        self.canvas.bind("<Control-z>", lambda e: self.canvas_op("undo"))
        self.canvas.bind("<Control-Z>", lambda e: self.canvas_op("undo"))
        self.canvas.bind("<Control-0>", lambda e: self.reset_zoom())
        self.canvas.bind("<bracketleft>", lambda e: self.adjust_brush(-3))
        self.canvas.bind("<bracketright>", lambda e: self.adjust_brush(3))
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

    def adjust_brush(self, delta):
        self.brush = max(1, min(200, self.brush + delta))
        self.slider.set(self.brush)
        self.lbl_brush_size.configure(text=f"{self.brush}px")

    def canvas_op(self, op, val=None):
        if op == "clear":
            self.history.append(self.mask.copy())
            self.mask = Image.new("L", (self.orig_w, self.orig_h), 0)
        elif op == "undo":
            if self.history:
                self.mask = self.history.pop()
        elif op == "brush":
            self.brush = int(float(val))
            self.lbl_brush_size.configure(text=f"{self.brush}px")
        elif op == "zoom_in":
            self.zoom = min(5.0, self.zoom + 0.15)
            self.lbl_zoom.configure(text=f"{int(self.zoom * 100)}%")
        elif op == "zoom_out":
            self.zoom = max(0.15, self.zoom - 0.15)
            self.lbl_zoom.configure(text=f"{int(self.zoom * 100)}%")
        if op in ["clear", "undo", "zoom_in", "zoom_out"]:
            self.update_canvas()

    def start_draw(self, event):
        self.history.append(self.mask.copy())
        if len(self.history) > 30:
            self.history.pop(0)
        self.drawing = True
        self.draw(event)

    def draw(self, event):
        if not self.drawing:
            return
        x = int(self.canvas.canvasx(event.x) / self.zoom)
        y = int(self.canvas.canvasy(event.y) / self.zoom)
        draw = ImageDraw.Draw(self.mask)
        draw.ellipse([x - self.brush, y - self.brush, x + self.brush, y + self.brush], fill=255)
        self.update_canvas()

    def stop_draw(self, event):
        self.drawing = False

    def update_canvas(self):
        base_img = Image.fromarray(self.cv_image)
        red_mask = Image.new("RGBA", base_img.size, (255, 60, 60, 100))
        mask_rgba = Image.new("RGBA", base_img.size, (0, 0, 0, 0))
        mask_rgba.paste(red_mask, (0, 0), self.mask)
        composite = Image.alpha_composite(base_img.convert("RGBA"), mask_rgba)
        new_w = int(self.orig_w * self.zoom)
        new_h = int(self.orig_h * self.zoom)
        resized = composite.resize((new_w, new_h), Image.Resampling.NEAREST)
        self.tk_img = ImageTk.PhotoImage(resized)
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, anchor="nw", image=self.tk_img)
        self.canvas.config(scrollregion=self.canvas.bbox("all"))

    def close(self):
        app = self.app
        if not app.project_data:
            self.cancel()
            return
        os.makedirs(app.project_data["project_dir"], exist_ok=True)
        self.mask.save(app.mask_path)
        app.project_data["status"] = "mask_ready"
        ProjectManager.save(app.project_data)
        if app.mask_frame:
            app.mask_frame.destroy()
            app.mask_frame = None
        app.show_frame("dashboard")
        app.lbl_progress.configure(text="mask saved successfully.")
        app.refresh_project_state()

    def cancel(self):
        app = self.app
        if app.mask_frame:
            app.mask_frame.destroy()
            app.mask_frame = None
        app.show_frame("dashboard")