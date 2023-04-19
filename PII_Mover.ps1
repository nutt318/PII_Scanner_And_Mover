# Created By: Jake Nutt & ChatGPT
# Moves files listed within a input file and moves them into a new directory with the same folder structure.

# Import the AlphaFS library
Add-Type -Path "C:\Program Files\PackageManagement\ProviderAssemblies\psalphafs.2.0.0.1\lib\AlphaFS.dll"

# Specify the input file path and the destination folder
$inputFilePath = "X:\PII_Results.txt"
$destFolder = "X:\Archived"

# Get the list of files from the input file
$files = Get-Content $inputFilePath | Get-ChildItem -Force

# Loop through each file and move it to the destination folder
foreach ($file in $files) {
    # Check if the file exists
    if ($file.Exists) {
        # Get the relative path of the file with respect to the input file
        $relativePath = $file.FullName | Resolve-Path -Relative | ForEach-Object { $_.Replace("..\","") }

        # Combine the relative path with the destination folder path to get the new path
        $newPath = Join-Path $destFolder $relativePath

        # Create the destination folder if it doesn't exist
        $destFolderPath = Split-Path $newPath
        if (!(Test-Path $destFolderPath)) {
            New-Item -ItemType Directory -Path $destFolderPath | Out-Null
        }

        # Move the file to the destination folder
        Move-Item $file.FullName $newPath
		Write-Output = $file.FullName $newPath
    }
    else {
        Write-Warning "File not found: $($file.FullName)"
    }
}
