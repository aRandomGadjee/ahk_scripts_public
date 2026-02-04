#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
SendMode "Input"
SetTitleMatchMode 2
SetTitleMatchMode "Slow"

#include ahk_credential_manager.ahk
;#include ahk_proxy_bypass.ahk
#include ahk_screen_timeout_bypass.ahk
#include ahk_traytip_helper.ahk

TrayTip "AHK", "AHK is now running"

;https://www.autohotkey.com/docs/v2/Hotkeys.htm
; Alt = !
; Ctrl = ^
; Shift = +

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                      Credential checks!                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CreateCredentials("AHK_KeepassPass", false, "KeePass")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          Bypass checks!                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BeginScreenTimeoutBypass()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                      Global variables                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

global UserProfilePath := EnvGet("USERPROFILE")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                      Global key remaps                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Win+Ctrl+R = Reload AHK script
#^r::{
    TrayTip "AHK Script", "Script Reloading"
    Sleep 3000
    KeyWait "Control"
    Reload
}

; Win+Ctrl+E = Edit script in VS Code
#^e::Run '"code" "' A_ScriptFullPath '"'

;Ctrl + Win + Escape - Reload proxy bypass
;^#Esc::UpdateBypassList() ;unused

;Win + Escape - Toggle proxy between local and network
;#Esc::ToggleProxy(ProxySettingsKey) ;unused

; CapsLock = Hide Slack
CapsLock::WinHide "ahk_exe slack.exe"

; Ctrl+Shift+V = Paste as comma-separated
^+v::{
    A_Clipboard := StrReplace(A_Clipboard, "`r`n", ",")
    A_Clipboard := StrReplace(A_Clipboard, "`t", ",")
    SendInput "^v"
}

; Shift+WheelUp = Scroll left
+WheelUp::{
    fcontrol := ControlGetFocus("A")
    Loop 2 {
        SendMessage 0x114, 0, 0, fcontrol, "A"
    }
}

; Shift+WheelDown = Scroll right
+WheelDown::{
    fcontrol := ControlGetFocus("A")
    Loop 2 {
        SendMessage 0x114, 1, 0, fcontrol, "A"
    }
}

; Win+G = Search Google
#g::{
    if (A_Clipboard = "") {
        SendInput "^c"
        ClipWait
    }
    Run "http://www.google.co.uk/search?q=" A_Clipboard
}

; Win+Ctrl+S = StackExchange search
#^s::{
    if (A_Clipboard = "") {
        SendInput "^c"
        ClipWait
    }
    searchStr := StrReplace(A_Clipboard, " ", "+")
    Run "http://www.google.co.uk/search?q=site`%3A+stackexchange.com+" searchStr
}

; Win+C = Open MSRA
#c::Run "msra.exe /offerra"

; Win+N = Notepad++
#n::Run "C:\Notepad++\notepad++.exe -multiInst"

; Win+Shift+V = Remote Desktop
#+v::Run "C:\Windows\System32\mstsc.exe"

; Win+I = Internet Explorer with A_ClipboardURL
#i::{
    
    A_Clipboard:= ""
    SendInput "^c"
    ClipWait
    Run "iexplore.exe " A_Clipboard
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          Active Windows Functions                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#HotIf WinActive("Open Database - yourvalutnamehere.kdbx")
Enter::SendPasswordInput("keepass","AHK_KeepassPass")
NumpadEnter::SendPasswordInput("keepass","AHK_KeepassPass")
#HotIf

; Notepad++
#HotIf WinActive("Notepad++")
^F4::SendInput "^w"
!Up::SendInput "^+{Up}"
!Down::SendInput "^+{Down}"
^j::SendInput "^!m"
#HotIf

; Outlook
#HotIf WinActive("Outlook")
Delete::SendInput "^q{Delete}"
#HotIf

; SQL Server Management Studio
#HotIf WinActive("Microsoft SQL Server Management Studio")
^d::SendInput "dbo."
^p::SendInput "dbo.psp"
Escape::SendInput "{Escape}{LAlt Down}{Break}{LAlt Up}"
^,::SendInput ",{Down}{End}"
!,::SendInput ",{Delete}{End}"
+!,::SendInput "{Up}{End},"
^+!,::SendInput "{Up}{End},{Delete}"
#HotIf

; SQL Server Management Studio - Win+Shift+T markdown table paste
#HotIf WinActive("Microsoft SQL Server Management Studio")
#+t::{
    data := A_Clipboard
    if (data = "")
        return
    
    lines := StrSplit(data, "`n", "`r")
    if (lines.Length < 2)
        return
    
    headers := StrSplit(lines[1], "`t")
    
    md := "|"
    for header in headers
        md .= " " Trim(header) " |"
    md .= "`n|"
    
    for header in headers
        md .= "---|"
    md .= "`n"
    
    Loop lines.Length - 1 {
        if (Trim(lines[A_Index + 1]) = "")
            continue
        cols := StrSplit(lines[A_Index + 1], "`t")
        md .= "|"
        for col in cols
            md .= " " Trim(col) " |"
        md .= "`n"
    }
    
    originalClip := A_Clipboard
    A_Clipboard := md
    SendInput "^v"
    Sleep 100
    A_Clipboard := originalClip
}
#HotIf

; SQL Server Profiler
#HotIf WinActive("SQL Server Profiler")
Delete::SendInput "^+{Delete}"
Escape::MenuSelect("A",, "File", "Pause Trace")
Space::MenuSelect("A",, "File", "Run Trace")
#HotIf


; Visual Studio
#HotIf WinActive("Microsoft Visual Studio") 
WheelLeft::SendInput "^-"
WheelRight::SendInput "^+-"
!LButton::SendInput "^-"
!RButton::SendInput "^+-"
MButton::SendInput "{F12}"
#HotIf

