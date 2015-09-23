. $applicationPath\DPT-DscPreReqs.ps1

# Install custom modules
Install-Module xPSDesiredStateConfiguration1
Install-Module xFirefox
Install-Module xChrome

# Main Configuration Data
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            Ensure="Present"
            PSDscAllowPlainTextPassword = $true
         }
    )
}