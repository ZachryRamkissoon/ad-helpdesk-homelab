<#
.SYNOPSIS
    Creates new-starter accounts in Active Directory from an HR CSV file.

.DESCRIPTION
    For each row in newhires.csv, creates an enabled user in the OU matching
    their department (Company\Users\<Department>), fills in title and
    department and email address, sets a temporary password that must be changed at first
    logon, and adds the user to the matching <Department>-Staff group.

    Group Policy (the S: drive map) and file share access then apply
    automatically, because they are tied to the OU and group.

.NOTES
    Lab: lab.local (Windows Server 2025). Run in an elevated PowerShell
    window on a domain controller or a machine with the ActiveDirectory module.
    The temporary password is prompted for at run time and never stored here.
#>

# Ask for the temporary password (it's never stored in this file)
$password = Read-Host "Temporary password for new starters" -AsSecureString

# Read HR's list
$users = Import-Csv "C:\Scripts\newhires.csv"

foreach ($u in $users) {

    # Each department has its own OU under Company\Users
    $ou = "OU=$($u.Department),OU=Users,OU=Company,DC=lab,DC=local"

    $params = @{
        Name                  = "$($u.FirstName) $($u.LastName)"
        GivenName             = $u.FirstName
        Surname               = $u.LastName
        DisplayName           = "$($u.FirstName) $($u.LastName)"
        SamAccountName        = $u.Username
        UserPrincipalName     = "$($u.Username)@lab.local"
        EmailAddress          = "$($u.Username)@lab.local"   # osTicket identifies users by email
        Title                 = $u.Title
        Department            = $u.Department
        Path                  = $ou
        AccountPassword       = $password
        ChangePasswordAtLogon = $true
        Enabled               = $true    # New-ADUser creates accounts disabled by default
    }

    New-ADUser @params

    # Department groups follow the convention <Department>-Staff
    Add-ADGroupMember -Identity "$($u.Department)-Staff" -Members $u.Username

    Write-Host "Created $($u.Username) in $($u.Department)"
}
