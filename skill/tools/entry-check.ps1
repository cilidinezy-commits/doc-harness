param([string]$ProjectRoot = '.')
# Entry uniqueness, made checkable.
#
# The rule: CLAUDE.md is the single authoritative entry, and AGENTS.md (if present) is a thin
# pointer to it, never a second copy of the state. Two divergent entry files are a bug factory in
# harnesses that read both - but until now the rule rested on review. These are the mechanical parts
# of it: the entry carries an identity lock, and the pointer is small, points at the entry, and
# carries neither state sections nor its own copy of the operational rules.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$claude = Join-Path $root 'CLAUDE.md'
$agents = Join-Path $root 'AGENTS.md'
$fail = @()

if (-not (Test-Path -LiteralPath $claude)) {
    Write-Output 'SKIP: no CLAUDE.md here (not a doc-harness project)'
    exit 0
}

$entry = [System.IO.File]::ReadAllText($claude, [System.Text.Encoding]::UTF8)
if ($entry.IndexOf('AGENT IDENTITY LOCK', [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
    $fail += 'CLAUDE.md has no AGENT IDENTITY LOCK'
}

if (Test-Path -LiteralPath $agents) {
    $pointer = [System.IO.File]::ReadAllText($agents, [System.Text.Encoding]::UTF8)
    $lines = @([System.IO.File]::ReadAllLines($agents, [System.Text.Encoding]::UTF8) | Where-Object { $_.Trim() })
    if ($lines.Count -gt 15) { $fail += ("AGENTS.md is not a thin pointer: {0} non-empty lines (> 15)" -f $lines.Count) }
    if ($pointer -notmatch 'CLAUDE\.md') { $fail += 'AGENTS.md does not point at CLAUDE.md' }
    if ($pointer -match 'doc-harness-ops-(start|end)') { $fail += 'AGENTS.md embeds the operational rules (a second entry, not a pointer)' }
    if ($pointer -match '(?m)^##\s+(NOW|Work Surface|Recent History|Notes)') { $fail += 'AGENTS.md carries state sections (a second copy of state, not a pointer)' }
}

if ($fail.Count -gt 0) {
    Write-Output ('FAIL: ' + ($fail -join ' | '))
    exit 1
}
Write-Output 'PASS: single entry (identity lock present; AGENTS.md, if any, is a thin pointer)'
