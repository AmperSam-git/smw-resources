; Basic Layer 2 Wrap

!NoHorzScroll   = 1     ;> no horz scroll
!FreeVerticalScroll = 0 ;> free vertical scroll

; Defines
!Dir   = $00            ;> scroll direction: #$00 = left/up; #$02 = right/down.
!Speed = $00F0          ;> scroll speed: positive = left/up; negative = right/down.
!Accel = $0002          ;> acceleration

; Layer 2 Addresses
!Layer2Speed    = $144A|!addr   ; use $144A for layer 2 X-speed, use $144C for layer 2 Y-speed
!Layer2Mult     = $1452|!addr   ; use $1452 for updating layer 2 X-position, use $1454 for updating layer 2 Y-position
!Layer2Pos      = $1466|!addr   ; use $1466 for layer 2 X-position next frame, use $1468 for layer 2 Y-position next frame


init:
    stz !Layer2Speed                ;\ reset speed
    stz !Layer2Speed+1              ;/
    rtl

main:
    if !FreeVerticalScroll
    lda #$01 : sta $1404|!addr
    endif

    if !NoHorzScroll
    stz $1411|!addr
    endif

    lda $9D
    ora $13D4|!addr
    bne .return

    lda #!Dir : sta $56

    rep #$20
    lda !Layer2Speed
    cmp.w #!Speed
    beq +
    clc
    adc.w #!Accel
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