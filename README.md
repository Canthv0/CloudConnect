# Project: Cloud Connect

## Install
The module is published to the PowerShell Gallery so it should be installed from there.
https://www.powershellgallery.com/packages/CloudConnect/1.0.0

Install-Module -Name CloudConnect

## Description:
PS Module for connecting to Shell / Graph API using ADAL to multiple Microsoft Cloud Services (O365)

## Implemented Services:
Exchange Online MFA                     - Connect-EXO
Exchange Online Legacy                  - Connect-EXOLegacy
Azure Graph                             - Connect-AzureGraph
MSOnline PowerShell for Azure AD        - Connect-MSOLService (Imported from MSOL Module)
Security and Compliance Center MFA      - Connect-SCC
Security and Compliance Center Legacy   - Connect-SCCLegacy

## Known Issues:
- New PSSession and Import must be done when refreshing the EXO token
- New PSSession and Import must be done when refreshing the SCC token

## License
MIT License