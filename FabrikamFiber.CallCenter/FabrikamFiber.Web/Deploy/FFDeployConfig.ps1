# copy DSC modules into system modules folder
$customModuleDirectory = Join-Path $env:SystemDrive "\Program Files\WindowsPowerShell\Modules"
$customModuleSrc = Join-Path $applicationPath "Deploy\xWebAdministration"
Copy-Item -Verbose -Force -Recurse -Path $customModuleSrc -Destination $customModuleDirectory 

if ((Get-NetFirewallRule -DisplayName "FabrikamFiber" -ErrorAction SilentlyContinue) -eq $null)
{
	New-NetFirewallRule -DisplayName FabrikamFiber -Action Allow -Direction Inbound -LocalPort 80 -Profile Any -Protocol TCP -RemotePort Any
}

$ConfigData = @{
    AllNodes = @(
		@{ NodeName = "*"},

        @{
			NodeName = $env:COMPUTERNAME
            DeploymentPath = $env:SystemDrive + "\inetpub\FF"
        }
    );
}