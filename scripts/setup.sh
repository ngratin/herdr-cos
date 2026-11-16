#!/bin/sh
# Install the staffer template into hc's template folder and prepare the workspace.
set -eu

repo=$(cd "$(dirname "$0")/.." && pwd)
workspace="$repo/workspace"
dest_dir="$HOME/.config/herdr-core/templates"

mkdir -p "$workspace/topics" "$dest_dir"
[ -f "$workspace/ledger.md" ] || printf '# Ledger\n\n## In progress\n\n## Waiting on the user\n\n## Decisions\n\n## Done\n' > "$workspace/ledger.md"

sed "s|{{COS_WORKSPACE}}|$workspace|g" "$repo/templates/staffer.md" > "$dest_dir/staffer.md"

echo "installed: $dest_dir/staffer.md"
hc templates
