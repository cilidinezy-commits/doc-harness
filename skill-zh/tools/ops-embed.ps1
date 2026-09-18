param(
    [string]$ProjectRoot = '.',
    [string]$OpsSource = '',
    [switch]$Check
)
# Re-embed (or verify) the operational-rules block inside a project's CLAUDE.md.
#
# The block is the region between <!-- doc-harness-ops-start --> and <!-- doc-harness-ops-end -->
# (inclusive), taken verbatim from the ops source file. Everything outside the sentinels is
# preserved byte-for-byte. This is what makes "re-embed" a mechanical operation instead of a
# careful manual edit, and -Check makes the copy falsifiable: a hand-edited or half-updated block
# is a red, not a silent divergence.
#
# Note: the file is written back with LF endings (the doc-harness convention) and UTF-8 without BOM.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $OpsSource) {
    foreach ($cand in @(
        (Join-Path $root 'skill/operational_rules.md'),
        (Join-Path $toolsDir '../operational_rules.md'),      # running from an installed skill copy
        (Join-Path $root '.claude/skills/doc-harness-v2/operational_rules.md'),
        (Join-Path $root '.claude/skills/doc-harness/operational_rules.md')
    )) {
        if (Test-Path -LiteralPath $cand) { $OpsSource = $cand; break }
    }
}
if (-not $OpsSource -or -not (Test-Path -LiteralPath $OpsSource)) {
    Write-Output 'SKIP: no ops source found (pass -OpsSource <path/to/operational_rules.md>)'
    exit 0
}

$startTag = '<!-- doc-harness-ops-start -->'
$endTag = '<!-- doc-harness-ops-end -->'

function Get-OpsBlock([string]$path) {
    $txt = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $txt = $txt.Replace("`r`n", "`n")
    $si = $txt.IndexOf($startTag)
    $ei = $txt.IndexOf($endTag)
    if ($si -lt 0 -or $ei -lt 0 -or $ei -lt $si) { return $null }
    if ($txt.IndexOf($startTag, $si + 1) -ge 0) { return $null }
    if ($txt.IndexOf($endTag, $ei + 1) -ge 0) { return $null }
    return $txt.Substring($si, ($ei + $endTag.Length) - $si)
}

$srcBlock = Get-OpsBlock $OpsSource
if (-not $srcBlock) { Write-Output ('FAIL: ops source has no single well-formed sentinel pair: ' + $OpsSource); exit 1 }

$claudePath = Join-Path $root 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $claudePath)) { Write-Output 'FAIL: CLAUDE.md not found'; exit 1 }
$claude = [System.IO.File]::ReadAllText($claudePath, [System.Text.Encoding]::UTF8)
$claudeNorm = $claude.Replace("`r`n", "`n")
$dstBlock = Get-OpsBlock $claudePath
if (-not $dstBlock) { Write-Output 'FAIL: CLAUDE.md has no single well-formed sentinel pair'; exit 1 }

$opsVer = ([regex]::Match($srcBlock, 'doc-harness-ops-version:\s*([0-9.]+)')).Groups[1].Value

if ($Check) {
    if ($srcBlock -eq $dstBlock) { Write-Output ('PASS: embedded ops block matches source (ops-version ' + $opsVer + ')'); exit 0 }
    Write-Output ('FAIL: embedded ops block differs from ' + $OpsSource + ' (run without -Check to re-embed)')
    exit 1
}

$new = $claudeNorm.Replace($dstBlock, $srcBlock)
if ($new -eq $claudeNorm) { Write-Output 'FAIL: replacement produced no change'; exit 1 }
[System.IO.File]::WriteAllText($claudePath, $new, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ('re-embedded ops block from ' + $OpsSource + ' (ops-version ' + $opsVer + ')')
