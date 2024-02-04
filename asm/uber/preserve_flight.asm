; Preserve Flight Through a Level Transition
;   by AmperSam

; Run as level asm or in gamemode 14
; - if used as level asm, make sure it's running the destination level also
;
; Things to note:
; - Mario's direction is preserved so it will override entrance direction set in Lunar Magic
; - spin fly preservation does work with Pipe Cannon entrance
; - Mario's entrance can still be on the ground
; - Mario's speed will be negated by a horizontal or vertical pipe entrance
; - preservation doesn't work with a water level entrance

; 1 byte of freeram used to flag a backup has been done
; cleared on overworld load but NOT cleared on level load!!
!freeram_flag = $192C|!addr

; Note: if you use the Retry System you may have to clear this flag on death
;  e.g. by adding 'stz $192C|!addr' to the death: routine in extra.asm

; 7 more bytes of ram for backing up player states
if read1($00FFD5) == $23
    !freeram_backup = $409460
else
    !freeram_backup = $7FA460
endif

init:
    lda $19 : beq .return                       ; skip if small Mario
    lda !freeram_flag : beq .return             ; skip if flag isn't set

    ; restore from backup
    lda !freeram_backup+0 : sta $72             ; restore player in air flag
    lda !freeram_backup+1 : sta $76             ; restore player direction
    lda !freeram_backup+2 : sta $7B             ;\ restore the player's X
    lda !freeram_backup+3 : sta $7D             ;/ ...and Y speed
    lda !freeram_backup+4 : sta $140D|!addr     ;\ restore spin jump flag
    lda !freeram_backup+5 : sta $14A6|!addr     ;/ ...and cape spin timer
    lda !freeram_backup+6 : sta $1407|!addr     ; restore cape phase
.return
    rtl

main:
    ; don't run if:
    lda $9D             ; animations are locked
    ora $71             ; ...is a cutscene
    ora $13D4|!addr     ; ...or the game is paused
    bne .return

    ; reset flag
    stz !freeram_flag

    lda $72 : beq .return                       ; skip if not in the air

    ; backup player states
    lda $72         : sta !freeram_backup+0     ; preserve player in air flag
    lda $76         : sta !freeram_backup+1     ; preserve player direction
    lda $7B         : sta !freeram_backup+2     ;\ preserve the player's X
    lda $7D         : sta !freeram_backup+3     ;/ ...and Y speed
    lda $140D|!addr : sta !freeram_backup+4     ;\ preserve spin jump flag
    lda $14A6|!addr : sta !freeram_backup+5     ;/ ...and cape spin timer
    lda $1407|!addr : sta !freeram_backup+6     ; preserve cape phase

    ; set flag to say backup is done
    lda #$01 : sta !freeram_flag
.return
    rtl
