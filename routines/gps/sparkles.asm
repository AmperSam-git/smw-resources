;~@sa1

;;; star sparkle effect
;;; usage: %sparkles()


?CreateSparkles:
    PHY                         ;preserve map16 high
    LDA $148D|!addr             ;\
    AND #$0F                    ;|
    CLC                         ;|
    ADC #$FE                    ;|
    CLC                         ;|
    ADC $98                     ;|
    STA $00                     ;/ $00 = Y position to spawn the sparkle at.
    LDA $148E|!addr             ;\
    AND #$0F                    ;|
    CLC                         ;|
    ADC #$FE                    ;|
    CLC                         ;|
    ADC $9A                     ;|
    STA $02                     ;/ $02 = X position to spawn the sparkle at.
    LDY #$0B                    ;\
?-  LDA $17F0|!addr,y           ;|
    BEQ ?SpawnMinorExtended     ;| Find an empty minor extended sprite slot. Return if none found.
    DEY                         ;|
    BPL ?-                      ;/
    PLY                         ;restore map16 high
    RTL

?SpawnMinorExtended:
    LDA #$05                    ;\ Minor extended sprite to spawn (sparkle).
    STA $17F0|!addr,y           ;/
    LDA $00                     ;\ Set Y position.
    STA $17FC|!addr,y           ;/
    LDA $02                     ;\ Set X position.
    STA $1808|!addr,y           ;/
    LDA #$17                    ;\ Number of frames to keep the sprite active for.
    STA $1850|!addr,y           ;/
    PLY                         ;restore map16 high
    RTL
