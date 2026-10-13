#!/bin/sh
# herdr port of tmux extrakto: Enter copies the pick, Tab types it into the pane.
# Runs in a popup, so the source is the focused pane, not this popup's own pane.
set -eu

extrakto="$HOME/.tmux/plugins/extrakto/extrakto.py"
pane=$(env -u HERDR_PANE_ID herdr pane current --current \
  | python3 -c 'import json, sys; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')

out=$(herdr pane read "$pane" --source recent-unwrapped --lines 2000 \
  | python3 "$extrakto" --all -r \
  | awk 'NF && !seen[$0]++' \
  | fzf --layout=reverse --tiebreak=index --expect=tab \
        --prompt='extrakto> ' --header='enter: copy · tab: insert') || exit 0

key=$(printf '%s\n' "$out" | sed -n 1p)
pick=$(printf '%s\n' "$out" | sed -n 2p)
[ -n "$pick" ] || exit 0

if [ "$key" = tab ]; then
  herdr pane send-text "$pane" "$pick" >/dev/null
else
  printf '%s' "$pick" | pbcopy
fi
