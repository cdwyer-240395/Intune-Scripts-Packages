ZIP also included for easy download of all files for necessary package.

Installation:

An Intune package is provided for ease of deployment. Simply upload this package to Intune, and it will execute the pre-configured login script automatically upon user login.


Ensure the Install Command is: %windir%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "install.ps1"

For detection policy use the file UserPolicy.ps1 in "GroupPolicy\User\Scripts\Logon"


The login script included in the package performs the following actions


Powershell Window Suppression: 

- Prevents the Powershell window from appearing when the script is run, offering a seamless experience for users.


Shortcut Management: 

- Removes existing shortcuts from both the Public and Current User's Desktop.


User Interface Customizations:

- Activates Dark Mode for the taskbar (Note: This does not apply to File Explorer).
- Aligns the taskbar to the left side of the screen.
- Restores the traditional Windows 10 Right-Click Context Menu.
- Sets File Explorer to open to 'This PC' by default, instead of 'Quick Access'.
- System Clean-up: Deletes temporary files to free up space and improve system performance.


Functionality Tweaks:

- Assigns the 'Snipping Tool' function to the 'Print Screen' button for easy screen captures.
- Sets the Powershell Execution Policy to 'Restricted' after the script has completed to enhance security.


Customization:

To tailor the login script to your specific needs, you may edit the UserPolicy.ps1 file located in the GroupPolicy\User\Scripts\Logon directory. Ensure that the filename remains unchanged (UserPolicy.ps1) to maintain compatibility with the psscripts.ini reference.
