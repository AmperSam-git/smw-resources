; Resets P-Switch Timer on L+R.

main:
    lda $17             ;\
    and #$30            ;| if l+r pressed
    cmp #$30            ;/
    beq .stopTimer      ;> run routine to stop timer
    rtl

.stopTimer
    stz $14AD|!addr     ;> reset Blue p-switch timer
    stz $14AE|!addr     ;> reset Silver p-switch timer

    lda $0DDA|!addr     ;\ restore music
    sta $1DFB|!addr     ;/
    rtl