param(
    [string]$ProjectRoot = '.',
    [string[]]$Files = @(),
    [string]$Category = 'Uncategorized',
    [string]$Manifest = ''
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$idx = Join-Path $root 'FILE_INDEX.md'
if (-not (Test-Path -LiteralPath $idx)) { Write-Output 'FAIL: FILE_INDEX.md not found'; exit 1 }

# Via `powershell -File`, an array argument arrives as ONE comma-joined string, so a list of paths
# silently becomes a single nonsense entry. Expand on commas - and then require every path to
# exist before writing anything: if a real filename contained a comma, the expansion would produce
# non-existent paths and fail loudly instead of registering a wrong entry.
$expanded = New-Object System.Collections.Generic.List[string]
foreach ($f in $Files) { foreach ($one in ($f -split ',')) { if ($one.Trim()) { $expanded.Add($one.Trim()) } } }
$Files = @($expanded)
if ($Files.Count -eq 0) { Write-Output 'FAIL: no files given'; exit 1 }

$missing = @($Files | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) })
if ($missing.Count -gt 0) { Write-Output ('FAIL: these paths do not exist under ' + $root + ': ' + ($missing -join ', ')); exit 1 }

$lines = [System.IO.File]::ReadAllLines($idx, [System.Text.Encoding]::UTF8)
$catHead = "## $Category"
$dash = [string][char]0x2014
$out = New-Object System.Collections.Generic.List[string]
$inserted = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
    $out.Add($lines[$i])
    if (-not $inserted -and $lines[$i] -eq $catHead) {
        foreach ($f in $Files) {
            $rel = $f.Trim()
            $full = Join-Path $root $rel
            if (Test-Path -LiteralPath $full) { $rel = $full.Substring($root.Length + 1).Replace('\', '/') }
            $out.Add(('- `' + $rel + '` ' + $dash + ' '))
        }
        $inserted = $true
    }
}
if (-not $inserted) {
    $out.Add('')
    $out.Add($catHead)
    foreach ($f in $Files) {
        $rel = $f.Trim()
        $full = Join-Path $root $rel
        if (Test-Path -LiteralPath $full) { $rel = $full.Substring($root.Length + 1).Replace('\', '/') }
        $out.Add(('- `' + $rel + '` ' + $dash + ' '))
    }
}
[System.IO.File]::WriteAllLines($idx, $out, [System.Text.Encoding]::UTF8)
if ($Manifest) {
    $lines2 = $Files | ForEach-Object {
        $p = Join-Path $root $_
        if (Test-Path -LiteralPath $p) { $h = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash; "$h  $_" }
    }
    [System.IO.File]::WriteAllLines($Manifest, $lines2, [System.Text.Encoding]::UTF8)
}
Write-Output ("registered " + $Files.Count + " file(s) under '" + $Category + "': " + ($Files -join ', '))
