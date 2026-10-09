<#
.SYNOPSIS
    Lists user accounts missing a job title or department.

.DESCRIPTION
    Searches Company\Users (and every OU below it) for accounts where Title
    or Department is empty. Used in ticket #1009 to find and then verify the
    fix of incomplete accounts: an empty result means nothing is missing.
#>

Get-ADUser -Filter * -SearchBase "OU=Users,OU=Company,DC=lab,DC=local" -Properties Title,Department |
    Where-Object { -not $_.Title -or -not $_.Department } |
    Select-Object Name,SamAccountName,Title,Department
