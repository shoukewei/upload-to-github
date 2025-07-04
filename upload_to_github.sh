#!/bin/bash
set -e

echo "🚀 GitHub Project Uploader Script"

# 1. Get repo info
read -p "Enter GitHub repository name: " REPO_NAME
read -p "Public or Private repository? (public/private) [private]: " VISIBILITY
VISIBILITY=$(echo "${VISIBILITY:-private}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

read -p "Enter initial commit message [Initial commit]: " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"Initial commit"}

# 2. Optional files
read -p "Do you want to create README.md? (y/n) [y]: " CREATE_README
CREATE_README=$(echo "${CREATE_README:-y}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

read -p "Do you want to add a .gitignore? (y/n) [y]: " CREATE_GITIGNORE
CREATE_GITIGNORE=$(echo "${CREATE_GITIGNORE:-y}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

read -p "Do you want to add a LICENSE file? (y/n) [y]: " CREATE_LICENSE
CREATE_LICENSE=$(echo "${CREATE_LICENSE:-y}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

# 3. License details
if [ "$CREATE_LICENSE" = "y" ]; then
  AUTHOR_NAME=$(git config user.name)
  read -p "Enter your full name for the LICENSE [$AUTHOR_NAME]: " NAME_INPUT
  AUTHOR_NAME=${NAME_INPUT:-$AUTHOR_NAME}

  echo "Choose a license:"
  echo "1) MIT"
  echo "2) Apache 2.0"
  echo "3) GPLv3"
  read -p "Enter number [1]: " LICENSE_CHOICE
  LICENSE_CHOICE=${LICENSE_CHOICE:-1}
fi

# 4. Git init and file creation
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
      echo "❌ Invalid license choice. Skipping LICENSE generation."
      ;;
  esac
  echo "✅ Created LICENSE ($LICENSE_TYPE) for $AUTHOR_NAME"
fi

# 5. Commit and push
git add .
git commit -m "$COMMIT_MSG"

if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) not installed. Install from https://cli.github.com/ and retry."
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "❌ GitHub CLI (gh) not authenticated. Run 'gh auth login' and retry."
  exit 1
fi

gh repo create "$REPO_NAME" --$VISIBILITY --source=. --remote=origin --push

REPO_URL=$(gh repo view "$REPO_NAME" --json url -q '.url' 2>/dev/null)
echo -e "\n🎉 Successfully pushed to GitHub:"
echo "🔗 $REPO_URL"
echo "You can now view your repository at $REPO_URL"



