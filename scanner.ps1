$outputFile =
"C:\PasswordScans\IDrive\output.csv"        #CHANGE OUTPUT
$searchPath = "CHANGE"      #CHANGE SEARCH PATH 
$searchTerm = "password","pwd","pass:","Username:","Username"      #CHANGE KEY WORDS IF WANTED 
$excludePhrase1 = "password Changed"   #CHANGE IF WANTED
$excludePhrase2 = "Password Expires"    #CHANGE IF WANTED

# Check if output file already exists
if (Test-Path $outputFile) {
    # Import existing data into a variable
    $existingData = Import-Csv -Path $outputFile

    # Get the last file processed
    $lastFileProcessed = ($existingData | Select-Object -Last 1).FilePath

    # Search for files that have a higher file name
    $newFiles = Get-ChildItem -Path $searchPath -Recurse -Include "*.txt" | Where-Object {$_.FullName -gt $lastFileProcessed}

    # Search for .txt files that contain the search term
    $newData = $newFiles | Select-String -Pattern $searchTerm | Where-Object {$_.Line -notmatch $excludePhrase1 -and $_.Line -notmatch $excludePhrase2} | ForEach-Object {
        # Add the file path and the line that contains the search term to the output array
        [PSCustomObject]@{
            FilePath = $_.Path
            Line = $_.Line
        }
    }

    # Combine existing data and new data
    $output = $existingData + $newData

    # Export the combined data to a CSV file with headers
    $output | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

} else {
    # Create an empty array to store the output
    $output = @()

    # Add the headers to the output file
    $output += [PSCustomObject]@{
        FilePath = "FilePath"
        Line = "Line"
    }

    # Search for .txt files that contain the search term
    Get-ChildItem -Path $searchPath -Recurse -Include "*.txt" |
        Select-String -Pattern $searchTerm |
        Where-Object {$_.Line -notmatch $excludePhrase1 -and $_.Line -notmatch $excludePhrase2} |
        ForEach-Object {
            # Add the file path and the line that contains the search term to the output array
            $output += [PSCustomObject]@{
                FilePath = $_.Path
                Line = $_.Line
            }
            # Export the output array to a CSV file with headers
            $output | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
        }
}
