;-------------------------------------------------------------
; Run in this file in gamemode 10
;-------------------------------------------------------------

incsrc "no_overworld_defs.asm"

init:

.check_sublevel
    LDA $141A|!addr
    BEQ .if_translevel

; or if returning from dead with retry patch
.if_sublevel
    if !save_at_midways
        LDA $13CE|!addr
        if !save_during_transitions : EOR #$01
        STA !midway_flag
    elseif !save_during_transitions
        LDA #$01
        STA !midway_flag
    endif
    BRA .return

.if_translevel
    if !save_at_midways || !save_during_transitions : %STZ(!midway_flag)

.return_if_intro_level
    LDA $0109|!addr
    if !intro_level == $01
        BEQ +           ;continue if flag is 00
        CMP #$02        ;or 02
        BEQ +
        BRA .return
        +
    else
        CMP #$02
        BCC +           ;continue if flag is 00 or 01
        BRA .return
        +
    endif

.get_mario_or_luigi
    LDY #$00
    LDX $0DB2|!addr     ; if 2 players
    BEQ +
    LDX $0DD6|!addr     ; mario or luigi
    LDY $0DB3|!addr     ; mario or luigi
    +

; level load uses mario ow pos to load level
.set_mario_ow_position_to_zero
    REP #$20
    STZ $1F17|!addr,x     ; mario pos (x=0), luigi pos(x=1)
    STZ $1F19|!addr,x
    STZ $1F1F|!addr,x
    STZ $1F21|!addr,x
    SEP #$20

;level load gets translevel from 7ED000
.set_translevel_to_mario_ow_pos
    %LDA_current_level()
    STA !7ED000         ;store curr translevel to OW pos.
    STA !7ED000+$400    ; mario pos could be here too.
    CMP #$25
    LDA #$00
    ROL
    STA $1F11|!addr,y   ; translevel highbyte to $1F11 (used in level load)

.reset_0109
    STZ $0109|!addr     ; set flag back to normal on level load. Otherwise, it would behave weird.

.return
    RTL
