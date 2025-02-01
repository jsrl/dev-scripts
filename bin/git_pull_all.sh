#!/bin/bash

for dir in */; do
  if [ -d "$dir/.git" ]; then
    echo "📂 Checking $dir..."
    cd "$dir"

    # Fetch remote changes
    git fetch

    # Get the current branch
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if the branch has an upstream
    UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

    if [ -z "$UPSTREAM" ]; then
        echo "⚠️  No upstream branch for $BRANCH in $dir. Skipping..."
        cd ..
        continue
    fi

    # Get commit hashes
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "🛑 Uncommitted changes in $dir. Skipping pull..."
        cd ..
        continue
    fi

    # Compare hashes
    if [ "$LOCAL" = "$REMOTE" ]; then
      echo "✅ $dir ($BRANCH) is already up to date."
    else
      echo "🚀 Changes detected in $dir ($BRANCH), pulling updates..."
      git pull
    fi

    cd ..
  fi
done
