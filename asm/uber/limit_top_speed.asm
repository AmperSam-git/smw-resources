;---------------------------------------------------------------
; Limit Mario's Top Speed
;---------------------------------------------------------------
; I used this ASM with the following tweak to make Mario
; always run and slow down when the button is held.
;
;   org $00D718 : db $00
;---------------------------------------------------------------

; default values: 13-15 walking, 2F-31, running
!MaxSpeed = $14

main:
    ; don't run if animationed locked or paused
    lda $9D : ora $13D4|!addr : bne .return

    ; check if X/Y is held
.check_byetUDLR
    lda $15 : ora $16
    and #$40
    bne limit_speed
.return:
    rtl

limit_speed:
    LDA $7B                 ; check X speed...
    BPL .going_right        ; if going right, skip to limiting right speed

.going_left
    CMP #(!MaxSpeed*-1)     ;\ if it isn't max speed...
    BPL .return             ;/ return
    LDA #(!MaxSpeed*-1)     ; otherwise set max speed
    BRA +

.going_right
    CMP #!MaxSpeed          ;\ if it isn't max speed...
    BMI .return             ;/ return
    LDA #!MaxSpeed          ; otherwise set max speed
+   STA $7B                 ; set X speed

.return
    rtl