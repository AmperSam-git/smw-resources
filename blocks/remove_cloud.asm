; act as 25
db $37

JMP Mario : JMP Mario : JMP Mario
JMP Return : JMP Return : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario

Mario:
	LDA $18C2|!addr             ;> check if in the cloud
    BEQ +                       ;> skip return if not
    STA $18E0|!addr             ;> remove cloud
    +
Return:
	RTL

print "Removes Lakitu cloud."