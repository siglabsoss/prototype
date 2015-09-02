Loop, 700
{

WinWait, Filter Visualization Tool - Figure 1: Filter Coefficients, 
IfWinNotActive, Filter Visualization Tool - Figure 1: Filter Coefficients, , WinActivate, Filter Visualization Tool - Figure 1: Filter Coefficients, 
WinWaitActive, Filter Visualization Tool - Figure 1: Filter Coefficients, 
Send, {DOWN}{CTRLDOWN}c{CTRLUP}
WinWait, Untitled - Notepad, 
IfWinNotActive, Untitled - Notepad, , WinActivate, Untitled - Notepad, 
WinWaitActive, Untitled - Notepad, 
Send, {CTRLDOWN}v{CTRLUP}{ENTER}
}


;WinWait, Filter Visualization Tool - Figure 1: Filter Coefficients, 
;IfWinNotActive, Filter Visualization Tool - Figure 1: Filter Coefficients, , WinActivate, Filter Visualization Tool - Figure 1: Filter Coefficients, 
;WinWaitActive, Filter Visualization Tool - Figure 1: Filter Coefficients, 
;Send, {DOWN}{CTRLDOWN}c{CTRLUP}
;WinWait, Untitled - Notepad, 
;IfWinNotActive, Untitled - Notepad, , WinActivate, Untitled - Notepad, 
;WinWaitActive, Untitled - Notepad, 
;Send, {CTRLDOWN}v{CTRLUP}{ALTDOWN}{ALTUP}
