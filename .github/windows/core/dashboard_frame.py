import os
import customtkinter as ctk
from core.ui_helpers import APP_FONT
from core.config_manager import DEFAULT_MODEL_NAME

ACCENT_BLUE = "#3b82f6"
ACCENT_PURPLE = "#8b5cf6"
ACCENT_GREEN = "#22c55e"
ACCENT_AMBER = "#f59e0b"
ACCENT_CYAN = "#06b6d4"
ACCENT_RED = "#ef4444"
BG_DARK = "#0a0a0f"
BG_CARD = "#12121a"
BG_CARD_HOVER = "#1a1a28"
BG_SURFACE = "#0f0f18"
BG_INPUT = "#16161f"
BORDER_DIM = "#1e1e2e"
TEXT_PRIMARY = "#f1f5f9"
TEXT_SECONDARY = "#94a3b8"
TEXT_DIM = "#475569"


class DashboardFrame:
    def __init__(self, app):
        self.app = app

    def setup(self):
        app = self.app
        frame = ctk.CTkFrame(app.main_container, fg_color=BG_DARK)
        app.frames["dashboard"] = frame

        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)

        top_bar = ctk.CTkFrame(frame, height=52, fg_color=BG_CARD, corner_radius=12)
        top_bar.grid(row=0, column=0, sticky="ew", padx=6, pady=(6, 4))
        top_bar.grid_propagate(False)
        top_bar.grid_columnconfigure(1, weight=1)

        left_top = ctk.CTkFrame(top_bar, fg_color="transparent")
        left_top.grid(row=0, column=0, sticky="w", padx=14, pady=8)

        app.lbl_video = ctk.CTkLabel(left_top, text="no file loaded", font=(APP_FONT, 13, "bold"), text_color=TEXT_SECONDARY, anchor="w")
        app.lbl_video.pack(side="left")

        center_top = ctk.CTkFrame(top_bar, fg_color="transparent")
        center_top.grid(row=0, column=1, sticky="ew", padx=10, pady=8)

        app.progress_bar = ctk.CTkProgressBar(center_top, height=6, corner_radius=3, progress_color=ACCENT_BLUE, fg_color=BORDER_DIM)
        app.progress_bar.pack(fill="x", side="top", pady=(6, 2))
        app.progress_bar.set(0)
        app.lbl_progress = ctk.CTkLabel(center_top, text="ready", font=(APP_FONT, 10), text_color=TEXT_DIM, anchor="w")
        app.lbl_progress.pack(fill="x", side="top")

        right_top = ctk.CTkFrame(top_bar, fg_color="transparent")
        right_top.grid(row=0, column=2, sticky="e", padx=14, pady=8)

        app.lbl_status = ctk.CTkLabel(right_top, text="● idle", font=(APP_FONT, 11), text_color=TEXT_DIM)
        app.lbl_status.pack(side="right")

        body = ctk.CTkFrame(frame, fg_color="transparent")
        body.grid(row=1, column=0, sticky="nsew", padx=6, pady=(0, 6))
        body.grid_columnconfigure(0, weight=0, minsize=260)
        body.grid_columnconfigure(1, weight=1)
        body.grid_rowconfigure(0, weight=1)

        left_panel = ctk.CTkFrame(body, fg_color=BG_CARD, corner_radius=12, width=260)
        left_panel.grid(row=0, column=0, sticky="nsew", padx=(0, 4))
        left_panel.grid_propagate(False)
        left_panel.grid_rowconfigure(1, weight=1)

        panel_header = ctk.CTkFrame(left_panel, fg_color="transparent")
        panel_header.grid(row=0, column=0, sticky="ew", padx=14, pady=(14, 6))

        ctk.CTkLabel(panel_header, text="tools", font=(APP_FONT, 15, "bold"), text_color=TEXT_PRIMARY).pack(side="left")

        tools_scroll = ctk.CTkScrollableFrame(left_panel, fg_color="transparent", scrollbar_button_color=BORDER_DIM, scrollbar_button_hover_color=TEXT_DIM)
        tools_scroll.grid(row=1, column=0, sticky="nsew", padx=4, pady=(0, 8))

        self.build_tool_card(
            tools_scroll,
            icon="📂", title="import",
            desc="load video file",
            color=ACCENT_BLUE,
            command=app.select_video,
            attr="btn_step1"
        )
        self.build_tool_card(
            tools_scroll,
            icon="🎭", title="mask",
            desc="remove watermarks",
            color=ACCENT_AMBER,
            command=app.open_mask_editor,
            attr="btn_step2"
        )
        self.build_tool_card(
            tools_scroll,
            icon="💧", title="watermark",
            desc="add your branding",
            color=ACCENT_CYAN,
            command=app.open_watermark_editor,
            attr="btn_step3"
        )
        self.build_tool_card(
            tools_scroll,
            icon="⚡", title="render",
            desc="export final video",
            color=ACCENT_GREEN,
            command=app.start_processing,
            attr="btn_step4"
        )
        self.build_tool_card(
            tools_scroll,
            icon="✨", title="ai generate",
            desc="captions and hashtags",
            color=ACCENT_PURPLE,
            command=app.start_ai_generation,
            attr="btn_step5"
        )

        project_mini = ctk.CTkFrame(left_panel, fg_color=BG_SURFACE, corner_radius=8)
        project_mini.grid(row=2, column=0, sticky="ew", padx=10, pady=(0, 12))

        app.lbl_project = ctk.CTkLabel(project_mini, text="📂 no project", font=(APP_FONT, 10), text_color=TEXT_DIM, anchor="w")
        app.lbl_project.pack(fill="x", padx=10, pady=(8, 2))
        app.lbl_output = ctk.CTkLabel(project_mini, text="📦 no export", font=(APP_FONT, 10), text_color=TEXT_DIM, anchor="w")
        app.lbl_output.pack(fill="x", padx=10, pady=(0, 4))

        mini_btns = ctk.CTkFrame(project_mini, fg_color="transparent")
        mini_btns.pack(fill="x", padx=8, pady=(0, 8))
        app.btn_open_project = ctk.CTkButton(mini_btns, text="📁", width=36, height=28, font=(APP_FONT, 14), fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=app.open_project_folder)
        app.btn_open_project.pack(side="left", padx=(0, 4))
        app.btn_reload_video = ctk.CTkButton(mini_btns, text="🔄", width=36, height=28, font=(APP_FONT, 14), fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=app.select_video)
        app.btn_reload_video.pack(side="left")
        app.lbl_model = ctk.CTkLabel(mini_btns, text=f"🤖 {app.config_data.get('gemini_model', DEFAULT_MODEL_NAME)}", font=(APP_FONT, 9), text_color=TEXT_DIM)
        app.lbl_model.pack(side="right")

        right_panel = ctk.CTkFrame(body, fg_color=BG_CARD, corner_radius=12)
        right_panel.grid(row=0, column=1, sticky="nsew", padx=(4, 0))
        right_panel.grid_rowconfigure(1, weight=1)
        right_panel.grid_columnconfigure(0, weight=1)

        workspace_header = ctk.CTkFrame(right_panel, fg_color="transparent")
        workspace_header.grid(row=0, column=0, sticky="ew", padx=16, pady=(14, 4))
        ctk.CTkLabel(workspace_header, text="✨  ai content studio", font=(APP_FONT, 16, "bold"), text_color=TEXT_PRIMARY).pack(side="left")

        workspace_body = ctk.CTkScrollableFrame(right_panel, fg_color="transparent", scrollbar_button_color=BORDER_DIM, scrollbar_button_hover_color=TEXT_DIM)
        workspace_body.grid(row=1, column=0, sticky="nsew", padx=6, pady=(0, 8))

        context_card = ctk.CTkFrame(workspace_body, fg_color=BG_SURFACE, corner_radius=10)
        context_card.pack(fill="x", padx=8, pady=(0, 8))

        ctx_header = ctk.CTkFrame(context_card, fg_color="transparent")
        ctx_header.pack(fill="x", padx=12, pady=(10, 4))
        ctk.CTkLabel(ctx_header, text="📝 video description", font=(APP_FONT, 13, "bold"), text_color=TEXT_PRIMARY).pack(side="left")
        ctk.CTkButton(ctx_header, text="copy", width=50, height=22, font=(APP_FONT, 10), fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=5, command=lambda: app.copy_textbox_content(app.txt_context, "Context")).pack(side="right")

        app.txt_context = ctk.CTkTextbox(context_card, height=75, font=("Tahoma", 13), fg_color=BG_INPUT, border_width=1, border_color=BORDER_DIM, corner_radius=8)
        app.txt_context.pack(fill="x", padx=12, pady=(0, 10))
        app.txt_context.bind("<KeyRelease>", app.on_context_text_changed)
        app.setup_context_textbox_direction()

        lang_row = ctk.CTkFrame(context_card, fg_color="transparent")
        lang_row.pack(fill="x", padx=12, pady=(0, 10))
        ctk.CTkLabel(lang_row, text="🌐 output language:", font=(APP_FONT, 12), text_color=TEXT_SECONDARY).pack(side="left")
        app.opt_ai_language = ctk.CTkOptionMenu(
            lang_row,
            values=["english", "persian", "arabic", "turkish", "spanish", "french", "german", "portuguese", "chinese", "japanese", "korean", "russian", "hindi", "indonesian"],
            font=(APP_FONT, 12),
            fg_color=BG_INPUT,
            button_color=BORDER_DIM,
            button_hover_color=TEXT_DIM,
            dropdown_fg_color=BG_CARD,
            dropdown_hover_color=BORDER_DIM,
            width=140,
            height=28,
            corner_radius=6
        )
        app.opt_ai_language.set("english")
        app.opt_ai_language.pack(side="left", padx=(8, 0))
        
        tabs = ctk.CTkTabview(
            workspace_body,
            fg_color=BG_SURFACE,
            segmented_button_fg_color=BG_INPUT,
            segmented_button_selected_color=ACCENT_BLUE,
            segmented_button_selected_hover_color="#2563eb",
            segmented_button_unselected_color=BORDER_DIM,
            segmented_button_unselected_hover_color=TEXT_DIM,
            corner_radius=10,
            border_width=1,
            border_color=BORDER_DIM
        )
        tabs.pack(fill="both", expand=True, padx=8, pady=(0, 8))

        tab_ig = tabs.add("  📸 instagram  ")
        tab_yt = tabs.add("  ▶️ youtube  ")

        self.build_instagram_tab(tab_ig)
        self.build_youtube_tab(tab_yt)

    def build_tool_card(self, parent, icon, title, desc, color, command, attr):
        app = self.app

        card = ctk.CTkFrame(parent, fg_color=BG_SURFACE, corner_radius=10, height=72)
        card.pack(fill="x", pady=(0, 5), padx=6)

        inner = ctk.CTkFrame(card, fg_color="transparent")
        inner.pack(fill="x", padx=10, pady=8)
        inner.grid_columnconfigure(1, weight=1)

        accent_bar = ctk.CTkFrame(inner, width=4, height=40, fg_color=color, corner_radius=2)
        accent_bar.grid(row=0, column=0, rowspan=2, sticky="ns", padx=(0, 10))

        title_lbl = ctk.CTkLabel(inner, text=f"{icon}  {title}", font=(APP_FONT, 13, "bold"), text_color=TEXT_PRIMARY, anchor="w")
        title_lbl.grid(row=0, column=1, sticky="w")

        desc_lbl = ctk.CTkLabel(inner, text=desc, font=(APP_FONT, 10), text_color=TEXT_DIM, anchor="w")
        desc_lbl.grid(row=1, column=1, sticky="w")

        btn = ctk.CTkButton(inner, text="→", width=36, height=36, font=(APP_FONT, 16, "bold"), fg_color=color, hover_color=self.darken(color), corner_radius=8, command=command)
        btn.grid(row=0, column=2, rowspan=2, padx=(8, 0))

        setattr(app, attr, btn)

        for w in [card, inner, title_lbl, desc_lbl]:
            w.bind("<Enter>", lambda e, c=card: c.configure(fg_color=BG_CARD_HOVER))
            w.bind("<Leave>", lambda e, c=card: c.configure(fg_color=BG_SURFACE))

    def darken(self, hex_color):
        hex_color = hex_color.lstrip("#")
        r = max(0, int(hex_color[0:2], 16) - 30)
        g = max(0, int(hex_color[2:4], 16) - 30)
        b = max(0, int(hex_color[4:6], 16) - 30)
        return f"#{r:02x}{g:02x}{b:02x}"

    def build_instagram_tab(self, tab):
        app = self.app

        actions = ctk.CTkFrame(tab, fg_color="transparent")
        actions.pack(fill="x", padx=8, pady=(8, 4))
        ctk.CTkButton(actions, text="📋 copy full pack", width=140, height=26, font=(APP_FONT, 11), fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=app.copy_instagram_pack).pack(side="right")

        self.build_field(tab, "🏷️", "identified topic", "entry", "ent_topic", "Identified topic")
        self.build_field(tab, "✍️", "caption", "textbox", "txt_instagram_caption", "Instagram caption", height=110)
        self.build_field(tab, "#️⃣", "hashtags", "textbox", "txt_instagram_tags", "Instagram hashtags", height=65)

    def build_youtube_tab(self, tab):
        app = self.app

        actions = ctk.CTkFrame(tab, fg_color="transparent")
        actions.pack(fill="x", padx=8, pady=(8, 4))
        ctk.CTkButton(actions, text="📋 copy full pack", width=140, height=26, font=(APP_FONT, 11), fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=6, command=app.copy_youtube_pack).pack(side="right")

        self.build_field(tab, "🎬", "title", "entry", "ent_youtube_title", "YouTube title")
        self.build_field(tab, "📄", "description", "textbox", "txt_youtube_description", "YouTube description", height=110)
        self.build_field(tab, "#️⃣", "hashtags", "textbox", "txt_youtube_tags", "YouTube hashtags", height=65)

    def build_field(self, parent, icon, label, widget_type, attr, copy_label, height=None):
        app = self.app

        section = ctk.CTkFrame(parent, fg_color="transparent")
        section.pack(fill="x", padx=8, pady=(0, 5))

        header = ctk.CTkFrame(section, fg_color="transparent")
        header.pack(fill="x", pady=(0, 2))
        ctk.CTkLabel(header, text=f"{icon} {label}", font=(APP_FONT, 12, "bold"), text_color=TEXT_SECONDARY).pack(side="left")
        ctk.CTkButton(header, text="copy", width=44, height=20, font=(APP_FONT, 9), fg_color=BORDER_DIM, hover_color=TEXT_DIM, corner_radius=4, command=lambda: self.copy_field(attr, copy_label)).pack(side="right")

        if widget_type == "entry":
            widget = ctk.CTkEntry(section, font=(APP_FONT, 13), fg_color=BG_INPUT, border_color=BORDER_DIM, border_width=1, corner_radius=7, height=34)
            widget.pack(fill="x")
            widget.bind("<KeyRelease>", app.schedule_project_autosave)
        else:
            h = height or 100
            widget = ctk.CTkTextbox(section, height=h, font=(APP_FONT, 13), fg_color=BG_INPUT, border_width=1, border_color=BORDER_DIM, corner_radius=7)
            widget.pack(fill="x")
            widget.bind("<KeyRelease>", app.schedule_project_autosave)

        setattr(app, attr, widget)

    def copy_field(self, attr, label):
        app = self.app
        widget = getattr(app, attr, None)
        if not widget:
            return
        if isinstance(widget, ctk.CTkEntry):
            app.copy_entry_content(widget, label)
        elif isinstance(widget, ctk.CTkTextbox):
            app.copy_textbox_content(widget, label)