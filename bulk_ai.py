#!/bin/bash

SOURCE_DIR="$HOME/auto"
DEST_BASE="/opt/omniscient"

# Declare categories and their destinations
declare -A DESTS=(
  ["scripts"]="$DEST_BASE/scripts"
  ["archives"]="$DEST_BASE/archives"
  ["osint"]="$DEST_BASE/osint_tools"
  ["omniscient_core"]="$DEST_BASE/core"
  ["configs"]="$DEST_BASE/configs"
  ["logs"]="$DEST_BASE/logs"
  ["backups"]="$DEST_BASE/backups"
  ["web"]="$DEST_BASE/web_assets"
  ["ui"]="$DEST_BASE/gui"
  ["docs"]="$DEST_BASE/docs"
  ["databases"]="$DEST_BASE/databases"
  ["containers"]="$DEST_BASE/containers"
  ["misc"]="$DEST_BASE/misc_unsorted"
)

# Re-use the classification logic
classify_folder() {
  local name=$(basename "$1" | tr '[:upper:]' '[:lower:]')
  case "$name" in
    *.zip|*.tar.gz|*.xz|*.tar) echo "archives" ;;
    *.sql|*.db) echo "databases" ;;
    *.py|*python*|*bash*|*sh*) echo "scripts" ;;
    *.html|*html*) echo "web" ;;
    *init.*|*config*|*.conf) echo "configs" ;;
    *log*) echo "logs" ;;
    *backup*) echo "backups" ;;
    *interface*|*frontend*) echo "ui" ;;
    *readme*|*doc*) echo "docs" ;;
    *osint*|*intel*|*search*) echo "osint" ;;
    *omniscient*) echo "omniscient_core" ;;
    *docker*) echo "containers" ;;
    *) echo "misc" ;;
  esac
}

# Move classified directories
cd "$SOURCE_DIR"
for item in *; do
  [ -e "$item" ] || continue
  category=$(classify_folder "$item")
  target="${DESTS[$category]}"
  echo "[+] Moving '$item' => '$target'"
  mkdir -p "$target"
  mv "$item" "$target/"
done
