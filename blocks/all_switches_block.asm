db $37

JMP Switches : JMP Switches : JMP Switches : JMP Switches : JMP Switches : JMP Switches : JMP Switches
JMP Switches : JMP Switches : JMP Switches : JMP Switches : JMP Switches

!ActAs = $0025		; Change this as needed.

Switches:
    LDA $1F27|!addr
    AND $1F28|!addr
    AND $1F29|!addr
    AND $1F2A|!addr
    BEQ Return

    LDY.b #!ActAs>>8
    LDA.b #!ActAs
    STA $1693|!addr

Return:
    RTL

print "A block changes its Act As only if all 4 Switch Palace Switches are pressed."