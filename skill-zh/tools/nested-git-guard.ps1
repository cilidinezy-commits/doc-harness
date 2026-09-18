param([string]$RepoRoot = '.')
$ErrorActionPreference = 'SilentlyContinue'
$root = (Resolve-Path -LiteralPath $RepoRoot).Path
$staged = git -C $root diff --cached --name-only 2>$null
if (-not $staged) { Write-Output 'PASS: nothing staged'; exit 0 }
$bad = @()
foreach ($rel in $staged) {
  if (-not $rel) { continue }
  $full = Join-Path $root $rel
  $dir = Split-Path -Parent $full
  if (-not $dir) { continue }
  $cla = Join-Path $dir 'CLAUDE.md'
  if (Test-Path -LiteralPath $cla) {
    $claResolved = (Resolve-Path -LiteralPath $cla).Path
    $rootCla = Join-Path $root 'CLAUDE.md'
    if ($claResolved -ne $rootCla) {
      $bad += $rel
    }
  }
}
if ($bad.Count -gt 0) {
  Write-Output 'FAIL: staged file(s) inside a nested project that has its own CLAUDE.md:'
  $bad | Select-Object -Unique | ForEach-Object { Write-Output "  $_" }
  exit 1
} else {
  Write-Output 'PASS: no nested-project staging detected'
}
