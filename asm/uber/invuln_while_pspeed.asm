; give star power after certain speed

!StarFrames = $0A   ; only a small amount so there's leeway for the player
!Speed = $70        ; p-speed

main:
    LDA $13E4|!addr
    CMP #!Speed
    BNE .return
.star
    LDA #!StarFrames
    STA $1490|!addr
.loop
    LDA $1490|!addr
    BEQ RefillStar
.speed_check
    LDA $13E4|!addr
    CMP #!Speed
    BNE NoStar
.return
    RTL

NoStar:
    STZ $1490|!addr
    RTL

RefillStar:
    LDA #!StarFrames
    STA $1490|!addr
    RTL