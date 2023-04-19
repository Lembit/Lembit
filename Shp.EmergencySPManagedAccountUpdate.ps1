#########################################################################################################
#########################################################################################################
############################### Author: Antonio Leonardo de Abreu Freire ################################
#### Microsoft Certified ID: 13271836, vide https://www.youracclaim.com/users/antonioleonardo/badges ####
#########################################################################################################
## Update SharePoint Account Password on all Farm Layers: IIS, Windows Services and SharePoint Services #
#########################################################################################################
#########################################################################################################
########### Don't Forget this Script Premisses! The current user to execute this script needs: ##########
########### a)Belongs to Farm Administrator Group; ######################################################
########### b)local machine Administrator (on any SharePoint Farm server); ##############################
########### c)SQL Server SecurityAdmin profile (on SharePoint database instance); #######################
########### d)db_owner on databases "SharePoint_Config" and "SharePoint_Admin_<any guid>"; ##############
#########################################################################################################
#########################################################################################################
#########################################################################################################

Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted -Force
Import-Module WebAdministration
$serviceAccount = Read-Host -Prompt "Please enter the user (in DOMAIN\username format)."
$securePass = Read-Host "Now, what is this user's password? Please enter (this field will be encrypted)." -AsSecureString
$plainTextPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass))
$applicationPools = Get-ChildItem IIS:\AppPools | where { $_.processModel.userName -eq $serviceAccount }
foreach($pool in $applicationPools)
{
    $pool.processModel.userName = $serviceAccount
    $pool.processModel.password = $plainTextPass
    $pool.processModel.identityType = 3
    $pool | Set-Item
}
$serverName = $env:computername
$shpServices = gwmi win32_service -computer $serverName | where {$_.StartName -eq $serviceAccount}
foreach($service in $shpServices)
{
   $service.change($null,$null,$null,$null,$null,$null,$null,$plainTextPass)
}
Add-PSSnapin Microsoft.SharePoint.PowerShell
$managedAccount = Get-SPManagedAccount | where { $_.UserName -eq $serviceAccount }
Set-SPManagedAccount -Identity $managedAccount -ExistingPassword $securePass –UseExistingPassword:$True -Confirm:$False
if((Get-SPFarm).DefaultServiceAccount.Name -eq $serviceAccount)
{
   stsadm.exe –o updatefarmcredentials –userlogin $serviceAccount –password $plainTextPass
}
iisreset /noforce