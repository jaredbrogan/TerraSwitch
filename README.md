# TerraSwitch
PowerShell script that facilitates the action of switching Terraform versions on the fly.

## Usage
```
Options are as follows:
  -Version : The version of Terraform to be installed.
          - The list of versions that are able to be used can be derived from the '-ListVersions' option below.

  -ListVersions : List all versions of Terraform available for installation.

  -Latest : Automatic installation of the latest version of Terraform. 
```
### Examples
```
PS C:\Users> TerraSwitch.ps1 -Version 0.12.5
[INFO] Proceeding with installation of version 0.12.5

[INFO] Installing Terraform v0.12.5... Success!

====================TERRAFORM_OUTPUT====================
Terraform v0.12.5

Your version of Terraform is out of date! The latest version
is 1.3.4. You can update by downloading from www.terraform.io/downloads.html
```
```
PS C:\Users> TerraSwitch.ps1 -Latest                                                                                                                [INFO] Proceeding with installation of the latest version available

[INFO] Using previously downloaded Terraform v1.3.4
[WARNING] The 'C:\Users\johndoe\terraform\bin' directory is not residing in PATH.
  • Updating PATH now... Success!

[INFO] Installing Terraform v1.3.4... Success!

====================TERRAFORM_OUTPUT====================
Terraform v1.3.4
on windows_amd64
```
```
PS C:\Users> TerraSwitch.ps1 -Version 1.2.8
[INFO] Proceeding with installation of version 1.2.8

[INFO] Using previously downloaded Terraform v1.2.8
[INFO] Installing Terraform v1.2.8... Success!

====================TERRAFORM_OUTPUT====================
Terraform v1.2.8
on windows_amd64

Your version of Terraform is out of date! The latest version
is 1.3.4. You can update by downloading from https://www.terraform.io/downloads.html
```
---

#### Disclaimer
This was heavily influenced by [TFswitch/Terraform-Switcher](https://github.com/warrensbox/terraform-switcher).  
Due to it not being natively compatible with PowerShell, I decided to create this instead.

---

## Contributors
* [**Jared Brogan**](https://github.com/jaredbrogan "Author")
