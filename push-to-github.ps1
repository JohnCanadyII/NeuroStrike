# NeuroStrike - Push to GitHub
# Run this in PowerShell after copying the NeuroStrike folder to your Windows machine

$GITHUB_USERNAME = "JohnCanadyII"
$REPO_NAME = "NeuroStrike"
$GITHUB_TOKEN = "YOUR_TOKEN_HERE"  # Replace with your GitHub token

# Initialize git repo
git init
git add .
git commit -m "Initial commit - NeuroStrike SOC Lab Phase 1 Complete"

# Create GitHub repo and push
git remote add origin "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
git branch -M main
git push -u origin main

Write-Host "✅ NeuroStrike pushed to GitHub!"
Write-Host "View at: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
