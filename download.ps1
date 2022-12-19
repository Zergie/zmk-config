Remove-Item *.uf2 -ErrorAction SilentlyContinue
gh run download
Invoke-Item .
