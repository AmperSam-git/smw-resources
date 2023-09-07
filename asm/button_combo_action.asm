; ------------------------------ ;
;    Do Thing on Button Combo    ;
; ------------------------------ ;

; ------------------------------ ;
;             Defines            ;
; ------------------------------ ;

!Logic = 1		; 0 = Do action when ANY of selected buttons pressed. 1 = Do action when ALL of selected buttons pressed.

!b = !false		; B
!y = !false		; Y
!e = !false		; Select
!t = !false		; Start
!U = !false		; Up
!D = !false		; Down
!L = !true		; Left
!R = !true		; Right

; These two button groups function separately of each other. Set all the buttons in a group to "!false" to disable the effect for that group.

!a = !true		; A
!x = !true		; X
!l = !true		; L
!r = !true		; R

; ------------------------------ ;
;          Do not edit           ;
; ------------------------------ ;

!Combo1 = (!b<<7)+(!y<<6)+(!e<<5)+(!t<<4)+(!U<<3)+(!D<<2)+(!L<<1)+!R
!Combo2 = (!a<<7)+(!x<<6)+(!l<<5)+(!r<<4)

!true = 1
!false = 0

if !b|!y|!e|!t|!U|!D|!L|!R == 1
!byetUDLR = !true
else
!byetUDLR = !false
endif

if !a|!x|!l|!r == 1
!axlr = !true
else
!axlr = !false
endif

; ------------------------------ ;
;              Code              ;
; ------------------------------ ;

main:
	LDA $9D
	ORA $13D4|!addr
	BNE Return
	LDY $0DB3|!addr
	if !byetUDLR == !true
		LDA $0DA2|!addr,y
		ORA $0DA6|!addr,y
		AND #!Combo1
		if !Logic
			CMP #!Combo1
			BEQ Action
		else
			BNE Action
		endif
	endif
	if !axlr == !true
		LDA $0DA4|!addr,y
		ORA $0DA8|!addr,y
		AND #!Combo2
		if !Logic
			CMP #!Combo2
			BEQ Action
		else
		BNE Action
		endif
	endif

Return:
	RTL

Action:
	LDA #$06
	STA $71
	STZ $89
	STZ $88
	RTL