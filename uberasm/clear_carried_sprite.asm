init:
    ; check if mario carrying
    LDA $148F|!addr
    ORA $1470|!addr
    BEQ .Return

    ; load sprites
    LDA !9E,x
    ; check for yoshi
    CMP #$35
    BEQ .YoshiMouth
    ; check if spring
    CMP #$2F
    BEQ .Kill
    ; check for disco shell
    CMP #$0A
    BCC .ShellState

    ; check if in carried state
    LDA !14C8,x
    CMP #$09
    BCC .Return

.Kill
    ; kill sprite
    STZ !14C8,x
    RTL

.ShellState
    LDA !187B,x
    BEQ .Kill
    RTL

.YoshiMouth
    ; check swallow timer
    LDA $18AC|!addr : BEQ .Return
    ; reset swallow timer
    STZ $18AC|!addr
    ; clear mouth sprite
    PHY
    LDY !160E,x
    BMI +
    LDA #$00
    STA !14C8,y
+   PLY

.Return
    RTL