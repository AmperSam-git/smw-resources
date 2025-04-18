;-------------------------------------------------------------
; Run in this file in gamemode 0C
;-------------------------------------------------------------

incsrc "no_overworld_defs.asm"

;-------------------------------------------------------------
; Code
;-------------------------------------------------------------

; instead of loading OW, this code sets a flag to bypass it (sets $0109 to #$01).
; also does stuff like dealing with a level being beaten,
; reloading music, flags etc... (down in sublabel .just_reload_stuff)
; this code has a lot of verbose.

init:
    .check_game_over
        ; lives
        LDA $0DBE|!addr
        BPL ..continue

if !two_player_sharing == 0
        ; 2 player mode
        LDA $0DB2|!addr
        BEQ ..to_tile_screen

        ; which player(luigi or mario)
        LDA $0DB3|!addr
        EOR #$01
        TAX

        ; other player's lives
        LDA $0DB4|!addr,x
        BPL ..continue
endif

        ..to_tile_screen
        ; change gamemode to title screen ($02)
        LDA #$02
        STA $0100|!addr
        RTL
        ..continue

    if !skip_intro_level
        LDA $0109|!addr
        CMP.b #!intro_level
        BNE +
        STZ $0109|!addr
        +
    endif

    .set_flag_to_bypass_overworld
        ; check if $0109 is intro level (more than zero)
        LDA $0109|!addr
        BEQ +
        JMP .just_reload_stuff
        +
        ; set to #$01 to bypass overworld load (this happens at CODE_00A096)
        INC $0109|!addr
        ; if for some reason intro level is $01, inc twice so it's not the same
        if !intro_level == $01 : INC $0109|!addr

    ; run this code once for the whole game (just after intro level)
    .for_the_first_time
        LDA !new_game_flag
        BNE +
    if !advanced_mode
        LDA #!first_level_13BF
        STA !curr_level

        ; advanced mode uses $1EA2 to store info about levels' exits
    ..reset_some_ow_flags
        LDX #95
        -
        LDA $1EA2|!addr,x
        AND #%11110000
        STA $1EA2|!addr,x
        DEX
        BPL -
    endif
        ;save game for the first time
        %SaveGame()
        INC !new_game_flag
    +

    .check_if_level_beaten
        ; load events
        LDA $0DD5|!addr
        BNE +
        -
        JMP .just_reload_stuff
        +
        CMP #$05
        BCS -

    ; kind of messy
    .level_is_beaten

        ..check_if_final_level
            %LDA_current_level()
            CMP #!FINAL_level_13BF
            BNE ..not_final_level
            JMP ..credits

        ..not_final_level
            %beat_level()
            %set_next_level()
            if !save_when_beating_level
                %SaveGame()
            endif
            JMP .just_reload_stuff

        ..credits
            if !more_levels_after_credits
                %beat_level()
                %set_next_level()
                %SaveGame()
            endif
            ; load credits scene (#$08) to current cutscene ($13C6)
            LDA #$08 : STA $13C6|!addr
            ; and load credits gamemode (#$19) to curr gamemode (#$18 doesn't work)
            LDA #$19 : STA $0100|!addr
            BRA .reset_music

    .just_reload_stuff

        ;STZ $0DD5|!addr    ; not needed?
        STZ $13C6|!addr     ; current cutscene
        STZ $13D2|!addr     ; current switch palace color
        LDA #$10
        STA $0101+3|!addr   ; make it believe sprite GFX 1 is from the overworld (#$10). So it DMAs it later.
        STA $0101+2|!addr   ; same but GFX 2
        STA $0101+1|!addr   ; same but GFX 3
        STA $0101+0|!addr   ; same but GFX 4


    .2_player_stuff

        ..check_if_2_players_mode
        LDA $0DB2|!addr
        BEQ ..dont_switch

        ; player to X (0 mario, 1 luigi)
        ..get_current_player
        LDX $0DB3|!addr

        ..save_player_stuff
    if !two_player_sharing == 0
        LDA $0DBE|!addr     ;\ lives
        STA $0DB4|!addr,x   ;/
        LDA $0DBF|!addr     ;\ coins
        STA $0DB6|!addr,x   ;/
        LDA $19             ;\ powerup
        STA $0DB8|!addr,x   ;/
        LDA $0DC1|!addr     ; if yoshi
        BEQ ++
        LDA $13C7|!addr     ;\
        ++                  ;| yoshi color
        STA $0DBA|!addr,x   ;/
        LDA $0DC2|!addr     ;\ itembox
        STA $0DBC|!addr,x   ;/
    endif

        ;(for exit.asm block)
        ..check_if_fade_to_luigi
        ; current overworld process
        LDA $13D9|!addr
        CMP #$06
        BEQ +

        ..check_if_switch_flag
        LDA $0DD5|!addr
        BEQ ..dont_switch
        +

        ..switch_player
        TXA         ; X has current player
        EOR #$01 ;switch
        TAX

        ..load_other_player_stuff
        if !two_player_sharing == 0
        LDA $0DB4|!addr,x ; lives
        BMI ..dont_switch ; don't switch if other player has no lives
        STA $0DBE|!addr
        LDA $0DB6|!addr,x ; coins
        STA $0DBF|!addr
        LDA $0DB8|!addr,x ; powerup
        STA $19
        LDA $0DBA|!addr,x ; yoshi color
        STA $13C7|!addr
        STA $0DC1|!addr
        STA $187A|!addr
        LDA $0DBC|!addr,x ; itembox
        STA $0DC2|!addr
        endif

        ..confirm_switch
        STX $0DB3|!addr ; store switched player
        TXA
        ASL
        ASL
        STA $0DD6|!addr ; store switched player

        ..dont_switch

    .reset_music
        LDA $008075|!bank; if addmusik installed
        CMP #$5C
        BNE ..noamk

        ..amk
        LDA #$00
        STA $1DFB|!addr
        STA !addmusick_ram_addr
        BRA +

        ..noamk
        STZ $0DDA|!addr ;reset music
        +

RTL
