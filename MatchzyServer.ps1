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
                #Wait for the user to press a key before closing the window
                Read-Host -Prompt "Press Enter to exit"
                exit
            }
        }
        else {
            Write-Host "CS2 installation directory not found. Exiting..." -BackgroundColor Red -ForegroundColor White
            #Wait for the user to press a key before closing the window
            Read-Host -Prompt "Press Enter to exit"
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
            #Wait for the user to press a key before closing the window
            Read-Host -Prompt "Press Enter to exit"
            exit
        }
    }

    # Define the path of the temporary directory
    $TEMP_DIR = "$env:TEMP\MatchZy"

    # Create the temporary directory if it doesn't exist
    if (-not (Test-Path -Path $TEMP_DIR)) {
        New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    }
    
    # Delete all files in the temporary directory
    Get-ChildItem -Path $TEMP_DIR -Recurse | Remove-Item -Force -Recurse

    ## Getting the resources

    #Metamod

    $METAMOD_URL = "https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1277-windows.zip" #while metamod is in dev builds, this will have to be updated manually
    $metamodZipPath = "$TEMP_DIR\mmsource.zip"
    $metamodExtractPath = "$TEMP_DIR\mmsource"

    # extract the metamod zip file to the csgo folder
    Write-Host "Downloading Metamod..." -BackgroundColor Yellow -ForegroundColor Black
    Write-Host $METAMOD_URL

    # Download the Metamod zip file to the temporary directory, extract the content and sent to the cs2 folder
    try {
        Invoke-WebRequest -Uri $METAMOD_URL -OutFile $metamodZipPath
        Expand-Archive -Path $metamodZipPath -DestinationPath $metamodExtractPath
        Copy-Item -Path "$metamodExtractPath\*" -Destination "$cs2InstallDir\game\csgo" -Recurse -Force
    }
    catch {
        Write-Error "Error: $_" 
        Write-Host "There was an error with your installation when downloading Metamod. Please try again." -BackgroundColor Black -ForegroundColor White
        #Wait for the user to press a key before closing the window
        Read-Host -Prompt "Press Enter to exit"
        exit
    }

    try {
        #CSSHARP
        $CSSHARP_API_URL = "https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"
        $asset = Invoke-RestMethod -Uri $CSSHARP_API_URL | Select-Object -ExpandProperty assets | Select-Object -Index 3 #Last release is the windows build

        # Send a GET request to the GitHub API and parse the JSON response to extract the download URL from the 4th asset
        $CSSHARP_RELEASE_URL = $asset.browser_download_url

        # Download the latest cssharp release and save it to the temporary directory
        Write-Host "Downloading the CounterStrikeSharp latest release from GitHub..." -BackgroundColor Yellow -ForegroundColor Black
        Write-Host $CSSHARP_RELEASE_URL

        # Download the latest release and save it to the temporary directory
        Invoke-WebRequest -Uri $CSSHARP_RELEASE_URL -OutFile "$TEMP_DIR\CSSHarp.zip"

        # Extract the downloaded file 
        Expand-Archive -Path "$TEMP_DIR\CSSHarp.zip" -DestinationPath "$TEMP_DIR\extracted" -Force
    }
    catch {
        Write-Error "Error: $_"
        Write-Host "There was an error with your installation when downloading CounterStrikeSharp. Please try again." -BackgroundColor Black -ForegroundColor White
        #Wait for the user to press a key before closing the window
        Read-Host -Prompt "Press Enter to exit"
        exit
    }

    try {
        #Matchzy

        # Define the URL of the latest release
        $API_URL = "https://api.github.com/repos/shobhit-pathak/MatchZy/releases/latest"
        # Send a GET request to the GitHub API and parse the JSON response to extract the download URL
        $RELEASE_URL = (Invoke-RestMethod -Uri $API_URL | Select-Object -ExpandProperty assets | Select-Object -Index 1 )

        Write-Host "Downloading the Matchzy latest release from GitHub..." -BackgroundColor Yellow -ForegroundColor Black
        Write-Host $RELEASE_URL.browser_download_url

        # Download the latest release and save it to the temporary directory
        Invoke-WebRequest -Uri $RELEASE_URL.browser_download_url -OutFile "$TEMP_DIR\Matchzy.zip"

        # Extract the downloaded file 
        Expand-Archive -Path "$TEMP_DIR\MatchZy.zip" -DestinationPath "$TEMP_DIR\extracted" -Force
    }
    catch {
        Write-Error "Error: $_"
        Write-Host "There was an error with your installation when downloading Matchzy. Please try again." -BackgroundColor Black -ForegroundColor White
        #Wait for the user to press a key before closing the window
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
  
    #Open explorer to the temporary directory
    #Invoke-Item -Path $TEMP_DIR

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

    # Check if the csgo/addons/metamod line is already present in the gameinfo.gi file
    $FILE_PATH = "$cs2InstallDir\game\csgo\gameinfo.gi"
    $LINE_TO_CHECK = "csgo/addons/metamod"

    $lineExists = Get-Content -Path $FILE_PATH | Select-String -Pattern $LINE_TO_CHECK

    try {
        if ($lineExists) {
            Write-Host "The line 'Game csgo/addons/metamod' is already present in the gameinfo.gi file."
        }
        else {
            Write-Host "The line 'Game csgo/addons/metamod' is not present in the gameinfo.gi file."
            Write-Host "Updating gameinfo.gi..." -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "CS2_INSTALL_DIR: $cs2InstallDir" -BackgroundColor Yellow -ForegroundColor Black
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
        }

        # Copy the downloaded files to the CS2 installation directory
        Copy-Item -Path "$TEMP_DIR\extracted\*" -Destination "$cs2InstallDir\game\csgo\" -Recurse -Force
    }
    catch {
        Write-Error "Error: $_" 
        Write-Host "There was an error updating the gameinfo.gi file or copying the downloaded files. Please try again." -BackgroundColor Black -ForegroundColor White
        #Wait for the user to press a key before closing the window
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
  
    Write-Host "CS2 with MatchZy update completed!" -BackgroundColor Green -ForegroundColor Black
    Write-Host "Your configurations files might have been overwritten. Please check the backup folder if you wish to restore them." -BackgroundColor Yellow -ForegroundColor Black
  
    #Open explorer to the CS2 installation directory
    Invoke-Item -Path $cs2InstallDir

}
end {
    #Wait for the user to press a key before closing the window
    Read-Host -Prompt "Press Enter to exit"
}
