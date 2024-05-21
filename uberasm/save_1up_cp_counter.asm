
; Save Individual 1-up Checkpoint Counter
;
; Use as level asm or in gamemode 14

; 1 byte unused ram to backup the 1-up checkpoint counter
; important to take from the unused block
!RAM_counter_backup = $7FA123

; To save this to SRAM, add the following to the
; SRAM table, changing the address as appropriate
;
;   dl $7FA123 : dw $0001
;

init:
    ; restore the backup
    lda !RAM_counter_backup : sta $1421|!addr
    RTL

main:
    ; back up the 1up CP counter
    lda $1421|!addr : sta !RAM_counter_backup
    rtl
