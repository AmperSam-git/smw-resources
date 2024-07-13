db $42

JMP ShatterIfBelow : JMP Shatter : JMP Shatter : JMP Return : JMP Return : JMP Return : JMP Return
JMP Shatter : JMP Return : JMP Return

ShatterIfBelow:
    BRA +
Shatter:
    LDA #$FF : STA $7D
+
    LDA #$0F : TRB $9A : TRB $98
    %shatter_block()
Return:
    RTL

print "A block that shatters when mario touches it. Is solid for sprites"