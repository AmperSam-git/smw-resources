load:
    REP #$20
    ; get player x-position
    LDA $94
    AND #$FF00
    ; set layer 1 position
    STA $1462|!addr
    STA $1A
    ; set layer 2 position
    STA $1466|!addr
    STA $1E
    SEP #$20
    ; no horizontal scroll
    STZ $1411|!addr
    ; no vertical scroll
    STZ $1412|!addr
    RTL