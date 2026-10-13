#!/usr/bin/env python3
# State per workspace: "<current tab_id> <previous tab_id>". Focusing the
# previous tab fires tab.focused again, which swaps the pair, so toggle repeats.
import json
import os
import subprocess
import sys

HERDR = os.environ.get("HERDR_BIN_PATH", "herdr")
STATE = os.environ.get("HERDR_PLUGIN_STATE_DIR", os.path.expanduser("~/.local/state/herdr-last-tab"))


def find(obj, key):
    if isinstance(obj, dict):
        if key in obj:
            return obj[key]
        obj = list(obj.values())
    if isinstance(obj, list):
        for v in obj:
            found = find(v, key)
            if found is not None:
                return found
    return None


def path(workspace_id):
    return os.path.join(STATE, workspace_id.replace("/", "_"))


def read(workspace_id):
    try:
        with open(path(workspace_id)) as f:
            return (f.read().split() + [None, None])[:2]
    except FileNotFoundError:
        return [None, None]


def record():
    event = json.loads(os.environ["HERDR_PLUGIN_EVENT_JSON"])
    tab, ws = find(event, "tab_id"), find(event, "workspace_id")
    if not tab or not ws:
        sys.exit(f"tab.focused event missing tab_id/workspace_id: {event}")
    current, _ = read(ws)
    if tab == current:
        return
    os.makedirs(STATE, exist_ok=True)
    tmp = path(ws) + ".tmp"
    with open(tmp, "w") as f:
        f.write(f"{tab} {current or ''}")
    os.replace(tmp, path(ws))


def toggle():
    out = subprocess.run([HERDR, "tab", "list"], capture_output=True, text=True, check=True).stdout
    tabs = find(json.loads(out), "tabs") or []
    focused = next((t for t in tabs if t.get("focused")), None)
    if not focused:
        sys.exit("no focused tab")
    _, previous = read(focused["workspace_id"])
    if previous and any(t["tab_id"] == previous for t in tabs):
        subprocess.run([HERDR, "tab", "focus", previous], check=True, capture_output=True)


if __name__ == "__main__":
    {"record": record, "toggle": toggle}[sys.argv[1]]()
