!Layer2Speed    = $144A|!addr
!Layer2Mult     = $1452|!addr
!Layer2Pos      = $1466|!addr

init:
    stz !Layer2Speed                ;\ reset speed
    stz !Layer2Speed+1              ;/
    rtl

main:
    ;lda #$01 : sta $1404|!addr      ;> free vertical scroll
    stz $1411|!addr                 ;> no horz scroll

    lda $9D
    ora $13D4|!addr
    bne .return

    lda #$00 : sta $56              ;> scroll direction: #$00 = left/up; #$02 = right/down.

    rep #$20
    lda !Layer2Speed
    cmp.w #$01B0                    ;> scroll speed: positive = left/up; negative = right/down.
    beq +
    clc
    adc.w #$0002                    ;> acceleration
    sta !Layer2Speed
+   lda !Layer2Mult
    and #$00FF
    clc
    adc !Layer2Speed
    sta !Layer2Mult
    and #$FF00
    bpl ++
    ora #$00FF
++  xba
    clc
    adc !Layer2Pos
    and #$00FF
    sta !Layer2Pos
    sep #$20

.return:
    rtl