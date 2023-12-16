[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)][String]$steamcmdPath,
    [Parameter(Mandatory = $false)][String]$cs2InstallDir = "$steamcmdPath\cs2-ds"
)
process {
    # Check if the script is running with administrative privileges
    if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File", "`"$($MyInvocation.MyCommand.Path)`"", "-steamcmdPath", "`"$steamcmdPath`"", "-cs2InstallDir", "`"$cs2InstallDir`""
        exit

    }
    $Host.UI.RawUI.BackgroundColor = "Black"
    Clear-Host
    # Check if SteamCMD is installed
    if (!(Test-Path "$steamcmdPath\steamcmd.exe")) {
        Write-Host "Error: SteamCMD not found. Please provide the correct path in the script." -BackgroundColor Red
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
  
    # Check if CS2 installation directory exists, if it does not, ask user if they wish to install cs2
  
    if (!(Test-Path $cs2InstallDir)) {
        Write-Host "CS2 installation directory not found." -BackgroundColor Yellow -ForegroundColor Black
        $userInput = Read-Host "CS2 installation directory not found. Would you like to install CS2? (y/n)"
        if ($userInput -eq "y" -or $userInput -eq "Y") {
            Write-Host "Installing CS2..." -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "CS2 installation directory: $cs2InstallDir"
            # Create the CS2 installation directory
            New-Item -ItemType Directory -Path $cs2InstallDir | Out-Null
            # Run SteamCMD to install and validate CS2
            & "$steamcmdPath\steamcmd.exe" +force_install_dir "$cs2InstallDir" +login anonymous +app_update 740 +validate +quit
            # Check the installation result
            if ($LASTEXITCODE -eq 0) {
                Write-Host "CS2 has been successfully installed." -BackgroundColor Green
            }
            else {
                Write-Host "Error: CS2 installation failed." -BackgroundColor Red -ForegroundColor White
                exit
            }
        }
        else {
            Write-Host "CS2 installation directory not found. Exiting..." -BackgroundColor Red -ForegroundColor White
            exit
        }
    }
    else {
        Write-Host "CS2 installation directory: $cs2InstallDir" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "Updating CS2..." -BackgroundColor Yellow -ForegroundColor Black
        # Run SteamCMD to update CS2
        & "$steamcmdPath\steamcmd.exe" +force_install_dir "$cs2InstallDir" +login anonymous +app_update 730  +quit
        # Check the update result
        if ($LASTEXITCODE -eq 0) {
            Write-Host "CS2 has been successfully updated." -BackgroundColor Green
        }
        else {
            Write-Host "Error: CS2 update failed." -BackgroundColor Red -ForegroundColor White
            exit
        }
    }

  
    # Define the URL of the latest release
    $API_URL = "https://api.github.com/repos/shobhit-pathak/MatchZy/releases/latest"

    #Define the URL of the latest cssharp release
    $CSSHARP_API_URL = "https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"

    $asset = Invoke-RestMethod -Uri $CSSHARP_API_URL | Select-Object -ExpandProperty assets | Select-Object -Index 3

    # Send a GET request to the GitHub API and parse the JSON response to extract the download URL from the 4th asset
    $CSSHARP_RELEASE_URL = $asset.browser_download_url  
    # Send a GET request to the GitHub API and parse the JSON response to extract the download URL
    $RELEASE_URL = (Invoke-RestMethod -Uri $API_URL | Select-Object -ExpandProperty assets | Select-Object -First 1 -ExpandProperty browser_download_url)
  
    # Download the latest cssharp release and save it to the temporary directory

    Write-Host "Downloading the CounterStrikeSharp latest release from GitHub..." -BackgroundColor Yellow -ForegroundColor Black
    Write-Host $CSSHARP_RELEASE_URL

    # Define the path of the temporary directory
    $TEMP_DIR = "$env:TEMP\MatchZy"

    # Create the temporary directory if it doesn't exist
    if (-not (Test-Path -Path $TEMP_DIR)) {
        New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    }

    # Delete all files in the temporary directory
    Get-ChildItem -Path $TEMP_DIR -Recurse | Remove-Item -Force -Recurse

    
  
  
    # Download the latest release and save it to the temporary directory
    Invoke-WebRequest -Uri $CSSHARP_RELEASE_URL -OutFile "$TEMP_DIR\CSSHarp.zip"

    # Extract the downloaded file 
    Expand-Archive -Path "$TEMP_DIR\CSSHarp.zip" -DestinationPath "$TEMP_DIR\extracted" -Force

    Write-Host "Downloading the Matchzy latest release from GitHub..." -BackgroundColor Yellow -ForegroundColor Black
    Write-Host $RELEASE_URL
  

    # Download the latest release and save it to the temporary directory
    Invoke-WebRequest -Uri $RELEASE_URL -OutFile "$TEMP_DIR\Matchzy.zip"
   
  
  
    # Extract the downloaded file 
    Expand-Archive -Path "$TEMP_DIR\MatchZy.zip" -DestinationPath "$TEMP_DIR\extracted" -Force
  
    #Open explorer to the temporary directory
    Invoke-Item -Path $TEMP_DIR

    #If the folder  "$cs2InstallDir\game\csgo\addons" exists, ask if the user wishes to create the backup
    if (Test-Path "$cs2InstallDir\game\csgo\addons" ) {
        Write-Host "CS2 addons folder found." -BackgroundColor Yellow -ForegroundColor Black
        $userInput = Read-Host "CS2 addons folder found. Would you like to create a backup of your addons and configs? (y/n)"
        if ($userInput -eq "y" -or $userInput -eq "Y") {
            #Create backup folder with gameinfo.gi and the addons and cfg folders
            Write-Host "Creating backup folder..." -BackgroundColor Yellow -ForegroundColor Black
            $BACKUP_DIR = "$cs2InstallDir\backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
  
            # Create the backup directory if it doesn't exist
            if (-not (Test-Path -Path $BACKUP_DIR)) {
                New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
            }
  
            # Copy the gameinfo.gi file to the backup directory
            Copy-Item -Path "$cs2InstallDir\game\csgo\gameinfo.gi" -Destination $BACKUP_DIR -Force
  
            # Copy the addons and cfg folders to the backup directory
            Copy-Item -Path "$cs2InstallDir\game\csgo\addons" -Destination $BACKUP_DIR -Recurse -Force
            Copy-Item -Path "$cs2InstallDir\game\csgo\cfg" -Destination $BACKUP_DIR -Recurse -Force
  
            Write-Host "Backup completed. The backup folder is located at $BACKUP_DIR" -BackgroundColor Green
  
        }
        else {
            Write-Host "Backup not created." -BackgroundColor Yellow -ForegroundColor Black
        }
    }
  
    # Update gameinfo.gi
  
    Write-Host "Updating gameinfo.gi..." -BackgroundColor Yellow -ForegroundColor Black
    Write-Host "CS2_INSTALL_DIR: $cs2InstallDir" -BackgroundColor Yellow -ForegroundColor Black
    $FILE_PATH = "$cs2InstallDir\game\csgo\gameinfo.gi"
    $NEW_LINE = "			Game	csgo/addons/metamod"
    $BEFORE_LINE = "			Game	csgo"
  
  (Get-Content -Path $FILE_PATH) | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq $BEFORE_LINE) {
            $NEW_LINE
        }
        $line
    } | Set-Content -Path "$FILE_PATH.new"
  
    Move-Item -Path "$FILE_PATH.new" -Destination $FILE_PATH -Force
  
    # Copy the downloaded files to the CS2 installation directory
    Copy-Item -Path "$TEMP_DIR\extracted\*" -Destination "$cs2InstallDir\game\csgo\" -Recurse -Force
  
    Write-Host "CS2 with MatchZy update completed!" -BackgroundColor Green -ForegroundColor Black
  
    #Open explorer to the CS2 installation directory
    Invoke-Item -Path $cs2InstallDir

}
end {
    #Wait for the user to press a key before closing the window
    Read-Host -Prompt "Press Enter to exit"
}
