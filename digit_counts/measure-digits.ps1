<#
.SYNOPSIS
Counts the digits/characters in the given input.
.DESCRIPTION
It converts the input to a character array, and groups the like characters.
.PARAMETER InputObject
The input to work on.
#>
Param(
    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
    [object[]]$InputObject
)
Process {
$InputObject | ForEach-Object { $_.ToString().ToCharArray() } | Group-Object | `
        Sort-Object -Property Count | `
        Select-Object -Property Name,Count
}