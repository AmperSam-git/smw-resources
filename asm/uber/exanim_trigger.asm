!Number = 0                 ; which trigger to use. Valid numbers are 0-F
!Flag = $1F2F|!addr         ; user-set flag to trigger animation

; do not change
!ExAnimRAM = $7FC0FC        ; $7FC070 for MANUAL triggers
                            ; $7FC0FC for CUSTOM triggers

if $!Number > $7
    !Add = $1
    !Number #= $!Number-$8
else
    !Add = $0
endif

main:
    LDA !Flag
    BEQ +
    LDA !ExAnimRAM+!Add
    ORA #$01<<$!Number
    STA !ExAnimRAM+!Add
    RTL
    +
    LDA !ExAnimRAM+!Add
    AND #~($01<<$!Number)
    STA !ExAnimRAM+!Add
    RTL
