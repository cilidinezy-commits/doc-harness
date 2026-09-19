param([string]$ProjectRoot = '.')
# Consistency of the skill documents themselves. Two claims that used to rest on human review:
#
#   1. LANGUAGE PARITY - `skill/` (English, authoritative) and `skill-zh/` (Chinese) must describe
#      the same document. Translating changes words, not structure: same files, same heading levels
#      in the same order, same number of code fences and table rows.
#   2. NO RETIRED MODEL - the skill docs must not teach the v1 model. Terms from the retired model
#      are allowed only where they are clearly about migrating from or archiving v1.
#   3. SAME NORMATIVE IDENTIFIERS - the facts that must not be translated: every file path with an
#      extension and every event verb named in one language must be named in the other. (Phrases
#      with translated placeholders, e.g. a command example, are deliberately out of scope.)
#   4. NATIVE ENGLISH - the English documents must be written for English readers, not translated
#      sentence by sentence: no CJK may appear in them. This scan is the mechanically checkable half
#      of that rule; the other half (examples must be native, not the other edition's examples
#      carried over) stays a review judgement. Lines that name the Chinese edition are allowed.
#      (Criterion learned from a sibling project's field report, 2026-09-19.)
#
# Skips silently when there is no skill/ + skill-zh/ pair (i.e. in a normal project), so it can sit
# inside conformance without burdening projects that merely use the skill.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$en = Join-Path $root 'skill'
$zh = Join-Path $root 'skill-zh'
if (-not (Test-Path -LiteralPath $en) -or -not (Test-Path -LiteralPath $zh)) {
    Write-Output 'SKIP: no skill/ + skill-zh/ pair here'
    exit 0
}

# Non-ASCII literals are built from code points: tool scripts must stay ASCII-only, because
# PowerShell 5.1 reads a BOM-less .ps1 as ANSI and would mangle them (encoding-guard enforces this).
function CodePointString([int[]]$points) { return (-join ($points | ForEach-Object { [char]$_ })) }

$fail = @()

# Identifiers a translation must not change: a path with a file extension, or an event verb
# (`unit:open`). Anchored shapes only, so command examples and translated placeholders are ignored.
function Get-Identifiers([string]$path) {
    $txt = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $found = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($txt, '`([^`\r\n]+)`')) {
        $t = $m.Groups[1].Value.Trim()
        $isPath = $t -match '^[A-Za-z0-9_./-]+\.(md|log|ps1|json|yaml|yml)$'
        $isVerb = $t -match '^[a-z-]+:[a-z-]+$'
        if (($isPath -or $isVerb) -and -not $found.Contains($t)) { $found.Add($t) }
    }
    return @($found | Sort-Object)
}

