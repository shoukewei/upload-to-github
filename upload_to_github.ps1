# GitHub Project Uploader Script - Windows PowerShell version

Write-Host "GitHub Project Uploader Script"

# 1. Get GitHub repo info
$repoName = Read-Host "Enter GitHub repository name"
$visibility = Read-Host "Public or Private repository? (public/private) [private]"
if ([string]::IsNullOrWhiteSpace($visibility)) { $visibility = "private" }
$visibility = $visibility.ToLower()

$commitMsg = Read-Host "Enter initial commit message [Initial commit]"
if ([string]::IsNullOrWhiteSpace($commitMsg)) { $commitMsg = "Initial commit" }

# 2. Check git config user.name and user.email
$authorName = git config user.name
$authorEmail = git config user.email

if (-not $authorName) {
    $authorName = Read-Host "Enter your full name for git commits (user.name)"
    git config --global user.name "$authorName"
    Write-Host "Set git user.name to '$authorName'"
}
if (-not $authorEmail) {
    $authorEmail = Read-Host "Enter your email for git commits (user.email)"
    git config --global user.email "$authorEmail"
    Write-Host "Set git user.email to '$authorEmail'"
}

Write-Host "Using Git identity: $authorName <$authorEmail>"

# 3. Optional files
$createReadme = Read-Host "Do you want to create README.md? (y/n) [y]"
if ([string]::IsNullOrWhiteSpace($createReadme)) { $createReadme = "y" }
$createGitignore = Read-Host "Do you want to add a .gitignore? (y/n) [y]"
if ([string]::IsNullOrWhiteSpace($createGitignore)) { $createGitignore = "y" }
$createLicense = Read-Host "Do you want to add a LICENSE file? (y/n) [y]"
if ([string]::IsNullOrWhiteSpace($createLicense)) { $createLicense = "y" }

if ($createLicense -eq "y") {
    $licenseNameInput = Read-Host "Enter your full name for the LICENSE [$authorName]"
    if (-not [string]::IsNullOrWhiteSpace($licenseNameInput)) {
        $authorName = $licenseNameInput
    }

    Write-Host "Choose a license:"
    Write-Host "1) MIT"
    Write-Host "2) Apache 2.0"
    Write-Host "3) GPLv3"
    $licenseChoice = Read-Host "Enter number [1]"
    if ([string]::IsNullOrWhiteSpace($licenseChoice)) { $licenseChoice = "1" }
}

# 4. Git init and file creation
git init | Out-Null

if ($createReadme -eq "y") {
    "# $repoName" | Out-File -Encoding utf8 README.md
    Write-Host "Created README.md"
}

if ($createGitignore -eq "y") {
    @"
*.log
.env
__pycache__/
node_modules/
dist/
"@ | Out-File -Encoding utf8 .gitignore
    Write-Host "Created .gitignore"
}

if ($createLicense -eq "y") {
    $year = (Get-Date).Year
    switch ($licenseChoice) {
        "1" {
            $licenseType = "MIT"
            @"
MIT License

Copyright (c) $year $authorName

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
"@ | Out-File -Encoding utf8 LICENSE
        }
        "2" {
            $licenseType = "Apache-2.0"
            @"
Apache License 2.0

Copyright $year $authorName

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License...

Unless required by applicable law or agreed to in writing...
"@ | Out-File -Encoding utf8 LICENSE
        }
        "3" {
            $licenseType = "GPLv3"
            @"
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) $year $authorName

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License...

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY...
"@ | Out-File -Encoding utf8 LICENSE
        }
        default {
            Write-Host "Invalid license choice. Skipping LICENSE."
        }
    }
    if (Test-Path LICENSE) {
        Write-Host "Created LICENSE ($licenseType) for $authorName"
    }
}

# 5. Commit and push to GitHub
git add .
git commit -m "$commitMsg"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ and try again."
    exit 1
}

try {
    gh auth status | Out-Null
} catch {
    Write-Error "GitHub CLI (gh) is not authenticated. Please run 'gh auth login' and try again."
    exit 1
}

# Remove existing origin remote if exists
git remote remove origin 2>$null

gh repo create $repoName --$visibility --source=. --remote=origin --push

$repoUrl = gh repo view $repoName --json url -q '.url'

if ($repoUrl) {
    Write-Host ""
    Write-Host "Successfully pushed to GitHub:"
    Write-Host $repoUrl
} else {
    Write-Warning "Repo created but URL not detected. Please verify on GitHub manually."
}

