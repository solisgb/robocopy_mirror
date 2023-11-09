Clear-Host

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

Write-Host "`nSaved directories to be copied as mirrors"
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
    if ($exclude_dirs.Count -gt 0){
        Write-Host "Excluded directories"
        foreach ($item in $exclude_dirs) {
             Write-Host $item
        }
    }
} else {
    Write-Host "`nKey '$selectedKey' not found in the JSON file."
    exit
}

# Test if the paths exist and and are directories
$directories = @($source, $destination)
if ($exclude_dirs.Count -gt 0) {
    $directories = @($source, $destination) + $exclude_dirs
}
$ifaults = 0
foreach ($directory in $directories) {
    if (Test-Path -Path $directory -PathType Container) {
        #Write-Host "Directory '$directory' exists and is a directory."
    } elseif (Test-Path -Path $directory) {
        Write-Host "Path '$directory' exists but is not a directory."
        $ifaults += 1
    } else {
        Write-Host "Path '$directory' does not exist."
        $ifaults += 1
    }
}

if ($ifaults -gt 0){
    "`nRemove non-existent directories from $jsonfile_name"
    exit
}


if ($exclude_dirs.Count -gt 0){
    $xd_opt = @("/XD", $exclude_dirs)
} else {
    $xd_opt = ""
}


# Display options
Write-Host "`nWrite the desired action"
Write-Host "1. Preview (doesn't mirror the source directory)."
Write-Host "2. Mirror the source directory."
Write-Host "Other. Quit the script."
# Ask to continue with the execution of the script
$action = Read-Host -Prompt "`nPress the selected option"

$base_options = "/MIR", "/R:1", "/W:1", "/NDL"

if ($action -eq "1") {
    robocopy $source $destination $base_options $xd_opt /L /LOG:$logFilePath
}
elseif ($action -eq "2") {
    robocopy $source $destination $base_options $xd_opt /LOG:$logFilePath
}
else {
    Write-Host "`nEjecución finalizada por el usuario."
    exit
}
