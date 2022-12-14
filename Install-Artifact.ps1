Remove-Item *.uf2 -ErrorAction SilentlyContinue
gh run download

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

Write-Host "All done." -ForegroundColor Green
