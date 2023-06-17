;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Save Power-Up to Item Box with L/R by AmperSam
;
; This patch will allow you to "steal" any of the 4 valid powerup states that
; Mario can have and place that corresponding power in the item box. Since the star isn't
; in the power-up list at $19, this ASM checks if the star timer is active instead.
;
; Note: if Mario is in a power-up state AND has star power, this ASM will steal the star power
; first. Only pressing L/R after stealing the star will steal the power-up. Stealing star power
; can be disabled.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!give_iframes = 1                   ;> If 1, give player some invincibility when power stealing
!iframes_time = $7F                 ;> number of frames to make player invincible (default: 7F)

!steal_star = 1                     ;> Allow stealing star power

!drop_existing_item = 1             ;> Drop the item already in the box when stealing

!play_sfx = 1                       ;> If 1, play item box SFX when power stealing
!sfx_value = $0B                    ;> SFX value
!sfx_bank = $1DFC|!addr             ;> SFX bank

main:
    lda $9D                         ;\ check if game is frozen or...
    ora $13D4|!addr                 ;| if game is paused
    bne .return                     ;/

    lda $19                         ;\ load powerup state and...
    sta $00                         ;/ store in scratch ram

    if !steal_star
        lda $1490|!addr             ;\ load star timer and...
        sta $01                     ;/ store in (different) scratch ram
    endif

    lda $18                         ;\ check if either L or R is pressed...
    bit #%00110000 : bne steal      ;/ and run the steal routine

.return
    rtl

steal:
    if !drop_existing_item
        JSL $028008                 ;> drop existing item box item
    endif

    if !steal_star
        lda $1490|!addr             ;\ check if star active...
        ora $19                     ;| or powerup state
        beq .return                 ;/
    else
        lda $19                     ;\ just check if powerup state is active
        beq .return                 ;/
    endif

    if !give_iframes
        lda #!iframes_time          ;\ take number of i-frames...
        sta $1497|!addr             ;/ store in the invincibility timer
    endif

    if !play_sfx
        lda #!sfx_value             ;\ play "item get" sfx for item box
        sta !sfx_bank               ;/
    endif

    if !steal_star
        ldx $01                     ;\ if a star was active...
        bne .store_star             ;/ steal the star
    endif

    ldx $00                         ;\ if the player is small...
    beq .return                     ;/ do nothing

.store_powerup
    dex
    lda power_ups,x                 ;\ load the power up values...
    sta $0DC2|!addr                 ;/ store to item box

    stz $19                         ;> clear power up state
    stz $1407|!addr                 ;\ reset flight state...
    stz $13E0|!addr                 ;/ and player's pose (for cape)
    bra .return

.store_star
    ldx #$03                        ;> load star value ($03 = star)
    lda $01                         ;\ check if star timer was active...
    beq .return                     ;/ if not do nothing

    stx $0DC2|!addr                 ;> store star to item box

    stz $18D3|!addr                 ;> clear star sparkles
    stz $1490|!addr                 ;> remove star powerup

..restore_music
    lda $0DDA|!addr                 ;\ check the music register...
    cmp #$FF                        ;| if #$FF (level end)...
    beq .return                     ;/ do nothing
    and #$7F                        ;\ clear bit 7 to stop star music...
    sta $0DDA|!addr                 ;| store new value back in the register and...
    sta $1DFB|!addr                 ;/ restore the song number

.return
    rtl

power_ups:
    db $01,$04,$02                  ;> $01 = mushroom, $04 = cape, $02 = flower