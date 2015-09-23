$ConfigData = @{
    AllNodes = @(
		@{ NodeName = "*"},

        @{	NodeName = "localhost";
            WebsiteName = "FFWeb"
			DeploymentPath = $env:SystemDrive + "\inetpub\FFWeb"
            FFExpressConnection = "data source=.;Integrated Security=True;Initial Catalog=FabrikamFiber-Express;User Id='" + $UserName +"'"
            ConnectionStringProvider = "System.Data.SqlClient"
        }
    )
}