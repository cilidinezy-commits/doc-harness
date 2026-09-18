param(
    [string]$WorkDir = '',
    [switch]$Keep
)
# Deterministic regression test of the handoff mechanism itself.
#
# It builds a deliberately NON-LINEAR fixture (units across two parts, opened/activated/closed in
# interleaved order, one paused, one dead end), then asserts the claims the spec makes about the
# projection - and asserts that the guards are not vacuous (they must go red on broken input).
#
# This is the deterministic half of "handoff verification"; the judgment half (a reader recovering
# the state from the entry documents alone) can only be done by a reader, and is recorded in notes.
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/doc-state.ps1')
. (Join-Path $toolsDir 'lib/pshost.ps1')

if (-not $WorkDir) {
    # Path::GetTempPath() is the portable one: $env:TEMP does not exist on Linux/macOS.
    $WorkDir = Join-Path ([System.IO.Path]::GetTempPath()) ('doc-harness-handoff-' + ([Guid]::NewGuid().ToString('N').Substring(0, 8)))
}
New-Item -ItemType Directory -Path (Join-Path $WorkDir 'notes') -Force | Out-Null
$today = Get-Date -Format 'yyyy-MM-dd'

$fail = @()
$done = @()
function Assert($name, $cond, $detail) {
    if ($cond) { $script:done += $name } else { $script:fail += ($name + ' :: ' + $detail) }
}

