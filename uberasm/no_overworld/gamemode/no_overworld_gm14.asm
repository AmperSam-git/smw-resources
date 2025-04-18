;-------------------------------------------------------------
; Run in this file in gamemode 14
;-------------------------------------------------------------

incsrc "no_overworld_defs.asm"


main:

if !save_at_midways
    LDA $13CE|!addr
    CMP !midway_flag    ; if ram different from midway flag
    BEQ +
    INC                 ; make them equal (should be #$02)
    STA $13CE|!addr
    STA !midway_flag

    LDX $13BF|!addr     ; and save midway status of translevel
    LDA $1EA2|!addr,x
    ORA #$40
    STA $1EA2|!addr,x

    %SaveGame()
    +
elseif !save_during_transitions
    LDA !midway_flag
    BEQ +
    LDX $13BF|!addr     ; and save midway status of translevel
    LDA $1EA2|!addr,x
    ORA #$40
    STA $1EA2|!addr,x
    %SaveGame()
    %STZ(!midway_flag)
    +
endif
    RTL