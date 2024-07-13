db $42
JMP Return : JMP MarioAbove : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return
JMP TopCorner : JMP Return : JMP Return

!spin_breakable_only = 1            ; set to 1 to only break via spin jump
                                    ; otherwise break always from the top
MarioAbove:
TopCorner:

if !spin_breakable_only
.check_if_spinning
    LDA $140D|!addr                 ; check if spin jumping...
    BNE .check_y_speed              ; if so, go to speed check
    BRA Return                      ; otherwise return
endif

.check_y_speed:
    LDA $7D : CMP #$80              ; check if Mario moving upwards...
    BCC	Break                       ; if not, go to break block
    BRA Return                      ; otherwise return

Break:
    LDA #$D0 : STA $7D	            ; set Mario's Y Speed slightly up
    %rainbow_shatter_block()        ; shatter block
Return:
    RTL                             ; end

if !spin_breakable_only
    print "A weakened block that will break if Mario spin jumps on it"
else
    print "A weakened block that will break if Mario steps on it"
endif
