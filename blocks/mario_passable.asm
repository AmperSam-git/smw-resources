; act as 25
db $37

JMP Mario : JMP Mario : JMP Mario
JMP Return : JMP Return : JMP Return : JMP Return
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario

Mario:
    LDY #$00
    LDA #$25
    STA $1693|!addr
Return:
    RTL

print "A block that is only passable by Mario. To sprites, it will obey the Act as setting."