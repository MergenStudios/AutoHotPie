﻿#Persistent
#SingleInstance ignore
#Include %A_ScriptDir%\Resources\lib\Gdip_All.ahk
#Include %A_ScriptDir%\Resources\lib\GdipHelper.ahk
#Include %A_ScriptDir%\Resources\lib\BGFuncs.ahk
#Include %A_ScriptDir%\Resources\lib\Jxon.ahk
CoordMode, Mouse, Screen


runPieMenu(profileNum, index)
	{
	global
	MouseGetPos, iMouseX, iMouseY
	StartDrawGDIP()
	PieRegion := 0
	iPieRegion := drawPie(G, iMouseX, iMouseY, 0, 0, settings[profileNum].pieMenus[index].numSlices, settings[profileNum].pieMenus[index].radius, settings[profileNum].pieMenus[index].thickness, settings[profileNum].pieMenus[index].bgColor, settings[profileNum].pieMenus[index].selColor)
	loop
		{
		if !GetKeyState(settings[profileNum].pieMenus[index].hotkey, "P")
			Break
		MouseGetPos, mouseX, mouseY
		;Calculate Distance and Angle
		dist := (Sqrt((Abs(mouseX-iMouseX)**2) + (Abs(mouseY-iMouseY)**2)))
		theta := calcAngle(iMouseX, iMouseY, mouseX, mouseY)
		If (dist <= ((settings[profileNum].pieMenus[index].radius/2)+(settings[profileNum].pieMenus[index].thickness/2)))
		{
		pieRegion := 0
		}
		Else
		{
		pieRegion := Round(theta/(360/settings[profileNum].pieMenus[index].numSlices))+1	
		If (pieRegion == (settings[profileNum].pieMenus[index].numSlices + 1))
			pieRegion := 1
		}
		If (pieRegion != iPieRegion)
			{
			StartDrawGDIP()	
			iPieRegion := drawPie(G, iMouseX, iMouseY, dist, theta, settings[profileNum].pieMenus[index].numSlices, settings[profileNum].pieMenus[index].radius, settings[profileNum].pieMenus[index].thickness, settings[profileNum].pieMenus[index].bgColor, settings[profileNum].pieMenus[index].selColor)
			}
		sleep 20
		}
	StartDrawGDIP()
	ClearDrawGDIP()
	EndDrawGDIP()
	return %pieRegion%
}

;Check AHK version and if AHK is installed.  Prompt install or update.
checkAHK()

;Read Json Settings file to object
	FileRead, settings, %A_ScriptDir%\Resources\settings.json
	global settings := Jxon_Load(settings)

;Initialize Variables and GDI+ Screen bitmap
	;Thank you Tariq Porter
	; monLeft := 0 monRight := 0 monTop := 0 monBottom := 0
	global monLeft := 0
	global monRight := 0
	global monTop := 0
	global monBottom := 0
	getMonitorCoords(monLeft, monTop, monRight, monBottom)
	SetUpGDIP(monLeft, monTop, monRight-monLeft, monBottom-monTop)




;Hotkey, IfWinActive, ahk_class Notepad

; for profiles in settings
; for menus in profiles
; msgbox, % settings[1].ahkHandle

; for profiles in settings
; 	Hotkey, IfWinActive, settings[profiles].ahkHandle
for profiles in settings
	{
	if settings[profiles].ahkHandle == "ahk_group regApps"
		continue
	GroupAdd, regApps, % settings[profiles].ahkHandle
	}
; msgbox, % ahk_group regApps


for profiles in settings
	{
	; msgbox, boop		
	if settings[profiles].ahkHandle == "ahk_group regApps"
		{
		; msgbox, boop
		Hotkey, IfWinNotActive, ahk_group regApps
		for menus in settings[profiles].pieMenus
			{
			Hotkey, % settings[profiles].pieMenus[menus].hotkey, pieLabel
			}
		}
	else
		{
		; msgbox, % settings[profiles].ahkHandle
		Hotkey, IfWinActive, % settings[profiles].ahkHandle
		for menus in settings[profiles].pieMenus
			{
			; msgbox, % settings[profiles].pieMenus[menus].hotkey
			Hotkey, % settings[profiles].pieMenus[menus].hotkey, pieLabel
			}
		}
	}

return
;End Initialization

; pieLabel:
;     runPieMenu(1, 1)
; return

pieLabel:
	;Get application and key
	WinGet, activeWindow, ProcessName, A
	activeWindow := "ahk_exe " + activeWindow	
	activeKey := A_ThisHotkey

	;Lookup profile and key index
	for profiles in settings
		{
		if settings[profiles].ahkHandle == activeWindow
			{
			for menus in settings[profiles].pieMenus
				{
				;if hotkey found []
				if settings[profiles].pieMenus[menus].hotkey == activeKey
					{
					functionNum := runPieMenu(profiles, menus)
					; msgbox, % functionNum
					break, 2
					}				
				}
			}		
		}

	; msgbox, %activeWindow%  `nHotkey = %A_ThisHotkey%
	;functionNum := runPieMenu(1, 1)
	; msgbox, % functionNum
return

; runPieMenu(profiles, menu)


i::
exitapp
return



;If a display is connected or disconnected
	OnMessage(0x7E, "WM_DISPLAYCHANGE")
	return
	WM_DISPLAYCHANGE(wParam, lParam)
		{
		sleep, 200
		Reload
		}
