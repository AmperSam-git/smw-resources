; clears score sprites
; used initially with retry death routine

load:
    stz $16E1|!addr
    stz $16E2|!addr
    stz $16E3|!addr
    stz $16E4|!addr
    stz $16E5|!addr
    stz $16E6|!addr
    rtl