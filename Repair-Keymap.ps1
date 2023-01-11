$file = "$PSScriptRoot/config/sofle.keymap"

$insideBinding = $false

Get-Content $file |
    ForEach-Object {
        if ($insideBinding -and $_.Trim().StartsWith(">;")) {
            $insideBinding = $false

            $keys = @{}
            $rows = 0
            $cols = 0
            foreach ($line in $bindings -split "`n") {
                $col = 0

                if ($rows -gt 3) {
                    $keys.Add("${rows},0", "")
                    $keys.Add("${rows},1", "")
                    $col += 2
                }

                foreach ($key in $line |
                    Select-String -Pattern "(&[^&]+)" -AllMatches |
                    ForEach-Object Matches |
                    ForEach-Object { $_.Groups[1].Value.Trim() }) {

                    $keys.Add("${rows},${col}", $key)

                    if ($rows -lt 3 -and $col -eq 5) {
                        $keys.Add("${rows},6", "")
                        $keys.Add("${rows},7", "")
                        $col += 2
                    }

                    if ($col -gt $cols) { $cols = $col }
                    $col += 1
                }

                $rows += 1
            }
            $rows -= 1

            $padding = 0..$cols |
                        ForEach-Object {
                            $col = $_
                            0..$rows |
                                ForEach-Object { $keys["${_},${col}"].Length } |
                                Measure-Object -Maximum |
                                ForEach-Object { [int]$_.Maximum }
                        }

            $index = 0
            0..$rows |
                ForEach-Object {
                    $row = [int]$_
                    
                    0..$cols |
                        ForEach-Object `
                            -Begin { "/*" } `
                            -End   { "*/"  } `
                            -Process {
                                if ($keys["${row},${_}"].Length -gt 0) {
                                    $number = $index.ToString()
                                    $filler = "-"
                                    $index += 1
                                } else {
                                    $number = ""
                                    $filler = " "
                                }

                                $number = $number.PadLeft(3, " ")
                                $number = $number.PadRight(4, " ")
                                $number = "$([string]::new($filler, ($padding[$_] - $number.Length) / 2))$number"
                                $number = "$number$([string]::new($filler, $padding[$_] - $number.Length))"

                                $number
                            } |
                        Join-String -Separator "|" |
                        ForEach-Object { $_ -replace '(\*| )\|( )','$1 $2' }

                    0..$cols |
                        ForEach-Object {
                            try {
                                $keys["${row},${_}"].PadRight($padding[$_])
                            } catch {
                                ""
                            }
                        } |
                        Join-String -Separator " " |
                        ForEach-Object { "   $($_.TrimEnd())" }
                } #| Write-Host

            #$bindings
            $_
        } elseif ($insideBinding) {
            if ($_.TrimStart().StartsWith("/*"))
            { }
            elseif ($_.Trim().Length -lt 3)
            { }
            else
            { $bindings += $_ }
        } elseif ($_.Trim().StartsWith("sensor-bindings = ")) {
            $_.Replace(",", " ")
        } else {
            $_
        }

        if (!$insideBinding -and $_.Trim() -eq "bindings = <") {
            $insideBinding = $true
            $bindings = @()
        }
    } |
    Out-String |
    ForEach-Object { $_.TrimEnd() } |
    Set-Content -Path $file
