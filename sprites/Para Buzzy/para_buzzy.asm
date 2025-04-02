;----------------------------------------------------------------
; Para-Buzzy by AmperSam
;
; A flying Buzzy Beetle that behaves like SMB3 Para-Beetle
;
; Loosely based on sprite by Romi, imamelia (https://smwc.me/s/27631)
;
; Uses Extra Bit
; 	if clear: rises
; 	if clear: sinks slowly
;
; Extra byte 1: Initial Direction
;   00 - flies towards Mario
;   01 - flies left
;   02 - flies right
;   03 - flies away* from Mario
;
; Extra byte 2: Sprite Speed
;   0C - Default
;----------------------------------------------------------------

;----------------------------------------------------------------
; defines and tables
;----------------------------------------------------------------

Tilemap:
    db $80,$82,$80,$82
Props:
    db $40,$00,$40,$00
WingSize:
    db $00,$02,$00,$02
WingXDisp:
    db $FF,$F8,$09,$08
WingYDisp:
    db $07,$FF,$07,$FF
WingTiles:
    db $5D,$C6,$5D,$C6
WingProps:
    db $76,$76,$36,$36

;----------------------------------------------------------------
; init routine
;----------------------------------------------------------------

print "INIT ",pc
    PHB
    PHK
    PLB
    JSR ParaBuzzyInit
    PLB
    RTL

ParaBuzzyInit:
    LDA $94
    CMP !E4,x
    LDA $95
    SBC !14E0,x
    BPL +
    INC !157C,x
+   LDA !extra_byte_1,x
    AND #$03
    BEQ .Return
    CMP #$03
    BEQ .FaceAway
    DEC
    EOR #$01
    STA !157C,x
.Return
    RTS
.FaceAway
    LDA !157C,x
    EOR #$01
    STA !157C,x
    RTS

;----------------------------------------------------------------
; main routine wrapper
;----------------------------------------------------------------

print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR ParaBuzzyMain
    PLB
    RTL

;----------------------------------------------------------------
; main routine
;----------------------------------------------------------------

ParaBuzzyMain:
    JSR Graphics
    LDA !14C8,x
    EOR #$08
    ORA $9D
    BNE ReturnMain

    LDA #$00
    %SubOffScreen()
    INC !1570,x

.XSpeed
    LDA !extra_byte_2,x     ; \ get value from extra byte
    STA $00                 ; / stash it
    LDY !157C,x             ; \ check direction and branch if set
    BEQ +                   ; /
    LDA $00                 ; \ invert the value otherwise
    EOR #$FF                ; /
    +                       ;
    STA !B6,x               ; set x speed

    LDA !1504,x
    BNE .Update
    LDA #$01
    LDY !AA,x
    BEQ .Update
    BMI .YSpeed000
    DEC : DEC
.YSpeed000
    CLC
    ADC !AA,x
    STA !AA,x
.Update
    JSL $01801A|!BankB
    JSL $018022|!BankB
    LDA $1491|!Base2
    STA !1528,x
    LDY #$B9
    LDA $1490|!Base2
    BEQ .StoreTo167A
    LDY #$39
.StoreTo167A
    TYA
    STA !167A,x
    LDA !15D0,x
    BNE ReturnMain
    JSL $01803A|!BankB
    BCC Return2
    PHK
    PEA Continue-1
    PEA $8020
    JML $01B45C|!BankB
ReturnMain:
    RTS

Continue:
    BCC .SpriteWins
    LDA !1504,x
    BNE .PlayerWins000
    LDA #$01
    STA !1504,x
    LDY #$10
    LDY #$03
.SetYSpeed
    STY !AA,x
.PlayerWins000
    LDA #$08
    STA !154C,x

    LDA !extra_bits,x       ;\ If extra bit is set don't rise
    AND #$04                ;|
    BNE Return2        		;/

    LDA !AA,x
    DEC
    CMP #$F0
    BMI .Return
    STA !AA,x
.Return
    RTS
.SpriteWins
    LDA !154C,x
    BNE Return2
    JSL $00F5B7|!BankB
Return2:
    LDA !154C,x
    BNE ReturnMain
    STZ !1504,x
    STZ !AA,x
.NoResetSpeed
    RTS

;----------------------------------------------------------------
; graphics routine
;----------------------------------------------------------------

Graphics:
    %GetDrawInfo()

    STZ $06

    LDA !14C8,x         ;if dead, don't animate
    CMP #$08
    BCC .NoAnim

    LDA !1570,x
    LSR #2
    LDY !1504,x
    BNE .FastAnimation
    LSR
.FastAnimation
    AND #$01
    STA $06
.NoAnim
    LDY !15EA,x

    LDA !157C,x         ;\
    ASL                 ; | multiply the direction
    CLC                 ; | add our frame index to index the tables
    ADC $06             ; |
    TAX                 ;/
    LDA $00             ;\
    CLC                 ; | wings x pos
    ADC WingXDisp,x     ; |
    STA $0300|!Base2,y  ;/

    LDA $01             ;\
    CLC                 ; | wings y pos
    ADC WingYDisp,x     ; |
    STA $0301|!Base2,y  ;/

    LDA WingTiles,x     ;\  wings tilemap
    STA $0302|!Base2,y  ;/

    LDA $64             ;\
    ORA WingProps,x     ; | wings properties
    STA $0303|!Base2,y  ;/

    TYA                 ;\
    LSR #2              ; | index into tilesize
    TAY                 ;/
    LDA WingSize,x      ;\  variable size, depending on the wing frame
    STA $0460|!Base2,y  ;/

    LDX $15E9|!Base2    ;restore sprite slot

    LDA !15EA,x         ;tile index
    CLC : ADC #$04      ;
    TAY                 ;"INY #4"

    LDA !157C,x
    STA $02

    LDA !15F6,x
    ORA $64
    STA $04

    LDA $01
    SEC
    SBC #$02
    STA $0301|!Base2,y

    LDX $06
    LDA Tilemap,x
    STA $03

    LDA $00
    STA $0300|!Base2,y

    LDA $01
    STA $0301|!Base2,y

    LDA $03
    STA $0302|!Base2,y

    LDX $02
    LDA $04
    ORA Props,x
    ;ORA $64
    STA $0303|!Base2,y

    PHY
    TYA
    LSR #2
    TAY
    LDA #$02            ;16x16 tiles
    STA $0460|!Base2,y
    PLY

    LDA #$01            ;2 tiles
    LDX $15E9|!Base2    ;restore sprite slot
    LDY #$FF            ;different sizes (except when in egg form but whatev)
    JSL $01B7B3|!BankB  ;
.Return
    RTS
