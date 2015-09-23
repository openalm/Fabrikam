# Enable DSC
winrm quickconfig -force

# Set execution policy
Set-ExecutionPolicy Unrestricted -Scope Process

# Enable CredSSP
Enable-WSManCredSSP -Role client -DelegateComputer * -Force
Enable-WSManCredSSP -Role server -Force

#Install PSGet
Invoke-WebRequest -Uri "http://nuget.org/nuget.exe" -OutFile "$env:TEMP\NuGet.exe"; &"$env:TEMP\NuGet.exe" install PSGet -NoCache -Source http://dtlgalleryint.cloudapp.net/api/v2/ -ExcludeVersion -PackageSaveMode "nuspec" -OutputDirectory "$env:ProgramFiles\WindowsPowerShell\Modules"

# Update LCM settings
Configuration SetLcmConfigurationMode
{
    param([CimInstance] $LCM)
    LocalConfigurationManager
    {
        ConfigurationMode = 'ApplyOnly'
        AllowModuleOverwrite = $LCM.AllowModuleOverwrite
        CertificateID = $LCM.CertificateID
        ConfigurationID = $LCM.ConfigurationID
        ConfigurationModeFrequencyMins = 1200
        Credential = $LCM.Credential
        DownloadManagerCustomData = $LCM.DownloadManagerCustomData
        DownloadManagerName = $LCM.DownloadManagerName
        RebootNodeIfNeeded = $true
        RefreshFrequencyMins = 600
        RefreshMode = $LCM.RefreshMode
    }
}

$lcm = Get-DscLocalConfigurationManager
SetLcmConfigurationMode -LCM $lcm -OutputPath $env:TMP\SetLcmConfigurationMode
Set-DscLocalConfigurationManager -Path $env:TMP\SetLcmConfigurationMode

# Enable the DSC Analytic (verbose) log
# Per http://blogs.msdn.com/b/powershell/archive/2014/01/03/using-event-logs-to-diagnose-errors-in-desired-state-configuration.aspx
# The DSC Operational log (on by default) captures error messages
# The DSC Analytic log (OFF by default) captures verbose messages (including those logged by a resource)
# The DSC Debug log (OFF by default) captures "how the errors occurred"
wevtutil.exe set-log "Microsoft-Windows-Dsc/Analytic" /enabled:false
wevtutil.exe set-log "Microsoft-Windows-Dsc/Debug" /enabled:false
wevtutil.exe set-log "Microsoft-Windows-Dsc/Analytic" /quiet:true /enabled:true /retention:true
wevtutil.exe set-log "Microsoft-Windows-Dsc/Debug" /quiet:true /enabled:true /retention:true