function Connect-EXO {

    <#
    .SYNOPSIS
    Creates a connection to Exchange online using Oauth

    .DESCRIPTION
    Acquires a token from Azure AD
    Uses that token to connect to Exchange Online Powershell

    Token lifetime is 1 hour
    The Caller must manage the session / token lifetime.
    It will pull the token from the token cache for a silent refresh of the toke if it is there.

    When the token expires if the session is not refreshed the Exchange shell will attempt implict remoting that will prompt / fail

    .LINK
    https://github.com/Canthv0/CloudConnect

    .PARAMETER Prefix

    Adds support for cmdlet noun prefixing. This avoids clobbering existing cmdlets in the current PS environment.

    .PARAMETER CommandList

    Supports importing only specific cmdlets with this session. This will speed up the creation of the session and ultimately use less memory.

    .OUTPUTS
    None.  Creates a PS session to EXO and imports it into the global scope

    .EXAMPLE
    Connect-Exo

    Will prompt for credentials and import Exchange PS Session into the global scope

    .EXAMPLE
    Connect-Exo -Prefix "client"

    Will prompt for credentials and import Exchange PS Session into the global scope, prefixing all nouns with "client"
    i.e. Get-clientMailbox

    .EXAMPLE
    Connect-Exo -CommandList "Get-Mailbox","Set-Mailbox"

    Will prompt for credentials and import Exchange PS Session into the global scope, including only those commands listed.

    #>

    param(
        [parameter(Mandatory=$false)]
        [string]$Prefix,

        [Parameter(Mandatory=$false)]
        [string[]]$CommandList
    )
    # Get the token from the service
    $Token = Get-ServiceToken -service exo

    # Check for an existing PS Session to EXO and remove it
    Get-PSSession -name exo* | Remove-PSSession -Confirm:$false

    # Build the auth information
    $Authorization = "Bearer {0}" -f $Token.Result.AccessToken
    $UserId = ($Token.Result.UserInfo.DisplayableId).tostring()

    # create the "basic" token to send to O365 EXO
    $Password = ConvertTo-SecureString -AsPlainText $Authorization -Force
    $Credtoken = New-Object System.Management.Automation.PSCredential -ArgumentList $UserId, $Password

    # Create and import the session
    $Session = New-PSSession -Name EXO -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/PowerShell-LiveId?BasicAuthToOAuthConversion=true' -Credential $Credtoken -Authentication Basic -AllowRedirection -ErrorAction Stop

    $ImportSessionParams = @{

        Session = $Session
        AllowClobber = $true
    }

    $ImportModuleParams = @{

        global = $true
        WarningAction = "SilentlyContinue"
    }

    if($Prefix) {

        $ImportSessionParams.Add("Prefix",$Prefix)
        $ImportModuleParams.Add("Prefix",$Prefix)
    }

    if($CommandList) {

        $ImportSessionParams.Add("CommandName",$CommandList)
    }

    Import-Module (Import-PSSession @ImportSessionParams) @ImportModuleParams

}