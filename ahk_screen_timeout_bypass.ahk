#Requires AutoHotkey v2.0
#SingleInstance Force
#include ahk_traytip_helper.ahk
; BIG DIRTY BODGE!
; if the app is not running with admin creds, run a new instance as admin and end this One
; UAC is still required

if !A_IsAdmin
{
    Run '*RunAs "' A_AhkPath '" /restart "'  A_ScriptFullPath '"'
    ExitApp
}

ShowTrayTip("AutoHotKey - v2", "Screen Timeout bypass is running...", 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Common Functions        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; provide registry path and the name of the registry - returns Reg Value
ReadRegKey(regPath, regName) 
{ 
    return RegRead(regPath, regName) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Shitty Screen Timeout Fix   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;global LockScreenTimeoutRegPath := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
;global ScreenTimeoutDefaultValue := 3600
;global LockScreenTimeoutRegName := "inactivitytimeoutsecs"

global ScreenTimeoutRegPath := "HKCU\Control Panel\PowerCfg\GlobalPowerPolicy"
global PluggedScreenTimeoutRegName := "ACTimeout"
global PluggedScreenTimeoutValue := 3600
global BatteryScreenTimeoutRegName := "DCTimeout"
global BatteryScreenTimeoutValue := 300


BeginScreenTimeoutBypass() {
    CreateTimeoutRegistryKey(ScreenTimeoutRegPath, PluggedScreenTimeoutRegName, PluggedScreenTimeoutValue, "REG_DWORD")
    CreateTimeoutRegistryKey(ScreenTimeoutRegPath, BatteryScreenTimeoutRegName, BatteryScreenTimeoutValue, "REG_DWORD")

    CheckScreenTimeout()
    SetTimer(CheckScreenTimeout, 5000)  ; Add parentheses
}

CheckScreenTimeout() {
    ; Check both AC and DC
    if (RegRead(ScreenTimeoutRegPath, PluggedScreenTimeoutRegName) != PluggedScreenTimeoutValue)
        SetScreenTimeout()
    if (RegRead(ScreenTimeoutRegPath, BatteryScreenTimeoutRegName) != BatteryScreenTimeoutValue)
        SetScreenTimeout()
}

SetScreenTimeout() {
    RegWrite(PluggedScreenTimeoutValue, "REG_DWORD", ScreenTimeoutRegPath, PluggedScreenTimeoutRegName)
    RegWrite(BatteryScreenTimeoutValue, "REG_DWORD", ScreenTimeoutRegPath, BatteryScreenTimeoutRegName)
    ShowTrayTip("Screen timeout reset", "Timeouts restored", 2)
}

; creates a registry key with a default value if it does not exist
CreateTimeoutRegistryKey(key, valueName, defaultValue, type := "REG_SZ") {
    try
        return RegRead(key, valueName)
    catch {
        RegWrite(defaultValue, type, key, valueName)
        return defaultValue
    }
}