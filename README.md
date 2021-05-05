# This project has been depricated!!
# The underlying module is no longer support by Microsoft
# The code is being left here for historical reasons only


# Project: Cloud Connect

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
