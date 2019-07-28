#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=..\Get Rainway Logs.exe
#AutoIt3Wrapper_Res_Comment=Collects Rainway Logs and saves them to a user-defined folder.
#AutoIt3Wrapper_Res_Description=Collects Rainway Logs and saves them to a user-defined folder.
#AutoIt3Wrapper_Res_Fileversion=2.0.0.5
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=Get Rainway Logs
#AutoIt3Wrapper_Res_ProductVersion=2
#AutoIt3Wrapper_Res_CompanyName=BetaLeaf.net Computer Services
#AutoIt3Wrapper_Res_LegalCopyright=Jeff Savage (BetaLeaf) 2019
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <MsgBoxConstants.au3>
#include "RollbarSDK.au3"

;Enable Automatic Error Reporting
_Rollbar_Init("f4c602310d484b17a81cd676448a0ef3") ;if needed, change "_Rollbar_Init()" to "_Rollbar_InitAsk() to ask user first. (If user says no, sets NULL API key and disables reporting)

;Track times program was run.
_Rollbar_Send("Info", "Run Count")

;Script Constants
Global Const $sScriptTitle = "Get Rainway Logs"
Global Const $sRainwayPath = @LocalAppDataDir & "\Rainway, Inc\Server"
Global Const $s7zTempDir = @TempDir & "\BetaLeaf.net Software\Get Rainway Logs"

;Detect 7-Zip Installation or use pre-packaged version.
Select
	Case FileExists("C:\Program Files\7-Zip\7zG.exe") = True
		Global $s7zPath = "C:\Program Files\7-Zip\7zG.exe"
	Case FileExists("C:\Program Files (x86)\7-Zip\7zG.exe") = True
		Global $s7zPath = "C:\Program Files (x86)\7-Zip\7zG.exe"
	Case Else
		If DirCreate($s7zTempDir) = False Then
			Local $sMsg = "Could not create directory: " & $s7zTempDir
			_Rollbar_Send("Error", $sMsg, "Could not create directory: .\BetaLeaf.net Software\Get Rainway Logs")
			Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
		EndIf

		;Extract pre-packaged version of 7-Zip.
		FileInstall("7-Zip\7za.exe", $s7zTempDir & "\7za.exe")
		If FileExists($s7zTempDir & "\7za.exe") = False Then
			Local $sMsg = "Could not extract file: " & $s7zTempDir & "\7za.exe"
			_Rollbar_Send("Error", $sMsg, "Could not extract file: .\BetaLeaf.net Software\Get Rainway Logs\7za.exe")
			Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
		EndIf

		FileInstall("7-Zip\7za.dll", $s7zTempDir & "\7za.dll")
		If FileExists($s7zTempDir & "\7za.dll") = False Then
			Local $sMsg = "Could not extract file: " & $s7zTempDir & "\7za.dll"
			_Rollbar_Send("Error", $sMsg, "Could not extract file: .\BetaLeaf.net Software\Get Rainway Logs\7za.dll")
			Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
		EndIf

		FileInstall("7-Zip\7zxa.dll", $s7zTempDir & "\7zxa.dll")
		If FileExists($s7zTempDir & "\7zxa.dll") = False Then
			Local $sMsg = "Could not extract file: " & $s7zTempDir & "\7zxa.dll"
			_Rollbar_Send("Error", $sMsg, "Could not extract file: .\BetaLeaf.net Software\Get Rainway Logs\7zxa.dll")
			Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
		EndIf

		Global $s7zPath = $s7zTempDir & "\7za.exe"
EndSelect

;Check if Rainway path exists
If FileExists($sRainwayPath) = False Then
	Local $sMsg = "Path not found or invalid: " & $sRainwayPath
	_Rollbar_Send("Error", $sMsg, "Path not found or invalid: .\Rainway, Inc\Server")
	Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
EndIf

;Have user pick a folder to save logs to
Local $sSaveDirectory = FileSelectFolder($sScriptTitle & " - Select Save Folder", @DesktopDir)
If @error = 1 Then Exit

;Create 7z with max compression
ShellExecuteWait($s7zPath, 'a -t7z -m0=lzma2 -mx=9 -aoa -mfb=273 -md=1536m -ms=on "' & $sSaveDirectory & '\Rainway Logs" "' & @LocalAppDataDir & '\Rainway, Inc" -xr!Caches -xr!Cookies -xr!Dictionaries')
If FileExists($sSaveDirectory & "\Rainway Logs.7z") = False Then
	Local $sMsg = "Could not save 7z file."
	_Rollbar_Send("Error", $sMsg)
	Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
EndIf

;Store 7z into zip file so we can upload to github
ShellExecuteWait($s7zPath, 'a -tzip -m0=Copy "' & $sSaveDirectory & '\Rainway Logs.zip" "' & $sSaveDirectory & '\Rainway Logs.7z"')
If FileExists($sSaveDirectory & "\Rainway Logs.zip") = False Then
	Local $sMsg = "Could not save zip file."
	_Rollbar_Send("Error", $sMsg)
	Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
EndIf

;Delete the redundant 7z file
If FileExists($sSaveDirectory & "\Rainway Logs.7z") = True Then
	If FileDelete($sSaveDirectory & "\Rainway Logs.7z") = False Then
		Local $sMsg = "Could not cleanup 7z file."
		_Rollbar_Send("Error", $sMsg)
		Exit MsgBox($MB_ICONERROR + $MB_SYSTEMMODAL + $MB_SETFOREGROUND, $sScriptTitle, $sMsg)
	EndIf
EndIf

ShellExecute($sSaveDirectory)
MsgBox($MB_ICONINFORMATION + $MB_SYSTEMMODAL + $MB_TOPMOST, $sScriptTitle, 'Now drag-and-drop the "Rainway Logs.zip" file into the comments box on your GitHub issue post.')
