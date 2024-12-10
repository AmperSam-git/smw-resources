;Behaves $130.
;This block will teleport the player using a specific screen exit.

!screen_num = $00   ;>screen number this block uses.

db $42
JMP Return : JMP Return : JMP MarioSide
JMP Return : JMP Return : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return

MarioSide:

.on_left_of_pipe:
    LDA $93             ;\ check if on left side of tile
    CMP #$00            ;|
    BNE Return          ;/

    LDA $15             ;\ check if holding left button on controller
    AND #$01            ;|
    BEQ Return          ;/

if !EXLEVEL
    JSL $03BCDC|!bank
else
    LDA $5B
    AND #$01
    ASL
    TAX
    LDA $95,x
    TAX
endif

.warp_to_level:
    LDA ($19B8+!screen_num)|!addr   ;\adjust what screen exit to use for
    STA $19B8|!addr,x        ;|teleporting.
    LDA ($19D8+!screen_num)|!addr   ;|
    STA $19D8|!addr,x           ;/

.enter_pipe_left:
    LDA #$32            ;\ set pipe animation timer
    STA $88             ;/

    LDA #$01            ;\ set action to enter pipe from the left
    STA $89             ;/

    LDA $76             ;\ set player direction
    EOR #$01            ;|
    STA $76             ;/

    LDA #$04            ;\ play pipe sound effect
    STA $1DF9|!addr     ;/

    LDA #$01            ;\ preserve held item
    STA $1419|!addr     ;/

    LDA #$05            ;\ teleport the player.
    STA $71             ;/
Return:
    RTL

print "Left-facing pipe that teleports the player using a specific screen exit."