param(
    [string]$ProjectRoot = '.',
    # Closes are normally backed by an artifact that exists (root); judgments are normally a stated
    # decision (decision). They are separate knobs because one default would mislabel one of them.
    [ValidateSet('root','decision','reported')][string]$CloseClass = 'root',
    [ValidateSet('root','decision','reported')][string]$JudgmentClass = 'decision',
    [string]$Reason = '',
    [switch]$WhatIf
)
# One-time event-schema migration for a project that adopted doc-harness before a schema change
# (for example: before `class=` became mandatory on closes and judgments).
#
# Append-only is the rule for *recording*; adopting a stricter schema is a deliberate, one-time
# rewrite, and this tool makes it auditable instead of hand-made:
#   1. archive the pre-migration log to _archive/events-pre-migration-<date>.log (evidence)
#   2. normalize the events (append the missing field to closes/judgments)
#   3. leave a comment line in the log recording what was migrated and where the old log went
#      (comments replay as no-ops, so the projection is untouched by the record itself)
#   4. re-project
# It never invents evidence: closes with no evidence= at all are reported, not patched.
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$ev = Join-Path $root 'events.log'
if (-not (Test-Path -LiteralPath $ev)) { Write-Output 'FAIL: events.log not found'; exit 1 }

$today = Get-Date -Format 'yyyy-MM-dd'
$lines = [System.IO.File]::ReadAllLines($ev, [System.Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$changed = 0
$noEvidence = @()

foreach ($line in $lines) {
    $t = $line.TrimEnd()
    if (-not $t.Trim() -or $t.Trim().StartsWith('#')) { $out.Add($t); continue }
    $p = $t.Trim() -split ' ', 3
    $verb = if ($p.Count -ge 2) { $p[1] } else { '' }
    $payload = if ($p.Count -ge 3) { $p[2] } else { '' }
    if (($verb -eq 'unit:close' -or $verb -eq 'judgment:set') -and $payload -notmatch 'class=(root|decision|reported)') {
        $id = ($payload -split ' ', 2)[0]
        if ($verb -eq 'unit:close' -and $payload -notmatch 'evidence=') { $noEvidence += $id }
        $cls = if ($verb -eq 'unit:close') { $CloseClass } else { $JudgmentClass }
        $t = $t + ' class=' + $cls
        $changed++
    }
    $out.Add($t)
}

if ($changed -eq 0) {
    if ($noEvidence.Count -gt 0) { Write-Output ('FAIL: closes with no evidence= : ' + ($noEvidence -join ', ')); exit 1 }
    Write-Output 'nothing to migrate (every close/judgment already carries a class)'
    exit 0
}

$archiveRel = '_archive/events-pre-migration-' + $today + '.log'
$archiveFull = Join-Path $root ($archiveRel.Replace('/','\'))
$note = '# ' + $today + ' schema migration: added class= to ' + $changed + ' event(s) (closes -> ' + $CloseClass + ', judgments -> ' + $JudgmentClass + ')'
if ($Reason) { $note += ' (' + $Reason + ')' }
$note += '; pre-migration log archived at ' + $archiveRel
if ($noEvidence.Count -gt 0) { $note += '; STILL MISSING evidence: ' + ($noEvidence -join ', ') }
$out.Add($note)

if ($WhatIf) {
    Write-Output ('WHATIF: would migrate ' + $changed + ' event(s), archive to ' + $archiveRel)
    if ($noEvidence.Count -gt 0) { Write-Output ('WHATIF: still missing evidence on: ' + ($noEvidence -join ', ')) }
    exit 0
}

$archiveDir = Split-Path -Parent $archiveFull
if (-not (Test-Path -LiteralPath $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }
[System.IO.File]::WriteAllLines($archiveFull, $lines, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::WriteAllLines($ev, $out, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ('migrated ' + $changed + ' event(s); pre-migration log -> ' + $archiveRel)

$proj = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $toolsDir 'project.ps1'),'-ProjectRoot',$root,'-Write') -Wait -PassThru -WindowStyle Hidden
if ($proj.ExitCode -ne 0) { Write-Output 'FAIL: project.ps1'; exit $proj.ExitCode }
Write-Output 're-projected'
if ($noEvidence.Count -gt 0) { Write-Output ('WARN: still missing evidence on: ' + ($noEvidence -join ', ') + ' - add it by hand where the artifact is known') }
Write-Output ('REMINDER: register ' + $archiveRel + ' in FILE_INDEX.md')
