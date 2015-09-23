Configuration FabrikamWebsite 
{ 
	Import-DSCResource -ModuleName xWebAdministration

	Node $AllNodes.NodeName
	{
		#Install the IIS Role 
		WindowsFeature IIS 
		{ 
		  Ensure = “Present” 
		  Name = “Web-Server” 
		} 

		# Install the ASP .NET 4.5 role 
		WindowsFeature AspNet45 
		{ 
			Ensure = "Present" 
			Name = "Web-Asp-Net45" 
		} 

		# Copy website bits to configured deployment path
		File CopyDeploymentBits
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = $applicationPath
            DestinationPath = $Node.DeploymentPath
        }
		
		# Stop the default website 
		xWebsite DefaultSite  
		{ 
			Ensure          = "Present" 
			Name            = "Default Web Site" 
			State           = "Stopped" 
			PhysicalPath    = "C:\inetpub\wwwroot" 
			DependsOn       = "[WindowsFeature]IIS" 
		}

		# Create and start Fabrikam website
		xWebsite FabrikamFiberWebSite  
		{ 
			Ensure          = "Present" 
			Name            = "FabrikamFiber" 
			State           = "Started" 
			PhysicalPath    = $Node.DeploymentPath
			DependsOn       = "[File]CopyDeploymentBits" 
		}
	}
}

FabrikamWebsite -ConfigurationData $ConfigData -Verbose