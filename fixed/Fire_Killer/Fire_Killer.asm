;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fireball Bullet Bill by 33953YoShI (wakogoro)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uses first extra bit: YES
; 	- if clear, fireballs fire at 45 degree angles
; 	- if set, fireballs fire at 90 degree angles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        !Explode_SFX    = $09
        !Shoot_SFX      = $0F

        !Tile = $A6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
        PHY

        %SubHorzPos()

        TYA
        STA !157C,x
        PLY
        LDA !7FAB10,x
        AND #$04
        STA !151C,x

        LDA #!Shoot_SFX
        STA $1DFC|!addr
        RTL

print "MAIN ",pc
        PHB
        PHK
        PLB
        JSR SpriteMain
        PLB
        RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_Speed:
        db $20,$E0

Fire_X:
        db $12,$12,$EE,$EE
        db $18,$00,$E8,$00
Fire_Y:
        db $12,$EE,$EE,$12
        db $00,$18,$00,$E8

SpriteMain:
        LDA $64
        PHA
        LDA !163E,x
        BEQ +
        DEC !163E,x
        LDA #$10
        STA $64
        +
        JSR SubGFX
        PLA
        STA $64
        LDA $9D
        BNE Return
        LDA !14C8,x
        CMP #$08
        BNE Return

        %SubOffScreen()

        LDY !157C,x
        LDA X_Speed,y
        STA !B6,x
        STZ !AA,x
        LDA !1686,x
        PHA
        LDA !163E,x
        BEQ +
        LDA !1686,x
        ORA #$80
        STA !1686,x
        +

        JSL $01802A|!bank
        PLA
        STA !1686,x
        LDA !1588,x
        AND #$0B
        BNE SpawnFireBall

        JSL $01A7DC|!bank
        BCC Return

        %SubVertPos()

        LDA $0E
        CMP #$EE
        BPL SpawnFireBall
        LDA #$01
        STA !167A,x
        JSL $01A7DC|!bank

Return:
        RTS


SpawnFireBall:
        LDA #$03
        STA $0F
        LDA #!Explode_SFX
        STA $1DFC|!addr
        STZ !14C8,x

        STZ $00 : STZ $01
        LDA #$1B : STA $02
        LDA #$01
        %SpawnSmoke()       ;

LoopStart:
        LDY #$07
-
        LDA $170B|!addr,y
        BEQ ExtSpr
        DEY
        BPL -
        STZ $0F
        RTS

ExtSpr:
        PHY
        LDA $0F
        ORA !151C,x
        TAY
        LDA Fire_Y,y
        STA $00
        LDA Fire_X,y
        STA $01
        PLY

        LDA #$02
        STA $170B|!addr,y

        LDA !D8,x
        CLC
        ADC #$04
        STA $1715|!addr,y
        LDA !14D4,x
        ADC #$00
        STA $1729|!addr,y

        LDA !E4,x
        CLC
        ADC #$04
        STA $171F|!addr,y
        LDA !14E0,x
        ADC #$00
        STA $1733|!addr,y

        LDA $00
        STA $173D|!addr,y
        LDA $01
        STA $1747|!addr,y
        DEC $0F
        BPL LoopStart
        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGFX:
        %GetDrawInfo()

        LDA $00
        STA $0300|!addr,y
        LDA $01
        STA $0301|!addr,y
        LDA #!Tile
        STA $0302|!addr,y
        LDA !157C,x
        EOR #$01
        LSR A
        ROR A
        LSR A
        ORA !15F6,x
        ORA $64
        STA $0303|!addr,y

        LDA #$00
        LDY #$02
        %FinishOAMWrite()
        RTS