# ---------------------------------------------------------------- 1. language parity
function Get-Skeleton([string]$path) {
    $levels = New-Object System.Collections.Generic.List[int]
    $fence = 0
    $tableRows = 0
    $inFence = $false
    foreach ($line in [System.IO.File]::ReadAllLines($path, [System.Text.Encoding]::UTF8)) {
        $t = $line.Trim()
        if ($t.StartsWith('```')) { $fence++; $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        if ($t -match '^(#{1,6})\s') { $levels.Add($Matches[1].Length) }
        elseif ($t -match '^\|') { if ($t -notmatch '^\|[\s\-:|]+\|$') { $tableRows++ } }
    }
    return [pscustomobject]@{ Levels = @($levels); Fences = $fence; TableRows = $tableRows }
}

$enNames = @(Get-ChildItem -LiteralPath $en -File | Select-Object -ExpandProperty Name | Sort-Object)
$zhNames = @(Get-ChildItem -LiteralPath $zh -File | Select-Object -ExpandProperty Name | Sort-Object)
foreach ($n in $enNames) { if ($zhNames -notcontains $n) { $fail += "missing in skill-zh/: $n" } }
foreach ($n in $zhNames) { if ($enNames -notcontains $n) { $fail += "missing in skill/: $n" } }

foreach ($n in ($enNames | Where-Object { $zhNames -contains $_ })) {
    $a = Get-Skeleton (Join-Path $en $n)
    $b = Get-Skeleton (Join-Path $zh $n)
    if (($a.Levels -join ',') -ne ($b.Levels -join ',')) {
        $fail += ("heading structure differs: {0} (en: {1} | zh: {2})" -f $n, ($a.Levels -join ','), ($b.Levels -join ','))
    }
    if ($a.Fences -ne $b.Fences) { $fail += ("code fences differ: {0} (en {1} vs zh {2})" -f $n, $a.Fences, $b.Fences) }
    if ($a.TableRows -ne $b.TableRows) { $fail += ("table rows differ: {0} (en {1} vs zh {2})" -f $n, $a.TableRows, $b.TableRows) }

    $ids = @{ en = Get-Identifiers (Join-Path $en $n); zh = Get-Identifiers (Join-Path $zh $n) }
    foreach ($only in @($ids.en | Where-Object { $ids.zh -notcontains $_ })) {
        $fail += ("identifier in skill/{0} but not skill-zh/{0}: {1}" -f $n, $only)
    }
    foreach ($only in @($ids.zh | Where-Object { $ids.en -notcontains $_ })) {
        $fail += ("identifier in skill-zh/{0} but not skill/{0}: {1}" -f $n, $only)
    }
}

# ---------------------------------------------------------------- 2. retired model vocabulary
$retired = @(
    'WORKLOG',                                          # the v1 prose worklog artifact
    'car body',
    'headlight',
    'tire track',
    'driving manual',
    'five documents',
    'Phase Transition',
    (CodePointString @(0x8F66, 0x8EAB)),                             # car body
    (CodePointString @(0x8F66, 0x706F)),                             # headlights
    (CodePointString @(0x8F66, 0x8F99)),                             # tire tracks
    (CodePointString @(0x9A7E, 0x9A76, 0x624B, 0x518C)),             # driving manual
    (CodePointString @(0x4E94, 0x4E2A, 0x6587, 0x6863)),             # "five documents"
    (CodePointString @(0x9636, 0x6BB5, 0x5207, 0x6362))              # "phase transition"
)
$allowedMarkers = @(
    'v1', 'archive', 'historical', 'legacy', 'superseded', 'migrat', 'deprecat',
    (CodePointString @(0x5386, 0x53F2)),                             # history
    (CodePointString @(0x8FC1, 0x79FB)),                             # migrate
    (CodePointString @(0x5F52, 0x6863)),                             # archive
    (CodePointString @(0x5E9F, 0x5F03)),                             # deprecated
    (CodePointString @(0x5DF2, 0x79FB, 0x9664))                      # "removed"
)

foreach ($dir in @($en, $zh)) {
    foreach ($file in (Get-ChildItem -LiteralPath $dir -File)) {
        $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)
        for ($i = 0; $i -lt $lines.Count; $i++) {
            foreach ($term in $retired) {
                if ($lines[$i].IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) { continue }
                $ok = $false
                foreach ($m in $allowedMarkers) {
                    if ($lines[$i].IndexOf($m, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { $ok = $true; break }
                }
                if (-not $ok) { $fail += ("retired v1 vocabulary without a migration/history marker: {0}:{1}  {2}" -f $file.Name, ($i + 1), $lines[$i].Trim()) }
            }
        }
    }
}

# ---------------------------------------------------------------- 4. English documents stay English
$englishDocs = @(Get-ChildItem -LiteralPath $en -File | ForEach-Object { $_.FullName })
$readme = Join-Path $root 'README.md'
if (Test-Path -LiteralPath $readme) { $englishDocs += $readme }
$cjk = '[\u4e00-\u9fff]'
$namesChineseEdition = 'README_zh|doc-harness-zh|skill-zh'
foreach ($file in $englishDocs) {
    $lines = [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -notmatch $cjk) { continue }
        if ($lines[$i] -match $namesChineseEdition) { continue }
        $fail += ("CJK in an English document: {0}:{1}  {2}" -f (Split-Path $file -Leaf), ($i + 1), $lines[$i].Trim())
    }
}

# ---------------------------------------------------------------- report
if ($fail.Count -gt 0) {
    Write-Output ('FAIL: skill docs are inconsistent (' + $fail.Count + ' item(s)):')
    $fail | ForEach-Object { Write-Output ('  ' + $_) }
    exit 1
}
Write-Output ('PASS: skill docs consistent - ' + $enNames.Count + ' file pairs; skeletons, normative identifiers and vocabulary agree; English docs are CJK-free')
