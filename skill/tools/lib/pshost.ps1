# Running the toolbelt's child processes portably.
#
# Tools must not assume `powershell.exe`: that name exists only on Windows, while the same tools
# are expected to run under `pwsh` on Linux and macOS (and in CI). The portable rule is to re-run
# the *same host* that is executing this script, and to pass Windows-only switches only on Windows.
function Get-PsHostPath {
    $p = $null
    try { $p = (Get-Process -Id $PID).Path } catch { }
    if (-not $p) { $p = (Get-Command powershell, pwsh -ErrorAction SilentlyContinue | Select-Object -First 1).Source }
    if (-not $p) { $p = 'powershell' }
    return $p
}

function Invoke-PsScript {
    param([string]$Script, [string[]]$ScriptArgs = @())
    $exe = Get-PsHostPath
    $a = @('-NoProfile','-File',$Script)
    if ($PSVersionTable.PSEdition -eq 'Desktop') { $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$Script) }
    $a += $ScriptArgs
    & $exe @a | Out-Null
    return $LASTEXITCODE
}
