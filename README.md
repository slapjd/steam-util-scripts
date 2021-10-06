# steam-util-scripts
Utility scripts for launching programs (namely firefox) in steam written in PowerShell

## Usage
Set a steam shortcut to pwsh (PowerShell 7) and have it run the desired script. The script itself will take 3 arguments:

- `-game`: Process name to monitor
- `-launchcmd`: Executable to run
- `- launchargs`: Command line arguments to give executable

## Example
Personal example for youtube using GloSC for steam overlay:

Target: `"C:\Program Files\PowerShell\7\pwsh.exe"`

Start In: `"C:/Program Files (x86)/GloSC"`

Launch Options: `-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "& <PathToScript>/LaunchAndWaitFirefoxSpecial.ps1 -launchcmd 'C:/Program Files (x86)/GloSC/SteamTarget.exe' -LaunchArgs './targets/Youtube.ini' -game 'Firefox'"`