; infinite lives
org $00D0D8 : NOP #3

; remove life counter from status bar
org $008F55 : NOP #6

; remap tiles where life counter used to be
org $008CC1 : dw $3826,$3887,$3888 ; uses "x" and "*96" tiles

; hide number of lives on the overworld
org $00A15A : BRA $02

; don't show the X next to lives on overworld
org $04A530 : db $FE