;;; UberASM conversion and enhancement of Ersanio's "SMB3 P-Meter"  by AmperSam
;;; Run in Gamemode 12 and 14, or as level ASM

if read1($00FFD5) == $23
    ; SA-1 base addresses
    sa1rom
    !SA1  = 1
    !addr = $6000
    !bank = $000000
else
    ; Non SA-1 base addresses
    lorom
    !SA1  = 0
    !addr = $0000
    !bank = $800000
endif

;Tilemap defines
!TriangleEmpty  = $57       ;Empty tile of triangle
!EndEmpty1      = $58       ;Empty tile of P, left side
!EndEmpty2      = $59       ;Empty tile of P, right side

!TriangleFull   = $67       ;Filled tile of triangle
!EndFull1       = $68       ;Filled tile of P, left side
!EndFull2       = $69       ;Filled tile of P, right side

;Misc defines
!Position       = $0F09|!addr
!Length         = 5

;Don't Change
!FullPosition   = !Position+!Length

;SFX defines
!PlaySFX        = 1             ; Set to 1 to play SFX (when meter is full).
!SFXNum         = $19           ; Sound number
!SFXRam         = $1DF9|!addr   ; Sound port

;Hijack defines
!UseStatusHiJack    = 1             ; Set to 1 to insert a small hijack into the status area
                                    ; If removing this resource, set to zero and re-run UberASM Tool to remove the hijack
                                    ; then remove it from your list.txt

!TempTile           = $3D
!ArrowProps         = $38           ; YXPPCCCT properties of p-meter arrow tiles
!EndProps           = $38           ; YXPPCCCT properties of p-meter end tiles


;=====================================
; Hijack code
;=====================================

; This is to change some of the properties of the tiles
; in the status area since they are hard-coded

if !UseStatusHiJack
    pushpc

    ; set the properties of the region used by the p-meter, overriding "TIME" tiles
    org $008CA9
        db !TempTile,!ArrowProps,!TempTile,!ArrowProps,!TempTile,!ArrowProps,!TempTile,!ArrowProps
        db !TempTile,!ArrowProps,!TempTile,!EndProps,!TempTile,!EndProps

    ; Put a little clock before the timer to replace "TIME"
    org $008CDF
        db $76,$3C

    pullpc
else
    pushpc
        ; restore the tilemap of "TIME" and blank space
        org $008CA9
            db $FC,$38,$3D,$3C,$3E,$3C,$3F,$3C      ; blank tile, "TIME" tiles
            db $FC,$38,$FC,$38,$FC,$38              ; 3x blank tiles

        ; put blank tile back in front of timer
        org $008CDF
            db $FC,$38
    pullpc
endif


;=====================================
; Main code
;=====================================
init:
main:
    LDY #$00
    LDA $13E4|!addr
    LSR #4
    TAX
    BEQ .NoFullLoop
    LDA #!TriangleFull
.FullLoop
    STA !Position,y
    INY
    DEX
    BNE .FullLoop
.NoFullLoop
    LDA #!TriangleEmpty
    BRA .TestEmptyLoop
.EmptyLoop
    STA !Position,y
    INY
.TestEmptyLoop
    CPY #!Length
    BCC .EmptyLoop

    ; display empty end
    LDA #!EndEmpty1 : STA !FullPosition
    LDA #!EndEmpty2 : STA !FullPosition+1

.SpeedCheck
    ; check if at p-speed
    LDA $13E4|!addr
    CMP #$60
    BCC .Return

.DrawPMeterEnd
    ; Prepare frame counter for flashing "( P )"
    LDA $14
    LSR #4
    AND #$01
    TAX

    ; Store flashing tiles
    LDA.l EndTiles,x : STA !FullPosition
    LDA.l EndTiles2,x : STA !FullPosition+1

if !PlaySFX
    ; Keep the sound playing
    LDA $14
    AND #$07
    BNE .Return
    LDA #!SFXNum
    STA !SFXRam
endif

.Return
    RTL

EndTiles:
    db !EndEmpty1,!EndFull1
EndTiles2:
    db !EndEmpty2,!EndFull2