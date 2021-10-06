# This script is used to wait for programs that don't block the command line.

param (
    [Parameter(Mandatory=$True)][string]$launchcmd,    # Command to launch game
    [Parameter(Mandatory=$True)][string[]]$game        # Game(s) to watch
)

$scriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition

function Wait-ProcessChildren($id) {
    $child = Get-CimInstance -ClassName win32_process | where {$_.ParentProcessId -In $id}
    if ($child) {
        Write-Host 'Child found'
        Wait-Process -Id $child.handle
        Wait-ProcessChildren $child.handle
    }
}

#Get existing steamwebhelpers
$oldpids = Get-Process $game

# Start Game
Start-Process $launchcmd

#Wait for process
Start-Sleep -Seconds 2

$gameStarted = $False

Write-Host 'Waiting for game to start'

# Get current system date
$currentDate = Get-Date
Do {
    $gameProcess = Get-Process $game -ErrorAction SilentlyContinue | ?{$oldpids.id -notcontains $_.id}

    If (!($gameProcess)) {
        # Timeout after 30 minutes
		If ($currentDate.AddMinutes(30) -lt (Get-Date)) {
			Write-Host 'Game process could not be found'
			exit
		}
        Start-Sleep -Seconds 1
    } Else {
        Write-Host 'Game started!'
        $gameStarted = $true
    }
} Until ($gameStarted)

# Wait until game closes
Wait-Process -InputObject $gameProcess

# Wait until child processes close
Wait-ProcessChildren $gameProcess.Id

Write-Host 'Game closed'