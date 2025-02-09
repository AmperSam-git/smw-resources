;=====================================
; Single Screen v1.3 by TheBiob
;=====================================

; FreeRAM, four (4) bytes used (actually in the Empty region)
if read1($00FFD5) == $23
    !FreeRAM = $409700
else
    !FreeRAM = $7FA700
endif

; RAM used for backup of layer 1 in horizontal scrolling, two (2) bytes
!RAM_Horz_LayerBackup = !FreeRAM
; RAM used for backup of layer 1 during vertical scrolling, two (2) bytes
!RAM_Vert_LayerBackup = !FreeRAM+2

;=====================================
; Options
;=====================================

;; Vertical Scrolling
; Set to 1 to enable vertical single screen scrolling
!OPT_vertical_scrolling = 1

; Set to 1 to align the camera to the nearest vertical screen and center it
; Note: the screen must start close to that border or graphical glitches may occur
!OPT_vertical_align = 0

;; Horizontal Scrolling
; Set to 1 to enable horizontal single screen scrolling
!OPT_horizontal_scrolling = 1

; Set to 1 to align the camera to the nearest horizontal screen and center
; Note: the screen must start close to that border or graphical glitches may occur)
!OPT_horizontal_align = 0

;; Pause Behavior
; setting this to 1 to will disable pausing during a screen transition
; setting this to 0 to will allow pausing the game during a screen transition
!OPT_pause_behavior = 0

;; Blackout Screen
; Set to 1 to blackout the screen while scrolling
!OPT_blackout_screen = 0


;=====================================
; Definitions
;=====================================

; Thresholds to trigger the screen scroll
!DEF_x_offset = #$0008          ; x offset, default $0008 (half a tile)
!DEF_y_offset = #$0020          ; y offset, default $0020 (two tiles)

; The dimensions of the onscreen region that triggers a scroll
; Note: configured by default to match SNES screen resolution (256x224)
!DEF_screen_width   = $100      ; scroll width, default $100
!DEF_screen_height  = $E0       ; scroll height, default $E0

; Vertical scroll speed, !DEF_screen_height must be divisible by this value.
; Note: it's not recommended to go above $10 due to sprite loading issues.
!DEF_vert_scroll_speed = $08

; Horizontal scroll speed, !DEF_screen_width must be divisible by this value
; Note: it's not recommended to go above $10 due to sprite loading issues.
!DEF_horz_scroll_speed = $08


;=====================================
; Hijack code
;=====================================

; Set to 1 to insert a small hijack into the side exit code
!UseSideExitHijack = 1

; If removing this resource, set to zero and re-run UberASM Tool to remove the hijack
; then remove it from your list.txt

if !UseSideExitHijack
    pushpc
        ; apply hijack
        org $00E98C
            JML SideExit
    pullpc

    SideExit:
        LDA $1B96|!addr
        BEQ +
        CMP #$AC
        BEQ ++
        REP #$20
        JML $00E993|!bank
    +   JML $00E9A1|!bank
    ++  JML $00E9FB|!bank
else
    pushpc
        ; restore original code
        org $00E98C
            LDA.W $1B96|!addr
            BEQ $10
    pullpc
endif

;=====================================
; UberASM code
;=====================================

; INIT CODE
init:
    REP #$20
    if !OPT_horizontal_scrolling
        if !OPT_horizontal_align
            LDA $94
            AND #$FF00
            STA $1462|!addr
            STA $1A
        else
            LDA $1462|!addr
        endif
        STA !RAM_Horz_LayerBackup
    endif

    if !OPT_vertical_scrolling
        if !OPT_vertical_align
            LDA $96
            AND #$FF00
            CLC : ADC #$0010
            STA $1464|!addr
            STA $1C
        else
            LDA $1464|!addr
        endif
        STA !RAM_Vert_LayerBackup
    endif

    if !OPT_vertical_scrolling && !OPT_horizontal_scrolling
        STZ $1411|!addr ; > Disable horz&vert scrolling
        SEP #$20
    else
        SEP #$20
        if !OPT_vertical_scrolling
            STZ $1412|!addr ; > Disable vert scrolling
        endif

        if !OPT_horizontal_scrolling
            STZ $1411|!addr ; > Disable horz scrolling
        endif
    endif

    LDA #$AC        ; \ enable side exits hijack to ensure the player is able to leave the screen
    STA $1B96|!addr ; /
