param([string]$ProjectRoot = '.', [switch]$Full)
$ErrorActionPreference = 'Continue'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/pshost.ps1')
$fail = @()
foreach ($t in @('now-verify.ps1','encoding-guard.ps1','unregistered.ps1','dead-pointer.ps1','recurrence.ps1','cite-check.ps1','stale-check.ps1','skill-consistency.ps1','entry-check.ps1','toolbelt-sync.ps1')) {
  $script = Join-Path $toolsDir $t
  $code = Invoke-PsScript -Script $script -ScriptArgs @('-ProjectRoot',$root)
  if ($code -ne 0) { $fail += ("{0}(exit {1})" -f $t, $code) }
}

# The embedded ops block must equal the installed ops source (skipped when no source is present).
# Conformance never writes, so this runs in -Check mode.
$oe = Invoke-PsScript -Script (Join-Path $toolsDir 'ops-embed.ps1') -ScriptArgs @('-ProjectRoot',$root,'-Check')
if ($oe -ne 0) { $fail += ("ops-embed.ps1(exit {0})" -f $oe) }

# -Full additionally runs the mechanism regression test (a fixture project in a temp dir). It is
# kept out of the default path so that recording one state change stays fast, and is meant for
# release/CI or whenever the projection machinery itself was touched.
if ($Full) {
  $ht = Join-Path $toolsDir 'handoff-test.ps1'
  $code = Invoke-PsScript -Script $ht
  if ($code -ne 0) { $fail += ("handoff-test.ps1(exit {0})" -f $code) }
}

# Version drift: ops sentinel in CLAUDE.md must equal spec **Version** line (skip if spec absent).
$claudePath = Join-Path $root 'CLAUDE.md'
$specPath = Join-Path $root 'DOC_HARNESS_SPEC.md'
if ((Test-Path -LiteralPath $claudePath) -and (Test-Path -LiteralPath $specPath)) {
  $ops = (Select-String -LiteralPath $claudePath -Pattern 'doc-harness-ops-version:\s*([0-9.]+)' | Select-Object -First 1).Matches.Groups[1].Value
  $spec = (Select-String -LiteralPath $specPath -Pattern '\*\*Version\*\*:\s*v?([0-9.]+)' | Select-Object -First 1).Matches.Groups[1].Value
  if ($ops -and $spec -and $ops -ne $spec) {
    $fail += ("version-drift ops={0} spec={1}" -f $ops, $spec)
  }
}

# Projection freshness: in-memory projection from events.log must equal disk CURRENT_STATUS.md.
. (Join-Path $toolsDir 'lib/doc-state.ps1')
$state = Get-DocState -ProjectRoot $root
if ($state.Ok -and $state.Errors.Count -eq 0) {
  $expected = Render-CurrentStatus -State $state
  $diskPath = Join-Path $root 'CURRENT_STATUS.md'
  if (Test-Path -LiteralPath $diskPath) {
    # Normalize line endings before comparing: a CRLF checkout must not read as a stale projection.
    $disk = [System.IO.File]::ReadAllText($diskPath, [System.Text.Encoding]::UTF8).Replace("`r`n","`n").TrimEnd("`n")
    $exp = $expected.Replace("`r`n","`n").TrimEnd("`n")
    if ($disk -ne $exp) { $fail += 'projection-stale (CURRENT_STATUS.md != events.log projection)' }
  } else {
    $fail += 'projection-missing (no CURRENT_STATUS.md)'
  }
} else {
  $fail += ('events-parse-failed: ' + ($state.Errors -join ' | '))
}

$ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$result = if ($fail.Count -gt 0) { 'FAIL' } else { 'PASS' }
$rec = (@{ ts = $ts; event = 'conformance'; detail = ($fail -join ', ') } | ConvertTo-Json -Compress)
$rt = Join-Path $root '_runtime'
if (-not (Test-Path -LiteralPath $rt)) { New-Item -ItemType Directory -Path $rt -Force | Out-Null }
Add-Content -LiteralPath (Join-Path $rt 'ops-log.ndjson') -Value $rec -Encoding UTF8
if ($fail.Count -gt 0) {
  Write-Output ('FAIL: ' + ($fail -join ', '))
  exit 1
} else {
  Write-Output 'PASS: tools + version conformance'
}
