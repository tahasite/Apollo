import os
import json
import sqlite3
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_FILE = os.path.join(BASE_DIR, "smart_video_editor.db")


class ProjectManager:
    @staticmethod
    def connect():
        conn = sqlite3.connect(DB_FILE)
        conn.row_factory = sqlite3.Row
        return conn

    @staticmethod
    def init_db():
        with ProjectManager.connect() as conn:
            conn.execute(
                """
                create table if not exists projects (
                    video_path text primary key,
                    project_dir text not null,
                    mask_path text not null,
                    output_path text not null,
                    note_text text default '',
                    identified_topic text default '',
                    ai_instagram_caption text default '',
                    ai_instagram_hashtags text default '',
                    ai_youtube_title text default '',
                    ai_youtube_description text default '',
                    ai_youtube_hashtags text default '',
                    wm_path text default '',
                    wm_scale real default 1.0,
                    wm_x real default 50.0,
                    wm_y real default 50.0,
                    status text default 'video_selected',
                    updated_at text not null
                )
                """
            )
            conn.commit()

    @staticmethod
    def build_paths(video_path):
        video_dir = os.path.dirname(video_path)
        video_name = os.path.splitext(os.path.basename(video_path))[0]
        project_dir = os.path.join(video_dir, f"{video_name}_sve_project")
        return {
            "project_dir": project_dir,
            "mask_path": os.path.join(project_dir, "mask.png"),
            "output_path": os.path.join(project_dir, "final_export.mp4"),
            "silent_output_path": os.path.join(project_dir, "render_silent.mp4"),
            "state_path": os.path.join(project_dir, "project_state.json"),
            "ai_pack_path": os.path.join(project_dir, "ai_pack.json")
        }

    @staticmethod
    def build_default(video_path, config):
        paths = ProjectManager.build_paths(video_path)
        return {
            "video_path": video_path,
            "project_dir": paths["project_dir"],
            "mask_path": paths["mask_path"],
            "output_path": paths["output_path"],
            "note_text": "",
            "identified_topic": "",
            "ai_instagram_caption": "",
            "ai_instagram_hashtags": "",
            "ai_youtube_title": "",
            "ai_youtube_description": "",
            "ai_youtube_hashtags": "",
            "wm_path": config.get("wm_path", ""),
            "wm_scale": float(config.get("wm_scale", 1.0)),
            "wm_x": float(config.get("wm_x", 50.0)),
            "wm_y": float(config.get("wm_y", 50.0)),
            "status": "video_selected",
            "updated_at": datetime.now().isoformat()
        }

    @staticmethod
    def hydrate(project, config):
        if not project or not project.get("video_path"):
            return None
        base = ProjectManager.build_default(project["video_path"], config)
        base.update(project)
        paths = ProjectManager.build_paths(project["video_path"])
        base["project_dir"] = paths["project_dir"]
        base["mask_path"] = paths["mask_path"]
        base["output_path"] = paths["output_path"]
        base["updated_at"] = base.get("updated_at") or datetime.now().isoformat()
        try:
            base["wm_scale"] = float(base.get("wm_scale", 1.0))
        except:
            base["wm_scale"] = 1.0
        try:
            base["wm_x"] = float(base.get("wm_x", 50.0))
        except:
            base["wm_x"] = 50.0
        try:
            base["wm_y"] = float(base.get("wm_y", 50.0))
        except:
            base["wm_y"] = 50.0
        return base

    @staticmethod
    def load_snapshot(video_path, config):
        paths = ProjectManager.build_paths(video_path)
        if os.path.exists(paths["state_path"]):
            try:
                with open(paths["state_path"], "r", encoding="utf-8") as f:
                    data = json.load(f)
                return ProjectManager.hydrate(data, config)
            except:
                return None
        return None

    @staticmethod
    def load_by_video(video_path, config):
        with ProjectManager.connect() as conn:
            row = conn.execute("select * from projects where video_path = ?", (video_path,)).fetchone()
        if row:
            return ProjectManager.hydrate(dict(row), config)
        return None

    @staticmethod
    def load_latest(config):
        with ProjectManager.connect() as conn:
            row = conn.execute("select * from projects order by updated_at desc limit 1").fetchone()
        if row:
            project = ProjectManager.hydrate(dict(row), config)
            if project and os.path.exists(project["video_path"]):
                return project
        return None

    @staticmethod
    def load_or_create(video_path, config):
        project = ProjectManager.load_by_video(video_path, config)
        if not project:
            project = ProjectManager.load_snapshot(video_path, config)
        if not project:
            project = ProjectManager.build_default(video_path, config)
        ProjectManager.save(project)
        return project

    @staticmethod
    def save_text_exports(project):
        paths = ProjectManager.build_paths(project["video_path"])
        os.makedirs(paths["project_dir"], exist_ok=True)
        with open(paths["state_path"], "w", encoding="utf-8") as f:
            json.dump(project, f, ensure_ascii=False, indent=4)
        ai_payload = {
            "identified_topic": project.get("identified_topic", ""),
            "instagram_caption": project.get("ai_instagram_caption", ""),
            "instagram_hashtags": project.get("ai_instagram_hashtags", ""),
            "youtube_title": project.get("ai_youtube_title", ""),
            "youtube_description": project.get("ai_youtube_description", ""),
            "youtube_hashtags": project.get("ai_youtube_hashtags", "")
        }
        with open(paths["ai_pack_path"], "w", encoding="utf-8") as f:
            json.dump(ai_payload, f, ensure_ascii=False, indent=4)
        instagram_text = "\n\n".join(
            [
                f"identified topic:\n{project.get('identified_topic', '').strip()}",
                f"caption:\n{project.get('ai_instagram_caption', '').strip()}",
                f"hashtags:\n{project.get('ai_instagram_hashtags', '').strip()}"
            ]
        ).strip()
        youtube_text = "\n\n".join(
            [
                f"identified topic:\n{project.get('identified_topic', '').strip()}",
                f"title:\n{project.get('ai_youtube_title', '').strip()}",
                f"description:\n{project.get('ai_youtube_description', '').strip()}",
                f"hashtags:\n{project.get('ai_youtube_hashtags', '').strip()}"
            ]
        ).strip()
        with open(os.path.join(paths["project_dir"], "instagram_pack.txt"), "w", encoding="utf-8") as f:
            f.write(instagram_text)
        with open(os.path.join(paths["project_dir"], "youtube_shorts_pack.txt"), "w", encoding="utf-8") as f:
            f.write(youtube_text)

    @staticmethod
    def save(project):
        if not project or not project.get("video_path"):
            return
        project["updated_at"] = datetime.now().isoformat()
        paths = ProjectManager.build_paths(project["video_path"])
        project["project_dir"] = paths["project_dir"]
        project["mask_path"] = paths["mask_path"]
        project["output_path"] = paths["output_path"]
        os.makedirs(project["project_dir"], exist_ok=True)
        with ProjectManager.connect() as conn:
            conn.execute(
                """
                insert into projects (
                    video_path, project_dir, mask_path, output_path, note_text,
                    identified_topic, ai_instagram_caption, ai_instagram_hashtags,
                    ai_youtube_title, ai_youtube_description, ai_youtube_hashtags,
                    wm_path, wm_scale, wm_x, wm_y, status, updated_at
                )
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                on conflict(video_path) do update set
                    project_dir = excluded.project_dir,
                    mask_path = excluded.mask_path,
                    output_path = excluded.output_path,
                    note_text = excluded.note_text,
                    identified_topic = excluded.identified_topic,
                    ai_instagram_caption = excluded.ai_instagram_caption,
                    ai_instagram_hashtags = excluded.ai_instagram_hashtags,
                    ai_youtube_title = excluded.ai_youtube_title,
                    ai_youtube_description = excluded.ai_youtube_description,
                    ai_youtube_hashtags = excluded.ai_youtube_hashtags,
                    wm_path = excluded.wm_path,
                    wm_scale = excluded.wm_scale,
                    wm_x = excluded.wm_x,
                    wm_y = excluded.wm_y,
                    status = excluded.status,
                    updated_at = excluded.updated_at
                """,
                (
                    project.get("video_path", ""),
                    project.get("project_dir", ""),
                    project.get("mask_path", ""),
                    project.get("output_path", ""),
                    project.get("note_text", ""),
                    project.get("identified_topic", ""),
                    project.get("ai_instagram_caption", ""),
                    project.get("ai_instagram_hashtags", ""),
                    project.get("ai_youtube_title", ""),
                    project.get("ai_youtube_description", ""),
                    project.get("ai_youtube_hashtags", ""),
                    project.get("wm_path", ""),
                    float(project.get("wm_scale", 1.0)),
                    float(project.get("wm_x", 50.0)),
                    float(project.get("wm_y", 50.0)),
                    project.get("status", "video_selected"),
                    project.get("updated_at", datetime.now().isoformat())
                )
            )
            conn.commit()
        ProjectManager.save_text_exports(project)