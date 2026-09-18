param(
    [string]$ProjectRoot = '.',
    [ValidateSet('open','activate','close','pause','next','judgment','read','plan','deadend','note')][string]$Verb,
    [string]$Text,
    # Raw event lines ("<verb> <payload>"), for recording several state changes at once. An element
    # may itself contain newlines (one event per line). The date is added; verbs are validated
    # before anything is written, so a batch never half-applies.
    [string[]]$Events = @(),
    # Robust batch path: a UTF-8 file with one raw event per line (blank lines and # comments are
    # ignored). Prefer this when calling via `powershell -File` - there, an array argument arrives
    # as one comma-joined string, which is easy to get silently wrong.
    [string]$EventsFile = ''
)
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/doc-state.ps1')
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$ev = Join-Path $root 'events.log'
if (-not (Test-Path -LiteralPath $ev)) { Write-Output 'FAIL: events.log not found'; exit 1 }
$verbMap = @{ open='unit:open'; activate='unit:activate'; close='unit:close'; pause='unit:pause'; next='next:set'; judgment='judgment:set'; read='read-first:set'; plan='plan:set'; deadend='dead-end:set'; note='note:set' }
$date = Get-Date -Format 'yyyy-MM-dd'

$raw = New-Object System.Collections.Generic.List[string]
if ($Verb) {
    if (-not $Text) { Write-Output 'FAIL: -Verb requires -Text'; exit 1 }
    $raw.Add($verbMap[$Verb] + ' ' + $Text)
} elseif ($Text) {
    Write-Output 'FAIL: -Text requires -Verb'; exit 1
}
foreach ($e in $Events) {
    foreach ($one in ($e -split "`r?`n")) { if ($one.Trim()) { $raw.Add($one.Trim()) } }
}
if ($EventsFile) {
    if (-not (Test-Path -LiteralPath $EventsFile)) { Write-Output ('FAIL: events file not found: ' + $EventsFile); exit 1 }
    foreach ($one in [System.IO.File]::ReadAllLines($EventsFile, [System.Text.Encoding]::UTF8)) {
        $t = $one.Trim()
        if (-not $t -or $t.StartsWith('#')) { continue }
        $raw.Add($t)
    }
}
if ($raw.Count -eq 0) { Write-Output 'FAIL: nothing to record (use -Verb/-Text, -Events or -EventsFile)'; exit 1 }

$known = @($verbMap.Values)
# Fail closed: a comma-joined batch (the `powershell -File` array trap) looks like
# "unit:open x,unit:activate x" - one line, two events, silently recorded as one. Refuse it.
$suspect = @($raw | Where-Object { $_ -match ',\s*(unit:(open|activate|close|pause)|next:set|judgment:set|read-first:set|plan:set|dead-end:set|note:set)\b' })
if ($suspect.Count -gt 0) {
    Write-Output 'FAIL: a comma-joined line looks like several events glued together; separate them with newlines or use -EventsFile'
    exit 1
}
$bad = @($raw | Where-Object { $known -notcontains (($_ -split ' ', 2)[0]) })
if ($bad.Count -gt 0) { Write-Output ('FAIL: unknown verb in: ' + ($bad -join ' | ')); exit 1 }

$lines = @($raw | ForEach-Object { "$date $_" })
Add-Content -LiteralPath $ev -Value $lines -Encoding UTF8
$lines | ForEach-Object { Write-Output ("appended: " + $_) }

# Re-project only if the log is well-formed: a malformed event must not overwrite a good projection.
$proj = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $toolsDir 'project.ps1'),'-ProjectRoot',$root,'-Write') -Wait -PassThru -WindowStyle Hidden
if ($proj.ExitCode -ne 0) { Write-Output 'FAIL: event appended, but the log did not parse - fix the event, then re-project'; exit $proj.ExitCode }
Write-Output ('recorded ' + $lines.Count + ' event(s) + re-projected CURRENT_STATUS.md')

# Conformance has two very different outcomes here, and conflating them misleads: a failure means
# SOME guard is red, not that the record failed. Say which.
$confOut = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $toolsDir 'conformance.ps1') -ProjectRoot $root 2>&1
$confCode = $LASTEXITCODE
if ($confCode -ne 0) {
    Write-Output ('conformance: RED - ' + (($confOut | Where-Object { $_ -match '\S' }) -join ' | '))
    Write-Output 'note: the event IS recorded and the projection IS updated; the red items above are separate issues - fix them, then re-run conformance'
    exit $confCode
}
Write-Output 'PASS: recorded + re-projected + conformance green'
