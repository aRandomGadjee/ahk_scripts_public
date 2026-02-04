#Requires AutoHotkey v2.0
#SingleInstance Force

; bloody annoying.... the traytip takes params as TrayTip(Body, Title [Option])
; this function just makes it it easier on my own psyche
; Shows TrayTip(title, body, [optional: options]) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;						OPTIONAL SHITE TABLE 							;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	Function Description				|  Dec	|	 Hex	|  String	;;
;;	------------------------------------|-------|-----------|---------	;;
;;	Info icon							|	1	|	0x1		|	Iconi	;;
;;	Warning icon						|	2	|	0x2		|	Icon!	;;
;;	Error icon							|	3	|	0x3		|	Iconx	;;
;;	Tray icon							|	4	|	0x4		|	N/A		;;
;;	Do not play the notification sound.	|	16	|	0x10	|	Mute	;;
;;	Use the large version of the icon.	|	32	|	0x20	|	N/A		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; we only care about the Dec (decimal) value and the function name

ShowTrayTip(title, body, option := 0) {
	arrOptions := Array([1,2,3,4,16,32])
    if (option > 0)
        TrayTip(body, title, option)
    else
        TrayTip(body, title)
}