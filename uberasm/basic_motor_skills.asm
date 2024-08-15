!SpinJumpFlag = $140D|!addr

main:
    lda $9D             ;\ check if game paused or frozen
    ora $13D4|!addr     ;|
    bne .return         ;/

    lda $72             ;\ check if in air
    beq .return         ;/
    lda !SpinJumpFlag   ;\ check if spin jump
    beq .IsSpinning     ;/

    lda $16             ;\ check button press
    bpl .return         ;/
    stz !SpinJumpFlag   ;\ clear spin jump flag
    bra .return         ;/

.IsSpinning
    lda $18             ;\ check button press
    bpl .return         ;/
    lda #$01            ;\ set spin jump flag
    sta !SpinJumpFlag   ;/

.return
    rtl