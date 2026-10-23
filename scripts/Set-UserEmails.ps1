<#
.SYNOPSIS
    Gives every employee an email address based on their logon name.

.DESCRIPTION
    osTicket identifies portal users by email address, and accounts created
    before the help desk existed had none. This sets <username>@lab.local on
    every user in Company\Users (including the IT, HR and Sales OUs), then
    lists the result. Disabled former employees live in Company\Disabled Users,
    outside the search, so they are deliberately left alone.

.NOTES
    Run in an elevated PowerShell window on DC01. Safe to re-run.
#>

$searchBase = "OU=Users,OU=Company,DC=lab,DC=local"

Get-ADUser -Filter * -SearchBase $searchBase |
    ForEach-Object { Set-ADUser $_ -EmailAddress "$($_.SamAccountName)@lab.local" }

# Verify: every row should show an address
Get-ADUser -Filter * -SearchBase $searchBase -Properties mail |
    Select-Object SamAccountName, mail
