; Set always-on-top on/off
#+`::
    WinGet, currentWindow, ID, A
    WinGet, ExStyle, ExStyle, ahk_id %currentWindow%
    if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
    {
    	Winset, AlwaysOnTop, off, ahk_id %currentWindow%
	    SplashImage,, x0 y0 b fs12, Always on top OFF.
	    Sleep, 1000
	    SplashImage, Off
    }
    else
    {
	    WinSet, AlwaysOnTop, on, ahk_id %currentWindow%
	    SplashImage,,x0 y0 b fs12, Always on top ON.
	    Sleep, 1000
	    SplashImage, Off
    }
return

; Changing window transparencies
; https://softwarerecs.stackexchange.com/questions/7565/changing-the-transparency-of-a-programs-windows-whenever-i-start-it
; https://github.com/jvtrigueros/AutoHotkeyScripts/blob/master/Opacity/opacity.ahk
#+WheelUp::  ; Increments transparency up by 3.375% (with wrap-around)
    DetectHiddenWindows, on
    WinGet, curtrans, Transparent, A
    if ! curtrans
        curtrans = 255
    newtrans := curtrans + 8
    if newtrans < 255
    {
        WinSet, Transparent, %newtrans%, A
    }
    else
    {
        WinSet, Transparent, 255, A
    }
return

#+WheelDown::  ; Increments transparency down by 3.375% (with wrap-around)
    DetectHiddenWindows, on
    WinGet, curtrans, Transparent, A
    if ! curtrans
        curtrans = 255
    newtrans := curtrans - 8
    if newtrans > 63
    {
        WinSet, Transparent, %newtrans%, A
    }
    else
    {
        WinSet, Transparent, 64, A
    }
return

#++::  ; Increments transparency up by 3.375% (with wrap-around)
    DetectHiddenWindows, on
    WinGet, curtrans, Transparent, A
    if ! curtrans
        curtrans = 255
    newtrans := curtrans + 8
    if newtrans < 255
    {
        WinSet, Transparent, %newtrans%, A
    }
    else
    {
        WinSet, Transparent, 255, A
    }
return

#+-::  ; Increments transparency down by 3.375% (with wrap-around)
    DetectHiddenWindows, on
    WinGet, curtrans, Transparent, A
    if ! curtrans
        curtrans = 255
    newtrans := curtrans - 8
    if newtrans > 63
    {
        WinSet, Transparent, %newtrans%, A
    }
    else
    {
        WinSet, Transparent, 64, A
    }
return

#+O::  ; Reset Transparency Settings using Win+Shift+O
;    WinSet, Transparent, 255, A
    WinSet, Transparent, OFF, A
return

#+g::  ; Press Win+Shift+G to show the current settings of the window under the mouse.
    MouseGetPos,,, MouseWin
    WinGet, Transparent, Transparent, ahk_id %MouseWin%
    ToolTip Translucency:` %Transparent%`n
	Sleep 500
	ToolTip
return

