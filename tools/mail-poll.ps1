param(
    [string]$Inbox = '.\inbox',
    [int]$IntervalSeconds = 60,
    [int]$CheckInSeconds = 7200,
    [string]$Heartbeat = '.\_runtime\mail-poll-heartbeat.log',
    [int]$NotifyDelaySeconds = 0
)
$ErrorActionPreference = 'SilentlyContinue'
$hbDir = Split-Path -Parent $Heartbeat
if ($hbDir) { New-Item -ItemType Directory -Path $hbDir -Force | Out-Null }
$start = Get-Date
while ($true) {
    Start-Sleep -Seconds $IntervalSeconds
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $unread = Get-ChildItem -LiteralPath $Inbox -Filter *.md -File | Where-Object {
        $head = Get-Content -LiteralPath $_.FullName -TotalCount 12 -Encoding UTF8
        ($head | Select-String '^status:\s*unread')
    }
    if ($unread) {
        if ($NotifyDelaySeconds -gt 0) { Start-Sleep -Seconds $NotifyDelaySeconds }
        Add-Content -LiteralPath $Heartbeat -Value "[$ts] ACTIONABLE" -Encoding UTF8
        foreach ($f in $unread) { Write-Output ("TASK=inbox|ITEM=" + $f.Name) }
        exit 0
    }
    $elapsed = ((Get-Date) - $start).TotalSeconds
    if ($elapsed -ge $CheckInSeconds) {
        Add-Content -LiteralPath $Heartbeat -Value "[$ts] CHECKIN" -Encoding UTF8
        Write-Output 'CHECKIN'
        exit 0
    }
    Add-Content -LiteralPath $Heartbeat -Value "[$ts] no mail" -Encoding UTF8
}
