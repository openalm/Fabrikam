param (
    [string]$applicationPath
)

Copy-Item $applicationPath\FabrikamFiber.CallCenter\DSCModule\* $env:systemdrive\Windows\System32\WindowsPowerShell\v1.0\Modules -Force -Recurse