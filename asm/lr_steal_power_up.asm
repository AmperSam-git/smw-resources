;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Save Power-Up to Item Box with L/R by AmperSam
;
; This patch will allow you to "steal" any of the 4 valid powerup states that
; Mario can have and place that corresponding power in the item box.
;
; Since the star isn't in the power up list at $19, this asm checks if the
; star timer is active instead.
;
; Uses FreeRAM: 2 bytes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!give_iframes = 1                   ;> If 1, give player some invincibility when power stealing
!iframes_time = $7F                 ;> number of frames to make player invincible (default: 7F)

!play_sfx = 1                       ;> If 1, play item box SFX when power stealing
!sfx_value = $0B                    ;> SFX value
!sfx_bank = $1DFC|!addr             ;> SFX bank

!item_box = $0DC2|!addr             ;> address of item box

!powerup_freeram = $1869|!addr      ;> freeram address to store old powerup state (1 byte)
!star_freeram = $186A|!addr         ;> freeram address to star timer (1 byte)

main:
    lda $19                         ;\ load powerup state and...
    sta !powerup_freeram            ;/ store in FreeRAM

    lda $1490|!addr                 ;\ load star timer and...
    sta !star_freeram               ;/ store in FreeRAM

    lda $18                         ;\ check if either L or R is pressed
    bit #%00100000 : bne steal      ;| and run the steal power up routine
    bit #%00010000 : bne steal      ;/
    rtl

steal:

    lda $1490|!addr                 ;\ check if star or...
    ora $19                         ;| powerup state is active
    beq .return                     ;/

    stz $19                         ;> remove player's power up

    stz $1407|!addr                 ;> reset cape flight
    stz $1490|!addr                 ;> remove star powerup
    stz $13E0|!addr                 ;> reset player's pose

    if !give_iframes
        lda #!iframes_time          ;\ give i-frames
        sta $1497|!addr             ;/
    endif

    if !play_sfx
        lda #!sfx_value             ;\ play item get sfx for item box
        sta !sfx_bank               ;/
    endif

    lda !powerup_freeram            ;\ compare stored powerup state with...
    cmp #$01                        ;/ mushroom value
    beq .store_mushroom

    lda !powerup_freeram            ;\ compare stored powerup state with...
    cmp #$02                        ;/ cape value
    beq .store_cape

    lda !powerup_freeram            ;\ compare stored powerup state with...
    cmp #$03                        ;/ flower value
    beq .store_flower

    lda !star_freeram               ;\ check if star timer was active
    cmp #$00                        ;/
    bne .store_star

    rtl

.store_mushroom
    lda #$01 : sta !item_box        ;> put mushroom in item box
    rtl

.store_flower
    lda #$02 : sta !item_box        ;> put flower in item box
    rtl

.store_star
    lda #$03 : sta !item_box        ;> put star in item box
    rtl

.store_cape
    lda #$04 : sta !item_box        ;> put feather in item box
    rtl

.return
    rtl