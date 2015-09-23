configuration InstallModules
{
    param
    (
        # Target nodes to apply the configuration
        [string[]]$NodeName = 'localhost',

        # Source Path for Modules
        [String]$SourcePath = "$applicationPath\Deploy\Modules",

        # Destination path for Modules
        [String]$DestinationPath = "$env:ProgramFiles\WindowsPowershell\Modules"
    )

    Node $NodeName
    {
        # Copy the Modules
        File ModuleContent
        {
            Ensure          = "Present"
            SourcePath      = $SourcePath
            DestinationPath = $DestinationPath
            Recurse         = $true
            Type            = "Directory"
        }       
    }
}

InstallModules