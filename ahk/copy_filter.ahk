
; Instructions
; Set the loop iteration to the number of filter coeficients, click on the top line (numerator)
; alt tab away and run this script
; paste into a text editor when done

SetKeyDelay, 0

val = 

WinWait, Filter Visualization Tool - Figure 1: Filter Coefficients, 
IfWinNotActive, Filter Visualization Tool - Figure 1: Filter Coefficients, , WinActivate, Filter Visualization Tool - Figure 1: Filter Coefficients, 
WinWaitActive, Filter Visualization Tool - Figure 1: Filter Coefficients, 

; clear clipboard
clipboard =

Loop, 501
{
; copy the line
Send, {DOWN}{CTRLDOWN}c{CTRLUP}
; wait till clipboard has contents
ClipWait,
; save to our variable
val = %val%`r`n%clipboard%
; clear out clipboard (so ClipWait will work correctly)
clipboard =
; Sleep so it looks better
;sleep, 5
}


clipboard = %val%
tooltip, Filter copied to clipboard


sleep 5000
