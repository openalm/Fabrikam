function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[String]$WebSite,

		[parameter(Mandatory = $true)]
		[String]$Name,

		[parameter(Mandatory = $true)]
		[String]$ConnectionString
	)

    # Normalized path for IIS: drive
    $IISPath = "IIS:\Sites\$WebSite"
    Assert-Input -PSPath $IISPath

    # Filter for the given name
    $filter = "connectionStrings/add[@Name='$Name']"

    $connectionElement = Get-WebConfigurationProperty -PSPath $IISPath -Filter $filter -Name *
    
    [ordered]@{
        Ensure           = if($connectionElement){'Present'}else{'Absent'}
		WebSite          = $WebSite
		Name             = $connectionElement.Name
		ConnectionString = $connectionElement.ConnectionString
		ProviderName     = $connectionElement.ProviderName
	}
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[String]$WebSite,

		[parameter(Mandatory = $true)]
		[String]$Name,

		[parameter(Mandatory = $true)]
		[String]$ConnectionString,

		[String]$ProviderName = 'System.Data.SqlClient',

        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present'
	)

    # Normalized path for IIS: drive
    $IISPath = "IIS:\Sites\$WebSite"

    Assert-Input -PSPath $IISPath

    Assert-Property -PSPath $IISPath -Name $Name  -Apply `
                    -ConnectionString $ConnectionString -ProviderName $ProviderName
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[String]$WebSite,

		[parameter(Mandatory = $true)]
		[String]$Name,

		[parameter(Mandatory = $true)]
		[String]$ConnectionString,

		[String]$ProviderName = 'System.Data.SqlClient',

        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present'
	)

    # Normalized path for IIS: drive
    $IISPath = "IIS:\Sites\$WebSite"

    Assert-Input -PSPath $IISPath

    Assert-Property -PSPath $IISPath -Name $Name `
                    -ConnectionString $ConnectionString -ProviderName $ProviderName
}

#region Helper Function

# Internal function to throw terminating error with specified errroCategory, errorId and errorMessage
function New-TerminatingError
{
    param
    (
        [Parameter(Mandatory)]
        [String]$errorId,
        
        [Parameter(Mandatory)]
        [String]$errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]$errorCategory
    )
    
    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

function Assert-Input
{
	param
	(
		[parameter(Mandatory = $true)]
		[String]$PSPath
    )

    # Find Website name from the PSPath of IIS drive
    $WebSite = $($PSPath.Split('\')[-1])

    # Check if WebAdministration module is present for IIS cmdlets
    if(!(Get-Module -ListAvailable -Name WebAdministration))
    {
        $errorString = 'Please ensure that IIS (Web-Server) role is installed with its PowerShell module'
        New-TerminatingError -errorId 'MissingWebAdministrationModule' -errorMessage $errorString `
                             -errorCategory InvalidOperation
    }
    
    Import-Module WebAdministration -Verbose:$false

    # Check website exists under IIS drive
    if(!(dir $PSPath -ErrorAction SilentlyContinue))
    {
        $errorString = "There is no website $WebSite"
        New-TerminatingError -errorId 'MissingWebSite' -errorMessage $errorString `
                             -errorCategory InvalidOperation
    }

    # Check if the folder conatins web.config file
    if(! ((Get-WebConfigFile -PSPath $PSPath).Name -eq 'web.config') )
    {
        $errorString = "Website $WebSite is missing web.config file"
        New-TerminatingError -errorId 'MissingWebConfigFile' -errorMessage $errorString `
                             -errorCategory InvalidOperation
    }
}

function Assert-Property
{
	param
	(
		[parameter(Mandatory = $true)]
		[String]$PSPath,

		[parameter(Mandatory = $true)]
		[String]$Name,

		[parameter(Mandatory = $true)]
		[String]$ConnectionString,

		[parameter(Mandatory = $true)]
		[String]$ProviderName,

        [Switch]$Apply

        #[Microsoft.IIs.PowerShell.Framework.ConfigurationElement]
	)

    # Filter for the given name
    $filter = "connectionStrings/add[@Name='$Name']"

    Write-Verbose -Message "Checking connectionString element with Name='$Name' in web.config for $PSPath ..."
    $connectionElement = Get-WebConfigurationProperty -PSPath $PSPath -Filter $filter -Name *
    
    # If connectionString element is present
    if($connectionElement)
    {
        Write-Verbose -Message "Found connectionStrings element with Name='$Name' in web.config"

        # Validate various attributes, if the connectionStrings element should be present
        if($Ensure -eq 'Present')
        {
            #Check for connectiongstring attribute
            Write-Verbose -Message "Checking connectionString attribute for Name='$Name' ..."
            if($connectionElement.ConnectionString -ne $ConnectionString)
            {
                Write-Verbose -Message "connectionString attribute for Name='$Name' is not in desired state"
                Write-Debug -Message "connectionString expected $ConnectionString, but actual is $($connectionElement.ConnectionString)"
                if($Apply)
                {
                    Set-WebConfigurationProperty -PSPath $PSPath -Filter $filter -Name 'ConnectionString' -Value $ConnectionString
                    Write-Verbose -Message "connectionString attribute for Name='$Name' is now in desired state"
                    Write-Debug -Message "connectionString is set to $($connectionElement.ConnectionString)"
                }
                else
                {
                    return $false
                }
            }
            else
            {
                Write-Verbose -Message "connectionString attribute for Name='$Name' is in desired state"
            }

            #Check for providerName attribute
            Write-Verbose -Message "Checking providerName attribute for Name='$Name' ..."
            if($connectionElement.providerName -ne $ProviderName)
            {
                Write-Verbose -Message "providerName attribute for Name='$Name' is not in desired state. Expected $ProviderName, actual $($connectionElement.ProviderName)"
                if($Apply)
                {
                    Set-WebConfigurationProperty -PSPath $PSPath -Filter $filter -Name 'ProviderName' -Value $ProviderName
                    Write-Verbose -Message "providerName attribute for Name='$Name' is now in desired state"
                }
                else
                {
                    return $false
                }
            }
            else
            {
                Write-Verbose -Message "providerName attribute for Name='$Name' is in desired state"
            }

            # If all the attributes are correct, return true for Test-TR function
            if(! $Apply){return $true}
        }

        # The element should not be present
        else
        {
            if($Apply)
            {
                Clear-WebConfiguration -PSPath $PSPath -Filter $filter
            }
            else
            {
                return $false
            }
        }
    }
    # If connectionString element is absent
    else
    {
        Write-Verbose -Message "connectionString element with Name='$Name' is not present in web.config"

        # If connectionStrings element should be present, add one
        if($Ensure -eq 'Present')
        {
            if($Apply)
            {
                # Element to add
                $item = @{Name=$Name;ConnectionString=$ConnectionString;ProviderName=$ProviderName}

                Write-Verbose -Message 'Adding a connectionString element in the web.config ...'
                Add-WebConfigurationProperty -PSPath $PSPath -Filter 'ConnectionStrings' -Name . -Value $item
                Write-Verbose -Message 'connectionString element successfully added to the web.config'
            }
            else
            {
                return $false
            }
        }
        else
        {
            # If connectionStrings element should be absent, return true for Test-TR function
            if(! $Apply){return $true}
    }
}
}
#endregion

Export-ModuleMember -Function *-TargetResource