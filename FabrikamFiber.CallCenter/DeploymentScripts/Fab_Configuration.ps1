﻿param
(
    [string]$applicationPath
)

$ConfigData = 
@{
    AllNodes = @(
		@{ NodeName = "*"},

        @{	NodeName = "localhost";
            WebsiteName = "FFWeb"
            WebsiteBitsSourcePath = $applicationPath + "\FabrikamFiber.CallCenter\FabrikamFiber.Web"
			DeploymentPath = $env:SystemDrive + "\inetpub\FFWeb"
            FFExpressConnection = "data source=.;Integrated Security=True;Initial Catalog=FabrikamFiber-Express;User Id='" + "fareast\lmtstlab" + "'"
            ConnectionStringProvider = "System.Data.SqlClient"
            WebAppPoolName = "FabrikamPool"
            WebsitePort = "81"
            UserName = "fareast\lmtstlab"
            Password = "ipl@2015"
        }
    )
}

Configuration FabFiber
{
	Import-DscResource -Module xWebAdministration

	Node $AllNodes.NodeName
	{

        xWebSite DefaultWebsite
        {
            Name                 =  "Default Web Site"            
            PhysicalPath         =  "C:\inetpub\wwwroot"
            State                =  "Stopped"            
        }

 	    File CopyDeploymentBits
		{
			Ensure = "Present"
			Type = "Directory"
			Recurse = $true
			SourcePath = $Node.WebsiteBitsSourcePath
			DestinationPath = $Node.DeploymentPath
		}


            WindowsFeature WebScriptingTools
              {
                     Ensure = "Present"
                     Name = "Web-Scripting-Tools"
                     DependsOn = "[File]CopyDeploymentBits"
              }

              WindowsFeature WebDAVPublishing
             {
                    Ensure = "Present"
                    Name = "Web-DAV-Publishing"
                    DependsOn = "[WindowsFeature]WebScriptingTools"
             }

              WindowsFeature NETFramework45ASPNET
              {
                     Ensure = "Present"
                     Name = "NET-Framework-45-ASPNET"
                     DependsOn = "[WindowsFeature]WebDAVPublishing"
              }

              WindowsFeature AspNet45
              {
                     Ensure = "Present"
                     Name = "Web-Asp-Net45"
                     DependsOn = "[WindowsFeature]NETFramework45ASPNET"
              } 


		WindowsFeature IIS
		{
			Ensure = "Present"
			Name = "Web-Server"
			DependsOn = "[WindowsFeature]AspNet45"
		}	

		xWebAppPool NewWebAppPool 
        { 
            Name   = $Node.WebAppPoolName 
            Ensure = "Present" 
            State  = "Started" 
        } 	

		xWebsite FabrikamWebSite
		{
			Ensure = "Present"
			Name = $Node.WebsiteName
			State = "Started"
			PhysicalPath = $Node.DeploymentPath
			ApplicationPool = $Node.WebAppPoolName
			BindingInfo = MSFT_xWebBindingInformation 
                {                   
                 Port = $Node.WebsitePort
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

        Script UpdateNewWebAppPoolIdentity
        {
            SetScript =
            {            
                $poolName = [String]('IIS:\AppPools\'+$using:Node.WebAppPoolName)
                $pool = get-item($poolName);

                $pool.processModel.userName = [String]($using:Node.UserName)
                $pool.processModel.password = [String]($using:Node.Password)
                $pool.processModel.identityType = [String]("SpecificUser");

                $pool | Set-Item 
            }        

            GetScript = { return @{} }

            TestScript = { return $false }   
            
            DependsOn = "[xWebConnectionString]FabrikamFiberDWConnectionString"    
        }         
	}
}

FabFiber -ConfigurationData $ConfigData