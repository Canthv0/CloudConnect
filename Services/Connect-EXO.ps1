function Connect-EXO {

    # Get the token from the service
    $Token = Get-ServiceToken -service exo

    # Build the auth information
    $Authorization = "Bearer {0}" -f $Token.Result.AccessToken
    $UserId = ($Token.Result.UserInfo.DisplayableId).tostring()
    
    # create the "basic" token to send to O365 EXO
    $Password = ConvertTo-SecureString -AsPlainText $Authorization -Force
    $Credtoken = New-Object System.Management.Automation.PSCredential -ArgumentList $UserId, $Password
    
    # Create and import the session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/PowerShell-LiveId?BasicAuthToOAuthConversion=true' -Credential $Credtoken -Authentication Basic -AllowRedirection
    Import-Module (Import-PSSession $Session -AllowClobber) -Global

}