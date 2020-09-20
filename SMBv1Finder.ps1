#Requires -RunAsAdministrator

#SMBv1Finder.ps1
#Version 0.1
#By: Arjan Sturing
#This script is for finding Windows servers with SMBv1 enabled and listing the shares within a AD environment.
#Use this script at you own risk!
#Always make sure that you have the permission of the server owner before executing the script!

#Function for finding Servers in Active Directory with SMBv1 enabled and listing the shares of the regarding servers.
function smbv1-ad{Get-Item WSMan:\localhost\Client\TrustedHosts
Write-Host "For scanning the servers in de AD you need to enable PS Remoting on the servers."
Write-Host "In the readme file you will find a guide to enable PS Remoting by GPO"
Write-Host ""-ForeGroundColor Green
Write-Host "Enter credentials of authorized PS Remoting AD User" -ForeGroundColor Green
$credential = Get-Credential -Message "Enter credentials of authorized PS Remoting AD User"
$servers = Get-ADComputer -properties "operatingsystem" -filter {operatingsystem -like "*server*"} | select DNSHostname
md $env:USERPROFILE\SMBv1Finder -Force
md $env:USERPROFILE\SMBv1Finder\adscan -Force
cd $env:USERPROFILE\SMBv1Finder\adscan
Get-ChildItem *.txt | foreach { Remove-Item -Path $_.FullName }
foreach ($server in $servers)
{
Invoke-Command -ComputerName $Server.DNSHostname -ScriptBlock {Get-SmbServerConfiguration | Select EnableSMB1Protocol} -Credential $credential | Out-File -FilePath $env:USERPROFILE\SMBv1Finder\adscan\$Server.txt
Invoke-Command -ComputerName $Server.DNSHostname -ScriptBlock {Get-SmbShare} -Credential $credential | Out-File -FilePath $env:USERPROFILE\SMBv1Finder\adscan\$Server.txt -Append
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace '@{DNSHostname=','' }
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace '}','' }
}
}


#Function for finding specified server with SMBv1 enabled and listing the shares of the regarding server.
function smbv1-manual{
Write-Host "For scanning a remote server to enable PS Remoting on the regarding server."
Write-Host "You can enable PS Remoting by executing the follwing command on the regarding server: Enable-PSRemoting -Force"
Write-Host ""-ForeGroundColor Green
$server = Read-Host -Prompt 'Enter Server FDQN or IP Address'
cls
Write-Host "Enter credentials of authorized PS Remoting User" -ForeGroundColor Green
$credential = Get-Credential -Message "Enter credentials of authorized PS Remoting User" 
md $env:USERPROFILE\SMBv1Finder -Force
Invoke-Command -ComputerName $server -ScriptBlock {Get-SmbServerConfiguration | Select EnableSMB1Protocol} -Credential $credential  | Out-File -FilePath $env:USERPROFILE\SMBv1Finder\$server.txt
Invoke-Command -ComputerName $server -ScriptBlock {Get-SmbShare} -Credential $credential  | Out-File -FilePath $env:USERPROFILE\SMBv1Finder\$server.txt -Append
}

#Function for finding SMBv1 status of current computer and listing the shares of the current computer..
function smbv1-local{ 
md $env:USERPROFILE\SMBv1Finder -Force
Get-SmbServerConfiguration | Select EnableSMB1Protocol | Out-File -FilePath $env:USERPROFILE\SMBv1Finder\$env:COMPUTERNAME.txt
Get-SmbShare | Out-File -FilePath $env:USERPROFILE\SMBv1Finder\$env:COMPUTERNAME.txt -append
}

#Function for the menu.
function menu
{
    
    Clear-Host
    write-host ""
    write-host " _______  __   __  _______  __   __  ____     _______  ___   __    _  ______   _______  ______" -ForegroundColor Red
    write-host "|       ||  |_|  ||  _    ||  | |  ||    |   |       ||   | |  |  | ||      | |       ||    _ |" -ForegroundColor Red   
    write-host "|  _____||       || |_|   ||  |_|  | |   |   |    ___||   | |   |_| ||  _    ||    ___||   | ||" -ForegroundColor Red
    write-host "| |_____ |       ||       ||       | |   |   |   |___ |   | |       || | |   ||   |___ |   |_||_" -ForegroundColor Red
    write-host "|_____  ||       ||  _   | |       | |   |   |    ___||   | |  _    || |_|   ||    ___||    __  |" -ForegroundColor Red
    write-host " _____| || ||_|| || |_|   | |     |  |   |   |   |    |   | | | |   ||       ||   |___ |   |  | |" -ForegroundColor Red
    write-host "|_______||_|   |_||_______|  |___|   |___|   |___|    |___| |_|  |__||______| |_______||___|  |_|" -ForegroundColor Red
    write-host ""
    write-host "By: Arjan Sturing" -ForegroundColor Green
    write-host "" 
    Write-Host "1: Scan all servers of Active Directory Domain"
    Write-Host "2: Scan specified server"
    Write-Host "3: Scan current server"
    Write-Host "Q: Quit"
    write-host "" 
    Write-Host "Automate the world! #Powershell" -ForegroundColor Yellow
    write-host "" 

     $selection = Read-Host "Select an option"
     switch ($selection)
     {
         '1' {
             cls
             smbv1-ad
             cls
             Write-Host "You can find the results in the following directory: $env:USERPROFILE\SMBv1Finder\adscan" -ForeGroundColor Green
             Start-Sleep 5
             cls
             menu
         } '2' {
             cls
             smbv1-manual
             cls
             Write-Host "You can find the results in the following directory: $env:USERPROFILE\SMBv1Finder\" -ForeGroundColor Green
             Start-Sleep 5
             cls
             menu
         }
         '3' {
             cls
             smbv1-local
             cls
             Write-Host "You can find the results in the following directory: $env:USERPROFILE\SMBv1Finder\" -ForeGroundColor Green
             Start-Sleep 5
             cls
             menu
         }  
     }
     }
menu
