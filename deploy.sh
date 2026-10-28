#!/usr/bin/env bash
set -e

REPO_NAME="${1:-az-consultants-enterprise}"
ORG_NAME="${2:-az-consultants}"

echo "=========================================="
echo "🚀 Deploying AZ Consultants Enterprise Hub"
echo "=========================================="

if [ -z "$GITHUB_TOKEN" ]; then
  if [ -f "$HOME/.config/gh/hosts.yml" ]; then
    TOKEN=$(grep -m 1 "oauth_token:" "$HOME/.config/gh/hosts.yml" | awk '{print $2}')
    export GITHUB_TOKEN="$TOKEN"
  fi
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ Error: GITHUB_TOKEN not found. Please set export GITHUB_TOKEN='your_token'"
  exit 1
fi

echo "1. Checking/Creating repository on GitHub..."
HTTP_STATUS=$(curl -s -o /tmp/gh_repo_resp.json -w "%{http_code}" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/orgs/$ORG_NAME/repos \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"AZ Consultants GitHub Enterprise Hub & Architecture Showcase\",\"private\":false,\"has_issues\":true,\"has_projects\":true,\"has_wiki\":true}")

if [ "$HTTP_STATUS" -eq 201 ]; then
  echo "✅ Remote repo created under $ORG_NAME/$REPO_NAME"
elif [ "$HTTP_STATUS" -eq 422 ]; then
  echo "ℹ️ Remote repo already exists under $ORG_NAME/$REPO_NAME"
else
  echo "⚠️ Note: Attempting push directly to organization/user repo..."
fi

echo "2. Pushing local branches to remote..."
cd /home/aamir/.gemini/antigravity/scratch/az-consultants-enterprise

git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${ORG_NAME}/${REPO_NAME}.git"

git push -u origin main --force

echo "=========================================="
echo "🎉 Successfully Deployed to GitHub Enterprise!"
echo "URL: https://github.com/${ORG_NAME}/${REPO_NAME}"
echo "=========================================="
