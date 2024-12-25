# Configuration
$ContainerName = "ffhub-sql"
$DBName = "FfhubDB"
$BackupDir = "C:\Backups"  # Change to your desired backup directory
$BackupFileName = "${DBName}_$(Get-Date -Format 'yyyyMMddHHmmss').bak"
$BackupFilePath = Join-Path $BackupDir $BackupFileName
$ContainerBackupPath = "/var/opt/mssql/backups/$BackupFileName"
$SAPassword = "YourStrong@Password"  # Replace with your SA password

# Ensure the backup directory exists
if (!(Test-Path -Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

# Step 1: Run the backup command inside the Docker container
Write-Host "Running backup inside the container..."
docker exec $ContainerName /opt/mssql-tool18/bin/sqlcmd `
    -S localhost -U SA -P $SAPassword `
    -Q "BACKUP DATABASE [$DBName] TO DISK = N'$ContainerBackupPath' WITH NOFORMAT, INIT, NAME = '$DBName-full-backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

# Step 2: Copy the backup file from the container to the host
Write-Host "Copying backup file from container to host..."
docker cp "$ContainerName:$ContainerBackupPath" $BackupFilePath

# Step 3: Clean up the backup file inside the container (optional)
Write-Host "Cleaning up backup file inside the container..."
docker exec $ContainerName rm $ContainerBackupPath

# Final message
Write-Host "Backup completed successfully! Backup file saved to $BackupFilePath"