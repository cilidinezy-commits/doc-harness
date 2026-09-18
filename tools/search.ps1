param(
    [string]$ProjectRoot = '.',
    [Parameter(Mandatory=$true)][string]$Query,
    [ValidateSet('all','now','history','files','anchor')][string]$Layer = 'all',
    [int]$MaxHits = 50
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path

$files = New-Object System.Collections.Generic.List[string]
foreach ($rel in @('CLAUDE.md','events.log','CURRENT_STATUS.md','FILE_INDEX.md','PHILOSOPHY.md')) {
    $p = Join-Path $root $rel
    if (Test-Path -LiteralPath $p) { $files.Add($p) }
}
if ($Layer -eq 'now') {
    $files = @((Join-Path $root 'CURRENT_STATUS.md'))
} elseif ($Layer -eq 'history') {
    # History = the event log plus whatever has been archived out of it. No hard-coded
    # archive filenames: a project names its own, and if none exists the layer is just the log.
    $hist = New-Object System.Collections.Generic.List[string]
    $evp = Join-Path $root 'events.log'
    if (Test-Path -LiteralPath $evp) { $hist.Add($evp) }
    foreach ($a in (Get-ChildItem -LiteralPath (Join-Path $root '_archive') -Recurse -File -ErrorAction SilentlyContinue)) { $hist.Add($a.FullName) }
    $files = @($hist)
} elseif ($Layer -eq 'files') {
    $files = @((Join-Path $root 'FILE_INDEX.md'))
} elseif ($Layer -eq 'anchor') {
    $files = @((Join-Path $root 'CLAUDE.md'))
} elseif ($Layer -eq 'all') {
    $more = Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {
        $_.Extension -eq '.md' -and ($_.FullName.Substring($root.Length + 1).Replace('\','/') -notmatch '(^|/)(\.git|\.venv|node_modules|inbox|outbox|__pycache__|\.claude|_archive|_runtime|_validation|_[^/]*)(/|$)')
    } | ForEach-Object { $_.FullName }
    foreach ($m in $more) { if (-not $files.Contains($m)) { $files.Add($m) } }
}

$hits = 0
foreach ($f in $files) {
    if (-not (Test-Path -LiteralPath $f)) { continue }
    if ($hits -ge $MaxHits) { break }
    $m = Select-String -LiteralPath $f -Pattern $Query -Encoding UTF8
    foreach ($x in $m) {
        if ($hits -ge $MaxHits) { break }
        $rel = if ($f.StartsWith($root)) { $f.Substring($root.Length + 1).Replace('\','/') } else { $f }
        Write-Output ("{0}:{1}: {2}" -f $rel, $x.LineNumber, $x.Line.Trim())
        $hits++
    }
}
if ($hits -eq 0) { Write-Output 'NO MATCHES' }
