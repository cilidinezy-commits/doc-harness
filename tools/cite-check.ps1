param([string]$ProjectRoot = '.')
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/doc-state.ps1')
$s = Get-DocState -ProjectRoot $ProjectRoot
if (-not $s.Ok) { Write-Output ('FAIL: ' + $s.Error); exit 1 }
$missing = @()
if ($s.Judgment -and $s.Judgment -notmatch 'source=') { $missing += 'judgment has no source' }
if ($s.Judgment -and $s.Judgment -notmatch 'class=(root|decision|reported)') { $missing += 'judgment source has no class (root|decision|reported)' }
foreach ($u in $s.Units) {
    if ($u.State -eq 'done') {
        if ($u.Evidence -notmatch 'evidence=') { $missing += "unit $($u.Id) has no evidence" }
        if ($u.Evidence -notmatch 'class=(root|decision|reported)') { $missing += "unit $($u.Id) evidence has no class (root|decision|reported)" }
    }
}
if ($missing.Count -gt 0) { Write-Output ('FAIL: ' + ($missing -join ' | ')); exit 1 }
Write-Output 'PASS: judgments and active/done units carry source/evidence'
