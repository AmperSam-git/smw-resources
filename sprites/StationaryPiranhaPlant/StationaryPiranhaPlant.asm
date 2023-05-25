;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Stationary Piranha Plants, by AmperSam, based on disassembly by imamelia.
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is clear, the Piranha Plant will be rightside-up.  If the first extra
;; bit is set, the Piranha Plant will be upside-down.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; the tiles for the graphics routine

!HeadTile1 = $AC        ; Closed Mouth
!HeadTile2 = $AE        ; Open mouth
!StemTile  = $CE        ; Stem (uses flopping fish)

Tilemap:
db !StemTile,!HeadTile2,!StemTile,!HeadTile1,!StemTile,!HeadTile2,!StemTile,!HeadTile1

; tile Y offset for the graphics routine depending on direction
; stem, head, stem, head (normal) stem, head, stem, head (upside-down)

TileYOffset:
db $10,$00,$10,$00,$F0,$00,$F0,$00

; tile properties for the graphics routine

TileProperties:
db $5A,$58,$5A,$58,$DA,$D8,$DA,$D8

; stem palette D, head palette C, Y-flip depending on direction,
; always GFX page 1 and priority setting 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "INIT ",pc
        JSR PiranhaInit
        RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaInit:

        LDA !7FAB10,x           ; check the extra bit
        AND #$04                ; if the extra bit is clear...
        LSR                     ;
        LSR                     ;
        STA !1510,x             ;
        BEQ InitUpPiranha       ; skip the part of the init routine strictly for the upside-down plant

        LDA !D8,x               ;
        SEC                     ; offset its Y position
        SBC #$00                ;
        STA !D8,x               ;
        LDA !14D4,x             ; handle the high byte
        SBC #$00                ; to prevent overflow
        STA !14D4,x             ;

InitUpPiranha:

        LDA !E4,x               ;
        CLC                     ;
        ADC #$08                ; shift the sprite's X position to the right 8 pixels
        STA !E4,x               ;
        DEC !D8,x               ; shift the sprite down 1 pixels
        LDA !D8,x               ;
        CMP #$FF                ; if there was overflow...
        BNE EndInit             ;
        DEC !14D4,x             ; decrement the high byte as well

EndInit:
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR PiranhaPlantsMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaPlantsMain:

        JSR PiranhaPlantGFX     ; draw the sprite

        LDA #$00                ;
        %SubOffScreen()

        LDA $9D                 ; if sprites are locked...
        BNE EndMain             ; terminate the main routine right here

        JSR SetAnimationFrame   ; determine which frame the plant should show

        JSL $01803A|!BankB      ; interact with the player and other sprites

EndMain:
        RTS


SetAnimationFrame:
        INC !1570,x             ; $1570,x - individual sprite frame counter, in this context
        LDA !1570,x             ;
        LSR #3                  ; change image every 8 frames
        AND #$01                ;
        STA !1602,x             ; set the resulting image
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaPlantGFX:                ; imamelia's graphics routine, since the Piranha Plant uses a shared routine.

        %GetDrawInfo()          ; set some variables up for writing to OAM

        LDA !1510,x             ; direction bit
        ASL                     ; x2
        ASL                     ; x4
        STA $03                 ; set the tilemap index
        LDA !1602,x             ; current frame
        ASL                     ;
        ORA #$01                ;
        ORA $03                 ;
        STA $03                 ; set the index for the Y offsets depending on frame and direction

        LDA #$01                ; 2 tiles to draw
        STA $04                 ;

        LDX $03

GFXLoop:

        LDA $00                 ;
        STA $0300|!Base2,y      ; no X offset

        LDA $01                 ;
        CLC                     ;
        ADC TileYOffset,x       ; set the tile Y offset depending on direction and which tile is being drawn
        STA $0301|!Base2,y      ;

        LDA Tilemap,x           ; set the tile number
        STA $0302|!Base2,y      ;

        LDA TileProperties,x    ; set the tile properties
        STA $0303|!Base2,y      ;

        INY #4                  ; increment Y to get to the next OAM slot
        DEX                     ;
        DEC $04                 ; decrement the tile counter
        BPL GFXLoop             ; if still positive, there is another tile to draw

        LDX $15E9|!Base2        ; sprite index back into X
        LDY #$02                ; the tiles were 16x16
        LDA #$01                ; we drew 2 tiles
        JSL $01B7B3|!BankB      ;

        RTS                     ;