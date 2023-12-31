

# MatchzyCS2ServerScript

A script that automatically prepares a CS2 dedicated server with Matchzy installed and ready to use.
On both scripts, **steamcmd must already be installed**. You can find information on how to install it [here](https://developer.valvesoftware.com/wiki/SteamCMD).

## Windows

This powershell script requires at least powershell 3.0 .
This script might in some cases need administrative permissions for the multiple I/O operations, therefor it is required when running the script.

There are 2 parameters for running the script:

| Parameter               | Mandatory?                                                |
| ----------------- | ---------------------------------------------------------------- |
| -steamcmdPath       | Yes |
| -cs2InstallDir       | No |
 ### Usage
To use the script, simply open a Powershell terminal and type:
```ps
C:\path\to\script\MatchzyServer.ps1 -steamcmdPath "C:\path\to\steamcmd" -cs2InstallDir "C:\path\to\steamcmd\cs2-ds"
```

## Linux

This bash script has the following dependencies:

 - steamcmd
 - curl
 - jq
 - unzip

When using the script, you have to provide the path for the CS2 Dedicated Server folder. This can be either sent as an argument of the script or it will be requested when starting the script. If the folder does not exist, the script will try to create it.
 
 ### Usage
To use the script, open a terminal and type:
```sh
/path/to/script/MatchzyServerLinux.sh "/path/to/cs2-ds"
```


## Related Projects

 - [MatchZy Plugin](https://github.com/shobhit-pathak/MatchZy)
 - [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp/)



## License

[GNU AGPL v3](https://choosealicense.com/licenses/agpl-3.0/)



## License

[GNU AGPL v3](https://choosealicense.com/licenses/agpl-3.0/)

