!powerup        =   1   ; powerup
!reserve        =   1   ; item box item
!held           =   1   ; held item
!yoshi          =   1   ; yoshi
!coins          =   1   ; coins
!onoff          =   1   ; on/off switch state
!stars          =   1   ; bonus stars
!starblk        =   0   ; green star block
!starblkVal     =   10  ; counter for star block
!layer3         =   1   ; layer 3 position
!score          =   0   ; score
!midway         =   0   ; midway point
!timer          =   1   ; timer
!timerVal       =   9   ; how many hundreds of seconds
!lives          =   0   ; lives
!lifeVal        =   5   ; how many lives to reset to

load:
    if !yoshi       : stz $0DC1|!addr
    if !held        : stz $148F|!addr : stz $1470|!addr
    rtl

init:
    if !powerup     : stz $19
    if !reserve     : stz $0DC2|!addr
    if !yoshi       : stz $187A|!addr : stz $13C7|!addr
    if !onoff       : stz $14AF|!addr
    if !midway      : stz $13CE|!addr
    if !layer3      : stz $22 : stz $23 : stz $24 : stz $25
    if !coins       : stz $0DBF|!addr
    if !stars       : stz $0F48|!addr : stz $0F49|!addr
    if !score       : rep #$20 : stz $0F34|!addr : stz $0F36|!addr : stz $0F38|!addr : sep #$20
    if !timer       : lda.b #!timerVal : sta $0F31|!addr : stz $0F32|!addr : stz $0F33|!addr
    if !lives       : lda.b #!lifeVal-1 : sta $0DBE|!addr
    if !starblk     : lda.b #!starblkVal : sta $0DC0|!addr
    rtl