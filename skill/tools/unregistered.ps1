param([string]$ProjectRoot = '.')
$ErrorActionPreference = 'SilentlyContinue'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$indexPath = Join-Path $root 'FILE_INDEX.md'
if (-not (Test-Path -LiteralPath $indexPath)) { Write-Output 'FAIL: root FILE_INDEX.md not found'; exit 1 }

# Register only the ROOT FILE_INDEX entries, by exact relative path (no bare-filename fallback,
# no nested-project index reuse) - fixes the F3 false PASS/whitewash issues.
$txt = Get-Content -LiteralPath $indexPath -Encoding UTF8 -Raw
$registered = @{}
foreach ($m in [regex]::Matches($txt, '`([^`]+)`')) {
  $p = $m.Groups[1].Value.Trim().Replace('\','/').TrimStart('/')
  $registered[$p] = $true
}

# Skip scratch / VCS / dependency / mailbox directories, plus nested projects (any ancestor
# directory below root that contains its own CLAUDE.md or AGENTS.md).
$skip = '(^|/)(\.git|\.venv|node_modules|inbox|outbox|__pycache__|\.claude-plugin|_[^/]*|\.[^/]+)(/|$)'
# The toolbelt mirrors inside the skill folders are skipped: they are covered by the canonical
# `tools/` entries, and `toolbelt-sync.ps1` enforces that all copies are byte-identical.
$mirror = '^(skill|skill-zh)/tools/'
$unreg = @()
Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($root.Length + 1).Replace('\','/')
  if ($rel -match $skip) { return }
  if ($rel -match $mirror) { return }
  $d = Split-Path $_.FullName -Parent
  while ($d -and $d -ne $root) {
    if ((Test-Path -LiteralPath (Join-Path $d 'CLAUDE.md')) -or (Test-Path -LiteralPath (Join-Path $d 'AGENTS.md'))) { return }
    $d = Split-Path $d -Parent
  }
  if (-not $registered.ContainsKey($rel)) { $unreg += $rel }
}

if ($unreg.Count -gt 0) {
  Write-Output 'FAIL: unregistered files (root FILE_INDEX, exact-path):'
  $unreg | Sort-Object -Unique | ForEach-Object { Write-Output "  $_" }
  exit 1
} else {
  Write-Output 'PASS: no obvious unregistered files'
}