# ---------------------------------------------------------------- fixture
$events = @(
    '# events.log - handoff-test fixture (append-only; one event per line)',
    "$today plan:set research | design | build",
    "$today unit:open A/alpha establish baseline",
    "$today unit:open A/beta  extend corpus",
    "$today unit:activate A/alpha",
    "$today unit:open B/gamma cross-part insert",
    "$today unit:activate B/gamma",
    "$today unit:open A/delta abandoned path",
    "$today unit:close A/delta evidence=notes/alpha.md class=root",
    "$today unit:pause A/beta",
    "$today next:set finish A/alpha baseline blocker=waiting for user confirmation",
    "$today read-first:set notes/alpha.md, notes/beta.md",
    "$today judgment:set event log is the primitive source=notes/alpha.md class=decision",
    "$today dead-end:set A/delta: tried chronological recording; it distorts cross-part jumps",
    "$today note:set re-embedded the ops block and re-ran the guards"
)
foreach ($f in @('events.log','notes/alpha.md','notes/beta.md')) {
    $full = Join-Path $WorkDir $f
    $body = if ($f -eq 'events.log') { $events } else { @('# ' + $f) }
    [System.IO.File]::WriteAllLines($full, $body, (New-Object System.Text.UTF8Encoding($false)))
}
$index = @(
    '# FILE_INDEX - handoff-test fixture', '',
    '## Core Documents',
    '- `CLAUDE.md` - fixture entry',
    '- `events.log` - event log',
    '- `CURRENT_STATUS.md` - projection',
    '- `FILE_INDEX.md` - this file', '',
    '## Notes',
    '- `notes/alpha.md` - fixture note',
    '- `notes/beta.md` - fixture note'
)
[System.IO.File]::WriteAllLines((Join-Path $WorkDir 'FILE_INDEX.md'), $index, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::WriteAllLines((Join-Path $WorkDir 'CLAUDE.md'), @(
    '# fixture - Entry Document',
    '',
    '> AGENT IDENTITY LOCK',
    '>',
    '> You are the fixture project agent. Scope: nothing at all.',
    '',
    'Stable anchor placeholder.'
), (New-Object System.Text.UTF8Encoding($false)))

$projCode = Invoke-PsScript -Script (Join-Path $toolsDir 'project.ps1') -ScriptArgs @('-ProjectRoot',$WorkDir,'-Write')
Assert 'project runs' ($projCode -eq 0) ('project.ps1 exit ' + $projCode)
$csPath = Join-Path $WorkDir 'CURRENT_STATUS.md'
if (-not (Test-Path -LiteralPath $csPath)) { Write-Output ('FAIL: projection not written to ' + $csPath); exit 1 }
$cs = [System.IO.File]::ReadAllText($csPath, [System.Text.Encoding]::UTF8)

# ---------------------------------------------------------------- claims about the projection
$s = Get-DocState -ProjectRoot $WorkDir
Assert 'log parses (comments ignored)' ($s.Ok -and $s.Errors.Count -eq 0) (($s.Errors) -join ' | ')

$again = Render-CurrentStatus -State (Get-DocState -ProjectRoot $WorkDir)
Assert 'projection is deterministic' (($again.Replace("`r`n","`n").TrimEnd("`n")) -eq ($cs.Replace("`r`n","`n").TrimEnd("`n"))) 'two renders differ'

$lines = $cs -split "`r?`n"
$start = [array]::IndexOf($lines, ($lines | Where-Object { $_ -match '^##\s+NOW\s*$' } | Select-Object -First 1))
$end = $lines.Count
for ($i = $start + 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^##\s') { $end = $i; break } }
$nowLines = $end - $start
Assert 'NOW is bounded (<= 30 lines)' ($nowLines -le 30) ("NOW is $nowLines lines")

$active = ($s.ActiveUnitIds -join ', ')
Assert 'frontier = activated units, in open order' ($active -eq 'A/alpha, B/gamma') ("active = $active")
Assert 'frontmatter matches frontier' ($cs -match 'active_unit_ids: \[A/alpha, B/gamma\]') 'frontmatter active_unit_ids wrong'
Assert 'paused unit is not active' ($s.Units | Where-Object { $_.Id -eq 'A/beta' }).State -eq 'paused' 'A/beta not paused'
Assert 'closed unit carries evidence' ($cs -match '\[done\] `A/delta` evidence=notes/alpha.md class=root') 'evidence missing from history'
Assert 'next step carries its blocker' ($s.Next -match 'blocker=') 'blocker missing'
Assert 'refresh marker present' ($cs -match '(?m)^-\s+\*\*Refreshed\*\*:\s+\d{4}-\d{2}-\d{2}\s*$') 'no Refreshed line'
Assert 'every read-first path resolves' (@($s.ReadFirst | Where-Object { -not (Test-Path -LiteralPath (Join-Path $WorkDir $_)) }).Count -eq 0) 'unresolvable read-first'
Assert 'judgment carries source + class' ($s.Judgment -match 'source=\S+ class=(root|decision|reported)') 'judgment source/class missing'
Assert 'negative ledger survives replay' ($s.DeadEnds.Count -eq 1) 'dead end not recorded'
Assert 'housekeeping note is recorded, dated, and rendered' (($s.Notes.Count -eq 1) -and ($cs -match "(?m)^- $today re-embedded the ops block")) 'note missing from projection'

# Structure: parts render as headings, so a branching project does not read as a linear list.
Assert 'parts render as headings' (($cs -match '(?m)^#### A\s*$') -and ($cs -match '(?m)^#### B\s*$')) 'no per-part heading'
Assert 'plan renders as parts, not one line' (($cs -match '(?m)^- research\s*$') -and ($cs -match '(?m)^- build\s*$')) 'plan not split'

# ---------------------------------------------------------------- guards must not be vacuous
$brokenDir = Join-Path $WorkDir '..broken'
New-Item -ItemType Directory -Path $brokenDir -Force | Out-Null
$kept = $events | Where-Object { $_ -notmatch '^' + [regex]::Escape($today) + ' unit:open A/alpha ' }
[System.IO.File]::WriteAllLines((Join-Path $brokenDir 'events.log'), $kept, (New-Object System.Text.UTF8Encoding($false)))
$bs = Get-DocState -ProjectRoot $brokenDir
Assert 'activate-before-open is caught' ($bs.Errors.Count -gt 0) 'broken log parsed clean'

$tampered = $cs + "- hand-edited line`n"
$expected = Render-CurrentStatus -State $s
Assert 'hand editing is caught as projection-stale' (($tampered.Replace("`r`n","`n").TrimEnd("`n")) -ne ($expected.Replace("`r`n","`n").TrimEnd("`n"))) 'tamper not detected'

$confCode = Invoke-PsScript -Script (Join-Path $toolsDir 'conformance.ps1') -ScriptArgs @('-ProjectRoot',$WorkDir)
Assert 'conformance is green on the fixture' ($confCode -eq 0) ('conformance exit ' + $confCode)

# ---------------------------------------------------------------- schema migration
# A project that predates a schema change must be able to adopt it without hand-editing the log,
# and without the guards staying red forever.
$migDir = Join-Path $WorkDir '..migrate'
New-Item -ItemType Directory -Path $migDir -Force | Out-Null
[System.IO.File]::WriteAllLines((Join-Path $migDir 'events.log'), @(
    "$today unit:open T1 old style close",
    "$today unit:close T1 evidence=notes/alpha.md",
    "$today judgment:set an old judgment source=notes/alpha.md"
), (New-Object System.Text.UTF8Encoding($false)))
$check1 = Invoke-PsScript -Script (Join-Path $toolsDir 'cite-check.ps1') -ScriptArgs @('-ProjectRoot',$migDir)
Assert 'pre-migration log fails cite-check' ($check1 -ne 0) 'missing class was not caught'
$migCode = Invoke-PsScript -Script (Join-Path $toolsDir 'log-migrate.ps1') -ScriptArgs @('-ProjectRoot',$migDir,'-Reason','handoff-test')
Assert 'migration runs' ($migCode -eq 0) ('log-migrate exit ' + $migCode)
$check2 = Invoke-PsScript -Script (Join-Path $toolsDir 'cite-check.ps1') -ScriptArgs @('-ProjectRoot',$migDir)
Assert 'post-migration log passes cite-check' ($check2 -eq 0) 'migration did not satisfy the guard'
Assert 'migration archived the old log' (Test-Path -LiteralPath (Join-Path $migDir ('_archive/events-pre-migration-' + $today + '.log'))) 'no archive'
Assert 'migration left a comment trail, not a fake event' ([System.IO.File]::ReadAllText((Join-Path $migDir 'events.log'), [System.Text.Encoding]::UTF8) -match '(?m)^#.*schema migration') 'no comment trail'

# ---------------------------------------------------------------- report
if (-not $Keep) {
    Remove-Item -LiteralPath $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $brokenDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $migDir -Recurse -Force -ErrorAction SilentlyContinue
}
if ($fail.Count -gt 0) {
    Write-Output ('FAIL: handoff test (' + $fail.Count + ' of ' + ($fail.Count + $done.Count) + ' assertions failed)')
    $fail | ForEach-Object { Write-Output ('  x ' + $_) }
    exit 1
}
Write-Output ('PASS: handoff test - ' + $done.Count + ' assertions (projection, frontier, parts, evidence, guards)')
