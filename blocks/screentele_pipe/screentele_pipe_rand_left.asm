;Behaves #$130.
;This block will use one of four screens exits at "random".
;Note that its not truly "random", It uses a frame counter,
;I don't know how to use the random number generation, feel
;free to update this block if you need to.

!Warp1 = $00        ;\screen numbers this block uses.
!Warp2 = $01        ;|
!Warp3 = $02        ;|
!Warp4 = $03        ;/

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

    PHY                 ;> prevent behavor bug
    LDA $14             ;\ use frame #$00-#$03
    AND #$03            ;/
    TAX                 ;\ use for table
    LDA randomtable,x   ;/
    TAY
    PHY

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
    PLY
    LDA $19B8|!addr,y   ;\adjust what screen exit to use for
    STA $19B8|!addr,x   ;|teleporting.
    LDA $19D8|!addr,y   ;|
    STA $19D8|!addr,x   ;/

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

    PLY                 ;> pull to prevent stack overflow.
Return:
    RTL

randomtable:
    db !Warp1, !Warp2, !Warp3, !Warp4

print "Left-facing pipe that teleports the player using 1 of 4 screens randomly."