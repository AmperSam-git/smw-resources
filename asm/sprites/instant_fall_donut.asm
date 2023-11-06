;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Donut Lift (sprite portion), by mikeyk
;; asar support by JackTheSpades
;;
;; Description:
;;
;; NOTE: This sprite works in conjunction with a custom block. The MAP16 number for
;; the block must be specified where it says !DONUT_MAP16_NUM, likewise, the in the block
;; you have to set the sprite number to whatever you insert this sprite as.
;;
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!DONUT_MAP16_NUM = $029D             ; map16 value of the donut block in hex
		!DONUT_SPRITE_TILE = $C2             ; graphic tile to use for donut sprite
		!DONUT_FALL_SPEED = $38 			 ; falling speed of donut (capped at 38)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
		PHB                     ; \
		PHK                     ;  |
		PLB                     ;  |
		JSR DONUT_CODE_START    ;  |
		PLB                     ;  |
		RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; donut main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DONUT_CODE_START:

		JSR DONUT_GRAPHICS      ;gfx routine
		LDA #$00
		%SubOffScreen()			;Sub_Off_Screen_X0

		LDA $9D                 ; \ if sprites locked, RETURN
		BNE .return             ; /
		LDA !14C8,x
		CMP #$08
		BNE .return

		LDA !AA,x               ;caps y speed at #$38
		CMP #!DONUT_FALL_SPEED
		BPL +
		CLC : ADC #$02
		STA !AA,x
+		JSL $01801A             ;sets speed

		JSL $01B44F
.return
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; donut graphics routine - specific
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DONUT_GRAPHICS:
		%GetDrawInfo()

		LDA !AA,x
		BNE +

		LDA $14
		AND #$02
		BNE +
		LDA !1558,x
		BEQ +

		DEC $00

+		LDA $00                 ; \ tile x position = sprite x location ($00)
		STA $0300|!Base2,y      ; /
		LDA $01                 ; \ tile y position = sprite y location ($01)
		STA $0301|!Base2,y      ; /

		LDA !15F6,x             ; tile properties xyppccct, format
		ORA $64                 ; add in tile priority of level
		STA $0303|!Base2,y      ; store tile properties

		LDA #!DONUT_SPRITE_TILE ; \ store tile
		STA $0302|!Base2,y      ; /

		LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
		LDA #$00                ;  | A = (number of tiles drawn - 1)
		JSL $01B7B3             ; / don't draw if offscreen
		RTS                     ; RETURN