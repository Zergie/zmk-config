Push-Location $PSScriptRoot
Remove-Item *.uf2 -ErrorAction SilentlyContinue
$runid = (gh run list --json databaseId --limit 1 | ConvertFrom-Json).databaseId
gh run download $runid --name firmware
Write-Host

do {
    Write-Host "Waiting for NICENANO drive.."
    Start-Sleep -Milliseconds 500
    $nicenano = Get-Volume | Where-Object FileSystemLabel -eq NICENANO
} while ($null -eq $nicenano)

Write-Host
Write-Host "Found $($nicenano.DriveLetter):\"
Start-Sleep -Seconds 2

Write-Host
Write-Host "Copying firmeware..."
$file = Get-ChildItem *_left-*.uf2
Copy-Item $file "$($nicenano.DriveLetter):\"

Pop-Location
Write-Host "All done." -ForegroundColor Green
