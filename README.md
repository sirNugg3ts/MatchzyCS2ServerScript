
# MatchzyCS2ServerScript

A script that automatically prepapres a CS2 dedicated server with Matchzy installed and ready to use
This script does **NOT** install Metamod 

## Windows

This powershell script requires at least powershell 3.0 .
This script might in some cases need administrative permissions for the multiple I/O operations, therefor it is required when running the script.

There are 2 parameters for running the script:

| Parameter               | Mandatory?                                                |
| ----------------- | ---------------------------------------------------------------- |
| -steamcmdPath       | Yes |
| -cs2InstallDir       | No |

To use the script, simply open a Powershell terminal and type:
```ps
C:\path\to\script\MatchzyServer.ps1 -steamcmdPath "C:\path\to\steamcmd" -cs2InstallDir "C:\path\to\steamcmd\cs2-ds"
```
## Related Projects

 - [MatchZy Plugin](https://github.com/shobhit-pathak/MatchZy)
 - [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp/)



## License

[GNU AGPL v3](https://choosealicense.com/licenses/agpl-3.0/)

