Configuration FabFiber
{
	Import-DscResource -Module xWebAdministration

	Node $AllNodes.NodeName
	{
		File CopyDeploymentBits
		{
			Ensure = "Present"
			Type = "Directory"
			Recurse = $true
			SourcePath = $applicationPath
			DestinationPath = $Node.DeploymentPath
		}

		WindowsFeature AspNet45
		{
			Ensure = "Present"
			Name = "Web-Asp-Net45"
		}

		WindowsFeature IIS
		{
			Ensure = "Present"
			Name = "Web-Server"
			DependsOn = "[WindowsFeature]AspNet45"
		}	

		xWebAppPool NewWebAppPool 
        { 
            Name   = $WebAppPoolName 
            Ensure = "Present" 
            State  = "Started" 
        } 	

		xWebsite FabrikamWebSite
		{
			Ensure = "Present"
			Name = $Node.WebsiteName
			State = "Started"
			PhysicalPath = $Node.DeploymentPath
			ApplicationPool = $WebAppPoolName
			BindingInfo = MSFT_xWebBindingInformation 
                { 
                 Port = $WebsitePort
                } 
			DependsOn = "[WindowsFeature]IIS"
		}

        xWebConnectionString FabrikamFiberConnectionString
        {
            Ensure = "Present"
            Name = "FabrikamFiber-Express"
            ConnectionString = $Node.FFExpressConnection
            ProviderName = $Node.ConnectionStringProvider
            WebSite = $Node.WebsiteName
            DependsOn = "[xWebsite]FabrikamWebSite"
        }

        xWebConnectionString FabrikamFiberDWConnectionString
        {
            Ensure = "Present"
            Name = "FabrikamFiber-DataWarehouse"
            ConnectionString = $Node.FFExpressConnection
            ProviderName = $Node.ConnectionStringProvider
            WebSite = $Node.WebsiteName
            DependsOn = "[xWebsite]FabrikamWebSite"
        }
	}
}

FabFiber -ConfigurationData $ConfigData -Verbose
