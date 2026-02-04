#Requires AutoHotkey v2.0
;https://www.autohotkey.com/docs/v2/Hotkeys.htm
; Alt = !
; Ctrl = ^
; Shift = +

; this probably goes without saying... but FOR THE LOVE OF GOD, do NOT store any creds you retrieve as global variables!
; always call SendPasswordInput() directly when you need to input a password

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                              Functions!                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; use this to check, and create, creds initially!
CreateCredentials(targetName, usernameIsNeeded := false, application:= "Application"){
    if(!DoesCredentialsExist(targetName)){
        PromptAndCreateCredentials(targetName, usernameIsNeeded, application)
    }
}

DoesCredentialsExist(credentialName){
    return CredRead(credentialName) ? true : false
}

; usage SendPasswordInput("Ahk", "Ahk_appName")
SendPasswordInput(application, targetName){
    cred := CredRead(targetName)
    if !cred {
        cred := PromptAndCreateCredentials(targetName, false, application)
        if !cred
            return  ; user cancelled
    }
    SendInput cred.password "{Enter}"
}

; usage SendMultipleInputs("MyApp", "MyApp_Credentials", "{Tab}", "{Tab}", "{Tab}")
; note: The key* variadic parameter collects all arguments after targetName into array, inserted between username and password.
SendMultipleInputs(application, targetName, key*){
    cred := CredRead(targetName)
    if !cred {
        cred := PromptAndCreateCredentials(targetName, false, application)
        if !cred
            return  ; user cancelled
    }
    ; build an array of inputs
    parts := [cred.username]
    parts.Push(key*)
    parts.Push(cred.password, "{Enter}")
    
    for item in parts
        SendInput item
}

; targetName will be stored as the "Internet or Network Address" in cred manager
PromptAndCreateCredentials(targetName, usernameIsNeeded := false, application:= "Application"){
    username := targetName  ; default username

    MsgBox("No credentials found for " application ". Please enter them now.", "Credentials Required", 48)
    
    if (usernameIsNeeded) {
        ibUser := InputBox(
            "Enter your username for " application ".",
            application " Login"
        )
        
        If (ibUser.Result != "OK" || ibUser.Value = "")
            return

        username := ibUser.Value
    }

    ibPass := InputBox(
        "Enter your password for " application ".`n(It will be stored securely in Windows Credential Manager.)",
        application " Password Required",
        "Password"
    )

    If (ibPass.Result != "OK" || ibPass.Value = "")
        return

    password := ibPass.Value

    CredWrite(targetName, username, password)

    return {name: targetName, username: username, password: password}
}

; credential management functions
; see https://www.reddit.com/r/AutoHotkey/comments/1051mkc/comment/j3921wj/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
CredWrite(name, username, password){
    credSize := 24 + A_PtrSize * 7
    cred := Buffer(credSize, 0)

    cbPassword := StrLen(password) * 2

    NumPut("UInt", 1, cred, 4)                                      ; Type
    NumPut("Ptr", StrPtr(name), cred, 8)                            ; TargetName
    NumPut("UInt", cbPassword, cred, 16 + A_PtrSize*2)              ; CredentialBlobSize
    NumPut("Ptr", StrPtr(password), cred, 16 + A_PtrSize*3)         ; CredentialBlob
    NumPut("UInt", 3, cred, 16 + A_PtrSize*4)                       ; Persist
    NumPut("Ptr", StrPtr(username), cred, 24 + A_PtrSize*6)         ; UserName

    return DllCall("Advapi32.dll\CredWriteW"
        , "Ptr", cred.Ptr
        , "UInt", 0
        , "Int")
}


CredRead(name){
    pCred := 0

    if !DllCall("Advapi32.dll\CredReadW"
        , "Str", name
        , "UInt", 1
        , "UInt", 0
        , "Ptr*", &pCred
        , "Int")
        return

    namePtr     := NumGet(pCred, 8, "Ptr")
    userPtr     := NumGet(pCred, 24 + A_PtrSize*6, "Ptr")
    blobSize    := NumGet(pCred, 16 + A_PtrSize*2, "UInt")
    passwordPtr := NumGet(pCred, 16 + A_PtrSize*3, "Ptr")

    name     := StrGet(namePtr)
    username := StrGet(userPtr)
    password := StrGet(passwordPtr, blobSize // 2)

    DllCall("Advapi32.dll\CredFree", "Ptr", pCred)

    return {name: name, username: username, password: password}
}
