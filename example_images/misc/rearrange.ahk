#SingleInstance Force

ResizeWin(l=1, r=2, lr=3, t=1, b=2, tb=3)
{
    if (lr > 0) {
        Width := ((r - l) / lr) * A_ScreenWidth
        Leftt := (l / lr) * A_ScreenWidth
    }
    if (tb > 0) {
        Height := ((b - t) / tb) * A_ScreenHeight
        Topp := (t / tb) * A_ScreenHeight
    }

    if (lr = 0) && (tb > 0) {
        WinMove,A,,,%Topp%,,%Height%
    } else if (lr > 0) && (tb = 0) {
        WinMove,A,,%Leftt%,,%Width%,
    } else if (lr > 0) && (tb > 0) {
        WinMove,A,,%Leftt%,%Topp%,%Width%,%Height%
    }



    ; SysGet, m, MonitorWorkArea 
    ; WinMove, A,, (l/lr)*mRight, (t/tb)*mBottom, ((r-l)/lr)*mRight, ((b-t)/tb) * mBottom
}

Numpad1::
ResizeWin(0, 1, 3, 2, 3, 3)
Return
Numpad2::
ResizeWin(1, 2, 3, 2, 3, 3)
Return
Numpad3::
ResizeWin(2, 3, 3, 2, 3, 3)
Return
Numpad4::
ResizeWin(0, 1, 3, 1, 2, 3)
Return
Numpad5::
ResizeWin(1, 2, 3, 1, 2, 3)
Return
Numpad6::
ResizeWin(2, 3, 3, 1, 2, 3)
Return
Numpad7::
ResizeWin(0, 1, 3, 0, 1, 3)
Return
Numpad8::
ResizeWin(1, 2, 3, 0, 1, 3)
Return
Numpad9::
ResizeWin(2, 3, 3, 0, 1, 3)
Return

; Alt + Numpad numbers to do 1/4 sizes
!Numpad1::
ResizeWin(0, 1, 2, 1, 2, 2)
Return
!Numpad3::
ResizeWin(1, 2, 2, 1, 2, 2)
Return
!Numpad7::
ResizeWin(0, 1, 2, 0, 1, 2)
Return
!Numpad9::
ResizeWin(1, 2, 2, 0, 1, 2)
Return
!Numpad4::
ResizeWin(0, 1, 2, 0, 1, 1)
Return
!Numpad6::
ResizeWin(1, 2, 2, 0, 1, 1)
Return
!Numpad8::
ResizeWin(0, 1, 1, 0, 1, 2)
Return
!Numpad2::
ResizeWin(0, 1, 1, 1, 2, 2)
Return
!Numpad5::
ResizeWin(0, 1, 1, 0, 1, 1)
Return

; Ctrl + Numpad numbers to do 2/3 sizes
^Numpad1::
ResizeWin(0, 2, 3, 1, 3, 3)
Return
^Numpad3::
ResizeWin(1, 3, 3, 1, 3, 3)
Return
^Numpad7::
ResizeWin(0, 2, 3, 0, 2, 3)
Return
^Numpad9::
ResizeWin(1, 3, 3, 0, 2, 3)
Return
^Numpad4::
ResizeWin(0, 2, 3, 0, 1, 1)
Return
^Numpad6::
ResizeWin(1, 3, 3, 0, 1, 1)
Return
^Numpad8::
ResizeWin(0, 1, 1, 0, 2, 3)
Return
^Numpad2::
ResizeWin(0, 1, 1, 1, 3, 3)
Return
^Numpad5::
ResizeWin(0, 1, 1, 0, 1, 1)
Return

; Enter and Zero send to max height/width
NumpadEnter::
ResizeWin(0, 0, 0, 0, 1, 1)
Return
Numpad0::
ResizeWin(0, 1, 1, 0, 0, 0)
Return
; ctrl+Numpad to move into different monitors