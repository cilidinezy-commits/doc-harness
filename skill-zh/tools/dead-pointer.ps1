param([string]$ProjectRoot = '.')
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/doc-state.ps1')
$s = Get-DocState -ProjectRoot $ProjectRoot
if (-not $s.Ok) { Write-Output ('FAIL: ' + $s.Error); exit 1 }
$dead = @()
foreach ($p in $s.ReadFirst) {
    if (-not (Test-Path -LiteralPath (Join-Path $s.Root $p))) { $dead += "read-first: $p" }
}
foreach ($u in $s.Units) {
    if ($u.Evidence -match 'evidence=(\S+)') {
        $path = $Matches[1]
        if (-not (Test-Path -LiteralPath (Join-Path $s.Root $path))) { $dead += "unit $($u.Id): $path" }
    }
}
$idx = Join-Path $s.Root 'FILE_INDEX.md'
if (Test-Path -LiteralPath $idx) {
    $txt = Get-Content -LiteralPath $idx -Encoding UTF8
    foreach ($line in $txt) {
        if ($line -match '^\s*-\s*`([^`]+)`') {
            $ref = ($Matches[1] -split '#')[0].Trim()
            if ($ref -match '^[A-Za-z0-9_./\\-]+$' -and $ref -match '\.[A-Za-z0-9]+$') {
                if (-not (Test-Path -LiteralPath (Join-Path $s.Root $ref))) { $dead += "FILE_INDEX: $ref" }
            }
        }
    }
}
if ($dead.Count -gt 0) { Write-Output ('FAIL: ' + ($dead -join ' | ')); exit 1 }
Write-Output 'PASS: no dead pointers'
