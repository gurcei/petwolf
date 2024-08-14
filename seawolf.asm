// ====================
// SEA WOLF DISASSEMBLY
// ====================
!to "seawolf.prg", cbm

!macro bit_skip_1_byte {
  !byte $24
}

!macro bit_skip_2_bytes {
  !byte $2c
}

// ----------------
// global variables
// ----------------
scr_ptr_lo = $02  // (low-byte) pointer to screen memory
scr_ptr_hi = $03  // (high-byte) pointer to screen memory
clr_ptr_lo = $04  // (low-byte) pointer to colour memory
clr_ptr_hi = $05  // (high-byte) pointer to colour memory
ret_ptr_lo = $06  // (low-byte) address to return to after call to draw_inline_text
ret_ptr_hi = $07  // (high-byte) address to return to after call to draw_inline_text
genvarB = $08    // usage varies
genvarA = $09  // usage varies
curr_ship_mirror_state = $0a 
//
//- can either be:
//  - #$01 = normal (ship faces to the right, will travel left to right)
//  - #$ff = mirrored (ship faces to the left, will travel right to left)
//
missile_chardata_row_iterator = $0e
// iterator to write out the 8 bytes of small_missile_char_data_x_offset0/2 into genarrayA at a desired y-offset relating to missile position
//
//- in missile_redraw_assessment:
//  - sta at $e4b0  ; (set it to #$08) 
//  - dec at #e4be (index for loop_back_to_next_row loop)
//
offset_to_char_idx_of_2x2_missile_chars = $0f  // offset to char index of 2x2 missile chars
//
//- missile_redraw_assessment:
//  - sta at $e47c (multiply by 4  ; so now ship0 = 0, ship1 = 4, ship2 = 8, ... ship7 = 28)
//    - reg A will equal one of the following, depending on which missile is referenced:
//      ; p1_missile4 = #$00, p1_missile3 = #$04
//      ; p1_missile2 = #$08, p1_missile1 = #$0c
//      ; p2_missile4 = #$10, p2_missile3 = #$14
//      ; p2_missile2 = #$18, p2_missile1 = #$1c
//
offset_to_char_data_addr_of_2x2_missile_chars = $10 
xpos_local = $11  // (a place to temporarily store x-position of current ship/missile/buoy)
ypos_local = $12  // (a place to temporarily store y-position of current ship/missile/buoy)
txt_x_pos = $13  // the x-position to draw text from  :  set to #$12 (18) in print_remaining_game_time
txt_y_pos = $14  // the y-position (row) to draw text from  :  set to #$18 (24) in print_remaining_game_time
real_game_mode_flag = $16  // (is it some kind of attract-mode flag?)
//
//- if set to #$FF, this means user will control the paddles for real gameplay
//- if set to #$00, attract mode is on. This means that computer will control both paddles automatically for attract mode
//
initial_game_time   = $17 // (in minutes?)
buff_spr2spr_coll = $18  // buffered value of sprite-to-sprite collision
buff_spr2back_coll = $19  // buffered value of sprite-to-background collision
randomval_lsb = $1B 
randomval_msb = $1C 
p1_score_lo = $1D  //the low two-digits of player1 score : set to #$00 in start_game
p2_score_lo = $1E  //the low two-digits of player2 score : set to #$00 in start_game
p1_score_hi = $1F  //the high two-digits of player1 score : set to #$00 in start_game
p2_score_hi = $20  //the high two-digits of player2 score : set to #$00 in start_game
high_score_lo = $21  //the low two-digits of high score
high_score_hi = $22  //the high two-digits of high score
iterator_local = $23  //(possibly a general index var used for different purposes in different places)
buoy_movement_timer = $24 
buoy_pair_index = $25 
//
//- Can either be:
//-   0: buoys 0 and 1 will be assessed
//-   2: buoys 2 and 3 will be assessed
//
secs_in_minute_left = $26  // maybe a seconds in the minute countdown
decimal_secs_in_minutes_left = $27 
minutes_left = $28  // (in minutes?) (in decimal mode)
idx_to_v1_ptboat_beep_beep_freq_array = $2a 
//
//- This is an index to an array describing on which frames will there be a beep sound made for the p.t. boat
//  - The array is v1_ptboat_beep_beep_freq_array
//  - Some entries in the array are #$0000 (silence), while others are the beep frequency, #$4EE8
//
v2_missile_fire_snd_counter = $2b 
  // - sta at $e955 (set to #$03)
v3_explosion_snd_counter = $2c 
  // - lda at $e97f
general_sound_timer = $2d 
//
//- lda at $e967
//- dec at $e96b (only if general_sound_timer is not yet zero)
//- sta at $e970 (if it was previousy zero, it will be now set to #$03)
//
curr_missile_colour = $2e 
missile_reload_timers = $2f  // to $2f-$30 [2]: countdown-to-zero timers for each player, to decide when missiles for player are reloaded
//
//  - timers start at #$B4 (180) - equates to "TIME TO LOAD: 3 SECONDS."
//  - when timer reaches #$78 (120) -  msg is "TIME TO LOAD: 2 SECONDS."
//  - when timer reaches #$3C (60)  -  msg is "TIME TO LOAD: 1 SECONDS."
//
//  - sta at $e306 (set to #$B4/dec180) it sets only if no# missiles left after shot is zero
p1_num_missiles = $31 
p2_num_missiles = $32  //set to #$04 in init_game_vars
last_paddle_fire_state = $33  // $33-$34 [2]:  
//
//- used to assure one-shot logic of the fire button (not rapid fire)
//- sta at $e2c3  (set to #$00)  - paddle fire button is off
//- sta at $e2d3  (set to #$ff)  - paddle fire button is on
//
players_xpos = $35  // $35-36 [2]:
//  - [0] = player1 x-pos in pixel units
//  - [1] = player2 x-pos in pixel units
//
//                 - submarine chars can only be drawn on columns 0 to 39
//                 - but I think the value stored here is x4 (so from 0 to 159)
//                   (as it is divided by 4 later in $e410)
//- sta at $e442 (it is later divided by 4 and used as an x-pos to draw the player's submarine)
//
attract_mode_player_xpos_waypoint = $37  // $37-38 [2]: for player1 and 2
ships_visibility = $39  // $39-$3c [4]: visibility of ships
//
//                 - #$00 = invisible
//                 - #$01 = visible
//                 - #$ff = shot/exploding
//                 (the negative-flag seems critical, and causes 'ship_is_currently_exploding')
//
ships_move_tmr = $3d  // $3d-40 [4]:  count-down timer of when to move ships along (I guess it counts down from larger amounts for slower ships?)
ships_move_max_time = $41  // $41-44 [4]: keeps a record of the max-count of frames the ship at this index needs to wait before moving
//- lda at $e07d
ships_xpos = $45  // $45-48 [4]: x-pos of all ships
ships_ypos = $49  // $49-4c [4]: y-pos of all ships
ships_mirror_flag = $4d  // $4d-50 [4]:  ; mirror orientation of all ships (01 = normal, FF = reversed?)
ships_type = $51  // $51-54 [4]:
//ship-type of all ships (idx 0-3) #$00=freighter, #$01=cruiser, #$02=p.t. boat
ships_explosion_tmr = $55  // $55-5c [8]:
// explosion duration countdown timer of each ship (and buoy)
// (is divided by 8 to decide which explosion frame to show - F9, F5 or F1)
//  - sta at $e053  (sets it to max timer value of #$18 / 24)
buoys_visibility = $5d  // $5d-$60 [4]:
//
//                 - #$00 = invisible
//                 - #$01 = visible
//                 - #$ff = shot/exploding
//- sta at $e218 (sets it to #$ff) (if xpos of buoy <12 or >=254)
//- lda at $e224
//- sta at $e253 (sets it to #$00 - on occasions when x-pos > 148)
//- sta at $e349 (set to #$01)
//
buoys_xpos = $61  // $61-64:  [4]:  (array of all buoy x-positions)
buoys_ypos = $65  // $65-68:  [4]:  (array of all buoy y-positions)
//
//        - (have values of either #$60 or #$80)
//        - (the absolute sprite x-pos for these is #$92 and #$B2)
//        - (that's a difference of #$32)
//
buoys_explode_timer = $69  // $69-6c: [4]:
//
//- upon a buoy exploding, it is set to 24, and decremented every frame
//- its value is divided by 8 to assist as an index to which explosion frame to show (0 - 2)
//- in buoy_logic:
//  - sta at $e21c (set to #$18 / dec24) - in response to a buoy being hit by a missile
//
torpedo_fire_xpos = $6d  // $6d-74 [8]:  (x-positions of all torpedoes)
torpedo_fire_ypos = $75  // $75-7c [8]:  (y-positions of all torpedoes)
//
//- the missile-fire starts at ypos dec160, decrements until it reaches less than dec16
//
//  - sta at $e52c (sets it to #$00 / dec0) (this occurs when missile-fire is no longer visible on screen)
// (if the ypos of the missile is less than #$10 / dec16, it will become invisible)
torpedo_fire_state = $7d  // $7d-84 [8]: 
//
//- #$00 = fired (is currently active on screen)
//- #$ff = not fired yet (no longer visible on screen)
//(index is the missile-index that hit the ship)
//- sta at $e046 (sets it to #$ff upon a missile hitting a ship)
//- sta at $e215 (sets it to #$ff upon a missile hitting a buoy)
//- sta at $e2f3 (sets it to #$00 upon a missile being fired by a player)
//
genarrayA = $85  // $85-A4 [32]:
//
//- multi-purpose array
//- PURPOSE1: within 'ship_logic:'
//  - is used to store a list of existing ship indexes that are on the same ypos as the newly spawned ship
//                  (these are sorted on their xpos, depending on the mirror/direction the ships are going)

//- PURPOSE2: within 'missile_redraw_assessment:'
//  - prepares the missile chars needed for each player's missile custom char-based soft-sprites
//    - which is then copied down to vic-bank0 at $0300 - $03ff
//    - I.e., vicbank0_missile_chars_for_player1/2
//
filtered_player_xpos = $fe  // $fe-ff [2]:
//
//- This stores the smoothed/filtered x-pos of the player's sub in 0-148 range (2-pixel units / pixel-pairs)
//- This value is calculated within 'read_paddle_position'
//- Later at $E442, it is copied across to 'players_xpos'
//- adc at $F109
//- sta at $F11F
//
vicbank0_sub_chars_for_player1 = $02a8  // $02a8-02cf [5][8]:
//
//- The custom char-based soft-sprite used for player1's submarine, whose contents are copied from
//  from submarine_charset1/2/3/4 ($ee48), depending on which 2-pixel location the sub is at 
// 
//char idx $55-59 address: $02A80-02
//+--------+--------+--------+--------+--------+
//|        |        | **     |        |        |
//|        |       *|*****   |        |        |
//|        |       *|*****   |        |        |
//|    ****|********|********|********|        |
//|  ******|********|********|********|**      |
//|  ******|********|********|********|**      |
//|    ****|********|********|********|        |
//|        |        |        |        |        |
//+--------+--------+--------+--------+--------+

vicbank0_sub_chars_for_player2 = $02d0  // $02d0-02ff [5][8]:
//
//- The custom char-based soft-sprite used for player2's submarine, whose contents are copied from
//  from submarine_charset1/2/3/4 ($ee48), depending on which 2-pixel location the sub is at 
//+--------+--------+--------+--------+--------+
//|        |        |     ** |        |        |
//|        |        |   *****|*       |        |
//|        |        |   *****|*       |        |
//|        |********|********|********|****    |
//|      **|********|********|********|******  |
//|      **|********|********|********|******  |
//|        |********|********|********|****    |
//|        |        |        |        |        |
//+--------+--------+--------+--------+--------+

vicbank0_missile_chars_for_player1 = $0300  // $0300-037F [4][4][8]:
//
//([4 missiles][4 chars per missile][8 bytes per char])
//  - sta at $e4fa  (seems to copy across a chunk of genarrayA?)
//- E.g. if player1 has fired all 4 missiles, it may look like this:

// MISSILE 4           MISSILE 3           MISSILE 2           MISSILE 1
//+--------+--------+ +--------+--------+ +--------+--------+ +--------+--------+
//|60   ** |62      | |64      |66      | |68      |6a      | |6c      |6e      |
//|     ** |        | |        |        | |        |        | |        |        |
//|    ****|        | | *      |        | |       *|        | |       *|        |
//|    ****|        | |***     |        | |      **|*       | |      **|*       |
//|    ****|        | |***     |        | |      **|*       | |      **|*       |
//|    ****|        | |***     |        | |      **|*       | |      **|*       |
//|    ****|        | |***     |        | |      **|*       | |      **|*       |
//|     ** |        | | *      |        | |       *|        | |       *|        |
//+--------+--------+ +--------+--------+ +--------+--------+ +--------+--------+
//|61      |63      | |65      |67      | |69      |6b      | |6d      |6f      |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//+--------+--------+ +--------+--------+ +--------+--------+ +--------+--------+

vicbank0_missile_chars_for_player2 = $0380  // $0380-03ff [4][4][8]:
//
//([4 missiles][4 chars per missile][8 bytes per char])
//- E.g. if player2 has fired all 4 missiles, it may look like this:
 //MISSILE 4           MISSILE 3           MISSILE 2           MISSILE 1
//+--------+--------+ +--------+--------+ +--------+--------+ +--------+--------+
//|70      |72      | |74      |76      | |78      |7a      | |7c      |7e      |
//|        |        | |        |        | |        |        | |        |        |
//|        |        | |   *    |        | | *      |        | |   *    |        |
//|        |        | |  ***   |        | |***     |        | |  ***   |        |
//|        |        | |  ***   |        | |***     |        | |  ***   |        |
//|        |        | |  ***   |        | |***     |        | |  ***   |        |
//|        |        | |  ***   |        | |***     |        | |  ***   |        |
//|   **   |        | |   *    |        | | *      |        | |   *    |        |
//+--------+--------+ +--------+--------+ +--------+--------+ +--------+--------+
//|71 **   |73      | |75      |77      | |79      |7b      | |7d      |7f      |
//|  ****  |        | |        |        | |        |        | |        |        |
//|  ****  |        | |        |        | |        |        | |        |        |
//|  ****  |        | |        |        | |        |        | |        |        |
//|  ****  |        | |        |        | |        |        | |        |        |
//|  ****  |        | |        |        | |        |        | |        |        |
//|   **   |        | |        |        | |        |        | |        |        |
//|        |        | |        |        | |        |        | |        |        |
//+--------+--------+ +--------+--------+ +--------+--------+ +--------+--------+

//--------------------------------

* = $0801

// BASIC Stub
  !word basic_end   // pointer to next basic line
  !word $0a         // line 10
  !byte $9e         // 'SYS' command
  !text "2061"      // '2061'
  !byte $00         // end of current basic line
basic_end:
  !word $00         // end of basic program

initialise:
    ; switch kernal rom off
    ; ---------------------
    sei
    lda  #$E5   ; %1110 0101
    sta  $01    ; (cassette-motor=off, cassette-switch=closed, char-rom-in=no, kernal-rom=off, basic-rom=on)

    ; copy cartridge rom contents to $E000
    ; ------------------------------------

    ; $02 word ptr holds SOURCE address of copy
    lda #<rom_start
    sta $02
    lda #>rom_start
    sta $03

    ; $04 word ptr holds DEST address of copy
    lda #$00
    sta $04
    lda #$e0
    sta $05

    ; $06 word = size to copy
    lda #$00
    sta $06
    lda #$20
    sta $07

    jsr copy_chunk

    ; copy $F000-$FFFF to $3000-$3FFF (to mirror ultimax mirroring behaviour)

    ; $02 word ptr holds SOURCE address of copy
    lda #$00
    sta $02
    lda #$f0
    sta $03

    ; $04 word ptr holds DEST address of copy
    lda #$00
    sta $04
    lda #$30
    sta $05

    ; $06 word = size to copy
    lda #$00
    sta $06
    lda #$10
    sta $07

    jsr copy_chunk

    ; now start up the cartridge!
    ; --------------------------
    jmp cold_start_handler


copy_chunk:
    ldy #$00
    lda ($02),y   ; get source byte
    sta ($04),y   ; write to dest addr

    ; decrement counter
    dec $06
    lda $06
    cmp #$ff
    beq dec_high_byte_too
    ora $07  ; if both are zero, time to finish
    bne continue_copy
    rts

dec_high_byte_too:
    dec $07
    lda $07
    ora $06   ; if both are zero, time to finish

continue_copy:
    ; increment src and dest ptrs
    inc $02
    lda $02
    cmp #$00
    bne +
    inc $03
+
    inc $04
    lda $04
    cmp #$00
    bne +
    inc $05
+
    jmp copy_chunk

//--------------------------------

;--------
rom_start:
;--------

