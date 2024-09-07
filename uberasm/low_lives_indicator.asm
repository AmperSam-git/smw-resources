;-------------------------------------------------------------------------------
; Low Lives Indicator by AmperSam
;-------------------------------------------------------------------------------
;
; Play a sound effect and blink the life count when the player has a minimum
; number of lives. I would not recommend having it play a sound with a high life
; minimum, as a constant noise playing would be irritating.
;
; Use in Gamemode 14 or as Level ASM (requires UberASM Tool 2.0 to run in "end:")
;-------------------------------------------------------------------------------

; Minimum number of lives to start the indicator (in hex)
!MinLifeCount = $01

;-------------------------------------------------------------------------------
; Play Sound Effect
;-------------------------------------------------------------------------------

; set to 0 to not play a sound effect
!PlaySound = 1

; be aware the sounds may conflict with other level sound effects
!SFXNum = $23
!SFXBank = $1DFC|!addr

; delay between sound effect (as playing every frame would be not wise)
!SFXInterval = $2F

;-------------------------------------------------------------------------------
; Blink Life Count (Layer 3)
;-------------------------------------------------------------------------------

; set to 0 to not blink life count in status bar
!BlinkLifeCount = 1

; Where on the status bar the life count is, usually 2 tiles. Change if using custom layer 3 hud
!Location1 = $0F16|!addr
!Location2 = $0F17|!addr

; This location is a single 8x8 tile, to change the location check the diagram here:
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=a70ec5339321

; Blank tile to use to cover the life count tiles for blinking effect
!CoverTile = $FC

;-------------------------------------------------------------------------------
end:
    ; skip if the game is frozen or paused
    lda $9D : ora $13D4|!addr : bne .return

    ; skip if in goal walk
    lda $1493|!addr : bne .return

    lda $0DBE|!addr         ;\
    cmp #!MinLifeCount      ;| check life count of the player
    bpl .return             ;/

if !PlaySound
    lda $14                 ;\
    and #!SFXInterval       ;| add a delay to sound playing
    bne +                   ;/
    lda #!SFXNum            ;\ play sound effect
    sta !SFXBank            ;/
    +
endif

if !BlinkLifeCount
    lda $14                 ;\
    and #$08                ;| animation rate
    bne +                   ;/
    lda #!CoverTile         ;\ draw cover tile
    sta !Location1          ;| ...over life count's first tile
    sta !Location2          ;/ ...and the adjacent tile
    +
endif

.return
    rtl