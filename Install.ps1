# Define the source and destination folders
$sourceFolder = Join-Path -Path $PSScriptRoot -ChildPath "GroupPolicy"
$destinationFolder = "$env:windir\System32\GroupPolicy"

# Take ownership and set initial full control permissions for 'Everyone'
Takeown /f $destinationFolder /r /d y
Icacls $destinationFolder /grant Everyone:(OI)(CI)F /t

# Mirror the directory structure and files from source to destination
Robocopy $sourceFolder $destinationFolder /MIR /COPYALL /IS /R:5 /W:1

# Remove 'Everyone' full control permissions
Icacls $destinationFolder /remove Everyone /t

# Remove 'Users' full control permissions and set Read & Execute permissions
Icacls $destinationFolder /remove "Users" /t
$usersReadExecutePermission = "Users:(OI)(CI)RX"
Icacls $destinationFolder /grant $usersReadExecutePermission

# Set full control permissions for 'Administrators' and 'SYSTEM'
$adminsFullControlPermission = "Administrators:(OI)(CI)F"
$systemFullControlPermission = "SYSTEM:(OI)(CI)F"
Icacls $destinationFolder /grant $adminsFullControlPermission
Icacls $destinationFolder /grant $systemFullControlPermission

# Set the owner to 'SYSTEM'
$systemSecurityIdentifier = New-Object System.Security.Principal.NTAccount("SYSTEM")
Icacls $destinationFolder /setowner $systemSecurityIdentifier /t
