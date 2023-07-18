;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Object-Interacting Phanto
; based on Wall-interacting Boo Stream by RussianMan and Phanto by yoshicookiezeus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Speed:
db $28,-$28

Acceleration:
db $01,-$01

!Tilemap = $88

!RAM_FrameCounterB      = $14
!RAM_SpritesLocked      = $9D
!RAM_SpriteNum          = !9E
!RAM_SpriteSpeedY       = !AA
!RAM_SpriteSpeedX       = !B6
!RAM_SpriteYLo          = !D8
!RAM_SpriteXLo          = !E4
!RAM_SpriteYHi          = !14D4
!RAM_SpriteXHi          = !14E0
!RAM_SpriteDir          = !157C
!RAM_SprObjStatus       = !1588
!RAM_OffscreenHorz      = !15A0
!RAM_SpritePal          = !15F6
!RAM_OffscreenVert      = !186C


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "MAIN ",pc
        PHB
        PHK
        PLB
        JSR Sprite_Code_Start
        PLB
        print "INIT ",pc
        RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sprite_Code_Start:
        LDA #$00                        ;\ use sprite x speed to determine sprite direction
        LDY !RAM_SpriteSpeedX,x         ; |
        BMI CODE_038F81                 ; |
        INC                             ; |
CODE_038F81:                            ; |
        STA !RAM_SpriteDir,x            ;/

        JSR Sprite_Graphics             ; sprite GFX

        LDA !14C8,X                     ;\ if sprite status not normal,
        EOR #$08                        ; |
        ORA !RAM_SpritesLocked          ;/  OR if sprites locked,
        JSR SubHasKey                   ;\ if Mario has a key,
        CPY #$01                        ;|
        BEQ Continue                    ;/ return
        RTS

Continue:
        ;LDA #$00                       ;\handle offscreen
        %SubOffScreen()                 ;/

        %SubHorzPos()
        LDA Speed,y
        BMI .Negative

        LDA !RAM_SpriteSpeedX,x
        BMI .NormAccel
        CMP Speed,y
        BCC .NormAccel

.FixValue
        STA !RAM_SpriteSpeedX,x
        BRA .Continue

.Negative
        LDA !RAM_SpriteSpeedX,x
        BPL .NormAccel
        CMP Speed,y
        BCC .FixValue

.NormAccel
        LDA !RAM_SpriteSpeedX,x
        CLC : ADC Acceleration,y
        STA !RAM_SpriteSpeedX,x

        ;now handle Y speed
        .Continue
        %SubVertPos()
        LDA Speed,y
        BMI .NegativeVert

        LDA !RAM_SpriteSpeedY,x
        BMI .NormAccelVert
        CMP Speed,y
        BCC .NormAccelVert

.FixValueVert
        STA !RAM_SpriteSpeedY,x
        BRA .ContinueForReal

.NegativeVert
        LDA !RAM_SpriteSpeedY,x
        BPL .NormAccelVert
        CMP Speed,y
        BCC .FixValueVert

.NormAccelVert
        LDA !RAM_SpriteSpeedY,x
        CLC : ADC Acceleration,y
        STA !RAM_SpriteSpeedY,x

.ContinueForReal
        TXA                             ;\ if sprite index or
        EOR !RAM_FrameCounterB          ; | frame counter mod 8 =/= 0
        AND #$07                        ; |
        ORA !RAM_OffscreenVert,x        ; | or sprite is offscreen vertically,
        BNE CODE_038FC2                 ;/ branch

CODE_038FC2:
        JSL $01801A|!BankB              ;\ update sprite position
        JSL $018022|!BankB              ;/

        JSL $019138|!BankB              ; interact with objects

        LDA !RAM_SprObjStatus,x         ;\ if touching object from side,
        AND #$03                        ; |
        BEQ CODE_038FDC                 ; |
        LDA !RAM_SpriteSpeedX,x         ; | invert x speed
        EOR #$FF                        ; |
        INC A                           ; |
        STA !RAM_SpriteSpeedX,x         ;/
CODE_038FDC:
        LDA !RAM_SprObjStatus,x         ;\ if touching object from top or bottom,
        AND #$0C                        ; |
        BEQ CODE_038FEA                 ; |
        LDA !RAM_SpriteSpeedY,x         ; | invert y speed
        EOR #$FF                        ; |
        INC A                           ; |
        STA !RAM_SpriteSpeedY,x         ;/

CODE_038FEA:
        JSL $01A7DC|!BankB              ; interact with Mario

Return:
        RTS                             ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; key routine (stol from Phanto)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubHasKey:
        PHX                     ; push Phanto sprite number
        LDY #$00                ; clear Y register
        LDA $1470|!Base2        ;\ if carriying flag not set,
        BEQ .Return             ;/ no need to check for key
        LDX.b #!SprSize-1       ; setup loop variable
-
        LDA !9E,x               ;\ if sprite currently being checked isn't key,
        CMP #$80                ; | (key = sprite # 80)
        BNE .NextX              ;/ no need to check anything else for that sprite
        LDA !14C8,x             ;\ if sprite is key, check if it is being carried
        CMP #$0B                ; |
        BNE .NextX              ;/ if it isn't, no more checks
        BRA .HasKey             ; if it is, get out of loop

.NextX
        DEX                     ; increase number of sprite to check
        BPL -                   ; if still sprites left to check, repeat loop
        BRA .Return             ; if not, return

.HasKey
        INY                     ; increase Y register to show that key is being carried
.Return
        PLX                     ; get Phanto sprite number back
        RTS                     ; and return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sprite_Graphics:
        %GetDrawInfo()

        LDA $00                 ; set x position of the tile
        STA $0300|!Base2,y
        LDA $01                 ; set y position of the tile
        STA $0301|!Base2,y
        LDA.b #!Tilemap
        STA $0302|!Base2,y

        LDA !15F6,x             ; get sprite palette info
        ORA $64                 ; add in the priority bits from the level settings
        STA $0303|!Base2,y      ; set properties

        LDY #$02                ; the tiles drawn were 16x16
        LDA #$00                ; one tile was drawn
        JSL $01B7B3|!BankB      ; finish OAM write
        RTS