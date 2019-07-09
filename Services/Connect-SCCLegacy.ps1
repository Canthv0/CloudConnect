Function Connect-SCCLegacy {

    <#
    .SYNOPSIS
    Creates a connection to Exchange online using Legacy Auth (BASIC)

    .DESCRIPTION
    Connecto to Security and Compliace Center in the Legacy Manner using Basic Authentication

    .LINK
    https://github.com/Canthv0/CloudConnect

    .PARAMETER Credential
    Credential Object used to connect to SCC.
    If not provided user will be prompted for it.

    .OUTPUTS
    None.  Creates a PS session to SCC and imports it into the global scope

    .EXAMPLE
    Connect-SCCLegacy

    Will prompt for credentials and import Exchange PS Session into the global scope

    .EXAMPLE
    $Cred = Get-Credential
    Connect-SCCLegacy -Credential $Cred

    Will used the $cred credential to connect to Security and Compliance Center

    #>

    Param($Credential)    

    # If we don't have a credential then prompt for it
    $i = 0
    while (($Null -eq $Credential) -and ($i -lt 5)) {
        $Credential = Get-Credential -Message "Please provide your Security and Compliance Center Credentials"
        $i++
    }
	
    # If we still don't have a credentail object then abort
    if ($null -eq $Credential) {
        Write-Error -Message "Failed to get credentials" -ErrorAction Stop
    }
	
    # Check for a previous sesison and remove it
    Get-PSSession -name Legacy_SCC* | Remove-PSSession -Confirm:$false

    # Create and import the session
    $session = New-PSSession -Name Legacy_SCC -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid/" -Credential $Credential -Authentication Basic -AllowRedirection
    Import-Module (Import-PSSession $Session -AllowClobber) -Global -WarningAction 'SilentlyContinue'
}