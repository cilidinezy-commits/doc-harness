param(
    [string]$ProjectRoot = '.',
    [string]$Today = (Get-Date -Format 'yyyy-MM-dd')
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$skip = '(^|/)(\.git|\.venv|node_modules|inbox|outbox|__pycache__|\.claude|_archive|_runtime|_validation|_[^/]*)(/|$)'
$files = Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {
    $_.Extension -eq '.md' -and ($_.FullName.Substring($root.Length + 1).Replace('\','/') -notmatch $skip)
}
$overdue = @()
foreach ($f in $files) {
    $m = Select-String -LiteralPath $f.FullName -Pattern 'conclusion_until:\s*(\d{4}-\d{2}-\d{2})' -Encoding UTF8
    foreach ($x in $m) {
        $d = $x.Matches[0].Groups[1].Value
        if ($d -lt $Today) {
            $rel = $f.FullName.Substring($root.Length + 1).Replace('\','/')
            $overdue += ("{0}:{1}: {2}" -f $rel, $x.LineNumber, $x.Line.Trim())
        }
    }
}
if ($overdue.Count -gt 0) {
    Write-Output 'FAIL: overdue conclusions (past conclusion_until):'
    $overdue | ForEach-Object { Write-Output "  $_" }
    exit 1
} else {
    Write-Output 'PASS: no overdue conclusions'
}
