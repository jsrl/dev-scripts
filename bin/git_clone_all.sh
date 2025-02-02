#!/bin/bash

# Path to the file where the GitHub token is stored
TOKEN_FILE="$(dirname "$0")/.github_token"  # Token file located in the same directory as the script

# Check if the token file exists
if [ ! -f "$TOKEN_FILE" ]; then
    echo "❌ Error: Token file ($TOKEN_FILE) not found. Please create the file with your GitHub token."
    exit 1
fi

# Read the token from the file
GITHUB_TOKEN=$(cat "$TOKEN_FILE")

# Check if the token is empty
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: The token file is empty. Please provide a valid GitHub token."
    exit 1
fi

# Configuration
GITHUB_USER="jsrl"  
DEST_DIR="$(dirname "$0")"  

# Step 1️⃣: Verify curl is working and fetch repositories
echo "🔍 Fetching repositories from GitHub..."
RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user/repos?type=all&per_page=100")

# Step 2️⃣: Check for errors in the API response (without printing everything)
ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message": "[^"]*' | cut -d'"' -f4)

if [ -n "$ERROR_MSG" ]; then
    echo "❌ Error: $ERROR_MSG"
    exit 1
fi

# Extract repository HTTPS URLs (use HTTPS instead of SSH)
REPOS=$(echo "$RESPONSE" | jq -r '.[].clone_url')

# Check if repositories were fetched
if [ -z "$REPOS" ]; then
    echo "❌ Error: No repositories found or failed to fetch repositories."
    exit 1
fi

# Step 5️⃣: Debugging messages inside the loop
for REPO in $REPOS; do
    REPO_NAME=$(basename "$REPO" .git)  # Remove the '.git' from the repository name

    # Ensure there is no .git at the end
    REPO_NAME="${REPO_NAME%.git}"

    REPO_PATH="$DEST_DIR/$REPO_NAME"

    if [ -d "$REPO_PATH" ]; then
        echo "⏩ Skipping $REPO_NAME (already exists in $DEST_DIR)"
    else
        echo "⬇️  Cloning $REPO_NAME..."
        git clone "$REPO" "$DEST_DIR/$REPO_NAME"
    fi
done

echo "✅ All repositories have been processed. Check $DEST_DIR for cloned repositories."
