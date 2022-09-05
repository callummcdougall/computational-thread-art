#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force



!t::
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Task Manager.lnk"
Return

!o::
Run, Obsidian
Return

#IfWinActive ahk_exe chrome.exe
^[::Browser_Back
^]::Browser_Forward
#IfWinActive ahk_exe Obsidian.exe
^[::Send ^!{Left}
^]::Send ^!{Right}
#IfWinActive



^h::				; Highlights stuff with Ctrl+h not Ctrl+Shift+h, useful in Notion
Send, ^+h
Return

; !x::				; Gets mouse coordinates
; CoordMode, Mouse, Screen 
; MouseGetPos, xpos, ypos 
; MsgBox, The cursor is at X%xpos% Y%ypos%
; Return

#+a::				; screenshots the chess board
CoordMode,Mouse,Screen
Send #+s
Sleep 500
MouseClickDrag, L, 471, 117, 2108, 1754, 4                      ; MouseClickDrag, L, 512, 117, 2065, 1670 - for a short period of time, this worked

!w::				; Opens tab in new window
Send ^l
Send ^c
Send ^w
Send ^n
Send ^v
Send {Enter}
Return

^+1::				; Moves mouse to the first monitor
DllCall("SetCursorPos", "int", 1535, "int", 960)
Return

^+2::				; Moves mouse to the second monitor
DllCall("SetCursorPos", "int", 4991, "int", 840)
Return

^+3::				; Moves mouse to the third monitor
DllCall("SetCursorPos", "int", 4455, "int", 2691)
Return

!/::
SendRaw \
Return

!#::
SendRaw |
Return

#n::
Run notepad.exe
Sleep 150
WinActivate, "Untitled - Notepad"
Return

; Always on Top
^SPACE:: Winset, Alwaysontop, , A ; ctrl + space
Return

; Capslock::\
; Return

~MButton & LButton::							; dragging windows via capslock
CapsLock & LButton::
CoordMode, Mouse  ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
if EWD_WinState = 0  ; Only if the window isn't maximized 
	SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released, so drag is complete.
{
	SetTimer, EWD_WatchMouse, Off
	return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
{
	SetTimer, EWD_WatchMouse, Off
	WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
	return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return

!c::				; shortcut to open command line
Run cmd
Return
; KeyWait Alt
; KeyWait c
; Sleep 50
; Send {LWin}
; Sleep 150
; SendRaw cmd
; Sleep 100
; Send {Enter}
; Return

^+c::				; copies text from a Kindle, and removes the annoying bit at the end
Send ^c
Sleep 100
WinGetActiveTitle, activeWindowName
name := "Callum's Kindle for PC"
IfInString, activeWindowName, %name%
{
	clipboardArray := StrSplit(clipboard, "`n")
	clipboard := clipboardArray[1]
}
Return

^!c::
{
 Send, ^c
 Sleep 50
 Run, https://www.google.com/search?q=%clipboard%
 Return
}

^+u::
Send ^x
SendRaw <ins>
Send ^v
SendRaw </ins>
Return


!d::				; adds meta information in Jupyter Notebooks, for creating Anki cards
;	Send {Esc}bm{Enter}[DATE] %A_YYYY%-%A_MM%-%A_DD%{Esc}
Send {Esc}ay{Enter}
SendRaw from jupyter_to_anki import *
Send {Enter}
SendRaw write_cards_to_anki_package()
Send {Esc}bm{Enter}
Send DECK = {Enter}TAGS = {Enter}URL = 
Return



!b::				; adds markdown bold formatting (for working in Jupyter)
{
	Send ^c
	Sleep 50
	Send {Delete}
	Send {Raw}**%ClipBoard%**
}
Return


!h::				; adds highlight and bold formatting (for working in Obsidian)
{
	Send ^c
	Sleep 50
	Send {Delete}
	Send {Raw}==**%ClipBoard%**==
	Send {End}
}
Return




!k::				; creates a code input (does different things if editing in Anki vs Jupyter)
{
	WinGet, exevar, ProcessName, A
	if (exevar == "anki.exe")
	{
		Send ^c
		Sleep 100
		Length := StrLen(Clipboard)
		Random, RandSeed, 10000000, 99999999
		Send {Delete}
		Send {Raw}<input maxlength='%Length%' name='%ClipBoard%_%RandSeed%' style='width: %Length%ch;'>
	}
	else
	{
		Send ^c
		Sleep 50
		Send {Delete}
		Send {Raw}{{{%ClipBoard%}}}
	}	
}
Return


; #e:: ; the ~ means that AHK should not prevent the key from targeting other programs. Without this, the "a" key would be effectively disabled for you.
; KeyWait, p, D T0.3 ; waits half a second for you to press Enter
; If(ErrorLevel=1) ; If you didn't press Enter within 0.5 seconds, the hotkey's thread will end
; 	Run explorer
; If(ErrorLevel=0)
; 	; Send {backspace 2}
; 	Run "C:\Users\calsm\Documents\Productivity"
; ;   Send {backspace 2}word ; Note that there's two backspaces here. You will have made the input "a" and "enter" which probably has to be erased.
; Return


!n::
{
	Run "C:\Users\calsm\AppData\Local\Programs\Notion"
}
Return

