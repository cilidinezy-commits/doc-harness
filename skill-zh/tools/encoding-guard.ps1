param([string]$ProjectRoot = '.')
$ErrorActionPreference = 'SilentlyContinue'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$strict = New-Object System.Text.UTF8Encoding($false, $true)
$bad = @()

# 1. State documents must be strict UTF-8 (mojibake in a status file is silent corruption).
foreach ($name in @('CLAUDE.md','CURRENT_STATUS.md','FILE_INDEX.md','events.log','PHILOSOPHY.md','AGENTS.md')) {
  $p = Join-Path $root $name
  if (-not (Test-Path -LiteralPath $p)) { continue }
  $bytes = [System.IO.File]::ReadAllBytes($p)
  try { $null = $strict.GetString($bytes) } catch { $bad += $name }
}

# 2. Tool scripts must be pure ASCII: PowerShell 5.1 reads BOM-less .ps1 as ANSI, so a literal
#    non-ASCII character in a script becomes mojibake at parse time. Build such characters from
#    their code points instead (see doc-state.ps1).
$asciiBad = @()
foreach ($f in (Get-ChildItem -LiteralPath $toolsDir -Recurse -Filter *.ps1 -File)) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  foreach ($b in $bytes) { if ($b -gt 127) { $asciiBad += $f.Name; break } }
}

if ($bad.Count -gt 0 -or $asciiBad.Count -gt 0) {
  $msg = @()
  if ($bad.Count -gt 0) { $msg += ('not valid UTF-8: ' + (($bad | Sort-Object -Unique) -join ', ')) }
  if ($asciiBad.Count -gt 0) { $msg += ('tool script not ASCII-only: ' + (($asciiBad | Sort-Object -Unique) -join ', ')) }
  Write-Output ('FAIL: ' + ($msg -join ' | '))
  exit 1
} else {
  Write-Output 'PASS: status documents are valid UTF-8; tool scripts are ASCII-only'
}
