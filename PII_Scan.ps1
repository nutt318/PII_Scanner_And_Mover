# Created By: Jake Nutt & ChatGPT
# Scans files for PII (SSN & CreditCard #'s) and logs findings to a results file.
# Only works on flat files, for example the following will NOT work (.pdf, jpg, .png, .docx, .xlsx, .pptx, etc.)

# Setup source directories to scan, extensions to look in and the results file, keep the '\\?\' before the directory to enable long file paths
# Do not scan Accounting share, it will contain company confidential items and is expected
$sourceDirectories = @(
        #"\\?\E:\Accounting",
        "\\?\X:\Contracts",
        "\\?\X:\Clients",
        "\\?\X:\Development",
        "\\?\X:\Marketing",
        "\\?\X:\Sales",
        "\\?\X:\Software",
        "\\?\X:\Travel"
)
$searchExtensions = @("*.txt", "*.doc", "*.xls", "*.csv")
$logFile = "E:\Scripts\PII_Results.txt"

# Define regular expressions to search for PII data
$ssnRegex = "\b\d{3}-\d{2}-\d{4}\b"
$creditCardRegex = "\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})\b"

# Initialize variables for progress bar
$totalFiles = 0
$processedFiles = 0

# Count total number of files to search
foreach ($directory in $sourceDirectories) {
    $totalFiles += @(Get-ChildItem -Path $directory -Recurse -Include $searchExtensions).Count
}

# Iterate through each file and search for PII data
foreach ($directory in $sourceDirectories) {
    Get-ChildItem -Path $directory -Recurse -Include $searchExtensions | ForEach-Object {
        $matchCount = 0

        # Search for PII data in the file, StreamReader reads one line of the file at a time to eliminate memory constraints
        $streamReader = [System.IO.StreamReader]::new($_.FullName)
        while (($line = $streamReader.ReadLine()) -ne $null) {
            # Search for SSNs
            $matchCount += ([regex]::Matches($line, $ssnRegex)).Count

            # Search for credit card numbers
            $matchCount += ([regex]::Matches($line, $creditCardRegex)).Count
        }
        $streamReader.Close()

        # Log results to file if PII data is found
        if ($matchCount -gt 0) {
            $outputPath = $_.FullName
            # Remove the \\?\ prefix from the path for logging
            $output = $outputPath.Replace("\\?\","")
            Add-Content -Path $logFile -Value $output
        }

        # Update progress bar
        $processedFiles++
        $percentComplete = $processedFiles / $totalFiles * 100
        $status = "{0}/{1} files processed" -f $processedFiles, $totalFiles
        Write-Progress -Activity "Searching for PII data" -Status $status -PercentComplete $percentComplete
    }
}


#Review the findings file and then run the mover
Write-Output "Scanning is finished, please review the PII_Results.txt document. If findings are valid run the PII_Mover.ps1 script";
