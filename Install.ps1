# Define the source and destination folders
$sourceFolder = Join-Path -Path $PSScriptRoot -ChildPath "GroupPolicy"
$destinationFolder = "$env:windir\System32\GroupPolicy"

# Take ownership of the destination folder
takeown /f $destinationFolder /r /d y

# Set initial full control permissions for 'Everyone', 'Administrators', and 'SYSTEM'
$acl = Get-Acl $destinationFolder
$permissionRules = @(
    New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"),
    New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"),
    New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
)

foreach ($rule in $permissionRules) {
    $acl.SetAccessRule($rule)
}
Set-Acl $destinationFolder $acl

# Mirror the directory structure and files from source to destination
# Added /IS to include same files, forcefully replacing them
robocopy $sourceFolder $destinationFolder /MIR /COPYALL /IS /R:5 /W:1

# Modify permissions to Read and Execute for 'Everyone' after copying
$readExecuteRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl = Get-Acl $destinationFolder
$acl.SetAccessRule($readExecuteRule)
Set-Acl $destinationFolder $acl

# Propagate the final permissions to all sub-items
Get-ChildItem $destinationFolder -Recurse | ForEach-Object {
    Set-Acl $_.FullName $acl
}
