!ResetScore = 1

; These are 24-bit, unsigned hex values
; Note that as the last digit of score is always 0,
; you have to divide your score number by 10 before
; converting it to hex and putting it in this table.

; only use one of these (some common values are provided for convenience)
ScoreValue:
    db $00,$03,$E8  ; 10000
    ;db $00,$09,$C4 ; 25000
    ;db $00,$13,$88 ; 50000
    ;db $00,$27,$10 ; 100000
    ;db $00,$61,$A8 ; 250000
    ;db $00,$C3,$50 ; 500000
    ;db $01,$86,$A0 ; 1000000
    ;db $03,$D0,$90 ; 2500000
    ;db $07,$A1,$20 ; 5000000
    ;db $0F,$42,$3F ; 9999990

init:
if !ResetScore
    ; set score to 0 for both
    ; check player
    LDA $0DB3|!addr : BNE .is_luigi
.is_mario
    STZ $0F34|!addr
    STZ $0F35|!addr
    STZ $0F36|!addr
    BRA +
.is_luigi
    STZ $0F37|!addr
    STZ $0F38|!addr
    STZ $0F39|!addr
+
endif
    RTL

main:
    LDA #$00
    ASL
    TAX
    LDY #$02
    STY $01
.loop
    ; check player
    LDA $0DB3|!addr : BNE .luigi_score

.mario_score
    LDA $0F34|!addr,y
    BRA .check_score

.luigi_score
    LDA $0F37|!addr,y

.check_score
    CMP ScoreValue,x
    BCC .not_enough
    DEC $01
    BMI do_thing

.not_enough
    INX
    DEY
    BPL .loop
    RTL

; thing to do when the score matches
do_thing:
    LDA #$02
    STA $19
    RTL
