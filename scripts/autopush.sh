#!/bin/bash
# Auto-push script for roblox-party-game
# Requires GITHUB_TOKEN set in environment or ~/.gitconfig credential store

REPO_DIR="/root/.openclaw/workspace-coder/roblox-party-game"
LOG_FILE="/root/.openclaw/workspace-coder/logs/roblox-autopush.log"

cd "$REPO_DIR" || exit 1
git add -A
if git diff --cached --quiet; then
    echo "[$(date '+%Y-%m-%d %H:%M')] No changes to push" >> "$LOG_FILE"
    exit 0
fi
git commit -m "Auto-sync $(date '+%Y-%m-%d %H:%M')" >> "$LOG_FILE" 2>&1
git push origin master >> "$LOG_FILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M')] Push complete (exit $?)" >> "$LOG_FILE"
