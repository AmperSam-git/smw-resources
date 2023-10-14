; insert act as 130
db $42
JMP Return : JMP Return : JMP MarioSide : JMP Return : JMP SpriteH : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return

SpriteH:
    ; Check if throw block
	LDA !9E,x
	CMP #$53
	BNE Return

    ; check if moving
	LDA !B6,x
	BEQ Return

    ; check sprite state
	LDA !14C8,x
	CMP #$0A
	BEQ SpriteBump
	CMP #$09
	BEQ SpriteBump
	RTL

SpriteBump:
	LDA !B6,x
	BMI .going_left

.going_right
	LDA #$D0 : STA !B6,x
	BRA +

.going_left
	LDA #$30 : STA !B6,x
+
    ; put in kicked state
	LDA #$0A : STA !14C8,x

    ; make block pass through
	LDY #$00
	LDA #$25
	STA $1693|!addr

    ; Play bounce sfx
    LDA #$08
	STA $1DFC|!addr
Return:
	RTL

print "A block that bumps sprites, and nudges Mario."