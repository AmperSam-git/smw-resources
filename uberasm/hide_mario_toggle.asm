!FreeRAM = $1879|!addr

main:
    LDA !FreeRAM : BEQ +
    ; hide mario
    LDA #$7F : STA $78
    ; ... and yoshi
    STZ $18DF|!addr
+   RTL

