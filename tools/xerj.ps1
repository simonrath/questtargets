param(
    [ValidateSet('Start','Index','Search','References')][string]$Action = 'Start',
    [string]$Query
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskExe = Join-Path $env:LOCALAPPDATA 'Programs/xerj/xerj.exe'
$taskData = Join-Path $env:LOCALAPPDATA 'xerj-questtargets'
$env:XERJ_URL = 'http://127.0.0.1:9320'
$env:XERJ_DISABLE_FEEDBACK = 'true'
if (-not (Test-Path -LiteralPath $taskExe)) { throw 'Install XERJ first: https://xerj.org/llms.txt' }
try { Invoke-RestMethod "$env:XERJ_URL/" -TimeoutSec 2 | Out-Null }
catch {
    New-Item -ItemType Directory -Path $taskData -Force | Out-Null
    Start-Process -FilePath $taskExe -WindowStyle Hidden -ArgumentList @(
        '--insecure','--bind','127.0.0.1','--port','9320','--data-dir',"$taskData/data",'--disable-feedback'
    ) -RedirectStandardOutput "$taskData/server.log" -RedirectStandardError "$taskData/server.err.log"
    $taskReady = $false
    for ($taskAttempt=0; $taskAttempt -lt 20; $taskAttempt++) {
        try { Invoke-RestMethod "$env:XERJ_URL/" -TimeoutSec 1 | Out-Null; $taskReady=$true; break }
        catch { Start-Sleep -Milliseconds 250 }
    }
    if (-not $taskReady) { throw "XERJ did not start; see $taskData/server.err.log" }
}
switch ($Action) {
    'Start' { Write-Output $env:XERJ_URL }
    'Index' {
        & $taskExe autoindex $taskRoot --prefix qtproject --no-graph --workers 2
        if ($LASTEXITCODE -notin @(0,3)) { throw 'Project indexing failed; inspect XERJ output' }
        & $taskExe corpus index qtrefs
        if ($LASTEXITCODE -notin @(0,3)) { throw 'Reference indexing failed; inspect XERJ output' }
    }
    'Search' { & $taskExe search --prefix qtproject $Query }
    'References' { & $taskExe code qtrefs $Query -k 3 }
}
