<# 
Encode script

Rules:
1  -> #
l  -> ~
A-Z (uppercase) -> ^A, ^B, ..., ^Z

Input:  first .txt file from .\input
Output: same filename in .\output
#>

function Encode-PemForOcr {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    $sb = New-Object System.Text.StringBuilder

    foreach ($ch in $Text.ToCharArray()) {
        if ($ch -ge 'A' -and $ch -le 'Z') {
            # Mark uppercase with ^
            [void]$sb.Append('^')
            [void]$sb.Append($ch)
        }
        elseif ($ch -eq '1') {
            # Replace digit 1
            [void]$sb.Append('#')
        }
        elseif ($ch -eq 'l') {
            # Replace lowercase l
            [void]$sb.Append('~')
        }
        else {
            [void]$sb.Append($ch)
        }
    }

    return $sb.ToString()
}

# --- I/O handling: ./input -> ./output ---

$inputDir  = Join-Path (Get-Location) 'input'
$outputDir = Join-Path (Get-Location) 'output'

if (-not (Test-Path $inputDir)) {
    Write-Error "Input folder not found: $inputDir"
    exit 1
}

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Pick the first .txt file from ./input
$file = Get-ChildItem -Path $inputDir -Filter '*.txt' | Sort-Object Name | Select-Object -First 1

if (-not $file) {
    Write-Error "No .txt files found in $inputDir"
    exit 1
}

Write-Host "Encoding file: $($file.FullName)"

$content = Get-Content -Path $file.FullName -Raw
$result  = Encode-PemForOcr -Text $content

$outPath = Join-Path $outputDir $file.Name
Set-Content -Path $outPath -Value $result

Write-Host "Encoded output written to: $outPath"
