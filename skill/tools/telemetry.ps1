param(
    [string]$ProjectRoot = '.',
    [string]$Event = '',
    [string]$Detail = ''
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$dir = Join-Path $root '_runtime'
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$log = Join-Path $dir 'ops-log.ndjson'
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$rec = (@{ ts = $ts; event = $Event; detail = $Detail } | ConvertTo-Json -Compress)
Add-Content -LiteralPath $log -Value $rec -Encoding UTF8
Write-Output "logged: $rec"
