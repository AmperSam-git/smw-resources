; Run in Gamemode 0E

!FillItemBox = 1            ; Set to 1 to also store power up in the player's item box
!FreeRAM = $14C1|!addr      ; FreeRAM uses as a check for the power-up state

PowerUps:
    db $01,$02,$03,$00      ; Power ups ($01 = mushroom, $02 = cape, $03 = flower, $00 = none)

main:
    ; check for R press
    LDA $18
    AND #$10
    BEQ .return

    ; check if the player is standing on a level and not in looking around mode
    LDA $13D9|!addr
    SEC
    SBC #$03
    ORA $13D4|!addr
    BNE .return

    LDA !FreeRAM        ; compare value in freeram
    CMP #$04            ; against 4 (the # of power ups)
    BNE .cyclePowerups

    STZ !FreeRAM        ; zero freeram

.cyclePowerups
    LDX !FreeRAM        ; while freeram value is non-zero
    LDA PowerUps,x      ; cycle through power-ups

    STA $19             ; store to active power-up state
    STA $0DB8|!addr     ; save to Mario state
    STA $0DB9|!addr     ; save to Luigi state

if !FillItemBox

    ; since the values are not the same for powerup status
    ; and power-up in item box we have to do some nonsense

    CMP #$02            ; check to avoid cape being flower in item box
    BNE +
    LDA #$04            ; load feather value instead
    +

    CMP #$03            ; check to avoid flower being star in item box
    BNE ++
    LDA #$02            ; load flower value instead
    ++

    STA $0DBC|!addr     ; store to item box (Mario)
    STA $0DBD|!addr     ; store to item box (Luigi)
endif

    INC !FreeRAM        ; increment freeram

.return
    RTL