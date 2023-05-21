; act as 130

db $37
JMP Switch : JMP Switch : JMP Switch : JMP Switch : JMP Switch : JMP Switch : JMP Switch
JMP Switch : JMP Switch : JMP Switch : JMP Switch : JMP Switch

!ActAsWhenSwitch = $0025        ;> act as when switch is on (Default: 25)

Switch:
    LDA $14AF|!addr             ;> check ON/OFF state
    BNE Return
    LDY.b #!ActAsWhenSwitch>>8  ;\ change tile to Act As
    LDA.b #!ActAsWhenSwitch     ;|
    STA $1693|!addr             ;/
Return:
    RTL

print "Block that is solid when ON/OFF switch is OFF."