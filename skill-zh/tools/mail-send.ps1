param(
    [string]$ProjectRoot = '.',
    [Parameter(Mandatory=$true)][string]$To,
    [string]$From = '',
    [string]$Subject = '',
    [string]$Body = '',
    [string]$BodyFile = '',
    [string]$Topic = 'message',
    [string]$InReplyTo = '',
    [string]$Priority = 'normal'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$recipient = (Resolve-Path -LiteralPath $To).Path
$outbox = Join-Path $root 'outbox'
$inbox = Join-Path $recipient 'inbox'
if (-not (Test-Path -LiteralPath $outbox)) { New-Item -ItemType Directory -Path $outbox -Force | Out-Null }
# A project's inbox is created by the first message that arrives (per the ops rules), so the sender
# creates it rather than failing: an absent inbox is not a reason the recipient cannot be reached.
if (-not (Test-Path -LiteralPath $inbox)) { New-Item -ItemType Directory -Path $inbox -Force | Out-Null }
if (-not $From) { $From = Split-Path $root -Leaf }
$bodyText = if ($BodyFile -and (Test-Path -LiteralPath $BodyFile)) { [System.IO.File]::ReadAllText($BodyFile, [System.Text.Encoding]::UTF8) } else { $Body }
$date = Get-Date -Format 'yyyy-MM-dd'
$slug = $Topic -replace '[^\w-]', '-'
$filename = "$date-from-$From-$slug.md"
$header = @(
    '---',
    "from: $From",
    "to: $(Split-Path $recipient -Leaf)",
    "date: $date",
    "subject: $Subject",
    'status: unread',
    "priority: $Priority"
)
if ($InReplyTo) { $header += "in-reply-to: $InReplyTo" }
$header += '---'
$header += ''
$full = ($header -join "`n") + $bodyText
$outPath = Join-Path $outbox $filename
[System.IO.File]::WriteAllText($outPath, $full + "`n", [System.Text.Encoding]::UTF8)
Copy-Item -LiteralPath $outPath -Destination (Join-Path $inbox $filename) -Force
Write-Output "sent: $outPath -> $inbox\$filename"
