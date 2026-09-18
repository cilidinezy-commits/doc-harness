param(
    [string]$ProjectRoot = '.',
    [string]$Action = 'check',
    [string]$Token = ''
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$cs = Join-Path $root 'CURRENT_STATUS.md'
if (-not (Test-Path -LiteralPath $cs)) { Write-Output 'FAIL: CURRENT_STATUS.md not found'; exit 1 }
$mtime = (Get-Item -LiteralPath $cs).LastWriteTimeUtc.Ticks
$side = Join-Path $root "_runtime/writer-$Token.json"
if ($Action -eq 'claim') {
    $d = Split-Path $side -Parent
    if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    @{ token = $Token; mtime = $mtime } | ConvertTo-Json | Set-Content -LiteralPath $side -Encoding UTF8
    Write-Output "claimed writer '$Token' at mtime $mtime"
    exit 0
}
if (-not (Test-Path -LiteralPath $side)) { Write-Output "WARN: no claim for token '$Token'"; exit 2 }
$claim = Get-Content -LiteralPath $side -Raw | ConvertFrom-Json
if ([int64]$claim.mtime -ne [int64]$mtime) {
    Write-Output 'FAIL: CURRENT_STATUS changed since claim (concurrent writer)'
    exit 1
}
Write-Output 'PASS: no concurrent write detected'
