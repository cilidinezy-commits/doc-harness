param(
    [string]$ProjectRoot = '.',
    [string]$EventsFile = 'events.log',
    [switch]$Write
)
$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $toolsDir 'lib/doc-state.ps1')
$s = Get-DocState -ProjectRoot $ProjectRoot -EventsFile $EventsFile
if (-not $s.Ok) { Write-Output ('FAIL: ' + $s.Error); exit 1 }
if ($s.Errors.Count -gt 0) { Write-Output ('FAIL: ' + ($s.Errors -join ' | ')); exit 1 }
$text = Render-CurrentStatus -State $s
if ($Write) {
    $path = Join-Path $s.Root 'CURRENT_STATUS.md'
    [System.IO.File]::WriteAllText($path, $text + "`n", [System.Text.Encoding]::UTF8)
    Write-Output "wrote $path"
} else {
    Write-Output $text
}
