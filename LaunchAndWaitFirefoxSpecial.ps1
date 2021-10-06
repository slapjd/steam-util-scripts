# This script is used to wait for programs that don't block the command line
# and also don't create new processes

param (
    [Parameter(Mandatory=$True)][string]$launchcmd,    # Command to launch game
    [Parameter(Mandatory=$True)][string]$game,         # Game(s) to watch
    [Parameter(Mandatory=$False)][string]$launchargs   # Arguments
)

Import-Module 'C:\Users\slapjd\Downloads\Executable\DockEngager\Get-ChildWindow.ps1'

$scriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition

function Wait-ProcessChildren($id) {
    $child = Get-CimInstance -ClassName win32_process | where {$_.ParentProcessId -In $id}
    if ($child) {
        Write-Host 'Child found'
        Wait-Process -Id $child.handle
        Wait-ProcessChildren $child.handle
    }
}

# Start Game
Start-Process $launchcmd -ArgumentList $launchargs

$gameStarted = $False

Write-Host 'Waiting for game to start'

# Get current system date
$currentDate = Get-Date
#Get existing window handle
$windowhandle = (Get-Process $game -ErrorAction SilentlyContinue | ?{$_.MainWindowHandle -gt 0}).MainWindowHandle
Do {
    $gameProcess = Get-Process $game -ErrorAction SilentlyContinue | ?{$_.MainWindowHandle -gt 0}

    # Wait for window handle to change (takes a little time)
    If ($gameProcess.MainWindowHandle -eq $windowhandle) {
        # Timeout after 30 minutes
		If ($currentDate.AddMinutes(30) -lt (Get-Date)) {
			Write-Host 'Game process could not be found'
			exit
		}
        Start-Sleep -Seconds 1
    } Else {
        Write-Host 'Game started!'
        #New window started
        $windowhandle = $gameProcess.MainWindowHandle
        $gameStarted = $true
    }
} Until ($gameStarted)

# Wait until game closes
Do {
    Start-Sleep -Seconds 1
    $gameProcess = Get-Process $game -ErrorAction SilentlyContinue | ?{$_.MainWindowHandle -gt 0}
} Until (!($gameProcess.MainWindowHandle -eq $windowhandle) -and (Get-ChildWindow $gameProcess.MainWindowHandle))

Write-Host 'Game closed'

#Kill glosc
Stop-Process -Name SteamTarget