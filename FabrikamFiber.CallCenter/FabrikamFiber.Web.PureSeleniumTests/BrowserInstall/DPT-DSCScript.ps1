Configuration Deploy
{
    Import-DscResource -module xFirefox 
    Import-DscResource -module xChrome

    Node $AllNodes.NodeName
    {
        MSFT_xFirefox firefox 
        {
        }

        MSFT_xChrome chrome
        {
        }
    }
}

Deploy -ConfigurationData $ConfigData