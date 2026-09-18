param(
    [string]$ProjectRoot = '.',
    [string]$Inbox = '',
    [string]$Heartbeat = '',
    [string]$StatusFile = '',
    [int]$IntervalSeconds = 60,
    [int]$CheckInSeconds = 7200,
    [int]$NotifyDelaySeconds = 0,
    [string]$ProcessCommand = '',
    [int]$StaleMinutes = 60,
    [int]$QuietSeconds = 120,
    [int]$MaxConsecutiveFailures = 3,
    [switch]$Once
)
$ErrorActionPreference = 'SilentlyContinue'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (-not $Inbox) { $Inbox = Join-Path $root 'inbox' }
if (-not $Heartbeat) { $Heartbeat = Join-Path $root '_runtime\mail-daemon-heartbeat.log' }
if (-not $StatusFile) { $StatusFile = Join-Path $root '_runtime\mail-status.md' }
$procDir = Join-Path $Inbox '_processing'
$log = Join-Path $root '_runtime\mail-daemon.log'
New-Item -ItemType Directory -Path $procDir -Force | Out-Null
$hbDir = Split-Path -Parent $Heartbeat
if ($hbDir) { New-Item -ItemType Directory -Path $hbDir -Force | Out-Null }

function Log($m) {
    Add-Content -LiteralPath $log -Value ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m) -Encoding UTF8
}
function WriteStatus($unreadCount, $unreadNames, $processingNames, $note) {
    $now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $lines = @('# Mail Auto-Poll Status','',"**Last check**: $now",'', '| Item | Value |','|------|-------|',"| Unread | $unreadCount |", "| Unread list | $($unreadNames -join '; ') |", "| Processing | $($processingNames -join '; ') |", "| Note | $note |")
    Set-Content -LiteralPath $StatusFile -Value $lines -Encoding UTF8
    Add-Content -LiteralPath $Heartbeat -Value ("[{0}] {1}" -f $now, $note) -Encoding UTF8
}

$start = Get-Date
$failCount = 0
$lastLaunch = [datetime]::MinValue

while ($true) {
    Start-Sleep -Seconds $IntervalSeconds

    # crash recovery: stale _processing (abandoned) back to inbox
    $stale = Get-ChildItem -LiteralPath $procDir -Filter *.md | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMinutes(-$StaleMinutes) }
    foreach ($s in $stale) {
        Move-Item -LiteralPath $s.FullName -Destination (Join-Path $Inbox $s.Name) -Force
        Log "recovered stale lock: $($s.Name)"
    }
    $processingNames = @(Get-ChildItem -LiteralPath $procDir -Filter *.md | ForEach-Object { $_.Name })

    $unread = @()
    foreach ($f in (Get-ChildItem -LiteralPath $Inbox -Filter *.md)) {
        $c = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
        if ($c -match 'status:\s*unread') { $unread += $f }
    }

    if ($unread.Count -eq 0) {
        WriteStatus 0 @() $processingNames 'no unread'
    } else {
        if ($NotifyDelaySeconds -gt 0) { Start-Sleep -Seconds $NotifyDelaySeconds }
        WriteStatus $unread.Count @($unread.Name) $processingNames 'unread found'
        if ($ProcessCommand) {
            if (((Get-Date) - $lastLaunch).TotalSeconds -lt $QuietSeconds) {
                WriteStatus $unread.Count @($unread.Name) $processingNames 'quiet period; waiting'
                continue
            }
            $toProcess = @($unread | Where-Object { $processingNames -notcontains $_.Name })
            foreach ($f in $toProcess) { Move-Item -LiteralPath $f.FullName -Destination (Join-Path $procDir $f.Name) -Force }
            if ($toProcess.Count -gt 0) {
                $lastLaunch = Get-Date
                Log "launching processor for: $($toProcess.Name -join ', ')"
                $out = cmd /c $ProcessCommand 2>&1
                if ($LASTEXITCODE -ne 0) {
                    $failCount++
                    Log "processor FAILED (exit $LASTEXITCODE)"
                } else {
                    $failCount = 0
                }
                if ($failCount -ge $MaxConsecutiveFailures) {
                    WriteStatus $unread.Count @($unread.Name) $processingNames "PAUSED: $failCount consecutive failures"
                    Log "PAUSED: consecutive failures"
                    break
                }
            }
        } else {
            foreach ($f in $unread) { Write-Output ("TASK=inbox|ITEM=" + $f.Name) }
        }
    }

    if (((Get-Date) - $start).TotalSeconds -ge $CheckInSeconds) {
        WriteStatus $unread.Count @($unread.Name) $processingNames 'CHECKIN'
        Log 'CHECKIN'
        $start = Get-Date
    }

    if ($Once) { break }
}
