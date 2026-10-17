#!/usr/bin/env python3
"""Serve the proposal UI and the PantangMakan Notion page it reads."""

import json
import sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PAGE_ID = "3fb1b8f7-1a1e-80bf-8d96-d48c6ccada22"
NOTION_DB = Path.home() / "Library/Application Support/Notion/notion.db"
ROOT = Path(__file__).resolve().parent
PORT = 8765


def rich_text(properties):
    if not properties:
        return ""
    try:
        props = json.loads(properties)
    except json.JSONDecodeError:
        return ""
    parts = []
    for part in props.get("title") or []:
        if isinstance(part, list) and part and isinstance(part[0], str):
            parts.append(part[0])
    return "".join(parts).strip()


def read_page():
    uri = f"file:{NOTION_DB}?mode=ro"
    con = sqlite3.connect(uri, uri=True)
    try:
        row = con.execute(
            "select properties, content, alive from block where id = ?",
            (PAGE_ID,),
        ).fetchone()
        if not row or not row[2]:
            raise RuntimeError("halaman PantangMakan tidak ada di Notion lokal")
        title = rich_text(row[0]) or "PantangMakan"
        content = json.loads(row[1] or "[]")
        blocks = []
        for child_id in content:
            child = con.execute(
                "select type, properties, alive from block where id = ?",
                (child_id,),
            ).fetchone()
            if not child or not child[2]:
                continue
            text = rich_text(child[1])
            if not text:
                continue
            blocks.append({"type": child[0], "text": text})
        return {"title": title, "blocks": blocks}
    finally:
        con.close()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/api/notion":
            try:
                body = json.dumps(read_page(), ensure_ascii=False).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Cache-Control", "no-store")
            except Exception as exc:
                body = json.dumps({"error": str(exc)}, ensure_ascii=False).encode()
                self.send_response(500)
                self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        target = ROOT / "index.html"
        data = target.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, fmt, *args):
        return


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
