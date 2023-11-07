;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spinjump <-> Jump
; Allows to change jumping state mid-air.
; Pressing A while jumping causes player to spin
; and pressing B while spinjumping causes playet to stop spinning.
; By RussianMan, AddMusicK detection added by AmperSam
; Credit is optional.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!PlayJumpSound = 1                      ; set to 0 to not play a sound effect

!SpinJumpSound = $04                    ; sound effect for spinjump
!SpinJumpBank = $1DFC|!addr             ;

!JumpSound = $01                        ; sound effect for normal jump
!JumpSoundBank = $1DFA|!addr            ;

!JumpSoundAMK = $2B                     ; sound effect for normal jump on AddMusic
!JumpSoundBankAMK = $1DF9|!addr         ; may also be $35 and $1DFC|!addr


main:
        LDA $9D                         ; don't do things when freeze flag is set
        ORA $75                         ; can't perform change underwater
        ORA $1470|!addr                 ; \don't run when carrying item.
        ORA $148F|!addr                 ; /
        ORA $187A|!addr                 ; and not when riding yoshi also don't run
        ORA $13D4|!addr                 ; and not when game is paused
        BNE .Return                     ; return if any of above is true

        LDA $72                         ; if not in air
        BEQ .Return                     ; don't run code

        LDA $140D|!addr                 ; check jump type
        BNE .SpinJumping                ; if non-0, spinjumping

        BIT $18                         ; if pressing A
        BPL .Return                     ; change jump to spinjump

        if !PlayJumpSound
        LDA #!SpinJumpSound             ; play spin sound effect
        STA !SpinJumpBank               ;
        endif

.Change
        LDA $140D|!addr                 ; spinjump into jump or vice versa
        EOR #$01                        ;
        STA $140D|!addr                 ;

.Return                                 ; return
        RTL                             ;

.SpinJumping
        BIT $16                         ; if pressing B
        BPL .Return                     ; change spinjump to jump

        if !PlayJumpSound
        LDA.l $008075|!bank             ; check if AMK modified ROM
        CMP #$5C                        ;
        BEQ .AMK                        ;

        LDA #!JumpSound                 ; play Vanilla sound effect
        STA !JumpSoundBank              ;
        BRA .Change                     ; change jump

.AMK
        LDA #!JumpSoundAMK              ; play AMK sound effect
        STA !JumpSoundBankAMK           ;
        endif
        BRA .Change                     ; change jump