#!/bin/bash

# Check if the token is provided as a parameter
if [ -z "$1" ]; then
    echo "Error: You must provide your GitHub token as the first parameter."
    echo "Usage: $0 <github_token>"
    exit 1
fi

# Configuration
GITHUB_USER="jsrl"  # You can change this or pass it as a second parameter if you prefer
GITHUB_TOKEN="$1"                   # Token passed as the first parameter
DEST_DIR="$(dirname "$0")"          # Use the directory where the script is located

# Create the destination folder if it doesn't exist
mkdir -p "$DEST_DIR"

# Get the list of repositories (public and private)
REPOS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user/repos?type=all&per_page=100" | jq -r '.[].ssh_url')

# Check if repositories were fetched
if [ -z "$REPOS" ]; then
    echo "Error: Could not fetch repositories. Please check your token and internet connection."
    exit 1
fi

# Clone each repository if it doesn't already exist
for REPO in $REPOS; do
    REPO_NAME=$(basename "$REPO" .git)
    if [ -d "$DEST_DIR/$REPO_NAME" ]; then
        echo "Repository $REPO_NAME already exists in $DEST_DIR. Skipping..."
    else
        echo "Cloning $REPO_NAME..."
        git clone "$REPO" "$DEST_DIR/$REPO_NAME"
    fi
done

echo "All repositories have been processed. Check $DEST_DIR for cloned repositories."