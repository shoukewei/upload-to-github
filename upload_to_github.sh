#!/bin/bash
set -e

echo "🚀 GitHub Project Uploader Script"

# --------------------------
# 1. Get GitHub repo info
# --------------------------
read -p "Enter GitHub repository name: " REPO_NAME
read -p "Public or Private repository? (public/private) [private]: " VISIBILITY
VISIBILITY=$(echo "${VISIBILITY:-private}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

read -p "Enter initial commit message [Initial commit]: " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"Initial commit"}

# --------------------------
# 2. Check git user config
# --------------------------
AUTHOR_NAME=$(git config user.name)
AUTHOR_EMAIL=$(git config user.email)

if [ -z "$AUTHOR_NAME" ]; then
  read -p "Enter your full name for git commits (user.name): " AUTHOR_NAME
  git config --global user.name "$AUTHOR_NAME"
  echo "✅ Set git user.name to '$AUTHOR_NAME'"
fi

if [ -z "$AUTHOR_EMAIL" ]; then
  read -p "Enter your email for git commits (user.email): " AUTHOR_EMAIL
  git config --global user.email "$AUTHOR_EMAIL"
  echo "✅ Set git user.email to '$AUTHOR_EMAIL'"
fi

echo "📇 Using Git identity: $AUTHOR_NAME <$AUTHOR_EMAIL>"

# --------------------------
# 3. Optional file creation
# --------------------------
read -p "Do you want to create README.md? (y/n) [y]: " CREATE_README
CREATE_README=$(echo "${CREATE_README:-y}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

read -p "Do you want to add a .gitignore? (y/n) [y]: " CREATE_GITIGNORE
CREATE_GITIGNORE=$(echo "${CREATE_GITIGNORE:-y}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

read -p "Do you want to add a LICENSE file? (y/n) [y]: " CREATE_LICENSE
CREATE_LICENSE=$(echo "${CREATE_LICENSE:-y}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

if [ "$CREATE_LICENSE" = "y" ]; then
  read -p "Enter your full name for the LICENSE [$AUTHOR_NAME]: " NAME_INPUT
  AUTHOR_NAME=${NAME_INPUT:-$AUTHOR_NAME}

  echo "Choose a license:"
  echo "1) MIT"
  echo "2) Apache 2.0"
  echo "3) GPLv3"
  read -p "Enter number [1]: " LICENSE_CHOICE
  LICENSE_CHOICE=${LICENSE_CHOICE:-1}
fi

# --------------------------
# 4. Git init and file creation
# --------------------------
git init

if [ "$CREATE_README" = "y" ]; then
  echo "# $REPO_NAME" > README.md
  echo "✅ Created README.md"
fi

if [ "$CREATE_GITIGNORE" = "y" ]; then
  echo -e "*.log\n.env\n__pycache__/\nnode_modules/\ndist/" > .gitignore
  echo "✅ Created .gitignore"
fi

if [ "$CREATE_LICENSE" = "y" ]; then
  YEAR=$(date +%Y)
  case $LICENSE_CHOICE in
    1)
      LICENSE_TYPE="MIT"
      cat <<EOF > LICENSE
MIT License

Copyright (c) $YEAR $AUTHOR_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
EOF
      ;;
    2)
      LICENSE_TYPE="Apache-2.0"
      cat <<EOF > LICENSE
Apache License 2.0

Copyright $YEAR $AUTHOR_NAME

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License...

Unless required by applicable law or agreed to in writing...
EOF
      ;;
    3)
      LICENSE_TYPE="GPLv3"
      cat <<EOF > LICENSE
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) $YEAR $AUTHOR_NAME

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License...

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY...
EOF
      ;;
    *)
      echo "❌ Invalid license choice. Skipping LICENSE."
      ;;
  esac

  if [ -f LICENSE ]; then
    echo "✅ Created LICENSE ($LICENSE_TYPE) for $AUTHOR_NAME"
  fi
fi

# --------------------------
# 5. Commit and push to GitHub
# --------------------------
git add .
git commit -m "$COMMIT_MSG"

if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ and try again."
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not authenticated. Please run 'gh auth login' and try again."
  exit 1
fi

gh repo create "$REPO_NAME" --$VISIBILITY --source=. --remote=origin --push

REPO_URL=$(gh repo view "$REPO_NAME" --json url -q '.url' 2>/dev/null)
if [ -n "$REPO_URL" ]; then
  echo -e "\n🎉 Successfully pushed to GitHub:"
  echo "🔗 $REPO_URL"
else
  echo "⚠️ Repo created but URL not detected. Please verify on GitHub manually."
fi
