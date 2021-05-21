Function Connect-EXOLegacy {

    <#
    .SYNOPSIS
    Creates a connection to Exchange online using Legacy Auth (BASIC)

    .DESCRIPTION
    Connecto to Exchange Online in the Legacy Manner using Basic Authentication

    .LINK
    https://github.com/Canthv0/CloudConnect

    .PARAMETER Credential
    Credential Object used to connect to EXO.
    If not provided user will be prompted for it.

    .PARAMETER Prefix

    Adds support for cmdlet noun prefixing. This avoids clobbering existing cmdlets in the current PS environment.

    .PARAMETER CommandList

    Supports importing only specific cmdlets with this session. This will speed up the creation of the session and ultimately use less memory.

    .OUTPUTS
    None.  Creates a PS session to EXO and imports it into the global scope

    .EXAMPLE
    Connect-EXOLegacy

    Will prompt for credentials and import Exchange PS Session into the global scope

    .EXAMPLE
    $Cred = Get-Credential
    Connect-EXOLegacy -Credential $Cred

    Will used the $cred credential to connect to exchange Online


    .EXAMPLE
    Connect-ExoLefgacy -Prefix "client"

    Will prompt for credentials and import Exchange PS Session into the global scope, prefixing all nouns with "client"
    i.e. Get-clientMailbox

    .EXAMPLE
    Connect-ExoLegacy -CommandList "Get-Mailbox","Set-Mailbox"

    Will prompt for credentials and import Exchange PS Session into the global scope, including only those commands listed.

    #>

    Param(
        [Parameter(Mandatory=$false)]
        [PSCredential]$Credential,

        [parameter(Mandatory=$false)]
        [string]$Prefix,

        [Parameter(Mandatory=$false)]
        [string[]]$CommandList


    )

    # If we don't have a credential then prompt for it
    $i = 0
    while (($Null -eq $Credential) -and ($i -lt 5)) {
        $Credential = Get-Credential -Message "Please provide your Exchange Online Credentials"
        $i++
    }

    # If we still don't have a credentail object then abort
    if ($null -eq $Credential) {
        Write-Error -Message "Failed to get credentials" -ErrorAction Stop
    }

    # Check for a previous sesison and remove it
    Get-PSSession -name Legacy_EXO* | Remove-PSSession -Confirm:$false

    # Create and import the session
    $session = New-PSSession -Name Legacy_EXO -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credential -Authentication Basic -AllowRedirection


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