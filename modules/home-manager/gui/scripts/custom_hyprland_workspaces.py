#!/usr/bin/env python3
import json
import subprocess

# Get current workspaces
raw = subprocess.check_output(["hyprctl", "workspaces", "-j"])
workspaces = json.loads(raw)

mapped = []
for ws in workspaces:
    num = ws["id"]
    monitor = ws["monitor"]
    active = ws["focused"]
    name = str((num - 6) if 7 <= num <= 12 else num)
    mapped.append({"name": name, "id": num, "active": active, "monitor": monitor})

print(
    json.dumps(
        {
            "text": " ".join(
                f"[{ws['name']}]" if ws["active"] else ws["name"] for ws in mapped
            ),
            "tooltip": "Workspaces 7–12 mapped to 1–6",
        }
    )
)
