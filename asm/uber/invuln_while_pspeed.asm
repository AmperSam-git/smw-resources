; give star power after certain speed

!StarFrames = $0A   ; only a small amount so there's leeway for the player
!Speed = $70        ; p-speed

; addresses
!StarPowerTimer = $1490|!addr
!PSpeedMeter = $13E4|!addr

main:
    LDA !PSpeedMeter
    CMP #!Speed
    BNE .return
.star
    LDA #!StarFrames
    STA !StarPowerTimer
.loop
    LDA !StarPowerTimer
    BEQ RefillStar
.speed_check
    LDA !PSpeedMeter
    CMP #!Speed
    BNE NoStar
.return
    RTL

NoStar:
    STZ !StarPowerTimer
    RTL

RefillStar:
    LDA #!StarFrames
    STA !StarPowerTimer
    RTL