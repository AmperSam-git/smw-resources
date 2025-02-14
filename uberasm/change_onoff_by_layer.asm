!switch = $14AF|!addr

main:
    ; check what layer player is on
    lda $13EF|!addr
    ; if on layer 1
    cmp #$01 : beq .flip_switch_on
    ; if on layer 2
    cmp #$02 : beq .flip_switch_off
    rtl

.flip_switch_on
    ; check if switch already ON
    lda !switch : beq .return
    ; set ON
    stz !switch
    ; play sfx
    lda #$0B : sta $1DF9|!addr
    rtl

.flip_switch_off
    ; check if switch already OFF
    lda !switch : bne .return
    ; set OFF
    lda #$01 : sta !switch
    ; play sfx
    lda #$0B : sta $1DF9|!addr

.return
    rtl
