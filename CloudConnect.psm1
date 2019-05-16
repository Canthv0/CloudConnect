Function Get-ServiceToken {
    <#
    .SYNOPSIS
    Get a token for a given Microsoft Cloud Service

    .DESCRIPTION
    Returns an ADAL token for a given Microsoft Cloud Service
    Will attempt to acquire the token silently (refresh) if possible

    .LINK
    https://github.com/Canthv0/CloudAuthModule

    .OUTPUTS
    Returns a token object for the requested cloud service

    .EXAMPLE
    Get-ServiceToken -Service EXO

    Returns a token for the Exchange Online Service.

    #>

    
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [ValidateSet("EXO","AzureGraph")]
        [string]
        $Service
    )

    # References
    # https://github.com/AzureAD/azure-activedirectory-library-for-dotnet/wiki/AcquireTokenSilentAsync-using-a-cached-token
    # https://github.com/AzureAD/azure-activedirectory-library-for-dotnet/tree/adalv3/dev
    # 

    # Ensure our ADAL types are loaded and availble
    Add-ADALType

    switch ($Service) {
        exo {
            # EXO Powershell Client ID
            $clientId = "a0c73c16-a7e3-4564-9a95-2bdf47383716" 
            # Set redirect URI for PowerShell
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
            # Set Resource URI to EXO endpoint
            $resourceAppIdURI = "https://outlook.office365.com"
            # Set Authority to Azure AD Tenant
            $authority = "https://login.windows.net/common"

        }
        AzureGraph {
            # Azure PowerShell Client ID
            $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
            # Set redirect URI for PowerShell
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
            # Set Resource URI to EXO endpoint
            $resourceAppIdURI = "https://graph.windows.net"
            # Set Authority to Azure AD Tenant
            $authority = "https://login.windows.net/common"            
        }
        Default { Write-Error "Service Not Implemented" -ErrorAction Stop }
    }

    # Create AuthenticationContext tied to Azure AD Tenant
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    # Create platform Options, we want it to prompt if it needs to.
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
    
    # Acquire token, this will place it in the token cache
    # $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters)

    Write-Debug "Looking in token cache"
    $Result = $authContext.AcquireTokenSilentAsync($resourceAppIdURI, $clientId)
    
    while ($result.IsCompleted -ne $true) { Start-Sleep -Milliseconds 500; write-debug "silent sleep" }
    
    # Check if we failed to get the token
    if (!($Result.IsFaulted -eq $false)) {
         
        Write-Debug "Acquire token silent failed"
        switch ($Result.Exception.InnerException.ErrorCode) {
            failed_to_acquire_token_silently { 
                # do nothing since we pretty much expect this to fail
                Write-Information "Cache miss, asking for credentials"
                $Result = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters)
                
                while ($result.IsCompleted -ne $true) { Start-Sleep -Milliseconds 500; write-debug "sleep" }
            }
            multiple_matching_tokens_detected {
                # we could clear the cache here since we don't have a UPN, but we are just going to move on to prompting
                Write-Information "Multiple matching entries found, asking for credentials"
                $Result = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters)
                
                while ($result.IsCompleted -ne $true) { Start-Sleep -Milliseconds 500; write-debug "sleep" }
            }
            Default { Write-Error -Message "Unknown Token Error $Result.Exception.InnerException.ErrorCode" -ErrorAction Stop }
        }
    }   

    Return $Result
    
}

Function Add-ADALType {

    $path = join-path (split-path (Get-Module azuread -ListAvailable | Where-Object { $_.Version -eq '2.0.2.16' }).Path -parent) 'Microsoft.IdentityModel.Clients.ActiveDirectory.dll'
    Add-Type -Path $path
    
}

Function Get-TokenCache {
    param(
        [Switch]$Full = $false
    )

    <#
    .SYNOPSIS
    Returns the current contents of the token cache

    .DESCRIPTION
    Returns basic properties about the objects currently in the token cache.
    Returns the local time that the token will expire.

    .LINK
    https://github.com/Canthv0/CloudAuthModule

    .OUTPUTS
    List of the information in the token cache.

    .EXAMPLE
    Get-TokenCache

    Displays the information currently in the token cache.

    #>


    # Ensure our ADAL types are loaded and availble
    Add-ADALType

    $cache = [Microsoft.IdentityModel.Clients.ActiveDirectory.TokenCache]::DefaultShared
    
    if ($full){
        Return $Cache.ReadItems()
    }
    else {
        $cache.ReadItems() | Select-Object DisplayableId, Authority, ClientId, Resource, @{Name = "ExpiresOn"; Expression = { $_.ExpiresOn.localdatetime } }
    }
    
    

}