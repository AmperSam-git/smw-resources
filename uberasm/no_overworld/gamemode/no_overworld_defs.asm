;-------------------------------------------------------------
; No Overworld 1.3 by Brolencho, modernized by AmperSam
;-------------------------------------------------------------


;-------------------------------------------------------------
; Uninstalling
;-------------------------------------------------------------

; To uninstall the hijacks set by this resource, set the
; following flag to 1 and re-run Uberasm Tool. After that,
; you can remove the no_overworld_*.asm files from your gamemode
; folder and remove references to them from your list.txt

    !completely_remove = 0


;-------------------------------------------------------------
; Basic Options
;-------------------------------------------------------------

; When using No OW, the first level you encounter would be $01
; then, level $02, then level $03, etc. but when you get to $24
; and beat it, next level is $101 then $102, $103...
; The following flag can set the initial level, but it must be
; between [$00-$24] or [$101-$13B].

    !first_level = $01


; The level that when player reaches and beats it will trigger
; the credits roll and end  the game.

    !final_level = $04


; When the player touches a midway, the game will save automatically.
; Set the following flag to 0 if you don't want that behaviour.

    !save_at_midways = 1


;-------------------------------------------------------------
; More options
;-------------------------------------------------------------

    !more_levels_after_credits  = 0     ; Set if there are more levels after beating the "final" level
    !save_when_beating_level    = 1     ; Save the game when beating levels
    !save_during_transitions    = 0     ; Save during level transitions; requires the Retry System to work properly
    !skip_intro_level           = 0     ; Skip the intro level
    !two_player_sharing         = 1     ; Share lives, coins, powerup, yoshi and itembox powerup in two-player mode


;-------------------------------------------------------------
; Advanced mode
;-------------------------------------------------------------

; Advanced mode allows you to manually set the level order
; after beating a level, for each exit type, instead of going
; in numerical order by translevel number.

; To use, set the following flag 1 and go edit the "ExitsTable"
; at the end of this file to modify the levels' exits.

    !advanced_mode = 0


;-------------------------------------------------------------
; RAM Defines
;-------------------------------------------------------------

    !curr_level             = $1F13|!addr   ; sram mirror - this saves current level to sram; used only if !advanced_mode
    !new_game_flag          = $1F14|!addr   ; sram mirror - should be 1 the whole game
    !midway_flag            = $1B80|!addr   ; ram - used if !save_at_midways = 1
    !addmusick_ram_addr     = $7FB000

;-------------------------------------------------------------
; Defines - dont change
;-------------------------------------------------------------

!first_level_13BF = 00
if !first_level >= $25
    !first_level_13BF #= !first_level-$DC
else
    !first_level_13BF #= !first_level
endif

!FINAL_level_13BF = 00
if !final_level >= $25
    !FINAL_level_13BF #= !final_level-$DC
else
    !FINAL_level_13BF #= !final_level
endif

!intro_level = read1($009CB1)

!7ED000 = $7ED000       ; $7ED000 if LoROM, $40D000 if SA-1 ROM.
if !sa1
    !7ED000 = $40D000       ; $7ED000 if LoROM, $40D000 if SA-1 ROM.
endif

if read2($009B41) == $04A0
    !sram_plus = 1
else
    !sram_plus = 0
endif

;-------------------------------------------------------------
; Macros
;-------------------------------------------------------------

macro SaveGame()
    if !sram_plus
        JSL $009BC9|!bank
    else
        PHB
        REP #$30
            LDX.w #$1EA2|!addr
            LDY.w #$1F49|!addr
            LDA.w #140
            if !sa1
                MVN $00,$00
            else
                MVN $7E,$7E
            endif
        SEP #$30
        JSL $009BC9|!bank ; v1.2, this is now above PLB to avoid crashes
        PLB
    endif
endmacro

macro ResetGame()
    STZ $4200                       ;no interrupts from here on out
    SEI                             ;
    SEP #$30                        ;request upload
    LDA #$FF                        ;
    STA $2141                       ;
    LDA #$00                        ;DB must be zero, this is done by the h/w normally
    PHA
    PLB
    STZ $420C                       ;disable any HDMA, this is done by the h/w normally
    JML $008016|!bank
endmacro

macro STZ(addr)
    if <addr> < $10000
        STZ <addr>
    else
        PHA
        LDA #$00
        STA <addr>
        PLA
    endif
endmacro

macro LDA_current_level()
    if !advanced_mode
        LDA !curr_level
    else
        LDA $1F2E|!addr             ; load number of beaten levels
        CLC                         ; and add first_level to get...
        ADC #!first_level_13BF      ; current level (translevel, $13BF format)
    endif
endmacro

