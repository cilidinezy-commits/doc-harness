param(
    [string]$Ledger = '.\MAIL_LEDGER.md',
    [string]$From = '',
    [string]$Date = (Get-Date -Format 'yyyy-MM-dd HH:mm'),
    [string]$Subject = '',
    [string]$Status = ''
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Ledger)) {
    Set-Content -LiteralPath $Ledger -Value '# MAIL LEDGER' -Encoding UTF8
    Add-Content -LiteralPath $Ledger -Value '' -Encoding UTF8
    Add-Content -LiteralPath $Ledger -Value '| From | Date | Subject | Status |' -Encoding UTF8
    Add-Content -LiteralPath $Ledger -Value '|------|------|---------|--------|' -Encoding UTF8
}
Add-Content -LiteralPath $Ledger -Value "| $From | $Date | $Subject | $Status |" -Encoding UTF8
Write-Output 'ledger appended'
