;;; UberASM conversion of Ersanio's SMB3 P-Meter patch

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
!Position       = $0F0A|!addr
!Length         = 6

; Don't Change
!FullPosition   = !Position+!Length

;SFX defines
!PlaySFX        = 1             ; Set to 1 to play SFX (when meter is full).
!SFXNum         = $19           ; Sound number
!SFXRam         = $1DF9|!addr   ; Sound port


; pushpc
; ;hijack to rearrange the status bar
; org $008CA9
;     db $3D,$3C,$3D,$3C,$3D,$3C,$3D,$3C
;     db $3D,$3C,$3D,$3C,$3E,$3C,$3F,$3C
;     db $FC,$3C,$2E,$3C
; pullpc

load:
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