;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Bob-omb Tower by AmperSam  (based on Goomba Tower, by Darolac)
;;
;; A tower of 4 bob-ombs that moves towards Mario and, when jumped on, it spawns 4 bombs ready to explode.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    !XSpeed     = $0C           ; default bomb walking speed: $0C

    !BombNum    = $0D           ; sprite to spawn (bomb: $0D)
    !Custom     = 0             ; set this if you want to use a custom sprite

    !State      = $09           ; sprite state ($14C8) of the bomb, default carriable
    !Timer      = $30           ; how long it takes for the bob-omb to explode.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XSpeed:

    db !XSpeed,-!XSpeed

FallXSpeed:

    db $10,-$10,$20,-$20        ; fall speed of each in the stack, from the bottom

Prop:

    db $40,$00

YOffset:

    db $00,-$0E,-$1D,-$2C       ; not a whole tiles because bob-omb is short
                                ; adjust if you use custom graphics

Tiles:

    db $CA,$CC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR TowerMain
    PLB
    RTL

print "INIT ",pc
    %SubHorzPos()
    TYA
    STA !157C,x
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TowerMain:

    JSR TowerGFX

    LDA !14C8,x                 ; \
    EOR #$08                    ; | load sprite status, check if default/alive,
    ORA $9D                     ; | sprites/animation locked flag
    BEQ .continue               ; /
    RTS

.continue
    %SubOffScreen()             ; check if the sprite is offscreen.

    JSL $01802A|!BankB          ; update sprite position.
    JSL $018032|!BankB

    LDA !sprite_x_high,x
    XBA
    LDA !sprite_x_low,x
    REP #$20
    SEC
    SBC $94
    BPL +
    EOR #$FFFF
    INC
    +
    CMP #$0010
    SEP #$20
    BCS .no_damage

    LDA !sprite_y_high,x
    XBA
    LDA !sprite_y_low,x

    PHY
    SEC
    LDY $187A|!addr
    REP #$20
    BEQ +
    SBC #$0010
    + PLY

    SBC $96
    CMP #$004A
    SEP #$20
    BCS .no_damage

    LDA $1497|!addr             ; if the player is flashing invincible...
    BNE .no_damage              ; don't interact

    LDA $1490|!addr             ; if the player is invencible...
    BNE BobombSpawn             ; jump to spawn, but kill the sprite

    LDA !154C,x                 ; if the interaction-disable timer is set...
    BNE .no_damage              ; act as if there were no contact at all

    LDA #$08                    ;
    STA !154C,x                 ; set the interaction-disable timer

    LDA $7D                     ;
    CMP #$10                    ; if the player's Y speed is not between 10 and 8F...
    BMI .sprite_wins            ; then the sprite hurts the player

    BRA BobombSpawn             ; spawn bombs

.sprite_wins
    JSL $00F5B7|!BankB          ; hurt mario

.no_damage
    LDA !1588,x                 ; \
    AND #$03                    ; | check if it's blocked from the sides
    BEQ +                       ; /
    LDA !B6,x                   ; if it is, then change speed...
    EOR #$FF
    INC
    STA !B6,x
    LDA !157C,x                 ; \
    EOR #$01                    ; | ...and change direction
    STA !157C,x                 ; /
    +

    LDY !157C,x
    LDA XSpeed,y
    STA !B6,x

.return
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; spawn bomb routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BobombSpawn:

    LDA #$03
    STA $0C
-
    LDY $0C

    STZ $00
    LDA YOffset,y
    STA $01
    LDA FallXSpeed,y
    STA $02
    LDA #$05
    STA $03


.spawn_bomb
    LDA #!SprSize-3
    STA $04

    LDA #!BombNum
    if !Custom
        SEC
    else
        CLC
    endif

    %SpawnSpriteSafe()
    BCS .continue

.set_bomb_timer
    if !Timer
    LDA #!Timer : STA !1540,y
    endif

.set_state
    LDA #!State : STA !14C8,y

    LDA #$09 : STA !1686,y      ; disable sprite-sprite interaction so bombs don't kill each other

    LDA #$08 : STA !154C,x      ; set the interaction-disable timer

.has_star
    LDA $1490|!addr
    BEQ .continue

    LDA #$02
    STA !14C8,y

.continue
    DEC $0C
    BPL -

    LDA $1490|!addr
    BEQ +
    %Star()
    BRA ++
    +
    JSL $01AA33|!BankB          ; boost the player's speed
    JSL $01AB99|!BankB          ; display contact graphics
    LDA #$02 : STA $1DF9|!addr
    ++

    DEC $0C
    BPL -

    STZ !14C8,x

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TowerGFX:

    %GetDrawInfo()

    LDA #$03
   STA $05

    STZ $07
    LDA !14C8,x
    CMP #$08
    BNE .no_animate
    LDA $14
    LSR #3
    AND #$01
    STA $07

.no_animate:

    LDA !15F6,x
    STA $06

    LDA !157C,x
    TAX
    LDA Prop,x
    ORA $64
    ORA $06
    STA $06

-   LDX $05

    LDA $00                     ; load X position of tile
    STA $0300|!addr,y           ; store it

    LDA $01                     ; load Y position of tile
    CLC
    ADC YOffset,x
    STA $0301|!addr,y           ; store it

    LDA $05 : CMP #$00          ; if not at end of loop/bottom of stack
    BNE .static_tile            ; break
    LDX $07
    LDA Tiles,x
    STA $0302|!addr,y
    BRA .continue

.static_tile
    LDX $07
    LDA Tiles
    STA $0302|!addr,y

.continue
    LDA $06
    STA $0303|!addr,y

    INY #4
    DEC $05
    BPL -


    LDX $15E9|!addr             ; recover sprite slot in X register

    LDA #$03                    ; draw stack
    LDY #$02                    ; 16x16 tiles
    JSL $01B7B3|!BankB          ; finish OAM write routine

.return
    RTS