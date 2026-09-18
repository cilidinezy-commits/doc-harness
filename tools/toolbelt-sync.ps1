param([string]$ProjectRoot = '.')
# The toolbelt ships three times: at the repository root (where this project runs its own gate) and
# inside each language's skill folder (so that *installing the skill* also delivers the mechanism
# that generates the projection). Three copies must stay byte-identical - a hand-maintained
# duplicate is exactly the kind of drift this project exists to eliminate.
#
# Skips silently when there is no skill/tools + skill-zh/tools pair (i.e. inside an installed skill),
# so it is inert everywhere except the repository that owns the copies.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$canonical = Join-Path $root 'tools'
$mirrors = @(
    (Join-Path $root 'skill/tools'),
    (Join-Path $root 'skill-zh/tools')
)
if (@($mirrors | Where-Object { -not (Test-Path -LiteralPath $_) }).Count -gt 0) {
    Write-Output 'SKIP: no skill/tools + skill-zh/tools pair here'
    exit 0
}

function Get-RelativeFileMap([string]$dir) {
    $map = @{}
    foreach ($f in (Get-ChildItem -LiteralPath $dir -Recurse -File)) {
        $rel = $f.FullName.Substring($dir.Length + 1).Replace('\','/')
        $map[$rel] = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
    }
    return $map
}

$fail = @()
$base = Get-RelativeFileMap $canonical
foreach ($mirror in $mirrors) {
    $name = $mirror.Substring($root.Length + 1).Replace('\','/')
    $m = Get-RelativeFileMap $mirror
    foreach ($rel in $base.Keys) {
        if (-not $m.ContainsKey($rel)) { $fail += ("missing in {0}: {1}" -f $name, $rel); continue }
        if ($m[$rel] -ne $base[$rel]) { $fail += ("differs from tools/{0}: {1}" -f $rel, $name) }
    }
    foreach ($rel in $m.Keys) {
        if (-not $base.ContainsKey($rel)) { $fail += ("present in {0} but not in tools/: {1}" -f $name, $rel) }
    }
}

if ($fail.Count -gt 0) {
    Write-Output ('FAIL: the toolbelt copies have drifted apart (' + $fail.Count + ' item(s)):')
    $fail | ForEach-Object { Write-Output ('  ' + $_) }
    exit 1
}
Write-Output ('PASS: toolbelt copies identical (' + $base.Count + ' files x 3 locations)')