!pseudopc $E000 {


// LOCATION: E000
ship_logic:
//--------
// has logic to spawn new ships when needed
// also checks for missile-to-ship collisions
    LDA  #$03  ; iterator over all 4 possible ships
    STA  iterator_local  ; $23
retry_next_possible_ship:
    LDX  iterator_local  ; $23  (ship iterator)
    LDA  ships_visibility,x  ; $39,X  ; perhaps visibility of all ships
    BNE  current_ship_visible_or_exploding  ; $E00D
    JMP  current_ship_not_visible  ; $E0D5  ; if $39,x is zero, then we do this jump
current_ship_visible_or_exploding:
    LDA  ships_ypos,x  ; $49,X  ; y-pos of all ships
    STA  ypos_local  ; $12  ; y-pos of current ship
    LDA  ships_xpos,x  ; $45,X  ; x-pos of all ships
    STA  xpos_local  ; $11  ; x-pos of current ship
    LDA  buff_spr2back_coll  ; $19
    AND  or_bitfields,x  ; $EE38,X  ; x = currently assessed ship (from 0 - 3)
    BEQ  no_spr2back_collision_detected  ; $E070  ; if no sprite-to-back collision for this sprite-x, then branch
; if we're here, then there was a ship to missile-fire collision
    LDY  ships_type,x  ; $51,X  ship-type of all ships (idx 0-3) #$00=freighter, #$01=cruiser, #$02=p.t. boat
    LDA  ship_type_widths,y  ; $EE0E,Y
    STA  genvarB  ; $08
// now figure out which of the 8 potential missiles hit this ship
    LDY  #$07
retry_next_missile:
// assess if this missile is in a valid yrange to have hit this ship
    LDA  torpedo_fire_ypos,y  ; $0075,Y  ; y-position of all torpedoes (4 for player1 and 4 for player2)
    BEQ  curr_torpedo_out_of_yrange_of_hit_ship  ; $E03F
    SEC
    SBC  ypos_local  ; $12  ; y-pos of current ship
    CMP  #$10  ; (dec16)
    BCS  curr_torpedo_out_of_yrange_of_hit_ship  ; $E03F  ; branch if >= 16
// yrange was valid, so now check missile is within xrange of hit ship
    LDA  torpedo_fire_xpos,y  ; $006D,Y  ; x-pos of all torpedoes (y=currently indexed torpedo)
    SEC
    SBC  xpos_local  ; $11  ; x-pos of current ship
    CMP  #$FE
    BCS  curr_torpedo_is_within_xrange_of_hit_ship  ; $E044  ; branch if >= 254
    CMP  genvarB  ; $08  ; contains a given ship_type_width,y
    BCC  curr_torpedo_is_within_xrange_of_hit_ship  ; $E044
curr_torpedo_out_of_yrange_of_hit_ship:
    DEY
    BPL  retry_next_missile  ; $E025
    BNE  no_spr2back_collision_detected  ; $E070
curr_torpedo_is_within_xrange_of_hit_ship:
    LDA  #$FF  ; #$ff = this torpedo is no longer visible
    STA  torpedo_fire_state,y  ; $007D,Y  (y=missile index that hit ship)
    LDA  ships_visibility,x  ; $39,X
    BMI  no_spr2back_collision_detected  ; $E070
    LDA  #$FF
    STA  ships_visibility,x  ; $39,X
    LDA  #$18  ; dec24
    STA  ships_explosion_tmr,x  ; $55,X
    LDA  missiles_colour_table,y  ; $EFAC,Y  ; seems to choose either yellow or orange?
    STA  $D027,X  ; $d027-$d02e = sprite 0-7 colours
    LDA  ships_type,x  ; $51,X   ship-type of all ships (idx 0-3) #$00=freighter, #$01=cruiser, #$02=p.t. boat
    TAX
    LDA  ship_scores,x  ; $EE1F,X
    PHA
    TYA
    LSR
    LSR
    TAX
    PLA  ; A = score of ship that was hit (in units of 100's - i.e. skipping trailing two digits)
    JSR  add_points_to_score_then_update_high_score_and_reprint  ; $E6E0
    JSR  trigger_voice3_sound  ; $E95D  ; (probably explosion sound?)
    JMP  super_duper_big_jump  ; $E1BD
no_spr2back_collision_detected:
    LDA  ships_visibility,x  ; $39,X
    BMI  ship_is_currently_exploding  ; $E0C2  ; is the ship currently exploding?
    LDA  ships_move_tmr,x  ; $3D,X
    BEQ  time_to_move_curr_ship_along  ; $E07D
    DEC  ships_move_tmr,x  ; $3D,X
    JMP  super_duper_big_jump  ; $E1BD
time_to_move_curr_ship_along:
// move the ship along a small increment along the x-axis?
    LDA  ships_move_max_time,x  ; $41,X
    STA  ships_move_tmr,x  ; $3D,X
    LDA  xpos_local  ; $11  ; x-position of current ship
    CLC
    ADC  ships_mirror_flag,x  ; $4D,X  ; mirror orientation of ships (#$01 normal, #$ff reversed)
    STA  xpos_local  ; $11
    STA  ships_xpos,x  ; $45,X  ; x-pos of all ships
    CMP  #$A0  ; dec160
    BCS  turn_off_ship  ; $E0B6  ; branch if >= 160
    LDY  ships_type,x  ; $51,X  ; ship-type of all ships
    CLC
    ADC  ship_type_widths,y  ; $EE0E,Y  ; some amount to add to x-pos, depending on ship-type
    CMP  #$A0  ; dec160
    BCS  turn_off_ship  ; $E0B6  ; branch if new x-pos is >= 160  ; ship has gone out of range?
    TXA
    JSR  set_sprite_position  ; $E8B4  (curr ship x,y vals in xpos_local/$11 and ypos_local/$12)
    LDX  iterator_local  ; $23  ; current ship-index
    LDA  ships_mirror_flag,x  ; $4D,X  ; mirror orientation of ships? (#$01 normal, #$ff reversed?)
    AND  #$04
    ORA  ships_type,x  ; $51,X  ; ship-type of all ships
    CLC
    ADC  #$EE  ; sprite ee is sprite-pointer to the 1st boat (ee=freighter), ef=cruiser, f0=pt-boat
                                        ; if ships reversed, then f2=freighter, f3=cruiser, f4 = pt-boat
    STA  $07F8,X  ; $07f8 to $07ff = sprite pointers
    JSR  set_sprite_colour  ; $F125
    NOP
    NOP
    TXA
    JSR  turn_on_sprite_A  ; $E8DD
skip_back:
    JMP  super_duper_big_jump  ; $E1BD
turn_off_ship:
  // ship has gone out of range, time to switch it off? 
    LDX  iterator_local  ; $23  ; idx to current ship
    LDA  #$00
    STA  ships_visibility,x  ; $39,X
    TXA
    JSR  turn_off_sprite_A  ; $E8E8
    BEQ  skip_back  ; $E0B3  ; branch if all sprites are off?
ship_is_currently_exploding:
    DEC  ships_explosion_tmr,x  ; $55,X
    BEQ  turn_off_ship  ; $E0B6
    LDA  ships_explosion_tmr,x  ; $55,X
    LSR
    LSR
    LSR  ; divide a by 8
    TAY
    LDA  explosion_sprite_pointers,y  ; $E1C5,Y
    STA  $07F8,X  ; set current explosion frame sprite for this ship
    JMP  super_duper_big_jump  ; $E1BD
current_ship_not_visible:
  // we jumped here due to current ship not being visible
; randomly decide if we should spawn a new ship now
    JSR  random_num_gen_into_A  ; $E893  ; it will return some magic value in A (based on randomval_lsb and randomval_msb)
    CMP  #$03  ; make the spawning of a new ship a low-probability occurence (3 in 256 chance, i.e., 1/85)
    BCC  decide_new_ship_details  ; $E0DF  ; if A value < 3 then branch
    JMP  super_duper_big_jump  ; $E1BD
decide_new_ship_details:
; randomly decide if new ship should be on top or bottom row
    JSR  random_num_gen_into_A  ; $E893  ; random_num_gen_into_A returns another magic value in A
    AND  #$20  ; this might set bit 5 or result in zero
               ; randomly decide if the new ship should be on top-row or bottom-row (dec0 or dec32)
    CLC
    ADC  #$18  ; A can either be:
               ;   #$18 (24) for top-row ypos of new ship,  or...
               ;   #$38 (56) for bottom-row ypos of new ship
               ; (add #$32 to these to get absolute ypos for ships, either #$4A or #$6A)
    LDX  iterator_local  ; $23  ; curr ship idx
    STA  ships_ypos,x  ; $49,X  ; y-pos of all ships
    STA  genvarB  ; $08  ; let genvarB = y-pos of current ship (newly spawned)
//+decide_new_ship_type:
    JSR  random_num_gen_into_A ; $E893  ; get some other magic value in A
    CMP  #$50  ; dec80
    BCC  skip_to_lda_2  ; $E0FE  ; branch if A<80  ; if under 80, let it be a pt boat
    CMP  #$A0  ; dec160
    BCC  skip_to_lda_1  ; $E0FB  ; branch if A<160  ; else if under 160, let it be a cruiser
    LDA  #$00                     ; else it's a freighter (highest probability)
    +bit_skip_2_bytes
skip_to_lda_1:
      LDA  #$01
    +bit_skip_2_bytes
skip_to_lda_2:
      LDA  #$02
    STA  genvarA  ; $09  ; new ship-type of newly spawned ship
some_comparison_of_this_new_ship_against_existing_ships:
  // perhaps to see if they clash?
    LDY  #$00
    LDX  #$03
ship_compare_retry:
    LDA  ships_visibility,x  ; $39,X  ; is ship at this index visible yet?
    BEQ  ship_compare_skip  ; $E115    ; branch if not visible?
    LDA  ships_ypos,x  ; $49,X  ; y-pos of all ships
    CMP  genvarB  ; $08  ; y-pos of current ship?
    BNE  ship_compare_skip  ; $E115  ; if new ship has different y-pos to existing ships, then branch
    TXA
    STA  genarrayA,y  ; $0085,Y
    INY
ship_compare_skip:
    DEX
    BPL  ship_compare_retry  ; $E106
    TYA  ; y = the number of existing ships that are on the same ypos as newly spawned ship
    BEQ  no_other_ships_on_row  ; $E18A  ; branch if no other existing ships are on the same ypos as newly spawned ship
    STA  genvarB  ; $08  ; the number of existing ships that are on the same ypos as newly spawned ship
    DEC  genvarB  ; $08
    LDX  genarrayA  ; $85  ; the first existing ship-idx on same y-pos as newly spawned ship
    LDA  ships_mirror_flag,x  ; $4D,X  ; mirror orientation of all ships? (01=normal, ff=reversed)
    STA  curr_ship_mirror_state  ; $0A  ; the mirror orientation of the first existing ship on same ypos as newly spawned ship
    BMI  ship_goes_right_to_left  ; $E150  ; if mirror orientation = $ff (mirrored), then branch
    CPY  #$01
    BEQ  get_xpos_of_closest_existing_ship_on_left  ; $E149  ; if no# of existing ships on same ypos as new ship is only one, then branch
restart_sort_algo_after_swapping_ship_pair:
    LDY  #$00    ; if we're here, then there are multiple existing ships on same ypos as new ship
loop_for_current_ship_sort:
// some kind of sorting logic?
    LDX  genarrayA,y  ; $85,Y  ; idx of existing ships on same ypos as new ship
    LDA  ships_xpos,x  ; $45,X  ; x-pos of all ships (x = index of an existing ship from the genarrayA list)
    LDX  genarrayA+1,y  ; $86,Y  ; idx of existing ship after this prior one
    CMP  ships_xpos,x  ; $45,X  ; compare 1st ship's xpos with 2nd ships xpos
    BCC  no_need_to_swap_pair  ; $E144  ; if 1st existing ship's xpos is less than 2nd existing ship's xpos, then branch
    BEQ  no_need_to_swap_pair ; $E144   ; or if their xpos are equal, branch too
// need to swap pair to sort them in order
    LDA  genarrayA,y  ; $0085,Y  ; a = xpos of 1st existing ship
    STX  genarrayA,y  ; $85,Y     ; let the 1st ship xpos now equal the 2nd ship xpos
    STA  genarrayA+1,y  ; $0086,Y  ; let the 2nd ship xpos now equal the 1st ship xpos (i.e. swap them)
    JMP  restart_sort_algo_after_swapping_ship_pair  ; $E12B
no_need_to_swap_pair:
    INY
    CPY  genvarB  ; $08  ; the number of existing ships that are on the same ypos as newly spawned ship minus one
    BCC  loop_for_current_ship_sort  ; $E12D  ; if incremented y < no# of existing ships on same ypos minus one, then branch
get_xpos_of_closest_existing_ship_on_left:
    LDX  genarrayA  ; $85  ; 1st of existing (and sorted ships) that is closest to the left screen edge
    LDA  ships_xpos,x  ; $45,X  ; x-pos of all ships
    JMP  compare_xpos_of_closest_ship_to_new  ; $E177
ship_goes_right_to_left:
// mirrored orientation (ships on this row are currently moving right to left)
    CPY  #$01  ; the number of existing ships that are on the same ypos as newly spawned ship
    BEQ  get_xpos_of_closest_existing_ship_on_right  ; $E170  ; if there's only one existing ship on this row, then branch (no need to sort?)
restart_sort_mirrored_algo_after_swapping_ship_pair:
// sorting logic for mirrored case
    LDY  #$00
loop_for_mirrored_current_ship_sort:
    LDX  genarrayA,y  ; $85,Y  ; idx of existing ships on same ypos as new ship
    LDA  ships_xpos,x  ; $45,X  ; get xpos of 1st existing ship
    LDX  genarrayA+1,y  ; $86,Y  ; get idx of 2nd existing ship
    CMP  ships_xpos,x  ; $45,X ; compare 1st ship's xpos with 2nd ship's xpos
    BCS  mirrored_no_need_to_swap_pair  ; $E16B  ; if 1st ship's xpos is >= 2nd ship's xpos, then branch (no need to swap for sort)
    LDA  genarrayA,y  ; $0085,Y  ; a = xpos of 1st ship
    STX  genarrayA,y  ; $85,Y    ; let 1st ship xpos now equal 2nd ship xpos
    STA  genarrayA+1,y  ; $0086,Y  ; let 2nd ship xpos now equal 1st ship xpos (i.e. swap them)
    JMP  restart_sort_mirrored_algo_after_swapping_ship_pair  ; $E154
mirrored_no_need_to_swap_pair:
    INY
    CPY  genvarB  ; $08  ; the number of existing ships on same ypos as new ship minus one
    BCC  loop_for_mirrored_current_ship_sort  ; $E156  ; if incrementeed y < no# existing ships on same ypos minus one, then branch
get_xpos_of_closest_existing_ship_on_right:
    LDX  genarrayA  ; $85  ; 1st of existing (and sorted ships) that is closest to the right screen edge
    LDA  #$88  ; dec136 (the right-most edge's xpos)
    SEC
    SBC  ships_xpos,x  ; $45,X  ; A = right_edge_xpos - 1st_existing_sorted_ships_xpos
compare_xpos_of_closest_ship_to_new:
// assess the gap between closest existing ship and newly spawned ship
    STA  genvarB  ; $08  ; holds x-width between the spawn-edge (left or right) and the closest existing ship
    LDA  ships_type,x  ; $51,X  ; get the ship-type of the closest ship to the spawn-edge
    ASL  ; multiply by 2
    ADC  ships_type,x  ; $51,X  ; a bit like multiply by 3  ; freighter=00, cruiser=3, ptboat=6
    ADC  genvarA  ; $09  ; newly-spawned ship-type
    TAX
    LDA  map_gap_from_existing_ship_to_new_ship,x  ; $EE13,X
    CMP  genvarB  ; $08  ; compare with x-width between spawn-edge and closest existing ship
    BCS  not_big_enough_gap_yet  ; $E1BD  ; branch if required_gap >= x-width spawn-edge to closest ship
    BCC  sufficient_gap_to_spawn_new_ship  ; $E197
no_other_ships_on_row:
//-------------------
// decide whether ship should move left-to-right (normal) or right-to-left (mirrored)
    JSR  random_num_gen_into_A  ; $E893  ; put magic number in A
    TAY
    BMI  skip_to_set_ship_mirrored  ; $E193  ; if neg-bit is on (i.e., range=128to255), then branch
         ; This is giving a 50/50 chance of the ship moving from left-to-right (normal) or right-to-left (mirrored)
    LDA  #$01  ; current ship = normal
    +bit_skip_2_bytes
skip_to_set_ship_mirrored:
      LDA  #$FF  ; current ship = mirrored
    STA  curr_ship_mirror_state  ; $0A  ; set curr ship to mirrored
sufficient_gap_to_spawn_new_ship:
    LDX  iterator_local  ; $23  ; idx to curr ship
    LDA  #$01
    STA  ships_visibility,x  ; $39,X  ; ship visibility table, set it to 1/visible
    STA  ships_move_tmr,x  ; $3D,X
    LDA  genvarA  ; $09  ; newly-spawned ship-type?
    STA  ships_type,x  ; $51,X  ; ship-type of all ships
    TAY
    LDA  ships_movement_delay,y  ; $EE1C,Y  ; find the movement frame-rate delay for this ship-type
    STA  ships_move_max_time,x  ; $41,X  ; record the needed frame-rate delay count in this array
    CPY  #$02  ; is ship-type = pt-boat?
    BNE  skip_if_not_pt_boat  ; $E1B0  ; branch if not pt-boat
    JSR  v1_reset_and_gate_off  ; $E93C  ; turn off v1 if we've spawned a pt-boat
skip_if_not_pt_boat:
    LDA  curr_ship_mirror_state  ; $0A  ; current ship mirror-state ($01=normal, $ff=mirrored)
    STA  ships_mirror_flag,x  ; $4D,X  ; mirror orientation of all ships
    BPL  skip_to_lda_00  ; $E1B9  ; branch if normal ship-orientation
    LDA  #$88  ; a = #$88 (dec136) (the right-edge xpos) for reversed ship-mirror orientation
    +bit_skip_2_bytes
skip_to_lda_00:
      LDA  #$00  ; a = 0 (the left-edge xpos) for normal ship-mirror orientation
    STA  ships_xpos,x  ; $45,X  ; x-pos of all ships
not_big_enough_gap_yet:
super_duper_big_jump:
    DEC  iterator_local  ; $23  ; idx to curr ship
    BMI  exit_ship_logic_routine  ; $E1C4
    JMP  retry_next_possible_ship  ; $E004
exit_ship_logic_routine:
    RTS

// sprite ee: (freighter)

// +------------------------+
// | *  *  *                |
// |   *    *               |
// |                        |
// |        **              |
// |        **  **          |
// |   **   **  **          |
// |   **   **  **          |
// |   **   **  ***         |
// |** **   *******      ***|
// |*****  ** *** **  ******|
// |* ********* *** ********|
// |*** * ***************** |
// |*********************** |
// | *********************  |
// | ********************   |
// |  ******************    |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

 

// sprite ef: (cruiser)

// +------------------------+
// |                        |
// |                        |
// |                        |
// |       * *              |
// |  *   *                 |
// |    *    **             |
// |         **             |
// |      ** **             |
// |      ** *****          |
// |      ** ** ***    **** |
// |      ** **** *     *   |
// |***  ***********   *****|
// |*********************** |
// |**********************  |
// | ********************   |
// |  ******************    |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

 

// sprite f0: (p.t. boat)

    // p.t. boat = "Patrol Torpedo" boat was a motor torpedo boat used by the United States Navy in World War II. It was small, fast, and inexpensive to build, valued for its maneuverability and speed

// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |       *                |
// |       **               |
// |       ****             |
// |      ** * *            |
// |  **  **********        |
// |  *************         |
// |   ***********          |
// |   **********           |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+


// sprite f2: (freighter - reversed)

// +------------------------+
// |                *  *  * |
// |               *    *   |
// |                        |
// |              **        |
// |          **  **        |
// |          **  **   **   |
// |          **  **   **   |
// |         ***  **   **   |
// |***      *******   ** **|
// |******  ** *** **  *****|
// |******** *** ********* *|
// | ***************** * ***|
// | ***********************|
// |  ********************* |
// |   ******************** |
// |    ******************  |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+


// sprite f3: (cruiser - reversed)
// 
// +------------------------+
// |                        |
// |                        |
// |                        |
// |              * *       |
// |                 *   *  |
// |             **    *    |
// |             **         |
// |             ** **      |
// |          ***** **      |
// | ****    *** ** **      |
// |   *     * **** **      |
// |*****   ***********  ***|
// | ***********************|
// |  **********************|
// |   ******************** |
// |    ******************  |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+


// sprite f4: (pt boat - reversed)
// 
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                *       |
// |               **       |
// |             ****       |
// |            * * **      |
// |        **********  **  |
// |         *************  |
// |          ***********   |
// |           **********   |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

// LOCATION: E1C5
explosion_sprite_pointers:
  !byte $F9, $F5, $F1


// sprite F9
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |     *****              |
// |   **********           |
// |  * **********          |
// | * * **** * ****        |
// | *   ** ***   **        |
// |*   ********   **       |
// |*  *** ******   *       |
// |  * ****** * * *        |
// |** *** *** ******       |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

	
// sprite F5
// +------------------------+
// |  ** *     ****         |
// | * ** *   **  **        |
// |**   * * * *** *        |
// |*  *****  *   *         |
// |  *   *  * * **         |
// | *     * * **  *        |
// |   *** * **             |
// |  **  * **  ***         |
// | *   ***** *   *        |
// |    ** *******          |
// |   *  ***** * *         |
// |  *  ** ***  * *        |
// | *  ***** **            |
// |   * ********           |
// |  * ****** * *          |
// |** *** *** *****        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

	
// sprite F1
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |    **                  |
// |   *  **  ***           |
// |  *  **  **  *          |
// | ** * *****             |
// | ***** ***  ***         |
// |** **  ****   **        |
// |**** *** *** ***        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+


// LOCATION: E1C8
buoy_logic:
//---------
    LDA  buoy_movement_timer  ; $24
    BPL  buoy_timer_not_expired_yet  ; $E1D0
; reset timer after expiring
    LDA  #$0B  ; dec11
    STA  buoy_movement_timer  ; $24
buoy_timer_not_expired_yet:
    DEC  buoy_movement_timer  ; $24
    LDA  #$03  ; buoy iterator (3 to 0)
    STA  iterator_local  ; $23
loop_next_buoy:
// loops on a decrementing iterator_local until all the way to zero
    LDX  iterator_local  ; $23
    LDA  buoys_visibility,x  ; $5D,X
    BNE  buoy_is_visible_or_exploading  ; $E1DF  ; branch if non-zero
// if buoy is invisible, jump to next buoy
    JMP  jmp_to_next_buoy  ; $E275
buoy_is_visible_or_exploading:
    LDA  buoys_xpos,x  ; $61,X
    STA  xpos_local  ; $11  (x-position of current buoy)
    LDA  buoys_ypos,x   ; $65,X  ; (array of all buoy y-positions)
    STA  ypos_local  ; $12  (y-position of the current buoy)
    TXA
    ORA  #$04
    TAY
    LDA  buff_spr2back_coll  ; $19
    AND  or_bitfields,y  ; $EE38,Y
    BEQ  skip_due_to_no_spr_to_back_collision  ; $E224  ; branch if the bit isn't on (no spr-to-back collision with this sprite)
    LDY  #$07
loop_next_torpedo_to_buoy_collision_check:
    // assess y-range
    LDA  torpedo_fire_ypos,y  ; $0075,Y  ; y-pos of all torpedoes
    BEQ  skip_to_next_torpedo  ; $E20E
    SEC
    SBC  ypos_local  ; $12  ; (y-position of the current buoy)
    CMP  #$15  ; dec21
    BCS  skip_to_next_torpedo  ; $E20E  ; branch if >= dec21 (or if we had an underflow and <0) i.e., torpedo not in y-range of current buoy
    // assess x-range
    LDA  torpedo_fire_xpos,y  ; $006D,Y  ; x-pos of all torpedoes
    SEC
    SBC  xpos_local  ; $11  ; (x-position of the current buoy)
    CMP  #$FE  ; dec254
    BCS  this_torpedo_hit_current_buoy  ; $E213 ; branch if >= 254 (-2)
    CMP  #$0C  ; dec12
    BCC  this_torpedo_hit_current_buoy  ; $E213
skip_to_next_torpedo:
    DEY
    BPL  loop_next_torpedo_to_buoy_collision_check  ; $E1F4
    BNE  skip_due_to_no_spr_to_back_collision  ; $E224
this_torpedo_hit_current_buoy:
// if we're here, a missile has hit a buoy
// Y = the torpedo/missile that made the hit
// X = the buoy that was hit
    LDA  #$FF  ; #$ff = this torpedo is no longer visible
    STA  torpedo_fire_state,y  ; $007D,Y
    STA  buoys_visibility,x  ; $5D,X
    LDA  #$18  ; dec24
    STA  buoys_explode_timer,x  ; $69,X
    JSR  trigger_voice3_sound  ; $E95D  ; (probably explosion sound?)
    JMP  jmp_to_next_buoy  ; $E275
skip_due_to_no_spr_to_back_collision:
    LDA  buoys_visibility,x  ; $5D,X
    BMI  buoy_currently_exploding  ; $E25E
    LDA  buoy_movement_timer  ; $24
    BNE  jmp_to_next_buoy  ; $E275
; interesting... buoys only move from left to right
    INC  xpos_local  ; $11  ; x-pos of current buoy
    LDA  xpos_local  ; $11
    CMP  #$94  ; 148
    BCS  make_this_buoy_invisible  ; $E251  ; buoy moved past right-edge of screen
    STA  buoys_xpos,x  ; $61,X  (array of all buoy x-positions)
    TXA
    ORA  #$04
    JSR  set_sprite_position  ; $E8B4  (a=sprite no#, x,y vals in xpos_local/$11 and ypos_local/$12)
    LDX  iterator_local  ; $23
    LDA  #$FA  ; sprite fa (afd buoy)
    STA  $07FC,X  ; sprite-pointers for sprites 4-7
    LDA  #$01
    STA  $D02B,X  ; sprite 4-7 colour (set it to white for the buoy)
    TXA
    ORA  #$04
    JSR  turn_on_sprite_A  ; $E8DD
    JMP  jmp_to_next_buoy  ; $E275
make_this_buoy_invisible:
    LDA  #$00
    STA  buoys_visibility,x  ; $5D,X
    TXA
    ORA  #$04
    JSR  turn_off_sprite_A  ; $E8E8
    JMP  jmp_to_next_buoy  ; $E275
buoy_currently_exploding:
    LDX  iterator_local  ; $23  ; current buoy index
    DEC  buoys_explode_timer,x  ; $69,X
    BEQ  make_this_buoy_invisible  ; $E251  ; timer expired? Then make buoy invisible
    LDA  buoys_explode_timer,x  ; $69,X  (range 0-23)
    LSR
    LSR
    LSR  ; divide by 8  (range 0-2)
    AND  #$03
    STA  genvarB  ; $08  ; index of buoy explode frame index to display
    LDA  #$F8  ; dec248  (prepare buoy explosion sprite pointer)
    SEC
    SBC  genvarB  ; $08
    STA  $07FC,X  ; sprite-pointers for sprites 4-7
                  ; sprite-pointer can be set to anything between $F6 - $F8
jmp_to_next_buoy:
    DEC  iterator_local  ; $23
    BMI  exit_buoy_logic_routine  ; $E27C
    JMP  loop_next_buoy  ; $E1D6
exit_buoy_logic_routine:
    RTS


// sprite F6: (buoy explosion?)
// 
// +------------------------+
// |   *  ** *  *   ** **   |
// |  *  **       * *   **  |
// | ***   **  ** ***    ** |
// | **  *  **   * ** ** ** |
// |  ** * * **   **     *  |
// |***** ***    ***  *** **|
// | ** **   ** ***  **  ** |
// |  **  *** * *  **** **  |
// |   **  ** *   *    **   |
// |    **  ***  ***  **    |
// |     ****  **  ****     |
// |      **   **   **      |
// |     ****  **  ****     |
// |    **  ** ** **  **    |
// |   **    ******    **   |
// |  **      ****      **  |
// | ********************** |
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// | ********************** |
// +------------------------+


// sprite F7: (buoy explosion?)
// 
// +------------------------+
// |  *    * *  *   **   *  |
// | *   **       * *     * |
// |** *   *   *    *      *|
// |* *          * *  ** ***|
// |*  *          **     * *|
// |***               *** **|
// | ** **   *    *   *   * |
// | ***  *** *    ***  **  |
// |** **  ** *   *     *   |
// | *  *   ***  * *  **    |
// |*    ****  **  **** *   |
// | **   **   **   **    * |
// |      ***  **      **** |
// | *  *   ** ** **  **    |
// |    *    *** **     *   |
// |  **      **        **  |
// | *    ***  ****     *** |
// |**    * ***   *  *   * *|
// |***      **  *** *   * *|
// |*   *** * *  *   *** ***|
// | * * *********  ******* |
// +------------------------+


// sprite F8:  (buoy explosion?)
// 
// +------------------------+
// |   ** ** * ** ****  *   |
// |     **       * *       |
// | * *   *   *    *    ** |
// |  *          * *  ** ** |
// | * *                 * *|
// |***               *** **|
// | ** **            *   * |
// | ***  *          *      |
// |** **               **  |
// | *                     *|
// |*    *            * * **|
// | **   *               **|
// |*                  **** |
// | *  *      *  *   **   *|
// |    *         *     *  *|
// |  **      **        **  |
// |**    ***  ****     *** |
// | *  * * ***      *   * *|
// | **      ** ***  *   * *|
// |    *** *  * *     *   *|
// |   *** *  *  * * * **   |
// +------------------------+


// sprite FA: (buoy)
// 
// +------------------------+
// |      ************      |
// |     *   *    *   *     |
// |     * * * **** * *     |
// |     *   *   ** * *     |
// |     * * * ****   *     |
// |**    ************    **|
// | **      ******      ** |
// |  **      ****      **  |
// |   **    ******    **   |
// |    **  ** ** **  **    |
// |     ****  **  ****     |
// |      **   **   **      |
// |     ****  **  ****     |
// |    **  ** ** **  **    |
// |   **    ******    **   |
// |  **      ****      **  |
// | ********************** |
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// | ********************** |
// +------------------------+


// LOCATION: E27D
handle_missile_firing_and_player_movement:
//---------------------------------------
// NOTE: It also contains buoy-respawn logic (based on player firing last missile of 4)
    LDA  #$01  ; iterator_local is set to #$01 to indicate (index to) player2 
               ; (it is set later at $E357 to #$00 to indicate player1)
    STA  iterator_local  ; $23
loop_next_player_to_assess_missiles_for:
    LDX  iterator_local  ; $23
    LDA  missile_reload_timers,x  ; $2F,X
    BEQ  assess_player_movement  ; $E2A9  ; if timer is zero, then skip over to assess player movement
    DEC  missile_reload_timers,x  ; $2F,X
    LDA  missile_reload_timers,x  ; $2F,X
    BEQ  reload_player_missiles  ; $E2A2  ; once timer expires, reload player missiles
    CMP  #$78  ; dec120
    BEQ  decrement_reload_time_on_screen  ; $E295  ; if we reach this timer=120 threshold, decrement reload time on screen
    CMP  #$3C  ; dec60
    BNE  assess_player_movement  ; $E2A9  ; if we reach this timer=60 threshold, decrement reload time on screen
decrement_reload_time_on_screen:
    TXA  ; a=0 for player1, a=1 for player2
    BNE  player2_update_reload_time  ; $E29D  ; branch if player2
    dec  $07c2   ; row24 - column2 on char screen (decrements the TIME TO LOAD: x SECONDS.) for player1
                 ; (it might be a black/invisible character that is used as a temp var) 
    BNE  assess_player_movement  ; $E2A9  ; if timer hasn't expired yet, skip to player movement assessment
player2_update_reload_time:
    DEC  $07DB   ; row24 - column27 on char screen  (decrements the TIME TO LOAD: x SECONDS.) for player2
    BNE  assess_player_movement  ; $E2A9  ; if timer hasn't expired yet, skip to player movement assessment
reload_player_missiles:
    LDA  #$04
    STA  p1_num_missiles,x  ; $31,X
    JSR  redraw_torpedo_amount_indicator  ; $E35F
assess_player_movement:
    LDA  iterator_local  ; $23
    LDY  real_game_mode_flag  ; $16
    BNE  skip_if_in_real_game_mode_flag  ; $E2B9
// if in attract mode, randomly decide when to fire missiles
    JSR  random_num_gen_into_A  ; $E893
    CMP  #$03
    BCC  auto_fire_missile_while_in_attract  ; $E2C8  ; branch if less than 3
    JMP  skip_over_paddle_reading  ; $E2BF
skip_if_in_real_game_mode_flag:
// if not in attract, we're in real game, to read user input for fire button
    JSR  read_paddle_fire_button  ; $E783
    TAX
    BNE  paddle_fires_pressed  ; $E2C8  ; branch if any paddle fires pressed
skip_over_paddle_reading:
    LDX  iterator_local  ; $23  ; player idx (0=player1, 1=player2)
    LDA  #$00  ; set flag to record that paddle fire state is presently off
    STA  last_paddle_fire_state,x  ; $33,X
    JMP  skip_to_next_player_assessment  ; $E357
auto_fire_missile_while_in_attract:
paddle_fires_pressed:
    LDX  iterator_local  ; $23
    LDA  last_paddle_fire_state,x  ; $33,X
    BEQ  transition_paddle_fire_state_from_off_to_on  ; $E2D1  ; if last paddle fire-state was off, then we have now transitioned to on
    JMP  skip_to_next_player_assessment  ; $E357
transition_paddle_fire_state_from_off_to_on:
    LDA  #$FF  ; $FF = fire-state = on
    STA  last_paddle_fire_state,x  ; $33,X
    LDA  missile_reload_timers,x  ; $2F,X
    BEQ  shoot_a_missile  ; $E2DC  ; if player's reload timer is zero, it means we still have missiles available to fire
    JMP  skip_to_next_player_assessment  ; $E357
shoot_a_missile:
    TXA  ; X = player idx (0=player1, 1=player2)
    ASL
    ASL  ; multiply by 4  (0=player1, 4=player2)
    CLC
    ADC  p1_num_missiles,x  ; $31,X  ; let A be index to the next available missile for this player
    TAY  ; Y = idx to next available missile for this player
    DEY  ; this decrement might be to assure the a kind of zero-indexed nature of referring to missiles here
    LDA  players_xpos,x  ; $35,X
    CLC
    ADC  #$07
    STA  torpedo_fire_xpos,y  ; $006D,Y
    LDA  #$A0  ; dec160
    STA  torpedo_fire_ypos,y  ; $0075,Y  ; y-position of submarine torpedo/fire
    LDA  #$00  ; #$00 = this torpedo is now visible
    STA  torpedo_fire_state,y  ; $007D,Y
    DEC  p1_num_missiles,x  ; $31,X
    JSR  redraw_torpedo_amount_indicator  ; $E35F
    JSR  play_fire_shoot_sound_on_v2  ; $E953
    LDX  iterator_local  ; $23
    LDA  p1_num_missiles,x  ; $31,X
    BNE  skip_to_next_player_assessment  ; $E357  ; if player still has missiles, do branch
    ; otherwise, they've run out of missiles now, and time to prepare the reload timer
    LDA  #$B4  ; dec180
    STA  missile_reload_timers,x  ; $2F,X
; buoy respawn logic
; ------------------
; we can only get here if we just fired the last missile in our set of 4 (whether it be player 1 or 2)
    LDA  buoy_pair_index  ; $25
    EOR  #$02  ; toggle bit1  ; so below, we can only possibly assess visibility of buoy 0 or 2
    STA  buoy_pair_index  ; $25
    TAX
    ; X = buoy-pair index (either 0 or 2)
    LDA  buoys_visibility,x  ; $5D,X  ; assess buoy1
    BEQ  assess_buoy2_visibility  ; $E31A  ; if buoy1 not visible, then branch
    LDA  buoys_visibility+1,x  ; $5E,X  ; assess buoy2
    BEQ  buoy1_visible_and_buoy2_invisible  ; $E32A  ; if buoy2 also not visible, then branch
; if both buoys visible, no need to do any respawning
; ---------------------------------------------------
    JMP  skip_to_next_player_assessment  ; $E357
assess_buoy2_visibility:
    LDA  buoys_visibility+1,x ; $5E,X
    BNE  buoy1_invisible_and_buoy2_visible  ; $E33A
; both buoys in the pair are invisible
//-------------------------------------
    LDA  #$00
    STA  buoys_xpos,x  ; $61,X  ; spawn new buoy at xpos=0
    CLC
    ADC  #$44  ; dec68  ; 2nd buoy in pair will be at xpos=68
    STA  buoys_xpos+1,x  ; $62,X
    JMP  assure_both_buoys_in_pair_visible_and_on_same_ypos  ; $E347
buoy1_visible_and_buoy2_invisible:
//---------------------------------
    LDA  buoys_xpos,x  ; $61,X  ; 1st buoy xpos
    CMP  #$4C  ; dec76  ; 1st_buoy_xpos >= 76
    BCS  respawn_2nd_buoy_behind_1st  ; $E333
    ADC  #$44  ; dec68
    +bit_skip_2_bytes
respawn_2nd_buoy_behind_1st:
      SBC  #$44  ; dec68
    STA  buoys_xpos+1,x  ; $62,X
    JMP  assure_both_buoys_in_pair_visible_and_on_same_ypos  ; $E347
buoy1_invisible_and_buoy2_visible:
//---------------------------------
; we're here if 1st buoy in pair is not visible, but 2nd buoy in pair is visible
    LDA  buoys_xpos+1,x  ; $62,X  ; A = xpos of 2nd buoy in pair
    CMP  #$4C  ; dec76
    BCS  respawn_1st_buoy_behind_2nd  ; $E343 ; if A >= 76 then branch to spawn 1st buoy behind 2nd
    ADC  #$44  ; otherwise spawn 1st buoy (in pair) in front of 2nd by dec68
    +bit_skip_2_bytes
respawn_1st_buoy_behind_2nd:
      SBC  #$44
    STA  buoys_xpos,x  ; $61,X
assure_both_buoys_in_pair_visible_and_on_same_ypos:
//--------------------------------------------------
    LDA  #$01
    STA  buoys_visibility,x  ; $5D,X
    STA  buoys_visibility+1,x  ; $5E,X
    TXA
    LSR
    TAY
    LDA  possible_buoy_y_positions,y  ; $EE22,Y
    STA  buoys_ypos,x  ; $65,X
    STA  buoys_ypos+1,x  ; $66,X
skip_to_next_player_assessment:
    DEC  iterator_local  ; $23  ; decrement player index from player2 to player1
    BMI  $E35E
    JMP  loop_next_player_to_assess_missiles_for  ; $E281
    RTS


redraw_torpedo_amount_indicator:
//------------------------------
    LDA  p1_num_missiles,x  ; $31,X   ; the number of missiles this player has remaining (player = x)
    PHA
    TXA
    BNE  still_have_missiles  ; $E368  ; if player still have missiles, redraw missile indicator area
    LDA  #$01
    +bit_skip_2_bytes
still_have_missiles:
      LDA  #$1A  ; dec26
    STA  txt_x_pos  ; $13
    LDA  #$17  ; dec23
    STA  txt_y_pos  ; $14
    JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
    LDA  #$26  ; ' ' space character
    LDY  #$00
loop_clear_next_line:
    LDX  #$0D  ; 13
loop_clear_next_char:
    STA  ($02),Y   ; draw 13 spaces in the missile area, starting at either (1,23) for no missiles,
                   ; or (26,23) for have missiles.
    INY
    DEX
    BNE  loop_clear_next_char  ; $E379
    CPY  #$28  ; dec40
    BCS  draw_players_torpedoes  ; $E387  ; branch if y >= 40 (upon clearing 2nd line of missiles?)
    LDY  #$28  ; dec40
    BNE  loop_clear_next_line  ; $E377
draw_players_torpedoes:
    PLA  ; retrieve number of missiles for currently assessed player again
    BEQ  draw_reloading_message  ; $E3A3  ; branch if player has no more missiles
    TAX
    DEX  ; decrease number of player missiles by one
loop_to_draw_prior_torpedo_in_group:
    LDA  #$50  ; #$50 = start of torpedo char
    LDY  #$04
    STY  genvarB  ; $08
    LDY  screen_offsets_for_each_missile_indicator,x  ; $EE24,X
loop_to_draw_next_torpedo_char:
    STA  (scr_ptr_lo),y   ; ($02),Y
    INY
    CLC
    ADC  #$01  ; increment to next torpedo char (e.g., #$50, #$51, #$52, #$53)
    DEC  genvarB  ; $08
    BNE  loop_to_draw_next_torpedo_char  ; $E395
    DEX  ; decrease x to point to prior torpedo in group (aiming to redraw it on screen next)
    BPL  loop_to_draw_prior_torpedo_in_group  ; $E38C
    RTS
draw_reloading_message:
    LDX  #$16  ; dec22  ; it draws from the end of the string and moves forward
    LDY  #$32  ; dec50
loop_for_next_char:
    LDA  time_to_load_msg,x  ; $E3B7,X
    STA  (scr_ptr_lo),y  ; ($02),Y
    DEY
    CPY  #$28  ; dec40      ; did we finish the 2nd line, and are now on last char of 1st line?
    BNE  skip_if_still_on_2nd_line  ; $E3B3  ; if not, maintain usual loop behaviour 
    LDY  #$0C  ; dec12  ; if so, reposition y to point to end of 1st line (to draw it from last char to first)
skip_if_still_on_2nd_line:
    DEX
    BPL  loop_for_next_char  ; $E3A7
    RTS

// LOCATION: E3B7
time_to_load_msg:
    !byte $3A, $2F, $33, $2B, $26, $3A, $35, $26,  $32, $35, $27, $2A, $42, $49, $26, $39
//           T  I  M  E     T  O      L  O  A  D  :  3     S
    !byte $2B, $29, $35, $34, $2A, $39, $41
//           E  C  O  N  D  S  .


update_player_submarine_positions:
//-------------------------------
// NOTE: Also assesses paddle-input to decide submarine position
    LDA  #$01  ; player index (0=player1, 1=player2)
    STA  iterator_local  ; $23
loop_next_player_submarine:
    LDX  iterator_local  ; $23
    TXA
    CLC
    ADC  #$15  ; dec21  ; this is row containing either:
                        ;    player1 sub (row21) - yellow
                        ; or player2 sub (row22) - light brown
    STA  txt_y_pos  ; $14
    LDA  #$00
    STA  txt_x_pos  ; $13
    JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
    LDY  real_game_mode_flag  ; $16
    BNE  assess_paddle_movement  ; $E405
// if we're in attract mode, move paddles around automatically?
    LDA  players_xpos,x  ; $35,X
    STA  genvarA  ; $09  ; hold x-pos of current player
    CMP  attract_mode_player_xpos_waypoint,x  ; $37,X
    BNE  assess_auto_travel_direction  ; $E3F9  ; if we didn't arrive to waypoint, branch to assess direction to travel
// if we get here, the attract mode paddle movement has reached the current waypoint,
// so it's time to pick a new waypoint to automatically travel towards
retry_if_random_waypoint_not_in_valid_xrange:
    JSR  random_num_gen_into_A  ; $E893
    CMP  #$93  ; dec147
    BCS  retry_if_random_waypoint_not_in_valid_xrange  ; $E3ED ; branch if >= 147
    STA  attract_mode_player_xpos_waypoint,x  ; $37,X
    JMP  jump_ahead  ; $E400
assess_auto_travel_direction:
    BCS  travelling_right_to_left  ; $E3FE  ; if current player x-pos >= waypoint, then branch (for decrement)
// otherwise player x-pos is less than waypoint (and we need to increment)
    INC  genvarA  ; $09  ; move paddle automatically to right
    +bit_skip_2_bytes
travelling_right_to_left:
      DEC  genvarA ; $09  ; move paddle automatically to left
jump_ahead:
    LDA  genvarA  ; $09
    JMP  wipe_current_player_submarine  ; $E40C
assess_paddle_movement:
    LDA  iterator_local  ; $23
    JSR  read_paddle_position  ; $F0F0
    STA  genvarA  ; $09
wipe_current_player_submarine:
    LDX  iterator_local  ; $23
    LDA  players_xpos,x  ; $35,X  ; player1/2 xpos
    LSR
    LSR
    TAY
    LDX  #$05
    LDA  #$26  ; ' ' space char
loop_wipe_next_submarine_char:
    STA  ($02),Y  ; wipe away existing player submarine chars with spaces (submarine is 5 chars wide)
    INY
    DEX
    BNE  loop_wipe_next_submarine_char  ; $E417
    // time to draw player's submarine at new position
    // -----------------------------------------------
    LDA  genvarA  ; $09  ; new xposition for paddle
    AND  #$03  ; figure out what x-offset within char the sub-should be drawn at (in pixel-pair units)
    TAX
    LDY  submarine_charset_idx,x  ; $EEE8,X  ; choose between submarine_charset1/2/3/4
    LDA  iterator_local  ; $23  ; player 1 or 2 index (0=player1, 1=player2)
    BNE  jump_if_player2  ; $E42C
    LDX  #$00  ; relative index for vic-bank0 chars describing current player1 submarine
               ; (absolute char idx range 55-59)
    +bit_skip_2_bytes
jump_if_player2:
      LDX  #$28  ; dec40  ; relative index for vic-bank0 chars describing current player2 submarine
    LDA  #$28  ; dec40  ; index of loop from 40 to 0, in order to copy across 5 chars to define player's sub)
    STA  genvarB  ; $08
loop_copy_desired_submarine_charset_across:
    LDA  submarine_charset1,y  ; $EE48,Y
    STA  vicbank0_sub_chars_for_player1,x  ; $02A8,X
    INX
    INY
    DEC  genvarB  ; $08
    BNE  loop_copy_desired_submarine_charset_across ; $E432
    LDX  iterator_local  ; $23  ; current player
    LDA  genvarA  ; $09  ; new x-pos of player's submarine
    STA  players_xpos,x  ; $35,X
    LSR
    LSR
    TAY
    LDA  sub_start_chars,x  ; $E45D,X  ; where x=0 is player1, x=1 is player2
    LDX  #$05  ; player submarine sprite consists of 5 chars
loop_draw_next_submarine_char:
    STA  ($02),Y
    CLC
    ADC  #$01
    INY
    DEX
    BNE  loop_draw_next_submarine_char  ; $E44C
    DEC  iterator_local  ; $23
    BMI  exit_update_player_submarine_positions_routine  ; $E45C
    JMP  loop_next_player_submarine  ; $E3D2
exit_update_player_submarine_positions_routine:
    RTS


sub_start_chars:
    !byte $55, $5A

//    55 = start char of 1st variation of submarine chars (maybe intended for player1)
//    5A = start char of 2nd variation of submarine chars (though both variations look quite similar)
//            (maybe intended for player2, possibly to give it a unique look?)


missile_redraw_assessment:
//-----------------------
    LDA  #$07  ; iterator over all possible missiles (7-4 are for player2, 3-0 are for player1)
    STA  iterator_local  ; $23
loop_next_missile:
    LDX  iterator_local  ; $23  ; missile iterator
    LDA  torpedo_fire_ypos,x  ; $75,X  ; y-position of all torpedoes
    BNE  torpedo_is_active  ; $E46C  ; non-zero means torpedo is live/visible/active
    JMP  skip_to_next_missile  ; $E52E
torpedo_is_active:
    PHA  ; A=ypos of current torpedo (can be in range of dec0 to dec160)
    LSR
    LSR
    LSR
    LSR  ; divide by 16 (decide which 2x2 block y-pos this torpedo will reside in?)
    TAY  ; y-pos index of 2x2 block this torpedo/missile resides in
         ; (range of dec0 to dec10)
    PLA  ; A=pure pixel ypos of current torpedo
    SEC
    SBC  missile_speed_at_indexed_2x2_ypos,y  ; $EFC0,Y
         ; At the lower part of the screen, the missile moves faster, #$02 = 2 pixels per frame
         ; At the mid and upper parts of the screen, the missile moves slower, #$01 = 1 pixel per frame
         ; the #$03 speed seems unused
    STA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
    // prepare destination pointers to missile char-data relating to current missile
    // -----------------------------------------------------------------------------
    TXA  ; index to the current missile/torpedo being assessed in loop
    ASL
    ASL  ; multiply by 4  ; so now p1_missile4 = #$00, p1_missile3 = #$04
                          ;        p1_missile2 = #$08, p1_missile1 = #$0c
                          ;        p2_missile4 = #$10, p2_missile3 = #$14
                          ;        p2_missile2 = #$18, p2_missile1 = #$1c
    STA  offset_to_char_idx_of_2x2_missile_chars  ; $0F  ; offset to char index of 2x2 missile chars
    ASL
    ASL
    ASL  ; multiply by 8  ; so now p1_missile4 = #$00, p1_missile3 = #$20
                          ;        p1_missile2 = #$40, p1_missile1 = #$60
                          ;        p2_missile4 = #$80, p2_missile3 = #$a0
                          ;        p2_missile2 = #$c0, p2_missile1 = #$e0
    STA  offset_to_char_data_addr_of_2x2_missile_chars  ; $10
    LDA  missiles_colour_table,x  ; $EFAC,X  ; a choice between yellow or light brown over idx0 to 7
    STA  curr_missile_colour  ; $2E
    LDY  #$1F  ; dec31  ; index to char-data for curr missile (4 chars = 32 bytes)
    LDA  #$00
    // we prepare the next missile char-data in genarrayA (treated as a temporary 2x2 char block)
    // ------------------------------------------------------------------------------------------
    // - wipe any prior contents in it first
loop_to_wipe_temp_2x2_char_block:
    STA  genarrayA,y  ; $0085,Y  ; reset entire genarrayA[32] to zeroes
         ; NOTE: genarrayA aims to house the new 2x2 char representation the current missile
    DEY
    BPL  loop_to_wipe_temp_2x2_char_block  ; $E48C
    // assess missile y-pos and how it will impact needed char data (small/medium/big missile)
    // ---------------------------------------------------------------------------------------
    LDA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
    LSR
    LSR
    LSR
    LSR  ; divide by 16  ; will be in range dec0 to dec10
    TAY
    LDA  map_2x2_ypos_to_chardata_offset_for_missile_size,y  ; $EFB4,Y  ; has values like #$00, #$40 and #$80 (over index0 to 11)
    ; this appears to be the offset into the missile-char-data to choose between:
    ; small(#$00), medium(#$40) or big(#$80) missiles (depending on which 2x2 char ypos missile is at)
    STA  genvarA  ; $09 ; stores the missile-char-data offset for small/medium/big missiles
    // assess missile x-pos and how it will impact needed char data (which x-offset to use)
    // ------------------------------------------------------------------------------------
    LDA  torpedo_fire_xpos,x  ; $6D,X  ; x-position of all torpedoes
    AND  #$03  ; xpos modulus to range 0-3
    ; missile xpos are in two-pixel (pixel-pair) units.
    ; So the MOD4 may have intended to see at which x-offset within the first char the missile is drawn
    ASL
    ASL
    ASL
    ASL ; multiply by 16  ; can be either #$00, #$10, #$20 or #$30
    ORA  genvarA  ; $09  ; could be value of either #$00 or #$40 or #$80
                         ; i.e. decide which x-offset variant to use of either small/medium/big missiles
    ; genvarA holds the missile-char-data offset for small/medium/big missiles
    ; the ORA will adjust this offset to point to the correct missile x-offset chardata
    ; E.g.:
    ; if genvarA = #$00 and...
    ;   if A = #$00 then point to small_missile_char_data_x_offset0
    ;   if A = #$10 then point to small_missile_char_data_x_offset2
    ;   if A = #$20 then point to small_missile_char_data_x_offset4
    ;   if A = #$30 then point to small_missile_char_data_x_offset6
    ; if genvarA = #$40 and...
    ;   if A = #$00 then point to medium_missile_char_data_x_offset0
    ;   if A = #$10 then point to medium_missile_char_data_x_offset2
    ;   if A = #$20 then point to medium_missile_char_data_x_offset4
    ;   if A = #$30 then point to medium_missile_char_data_x_offset6
    ; if genvarA = #$80 and...
    ;   if A = #$00 then point to big_missile_char_data_x_offset0
    ;   if A = #$10 then point to big_missile_char_data_x_offset2
    ;   if A = #$20 then point to big_missile_char_data_x_offset4
    ;   if A = #$30 then point to big_missile_char_data_x_offset6
    TAY  ; used as index in small_missile_char_data_x_offset0 later
    LDA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
    AND  #$07
    ; The MOD8 may have intended to see at which y-offset within first char the missile is drawn
    ; (this is in pixel units, and not in pixel-pair units)
    TAX
    LDA  #$08
    STA  missile_chardata_row_iterator  ; $0E
    ; draw missile into temp 2x2 char block (genarrayA) at desired y-offset
    ; ---------------------------------------------------------------------
loop_draw_next_pixel_row_of_missile_char_data:
    ; Y = offset to desired missile_char_data (which factors in what x-offset we want to draw at)
    ; X = which y-offset we want to start drawing into 2x2 char block of genarrayA)
    LDA  small_missile_char_data_x_offset0,y  ; $EEEC,Y  ; y-range = 0 to 7
    STA  genarrayA,x  ; $85,X
    LDA  small_missile_char_data_x_offset0+8,y  ; $EEF4,Y  ; y-range = 0 to 7
    STA  genarrayA+16,x  ; $95,X
    INX
    INY
    DEC  missile_chardata_row_iterator  ; $0E
    BNE  loop_draw_next_pixel_row_of_missile_char_data  ; $E4B2
    ; wipe out prior missile chars from screen
    ; ----------------------------------------
    LDX  iterator_local  ; $23  ; missile iterator ; ought to be an index from 0 to 7
    LDA  torpedo_fire_xpos,x  ; $6D,X
    STA  xpos_local  ; $11  ; x-pos of current torpedo/missile
    LDA  torpedo_fire_ypos,x  ; $75,X
    STA  ypos_local  ; $12  ; y-pos of current torpedo/missile
    JSR  set_scr_and_clr_ptr_locations_based_on_ship_xy_pos  ; $E6B1
    LDX  #$03
; wipe out prior chars of this missile from the screen
loop_wipe_next_char_of_2x2_char_missile:
    LDY  missile_char_offsets,x  ; $EE28,X
    LDA  (scr_ptr_lo),y  ; ($02),Y  ; read the char at this screen location
    CMP  #$60  ; first missile char in group
    BCC  skip_wipe_if_less_than_range_of_missile_chars  ; $E4DE
    LDA  #$26  ; ' ' space char
    STA  (scr_ptr_lo),y  ; ($02),Y  ; draw ' ' space char over prior missile
skip_wipe_if_less_than_range_of_missile_chars:
    DEX
    BPL  loop_wipe_next_char_of_2x2_char_missile  ; $E4D1
    ; check if missile reached top of screen (time to make it invisible?)
    ; --------------------------------------
    LDX  iterator_local  ; $23  (missile iterator)
    LDA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
    CMP  #$10  ; dec16
    BCC  reset_missile_ypos_to_zero  ; $E528  ; branch if less than 16
    LDY  torpedo_fire_state,x  ; $7D,X
    BNE  reset_missile_ypos_to_zero  ; $E528  ; branch if this torpedo is not currently visible on screen
    STA  torpedo_fire_ypos,x  ; $75,X  ; y-pos of all torpedoes
    STA  ypos_local  ; $12  ; y-pos of current ship
    JSR  set_scr_and_clr_ptr_locations_based_on_ship_xy_pos  ; $E6B1
    LDY  offset_to_char_data_addr_of_2x2_missile_chars  ; $10
    LDX  #$00
loop_copy_next_temp_chardata_to_dest_chardata:
    LDA  genarrayA,x  ; $85,X
    STA  vicbank0_missile_chars_for_player1,y  ; $0300,Y
    INY
    INX
    CPX  #$20  ; 32
    BNE  loop_copy_next_temp_chardata_to_dest_chardata  ; $E4F8
    ; now draw this missile's newly prepared chars onto the screen
    ; ------------------------------------------------------------
    LDA  offset_to_char_idx_of_2x2_missile_chars  ; $0F
    CLC
    ADC  #$63  ; dec99  ; start at the last char-idx for this 2x2 missile soft-sprite (e.g., #$63 to #$60)
    STA  genvarA  ; $09  ; could it relate to current paddle position?
    LDX  #$03
loop_draw_next_missile_char_on_screen:
    LDY  missile_char_offsets,x  ; $EE28,X
    LDA  (scr_ptr_lo),y  ; ($02),Y
    CMP  #$26  ; is it a ' ' space char?
    BEQ  draw_current_missile_char  ; $E519  ; if there's a space char current, in this position, then branch and draw the current missile char
    CMP  #$60  ; #$60 = first shot char in group
    BCC  skip_drawing_this_missile_char  ; $E521  ; if there's some non-space (and non-missile) char here
                                                  ; (perhaps attract-screen text), then don't draw this missile char
draw_current_missile_char:
    LDA  genvarA  ; $09
    STA  (scr_ptr_lo),y  ; ($02),Y
    LDA  curr_missile_colour  ; $2E  ; some colour choice between yellow or light-brown
    STA  (clr_ptr_lo),y  ; ($04),Y
skip_drawing_this_missile_char:
    DEC  genvarA  ; $09
    DEX
    BPL  loop_draw_next_missile_char_on_screen  ; $E50C
    BMI  skip_to_next_missile  ; $E52E
reset_missile_ypos_to_zero:
    LDX  iterator_local  ; $23
    LDA  #$00
    STA  torpedo_fire_ypos,x  ; $75,X  ; y-pos of all torpedoes
skip_to_next_missile:
    DEC  iterator_local  ; $23
    BMI  exit_missile_redraw_assessment_routine  ; $E535
    JMP  loop_next_missile  ; $E463
exit_missile_redraw_assessment_routine:
    RTS


paddle_and_function_key_reading_routine:
//--------------------------------------
    LDA  #$00
    JSR  read_paddle_fire_button  ; $E783
    TAX
    BNE  paddle_fire_or_F1_pressed  ; $E54B  ; jump if paddle fire pressed (A = FF)
    LDA  #$FE
    STA  $DC00
    LDA  $DC01
    TAX
    AND  #$10  ; Check if F1 is pressed
    BNE  no_paddle_fire_or_F1  ; $E54F ; Jump if not pressed
paddle_fire_or_F1_pressed:
    LDA  #$01
    BNE  finish_off_routine  ; $E562  ; will always jump (as A is non-zero)
no_paddle_fire_or_F1:
    TXA
    AND  #$20  ; Check if F3 is pressed
    BNE  no_F3_pressed  ; $E558  ; Jump if not pressed
    LDA  #$03
    BNE  finish_off_routine  ; $E562
no_F3_pressed:
    TXA
    AND  #$40  ; Check if F5 is pressed
    BNE  $E560  ; Jump if not pressed
    LDA  #$05
    +bit_skip_2_bytes
no_F5_pressed:
      LDA  #$00
finish_off_routine:
    LDX  #$7F
    STX  $DC00
    RTS
             ; If F1 or paddle-fire was pressed, A = 1
             ; If F3 was pressed, A = 3
             ; If F5 was pressed, A = 5
             ; else A = 0


parent_routine_that_does_key_paddle_input:
//----------------------------------------
    JSR  timer_loop  ; $E759
    JSR  paddle_and_function_key_reading_routine  ; $E536
    TAX
    BNE  parent_routine_that_does_key_paddle_input  ; $E568
    ; jump if any paddle-fire or func-key press (perhaps waiting for prior press to unpress)
    JSR  timer_loop  ; $E759
    INC  $1B
    JSR  paddle_and_function_key_reading_routine  ; $E536
    TAX
    BEQ  $E571  ; jump if no paddle-fire or func-key press
    RTS


prepare_game_screen:
//------------------
    JSR  clear_screen_and_draw_scores  ; $E799
    ; set colour various rows on screen (in colour ram)
    ; -------------------------------------------------
    LDX  #$27  ; (39)
loop_next_char_colour_in_row:
    LDA  #$07
    STA  $DB48,X  ; (row 21 colour ram all set to 7 / yellow) - player 1 submarine row
    LDA  #$08     ; (row 22 colour ram all set to 8 / light brown?) - player 2 submarine row
    STA  $DB70,X
    LDA  #$00
    STA  $D800,X  ; (row 0 colour ram all set to 0 / black)
    STA  $D828,X  ; (row 1 colour ram all set to 0 / black)
    DEX
    BPL  loop_next_char_colour_in_row  ; $E582
    ; set colours for missile indicator regions
    ; -----------------------------------------
    LDX  #$0D    ; (13)
loop_next_char_colour_in_missile_indicator_region:
    LDA  #$07      ; 7 = yellow
    STA  $DB99,X   ; (row 23 - from col 1 to 8)
    STA  $DBC1,X   ; (row 24 - from col 1 to 8)
    LDA  #$08      ; 8 = light brown
    STA  $DBB2,X   ; (row 23 - from col 26 to 33)
    STA  $DBDA,X   ; (row 24 - from col 26 to 33)
    DEX
    BPL  loop_next_char_colour_in_missile_indicator_region  ; $E599
    LDA  #$17  ; dec23
    STA  txt_y_pos  ; $14  (curr. ship y-pos)
    JSR  draw_inline_text  ; $E839

    !byte $3A, $2F, $33, $2B, $26, $32, $2B, $2C,  $3A, $00 
    //       T  I  M  E     L  E  F   T

    JSR  print_remaining_game_time  ; $E873
    LDX  #$00  ; for player 1
    JSR  redraw_torpedo_amount_indicator  ; $E35F
    LDX  #$01  ; for player 2
    JSR  redraw_torpedo_amount_indicator  ; $E35F
    JMP  allow_interrupts  ; $E8F3


show_intro_screen:
//---------------
; returns: - 0 if no user input pressed during intro (i.e., next up, switch to attract mode)
;          - ff if user pressed F1 or paddle fire
    JSR  interrupt_precursor  ; $E8F5
    JSR  clear_screen_and_draw_scores  ; $E799
    ; prepare colour of 1st two rows to white
    ; ---------------------------------------
    LDX  #$4F  ; dec79
    LDA  #$01
loop_next_char_colour_for_top_rows:
    STA  $D800,X  ; set first 2 lines to be white text?
    DEX
    BPL  loop_next_char_colour_for_top_rows
    LDA  #$18  ; dec24
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $44, $29, $45, $26, $47, $4F, $4E, $48,  $26, $28, $27, $32, $32, $3F, $43, $33
    //       (  C  )     1  9  8  2      B  A  L  L  Y  -  M
    !byte $2F, $2A, $3D, $27, $3F, $26, $44, $29,  $45, $26, $47, $4F, $4E, $48, $26, $29
    //       I  D  W  A  Y     (  C   )     1  9  8  2     C
    !byte $35, $33, $33, $35, $2A, $35, $38, $2B,  $00 
    //       O  M  M  O  D  O  R  E   

    ; title sprite preparations
    ; -------------------------
    LDX  #$04
loop_set_xy_pos_for_title_sprites:
    LDA  title_sprites_xpos,x  ; $E6A4,X
    STA  $D000,X  ; set xpos for sprite 2 (#$ff/255), 1 (#$e2/226) and then 0 (#$c5/197)
    LDA  title_sprites_ypos,x  ; $E6A9,X
    STA  $D001,X  ; set ypos for sprite 2 (#$c2/194), 1 (#$b2/178) and then 0 (#$a2/162)
    DEX
    DEX
    BPL  loop_set_xy_pos_for_title_sprites  ; $E60F
    LDA  #$00
    STA  $D010  ; sprites 0-7 xpos msb
    LDA  #$07   ; %0000 0111
    STA  $D015  ; sprite display enable (only 1st 3 sprites visible)
    ; print mission text
    ; ------------------
    LDA  #<mission_text1  ; #$CC
    STA  ret_ptr_lo  ; $06
    LDA  #>mission_text1  ; #$EF
    STA  ret_ptr_hi  ; $07  ; note: no valid assembly exists at $EFCC
    LDA  #$03
    STA  txt_y_pos  ; $14

prepare_to_display_next_line_of_intro_text:
    LDY  #$00
    LDA  (ret_ptr_lo),y  ; ($06),Y  ; pointer to inline-text-string
    BEQ  final_wait_for_user_input_on_title_screen ; $E64D  ; if next string is just a null terminator, branch to final wait for user input
    JMP  glide_ships_left_for_a_while_then_display_next_line_of_text  ; $E66A

write_line_routine:
    JSR  draw_text_to_screen  ; $E7EC
    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    INC  ret_ptr_lo  ; $06
    BNE  prepare_to_display_next_line_of_intro_text  ; $E635
    INC  ret_ptr_hi  ; $07
    BNE  prepare_to_display_next_line_of_intro_text  ; $E635
final_wait_for_user_input_on_title_screen:
    LDA  #$02
    STA  genvarB  ; $08  ; extra delay counter
loop_wait_longer_on_title_screen:
    LDY  #$78
loop_wait_on_title_screen:
    JSR  paddle_and_function_key_reading_routine  ; $E536
    CMP  #$01
    BEQ  exit_from_title_screen_due_to_paddle_fire  ; $E667
    JSR  timer_loop  ; $E759
    DEY
    BNE  loop_wait_on_title_screen  ; $E653
    DEC  genvarB  ; $08
    BNE  loop_wait_longer_on_title_screen  ; $E651
    LDA  #$00  ; if there was no user input till now, then it's time to jump to attract mode
    +bit_skip_2_bytes
exit_from_title_screen_due_to_paddle_fire:
      LDA  #$FF
    RTS

glide_ships_left_for_a_while_then_display_next_line_of_text:
;----------------------------------------------------------
    LDX  #$02
    LDY  #$F4  ; sprite frame for pt-boat reversed
loop_next_ship_sprite_colour:
    TYA
    STA  $07F8,X  ; set sprite frame for sprite 2
    DEY
    LDA  ship_sprite_colours,x  ; $E6AE,X
    STA  $D027,X  ; set colours of sprites 0, 1 and 2
    DEX
    BPL  loop_next_ship_sprite_colour  ; $E66E
    LDA  #$1D  ; dec29
    STA  genvarB  ; $08

loop_keep_gliding_left_until_time_to_display_next_line_of_text:
    LDX  #$04  ; index to sprite xy-pos details
loop_next_ship_sprite_to_glide_left:
    LDA  $D000,X  ; $d004/$d002/$d000 = sprite2/1/0 x-pos, 
    CMP  #$38  ; dec56
    BEQ  skip_ship_move  ; $E68C
    DEC  $D000,X  ; glide ships to left on title screen
skip_ship_move:
    DEX
    DEX
    BPL  loop_next_ship_sprite_to_glide_left  ; $E682
    JSR  timer_loop  ; $E759
    JSR  timer_loop  ; $E759
    JSR  paddle_and_function_key_reading_routine  ; $E536
    CMP  #$01
    BEQ  exit_from_title_screen_due_to_paddle_fire  ; $E667
    DEC  genvarB  ; $08
    BNE  loop_keep_gliding_left_until_time_to_display_next_line_of_text  ; $E680
    JMP  write_line_routine  ; $E63E

title_sprites_xpos:
    !byte $C5, $00, $E2, $00, $FF

title_sprites_ypos:
    !byte $A2, $00, $B2, $00, $C2

ship_sprite_colours:
    !byte $07, $03, $05
//  - 07 = Yellow (freighter)
//  - 03 = Cyan (cruiser)
//  - 05 = Green (pt-boat)

set_scr_and_clr_ptr_locations_based_on_ship_xy_pos:
//-------------------------------------------------
    PHA
    LDA  xpos_local  ; $11  ; x-pos of current ship
    LSR
    LSR  ; divide by 4
    STA  txt_x_pos  ; $13
    LDA  ypos_local  ; $12  ; y-pos of current ship
    LSR
    LSR
    LSR  ; divide by 8
    STA  txt_y_pos  ; $14
    +bit_skip_1_byte

adjust_scr_and_clr_ptr_locations:
//-------------------------------
      PHA  ; preserve A on stack
  ; (if falling through from prior function, the BIT will skip this line)
    TXA
    PHA  ; preserve X on stack
    LDX  txt_y_pos
    LDA  scr_row_ptr_lo,X  ; $EDDC,X
    CLC
    ADC  $13
    STA  scr_ptr_lo  ; $02
    STA  clr_ptr_lo  ; $04
    LDY  #$00
    LDA  scr_row_ptr_hi,x  ; $EDF5,X
    ADC  #$00
    STA  scr_ptr_hi  ; $03
    ADC  #$D4
    STA  clr_ptr_hi  ; $05
    PLA
    TAX  ; restore X from stack
    PLA  ; restore A from stack
    RTS

add_points_to_score_then_update_high_score_and_reprint:
//-----------------------------------------------------
    LDY  real_game_mode_flag  ; $16  ; was set to #$ff in start_game
    BNE  add_to_score_only_when_in_real_game_mode  ; $E6E5
// if we are in attract mode, bail out early (we won't add anything to the score)
    RTS
add_to_score_only_when_in_real_game_mode:
    SED
    CLC
    ADC  p1_score_lo,x  ; $1D,X
    STA  p1_score_lo,x  ; $1D,X
    LDA  p1_score_hi,x  ; $1F,X
    ADC  #$00
    STA  p1_score_hi,x ; $1F,X
    LDA  high_score_lo  ; $21
    SEC
    SBC  p1_score_lo,x  ; $1D,X
    LDA  high_score_hi  ; $22
    SBC  p1_score_hi,x  ; $1F,X
    BCS  skip_set_high_score  ; $E704  ; branch if we didn't beat high score
set_high_score:
    LDA  p1_score_lo,x  ; $1D,X
    STA  high_score_lo  ; $21
    LDA  p1_score_hi,x  ; $1F,X
    STA  high_score_hi  ; $22
skip_set_high_score:
    CLD


print_all_scores:
//---------------
    LDA  #$01
    STA  txt_y_pos  ; $14
    STA  txt_x_pos  ; $13
    JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0

print_player1_score:
    LDY  #$02  ; the x-location to start drawing digits from
    LDA  p1_score_lo  ; $1D
    LDX  p1_score_hi  ; $1F
    JSR  print_two_digits_in_X_and_two_digits_in_A_and_two_trailing_zeroes  ; $E726

print_high_score:
    LDY  #$10
    LDA  high_score_lo  ; $21
    LDX  high_score_hi  ; $22
    JSR  print_two_digits_in_X_and_two_digits_in_A_and_two_trailing_zeroes  ; $E726

print_player2_score:
    LDY  #$1E  ; (30) the x-location to start drawing digits from
    LDA  p2_score_lo  ; var6  ; $1E
    LDX  p2_score_hi  ; var8  ; $20


print_two_digits_in_X_and_two_digits_in_A_and_two_trailing_zeroes:
//----------------------------------------------------------------
    JSR  print_two_digits_in_X_and_two_digits_in_A  ; $E731
    ; add two trailing zeroes
    LDA  #$46  ; #$46 = '0' char
    STA  (scr_ptr_lo),Y
    INY
    STA  (scr_ptr_lo),Y  ; Is this to put two trailing '0' chars at the end of the score?
    RTS


print_two_digits_in_X_and_two_digits_in_A:
---------------------
    PHA
    LDA  #$00
    STA  genvarB  ; $08  ; $00 = hide any leading zero
    TXA
    JSR  print_two_digits_in_A  ; $E73B
    PLA


print_two_digits_in_A:
---------------------
; input: genvarB = 0 = hide any leading zeroes (when called from 'print_two_digits_in_X_and_two_digits_in_A' for printing scores)
;                = 1 = show leading zeroes (when called from 'print_remaining_game_time' to show remaining seconds)
    PHA
    LSR
    LSR
    LSR
    LSR
    JSR  print_nibble  ; $E746  ; print digit in high nibble first
    PLA
print_lower_nibble_digit_in_A:
    AND  #$0F  ; then print digit in lower nibble
print_nibble:
    BNE  adjust_a_to_corresponding_screen_code_char  ; $E750  ; always print non-zero nibbles
    LDX  genvarB  ; $08
    BNE  adjust_a_to_corresponding_screen_code_char  ; $E750  ; only print zero if genvarB is non-zero
    LDA  #$26    ; #$26 = ' ' space char in char-map
    BNE  print_char_to_screen  ; $E755
adjust_a_to_corresponding_screen_code_char:
    CLC
    ADC  #$46  ; #$46 = '0' char in char-map  (so this could relate to printing score)
    INC  genvarB
print_char_to_screen:
    STA  (scr_ptr_lo),Y
    INY
    RTS


timer_loop:
//---------
    LDA  $DC0E  ; CIA Control Register A - bit0 = start(1)/stop(0) timer
    LSR
    BCS  timer_loop  ;  $E759
    INC  $DC0E  ; after timer has stopped, restart it (turn bit0 back on)
    RTS

maybe_unused_function:
//--------------------
// or maybe time waster function?
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RTS


read_paddle_fire_button:
//----------------------
    TAX  ; a = 0 always, so x = 0
    LDA  #$FF
    STA  $DC00  ; Data Port A - Write Keyboard Column Values for keyboard scan
                ; Setting to #$FF seems to disable the keyboard column scan, so that $DC01 will read its
                ; alternate bitfields (and not row values)
    LDA  $DC01  ; Data Port B - Read Keyboard Row Values for keyboard scan
    AND  paddle_fire_bitfields,X  ; always pb E797 = #$04  (paddle fire button)
    BNE  paddle_fire_not_pressed  ; if bit3 was 1 (i.e., paddle fire not pressed) then jump
    LDA  #$FF   ; bit3 was 0, so set A = FF to indicate paddle fire was pressed
    +bit_skip_2_bytes
paddle_fire_not_pressed:
      LDA  #$00
    RTS  ; If paddle fire not pressed, return A = 0
         ; If paddle fire is pressed, A = FF

paddle_fire_bitfields:
    !byte $04, $08         ; 04 is used by $E797 for paddle 1 fire test
                           ; 08 is used by $E797 for paddle 2 fire test


// LOCATION: E799
clear_screen_and_draw_scores:
//---------------
    LDX  #$00
loop_clear_next_screen_char_and_color:
    LDA  #$26  ; This is the space ' ' char in their charater map
    STA  $0400,X  ; clear the screen memory with space ' ' chars
    STA  $0500,X
    STA  $0600,X
    STA  $06E8,X
    LDA  #$01
    STA  $D800,X  ; set colour memory to all 1 (white) value
    STA  $D900,X
    STA  $DA00,X
    STA  $DAE8,X
    DEX
    BNE  loop_clear_next_screen_char_and_color  ; $E79B
    STX  txt_y_pos  ; (X=0 at this point, so txt_y_pos=0)
    JSR  draw_inline_text  ; $E839
    !byte $F8, $26, $26, $36, $32, $27, $3F, $2B,  $38, $26, $47, $26, $26, $26, $26, $26
    //                P  L  A  Y  E   R     1               
    !byte $2E, $2F, $2D, $2E, $26, $39, $29, $35,  $38, $2B, $26, $26, $26, $26, $26, $36
    //       H  I  G  H     S  C  O   R  E                 P
    !byte $32, $27, $3F, $2B, $38, $26, $48, $26,  $26, $00
    //       L  A  Y  E  R     2        
    JMP  print_all_scores  ; $E705


draw_text_to_screen:
//------------------
    LDA  #$00
    STA  txt_x_pos  ; $13
    JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
    LDA  #$01  ; The current colour to draw the text in (defaults to white)
    PHA        ; this var is pushed onto the stack
    LDY  #$00
    STY  txt_x_pos
loop_count_number_of_special_chars:
    LDA  (ret_ptr_lo),y  ; ($06),Y  ; ptr to inline text
    BEQ  end_of_string  ; $E807  ; if null-ptr / end-of-string, then branch
    CMP  #$F8
    BCC  skip_x_pos_increment
    INC  txt_x_pos   ; for now, txt_x_pos is storing the number of special chars
skip_x_pos_increment:
    INY
    BNE  loop_count_number_of_special_chars  ; $E7FA  ; branch until y increments back to zero (a max of 255 chars)
end_of_string:
    DEY  ; Y ought to equal the length of the string
    TYA  ; A = Y = length of string
    SEC
    SBC  txt_x_pos  ; A = length of string minus the count of special F8 chars
    LSR       ; A = A / 2
    STA  txt_x_pos  ; Store half the length of the string in $13
    LDA  #$13  ; (19, half the screen width)
    SEC
    SBC  txt_x_pos  ; A = (half screen width) - (half string width)
              ;   = the x-position to assure string is horizontally centred
    TAY
draw_char_loop:
    LDX  #$00
    LDA  (ret_ptr_lo,X)   ; pw 06 = $EFCD  (x=0, out: a = 35 = 'O')
    BEQ  found_null ; $E837     ; A = null terminator?
    CMP  #$F8
    BCC  draw_valid_char ; $E828   ; branch if A < #$f8
    AND  #$07  ; and with %0000 0111 (A = desired colour index for text that follows?)
    TSX  ; X = stack pointer low
    INX
    STA  $0100,X  ; A value of #$01 (default text colour=white) was pushed the stack earlier at $E7F3.
                  ; This will reset this stack value to new text colour specified by the special char
    BCS  skip_draw_valid_char  ; $E82F  ; I think this always jumps, due to prior CMP#$F8 being true?
draw_valid_char:
    STA  (scr_ptr_lo),y  ; ($02),Y  ; pw 02 = 0478 , y = 4  (draw A char onto the screen)
    PLA
    PHA  ; aah, the stack var is the current colour to draw the text in
    STA  (clr_ptr_lo),y  ; ($04),Y  ; pw 04 = d878
    INY
skip_draw_valid_char:
    INC  ret_ptr_lo  ; $06  ; pb 06 = CD
    BNE  draw_char_loop  ; $E815
    INC  ret_ptr_hi  ; $07  ; pb 07 = EF
    BNE  draw_char_loop ; $E815

found_null:
    PLA  ; drop the stack var for current text colour
    RTS


draw_inline_text:
//---------------
    PLA
    CLC
    ADC  #$01
    STA  ret_ptr_lo  ; $06
    PLA
    ADC  #$00
    STA  ret_ptr_hi  ; $07   ; seems to be pulling the return from jsr address into pw $06
    JSR  draw_text_to_screen  ; $E7EC

    LDA  ret_ptr_hi  ; $07  ; push the modified return location back onto the stack
    PHA
    LDA  ret_ptr_lo  ; $06
    PHA
    RTS


update_game_time_left:
//--------------------
    LDA  decimal_secs_in_minutes_left  ; $27
    ORA  minutes_left  ; $28
    BEQ  print_remaining_game_time  ; $E873
    DEC  secs_in_minute_left  ; $26
    BPL  print_remaining_game_time  ; $E873
    LDA  #$3B  ; dec59  ; (reset seconds in minute countdown?)
    STA  secs_in_minute_left  ; $26
    SED
    LDA  decimal_secs_in_minutes_left  ; $27
    SEC
    SBC  #$01
    CLD
    STA  decimal_secs_in_minutes_left  ; $27
    BCS  print_remaining_game_time  ; $E873
    LDA  #$59  ; value is used in 'decimal mode'
    STA  decimal_secs_in_minutes_left  ; $27
    LDA  minutes_left  ; $28
    SED
    SBC  #$00
    CLD
    STA  minutes_left  ; $28


print_remaining_game_time:
//------------------------
    LDA  #$12  ; (18)
    STA  txt_x_pos  ; $13
    LDA  #$18  ; (24)
    STA  txt_y_pos  ; $14
    JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
    LDY  #$00
    LDA  #$01
    STA  genvarB  ; $08  ; $01 = show leading zeroes in 'print_lower_nibble_digit_in_A' call and later 'print_two_digits_in_A' call
    LDA  minutes_left  ; $28
    JSR  print_lower_nibble_digit_in_A  ; $E744
    LDA  #$42  ; ':' char
    STA  (scr_ptr_lo),y  ; ($02),Y
    INY
    LDA  decimal_secs_in_minutes_left  ; $27
    JMP  print_two_digits_in_A  ; $E73B


random_num_gen_into_A:
---------------------
// NOTE: randomval_lsb is constantly incremented inside the game_loop routine on every frame/iteration
//       (perhaps to improve the randomness provided by this routine)
    TXA  ; ship-index?
    PHA
    LDX  #$0B  ; dec11  ; loop over 10 times
loop_next_shift_left_and_bit0_insertion:
    ASL  randomval_lsb  ; $1B
    ROL  randomval_msb  ; $1C  ; treat randomval_lsb+randomval_msb like a 16-bit number we rol to the left (multiply by 2)
    ROL  ; rol whatever was left in Areg (usually some index/iterator value, usually ranging 0-7?)
    ROL  ; i.e., multiply this 'random-ish' value by 4
    EOR  randomval_lsb  ; $1B  ; flip some bits in the lsb of this 16-bit value
    ROL  ; multiply this 'random-ish' A value by 2
    EOR  randomval_lsb  ; $1B  ; flip some more bits in the lsb of this 16-bit value
    LSR
    LSR  ; divide 'random-ish' A value by 4
    EOR  #$FF  ; flip all the bits in 'random-ish' A
    AND  #$01  ; at this point, a=0 or 1  (only care about bit0 of regA)
    ORA  randomval_lsb  ; $1B  ; this could 'potentially' set bit0 of lsb of 16-bit value
    STA  randomval_lsb  ; $1B  ; so maybe it's a way to assure some balance between odd & even numbers?
    DEX
    BNE  loop_next_shift_left_and_bit0_insertion  ; $E897  ; loop from 11 to 1  ; repeat this randomizing recipe 10 times
    PLA
    TAX  ; restore prior regX value
    LDA  randomval_lsb  ; $1B  ; we return regA as our 'random' result
    RTS


set_sprite_position:
-------------------
// A = ship/buoy sprite index
//   - ships are from sprite index 0-3
//   - buoys are from sprite index 4-7
// xpos_local = curr ship/buoy xpos
// ypos_local = curr ship/buoy ypos
    TAX
    ASL  ; multiply by 2
    TAY
    LDA  xpos_local  ; $11
    CLC
    ADC  #$0C  ; add 12
    ASL
    STA  $D000,Y  ; store in sprite x-pos of desired sprite
    BCS  turn_on_msb_for_this_sprite  ; $E8CB
    ; turn off msb for this sprite
    ; ----------------------------
    LDA  and_bitfields,x  ; $EE40,X
    AND  $D010  ; sprite 0-7 xpos msb  ; turn off sprite xpos msb
    JMP  skip_turn_on_msb_for_this_sprite  ; $E8D1
turn_on_msb_for_this_sprite:
    LDA  or_bitfields,x  ; $EE38,X  ; turn on sprite xpos msb
    ORA  $D010
skip_turn_on_msb_for_this_sprite:
    STA  $D010  ; set sprite xpos msb to desired value (either on/off)
    LDA  ypos_local  ; $12
    CLC
    ADC  #$32  ; dec50  ; adjust ship y-pos to absolute sprite coordinates
    STA  $D001,Y  ; set sprite ypos
    RTS


turn_on_sprite_A:
----------------
    TAX
    LDA  or_bitfields,x  ; $EE38,X
    ORA  $D015
    STA  $D015  ; sprite display enable
    RTS


turn_off_sprite_A:
-----------------
    TAX
    LDA  and_bitfields,x  ; $EE40,X
    AND  $D015
    STA  $D015  ; sprite display disable
    RTS

allow_interrupts:
----------------
    CLI
    RTS

interrupt_precursor:
-------------------
    SEI
    LDA  #$00
    STA  $D021
    STA  $D020
    LDA  #$00
    STA  $D015  ; sprite display enable (hide them all?)
    RTS

interrupt_routine:
-----------------
    PHA
    TXA
    PHA
    LDX  $1A
    LDA  raster_colours,x  ; $E928,X
    STA  $D021
    STA  $D020
    LDA  raster_locations,x  ; $E92C,X
    STA  $D012  ; read/write raster value for compare irq
    INX
    TXA
    AND  #$03
    STA  $1A
    LDA  $D019  ; vic interrupt flag register
    STA  $D019
    PLA
    TAX
    PLA
    RTI

raster_colours:
// used within interrupt routine
    !byte $03, $0E, $06, $00
//  - [0] = 03 (cyan)
//  - [1] = 0e (light blue)
//  - [2] = 06 (blue)
//  - [3] = 00 (black)


raster_locations:
    !byte $46, $8A, $DA, $14

---------------------

init_sid:
--------
    LDX  #$18  ; (24)
loop_init_sid_values:
    LDA  sid_init_values,x  ; $EBDC,X
    STA  $D400,X
    DEX
    BPL  loop_init_sid_values
    RTS


v1_reset_and_gate_off:
---------------------
// we've spawned a pt boat, so turn off prior ocean sound (to make way for pt boat beep-beep later)
    LDA  #$06
    STA  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
    LDA  #$00
    STA  $D400  ; v1_freq_lo
    STA  $D401  ; v1_freq_hi
    LDA  #$50   ; %0101 0000
    STA  $D406  ; v1_env_sus_rel
    LDA  #$40   ; %0100 0000
    STA  $D404  ; v1_ctrl_reg  (select pulse, gate off)
    RTS


play_fire_shoot_sound_on_v2:
//--------------------------
    LDA  #$03
    STA  v2_missile_fire_snd_counter  ; $2B
    LDA  #$81  ; %1000 0001
    STA  $D40B  ; v2_ctrl_reg  (noise wave, gate on)
    RTS

trigger_voice3_sound:
//-------------------
    LDA  #$03
    STA  v3_explosion_snd_counter  ; $2C
    LDA  #$81  ; %1000 0001
    STA  $D412  ; This is turning gate on for voice3  (perhaps to trigger explosion sound?)
    RTS

assess_sound_states:
-------------------
  ; assesses whether to turn off any player fire/shot or ship explosion sounds
  ; also assesses whether to switch v1 to play the beep-beep of the P.T. boat
    LDA  general_sound_timer  ; $2D  ; this timer counts down from 3 to 0, then resets back to 3 and repeats this
    BEQ  reset_general_sound_timer  ; $E96E
    DEC  general_sound_timer  ; $2D
    RTS
reset_general_sound_timer:
    LDA  #$03
    STA  general_sound_timer  ; $2D
    ; assess if it's time to turn off v2 missile fire sound
    ; -----------------------------------------------------
    LDA  v2_missile_fire_snd_counter  ; $2B
    BEQ  assess_if_v3_explosion_snd_counter_has_expired  ; $E97F  ; if missile-fire sound timer already expired, then branch to check of v3 sound
    DEC  v2_missile_fire_snd_counter  ; $2B
    BNE  assess_if_v3_explosion_snd_counter_has_expired  ; $E97F
    ; if we have decremented timer to zero, then it's time to turn off the sound
    ; --------------------------------------------------------------------------
    LDA  #$80  ; %1000 0000
    STA  $D40B  ; v2_ctrl_reg  (noise wave, gate off)  ; turn off player fire/shoot sound?

assess_if_v3_explosion_snd_counter_has_expired:
    LDA  v3_explosion_snd_counter  ; $2C
    BEQ  check_if_any_ptboats_visible  ; $E98C
    DEC  v3_explosion_snd_counter  ; $2C
    BNE  check_if_any_ptboats_visible  ; $E98C
    LDA  #$80  ; %1000 0000
    STA  $D412  ; v3_ctrl_reg  (noise wave, gate off)  ; turn off explosion sound?

check_if_any_ptboats_visible:
    LDX  #$03
loop_next_ship_is_ptboat_check:
    LDA  ships_visibility,x  ; $39,X
    BEQ  skip_to_next_ship_check  ; $E99A   ; if ship is invisible, branch
    BMI  skip_to_next_ship_check  ; $E99A   ; if ship is exploding, branch
    LDA  ships_type,x  ; $51,X  ; possibly index to the type of ship on screen
    CMP  #$02
    BEQ  assess_ptboat_beep_beep_sound_state  ; $E9A9
skip_to_next_ship_check:
    DEX
    BPL  loop_next_ship_is_ptboat_check  ; $E98E
    LDX  #$06
loop_reset_sid_v1_to_ocean_sound:
    LDA  sid_init_values,x  ; $EBDC,X
    STA  $D400,X  ; reset sid voice1 values (ocean sound?)
    DEX
    BPL  loop_reset_sid_v1_to_ocean_sound  ; $E99F
    RTS

assess_ptboat_beep_beep_sound_state:
    DEC  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
    BPL  skip_ptboat_reset_state  ; $E9B1
    ; reset ptboat beep-beep state (so that the sound pattern repeats)
    ; ----------------------------
    LDA  #$05
    STA  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
skip_ptboat_reset_state:
    LDA  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
    ASL  ; multiply by 2
    TAX
    LDA  v1_ptboat_beep_beep_freq_array,x  ; $EE2C,X
    STA  $D400  ; v1_freq_lo
    LDA  v1_ptboat_beep_beep_freq_array+1,x  ; $EE2D,X
    STA  $D401  ; v1_freq_hi
    LDA  #$41  ; %0100 0001
    STA  $D404  ; v1_ctrl_reg  ; (pulse wave, gate on)  ; seems like the beep-beep of the P.T. boat
    RTS


start_game:
//---------
    JSR  init_game_vars  ; $EB93
    LDA  #$FF  ; turn on flag to say we are in real game (and not in attract mode)
    STA  real_game_mode_flag  ; $16
    LDA  initial_game_time  ; $17
    STA  minutes_left  ; $28
    STA  last_paddle_fire_state  ; $33
    STA  last_paddle_fire_state+1  ; $34
    LDA  #$00
    STA  p1_score_lo  ; $1D
    STA  p2_score_lo  ; $1E
    STA  p1_score_hi  ; $1F
    STA  p2_score_hi  ; $20
    JSR  prepare_game_screen ; $E57D
    JSR  init_sid  ; $E930
    LDA  #$3F  ; %0011 1111
    STA  $D418 ; filter bandpass+low-pass, volume = 15
    JSR  game_loop  ; $EB58
    LDA  #$00   ; (no filter, zero volume)
    STA  $D418  ; sid_sel_filter_and_vol
    LDA  #$0A
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $2D, $27, $33, $2B, $26, $26, $35, $3C,  $2B, $38, $00 
    //       G  A  M  E        O  V   E  R

    LDX  #$96
    JSR  timer_loop  ; $E759
    DEX
    BNE  $EA07
turn_off_attract_mode_and_show_intro_screen:
    LDA  #$00  ; turn off flag to say we are in attract mode game (and not in real game mode)
    STA  real_game_mode_flag  ; $16
    JSR  show_intro_screen  ; $E5CD
    TAY  ; (A=$ff if user pressed F1 or paddle-fire during intro screen, else A=0)
    BNE  user_wants_to_start_game  ; user pressed F1 or paddle fire to start game?
; ATTRACT MODE
; ------------
    JSR  init_game_vars  ; $EB93
    LDA  #$20
    STA  decimal_secs_in_minutes_left  ; $27
    LDX  #$01  ; player index (1=player2, 0=player1)
retry_random_num_for_initial_player_sub_position_in_attract_mode:
    JSR  random_num_gen_into_A  ; $E893
    CMP  #$28  ; dec40
    BCS  retry_random_num_for_initial_player_sub_position_in_attract_mode  ; if a >= 40 then loop
    STA  players_xpos,x  ; $35,X  ; place both player subs at some random 0-39 char xpos
    DEX  ; switch index from player2 to player1
    BPL  retry_random_num_for_initial_player_sub_position_in_attract_mode
    JSR  prepare_game_screen  ; $E57D
    LDA  #$0A  ; dec10
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

; this is overlay text shown in attract mode during gameplay

    !byte $2D, $27, $33, $2B, $26, $26, $35, $3C,  $2B, $38, $00
    //       G  A  M  E        O  V   E  R

    LDA  #$0F
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $36, $3B, $39, $2E, $26, $43, $2C, $47,  $43, $26, $3A, $35, $26, $28, $2B, $2D
    //       P  U  S  H     -  F  1   -     T  O     B  E  G
    !byte $2F, $34, $00
    //       I  N

    JSR  game_loop  ; $EB58  ; run game-loop for attract mode
    TAY  ; A = 1 only it we have pressed paddle fire while in attract mode
    BEQ  turn_off_attract_mode_and_show_intro_screen  ; $EA0D
user_wants_to_start_game:
; draw game-time selection screen
; -------------------------------
    JSR  clear_screen_and_draw_scores  ; $E799
    LDA  #$00
    STA  $D015  ; sprite display enable (hide all sprites)
    STA  $D40D  ; v2_env_gen sus/rel
    STA  $D414  ; v3_env_gen sus/rel
    JSR  allow_interrupts  ; $E8F3
    LDA  #$01
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

// trailing two zeroes of p1 score + highscore + p2 score
// ------------------------------------------------------
    !byte $F8, $26, $26, $26, $26, $46, $46, $26,  $26, $26, $26, $26, $26, $26, $26, $26
    //                      0  0                            
    !byte $26, $26, $26, $46, $46, $26, $26, $26,  $26, $26, $26, $26, $26, $26, $26, $26
    //                0  0                                  
    !byte $26, $46, $46, $00
    //          0  0

    LDA  #$05
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $43, $26, $36, $3B, $39, $2E, $26, $43,  $00 
    //       -     P  U  S  H     -

    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $2C, $47, $26, $3A, $35, $26, $39, $3A,  $27, $38, $3A, $26, $2D, $27, $33, $2B
    //       F  1     T  O     S  T   A  R  T     G  A  M  E
    !byte $41, $00
    //       .

    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $2C, $49, $26, $3A, $35, $26, $26, $2F,  $34, $29, $38, $2B, $27, $39, $2B, $26
    //       F  3     T  O        I   N  C  R  E  A  S  E  
    !byte $00

    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $26, $2C, $4B, $26, $3A, $35, $26, $26,  $2A, $2B, $29, $38, $2B, $27, $39, $2B
    //          F  5     T  O         D  E  C  R  E  A  S  E
    !byte $26, $00

    INC  txt_y_pos  ; $14
    INC  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $26, $36, $32, $27, $3F, $2F, $34, $2D,  $26, $3A, $2F, $33, $2B, $41, $00
    //          P  L  A  Y  I  N  G      T  I  M  E  .

    LDA  #$00
    STA  decimal_secs_in_minutes_left  ; $27
    LDA  #$17  ; dec23
    STA  txt_y_pos  ; $14
    JSR  draw_inline_text  ; $E839

    !byte $36, $32, $27, $3F, $2F, $34, $2D, $26,  $3A, $2F, $33, $2B, $00
    //       P  L  A  Y  I  N  G      T  I  M  E

    LDA  initial_game_time  ; $17
    STA  minutes_left  ; $28
retry_print_game_time_choice:
    JSR  print_remaining_game_time  ; $E873
retry_read_user_input:
    JSR  parent_routine_that_does_key_paddle_input  ; $E568
    CMP  #$01   ; was paddle-fire or F1 pressed?
    BNE  assess_F3_key_press  ; $EB3A  ; if not, branch
    JMP  start_game  ; $E9C7
assess_F3_key_press:
    CMP  #$03  ; was F3 pressed? (increase time)
    BNE  handle_F5_key_press  ; $EB4B  ; if not, branch
    LDA  minutes_left  ; $28
    CMP  #$09
    BEQ  retry_read_user_input  ; $EB30  ; if already 9 minutes, can't increase further, branch back
    INC  initial_game_time  ; $17
    INC  minutes_left  ; $28
    JMP  retry_print_game_time_choice  ; $EB2D
handle_F5_key_press:
    ; we're assuming if it's not paddle-fire, F1 or F3, then at this point, it must be F5 (decrease time)
    LDA  minutes_left  ; $28
    CMP  #$01
    BEQ  retry_read_user_input  ; $EB30
    DEC  initial_game_time  ; $17
    DEC  minutes_left  ; $28
    JMP  retry_print_game_time_choice  ; $EB2D


game_loop:
//--------
loopback:
    LDA  $D01E  ; sprite-to-sprite collision detect
    STA  buff_spr2spr_coll  ; $18
    LDA  $D01F  ; sprite-to-background collision detect
    STA  buff_spr2back_coll  ; $19
    JSR  ship_logic  ; $E000  ; has logic to spawn new ships when needed
    JSR  buoy_logic  ; $E1C8
    JSR  handle_missile_firing_and_player_movement  ; $E27D
    JSR  update_player_submarine_positions  ; $E3CE
    JSR  missile_redraw_assessment  ; $E45F
    LDA  real_game_mode_flag  ; $16
    BEQ  skip_if_in_attract_mode  ; $EB78
    JSR  assess_sound_states  ; $E967
skip_if_in_attract_mode:
    JSR  update_game_time_left  ; $E84E
    JSR  timer_loop  ; $E759
    LDA  real_game_mode_flag  ; $16
    BNE  skip_exit_attract_check  ; $EB8C
exit_attract_check:
    INC  randomval_lsb  ; $1B
    JSR  paddle_and_function_key_reading_routine  ; $E536
    TAY
    CMP  #$01
    BEQ  exit_game_loop_routine  ; $EB92  ; was paddle-fire or F1 pressed?
skip_exit_attract_check:
    LDA  minutes_left  ; $28
    ORA  decimal_secs_in_minutes_left  ; $27
    BNE  loopback  ; $EB58
exit_game_loop_routine:
    RTS


init_game_vars:
//-------------
    LDX  #$82
    LDA  #$00
    STA  $D015  ; sprite display enable/disable  (this will disable them all)
loop_next_var_to_reset:
    STA  $22,X  ; reset vars in range of $22 to $A4 to zero
    DEX
    BNE  loop_next_var_to_reset  ; $EB9A
    LDA  #$04
    STA  p1_num_missiles  ; $31
    STA  p2_num_missiles  ; $32
    LDA  #$00
    STA  buoys_xpos  ; $61
    LDA  #$44
    STA  buoys_xpos+1  ; $62
    LDA  #$60
    STA  buoys_ypos  ; $65
    STA  buoys_ypos+1  ; $66
    LDA  #$01
    STA  buoys_visibility  ; $5D
    STA  buoys_visibility+1  ; $5E
    LDA  #$3B  ; dec59
    STA  secs_in_minute_left  ; $26
    RTS

vic_init_values:
    !byte $1B, $00, $00, $00, $00, $08, $00, $10,  $FF, $00, $FF, $00, $0F, $00, $00, $03
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00

// $d011 = vic_ctrl_reg = 1B = %0001 1011
//     bit7 = raster_compare
//     bit6 = extended colour text (0=disable)
//     bit5 = bitmap mode (0=disable)
//     bit4 = blank screen to border colour (1=disable)
//     bit3 = select 24/25 row text (1=25rows)
//   bit2-0 = smooth scroll to y-dot position (val=3)
// $d012 = read/write raster value for compare irq (00)
// $d013 = light-pen latch xpos (00)
// $d014 = light-pen latch ypos (00)
// $d015 = sprite display enable (00 = disable all)
// $d016 = vic_ctrl_reg = 08 (%0000 1000)
//   bit7-6 = unused
//   bit5   = always set to zero
//   bit4   = multi-colour mode (0 = disable)
//   bit3   = select 38/40 column text (1 = 40 columns)
//   bit2-0 = smooth scroll to x-pos (val = 0)
// $d017 = sprites_expand_vert = 00
// $d018 = vic_mem_ctrl_reg = 10 (%0001 0000)
//   bit7-4 = video_matrix_base_addr (screen memory) = %0001 (i.e., default $0400 location)
//   bit3-1 = char dot-data base addr = %000 ; from $0000 to $07ff (based on vic-ii bank chosen by $DD00 - see c64 ref page 101)
//  $d019 = vic_interrupt_flag_reg = ff (%1111 1111)
//   bit7 = set on any enabled VIC IRQ condition
//   bit3 = light-pen triggered irq
//   bit2 = sprite-to-sprite collision irq
//   bit1 = sprite-to-background collision irq
//   bit0 = raster-compare irq flag
// $d01a = irq mask reg = 00 (0 = interrupt disabled)
// $d01b = sprite-to-background priority display = FF (1 = sprite)
// $d01c = sprite 0-7 multi-colour mode = 00 (0 = disable)
// $d01d = sprite 0-7 expand 2x horizontal = $0F = %0000 1111
//          (i.e., expand sprites 0-3 horz - for the ships)
// $d01e = sprite-to-sprite collision detect = 00
// $d01f = sprite-to-background collision detect = 00
// $d020 = border colour = 03 (cyan?)
// $d021 = background colour 0 = 00 (black)
// $d022 = background colour 1 = 00
// $d023 = background colour 2 = 00
// $d024 = background colour 3 = 00
// $d025 = sprite multi-colour register 0 = 00
// $d026 = sprite multi-colour register 1 = 00
// $d027 = sprite 0 colour = 00
// $d028 = sprite 1 colour = 00
// $d029 = sprite 2 colour = 00
// $d02a = sprite 3 colour = 00
// $d02b = sprite 4 colour = 00
// $d02c = sprite 5 colour = 00
// $d02d = sprite 6 colour = 00
// $d02e = sprite 6 colour = 00

sid_init_values:
    !byte $88, $13, $00, $08, $81, $00, $21, $98,  $3A, $00, $08, $80, $8C, $4B, $B0, $04
    !byte $00, $08, $80, $00, $FA, $00, $96, $F4,  $30

// VOICE1  (ocean sound?)
// ------
// $d400 = v1_freq_lo = $88
// $d401 = v1_freq_hi = $13
// $d402 = v1_pulse_lo = $00
// $d403 = v1_pulse_hi = $08
// $d404 = $81 = %1000 0001
//    $d404.7 = select noise = on
//    $d404.6 = select pulse = off
//    $d404.5 = select sawtooth = off
//    $d404.4 = select triangle = off
//    $d404.3 = disable oscillator 1 = off
//    $d404.2 = ring mod osc1 with osc3 = off
//    $d404.1 = sync osc1 with osc3 freq = off
//    $d404.0 = gate = on (start att/dec/sus)
// $d405 = v1_env_att_dec = $00 = %0000 0000
//    $d405.7-4 = attack = 0
//    $d405.3-0 = decay = 0
// $d406 = v1_env_sus_rel = $21 = %0010 0001
//    $d406.7-4 = sustain = 2
//    $d406.3-0 = release = 1
//
// VOICE2  (fire sound?)
// ------	
// $d407 = v2_freq_lo = $98
// $d408 = v2_freq_hi = $3A
// $d409 = v2_pulse_lo = $00
// $d40a = v2_pulse_hi = $08
// $d40b = $80 = %1000 0000
//    $d40b.7 = select noise = on
//    $d40b.6 = select pulse = off
//    $d40b.5 = select sawtooth = off
//    $d40b.4 = select triangle = off
//    $d40b.3 = disable oscillator 2 = off
//    $d40b.2 = ring mod osc2 with osc1 = off
//    $d40b.1 = sync osc2 with osc1 freq = off
//    $d40b.0 = gate = off (start att/dec/sus)
// $d40c = v2_env_att_dec = $8C = %1000 1100
//    $d40c.7-4 = attack = 8
//    $d40c.3-0 = decay = 12
// $d40d = v2_env_sus_rel = $4B = %0100 1011
//    $d40d.7-4 = sustain = 4
//    $d40d.3-0 = release = 11
//
// VOICE3  (explosion sound?)
// ------	
// $d40e = v3_freq_lo = $B0
// $d40f = v3_freq_hi = $04
// $d410 = v3_pulse_lo = $00
// $d411 = v3_pulse_hi = $08
// $d412 = $80 = %1000 0000
//    $d412.7 = select noise = on
//    $d412.6 = select pulse = off
//    $d412.5 = select sawtooth = off
//    $d412.4 = select triangle = off
//    $d412.3 = disable oscillator 3 = off
//    $d412.2 = ring mod osc3 with osc2 = off
//    $d412.1 = sync osc3 with osc2 freq = off
//    $d412.0 = gate = off (start att/dec/sus)
// $d413 = v3_env_att_dec = $00 = %0000 0000
//    $d413.7-4 = attack = 0
//    $d413.3-0 = decay = 0
// $d414 = v3_env_sus_rel = $FA %1111 1010
//    $d414.7-4 = sustain = 15
//    $d414.3-0 = release = 10
//
// FILTERS/VOLUME
// --------------
// $d415 = filter_cutoff_freq_lo (2-0) = $00
// $d416 = filter_cutoff_freq_hi (10-3) = $96
// $d417 = $F4 = %1111 0100
//    $d417.7-4 = filter resonance = 15
//    $d417.3 = filter external input = 0 (no)
//    $d417.2 = filter v3 output = 1 (yes)
//    $d417.1 = filter v2 output = 0 (no)
//    $d417.0 = filter v1 output = 0 (no)
// $d418 = $30 = %0011 0000
//    $d418.7 = cut-off v3 output = 0 (on)
//    $d418.6 = filter high-pass mode = 0 (off)
//    $d418.5 = filter band-pass mode = 1 (on)
//    $d418.4 = filter low-pass mode = 1 (on)
//    $d418.3-0 = output volume = 4

cold_start_handler:
//-----------------
    SEI
    CLD
    LDX  #$2F
    TXS  ; Why stack pointer so low? Aah, to make room for char-data copied into $0130 and onwards at $EC5C
    LDX  #$1D
    LDA  vic_init_values,x  ; $EBBE,X
    STA  $D011,X
    DEX
    BPL  $EBFC
    LDA  $D01E  ; sprite-to-sprite collision detect (read it to reset the value)
    LDA  $D01F  ; sprite-to-background collision detect (read it to reset the value)
    JSR  init_sid  ; $E930
    LDA  #$7F   ; %0111 1111
    STA  $DC0D  ; cia_irq_ctrl_reg (only allow IRQ, not others)
    LDA  #$00   ; %0000 0000
    STA  $DC0F  ; cia_ctrl_reg_B (use clk, timer b count system 2 clks, continuous, pulse, no, stop)
    LDX  #$00
    STX  $DC03  ; ddr_port_b
    DEX
    STX  $DC02  ; ddr_port_a
    LDA  #$E5   ; %1110 0101
    STA  $01    ; (cassette-motor=off, cassette-switch=closed, char-rom-in=no, kernal-rom=off, basic-rom=on)
    LDA  #$2F   ; %0010 1111
    STA  $00    ; mos 6510 ddr (1=output, 0=input)
    LDA  #$06
    STA  $DC04  ; timer_a_low_byte
    LDA  #$47
    STA  $DC05  ; timer_a_high_byte
    LDA  #$18   ; %0001 1000
    STA  $DC0E  ; cia_ctrl_reg_a (todclk=60Hz, serialio=input, tmracnt=system2clk, forceloadtmra=yes
                ;                 tmramode=oneshot, tmraoutputmode=pulse, outonpb6=no, startstoptmra=stop)
    LDA  #$01
    STA  $D01A  ; irq_mask_reg (raster_compare_irq = enabled)
    LDX  #$02
    LDA  #$00   ; initialise-to-zero all global variables in zero-page
loop_next_zp_var_to_reset:
    STA  $00,X
    INX
    BNE  loop_next_zp_var_to_reset
    LDA  #$03
    STA  initial_game_time  ; $17
loop_next_charset_data_to_copy_across:
    LDA  char_data_group1,x  ; $EC5C,X
    STA  $0130,X  ; copy across charset to vicii-bank 0, starting at charidx $26 (' ' space char)
    LDA  char_data_group2,x  ; $ECD4,X
    STA  $01A8,X  ; copy across charset to vicii-bank 0, starting at charidx $35 (letter 'O')
    INX
    BNE  loop_next_charset_data_to_copy_across
    JMP  turn_off_attract_mode_and_show_intro_screen  ; $EA0D

char_data_group1:
//---------------
//  - starting at chridx $26
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $38, $6C, $C6, $C6, $FE, $C6, $C6, $00
    !byte $FC, $66, $66, $7C, $66, $66, $FC, $00,  $3C, $66, $C0, $C0, $C0, $66, $3C, $00
    !byte $F8, $64, $66, $66, $66, $64, $F8, $00,  $FE, $60, $60, $7C, $60, $60, $FE, $00
    !byte $FE, $60, $60, $7C, $60, $60, $F0, $00,  $3C, $66, $C0, $DE, $C6, $66, $3C, $00
// char idx $26 address: $0130
// +--------+--------+--------+--------+--------+--------+--------+--------+
// |        |  ***   |******  |  ****  |*****   |******* |******* |  ****  |
// |        | ** **  | **  ** | **  ** | **  *  | **     | **     | **  ** |
// |        |**   ** | **  ** |**      | **  ** | **     | **     |**      |
// |        |**   ** | *****  |**      | **  ** | *****  | *****  |** **** |
// |        |******* | **  ** |**      | **  ** | **     | **     |**   ** |
// |        |**   ** | **  ** | **  ** | **  *  | **     | **     | **  ** |
// |        |**   ** |******  |  ****  |*****   |******* |****    |  ****  |
// |        |        |        |        |        |        |        |        |
// +--------+--------+--------+--------+--------+--------+--------+--------+

    !byte $C6, $C6, $C6, $FE, $C6, $C6, $C6, $00,  $3C, $18, $18, $18, $18, $18, $3C, $00
    !byte $1E, $0C, $0C, $0C, $CC, $CC, $78, $00,  $C6, $CC, $D8, $F0, $D8, $CC, $C6, $00
    !byte $F0, $60, $60, $60, $60, $60, $FE, $00,  $C6, $EE, $FE, $D6, $C6, $C6, $C6, $00
    !byte $C6, $E6, $F6, $DE, $CE, $C6, $C6, $00
// char idx $2E address: $0170
// +--------+--------+--------+--------+--------+--------+--------+
// |**   ** |  ****  |   **** |**   ** |****    |**   ** |**   ** |
// |**   ** |   **   |    **  |**  **  | **     |*** *** |***  ** |
// |**   ** |   **   |    **  |** **   | **     |******* |**** ** |
// |******* |   **   |    **  |****    | **     |** * ** |** **** |
// |**   ** |   **   |**  **  |** **   | **     |**   ** |**  *** |
// |**   ** |   **   |**  **  |**  **  | **     |**   ** |**   ** |
// |**   ** |  ****  | ****   |**   ** |******* |**   ** |**   ** |
// |        |        |        |        |        |        |        |
// +--------+--------+--------+--------+--------+--------+--------+

char_data_group2:
//---------------
    !byte $7C, $EE, $C6, $C6, $C6, $EE, $7C, $00,  $FC, $66, $66, $7C, $60, $60, $F0, $00
    !byte $38, $64, $C2, $C2, $CA, $64, $3A, $00,  $FC, $C6, $C6, $FC, $D8, $CC, $C6, $00
    !byte $7C, $C6, $C0, $7C, $06, $C6, $7C, $00,  $7E, $18, $18, $18, $18, $18, $3C, $00
    !byte $C6, $C6, $C6, $C6, $C6, $C6, $7C, $00,  $C6, $C6, $C6, $6C, $6C, $38, $38, $00
// char idx $35 address: $01A8
// +--------+--------+--------+--------+--------+--------+--------+--------+
// | *****  |******  |  ***   |******  | *****  | ****** |**   ** |**   ** |
// |*** *** | **  ** | **  *  |**   ** |**   ** |   **   |**   ** |**   ** |
// |**   ** | **  ** |**    * |**   ** |**      |   **   |**   ** |**   ** |
// |**   ** | *****  |**    * |******  | *****  |   **   |**   ** | ** **  |
// |**   ** | **     |**  * * |** **   |     ** |   **   |**   ** | ** **  |
// |*** *** | **     | **  *  |**  **  |**   ** |   **   |**   ** |  ***   |
// | *****  |****    |  *** * |**   ** | *****  |  ****  | *****  |  ***   |
// |        |        |        |        |        |        |        |        |
// +--------+--------+--------+--------+--------+--------+--------+--------+

    !byte $C6, $C6, $C6, $D6, $D6, $FE, $6C, $00,  $C6, $C6, $6C, $38, $6C, $C6, $C6, $00
    !byte $C6, $C6, $6C, $7C, $38, $38, $38, $00,  $FE, $C6, $0C, $38, $60, $C6, $FE, $00
    !byte $00, $00, $00, $00, $18, $18, $00, $00,  $00, $18, $18, $00, $18, $18, $00, $00
    !byte $00, $00, $00, $7E, $7E, $00, $00, $00,  $0C, $18, $30, $30, $30, $18, $0C, $00
// char idx $3D address: $01E8
// +--------+--------+--------+--------+--------+--------+--------+--------+
// |**   ** |**   ** |**   ** |******* |        |        |        |    **  |
// |**   ** |**   ** |**   ** |**   ** |        |   **   |        |   **   |
// |**   ** | ** **  | ** **  |    **  |        |   **   |        |  **    |
// |** * ** |  ***   | *****  |  ***   |        |        | ****** |  **    |
// |** * ** | ** **  |  ***   | **     |   **   |   **   | ****** |  **    |
// |******* |**   ** |  ***   |**   ** |   **   |   **   |        |   **   |
// | ** **  |**   ** |  ***   |******* |        |        |        |    **  |
// |        |        |        |        |        |        |        |        |
// +--------+--------+--------+--------+--------+--------+--------+--------+

    !byte $30, $18, $0C, $0C, $0C, $18, $30, $00,  $7C, $C6, $CE, $D6, $E6, $C6, $7C, $00
    !byte $18, $38, $18, $18, $18, $18, $3C, $00,  $7C, $C6, $C6, $0C, $38, $E0, $FE, $00
    !byte $7C, $C6, $06, $1C, $06, $C6, $7C, $00,  $0C, $1C, $2C, $4C, $FE, $0C, $0C, $00
    !byte $FE, $C0, $C0, $FC, $06, $C6, $7C, $00,  $1C, $30, $60, $FC, $C6, $C6, $7C, $00
// char idx $45 address: $0228
// +--------+--------+--------+--------+--------+--------+--------+--------+
// |  **    | *****  |   **   | *****  | *****  |    **  |******* |   ***  |
// |   **   |**   ** |  ***   |**   ** |**   ** |   ***  |**      |  **    |
// |    **  |**  *** |   **   |**   ** |     ** |  * **  |**      | **     |
// |    **  |** * ** |   **   |    **  |   ***  | *  **  |******  |******  |
// |    **  |***  ** |   **   |  ***   |     ** |******* |     ** |**   ** |
// |   **   |**   ** |   **   |***     |**   ** |    **  |**   ** |**   ** |
// |  **    | *****  |  ****  |******* | *****  |    **  | *****  | *****  |
// |        |        |        |        |        |        |        |        |
// +--------+--------+--------+--------+--------+--------+--------+--------+

    !byte $7E, $C6, $0C, $18, $18, $18, $18, $00,  $7C, $C6, $C6, $7C, $C6, $C6, $7C, $00
    !byte $7C, $C6, $C6, $7E, $06, $0C, $38, $00,  $00, $3F, $7F, $FF, $FF, $7F, $3F, $00
    !byte $00, $FF, $FF, $FF, $FF, $FF, $FF, $00,  $00, $FF, $FF, $FF, $FF, $FF, $FF, $00
    !byte $00, $8C, $CC, $FF, $FF, $CC, $8C, $00,  $60, $80, $40, $29, $CF, $09, $09, $09
// char idx $4D address: $0268
// +--------+--------+--------+--------+--------+--------+--------+--------+
// | ****** | *****  | *****  |        |        |        |        | **     |
// |**   ** |**   ** |**   ** |  ******|********|********|*   **  |*       |
// |    **  |**   ** |**   ** | *******|********|********|**  **  | *      |
// |   **   | *****  | ****** |********|********|********|********|  * *  *|
// |   **   |**   ** |     ** |********|********|********|********|**  ****|
// |   **   |**   ** |    **  | *******|********|********|**  **  |    *  *|
// |   **   | *****  |  ***   |  ******|********|********|*   **  |    *  *|
// |        |        |        |        |        |        |        |    *  *|
// +--------+--------+--------+--------+--------+--------+--------+--------+

some_unused_char_maybe:
//---------------------
//  - This looks like HAL (HAL Laboratories?)
    !byte $A4, $EE, $AA, $00, $20, $20, $38, $00
// char idx $55
// +--------+
// |* *  *  |
// |*** *** |
// |* * * * |
// |        |
// |  *     |
// |  *     |
// |  ***   |
// |        |
// +--------+

scr_row_ptr_lo:
//-------------
    !byte $00, $28, $50, $78, $A0, $C8, $F0, $18,  $40, $68, $90, $B8, $E0, $08, $30, $58
    !byte $80, $A8, $D0, $F8, $20, $48, $70, $98,  $C0

scr_row_ptr_hi:
//-------------
    !byte $04, $04, $04, $04, $04, $04, $04, $05,  $05, $05, $05, $05, $05, $06, $06, $06
    !byte $06, $06, $06, $06, $07, $07, $07, $07,  $07

;    E.g., taking the same index of each array gets you:
;        scr_row_ptr[0] = $0400
;        scr_row_ptr[1] = $0428
;        scr_row_ptr[2] = $0450
;        scr_row_ptr[3] = $0478
;        scr_row_ptr[4] = $04A0
;        scr_row_ptr[5] = $04C8
;        scr_row_ptr[6] = $04F0
;        scr_row_ptr[7] = $0518
;        scr_row_ptr[8] = $0540
;        scr_row_ptr[9] = $0568
;        scr_row_ptr[10] = $0590
;        scr_row_ptr[11] = $05B8
;        scr_row_ptr[12] = $05E0
;        scr_row_ptr[13] = $0608
;        scr_row_ptr[14] = $0630
;        scr_row_ptr[15] = $0658
;        scr_row_ptr[16] = $0680
;        scr_row_ptr[17] = $06A8
;        scr_row_ptr[18] = $06D0
;        scr_row_ptr[19] = $06F8
;        scr_row_ptr[20] = $0720
;        scr_row_ptr[21] = $0748
;        scr_row_ptr[22] = $0770
;        scr_row_ptr[23] = $0798
;        scr_row_ptr[24] = $07C0

ship_type_widths:  ; (used by ADC at $e091 and compared against #$a0 = 160)
    !byte $18, $18, $10
;   - dec: 24, 24, 16
;     [0] = 24 (width of freighter)
;     [1] = 24 (width of cruiser)
;     [2] = 16 (width of pt-boat)

unknown_data:
    !byte $00, $0A

map_gap_from_existing_ship_to_new_ship:  ; (used by lda at $e181)
    !byte $20, $46, $68, $20, $24, $58, $20, $24,  $30
;   - groups of 3 (relating to ship-type of existing ship closest to spawn edge)
;   - i.e., map[3][3], where:
;     - 1st idx is existing_ship_type
;     - 2nd idx is newly_spawned_ship_type
;   - The rough gist is, if the existing nearest ship is slow, and the new ship is faster, then we'll need a bigger gap?
;     - [0] = 20 46 68  (if existing ship was a freighter, use this group)
;         - #$20 (32) = gap needed if newly spawned ship is a freighter and nearest existing ship is freighter
;         - #$46 (70) = gap needed if newly spawned ship is a cruiser and nearest existing ship is freighter
;                         - since cruiser is slightly faster than freighter, we need a slightly bigger gap
;         - #$68 (104) = gap needed if newly spawned ship is a pt-boat and nearest existing ship is freighter
;                         - since pt-boat is much faster than freighter, we need an even bigger gap
;     - [1] = 20 24 58  (if existing ship was a cruiser, use this group)
;         - #$20 (32) = gap needed if newly spawned ship is a freighter and nearest existing ship is a cruiser
;         - #$24 (36) = gap needed if newly spawned ship is a cruiser and nearest existing ship is a cruiser
;         - #$58 (88) = gap needed if newly spawned ship is a pt-boat and nearest existing ship is a cruiser
;     - [2] = 20 24 30  (if existing ship was a pt-boat, use this group)
;         - #$20 (32) = gap needed if newly spawned ship is a freighter and nearest existing ship is a pt-boat
;         - #$24 (36) = gap needed if newly spawned ship is a cruiser and nearest existing ship is a pt-boat
;         - #$30 (48) = gap needed if newly spawned ship is a pt-boat and nearest existing ship is a pt-boat

ships_movement_delay:
    !byte $02, $01, $00
;   - [0] = 02 (move freighter along every 3 frames - slow)
;   - [1] = 01 (move cruiser along every 2 frames - faster)
;   - [2] = 00 (move pt-boat along every 1 frame - fastest)

ship_scores:
    !byte $02, $05, $0A
    ; Freighter = 200 points
    ;   Cruiser = 500 points
    ; P.T. boat = 1000 points

possible_buoy_y_positions:
    !byte $60, $80

;     $60 = 96
;     $80 = 128

screen_offsets_for_each_missile_indicator:
// (in the indicator group of 4 per player)
    !byte $2F, $07, $2A, $02

;     $2F = 47
;     $07 = 7
;     $2A = 42
;     $02 = 2

missile_char_offsets:
// as each missile is drawn with custom-chars in a 2x2 group, these relative screen offsets
// can quickly refer to each char offset of the 2x2 group
    !byte $00, $28, $01, $29
;   - $00 = 0
;   - $28 = 40
;   - $01 = 1
;   - $29 = 41

v1_ptboat_beep_beep_freq_array:
    !byte $00, $00, $E8, $4E, $00, $00, $00, $00,  $00, $00, $E8, $4E
;   - [0] = $0000
;   - [1] = $4EE8
;   - [2] = $0000
;   - [3] = $0000
;   - [4] = $0000
;   - [5] = $4EE8


or_bitfields:
    !byte $01, $02, $04, $08, $10, $20, $40, $80
;    - $01 = %0000 0001
;    - $02 = %0000 0010
;    - $04 = %0000 0100
;    - $08 = %0000 1000
;    - $10 = %0001 0000
;    - $20 = %0010 0000
;    - $40 = %0100 0000
;    - $80 = %1000 0000

and_bitfields:
    !byte $FE, $FD, $FB, $F7, $EF, $DF, $BF, $7F
;    - $FE = %1111 1110
;    - $FD = %1111 1101
;    - $FB = %1111 1011
;    - $F7 = %1111 0111
;    - $EF = %1110 1111
;    - $DF = %1101 1111
;    - $BF = %1011 1111
;    - $7F = %0111 1111


submarine_charset1:
    !byte $00, $00, $00, $3F, $FF, $FF, $3F, $00,  $01, $07, $07, $FF, $FF, $FF, $FF, $00
    !byte $80, $E0, $E0, $FF, $FF, $FF, $FF, $00,  $00, $00, $00, $FC, $FF, $FF, $FC, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+--------+--------+--------+
; |        |       *|*       |        |        |
; |        |     ***|***     |        |        |
; |        |     ***|***     |        |        |
; |  ******|********|********|******  |        |
; |********|********|********|********|        |
; |********|********|********|********|        |
; |  ******|********|********|******  |        |
; |        |        |        |        |        |
; +--------+--------+--------+--------+--------+

submarine_charset2:
    !byte                                          $00, $00, $00, $0F, $3F, $3F, $0F, $00
    !byte $00, $01, $01, $FF, $FF, $FF, $FF, $00,  $60, $F8, $F8, $FF, $FF, $FF, $FF, $00
    !byte $00, $00, $00, $FF, $FF, $FF, $FF, $00,  $00, $00, $00, $00, $C0, $C0, $00, $00
; +--------+--------+--------+--------+--------+
; |        |        | **     |        |        |
; |        |       *|*****   |        |        |
; |        |       *|*****   |        |        |
; |    ****|********|********|********|        |
; |  ******|********|********|********|**      |
; |  ******|********|********|********|**      |
; |    ****|********|********|********|        |
; |        |        |        |        |        |
; +--------+--------+--------+--------+--------+

submarine_charset3:
    !byte $00, $00, $00, $03, $0F, $0F, $03, $00,  $00, $00, $00, $FF, $FF, $FF, $FF, $00
    !byte $18, $7E, $7E, $FF, $FF, $FF, $FF, $00,  $00, $00, $00, $FF, $FF, $FF, $FF, $00
    !byte $00, $00, $00, $C0, $F0, $F0, $C0, $00  
; +--------+--------+--------+--------+--------+
; |        |        |   **   |        |        |
; |        |        | ****** |        |        |
; |        |        | ****** |        |        |
; |      **|********|********|********|**      |
; |    ****|********|********|********|****    |
; |    ****|********|********|********|****    |
; |      **|********|********|********|**      |
; |        |        |        |        |        |
; +--------+--------+--------+--------+--------+

submarine_charset4:
    !byte                                          $00, $00, $00, $00, $03, $03, $00, $00
    !byte $00, $00, $00, $FF, $FF, $FF, $FF, $00,  $06, $1F, $1F, $FF, $FF, $FF, $FF, $00
    !byte $00, $80, $80, $FF, $FF, $FF, $FF, $00,  $00, $00, $00, $F0, $FC, $FC, $F0, $00
; +--------+--------+--------+--------+--------+
; |        |        |     ** |        |        |
; |        |        |   *****|*       |        |
; |        |        |   *****|*       |        |
; |        |********|********|********|****    |
; |      **|********|********|********|******  |
; |      **|********|********|********|******  |
; |        |********|********|********|****    |
; |        |        |        |        |        |
; +--------+--------+--------+--------+--------+

submarine_charset_idx:
// choose between submarine_charset1/2/3/4
    !byte $00, $28, $50, $78

// small_missile_char_data_start  = EEEC
// medium_missile_char_data_start = EF2C 
// big_missile_char_data_start    = EF6C
// These are #$40 apart

small_missile_char_data_x_offset0:
    !byte $00, $00, $40, $E0, $E0, $E0, $E0, $40,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |        |        |
; |        |        |
; | *      |        |
; |***     |        |
; |***     |        |
; |***     |        |
; |***     |        |
; | *      |        |
; +--------+--------+

small_missile_char_data_x_offset2:
    !byte $00, $00, $10, $38, $38, $38, $38, $10,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |        |        |
; |        |        |
; |   *    |        |
; |  ***   |        |
; |  ***   |        |
; |  ***   |        |
; |  ***   |        |
; |   *    |        |
; +--------+--------+

small_missile_char_data_x_offset4:
    !byte $00, $00, $04, $0E, $0E, $0E, $0E, $04,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |        |        |
; |        |        |
; |     *  |        |
; |    *** |        |
; |    *** |        |
; |    *** |        |
; |    *** |        |
; |     *  |        |
; +--------+--------+

small_missile_char_data_x_offset6:
    !byte $00, $00, $01, $03, $03, $03, $03, $01,  $00, $00, $00, $80, $80, $80, $80, $00
; +--------+--------+
; |        |        |
; |        |        |
; |       *|        |
; |      **|*       |
; |      **|*       |
; |      **|*       |
; |      **|*       |
; |       *|        |
; +--------+--------+

medium_missile_char_data_x_offset0:
    !byte $60, $60, $F0, $F0, $F0, $F0, $F0, $60,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; | **     |        |
; | **     |        |
; |****    |        |
; |****    |        |
; |****    |        |
; |****    |        |
; |****    |        |
; | **     |        |
; +--------+--------+

medium_missile_char_data_x_offset2:
    !byte $18, $18, $3C, $3C, $3C, $3C, $3C, $18,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |   **   |        |
; |   **   |        |
; |  ****  |        |
; |  ****  |        |
; |  ****  |        |
; |  ****  |        |
; |  ****  |        |
; |   **   |        |
; +--------+--------+

medium_missile_char_data_x_offset4:
    !byte $06, $06, $0F, $0F, $0F, $0F, $0F, $06,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |     ** |        |
; |     ** |        |
; |    ****|        |
; |    ****|        |
; |    ****|        |
; |    ****|        |
; |    ****|        |
; |     ** |        |
; +--------+--------+

medium_missile_char_data_x_offset6:
    !byte $01, $01, $03, $03, $03, $03, $03, $01,  $80, $80, $C0, $C0, $C0, $C0, $C0, $80
; +--------+--------+
; |       *|*       |
; |       *|*       |
; |      **|**      |
; |      **|**      |
; |      **|**      |
; |      **|**      |
; |      **|**      |
; |       *|*       |
; +--------+--------+

big_missile_char_data_x_offset0:
    !byte $30, $78, $FC, $FC, $FC, $FC, $FC, $78,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |  **    |        |
; | ****   |        |
; |******  |        |
; |******  |        |
; |******  |        |
; |******  |        |
; |******  |        |
; | ****   |        |
; +--------+--------+

big_missile_char_data_x_offset2:
    !byte $0C, $1E, $3F, $3F, $3F, $3F, $3F, $1E,  $00, $00, $00, $00, $00, $00, $00, $00
; +--------+--------+
; |    **  |        |
; |   **** |        |
; |  ******|        |
; |  ******|        |
; |  ******|        |
; |  ******|        |
; |  ******|        |
; |   **** |        |
; +--------+--------+

big_missile_char_data_x_offset4:
    !byte $03, $07, $0F, $0F, $0F, $0F, $0F, $07,  $00, $80, $C0, $C0, $C0, $C0, $C0, $80
; +--------+--------+
; |      **|        |
; |     ***|*       |
; |    ****|**      |
; |    ****|**      |
; |    ****|**      |
; |    ****|**      |
; |    ****|**      |
; |     ***|*       |
; +--------+--------+

big_missile_char_data_x_offset6:
    !byte $00, $01, $03, $03, $03, $03, $03, $01,  $C0, $E0, $F0, $F0, $F0, $F0, $F0, $E0
; +--------+--------+
; |        |**      |
; |       *|***     |
; |      **|****    |
; |      **|****    |
; |      **|****    |
; |      **|****    |
; |      **|****    |
; |       *|***     |
; +--------+--------+


missiles_colour_table:
    !byte $07, $07, $07, $07, $08, $08, $08, $08
;   - a choice between yellow or light brown, with index from 0-7
;   - player1's 4 missiles will all be yellow
;   - player2's 4 missiles will all be light brown

map_2x2_ypos_to_chardata_offset_for_missile_size:
// the offset into the missile char data to reference either small (#$00), medium (#$40) or big (#$80) missiles
    !byte $00, $00, $00, $00, $00, $40, $40, $40,  $80, $80, $80, $80

missile_speed_at_indexed_2x2_ypos:
// At the lower part of the screen, the missile moves faster, #$02 = 2 pixels per frame
// At the mid and upper parts of the screen, the missile moves slower, #$01 = 1 pixel per frame
// the #$03 speed seems unused
    !byte $01, $01, $01, $01, $01, $01, $02, $02,  $02, $02, $03, $03

mission_text1:
    !byte $3F, $35, $3B, $38, $26, $33, $2F, $39,  $39, $2F, $35, $34, $26, $2F, $39, $26
    //       Y  O  U  R     M  I  S   S  I  O  N     I  S  
    !byte $3A, $35, $26, $2A, $2B, $39, $3A, $38,  $35, $3F, $26, $27, $39, $26, $33, $27
    //       T  O     D  E  S  T  R   O  Y     A  S     M  A
    !byte $34, $3F, $00
    //       N  Y

mission_text2:
    !byte $2B, $34, $2B, $33, $3F, $26, $39, $2E,  $2F, $36, $39, $26, $27, $39, $26, $36
    //       E  N  E  M  Y     S  H   I  P  S     A  S     P
    !byte $35, $39, $39, $2F, $28, $32, $2B, $26,  $28, $2B, $2C, $35, $38, $2B, $26, $3A
    //       O  S  S  I  B  L  E      B  E  F  O  R  E     T
    !byte $2F, $33, $2B, $26, $38, $3B, $34, $39,  $00
    //       I  M  E     R  U  N  S

mission_text3:
    !byte $35, $3B, $3A, $41, $26, $2C, $2F, $38,  $2B, $26, $3A, $35, $38, $36, $2B, $2A
    //       O  U  T  .     F  I  R   E     T  O  R  P  E  D
    !byte $35, $2B, $39, $26, $28, $3F, $26, $36,  $38, $2B, $39, $39, $2F, $34, $2D, $26
    //       O  E  S     B  Y     P   R  E  S  S  I  N  G  
    !byte $3A, $2E, $2B, $00
    //       T  H  E

mission_text4:
    !byte $28, $3B, $3A, $3A, $35, $34, $26, $35,  $34, $26, $3A, $2E, $2B, $26, $36, $27
    //       B  U  T  T  O  N     O   N     T  H  E     P  A
    !byte $2A, $2A, $32, $2B, $41, $26, $2F, $3A,  $26, $3A, $27, $31, $2B, $39, $26, $49
    //       D  D  L  E  .     I  T      T  A  K  E  S     3
    !byte $26, $39, $2B, $29, $35, $34, $2A, $39,  $00
    //          S  E  C  O  N  D  S

mission_text5:
    !byte $2C, $35, $38, $26, $2B, $27, $29, $2E,  $26, $3A, $35, $38, $36, $2B, $2A, $35
    //       F  O  R     E  A  C  H      T  O  R  P  E  D  O
    !byte $26, $32, $35, $27, $2A, $41, $00
    //          L  O  A  D  .

mission_text6:
    !byte $26, $00
    //      <emptyline>

mission_text7:
    !byte $FF, $26, $26, $26, $26, $26, $26, $26,  $26, $26, $43, $26, $26, $2C, $38, $2B
    // <yellow>                              -        F  R  E
    !byte $2F, $2D, $2E, $3A, $2B, $38, $42, $26,  $26, $48, $46, $46, $26, $36, $35, $2F
    //        I  G  H  T  E  R  :         2  0  0     P  O  I
    !byte $34, $3A, $39, $00
    //        N  T  S

mission_text8:
    !byte $FB, $26, $26, $26, $26, $26, $26, $26,  $26, $26, $43, $26, $26, $29, $38, $3B
    //  <cyan>                              -        C  R  U
    !byte $2F, $39, $2B, $38, $26, $26, $42, $26,  $26, $4B, $46, $46, $26, $36, $35, $2F
    //       I  S  E  R        :         5  0  0     P  O  I
    !byte $34, $3A, $39, $00
    //       N  T  S

mission_text9:
    !byte $FD, $26, $26, $26, $26, $26, $26, $26,  $26, $26, $43, $26, $26, $36, $41, $3A
    // <green>                              -        P  .  T
    !byte $41, $26, $28, $35, $27, $3A, $42, $26,  $47, $46, $46, $46, $26, $36, $35, $2F
    //       .     B  O  A  T  :      1  0  0  0     P  O  I
    !byte $34, $3A, $39, $00, $00  ; NOTE: Two null terminators indicate end of all intro text lines
    //       N  T  S

no_idea_yet:
    !byte $FF, $FF, $FF, $FF, $FF

read_paddle_position:
--------------------
    TAX  ; X = player index (0=player1, 1=player2)
    SEC
    LDA  #$C8  ; dec200
    SBC  $D419,X  ; adc paddle1 pos ($d419) or paddle2 pos ($d41a)
    BCS  skip_if_paddle_in_valid_range  ; $F0FB  ; branch if subtraction didn't cause a borrow (i.e. if paddle pos didn't surpass #$c8 / 200)
    LDA  #$00  ; if paddle-pos surpassed #$c8/200, then we set it to #$00
skip_if_paddle_in_valid_range:
    STA  genvarB  ; $08  ; otherwise paddle is set to be #$C8 minus paddle-pos
                      ; I.e., keep in the range of 0 to 200
    LSR  ; A=0 to 100
    CLC
    ADC  genvarB  ; $08  A = 1.5 * genvarB (range: 0 to 300)
    ROR  ; A = 0.75 * genvarB  (range: 0 to 150?)
         ; I wonder about carry-flag being on sometimes and going to bit7
         ; Aah, this logic is fine, the carry-bit becomes like a 'high byte',
         ; and the ROR pushes the bit0 of this high byte into our low byte reg A.
    LDY  #$00
    STY  genvarB  ; $08
    LDY  #$03
// Seems like prior x-pos of the player's submarine is added to the current paddle pos three times
// So the carry bits accumulate in genvarB. So genvarB is like the 'high byte' of this addition.
// Later, when the two ror's occur, it's like a division by 4, which brings it all back to the 8-bit range.
;
; I sense this is a smoothing filter, to prevent too much jitter on the paddles, by putting a heavier weighting
; on the prior xpos (x3) and smaller weighter on the newer xpos (x1), then divide by 4 to average it out.
;
; NOTE: I think the 0-150 range for sub movement relates to how the submarine_charset1/2/3/4 move the sub by increments of
; 2 pixels (not one). So the units of this amount aren't pixels by units of 2-pixels (or pixel pairs, if you prefer)
loop_next_add_of_prior_xpos:
    CLC
    ADC  filtered_player_xpos,x  ; $FE,X  ; let's assume filtered_player_xpos is initialised to zero, nothing gets added
    BCC  skip_carry_increment  ; $F10F     ; for this assumed initial case, we'll branch)
    INC  genvarB  ; $08  ; genvarB will contain how many times a carry happened (how many times the adc passed 255)
skip_carry_increment:
    DEY
    BNE  loop_next_add_of_prior_xpos  ; $F108
; So A = 3 x (old xpos) + new paddle xpos (in 2-pixel units)
    ROR  genvarB  ; $08
    ROR
    ROR  genvarB  ; $08
    ROR  ; shift A right twice (/4), and in bits7-6, place the genvarB count of how many carries occurred
         ; this
    SEC
    SBC  #$02   ; A=(0to150 range) - 2 = (-2 to 148 range)
    BCS  skip_floor_xpos_to_zero  ; $F11F  ; branch if sbc didn't cause borrow (A-2 was >= 0)
; I suppose it could only get here if genvarB was 0 (i.e., that count of carries in the y-loop was zero)
    LDA  #$00  ; so if no carries occurred, store a value of #$00
               ; i.e., assure range is 0 to 148
skip_floor_xpos_to_zero:
    STA  filtered_player_xpos,x  ; $FE,X  ; This stores the smoothed/filtered x-pos of the player's sub in 0-148 range
    RTS

some_unknown_data:
// doesn't appear to be used anywhere
    !byte $FF, $FF, $FF

set_sprite_colour:
//----------------
    LDA  $F12C,X
    STA  $D027,X
    RTS

sprite_colours:
    !byte $03, $0B, $0D
;     [0] = 03 = cyan
;     [1] = 0B = dark grey
;     [2] = 0D = light green
 
void_data:
// fill $f12f-$fb7f with $ff
  !fill $fb80-*,$ff

sprite_data:
// NOTE: I was a bit puzzled as to how the program as able to see these sprites
// at address $3B80 and onwards. (I couldn't find any code that copied it there!)
//
// It finally made sense after I read an explanation here:
// - http://www.floodgap.com/retrobits/ckb/secret/ultimax.html
//
// > The VIC-II, however, sees all 64K in its usual 16K clumps, with ROM banked
// > into the upper 4K of its current "slice" (meaning $F000-$FFFF of the
// > cartridge ROM actually "appears" at $3000-$3FFF in the default VIC addressing
// > space as well).'
//
// NOTE2: As I was using a cracked version of this game for the disassembly, I
// noticed that its decrunching routine appeared to indeed copy the sprites down
// to this lower $3B80 region. I.e., perhaps the cracked game didn't rely on this
// "ultimax" mode of behaviour? I might be able to assess this later by checking
// what the /LORAM, /HIRAM, /GAME and /EXROM lines were set to...
//
// Taking a look at memory location $01, it is set to $E5 (%1110 0101)
//   bit0 = /LORAM = 1
//   bit1 = /HIRAM = 0
//   bit2 = /CHAREN = 1
//   bit3 = Cassette Data Output Line = 0
//   bit4 = Cassette Switch Sense = 0 (Switch open)
//   bit5 = Cassette Motor Control = 1 (Motor off)
//   bit7-6 = 1 (undefined)
//
// The /GAME and /EXROM lines can only be set via a cartridge
// (pins 8 and 9, respectively)
//
// This memory mapping mode is described in the manual as:
// 
// > This map provides 60K bytes of RAM and I/O devices.
// > The user must write his own I/O driver routines.
//
// This $E5 value may have been placed in $01 via either the
// 'cold_start_handler' routine, or possibly the decrunching routine?
//
// NOTE3: Ah, the earlier-mentioned web paged elaborated on the reasons the
// decruncher did this:
// - http://www.floodgap.com/retrobits/ckb/secret/ultimax.html
//
// > This is the only mode where the VIC-II can access external memory (i.e., 
// > memory outside of its default 16K slice), engineered to allow the cartridge's
// > sprite and character data to be visible to the VIC-II without copying it and
// > wasting what little RAM is present -- particularly important since the Ultimax
// > has no built-in character set! (However, because of the processor's
// > restrictions it would be very stupid for software to attempt to use memory
// > higher than $1000.) Because of this complex little internal hackery, you must
// > also copy $F000-$FFFF to $3000-$3FFF before running an Ultimax cartridge dump
// > or the game will have scrambled graphics.

    !byte $49, $00, $00, $10, $80, $00, $00, $00,  $00, $00, $C0, $00, $00, $CC, $00, $18
    !byte $CC, $00, $18, $CC, $00, $18, $CE, $00,  $D8, $FE, $07, $F9, $BB, $3F, $BF, $EE
    !byte $FF, $EB, $FF, $FE, $FF, $FF, $FE, $7F,  $FF, $FC, $7F, $FF, $F8, $3F, $FF, $F0
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// | *  *  *                |
// |   *    *               |
// |                        |
// |        **              |
// |        **  **          |
// |   **   **  **          |
// |   **   **  **          |
// |   **   **  ***         |
// |** **   *******      ***|
// |*****  ** *** **  ******|
// |* ********* *** ********|
// |*** * ***************** |
// |*********************** |
// | *********************  |
// | ********************   |
// |  ******************    |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $01, $40, $00, $22, $00, $00, $08
    !byte $60, $00, $00, $60, $00, $03, $60, $00,  $03, $7C, $00, $03, $6E, $1E, $03, $7A
    !byte $08, $E7, $FF, $1F, $FF, $FF, $FE, $FF,  $FF, $FC, $7F, $FF, $F8, $3F, $FF, $F0
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                        |
// |                        |
// |                        |
// |       * *              |
// |  *   *                 |
// |    *    **             |
// |         **             |
// |      ** **             |
// |      ** *****          |
// |      ** ** ***    **** |
// |      ** **** *     *   |
// |***  ***********   *****|
// |*********************** |
// |**********************  |
// | ********************   |
// |  ******************    |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $01, $00, $00, $01, $80, $00, $01, $E0
    !byte $00, $03, $50, $00, $33, $FF, $00, $3F,  $FE, $00, $1F, $FC, $00, $1F, $F8, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |       *                |
// |       **               |
// |       ****             |
// |      ** * *            |
// |  **  **********        |
// |  *************         |
// |   ***********          |
// |   **********           |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $0C, $00, $00, $13, $38
    !byte $00, $26, $64, $00, $6B, $E0, $00, $7D,  $CE, $00, $D9, $E3, $00, $F7, $77, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |    **                  |
// |   *  **  ***           |
// |  *  **  **  *          |
// | ** * *****             |
// | ***** ***  ***         |
// |** **  ****   **        |
// |**** *** *** ***        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $00, $00, $92, $00, $01, $08, $00, $00,  $00, $00, $03, $00, $00, $33, $00, $00
    !byte $33, $18, $00, $33, $18, $00, $73, $18,  $E0, $7F, $1B, $FC, $DD, $9F, $FF, $77
    !byte $FD, $7F, $FF, $D7, $7F, $FF, $FF, $3F,  $FF, $FE, $1F, $FF, $FE, $0F, $FF, $FC
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                *  *  * |
// |               *    *   |
// |                        |
// |              **        |
// |          **  **        |
// |          **  **   **   |
// |          **  **   **   |
// |         ***  **   **   |
// |***      *******   ** **|
// |******  ** *** **  *****|
// |******** *** ********* *|
// | ***************** * ***|
// | ***********************|
// |  ********************* |
// |   ******************** |
// |    ******************  |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $02, $80, $00, $00, $44, $00
    !byte $06, $10, $00, $06, $00, $00, $06, $C0,  $00, $3E, $C0, $78, $76, $C0, $10, $5E
    !byte $C0, $F8, $FF, $E7, $7F, $FF, $FF, $3F,  $FF, $FF, $1F, $FF, $FE, $0F, $FF, $FC
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                        |
// |                        |
// |                        |
// |              * *       |
// |                 *   *  |
// |             **    *    |
// |             **         |
// |             ** **      |
// |          ***** **      |
// | ****    *** ** **      |
// |   *     * **** **      |
// |*****   ***********  ***|
// | ***********************|
// |  **********************|
// |   ******************** |
// |    ******************  |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $80, $00, $01, $80, $00, $07
    !byte $80, $00, $0A, $C0, $00, $FF, $CC, $00,  $7F, $FC, $00, $3F, $F8, $00, $1F, $F8
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                *       |
// |               **       |
// |             ****       |
// |            * * **      |
// |        **********  **  |
// |         *************  |
// |          ***********   |
// |           **********   |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $34, $1E, $00, $5A, $33, $00, $C5, $5D,  $00, $9F, $22, $00, $22, $56, $00, $41
    !byte $59, $00, $1D, $60, $00, $32, $CE, $00,  $47, $D1, $00, $0D, $FC, $00, $13, $EA
    !byte $00, $26, $E5, $00, $4F, $B0, $00, $17,  $F8, $00, $2F, $D4, $00, $DD, $DF, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |  ** *     ****         |
// | * ** *   **  **        |
// |**   * * * *** *        |
// |*  *****  *   *         |
// |  *   *  * * **         |
// | *     * * **  *        |
// |   *** * **             |
// |  **  * **  ***         |
// | *   ***** *   *        |
// |    ** *******          |
// |   *  ***** * *         |
// |  *  ** ***  * *        |
// | *  ***** **            |
// |   * ********           |
// |  * ****** * *          |
// |** *** *** *****        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $13, $48, $D8, $26, $02, $8C, $71, $9B,  $86, $64, $C5, $B6, $35, $63, $04, $FB
    !byte $87, $3B, $6C, $6E, $66, $33, $A9, $EC,  $19, $A2, $18, $0C, $E7, $30, $07, $99
    !byte $E0, $03, $18, $C0, $07, $99, $E0, $0C,  $DB, $30, $18, $7E, $18, $30, $3C, $0C
    !byte $7F, $FF, $FE, $EE, $E7, $77, $EE, $E7,  $77, $EE, $E7, $77, $7F, $FF, $FE, $20
// +------------------------+
// |   *  ** *  *   ** **   |
// |  *  **       * *   **  |
// | ***   **  ** ***    ** |
// | **  *  **   * ** ** ** |
// |  ** * * **   **     *  |
// |***** ***    ***  *** **|
// | ** **   ** ***  **  ** |
// |  **  *** * *  **** **  |
// |   **  ** *   *    **   |
// |    **  ***  ***  **    |
// |     ****  **  ****     |
// |      **   **   **      |
// |     ****  **  ****     |
// |    **  ** ** **  **    |
// |   **    ******    **   |
// |  **      ****      **  |
// | ********************** |
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// | ********************** |
// +------------------------+

    !byte $21, $48, $C4, $46, $02, $82, $D1, $10,  $81, $A0, $05, $37, $90, $03, $05, $E0
    !byte $00, $3B, $6C, $42, $22, $73, $A1, $CC,  $D9, $A2, $08, $48, $E5, $30, $87, $99
    !byte $E8, $63, $18, $C2, $03, $98, $1E, $48,  $DB, $30, $08, $76, $08, $30, $30, $0C
    !byte $43, $9E, $0E, $C2, $E2, $45, $E0, $67,  $45, $8E, $A4, $77, $57, $FC, $FE, $20
// +------------------------+
// |  *    * *  *   **   *  |
// | *   **       * *     * |
// |** *   *   *    *      *|
// |* *          * *  ** ***|
// |*  *          **     * *|
// |***               *** **|
// | ** **   *    *   *   * |
// | ***  *** *    ***  **  |
// |** **  ** *   *     *   |
// | *  *   ***  * *  **    |
// |*    ****  **  **** *   |
// | **   **   **   **    * |
// |      ***  **      **** |
// | *  *   ** ** **  **    |
// |    *    *** **     *   |
// |  **      **        **  |
// | *    ***  ****     *** |
// |**    * ***   *  *   * *|
// |***      **  *** *   * *|
// |*   *** * *  *   *** ***|
// | * * *********  ******* |
// +------------------------+

    !byte $1B, $5B, $C8, $06, $02, $80, $51, $10,  $86, $20, $05, $36, $50, $00, $05, $E0
    !byte $00, $3B, $6C, $00, $22, $72, $00, $40,  $D8, $00, $0C, $40, $00, $01, $84, $00
    !byte $2B, $62, $00, $03, $80, $00, $1E, $48,  $12, $31, $08, $02, $09, $30, $30, $0C
    !byte $C3, $9E, $0E, $4A, $E0, $45, $60, $6E,  $45, $0E, $94, $11, $1D, $25, $58, $20
// +------------------------+
// |   ** ** * ** ****  *   |
// |     **       * *       |
// | * *   *   *    *    ** |
// |  *          * *  ** ** |
// | * *                 * *|
// |***               *** **|
// | ** **            *   * |
// | ***  *          *      |
// |** **               **  |
// | *                     *|
// |*    *            * * **|
// | **   *               **|
// |*                  **** |
// | *  *      *  *   **   *|
// |    *         *     *  *|
// |  **      **        **  |
// |**    ***  ****     *** |
// | *  * * ***      *   * *|
// | **      ** ***  *   * *|
// |    *** *  * *     *   *|
// |   *** *  *  * * * **   |
// +------------------------+

    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $07, $C0, $00,  $1F, $F8, $00, $2F, $FC, $00, $57, $AF
    !byte $00, $46, $E3, $00, $8F, $F1, $80, $9D,  $F8, $80, $2F, $D5, $00, $DD, $DF, $80
    !byte $00, $00, $00, $00, $00, $00, $00, $00,  $00, $00, $00, $00, $00, $00, $00, $12
// +------------------------+
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// |     *****              |
// |   **********           |
// |  * **********          |
// | * * **** * ****        |
// | *   ** ***   **        |
// |*   ********   **       |
// |*  *** ******   *       |
// |  * ****** * * *        |
// |** *** *** ******       |
// |                        |
// |                        |
// |                        |
// |                        |
// |                        |
// +------------------------+

    !byte $03, $FF, $C0, $04, $42, $20, $05, $5E,  $A0, $04, $46, $A0, $05, $5E, $20, $C3
    !byte $FF, $C3, $60, $7E, $06, $30, $3C, $0C,  $18, $7E, $18, $0C, $DB, $30, $07, $99
    !byte $E0, $03, $18, $C0, $07, $99, $E0, $0C,  $DB, $30, $18, $7E, $18, $30, $3C, $0C
    !byte $7F, $FF, $FE, $EE, $E7, $77, $EE, $E7,  $77, $EE, $E7, $77, $7F, $FF, $FE, $20
// +------------------------+
// |      ************      |
// |     *   *    *   *     |
// |     * * * **** * *     |
// |     *   *   ** * *     |
// |     * * * ****   *     |
// |**    ************    **|
// | **      ******      ** |
// |  **      ****      **  |
// |   **    ******    **   |
// |    **  ** ** **  **    |
// |     ****  **  ****     |
// |      **   **   **      |
// |     ****  **  ****     |
// |    **  ** ** **  **    |
// |   **    ******    **   |
// |  **      ****      **  |
// | ********************** |
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// |*** *** ***  *** *** ***|
// | ********************** |
// +------------------------+

// LOCATION: FEC0
void_data2:
// fill $fec0-$fff9 with $ff
  !fill $fffa-*,$ff

irq_pointers:
    !byte $04, $E9, $F5, $EB, $04, $E9
;   - [0] = $E904 : interrupt_routine (NMI handler)
;   - [1] = $EBF5 : cold_start_handler (Cold start handler)
;   - [2] = $E904 : interrupt_routine (IRQ and BRK handler)

// in vim, type: nnoremap <F5>  :make seawolf.prg<CR>

} // end !pseudopc $E000
