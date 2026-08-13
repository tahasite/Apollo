import customtkinter as ctk
import tkinter as tk
import requests

APP_FONT = "Segoe UI"


class AnimationHelper:
    @staticmethod
    def fade_in_widget(widget, duration=400, steps=12):
        try:
            if not widget.winfo_exists():
                return
        except:
            return
        step_delay = max(1, duration // steps)
        widget._anim_step = 0
        widget._anim_steps = steps

        def _step():
            try:
                if not widget.winfo_exists():
                    return
            except:
                return
            widget._anim_step += 1
            if widget._anim_step < widget._anim_steps:
                widget.after(step_delay, _step)

        widget.after(10, _step)

    @staticmethod
    def pulse_button(button, times=3, interval=300):
        original_color = None
        try:
            original_color = button.cget("fg_color")
        except:
            return
        pulse_color = "#22d3ee"
        count = [0]

        def _pulse():
            try:
                if not button.winfo_exists():
                    return
            except:
                return
            if count[0] >= times * 2:
                try:
                    button.configure(fg_color=original_color)
                except:
                    pass
                return
            if count[0] % 2 == 0:
                try:
                    button.configure(fg_color=pulse_color)
                except:
                    pass
            else:
                try:
                    button.configure(fg_color=original_color)
                except:
                    pass
            count[0] += 1
            button.after(interval, _pulse)

        _pulse()

    @staticmethod
    def typewriter_label(label, text, speed=30):
        label.configure(text="")
        chars = list(text)
        index = [0]

        def _type():
            try:
                if not label.winfo_exists():
                    return
            except:
                return
            if index[0] < len(chars):
                current = text[:index[0] + 1]
                label.configure(text=current)
                index[0] += 1
                label.after(speed, _type)

        label.after(100, _type)


class InteractiveWidgetHelper:
    @staticmethod
    def select_all(event, widget):
        if isinstance(widget, ctk.CTkEntry):
            widget.select_range(0, 'end')
            widget.icursor('end')
        elif isinstance(widget, ctk.CTkTextbox):
            widget.tag_add('sel', '1.0', 'end')
        return "break"

    @staticmethod
    def show_context_menu(event, widget):
        menu = tk.Menu(widget, tearoff=0, bg="#1e1e1e", fg="white", selectcolor="#2563eb", activebackground="#2563eb", activeforeground="white")
        state = "normal"
        try:
            if str(widget.cget("state")) == "disabled":
                state = "disabled"
        except:
            pass
        menu.add_command(label="Cut", command=lambda: widget.event_generate("<<Cut>>"), state=state)
        menu.add_command(label="Copy", command=lambda: widget.event_generate("<<Copy>>"))
        menu.add_command(label="Paste", command=lambda: widget.event_generate("<<Paste>>"), state=state)
        menu.add_separator()
        menu.add_command(label="Select All", command=lambda: InteractiveWidgetHelper.select_all(None, widget))
        menu.tk_popup(event.x_root, event.y_root)

    @staticmethod
    def enable_shortcuts_and_menu(widget):
        widget.bind("<Button-3>", lambda event: InteractiveWidgetHelper.show_context_menu(event, widget))
        widget.bind("<Control-a>", lambda event: InteractiveWidgetHelper.select_all(event, widget))
        widget.bind("<Control-A>", lambda event: InteractiveWidgetHelper.select_all(event, widget))
        widget.bind("<Control-c>", lambda event: widget.event_generate("<<Copy>>"))
        widget.bind("<Control-C>", lambda event: widget.event_generate("<<Copy>>"))
        widget.bind("<Control-v>", lambda event: widget.event_generate("<<Paste>>"))
        widget.bind("<Control-V>", lambda event: widget.event_generate("<<Paste>>"))
        widget.bind("<Control-x>", lambda event: widget.event_generate("<<Cut>>"))
        widget.bind("<Control-X>", lambda event: widget.event_generate("<<Cut>>"))

    @staticmethod
    def register_inputs(parent):
        for child in parent.winfo_children():
            if isinstance(child, (ctk.CTkEntry, ctk.CTkTextbox)):
                InteractiveWidgetHelper.enable_shortcuts_and_menu(child)
            if child.winfo_children():
                InteractiveWidgetHelper.register_inputs(child)


class IPChecker:
    COUNTRY_FLAGS = {
        "AF": "🇦🇫", "AL": "🇦🇱", "DZ": "🇩🇿", "AR": "🇦🇷", "AM": "🇦🇲",
        "AU": "🇦🇺", "AT": "🇦🇹", "AZ": "🇦🇿", "BH": "🇧🇭", "BD": "🇧🇩",
        "BY": "🇧🇾", "BE": "🇧🇪", "BR": "🇧🇷", "BG": "🇧🇬", "CA": "🇨🇦",
        "CL": "🇨🇱", "CN": "🇨🇳", "CO": "🇨🇴", "HR": "🇭🇷", "CY": "🇨🇾",
        "CZ": "🇨🇿", "DK": "🇩🇰", "EG": "🇪🇬", "EE": "🇪🇪", "FI": "🇫🇮",
        "FR": "🇫🇷", "GE": "🇬🇪", "DE": "🇩🇪", "GR": "🇬🇷", "HK": "🇭🇰",
        "HU": "🇭🇺", "IN": "🇮🇳", "ID": "🇮🇩", "IR": "🇮🇷", "IQ": "🇮🇶",
        "IE": "🇮🇪", "IL": "🇮🇱", "IT": "🇮🇹", "JP": "🇯🇵", "JO": "🇯🇴",
        "KZ": "🇰🇿", "KE": "🇰🇪", "KR": "🇰🇷", "KW": "🇰🇼", "LB": "🇱🇧",
        "LY": "🇱🇾", "MY": "🇲🇾", "MX": "🇲🇽", "MA": "🇲🇦", "NL": "🇳🇱",
        "NZ": "🇳🇿", "NG": "🇳🇬", "NO": "🇳🇴", "OM": "🇴🇲", "PK": "🇵🇰",
        "PS": "🇵🇸", "PA": "🇵🇦", "PE": "🇵🇪", "PH": "🇵🇭", "PL": "🇵🇱",
        "PT": "🇵🇹", "QA": "🇶🇦", "RO": "🇷🇴", "RU": "🇷🇺", "SA": "🇸🇦",
        "RS": "🇷🇸", "SG": "🇸🇬", "SK": "🇸🇰", "SI": "🇸🇮", "ZA": "🇿🇦",
        "ES": "🇪🇸", "SE": "🇸🇪", "CH": "🇨🇭", "SY": "🇸🇾", "TW": "🇹🇼",
        "TH": "🇹🇭", "TR": "🇹🇷", "UA": "🇺🇦", "AE": "🇦🇪", "GB": "🇬🇧",
        "US": "🇺🇸", "UY": "🇺🇾", "UZ": "🇺🇿", "VE": "🇻🇪", "VN": "🇻🇳",
        "YE": "🇾🇪"
    }

    @staticmethod
    def get_ip_info():
        try:
            resp = requests.get("http://ip-api.com/json/?fields=query,country,countryCode,city,isp", timeout=8)
            data = resp.json()
            ip = data.get("query", "unknown")
            country = data.get("country", "unknown")
            code = data.get("countryCode", "")
            city = data.get("city", "")
            isp = data.get("isp", "")
            flag = IPChecker.COUNTRY_FLAGS.get(code, "🏳️")
            return {
                "ip": ip,
                "country": country,
                "country_code": code,
                "city": city,
                "isp": isp,
                "flag": flag
            }
        except:
            return {
                "ip": "unknown",
                "country": "unknown",
                "country_code": "",
                "city": "",
                "isp": "",
                "flag": "🏳️"
            }