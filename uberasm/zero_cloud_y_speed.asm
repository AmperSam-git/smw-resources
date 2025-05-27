main:

.check_if_in_cloud
    LDA $18C2|!addr : BNE .return

.zero_cloud_y_speed
    LDX #!sprite_slots-1
    -
    LDA !9E,x
    CMP #$87
    BNE +
    STZ !sprite_speed_y,x
    +
    DEX
    BPL -

.return
    RTL