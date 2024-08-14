;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Death Block Tile/Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            !BLOCK_TILE = $2E       ; uses the eating block tile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            PRINT "MAIN ",pc
            PHB                     ; \
            PHK                     ; | main sprite function, just calls local subroutine
            PLB                     ; |
            JSR DEATH_BLOCK_MAIN    ; |
            PLB                     ; |
            RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DEATH_BLOCK_MAIN:
            JSR GRAPHICS

            JSL $01801A|!BankB      ; \ sprite position
            JSL $018022|!BankB      ; /

            JSL $01B44F|!BankB      ; interact with sprites
            JSL $01A7DC|!BankB      ; check for Mario/sprite contact (carry set = contact)
            BCC RETURN

            JSL $00F606|!BankB      ; KILL
RETURN:
            RTS

GRAPHICS:
            JSL $0190B2|!BankB      ; draw sprite using the routine for sprites

            LDY !15EA,x
            LDA $0301|!Base2,y      ; \ load tile y position
            DEC A                   ; |
            STA $0301|!Base2,y      ; / store tile y position

            LDA #!BLOCK_TILE        ; \ store tile
            STA $0302|!Base2,y      ; /

            LDA $0303|!Base2,y      ; \ load tile properties
            AND #$3F                ; |
            STA $0303|!Base2,y      ; / store tile properties

            LDY #$02                ; \ 02, because we didn't write to 460 yet
            LDA #$00                ; | A = number of tiles drawn - 1
            JSL $01B7B3|!BankB      ; / don't draw if offscreen
            RTS
