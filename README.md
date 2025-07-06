# upload-to-github

This is a simple but powerful bash script that automates the entire GitHub upload process — including repo creation using the GitHub CLI. You’ll be able to go from zero to published with one command.

✅ What This Script Does:
✅ Initializes a local Git repo
✅ Adds all files and commits
✅ Creates a .gitignore
✅ Adds a README.md
✅ Lets you choose a license (MIT, Apache 2.0, GPLv3) and enters your real name
✅ Creates a remote GitHub repo (public/private) using GitHub CLI (gh)
✅ Connects your local repo to GitHub
✅ Pushes everything

🛠️ Requirements:
- GitHub CLI (gh) must be installed and authenticated
- Make sure you’re authenticated:
- gh auth login
- Git must be installed
You must run this inside the root folder of your project

🚀 How to Use
- Save it as `upload_to_github.sh`
Make it executable:
```
chmod +x upload_to_github.sh
```
3. Run:
```
./upload_to_github.sh
```
4. For windows, run:
```
.\upload_to_github.ps1
```
Reference to the post article: Automate GitHub Uploads with a Bash Script (in Seconds) https://medium.com/@shouke.wei/automate-github-uploads-with-a-bash-script-in-seconds-290e0cb31ba3
