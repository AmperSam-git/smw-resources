; act as 25
db $37

REP 8 : JMP NoFly : JMP InstantFly
REP 1 : JMP NoFly

InstantFly:
    LDA $72             ;\ Skip if not on ground
    BEQ NoFly           ;/
    LDA $1407|!addr     ;\ Skip if already flying
    ORA $140D|!addr     ;| ...or spinning
    BNE NoFly           ;/
    LDA $19             ;\
    CMP #$02            ;| Check for a cape, duh
    BNE NoFly           ;/
    LDA $15             ;\
    ORA $16             ;| Skip if not holding Y/X.
    AND #$40            ;|
    BEQ NoFly           ;/
    LDA #$02            ;\ Flying phase
    STA $1407|!addr     ;/ Gliding, staying on level
    lda #$03            ;\ Enable flight.
    sta $1408|!addr     ;/
NoFly:
    RTL

print "Instant flight"