<#
.SYNOPSIS
This PowerShell script performs multiple configuration tasks on a Windows machine upon user login.

.DESCRIPTION
The script is organized into distinct modules for ease of maintenance and clarity. Each module serves a specific purpose, from user interface customization to system maintenance tasks.

.NOTES
Author: Chris Dwyer
Date: 27.02.2024
#>

# ---------------------------------- Hide Powershell Console ---------------------------------- #

# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console

# ---------------------------------- Desktop Customisations ---------------------------------- #
#---Remove Desktop Icons (Public Desktop)
$shell = New-Object -ComObject Shell.Application
$desktop = $shell.Namespace('C:\Users\Public\Desktop')
$recycleBin = $desktop.ParseName('Recycle Bin.lnk')
$desktopItems = $desktop.Items()
foreach ($desktopItem in $desktopItems) {
    if ($desktopItem -ne $recycleBin) {
        $desktopItem.InvokeVerb('Delete')
    }
}
#---Remove Desktop Icons (User Desktop)
Remove-Item -Path "C:\Users\$env:UserName\Desktop\*" -Recurse -Force
#---Create Chrome Shortcut
$shortcutPath = "$env:PUBLIC\Desktop\Google Chrome.lnk"
$targetPath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if (!(Test-Path $shortcutPath)) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.Save()
}
#---Create My Files
$shortcutPath = "$env:PUBLIC\Desktop\My Files.lnk"
$targetPath = "$env:windir\explorer.exe"

if (!(Test-Path $shortcutPath)) {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.IconLocation = "$targetPath,0" 
    $shortcut.Save()
}

# ---------------------------------- Personalisation ---------------------------------- #
#---Dark Mode
# Set SystemUsesLightTheme value to 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
# Set AppsUseLightTheme value to 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
# Forcefully stop the Explorer process
cmd /c taskkill /f /im explorer.exe
# Start the Explorer process again
Start-Process explorer.exe

#---Left Align Taskbar
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Al = "TaskbarAl" # Shift Start Menu Left
$value = "0"
New-ItemProperty -Path $registryPath -Name $Al -Value $value -PropertyType DWORD -Force -ErrorAction Ignore

#---Set Right-Click Context Menu
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -PropertyType "String"

# ---------------------------------- File Explorer Customisations ---------------------------------- #
#--- Open to this PC (Not QuickAccess)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1

# ---------------------------------- System Configurations ---------------------------------- #
#---Delete Temp files
# Define paths to common temporary file locations
$tempPaths = @(
    $env:TEMP,  # User's temp folder
    "C:\Windows\Temp"  # System temp folder
)
# Iterate over each path and remove the files
foreach ($path in $tempPaths) {
    Write-Host "Cleaning $path"
    try {
        # Get all files and folders in the path
        Get-ChildItem -Path $path -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error cleaning $path. Error: $_"
    }
}

#---Print Screen Snipping Tool
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 1 -Type DWORD

# ---------------------------------- End Module ---------------------------------- #
#---Set Execution Policy to Restricted for User after UserPolicy
Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
Stop-Process -Name powershell