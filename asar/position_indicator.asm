; Position Indicator by AmperSam, based on Offscreen Indicator by Thomas.
; Displays a sprite tile on Mario's position to show where he is onscreen.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; GRAPHICAL SETTINGS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tile and YXPPCCCT for the marker when Mario is above the screen.
!Tile         =   $C2     ; Tile number
!Props        =   $24     ; YXPPCCCT properties
!Size         =   1       ; Size of the tile. 0 = 8x8, 1 = 16x16.

; Offset Settings for the tile
!xOffSet      =   $04-(!Size*4)
!yOffset      =   $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; OTHER SETTINGS ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!oamIndex   =   $0000   ; OAM index (from $0200) to use.
                        ; ^ don't touch this one unless you know how it works.
                        ;   this default value isn't really used by much so it should be fine.

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
    !bank = $000000
else
    lorom
    !addr = $0000
    !bank = $800000
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00A299
    autoclean JSL OnscreenIndicator

freecode

OnscreenIndicator:
    LDA $71
    CMP #$09
    BEQ .original_code
    PHB : PHK : PLB
.check_if_offscreen
    REP #$20
    LDA $80
    BMI .onscreen
    SEC : SBC #$00D9
    BMI .offscreen
    STA $00
    INY
    BRA .return
.onscreen:
    SEC : SBC #$FFE1
    BPL .offscreen
    EOR #$FFFF : INC
    STA $00
.offscreen:
    SEP #$20
.xpos
    LDY #$00
    LDA $7E
    CLC : ADC #!xOffSet
    STA $0200|!addr+!oamIndex,y
.ypos
    LDA $80
    CLC
    PHA
    LDA $19
    BEQ .is_small
    PLA
    ADC #!yOffset
    BRA +
.is_small
    PLA
    ADC #!yOffset+$10 ; add a whole tile for 2-tile mario
    +
    STA $0201|!addr+!oamIndex,y
    LDA #!Tile
    STA $0202|!addr+!oamIndex,y
    LDA #!Props
    ORA $64
    STA $0203|!addr+!oamIndex,y
    TYA
    LSR #$02
    TAY
if !Size
    LDA #$02
else
    LDA #$00
endif
    STA $0420|!addr+(!oamIndex/4),y
.return
    PLB
.original_code
    JML $00F6DB|!bank   ; Original code