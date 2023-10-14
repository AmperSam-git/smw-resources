; ------------------------------------------------------------------------------------------
; Unified Quality of Life patch set by AmperSam
;
; Credit to WhiteYoshiEgg and carol for Fast Overworld (https://smwc.me/s/20813) and
; Alcaro for AutoSave (https://smwc.me/s/12921) and Anti-Farming by AmperSam
; ------------------------------------------------------------------------------------------
; 1 byte of FreeRAM used ($14C1)
; ------------------------------------------------------------------------------------------

if read1($00FFD5) == $23        ; check if the rom is sa-1
    sa1rom
    !sa1 = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !addr = $0000
    !bank = $800000
endif


; ------------------------------------------------------------------------------------------
; Options. Set to 0 to not apply these features
; ------------------------------------------------------------------------------------------

!InfiniteLives = 1          ; Disable gaining and losing lives
!FastOverworld = 1          ; Triple Mario's speed on the Overworld
!AutoSave = 1               ; Saves the game every time you move on the Overworld
!AntiFarming = 0            ; Lets you cycle power-ups on the Overworld by pressing R

; ------------------------------------------------------------------------------------------
; Infinite Lives
; ------------------------------------------------------------------------------------------

if !InfiniteLives
    print " Patching infinite lives..."

    ; disable losing lives a.k.a. infinite lives
    org $00D0D8 : NOP #3

    ; also disable gaining lives
    org $028AD2 : NOP #3
    org $008F2F : NOP #3

else
    print " Infinite lives not patched."
endif


; ------------------------------------------------------------------------------------------
; Fast Overworld
; ------------------------------------------------------------------------------------------

if !FastOverworld
    print " Applying Fast Overworld patch..."

    !Speed      = $03
    !YoshiSpeed = $03

    org $048241                             ; Hijack Game Mode 0E ("On Overworld")
        autoclean JML ApplySpeed

        freecode
        reset bytes
        print " Inserted at $",pc

        ApplySpeed:
            PEA $0004
            PLB
            LDY #!Speed                         ;    Load speed value into Y

            LDA $0DD6|!addr : LSR #2 : TAX      ; \
            LDA $0DBA|!addr,x                   ;  | If the player is on Yoshi,
            BEQ .noYoshi                        ;  | load the Yoshi speed value instead
            LDY #!YoshiSpeed                    ; /

        .noYoshi


        .loop
            TYA                     ; \
            BEQ .return             ;  |
                                    ;  | Then all we need to do
            PHY                     ;  | is execute SMW's OW speed routine Y times.
            JSR .runSpeedRoutine    ;  |
            PLY                     ;  | (Each iteration makes it go faster, of course.)
                                    ;  |
            DEY                     ;  |
            BRA .loop               ; /


        .return
            LDX #$01                ; \ Restore the hijacked code and return
            JML $048246|!bank       ; /

        .runSpeedRoutine

            LDA $13D9|!addr         ; \
            CMP #$04                ;  |
            BNE ..return            ;  | Don't do this if the player isn't walking,
            LDA $13D4|!addr         ;  | the game is paused
            BNE ..return            ;  | or the ground is shaking
            LDA $1BA0|!addr         ;  |
            BNE ..return            ; /

            PHK                     ; \
            PEA.w ..return-1        ;  | Run SMW's OW speed routine
            PEA.w $048575-1         ;  |
            JML $04945D|!bank       ; /
        ..return
            RTS
else
    print " Fast Overworld not applied."
endif


; ------------------------------------------------------------------------------------------
; AutoSave
; ------------------------------------------------------------------------------------------

if !AutoSave
    print " Applying AutoSave patch..."

    ; run whenever you move to a new tile
    org $049037
        PHX
        PHY
        PHP

        PHB
        REP #$30
        LDX.w #$1EA2        ;>bytes to take from
        LDY.w #$1F49        ;>bytes to take to
        LDA.w #141-1        ;>how many bytes to transfer (-1 because byte 0 is included).
        if !sa1
            MVN $40,$40     ;>pick bank
        else
            MVN $7E,$7E
        endif
        SEP #$30
        PLB

        JSL $009BC9
        PLP
        PLY
        PLX
        RTS
    warnpc $049058

else
    print " AutoSave not applied."
endif


; ------------------------------------------------------------------------------------------
; Anti-Powerup Farming
; ------------------------------------------------------------------------------------------

!FillItemBox = 0            ; Set to 1 to also store power up in the player's item box
!FreeRAM = $14C1|!addr      ; FreeRAM uses as a check for the power-up state

PowerUps:
    db $01,$02,$03,$00      ; Power ups ($01 = mushroom, $02 = cape, $03 = flower, $00 = none)


if !AntiFarming
    print " Applying Anti Power-Up Farming patch..."

    org $048359
        autoclean JML CycleOnButtonPress

    freedata

    CycleOnButtonPress:
        ; original code
        CMP #$03
        BEQ +
        JML $04835D|!bank
        +

        ; check for R press
        LDA $18
        AND #$10
        BEQ .return

        ; check if the player is standing on a level and not in looking around mode
        LDA $13D9|!addr
        SEC
        SBC #$03
        ORA $13D4|!addr
        BNE .return

        LDA !FreeRAM        ; check freeram against table
        CMP #$04            ; 4 because of the power up states
        BNE .cyclePowerups  ; increment

        STZ !FreeRAM        ; zero freeram

    .cyclePowerups
        LDX !FreeRAM        ; while the freeram is non-zero
        LDA PowerUps,x      ; cycle through power-ups

        STA $19             ; store to active power-up state
        STA $0DB8|!addr     ; save to Mario state
        STA $0DB9|!addr     ; save to Luigi state

    if !FillItemBox

        ; because the values are not the same for powerup status
        ; and power-up in item box we have to do some nonsense

        CMP #$02            ; check to avoid cape being flower
        BNE +
        LDA #$04            ; load feather for item box instead
        +

        CMP #$03            ; check to avoid star
        BNE ++
        LDA #$02            ; load flower for item box instead
        ++

        STA $0DBC|!addr     ; store to item box (Mario)
        STA $0DBD|!addr     ; store to item box (Luigi)
    endif

        INC !FreeRAM        ; increment freeram

    .return
        JML $048366|!bank   ; return

else
    print " Anti Power-Up Farming not applied."
endif
