[cmdletbinding()]
param()

git add -p
git commit --amend --no-edit
git push -f

Start-Sleep 2
gh run watch

. "$PSScriptRoot/Install-Artifact.ps1"
