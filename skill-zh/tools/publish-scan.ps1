param(
    [string]$Root = '.',
    [string]$TermsFile = ''
)
# Privacy scan for a release build: no file in the tree may contain a forbidden term.
#
# The term list lives in a local file (default `<repo>/.publish-terms.txt`) and is itself never
# published - it names the things that must not be. This exists because a scan whose word list is
# recalled on the spot will miss a dimension (that is exactly how a release leaked off-project
# context once): the list is data, it persists, and the same list is used every time.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $Root).Path
if (-not $TermsFile) { $TermsFile = Join-Path $root '.publish-terms.txt' }
if (-not (Test-Path -LiteralPath $TermsFile)) {
    Write-Output 'SKIP: no terms file (nothing to scan for)'
    exit 0
}

$terms = @()
$allow = @()
foreach ($line in [System.IO.File]::ReadAllLines($TermsFile, [System.Text.Encoding]::UTF8)) {
    $t = $line.Trim()
    if (-not $t -or $t.StartsWith('#')) { continue }
    if ($t.StartsWith('allow:')) { $allow += $t.Substring(6).Trim(); continue }
    $terms += $t
}
if ($terms.Count -eq 0) { Write-Output 'SKIP: terms file lists no terms'; exit 0 }

$hits = @()
foreach ($f in (Get-ChildItem -LiteralPath $root -Recurse -File)) {
    $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
    if ($rel -match '(^|/)\.git/') { continue }
    if ($f.Name -eq '.publish-terms.txt') { continue }   # the list itself names the terms
    $exempt = $false
    foreach ($glob in $allow) {
        if ($rel -like $glob) { $exempt = $true; break }
    }
    if ($exempt) { continue }
    # Read defensively: a binary or a mis-encoded file must not crash the scan.
    $text = ''
    try { $text = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8) } catch { continue }
    $lines = $text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($term in $terms) {
            if ($lines[$i].IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hits += ("{0}:{1}: forbidden term '{2}'" -f $rel, ($i + 1), $term)
            }
        }
    }
}

if ($hits.Count -gt 0) {
    Write-Output ('FAIL: the tree contains ' + $hits.Count + ' forbidden-term occurrence(s):')
    $hits | Select-Object -First 40 | ForEach-Object { Write-Output ('  ' + $_) }
    if ($hits.Count -gt 40) { Write-Output ('  ... and ' + ($hits.Count - 40) + ' more') }
    exit 1
}
Write-Output ('PASS: no forbidden terms in ' + $root + ' (' + $terms.Count + ' terms checked)')
