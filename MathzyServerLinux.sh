#!/bin/bash

cs2InstallDir=""

# Check if the user has provided a CS2 installation directory
if [ -z "$1" ]; then
    echo "Error: No CS2 installation directory provided."
    read -p "Please provide the CS2 installation directory: " cs2InstallDir
else
    cs2InstallDir="$1"
    #if the cs2 installation directory does end with a slash, remove it
    if [ "${cs2InstallDir: -1}" = "/" ]; then
        cs2InstallDir="${cs2InstallDir::-1}"
    fi
fi

#check if steamcmd is installed
if ! command -v steamcmd >/dev/null 2>&1; then
    echo "Error: steamcmd is not installed or could not be found, check your PATH." >&2
    exit 1
fi

#check if curl and jq are installed
if ! command -v curl &>/dev/null; then
    echo "Error: curl is not installed." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed." >&2
    exit 1
fi

if ! command -v unzip &>/dev/null; then
    echo "Error: unzip is not installed." >&2
    exit 1
fi

# Check if CS2 installation directory exists, if it does not, ask user if they wish to install cs2
if [ ! -d "$cs2InstallDir" ]; then
    echo "CS2 installation directory not found."
    read -p "CS2 installation directory not found. Would you like to install CS2? (y/n)" userInput
    if [ "$userInput" = "y" ] || [ "$userInput" = "Y" ]; then
        echo "Installing CS2..."
        echo "CS2 installation directory: $cs2InstallDir"
        # Create the CS2 installation directory
        mkdir -p "$cs2InstallDir"
        #run steamcmd with anonymous login and install CS2
        steamcmd +force_install_dir "$cs2InstallDir/" +login anonymous +app_update 730 validate +quit
        
        # Check if CS2 was installed successfully
        if [ $? -eq 0 ]; then
            echo "CS2 installed successfully."
        else
            echo "Error: CS2 installation failed."
            exit 2
        fi
    else
        echo "Exiting..."
        exit 3
    fi
else
    echo "CS2 installation directory found."
fi

# Update CS2 installation
echo "Updating CS2..."
steamcmd +login anonymous +force_install_dir "$cs2InstallDir/" +app_update 730 +quit

# Check if CS2 was updated successfully
if [ $? -eq 0 ]; then
    echo "CS2 updated successfully."
else
    echo "Error: CS2 update failed."
    exit 4
fi

# Download and copy metamod
echo "Downloading Metamod..."
curl -L -o "/tmp/metamod.zip" "https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1278-linux.tar.gz"
# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "Metamod downloaded successfully."
else
    echo "Error: Metamod download failed."
    exit 5
fi
#untar metamod and copy to cs2 installation directory
echo "Extracting Metamod..."
mkdir -p /tmp/metamod
tar -xzf "/tmp/metamod.zip" -C /tmp/metamod/
# Check if the extraction was successful
if [ $? -eq 0 ]; then
    echo "Metamod extracted successfully."
else
    echo "Error: Metamod extraction failed."
    exit 6
fi
#copy metamod to cs2 installation directory
echo "Copying Metamod files to CS2 installation directory..."
cp -r /tmp/metamod/addons "$cs2InstallDir/game/csgo/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "Metamod files copied successfully."
else
    echo "Error: Metamod files copy failed."
    exit 7
fi


# Define the URL of the latest release
latestReleaseUrl="https://api.github.com/repos/shobhit-pathak/MatchZy/releases/latest"

# Download the JSON object from latestReleaseUrl
json=$(curl -s "$latestReleaseUrl")

# Extract the browser_download_url field from the first item in the assets array
downloadUrl=$(echo "$json" | jq -r '.assets[0].browser_download_url')

# Download the file from downloadUrl
curl -L -o "/tmp/matchzy.zip" "$downloadUrl"
# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "MatchZy downloaded successfully."
else
    echo "Error: MatchZy download failed."
    exit 5
fi

# Extract the downloaded archive to a temporary folder
echo "Extracting MatchZy..."

unzip -q -o "/tmp/matchzy.zip" -d /tmp/matchzy
# Check if the extraction was successful
if [ $? -eq 0 ]; then
    echo "MatchZy extracted successfully."
else
    echo "Error: MatchZy extraction failed."
    exit 6
fi

# if the cs2 installation dir has an addons folder, ask if the user wants to create a backup
if [ -d "$cs2InstallDir/game/csgo/addons" ]; then
    echo "CS2 addons folder found."
    read -p "Would you like to create a backup of the CS2 addons folder? (y/n)" userInput
    if [ "$userInput" = "y" ] || [ "$userInput" = "Y" ]; then
        echo "Creating backup of CS2 addons folder..."
        # Create the backups directory if it does not exist
        mkdir -p "$cs2InstallDir/backups"
        # Create a backup of the CS2 addons and cfg folder with the current date and time
        backupName="backup_$(date +%Y-%m-%d_%H-%M-%S)"
        tar -cf "$cs2InstallDir/backups/$backupName.tar" "$cs2InstallDir/game/csgo/addons" "$cs2InstallDir/game/csgo/cfg" "$cs2InstallDir/game/csgo/gameinfo.gi"
        
        # Check if the backup was created successfully
        if [ $? -eq 0 ]; then
            echo "CS2 addons folder backup created successfully."
        else
            echo "Error: CS2 addons folder backup creation failed."
            exit 7
        fi
    fi
fi

# Copy the extracted files to the CS2 installation directory
echo "Copying MatchZy files to CS2 installation directory..."
cp -r /tmp/matchzy/* "$cs2InstallDir/game/csgo/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "MatchZy files copied successfully."
else
    echo "Error: MatchZy files copy failed."
    exit 8
fi

#update gameinfo.gi
echo -e "\e[43;30mUpdating gameinfo.gi...\e[0m"
echo -e "\e[43;30mCS2_INSTALL_DIR: $cs2InstallDir\e[0m"

TARGET_DIR="$cs2InstallDir/game/csgo"
GAMEINFO_FILE="${TARGET_DIR}/gameinfo.gi"

if [ ! -f "${GAMEINFO_FILE}" ]; then
    echo "Error: ${GAMEINFO_FILE} does not exist in the specified directory."
    exit 1
fi

NEW_ENTRY="			Game	csgo/addons/metamod"

if grep -Fxq "$NEW_ENTRY" "$GAMEINFO_FILE"; then
    echo "The entry '$NEW_ENTRY' already exists in ${GAMEINFO_FILE}. No changes were made."
else
    awk -v new_entry="$NEW_ENTRY" '
        BEGIN { found=0; }
        // {
            if (found) {
                print new_entry;
                found=0;
            }
            print;
        }
        /Game_LowViolence/ { found=1; }
    ' "$GAMEINFO_FILE" > "$GAMEINFO_FILE.tmp" && mv "$GAMEINFO_FILE.tmp" "$GAMEINFO_FILE"

    echo "The file ${GAMEINFO_FILE} has been modified successfully. '$NEW_ENTRY' has been added."
fi


echo -e "\e[43;30mgameinfo.gi updated successfully.\e[0m"
#terminate
echo -e "\e[43;30mTerminating...\e[0m"
exit 0
