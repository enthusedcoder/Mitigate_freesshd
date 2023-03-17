#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** Start added by AutoIt3Wrapper ***
#include <AutoItConstants.au3>
; *** End added by AutoIt3Wrapper ***
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#include <Zip.au3>
#include <Services.au3>
#include <windows firewall.au3>
#include <Array.au3>
; Script Start - Add your code below here
If @OSArch = "X64" Then
	$reg = RegRead ( "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\70DBC326-7505-4913-A0C1-C6BD87C1859D_is1", "QuietUninstallString" )
Else
	$reg = RegRead ( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\70DBC326-7505-4913-A0C1-C6BD87C1859D_is1", "QuietUninstallString" )
EndIf
If @error Then
	ConsoleWrite ( "freesshd not installed" & @CRLF )
Else
	$proc = Run ( $reg, @SystemDir, @SW_SHOW, $STDOUT_CHILD )
	ProcessWaitClose ( $proc )
EndIf
$drives = DriveGetDrive ( $DT_FIXED )
If @OSArch = "X64" Then
	FileInstall ( "C:\Users\whiggs\Downloads\OpenSSH-Win64.zip", @ScriptDir & "\openssh.zip" )
	_Zip_UnzipAll ( @ScriptDir & "\openssh.zip", $drives[$drives[0]] & "\Program Files (x86)" )
	DirMove ( $drives[$drives[0]] & "\Program Files (x86)\OpenSSH-Win64", $drives[$drives[0]] & "\Program Files (x86)\OpenSSH" )
	$folder = $drives[$drives[0]] & "\Program Files (x86)\OpenSSH"
Else
	FileInstall ( "C:\Users\whiggs\Downloads\OpenSSH-Win32.zip", @ScriptDir & "\openssh.zip" )
	_Zip_UnzipAll ( @ScriptDir & "\openssh.zip", $drives[$drives[0]] & "\Program Files" )
	DirMove ( $drives[$drives[0]] & "\Program Files\OpenSSH-Win32", $drives[$drives[0]] & "\Program Files\OpenSSH" )
	$folder = $drives[$drives[0]] & "\Program Files\OpenSSH"
EndIf

ShellExecuteWait ( "powershell.exe", '-executionpolicy unrestricted -command "Set-Executionpolicy unrestricted -force -confirm:$false"', @SystemDir )
ShellExecuteWait ( "powershell.exe", '-executionpolicy unrestricted -file "install-sshd.ps1"', $folder )
Sleep ( 1500 )
_Service_SetStartType ( "ssh-agent", $SERVICE_AUTO_START )
_Service_SetStartType ( "sshd", $SERVICE_AUTO_START )
Sleep ( 500 )
_Service_Start ( "ssh-agent" )
_Service_Start ( "sshd" )
ShellExecute ( "powershell.exe", '-executionpolicy unrestricted -file "FixHostFilePermissions.ps1"', $folder )

$win = WinWait ( "Administrator: Windows PowerShell" )
WinActivate ( $win )
WinWaitActive ( $win )
SendKeepActive ( "Administrator: Windows PowerShell" )
Do
	Send ( "a" & "{ENTER}", 0 )
Until Not WinExists ( "Administrator: Windows PowerShell" )
SendKeepActive ("")
Sleep ( 1500 )
ShellExecuteWait ( "powershell.exe", '-executionpolicy unrestricted -file "FixUserFilePermissions.ps1"', $folder )

Sleep ( 1500 )
_Service_Stop ( "ssh-agent" )
_Service_Stop ( "sshd" )
Sleep ( 1000 )
_Service_Start ( "ssh-agent" )
_Service_Start ( "sshd" )
_AddPort ( "ssh", 22, 0, Default, True )