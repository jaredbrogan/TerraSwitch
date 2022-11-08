<#
.SYNOPSIS
    This script facilitates the process of changing Terraform versions.

.DESCRIPTION
    This script will allow users to quickly and efficiently change the version of Terraform being utilized.

    Options are as follows:
     -Version : The version of Terraform to be installed.
            - The list of versions that are able to be used can be derived from the '-ListVersions' option below.

     -ListVersions : List all versions of Terraform available for installation.

     -Latest : Automatic installation of the latest version of Terraform. 

.EXAMPLE
    TerraSwitch.ps1 -Version 1.3.4

.EXAMPLE
    TerraSwitch.ps1 -ListVersions

.LINK
    https://github.com/jaredbrogan/TerraSwitch

.NOTES
    Author:  Jared Brogan
    Contact: jaredbrogan.github.io
#>

param(
  [Parameter(Mandatory=$false)][string]$Version,
  [Parameter(Mandatory=$false)][switch]$ListVersions,
  [Parameter(Mandatory=$false)][switch]$Latest
)

$bullet = [char]0x2022

function CheckParams {
  if ( !$Version -And !$ListVersions -And !$Latest -And !$Revert ){
    Write-Host -ForegroundColor Red "[ERROR] No arguments provided. Please try again."
    Write-Host -ForegroundColor Red "  $bullet Exit Code: 1"
    exit 1
  }
  elseif ( $Version -And !$ListVersions -And !$Latest -And !$Revert ){
    if ( $Version -match '^[0-9].{4}.*'){
      Write-Host -ForegroundColor Green "[INFO] Proceeding with installation of version $Version`n"
      InstallVersion($Version)
    }
    else{
      Write-Host -ForegroundColor Red "[ERROR] Version provided is not valid. Please try again."
      Write-Host -ForegroundColor Red "  $bullet Exit Code: 2"
      exit 2
    }
  }
  elseif ( !$Version -And $ListVersions -And !$Latest ){
    Write-Host -ForegroundColor Green "[INFO] Listing available Terraform versions..."
    ListVersions
  }
  elseif ( !$Version -And !$ListVersions -And $Latest ){
    Write-Host -ForegroundColor Green "[INFO] Proceeding with installation of the latest version available`n"
    $Version = "Latest"
    InstallVersion($Version)
  }
  else {
    Write-Host -ForegroundColor Red "[ERROR] Undetermined error found. Exiting..."
    Write-Host -ForegroundColor Red "  $bullet Exit Code: 3"
    exit 3
  }
}


function ListVersions {
  $Versions = ((Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/").Links.href | Select-Object -Skip 1 | %{ $_ -Replace "^/terraform/", "" }).TrimEnd('/')
 
  ForEach ($Version in $Versions){
    Write-Host "  $bullet $Version"
  }
  Write-Host ""
  exit 0
}

function InstallVersion($Version){
  # Variables
  $InstallDir = "$env:USERPROFILE\terraform"
  $BinDir = "$InstallDir\bin"
  $CacheDir = "$InstallDir\cache"
  $LocalStatus = $False
  
  # Check to see if Version is specified or set to Latest
  if ($Version -eq "Latest"){
    $Version = ((Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/").Links.href | Select-Object -Skip 1 | %{ $_ -Replace "^/terraform/", "" }).TrimEnd('/') | Select-Object -First 1
  }
  $DownloadDir = "$CacheDir\$Version\terraform_$Version`_windows_amd64"
  
  # Check if version is available locally, if not check if available externally
  if (Test-Path -Path "$CacheDir\$Version\terraform.exe") {
    Write-Host -ForegroundColor Green "[INFO] Using previously downloaded Terraform v$Version"
    $LocalStatus = $True
  }
  else{
    try{ 
      $StatusCode = (Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/$Version" -ErrorAction Stop).StatusCode
    }
    catch{
      $StatusCode = $_.Exception.Response.StatusCode.Value__
    }
    
    if ($StatusCode -ne 200){
      Write-Host -ForegroundColor Red "[ERROR] Version provided is not available. Exiting..."
      Write-Host -ForegroundColor Red "  $bullet Exit Code: 4"
      exit 4
    }
  }
  
  # Check if the installation directory is present
  if (! (Test-Path -Path $InstallDir) ){
    Write-Host -ForegroundColor Yellow "[WARNING] Install directory not present!"
    Write-Host -ForegroundColor Yellow "  $bullet Creating '$InstallDir' contents now... " -NoNewLine
    New-Item -ItemType "directory" -Path "$CacheDir" -Force | Out-File Null
    New-Item -ItemType "directory" -Path "$BinDir" -Force | Out-File Null
    if (Test-Path -Path $InstallDir){
      Write-Host -ForegroundColor Green "Success!`n"
    }
    else{
      Write-Host -ForegroundColor Red "Failed."
      Write-Host -ForegroundColor Red "  $bullet Exit Code: 5"
      exit 5
    }
  }
  
  # Checks if the installation directory is in PATH
  $UserPath = $env:path.split(";")
  $ValidPath = 0
  ForEach ($entry in $UserPath){
    if ($entry -eq $BinDir){
      $ValidPath++
    }
  }
  
  if ($ValidPath -eq 0){
    Write-Host -ForegroundColor Yellow "[WARNING] The '$BinDir' directory is not residing in PATH."
    Write-Host -ForegroundColor Yellow -NoNewLine "  $bullet Updating PATH now... "
    Add-Content -Value `n'$env:Path += ";$env:USERPROFILE\terraform\bin"' -Path "$PROFILE"
    & $PROFILE
    Write-Host -ForegroundColor Green "Success!`n"
  }
  
  # Install Terraform
  Write-Host -NoNewLine -ForegroundColor Green "[INFO] Installing Terraform v$Version... "
  New-Item -ItemType "directory" -Path "$CacheDir\$Version" -Force | Out-File Null
  if ($LocalStatus){
    Copy-Item "$CacheDir\$Version\terraform.exe" -Destination "$BinDir\terraform.exe" -Force | Out-Null
  }
  else{
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/$Version/terraform_$Version`_windows_amd64.zip" -OutFile "$DownloadDir.zip" | Out-Null
    Expand-Archive -Force -Path "$DownloadDir.zip" -DestinationPath "$DownloadDir" | Out-Null
    Copy-Item "$DownloadDir\terraform.exe" -Destination "$BinDir\terraform.exe" -Force | Out-Null
    Copy-Item "$DownloadDir\terraform.exe" -Destination "$CacheDir\$Version\terraform.exe" -Force | Out-Null
    Remove-Item -Path "$DownloadDir*" -Force -Recurse | Out-Null
  }
  
  $TFexe = "$BinDir\terraform.exe"
  if (Test-Path $TFexe){
    Write-Host -ForegroundColor Green "Success!`n"
  }
  else{
    Write-Host -ForegroundColor Red "Failed."
    Write-Host -ForegroundColor Red "  $bullet Exit Code: 6"
    exit 6
  }
  
  Write-Host "====================TERRAFORM_OUTPUT===================="
  Start-Process $TFexe -ArgumentList version -NoNewWindow -Wait
  Write-Host ""
  exit 0
}

#__main__
CheckParams
