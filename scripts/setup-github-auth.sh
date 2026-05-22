#!/bin/bash
# One-time GitHub auth setup for roblox-party auto-push
# Run this with the token: bash scripts/setup-github-auth.sh <TOKEN>

TOKEN="$1"

if [ -z "$TOKEN" ]; then
    echo "Usage: bash scripts/setup-github-auth.sh <github-personal-access-token>"
    echo "Token needs 'repo' scope."
    exit 1
fi

cd /root/.openclaw/workspace-coder/roblox-party-game

# Store credentials
git config --global credential.helper store
echo "https://ddh780644-bit:${TOKEN}@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Update remote with clean URL (no embedded creds)
git remote set-url origin https://github.com/ddh780644-bit/roblox-party.git

# Force-push local version to GitHub (our local has the full fixed project)
git push --force -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Push successful! Credential stored for future auto-pushes."
    echo "   Hourly cron is active — all changes auto-sync every hour."
    echo ""
    echo "For INSTANT push: cd /root/.openclaw/workspace-coder/roblox-party-game && bash scripts/autopush.sh"
else
    echo "❌ Push failed. Check token has 'repo' scope."
    exit 1
fi