return:
    RTL


; MAIN CODE
main:
    ; temporarily backup height of levels used by Lunar Magic to scratch
    LDA $5B
    LSR
    BCC +
    STZ $0E
    LDA $5F
    STA $0F
    BRA ++
+   REP #$20
    LDA $13D7|!addr
    STA $0E
    SEP #$20
++

if !OPT_pause_behavior == 0
    LDA $13D4|!addr ; don't run the routine when the game is paused
    BNE return
endif
    LDA $9D
    BEQ +
    EOR #$FF
    BEQ +
    RTL
    +
    LDA #$FF
    STA $9D

if !OPT_blackout_screen
    STZ $0DAE|!addr
endif

    REP #$20
if !OPT_vertical_scrolling
    LDA $1464|!addr
    CMP !RAM_Vert_LayerBackup
    BEQ +
    BCC .addVrt
    SEC : SBC.w #!DEF_vert_scroll_speed
    BRA .strVrt
.addVrt
    CLC : ADC.w #!DEF_vert_scroll_speed
.strVrt
    STA $1464|!addr
    SEP #$20
    if !OPT_pause_behavior
    LDA #$02 ; prevent pausing during a transition
    STA $13D3|!addr
    endif
    RTL
endif

if !OPT_horizontal_scrolling
+   LDA $1462|!addr
    CMP !RAM_Horz_LayerBackup
    BEQ +
    BCC .addHrz
    SEC : SBC.w #!DEF_horz_scroll_speed
    BRA .strHrz
.addHrz
    CLC : ADC.w #!DEF_horz_scroll_speed
.strHrz
    STA $1462|!addr
    SEP #$20
    if !OPT_pause_behavior
    LDA #$02 ; prevent pausing during a transition
    STA $13D3|!addr
    endif
    RTL
endif


; vertical screen scrolling
if !OPT_vertical_scrolling
+   LDA $96
    CLC : ADC.w !DEF_y_offset
    STA $00
    LDA !RAM_Vert_LayerBackup
    CMP $00
    BPL .subtractVert
    CLC : ADC.w #!DEF_screen_height
    CMP $00
    BMI .storeVert
    BRA .skipVert
.subtractVert
    SEC : SBC.w #!DEF_screen_height
.storeVert
    CMP #$0000
    BMI .skipVert
    CLC : ADC #$00E0
    CMP $0E
    BCS .skipVert
    SEC : SBC #$00E0
    STA !RAM_Vert_LayerBackup
.skipVert
endif


; horizontal screen scrolling
if !OPT_horizontal_scrolling
+   LDA $94
    CLC : ADC.w !DEF_x_offset
    STA $00
    LDA !RAM_Horz_LayerBackup
    CMP $00
    BPL .subtractHorz
    CLC : ADC.w #!DEF_screen_width
    CMP $00
    BMI .storeHorz
    BRA .skipHorz
.subtractHorz
    SEC : SBC.w #!DEF_screen_width
.storeHorz
    CMP #$0000
    BMI .skipHorz   ; don't store if the result is before screen 0
    STA !RAM_Horz_LayerBackup
.skipHorz
endif


; side border code
+   LDA $1462|!addr
    SEC : SBC.w #!DEF_screen_width
    BPL .noBorderLeft
    LDA $94
    SEC : SBC $1462|!addr
    CMP #$0080
    BCC .activeBorder
.noBorderLeft
    LDA $5B
    AND #$0001
    TAX
    LDA $5E,x
    AND #$00FF
    XBA
    SEC : SBC #$0100
    SEC : SBC.w #!DEF_screen_width
    CMP $1462|!addr
    BPL .noBorderRight
    LDA $94
    SEC : SBC $1462|!addr
    CMP #$0080
    BPL .activeBorder
.noBorderRight
    SEP #$20


;.disableBorder
    LDA #$AC
    STA $1B96|!addr
    BRA .done
.activeBorder
    SEP #$20
    STZ $1B96|!addr
.done
if !OPT_blackout_screen
    LDA #$0F
    STA $0DAE|!addr
endif
    STZ $9D ; > Unpause game
    RTL

assert !DEF_screen_width%!DEF_horz_scroll_speed == 0, "The horizontal scroll speed must be divisible by the screen width."
assert !DEF_screen_height%!DEF_vert_scroll_speed == 0, "The vertical scroll speed must be divisible by the screen height."
