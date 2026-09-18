param(
    [string]$ProjectRoot = '.',
    [int]$MaxNowLines = 30,
    [switch]$NoFreshness
)
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/doc-state.ps1')

$s = Get-DocState -ProjectRoot $ProjectRoot
if (-not $s.Ok) { Write-Output ('FAIL: ' + $s.Error); exit 1 }
if ($s.Errors.Count -gt 0) { Write-Output ('FAIL: ' + ($s.Errors -join ' | ')); exit 1 }

$fail = @()
$warn = @()

# 1. NOW must be actionable: a next step, and a read-first list that resolves on disk.
if (-not $s.Next) { $fail += 'no next step' }
if ($s.ReadFirst.Count -eq 0) { $fail += 'no read-first list' }
foreach ($p in $s.ReadFirst) {
    if (-not (Test-Path -LiteralPath (Join-Path $s.Root $p))) { $fail += "read-first missing: $p" }
}

# 2. The on-disk status file must exist, be strict UTF-8 (no mojibake), and carry the marker.
$cs = Join-Path $s.Root 'CURRENT_STATUS.md'
if (-not (Test-Path -LiteralPath $cs)) {
    $fail += 'no CURRENT_STATUS.md'
} else {
    $bytes = [System.IO.File]::ReadAllBytes($cs)
    $strict = New-Object System.Text.UTF8Encoding($false, $true)
    $text = ''
    try { $text = $strict.GetString($bytes) } catch { $fail += 'CURRENT_STATUS.md is not valid UTF-8 (mojibake)' }
    if ($text) {
        # 3. ## NOW must be bounded - history must not leak into it.
        $lines = $text -split "`r?`n"
        $start = -1
        for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^##\s+NOW\s*$') { $start = $i; break } }
        if ($start -lt 0) {
            $fail += 'no ## NOW block'
        } else {
            $end = $lines.Count
            for ($i = $start + 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^##\s') { $end = $i; break } }
            $nowLines = $end - $start
            if ($nowLines -gt $MaxNowLines) { $fail += "## NOW is $nowLines lines (> $MaxNowLines)" }
            $block = ($lines[$start..($end - 1)] -join "`n")
            if ($block -notmatch '(?m)^-\s+\*\*(?:Refreshed|Last refreshed)') { $fail += '## NOW has no refresh marker' }
        }
    }
}

# 4. Freshness vs. real work: if project files changed after the last recorded event,
#    the state was not recorded - exactly the loss a session switch would make permanent.
if (-not $NoFreshness) {
    $skip = '(^|/)(\.git|\.venv|node_modules|inbox|outbox|__pycache__|\.claude|\.claude-plugin|_[^/]*)(/|$)'
    $workDate = [datetime]::MinValue
    $newest = @()
    $note = 'file mtimes'

    # In a git working copy, mtimes are not evidence: a fresh clone stamps every file with the
    # checkout time, which would make the published tree fail its own gate the day after release.
    # There, "work" means uncommitted changes, plus a commit that changed something without touching
    # the event log. Outside git, mtimes are all we have.
    $isGit = $false
    $lastCommitDate = $null
    $lastCommitTouchesLog = $false
    if (Test-Path -LiteralPath (Join-Path $s.Root '.git')) {
        $d = (& git -C $s.Root log -1 --format=%cd --date=short 2>$null)
        if ($LASTEXITCODE -eq 0 -and $d) {
            $isGit = $true
            $lastCommitDate = ([string]$d).Trim()
            $names = (& git -C $s.Root log -1 --name-only --format= 2>$null)
            if (($names -join "`n") -match '(^|/)events\.log\s*$') { $lastCommitTouchesLog = $true }
        }
    }

    function Add-WorkDate([datetime]$d, [string]$rel) {
        if ($d -gt $script:workDate) { $script:workDate = $d; $script:newest = @($rel) }
        elseif ($d -eq $script:workDate) { $script:newest += $rel }
    }

    if ($isGit) {
        $note = 'uncommitted changes'
        $dirty = @(& git -C $s.Root status --porcelain -uall 2>$null)
        foreach ($line in $dirty) {
            if (-not $line -or $line.Length -lt 4) { continue }
            $rel = $line.Substring(3).Trim().Trim('"')
            if ($rel -match ' -> ') { $rel = ($rel -split ' -> ')[-1].Trim().Trim('"') }
            $rel = $rel.Replace('\', '/')
            if ($rel -match $skip) { continue }
            if ($rel -eq 'CURRENT_STATUS.md' -or $rel -eq 'events.log') { continue }
            $full = Join-Path $s.Root $rel
            if (Test-Path -LiteralPath $full) { Add-WorkDate (Get-Item -LiteralPath $full).LastWriteTime.Date $rel }
            else { Add-WorkDate (Get-Date).Date $rel }   # deletion is work too
        }
        if (-not $lastCommitTouchesLog -and $lastCommitDate) {
            $note = 'uncommitted changes or the last commit'
            Add-WorkDate ([datetime]::ParseExact($lastCommitDate, 'yyyy-MM-dd', $null)) ('commit ' + $lastCommitDate)
        }
    } else {
        Get-ChildItem -LiteralPath $s.Root -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($s.Root.Length + 1).Replace('\', '/')
            if ($rel -match $skip) { return }
            if ($rel -eq 'CURRENT_STATUS.md') { return }
            # events.log changing means recording happened (or a deliberate migration), not unrecorded
            # work; whether it was projected is already covered by the projection-freshness check.
            if ($rel -eq 'events.log') { return }
            Add-WorkDate $_.LastWriteTime.Date $rel
        }
    }
    if ($s.LastEventDate -match '^\d{4}-\d{2}-\d{2}$' -and $workDate -gt [datetime]::ParseExact($s.LastEventDate, 'yyyy-MM-dd', $null)) {
        $fail += ('unrecorded work scored from {0}: {1} is newer than the last event ({2}) - record it' -f $note, (($newest | Select-Object -First 3) -join ', '), $s.LastEventDate)
    }
}

if ($fail.Count -gt 0) { Write-Output ('FAIL: ' + ($fail -join ' | ')); exit 1 }
if ($warn.Count -gt 0) { $warn | ForEach-Object { Write-Output ('WARN: ' + $_) } }
if ($s.ActiveUnitIds.Count -eq 0) {
    Write-Output ('PASS: idle (no active units; next + read-first present; NOW bounded; state current)')
} else {
    Write-Output ('PASS: ' + $s.ActiveUnitIds.Count + ' active unit(s); NOW bounded/fresh; next + read-first resolvable')
}
