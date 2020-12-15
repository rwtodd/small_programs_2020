<# 
This is a one-off script to look at all MP4 files under the current directory
and use the Shell.Application COM object to look up the length of the movie.  It
then sorts them and outputs a CSV of it all.

The point was to look for identical or near-identical movies that I might have re-ripped at
different bitrates.  So, the names and file sizes will be different, but the movie length will
still be very similar.
#>

$objShell = New-Object -ComObject Shell.Application

Get-ChildItem -Directory | ForEach-Object {
    $objFolder = $objShell.namespace($_.FullName)
    
    Get-ChildItem (Join-Path $_ "*.mp4") | Foreach-Object {
        $fname = $_.Name
        $result = [PSCustomObject]@{
            File = Resolve-Path -Relative $_.FullName
            Length = $objFolder.GetDetailsOf($objFolder.parseName($fname),27)
        }
        write-output $result
    } 
} | Sort-Object -Property Length | Export-Csv -Path All_Lengths.csv
