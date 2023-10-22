Clear-Host
Write-Host "`nProjects to mirror directories"

#configuration file
$jsonfile_name = "robocopy_mirror_projects.json"
$logFilePath = "robocopy_log.txt"

# Read the JSON file
try {
    $jsonContent = Get-Content -Path $jsonfile_name | ConvertFrom-Json
}
catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)"
    exit
}

# Iterate through the keys and display source and destination attributes
foreach ($key in $jsonContent.PSObject.Properties) {
    Write-Host "Key: $($key.Name) ,  Source: $($key.Value.source) ,  Destination: $($key.Value.destination)"
    Write-Host "=============================="
}

# Prompt the user to enter the key or exit
$selectedKey = Read-Host "`nEnter the project key or 'exit' to quit"

# Check if the user wants to exit
if ($selectedKey -eq "exit") {
    Write-Host "`nExiting the script."
    exit
}

Clear-Host

# Read the JSON file again
$jsonContent = Get-Content -Path $jsonfile_name | ConvertFrom-Json

# Check if the specified key exists in the JSON file
if ($jsonContent.PSObject.Properties[$selectedKey]) {
    $selectedItem = $jsonContent.$selectedKey

    # Initialize variables
    $source = $selectedItem.source
    $destination = $selectedItem.destination
    $exclude_dirs = $selectedItem.exclude_dirs

    # Display the values
    Write-Host "`nSelected project"
    Write-Host "Key: $selectedKey"
    Write-Host "Source: $source"
    Write-Host "Destination: $destination"
    Write-Host "Exclude Directories: $($exclude_dirs -join ', ')"
} else {
    Write-Host "`nKey '$selectedKey' not found in the JSON file."
    exit
}

# Test if the paths exist and and are directories
$directories = @($source, $destination)
if ($excludeDirs.Count -gt 0) {
    $directories = @($source, $destination) + $directories
}
$ifaults = 0
Write-Host "`nTest of directories."
foreach ($dir1 in $directories) {
    if ( -not (Test-Path -Path $dir -PathType Container)) {
        Write-Host "The directory does not exists: $dir1"
        $ifaults += 1
    }
}
if ($ifaults -gt 0) {
    Write-Host "`n$ifaults directories doesn't exist"
    exit
} else {
    Write-Host "`nAll directories exist."
}

Clear-Host

# Create the exclude parameters for each directory
$excludeParams = $excludeDirs | ForEach-Object { "/XD", $_ }


# Display options
Write-Host "`nSource directory: $source"
Write-Host "Destination directory: $destination"
Write-Host "Options"
Write-Host "1. Files are to be listed only (not actions)."
Write-Host "2. Mirror using robocopy."
Write-Host "Other. Quit the script."
# Ask to continue with the execution of the script
$action = Read-Host -Prompt "`nPress the selected option"

Clear-Host

if ($action -eq "1") {
    robocopy $source $destination /S /MIR /B /SEC /FFT /Z /XA:H /R:0 /TEE /L @excludeParams /LOG:$logFilePath
}
elseif ($action -eq "2") {
    robocopy $source $destination /S /MIR /B /SEC /FFT /Z /XA:H /R:1 /W:1 /NP /TEE @excludeParams /LOG:$logFilePath
}
else {
    Write-Host "`nEjecución finalizada por el usuario."
    exit
}
