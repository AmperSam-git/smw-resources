;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spaceship Movement by Ampersam
;   based on ASM by wiiqwertyuiop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!allow_diagonals = 1

; Speeds
!SpeedH = $15   ;right/left
!SpeedV = $15   ;down/up

main:
    ; disable spin jump
    LDA #%10000000
    TRB $16
    TRB $18

    ; don't run if dying
    LDA $71 : CMP #$09 : BEQ .return

    ; check if touching ground...
    LDA $77 : AND #$07 : BEQ Movement

    ; Kill Mario
    JSL $00F606|!bank
.return
    RTL


Movement:
    ; load player
    LDY $0DB3|!addr

    ; load current buttons
    LDA $0DA2|!addr,y
    ORA $0DA6|!addr,y

    ; check cardinal directions
    CMP #%00001000 : BEQ Up
    CMP #%00000100 : BEQ Down
    CMP #%00000010 : BEQ Left
    CMP #%00000001 : BEQ Right

if !allow_diagonals
    ; check diagonal directions
    CMP #%00001010 : BEQ UpLeft
    CMP #%00001001 : BEQ UpRight
    CMP #%00000110 : BEQ DownLeft
    CMP #%00000101 : BEQ DownRight
endif

.not_moving
    ; otherwise be motionless
    STZ $7B
    STZ $7D
    RTL

; Cardinal Directions
Up:
    LDA #-!SpeedV : STA $7D
    STZ $7B
    RTL
Down:
    LDA #!SpeedV : STA $7D
    STZ $7B
    RTL
Left:
    LDA #-!SpeedH : STA $7B
    STZ $7D
    RTL
Right:
    LDA #!SpeedH : STA $7B
    STZ $7D
    RTL

if !allow_diagonals
; Diagonal Directions
UpLeft:
    LDA #-!SpeedV : STA $7D
    LDA #-!SpeedH : STA $7B
    RTL
UpRight:
    LDA #-!SpeedV : STA $7D
    LDA #!SpeedH : STA $7B
    RTL
DownLeft:
    LDA #!SpeedV : STA $7D
    LDA #-!SpeedH : STA $7B
    RTL
DownRight:
    LDA #!SpeedV : STA $7D
    LDA #!SpeedH : STA $7B
    RTL
endif