if !advanced_mode
    FlagsTable: db $01,$02,$04,$08
endif

macro beat_level()              ; A must contain current level ($13BF format)

    TAX                         ; current level to X

if !advanced_mode
    LDY $0DD5|!addr             ; load events (which exit was crossed)
    DEY
    LDA $1EA2|!addr,x           ; level flags from current level
    AND FlagsTable,y
    BEQ ?first_time_beating

    ?exit_already_beaten
    LDA $1EA2|!addr,x           ; level flags from current level
    AND #~$40                   ; reset midway flag
    STA $1EA2|!addr,x
    BRA +

    ?first_time_beating
    LDA $1EA2|!addr,x           ; level flags from current level
    ORA FlagsTable,y            ; set flag of exit beaten
    ORA #$80                    ; set beaten flag
    AND #~$40                   ; reset midway flag
    STA $1EA2|!addr,x
    INC $1F2E|!addr             ; increase number of beaten levels
    +
else
    LDA $1EA2|!addr,x           ; level flags from current level
    ORA #$80                    ; set beaten flag
    AND #~$40                   ; reset midway flag
    STA $1EA2|!addr,x
    INC $1F2E|!addr             ; increase number of beaten levels
    +
endif
endmacro

macro set_next_level()              ; uses $00 and $01 if !advanced_mode
if !advanced_mode
    ?get_normal_or_secret_exit  ;(normal or secret exit 1, 2 or 3)
    LDA $0DD5|!addr             ; load event(exit or secret exit)
    DEC
    ASL ; x2
    STA $00
    STZ $01

    ?add_to_curr_level
    REP #$30
    LDA !curr_level
    AND #$00FF
    ASL
    ASL
    ASL ; x8
    CLC
    ADC $00
    TAX

    ?get_next_level
    LDA.l ExitsTable,x
    SEP #$10

    ?reset_game_if_invalid_level
    CMP #$0025
    BCC +
    CMP #$013C
    BCS ?.re
    CMP #$0101
    BCS +
    ?.re
    %ResetGame()
    +

    ?to_translevel_format
    CMP #$0025
    BCC +
    SEC
    SBC #$00DC
    +
    SEP #$20

    ?store_level
    STA !curr_level
endif
endmacro


;-------------------------------------------------------------
; Hijacks
;-------------------------------------------------------------

pushpc

if !completely_remove

    ; restore original code for loading layer one
    org $04DC64
        db $20, $F2, $D7

    warn "No Overworld is removing the hijacks it needs to work properly."
else

    ; disable loading overworld layer1 translevels to $7ED000
    ; to fix issue in castle entrance
    org $04DC64
        NOP #3

endif

pullpc


;-------------------------------------------------------------
; Exits Table
;-------------------------------------------------------------

; The following table will allow you to manually set every exit
; for each available level, giving you more control over what
; happening in your hack.

if !advanced_mode

ExitsTable:
    .level_000
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_001                      ; <-- Example with level $01
        ..normal  dw $03            ; This sets normal exit to $03. So when you beat level $01, next level is $03,
        ..secret1 dw $101           ; but if you beat it with a secret exit(for example, a key), you go to $101.
        ..secret2 dw $24            ; if you beat it with secret exit 2, you go to $24.
        ..secret3 dw $13B           ; and with secret exit 3, you go to $13B.
    .level_002
        ..normal  dw $FF            ; a valid level must be between [$00-$24] or [$101-$13B].
        ..secret1 dw $FF            ; *CAREFUL*, if an exit is invalid the game will reset after getting that exit.
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_003
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_004
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_005
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_006
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_007
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_008
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_009
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_00A
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_00B
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_00C
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_00D
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_00E
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_00F
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_010
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_011
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_012
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_013
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_014
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_015
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_016
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_017
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_018
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_019
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_01A
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_01B
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_01C
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_01D
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_01E
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_01F
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_020
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_021
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_022
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_023
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_024
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_101
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_102
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_103
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_104
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_105
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_106
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_107
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_108
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_109
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_10A
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_10B
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_10C
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_10D
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_10E
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_10F
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_110
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_111
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_112
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_113
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_114
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_115
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_116
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_117
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_118
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_119
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_11A
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_11B
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_11C
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_11D
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_11E
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_11F
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_120
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_121
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_122
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_123
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_124
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_125
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_126
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_127
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_128
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_129
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_12A
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_12B
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_12C
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_12D
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_12E
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_12F
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_130
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_131
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_132
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_133
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_134
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_135
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_136
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_137
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_138
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_139
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_13A
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF
    .level_13B
        ..normal  dw $FF
        ..secret1 dw $FF
        ..secret2 dw $FF
        ..secret3 dw $FF

endif

