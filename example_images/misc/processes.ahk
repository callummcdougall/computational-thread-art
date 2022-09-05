#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

^2::						
InputBox, t, Action Input, , , 200, 100

t1 := SubStr(t, 1, 1)
t2 := SubStr(t, 2, 1)
t23 := Substr(t, 2, 2)
w_split := StrSplit(t, A_Space)
w1 := split_words[1]
w2 := split_words[2]
if RegExMatch(t, "^a.$")
{
    switch t2
    {
        case "r":
            Run, "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\AutoHotkey.lnk" "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\processes.ahk"
            Run, "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\AutoHotkey.lnk" "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\abbrevs.ahk"
            Run, "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\AutoHotkey.lnk" "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\shortcuts.ahk"
        case "e":
            Run, "C:\Users\calsm\AppData\Local\Programs\Microsoft VS Code\Code.exe" "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\processes.ahk"
            Run, "C:\Users\calsm\AppData\Local\Programs\Microsoft VS Code\Code.exe" "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\abbrevs.ahk"
            Run, "C:\Users\calsm\AppData\Local\Programs\Microsoft VS Code\Code.exe" "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\shortcuts.ahk"
    }
}
else if RegExMatch(t, "spy")
{
    Run, "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\AutoHotkey.lnk" "C:\Program Files\AutoHotkey\WindowSpy.ahk"
}
else if RegExMatch(t, "^n.{1,2}$")
{
    if WinExist("ahk_exe Notion.exe")
    {
        WinActivate
        Sleep 200
    }
    else 
    {
        Run, "C:\Users\calsm\AppData\Local\Programs\Notion\Notion.exe"
        WinWait, ahk_exe Notion.exe
        Sleep 3500
    }
    Send ^p
    Sleep 150
    switch t23
    {
        case "bu": SendRaw Budget
        case "wr": SendRaw Writing
        case "da": SendRaw Daily Reviews
        case "we": SendRaw Weekly Agenda
        case "mo": SendRaw Monthly Review
        case "th": SendRaw Thought Dump
        case "ca": SendRaw Calendar
    }
    Sleep 250
    if RegExMatch(t23, "we|mo")
    {
        Sleep 600
        Send {Tab 6}
        Sleep 350
        Send {Space}
        Sleep 350
        Send {Down 2}
        Sleep 400
        Send {Enter}
        Sleep 400
    }
    Send {Enter}
}
else if RegExMatch(t, "^e.$")
{
    switch t2
    {
        case "p": Run, "C:\Users\calsm\Documents\Productivity"
        case "s": Run, "C:\Users\calsm\Documents\PythonScripts"
        case "b": Run, "C:\Users\calsm\Documents\Blog\blog_website_heroku"
    }
}
else if RegExMatch(t, "^checks$")			; opens the things I check: fb, insta, gmail, outlook, linkedin
{
    Send ^t
    SendRaw https://www.instagram.com/
    Send {Enter}
    Send ^t
    Sleep 200
    SendRaw https://mail.google.com/mail/u/0/#inbox
    Send {Enter}
    Send ^t
    Sleep 200
    SendRaw https://www.facebook.com/
    Send {Enter}
    Send ^t
    Sleep 200
    SendRaw https://www.linkedin.com/feed/
    Send {Enter}
}
else if (t = "conda")
{
	Run "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Anaconda3 (64-bit)\Anaconda Prompt (anaconda3).lnk"
}
else if (t1 = "j") && (StrLen(t) = 2)          ; open jupyter notebooks, or lab
{
    Run "C:\Users\calsm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Anaconda3 (64-bit)\Anaconda Prompt (anaconda3)"
    Sleep 600
    switch t2
    {
        case "n": Send jupyter notebook
        case "l": Send jupyter lab
    }
    Send {Enter}
}
else if (t = "h")               ; opens my personal websites in Heroku (locally)
{
    Run cmd
    Sleep 150
    WinActivate, Command Prompt
    SendRaw cd C:\Users\calsm\Documents\Blog\blog_website_heroku\python-getting-started
    Send {Enter}
    Sleep 200
    Send heroku login
    Send {Enter}
    Sleep 1500
    Send d
    Sleep 3000
    WinWaitActive, Command Prompt,, 40
    Sleep 1000
    SendRaw heroku local -f Procfile.windows
    Send {Enter}
    Sleep 4000
    if WinExist("ahk_exe chrome.exe")
    {
        WinActivate
        Sleep 200
    }
    else 
    {
        Run, "C:\Program Files\Google\Chrome\Application\chrome.exe"
        WinWait, ahk_exe chrome.exe
        Sleep 2000
    }
    Send ^t
    Sleep 300
    SendRaw http://localhost:5000/
    Sleep 100
    Send {Enter}
}
else if (w1 = "h")				; this deals with all the cases where first word indicates second is input
{
    if WinActive("ahk_exe cmd.exe")
    {
        SendRaw git add .
        Send {Enter}
        Sleep 1000
        SendRaw git commit -m "
        Send %w2%
        SendRaw "
        Send {Enter}
        Sleep 1000
        SendRaw git push heroku main
        Send {Enter}
    }
}
Return