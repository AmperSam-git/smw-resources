;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Flaming baseball used by Baseball bat sprite by MellyMellouange
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FlameHeadTile1 = $6D
!FlameHeadTile2 = $7D
!FlameTailTile = $7E

!BaseballTile = $6E

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
       RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
        PHB                     ; \
        PHK                     ;  | The same old
        PLB                     ; /
        JSR MainCode            ;  Jump to sprite code
        PLB                     ; Yep
        RTL                     ; Return1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite Main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainCode:
        LDA !14C8,x
        CMP #$02
        BEQ .is_dead
        JSR SUB_DRAW_GFX
        BRA +

.is_dead
        JSR SUB_DEAD_GFX

+       LDA $9D
        BNE .return

        LDA #$00
        %SubOffScreen()

        JSL $018022|!bank
        JSR SmashThings
.return
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; smash Sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SmashThings:
        JSL $03B69F|!bank

        PHX
        TXY
        LDX #!SprSize

-       LDA !14C8,x
        CMP #$08
        BCC .no_contact
        LDA !167A,x
        AND #$02
        BNE .no_contact

        JSL $03B6E5|!bank

        JSL $03B72B|!bank
        BCC .no_contact

        JSR HitHit

.no_contact
        DEX
        CPX #$00
        BNE -
        PLX
        RTS


HitHit:
        LDA #$02
        STA !14C8,x

        ;LDA #$08
        ;JSL $02ACEF|!bank

        LDA #$15
        STA $1DF9|!addr

        LDA !B6,y
        AND #$80
        BEQ .go_right

        LDA #$C0
        STA !B6,x
        BRA .go_up

.go_right
        LDA #$40
        STA !B6,x

.go_up
        LDA #$C0
        STA !AA,x

        LDA #$02
        STA !14C8,y
        LDA #$00
        SEC
        SBC !B6,y
        STA !B6,y
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_DRAW_GFX:
        %GetDrawInfo()

        LDA $00                 ; set x position of the tile
        STA $0300|!Base2,y

        LDA !B6,x
        AND #$80
        BEQ GoingRight


        LDA !15F6,x             ; get sprite palette info
        ORA $64                 ; add in the priority bits from the level settings
        STA $0303|!Base2,y      ; set properties

        BRA FlamesDraw

GoingRight:

        LDA !15F6,x             ; get sprite palette info
        ORA $64                 ; add in the priority bits from the level settings
        ORA #$40
        STA $0303|!Base2,y      ; set properties

FlamesDraw:

        LDA $01                 ; set y position of the tile
        STA $0301|!Base2,y

        LDA $14
        LSR #2
        AND #$01
        BEQ SecondTile

        LDA #!FlameHeadTile1
        STA $0302|!Base2,y
        BRA DrawIt

SecondTile:
        LDA #!FlameHeadTile2
        STA $0302|!Base2,y

DrawIt:
        %GetDrawInfo()

        INY #4

        LDA !B6,x
        AND #$80
        BEQ GoingRight2

        LDA $00                 ; set x position of the tile
        CLC
        ADC #$08
        STA $0300|!Base2,y

        LDA !15F6,x             ; get sprite palette info
        ORA $64                 ; add in the priority bits from the level settings
        STA $0303|!Base2,y      ; set properties

        BRA FlamesDraw2

GoingRight2:
        LDA $00                 ; set x position of the tile
        SEC
        SBC #$08
        STA $0300|!Base2,y

        LDA !15F6,x             ; get sprite palette info
        ORA $64                 ; add in the priority bits from the level settings
        ORA #$40
        STA $0303|!Base2,y      ; set properties

FlamesDraw2:

        LDA $01                 ; set y position of the tile
        STA $0301|!Base2,y

        LDA #!FlameTailTile
        STA $0302|!Base2,y

        LDY #$00                ; #$02 means the tiles are 16x16
        LDA #$01                ; This means we drew one tile
        JSL $01B7B3|!bank
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_DEAD_GFX:

        %GetDrawInfo()

        LDA $00                 ; set x position of the tile
        STA $0300|!Base2,y

        LDA !15F6,x             ; get sprite palette info
        ORA $64                 ; add in the priority bits from the level settings
        STA $0303|!Base2,y      ; set properties

        LDA $01                 ; set y position of the tile
        STA $0301|!Base2,y

        LDA #!BaseballTile
        STA $0302|!Base2,y

        LDY #$00                ; #$02 means the tiles are 16x16
        LDA #$01                ; This means we drew one tile
        JSL $01B7B3|!bank
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;