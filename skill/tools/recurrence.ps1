param([string]$ProjectRoot = '.')
$ErrorActionPreference = 'Continue'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path

$di = [string][char]0x7B2C
$ci = [string][char]0x6B21
$gate = -join ([char[]]@(0x4F1A, 0x7EA2))

$found = @()
foreach ($name in @('PHILOSOPHY.md','CLAUDE.md','events.log')) {
  $p = Join-Path $root $name
  if (-not (Test-Path -LiteralPath $p)) { continue }
  $lines = [System.IO.File]::ReadAllLines($p, [System.Text.Encoding]::UTF8)
  $entryStart = 0
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^#{1,3}\s') { $entryStart = $i }
    $m = [regex]::Match($lines[$i], ($di + '\s*(\d+)\s*' + $ci))
    if ($m.Success -and ([int]$m.Groups[1].Value -ge 3)) {
      $scope = ($lines[$entryStart..$i] -join "`n")
      if ($scope.IndexOf($gate) -lt 0) {
        $found += ("{0}:{1}  {2}" -f $name, ($i + 1), $lines[$i].Trim())
      }
    }
  }
}

if ($found.Count -gt 0) {
  Write-Output 'FAIL: discipline re-stated >=3 times but still not a gate:'
  $found | ForEach-Object { Write-Output "  $_" }
  exit 1
} else {
  Write-Output 'PASS: no >=3x-recurring discipline left un-gated'
}
