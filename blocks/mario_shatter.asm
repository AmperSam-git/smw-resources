db $42

JMP Shatter : JMP Shatter : JMP Shatter : JMP Return : JMP Return : JMP Return : JMP Return
JMP Shatter : JMP Return : JMP Return

Shatter:
	LDA #$0F : TRB $9A : TRB $98
	%shatter_block()
Return:
	RTL

print "A block that shatters when mario touches it."