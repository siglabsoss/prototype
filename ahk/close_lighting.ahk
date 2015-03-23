; 1: A window's title must start with the specified WinTitle to be a match.
SetTitleMatchMode, 1

seenCount := 0

Loop
{
    ; tooltip, Iteration number is %A_Index%.  ; A_Index will be 1, 2, then 3
    

    WinWait, ProXR Example Software for Visual Basic 6, , 1
    if ErrorLevel   ; i.e. it's not blank or zero.
    {
    	; tooltip, The window does not exist.
    	seenCount := 0
    }
	else
	{
    	; tooltip, The window exists.
    	Sleep, 1000 ; this sleep already happens in the if window wasn't found
    	seenCount := seenCount + 1
	}

	; tooltip, %seenCount%
	; Sleep, 500

	if seenCount >= 60
	{
		; MsgBox "ok"
		tooltip, Closing ProXR Lighting Control...
		WinClose, ProXR Example Software for Visual Basic 6, , 1
		sleep, 3000
		tooltip,
	}


}
