# Define source and destination directories
$sourceDir = "C:\Xcalibur\data"
$destinationDir = "Y:\public\QE_plus_unifr\raw"
$logFile = "C:\Users\Q Exactive Plus\Desktop\QE_platform_utils\backup_log.txt"



# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logFile "$timestamp - $message"
}

# Function to perform the backup using robocopy
function Backup-Data {
    Log-Message "Starting backup for changed files"
    try {
        robocopy $sourceDir $destinationDir /MIR /XF desktop.ini /XD "System Volume Information" | Out-Null
        Log-Message "Backup completed"
    } catch {
        Log-Message "Error during backup: $_"
    }
}

# Create a FileSystemWatcher to monitor the source directory
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $sourceDir
$watcher.IncludeSubdirectories = $true
$watcher.Filter = "*.*"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, DirectoryName, LastWrite, LastAccess, CreationTime, Size'

# Define the actions to take on file changes
$onChanged = {
    param($source, $e)
    try {
        Log-Message "Change detected: $($e.ChangeType) - $($e.FullPath)"
        Backup-Data
    } catch {
        Log-Message "Error handling change event: $_"
    }
}

# Register event handlers for created, changed, and renamed events with error handling
try {
    Register-ObjectEvent -InputObject $watcher -EventName Created -Action $onChanged | Out-Null
    Log-Message "Registered Created event handler"
    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $onChanged | Out-Null
    Log-Message "Registered Changed event handler"
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $onChanged | Out-Null
    Log-Message "Registered Renamed event handler"
    Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $onChanged | Out-Null
    Log-Message "Registered Deleted event handler"
} catch {
    Log-Message "Error registering event handlers: $_"
}

# Start monitoring with logging to verify
try {
    $watcher.EnableRaisingEvents = $true
    Log-Message "Started monitoring $sourceDir"
} catch {
    Log-Message "Error starting monitoring: $_"
}

# Log startup
Log-Message "Script started and watching $sourceDir for changes..."

# Keep the script running
while ($true) {
    Start-Sleep -Seconds 10
}
