; Prevent left-right by stopping Mario if both keys are held

 !LeftInput = %00000010
!RightInput = %00000001

main:
    LDA $9D
    ORA $13D4|!addr
    BNE .return

.checkLeftInput
    LDA $0DA2|!addr
    AND #!LeftInput
    BEQ .checkRighttInput

.disableRightInput
    LDA #!RightInput
    TRB $15

.checkRighttInput
    LDA $0DA2|!addr
    AND #!RightInput
    BEQ .return

.disableLeftInput
    LDA #!LeftInput
    TRB $15

.return
    rtl