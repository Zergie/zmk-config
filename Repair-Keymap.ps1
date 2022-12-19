$file = "$PSScriptRoot/config/sofle.keymap"
Get-Content $file |
    ForEach-Object {
        if ($_.Trim().StartsWith("sensor-bindings = ")) {
            $_.Replace(",", " ")
        } else {
            $_
        }
    } |
    Out-String |
    Set-Content -Path $file
