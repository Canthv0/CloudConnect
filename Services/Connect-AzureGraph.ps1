function Connect-AzureGraph {

    <#
    .SYNOPSIS
    Provided an Authorization Header for the Azure Graph API

    .DESCRIPTION
    Acquires a token from Azure AD
    Returns an Authorization Header that can be used with Azure Graph API

    Token lifetime is 1 hour
    If token is within 15 min of expiring will acquire a new token and provide a new header

    .LINK
    https://github.com/Canthv0/CloudConnect

    .OUTPUTS
    Authorization Header to be used with the Azure Graph API

    .EXAMPLE
    Gets the Header and passes it to Graph API when used with Invoke-WebRequest

    $Header = Connect-AzureGraph
    
    $Url = "https://graph.windows.net/MyTenant/activities/signinEvents?api-version=beta&`$filter=signinDateTime+ge+2019-04-16T13:07:06Z"
    $RawReport = Invoke-WebRequest -UseBasicParsing -Headers $Header -Uri $url -TimeoutSec 300

    #>

    # See if we already have a token for the Azure Graph
    $CurrentToken = Get-TokenCache | Where-Object { $_.Resource -like "https://graph.windows.net" }
    
    
    # If there is not a token then get one
    if ($null -eq $CurrentToken) {
        # Get the token from the service
        Write-Debug "No Token Found"
        $Token = (Get-ServiceToken -service AzureGraph).Result
    }
    # If the token is within 15 minutes of expiring then we need to get a new token
    elseif (($CurrentToken.ExpiresOn - (get-date)).Totalminutes -lt 15){
        # Get the token from the service
        Write-Debug "Token about to expire"
        $Token = (Get-ServiceToken -service AzureGraph).Result
    }
    # Otherwise we should be good
    else {
        Write-Debug "Valid Token"
        $Token = (Get-TokenCache -Full) | Where-Object { $_.Resource -like "https://graph.windows.net" }
    }

    $Header = @{'Authorization' = "Bearer $($Token.AccessToken)" }

    Return $Header   

}