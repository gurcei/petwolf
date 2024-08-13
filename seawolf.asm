// ====================
// SEA WOLF DISASSEMBLY
// ====================

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
//- in bullet_redraw_and_ship_assessment:
//  - sta at $e4b0  ; (set it to #$08) 
//  - dec at #e4be (index for loop_back_to_next_row loop)
//
offset_to_char_idx_of_2x2_missile_chars = $0f  // offset to char index of 2x2 missile chars
//
//- bullet_redraw_and_ship_assessment:
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
whatis3 = $2b 
  // - sta at $e955 (set to #$03)
whatis4 = $2c 
  // - lda at $e97f
whatis5 = $2d 
//
//- lda at $e967
//- dec at $e96b (only if whatis5 is not yet zero)
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

//- PURPOSE2: within 'bullet_redraw_and_ship_assessment:'
//  - prepares the bullet chars needed for each player's missile custom char-based soft-sprites
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

// * = $0801

// TODO: BASIC Stub here

// TODO2: Add assembly routine to:
//  - switch off kernal rom
//  - copy chunk of code below to $E000

//--------------------------------

* = $E000

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
    BIT  $01A9
skip_to_lda_1:
      LDA  #$01
    BIT  $02A9
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
    BIT  $FFA9
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
    BIT  $00A9
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
    BIT  $44E9
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
    BIT  $44E9
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
$E35F               B5 31    LDA  p1_num_missiles,x  ; $31,X
$E361               48       PHA
$E362               8A       TXA
$E363               D0 03    BNE  +still_have_missiles  ; $E368
$E365               A9 01    LDA  #$01
$E367               2C A9 1A BIT  $1AA9
  +still_have_missiles:
  $E368               A9 1A    LDA  #$1A  ; dec26
$E36A               85 13    STA  txt_x_pos  ; $13
$E36C               A9 17    LDA  #$17  ; dec23
$E36E               85 14    STA  txt_y_pos  ; $14
$E370               20 C0 E6 JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
$E373               A9 26    LDA  #$26  ; ' ' space character
$E375               A0 00    LDY  #$00
-retry2:
$E377               A2 0D    LDX  #$0D  ; 13
-retry_clear_loop:
$E379               91 02    STA  ($02),Y   ; draw 13 spaces in the missile area, starting at either (1,23) for no missiles,
                                            ; or (26,23) for have missiles.
$E37B               C8       INY
$E37C               CA       DEX
$E37D               D0 FA    BNE  -retry_clear_loop  ; $E379
$E37F               C0 28    CPY  #$28  ; dec40
$E381               B0 04    BCS  +cleared_2nd_missile_line  ; $E387  ; branch if y >= 40 (upon clearing 2nd line of missiles?)
$E383               A0 28    LDY  #$28  ; dec40
$E385               D0 F0    BNE  -retry2  ; $E377
+cleared_2nd_missile_line:
$E387               68       PLA  ; retrieve number of missiles for currently assessed player again
$E388               F0 19    BEQ  +skip_due_to_no_missiles_left  ; $E3A3  ; branch if player has no more missiles
$E38A               AA       TAX
$E38B               CA       DEX  ; decrease number of player missiles by one
-loop_to_draw_prior_torpedo_in_group:
$E38C               A9 50    LDA  #$50  ; #$50 = start of torpedo char
$E38E               A0 04    LDY  #$04
$E390               84 08    STY  genvarB  ; $08
$E392               BC 24 EE LDY  screen_offsets_for_each_missile_indicator,x  ; $EE24,X
-loop_to_draw_next_torpedo_char:
$E395               91 02    STA  (scr_ptr_lo),y   ; ($02),Y
$E397               C8       INY
$E398               18       CLC
$E399               69 01    ADC  #$01  ; increment to next torpedo char (e.g., #$50, #$51, #$52, #$53)
$E39B               C6 08    DEC  genvarB  ; $08
$E39D               D0 F6    BNE  -loop_to_draw_next_torpedo_char  ; $E395
$E39F               CA       DEX  ; decrease x to point to prior torpedo in group (aiming to redraw it on screen next)
$E3A0               10 EA    BPL  -loop_to_draw_prior_torpedo_in_group  ; $E38C
$E3A2               60       RTS
+skip_due_to_no_missiles_left:
$E3A3               A2 16    LDX  #$16  ; dec22
$E3A5               A0 32    LDY  #$32  ; dec50
-loop_for_dex:
$E3A7               BD B7 E3 LDA  time_to_load_msg,x  ; $E3B7,X
$E3AA               91 02    STA  scr_ptr_lo,y  ; ($02),Y
$E3AC               88       DEY
$E3AD               C0 28    CPY  #$28  ; dec40
$E3AF               D0 02    BNE  +skip_if_y_not_40  ; $E3B3
$E3B1               A0 0C    LDY  #$0C  ; dec12
+skip_if_y_not_40:
$E3B3               CA       DEX
$E3B4               10 F1    BPL  -loop_for_dex  ; $E3A7
$E3B6               60       RTS


time_to_load_msg:
 :000E3B7 3A 2F 33 2B 26 3A 35 26  32 35 27 2A 42 49 26 39  | :/3+&:5&25'*BI&9
           T  I  M  E     T  O      L  O  A  D  :  3     S
 :000E3C7 2B 29 35 34 2A 39 41                               | +)54*9
           E  C  O  N  D  S  .


redraw_player_submarines:
//-----------------------
$E3CE               A9 01    LDA  #$01  ; player index (0=player1, 1=player2)
$E3D0               85 23    STA  iterator_local  ; $23
-big_loopback:
$E3D2               A6 23    LDX  iterator_local  ; $23
$E3D4               8A       TXA
$E3D5               18       CLC
$E3D6               69 15    ADC  #$15  ; dec21  ; this is row containing either:
                                                 ;    player1 sub (row21) - yellow
                                                 ; or player2 sub (row22) - light brown
$E3D8               85 14    STA  txt_y_pos  ; $14
$E3DA               A9 00    LDA  #$00
$E3DC               85 13    STA  txt_x_pos  ; $13
$E3DE               20 C0 E6 JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
$E3E1               A4 16    LDY  real_game_mode_flag  ; $16
$E3E3               D0 20    BNE  +skip_if_in_real_game_mode  ; $E405
// if we're in attract mode, move paddles around automatically?
$E3E5               B5 35    LDA  players_xpos,x  ; $35,X
$E3E7               85 09    STA  genvarA  ; $09  ; hold x-pos of current player
$E3E9               D5 37    CMP  attract_mode_player_xpos_waypoint,x  ; $37,X
$E3EB               D0 0C    BNE  +still_travelling_to_xpos_waypoint  ; $E3F9
// if we get here, the attract mode paddle movement has reached the current waypoint,
// so it's time to pick a new waypoint to automatically travel towards
-retry_if_randnum_greater_or_equal_147:
$E3ED               20 93 E8 JSR  random_num_gen_into_A  ; $E893
$E3F0               C9 93    CMP  #$93  ; dec147
$E3F2               B0 F9    BCS  -retry_if_randnum_greater_or_equal_147  ; $E3ED ; branch if >= 147
$E3F4               95 37    STA  attract_mode_player_xpos_waypoint,x  ; $37,X
$E3F6               4C 00 E4 JMP  +jump_ahead  ; $E400
+still_travelling_to_xpos_waypoint:
$E3F9               B0 03    BCS  +skip_to_dec  ; $E3FE  ; if current player x-pos >= waypoint, then branch (for decrement)
// otherwise player x-pos is less than waypoint (and we need to increment)
$E3FB               E6 09    INC  genvarA  ; $09  ; move paddle automatically to right
$E3FD               2C C6 09 BIT  $09C6
  +skip_to_dec:
  $E3FE               C6 09    DEC  genvarA ; $09  ; move paddle automatically to left
+jump_ahead:
$E400               A5 09    LDA  genvarA  ; $09
$E402               4C 0C E4 JMP  +jump_ahead2  ; $E40C
+skip_if_in_real_game_mode:
$E405               A5 23    LDA  iterator_local  ; $23
$E407               20 F0 F0 JSR  read_paddle_position  ; $F0F0
$E40A               85 09    STA  genvarA  ; $09
+jump_ahead2:
$E40C               A6 23    LDX  iterator_local  ; $23
$E40E               B5 35    LDA  players_xpos,x  ; $35,X  ; some player1/2 detail (maybe player submarine x-pos x 4)
$E410               4A       LSR
$E411               4A       LSR
$E412               A8       TAY
$E413               A2 05    LDX  #$05
$E415               A9 26    LDA  #$26  ; ' ' space char
-loop1:
$E417               91 02    STA  ($02),Y  ; wipe away existing player submarine chars with spaces (submarine is 5 chars wide)
$E419               C8       INY
$E41A               CA       DEX
$E41B               D0 FA    BNE  -loop1  ; $E417
$E41D               A5 09    LDA  genvarA  ; $09
$E41F               29 03    AND  #$03
$E421               AA       TAX
$E422               BC E8 EE LDY  submarine_charset_idx,x  ; $EEE8,X  ; choose between submarine_charset1/2/3/4
$E425               A5 23    LDA  iterator_local  ; $23  ; player 1 or 2 index (0=player1, 1=player2)
$E427               D0 03    BNE  +jump_if_player2  ; $E42C
$E429               A2 00    LDX  #$00  ; relative index for vic-bank0 chars describing current player1 submarine
                                        ; (absolute char idx range 55-59)
$E42B               2C A2 28 BIT  $28A2
  +jump_if_player2:
  $E42C               A2 28    LDX  #$28  ; dec40  ; relative index for vic-bank0 chars describing current player2 submarine
$E42E               A9 28    LDA  #$28  ; dec40  ; index of loop from 40 to 0, in order to copy across 5 chars to define player's sub)
$E430               85 08    STA  genvarB  ; $08
-loopy:
$E432               B9 48 EE LDA  submarine_charset1,y  ; $EE48,Y
$E435               9D A8 02 STA  vicbank0_sub_chars_for_player1,x  ; $02A8,X
$E438               E8       INX
$E439               C8       INY
$E43A               C6 08    DEC  genvarB  ; $08
$E43C               D0 F4    BNE  -loopy ; $E432
$E43E               A6 23    LDX  iterator_local  ; $23
$E440               A5 09    LDA  genvarA  ; $09
$E442               95 35    STA  players_xpos,x  ; $35,X  ; some player1/2 detail
$E444               4A       LSR
$E445               4A       LSR
$E446               A8       TAY
$E447               BD 5D E4 LDA  sub_start_chars,x  ; $E45D,X  ; where x=0 is player1, x=1 is player2
$E44A               A2 05    LDX  #$05  ; player submarine sprite consists of 5 chars
-loopy2:
$E44C               91 02    STA  ($02),Y
$E44E               18       CLC
$E44F               69 01    ADC  #$01
$E451               C8       INY
$E452               CA       DEX
$E453               D0 F7    BNE  -loopy2  ; $E44C
$E455               C6 23    DEC  iterator_local  ; $23
$E457               30 03    BMI  +skip_to_end  ; $E45C
$E459               4C D2 E3 JMP  -big_loopback  ; $E3D2
+skip_to_end:
$E45C               60       RTS


sub_start_chars:
 :000E45D 55 5A                                             | UZ

    55 = start char of 1st variation of submarine chars (maybe intended for player1)
    5A = start char of 2nd variation of submarine chars (though both variations look quite similar)
            (maybe intended for player2, possibly to give it a unique look?)


bullet_redraw_and_ship_assessment:
//--------------------------------
$E45F               A9 07    LDA  #$07  ; iterator over all possible missiles (7-4 are for player2, 3-0 are for player1)
$E461               85 23    STA  iterator_local  ; $23
-jumbo_loopback:
$E463               A6 23    LDX  iterator_local  ; $23  ; missile iterator
$E465               B5 75    LDA  torpedo_fire_ypos,x  ; $75,X  ; y-position of all torpedoes
$E467               D0 03    BNE  +torpedo_ypos_is_nonzero  ; $E46C
$E469               4C 2E E5 JMP  +jump_to_near_end  ; $E52E
+torpedo_ypos_is_nonzero:
$E46C               48       PHA  ; A=ypos of current torpedo (can be in range of dec0 to dec160)
$E46D               4A       LSR
$E46E               4A       LSR
$E46F               4A       LSR
$E470               4A       LSR  ; divide by 16 (decide which 2x2 block y-pos this torpedo will reside in?)
$E471               A8       TAY  ; y-pos index of 2x2 block this torpedo/missile resides in
                                  ; (range of dec0 to dec10)
$E472               68       PLA  ; A=pure pixel ypos of current torpedo
$E473               38       SEC
$E474               F9 C0 EF SBC  missile_speed_at_indexed_2x2_ypos,y  ; $EFC0,Y
                                  ; At the lower part of the screen, the missile moves faster, #$02 = 2 pixels per frame
                                  ; At the mid and upper parts of the screen, the missile moves slower, #$01 = 1 pixel per frame
                                  ; the #$03 speed seems unused
$E477               85 08    STA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
$E479               8A       TXA  ; index to the current missile/torpedo being assessed in loop
$E47A               0A       ASL
$E47B               0A       ASL  ; multiply by 4  ; so now p1_missile4 = #$00, p1_missile3 = #$04
                                                   ;        p1_missile2 = #$08, p1_missile1 = #$0c
                                                   ;        p2_missile4 = #$10, p2_missile3 = #$14
                                                   ;        p2_missile2 = #$18, p2_missile1 = #$1c
$E47C               85 0F    STA  offset_to_char_idx_of_2x2_missile_chars  ; $0F  ; offset to char index of 2x2 missile chars
$E47E               0A       ASL
$E47F               0A       ASL
$E480               0A       ASL  ; multiply by 8  ; so now p1_missile4 = #$00, p1_missile3 = #$20
                                                   ;        p1_missile2 = #$40, p1_missile1 = #$60
                                                   ;        p2_missile4 = #$80, p2_missile3 = #$a0
                                                   ;        p2_missile2 = #$c0, p2_missile1 = #$e0
$E481               85 10    STA  offset_to_char_data_addr_of_2x2_missile_chars  ; $10
$E483               BD AC EF LDA  missiles_colour_table,x  ; $EFAC,X  ; a choice between yellow or light brown over idx0 to 7
$E486               85 2E    STA  curr_missile_colour  ; $2E
$E488               A0 1F    LDY  #$1F  ; dec31  ; index to char-data for curr missile (4 chars = 32 bytes)
$E48A               A9 00    LDA  #$00
-loop_to_wipe_array:
$E48C               99 85 00 STA  genarrayA,y  ; $0085,Y  ; reset entire genarrayA[32] to zeroes
                                  ; NOTE: genarrayA aims to house the new 2x2 char representation the current missile
$E48F               88       DEY
$E490               10 FA    BPL  -loop_to_wipe_array  ; $E48C
$E492               A5 08    LDA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
$E494               4A       LSR
$E495               4A       LSR
$E496               4A       LSR
$E497               4A       LSR  ; divide by 16  ; will be in range dec0 to dec10
$E498               A8       TAY
$E499               B9 B4 EF LDA  map_2x2_ypos_to_chardata_offset_for_missile_size,y  ; $EFB4,Y  ; has values like #$00, #$40 and #$80 (over index0 to 11)
                             ; this appears to be the offset into the missile-char-data to choose between:
                             ; small(#$00), medium(#$40) or big(#$80) missiles (depending on which 2x2 char ypos missile is at)
$E49C               85 09    STA  genvarA  ; $09 ; stores the missile-char-data offset for small/medium/big missiles
$E49E               B5 6D    LDA  torpedo_fire_xpos,x  ; $6D,X  ; x-position of all torpedoes
$E4A0               29 03    AND  #$03  ; xpos modulus to range 0-3
                             ; I'm suspecting missile xpos are in two-pixel (pixel-pair) units too.
                             ; So the MOD4 may have intended to see at which x-offset within the first char the missile is drawn
$E4A2               0A       ASL
$E4A3               0A       ASL
$E4A4               0A       ASL
$E4A5               0A       ASL ; multiply by 16  ; can be either #$00, #$10, #$20 or #$30
$E4A6               05 09    ORA  genvarA  ; $09  ; could be value of either #$00 or #$40 or #$80
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
$E4A8               A8       TAY  ; used as index in small_missile_char_data_x_offset0 later
$E4A9               A5 08    LDA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
$E4AB               29 07    AND  #$07
                             ; The MOD8 may have intended to see at which y-offset within first char the missile is drawn
                             ; (I think this is in pixel units, and not in pixel-pair units)
$E4AD               AA       TAX
$E4AE               A9 08    LDA  #$08
$E4B0               85 0E    STA  missile_chardata_row_iterator  ; $0E
-loop_back_to_next_row:
                             ; Y = offset to desired missile_char_data (which factors in what x-offset we want to draw at)
                             ; X = which y-offset we want to start drawing into 2x2 char block of genarrayA)
$E4B2               B9 EC EE LDA  small_missile_char_data_x_offset0,y  ; $EEEC,Y  ; y-range = 0 to 7
$E4B5               95 85    STA  genarrayA,x  ; $85,X
$E4B7               B9 F4 EE LDA  small_missile_char_data_x_offset0+8,y  ; $EEF4,Y  ; y-range = 0 to 7
$E4BA               95 95    STA  genarrayA+16,x  ; $95,X
$E4BC               E8       INX
$E4BD               C8       INY
$E4BE               C6 0E    DEC  missile_chardata_row_iterator  ; $0E
$E4C0               D0 F0    BNE  -loop_back_to_next_row  ; $E4B2
$E4C2               A6 23    LDX  iterator_local  ; $23  ; missile iterator ; ought to be an index from 0 to 7
$E4C4               B5 6D    LDA  torpedo_fire_xpos,x  ; $6D,X
$E4C6               85 11    STA  xpos_local  ; $11  ; x-pos of current torpedo/missile
$E4C8               B5 75    LDA  torpedo_fire_ypos,x  ; $75,X
$E4CA               85 12    STA  ypos_local  ; $12  ; y-pos of current torpedo/missile
$E4CC               20 B1 E6 JSR  set_scr_and_clr_ptr_locations_based_on_ship_xy_pos  ; $E6B1
$E4CF               A2 03    LDX  #$03
; wipe out prior chars of this missile from the screen
-retry_next_char_of_2x2_char_missile:
$E4D1               BC 28 EE LDY  missile_char_offsets,x  ; $EE28,X
$E4D4               B1 02    LDA  (scr_ptr_lo),y  ; ($02),Y  ; read the char at this screen location
$E4D6               C9 60    CMP  #$60  ; first bullet char in group
$E4D8               90 04    BCC  +less_than_range_of_bullet_chars  ; $E4DE
$E4DA               A9 26    LDA  #$26  ; ' ' space char
$E4DC               91 02    STA  (scr_ptr_lo),y  ; ($02),Y  ; draw ' ' space char over prior bullet
+less_than_range_of_bullet_chars:
$E4DE               CA       DEX
$E4DF               10 F0    BPL  -retry_next_char_of_2x2_char_missile  ; $E4D1
; check if missile reached top of screen (time to make it invisible?)
$E4E1               A6 23    LDX  iterator_local  ; $23  (missile iterator)
$E4E3               A5 08    LDA  genvarB  ; $08  ; the next missile ypos (after decrementing missile speed value)
$E4E5               C9 10    CMP  #$10  ; dec16
$E4E7               90 3F    BCC  +reset_missile_ypos_to_zero  ; $E528  ; branch if less than 16
$E4E9               B4 7D    LDY  torpedo_fire_state,x  ; $7D,X
$E4EB               D0 3B    BNE  +reset_missile_ypos_to_zero  ; $E528  ; branch if this torpedo is not currently visible on screen
$E4ED               95 75    STA  torpedo_fire_ypos,x  ; $75,X  ; y-pos of all torpedoes
$E4EF               85 12    STA  ypos_local  ; $12  ; y-pos of current ship
$E4F1               20 B1 E6 JSR  set_scr_and_clr_ptr_locations_based_on_ship_xy_pos  ; $E6B1
$E4F4               A4 10    LDY  offset_to_char_data_addr_of_2x2_missile_chars  ; $10
$E4F6               A2 00    LDX  #$00
-loopback4:
$E4F8               B5 85    LDA  genarrayA,x  ; $85,X
$E4FA               99 00 03 STA  vicbank0_missile_chars_for_player1,y  ; $0300,Y
$E4FD               C8       INY
$E4FE               E8       INX
$E4FF               E0 20    CPX  #$20  ; 32
$E501               D0 F5    BNE  -loopback4  ; $E4F8
$E503               A5 0F    LDA  offset_to_char_idx_of_2x2_missile_chars  ; $0F
$E505               18       CLC
$E506               69 63    ADC  #$63  ; dec99  ; start at the last char-idx for this 2x2 missile soft-sprite (e.g., #$63 to #$60)
$E508               85 09    STA  genvarA  ; $09  ; could it relate to current paddle position?
$E50A               A2 03    LDX  #$03
-big_loop1:
$E50C               BC 28 EE LDY  missile_char_offsets,x  ; $EE28,X
$E50F               B1 02    LDA  (scr_ptr_lo),y  ; ($02),Y
$E511               C9 26    CMP  #$26  ; is it a ' ' space char?
$E513               F0 04    BEQ  +branch_if_space_char  ; $E519
$E515               C9 60    CMP  #$60  ; #$60 = first shot char in group

$E517               90 08    BCC  +branch_if_less_than_shot_char  ; $E521
+branch_if_space_char:
$E519               A5 09    LDA  genvarA  ; $09
$E51B               91 02    STA  (scr_ptr_lo),y  ; ($02),Y
$E51D               A5 2E    LDA  curr_missile_colour  ; $2E  ; some colour choice between yellow or light-brown
$E51F               91 04    STA  (clr_ptr_lo),y  ; ($04),Y
+branch_if_less_than_shot_char:
$E521               C6 09    DEC  genvarA  ; $09
$E523               CA       DEX
$E524               10 E6    BPL  -big_loop1  ; $E50C
$E526               30 06    BMI  +jump_to_near_end  ; $E52E
+reset_missile_ypos_to_zero:
$E528               A6 23    LDX  iterator_local  ; $23
$E52A               A9 00    LDA  #$00
$E52C               95 75    STA  torpedo_fire_ypos,x  ; $75,X  ; y-pos of all torpedoes
+jump_to_near_end:
$E52E               C6 23    DEC  iterator_local  ; $23
$E530               30 03    BMI  +skip_to_end  ; $E535
$E532               4C 63 E4 JMP  -jumbo_loopback  ; $E463
+skip_to_end:
$E535               60       RTS


paddle_and_function_key_reading_routine:
//--------------------------------------
$E536               A9 00    LDA  #$00
$E538               20 83 E7 JSR  read_paddle_fire_button  ; $E783
$E53B               AA       TAX
$E53C               D0 0D    BNE  paddle_fire_or_F1_pressed  ; $E54B  ; jump if paddle fire pressed (A = FF)
$E53E               A9 FE    LDA  #$FE
$E540               8D 00 DC STA  $DC00
$E543               AD 01 DC LDA  $DC01
$E546               AA       TAX
$E547               29 10    AND  #$10  ; Check if F1 is pressed
$E549               D0 04    BNE  no_paddle_fire_or_F1  ; $E54F ; Jump if not pressed
paddle_fire_or_F1_pressed:
$E54B               A9 01    LDA  #$01
$E54D               D0 13    BNE  finish_off_routine  ; $E562  ; will always jump (as A is non-zero)
no_paddle_fire_or_F1:
$E54F               8A       TXA
$E550               29 20    AND  #$20  ; Check if F3 is pressed
$E552               D0 04    BNE  no_F3_pressed  ; $E558  ; Jump if not pressed
$E554               A9 03    LDA  #$03
$E556               D0 0A    BNE  finish_off_routine  ; $E562
no_F3_pressed:
$E558               8A       TXA
$E559               29 40    AND  #$40  ; Check if F5 is pressed
$E55B               D0 03    BNE  $E560  ; Jump if not pressed
$E55D               A9 05    LDA  #$05
$E55F               2C A9 00 BIT  $00A9
  $E560               A9 00    LDA  #$00
finish_off_routine:
$E562               A2 7F    LDX  #$7F
$E564               8E 00 DC STX  $DC00
$E567               60       RTS
                                      ; If F1 or paddle-fire was pressed, A = 1
                                      ; If F3 was pressed, A = 3
                                      ; If F5 was pressed, A = 5
                                      ; else A = 0


parent_routine_that_does_key_paddle_input:
//----------------------------------------
$E568               20 59 E7 JSR  timer_loop  ; $E759
$E56B               20 36 E5 JSR  paddle_and_function_key_reading_routine  ; $E536
$E56E               AA       TAX
$E56F               D0 F7    BNE  parent_routine_that_does_key_paddle_input  ; $E568
                             ; jump if any paddle-fire or func-key press (perhaps waiting for prior press to unpress)
$E571               20 59 E7 JSR  timer_loop  ; $E759
$E574               E6 1B    INC  $1B
$E576               20 36 E5 JSR  paddle_and_function_key_reading_routine  ; $E536
$E579               AA       TAX
$E57A               F0 F5    BEQ  $E571  ; jump if no paddle-fire or func-key press
$E57C               60       RTS


prepare_game_screen:
//------------------
$E57D               20 99 E7 JSR  init_game_screen  ; $E799
$E580               A2 27    LDX  #$27  ; (39)
-loop1:
$E582               A9 07    LDA  #$07
$E584               9D 48 DB STA  $DB48,X  (row 21 colour ram all set to 7 / yellow) - player 1 submarine row
$E587               A9 08    LDA  #$08     (row 22 colour ram all set to 8 / light brown?) - player 2 submarine row
$E589               9D 70 DB STA  $DB70,X
$E58C               A9 00    LDA  #$00
$E58E               9D 00 D8 STA  $D800,X  (row 0 colour ram all set to 0 / black)
$E591               9D 28 D8 STA  $D828,X  (row 1 colour ram all set to 0 / black)
$E594               CA       DEX
$E595               10 EB    BPL  -loop1  ; $E582
$E597               A2 0D    LDX  #$0D    ; (13)
-loop2:
$E599               A9 07    LDA  #$07      ; 7 = yellow
$E59B               9D 99 DB STA  $DB99,X   ; (row 23 - from col 1 to 8)
$E59E               9D C1 DB STA  $DBC1,X   ; (row 24 - from col 1 to 8)
$E5A1               A9 08    LDA  #$08      ; 8 = light brown
$E5A3               9D B2 DB STA  $DBB2,X   ; (row 23 - from col 26 to 33)
$E5A6               9D DA DB STA  $DBDA,X   ; (row 24 - from col 26 to 33)
$E5A9               CA       DEX
$E5AA               10 ED    BPL  -loop2  ; $E599
$E5AC               A9 17    LDA  #$17  ; dec23
$E5AE               85 14    STA  ypos_local  ; $14  (curr. ship y-pos?)
$E5B0               20 39 E8 JSR  draw_inline_text  ; $E839

 :000E5B3 3A 2F 33 2B 26 32 2B 2C  3A 00 
           T  I  M  E     L  E  F   T

$E5BD               20 73 E8 JSR  print_remaining_game_time  ; $E873
$E5C0               A2 00    LDX  #$00
$E5C2               20 5F E3 JSR  redraw_torpedo_amount_indicator  ; $E35F
$E5C5               A2 01    LDX  #$01
$E5C7               20 5F E3 JSR  redraw_torpedo_amount_indicator  ; $E35F
$E5CA               4C F3 E8 JMP  allow_interrupts  ; $E8F3
midway_in_preparing_game_screen:
$E5CD               20 F5 E8 JSR  interrupt_precursor  ; $E8F5
$E5D0               20 99 E7 JSR  init_game_screen  ; $E799
$E5D3               A2 4F    LDX  #$4F  ; dec79
$E5D5               A9 01    LDA  #$01
$E5D7               9D 00 D8 STA  $D800,X  ; set first 2 lines to be white text?
$E5DA               CA       DEX
$E5DB               10 FA    BPL  $E5D7
$E5DD               A9 18    LDA  #$18  ; dec24
$E5DF               85 14    STA  txt_y_pos  ; $14
$E5E1               20 39 E8 JSR  draw_inline_text  ; $E839

 :777E5E4 44 29 45 26 47 4F 4E 48  26 28 27 32 32 3F 43 33  | D)E&GONH&('22?C3
           (  C  )     1  9  8  2      B  A  L  L  Y  -  M
 :777E5F4 2F 2A 3D 27 3F 26 44 29  45 26 47 4F 4E 48 26 29  | /*='?&D)E&GONH&)
           I  D  W  A  Y     (  C   )     1  9  8  2     C
 :777E604 35 33 33 35 2A 35 38 2B  00 
           O  M  M  O  D  O  R  E   

$E60D               A2 04    LDX  #$04
-loopback_title_sprites:
$E60F               BD A4 E6 LDA  title_sprites_xpos,x  ; $E6A4,X
$E612               9D 00 D0 STA  $D000,X  ; set xpos for sprite 2 (#$ff/255), 1 (#$e2/226) and then 0 (#$c5/197)
$E615               BD A9 E6 LDA  title_sprites_ypos,x  ; $E6A9,X
$E618               9D 01 D0 STA  $D001,X  ; set ypos for sprite 2 (#$c2/194), 1 (#$b2/178) and then 0 (#$a2/162)
$E61B               CA       DEX
$E61C               CA       DEX
$E61D               10 F0    BPL  -loopback_title_sprites  ; $E60F
$E61F               A9 00    LDA  #$00
$E621               8D 10 D0 STA  $D010  ; sprites 0-7 xpos msb
$E624               A9 07    LDA  #$07   ; %0000 0111
$E626               8D 15 D0 STA  $D015  ; sprite display enable (only 1st 3 sprites visible)
$E629               A9 CC    LDA  #>mission_text1  ; #$CC
$E62B               85 06    STA  ret_ptr_lo  ; $06
$E62D               A9 EF    LDA  #<mission_text1  ; #$EF
$E62F               85 07    STA  ret_ptr_hi  ; $07  ; note: no valid assembly exists at $EFCC
$E631               A9 03    LDA  #$03
$E633               85 14    STA  txt_y_pos  ; $14

-loop1:
$E635               A0 00    LDY  #$00
$E637               B1 06    LDA  (ret_ptr_lo),y  ; ($06),Y  ; pointer to inline-text-string
$E639               F0 12    BEQ  +skip1 ; $E64D  ; found string null-terminator? then branch
$E63B               4C 6A E6 JMP  +big_jump  ; $E66A
write_line_routine:
$E63E               20 EC E7 JSR  draw_text_to_screen  ; $E7EC
$E641               E6 14    INC  ypos_local  ; $14
$E643               E6 14    INC  ypos_local  ; $14
$E645               E6 06    INC  ret_ptr_lo  ; $06
$E647               D0 EC    BNE  -loop1  ; $E635
$E649               E6 07    INC  ret_ptr_hi  ; $07
$E64B               D0 E8    BNE  -loop1  ; $E635
+skip1:
$E64D               A9 02    LDA  #$02
$E64F               85 08    STA  genvarB  ; $08
-loopback_wait_longer_on_title_screen:
$E651               A0 78    LDY  #$78
-loopback_wait_on_title_screen:
$E653               20 36 E5 JSR  paddle_and_function_key_reading_routine  ; $E536
$E656               C9 01    CMP  #$01
$E658               F0 0D    BEQ  exit_from_title_screen_due_to_paddle_fire  ; $E667
$E65A               20 59 E7 JSR  timer_loop  ; $E759
$E65D               88       DEY
$E65E               D0 F3    BNE  loopback_wait_on_title_screen  ; $E653
$E660               C6 08    DEC  genvarB  ; $08
$E662               D0 ED    BNE  loopback_wait_longer_on_title_screen  ; $E651
$E664               A9 00    LDA  #$00
$E666               2C A9 FF BIT  $FFA9
  -exit_from_title_screen_due_to_paddle_fire:
  $E667               A9 FF    LDA  #$FF
$E669               60       RTS

+big_jump:
$E66A               A2 02    LDX  #$02
$E66C               A0 F4    LDY  #$F4  ; sprite frame for pt-boat reversed
-loopback_ship_sprite_colours:
$E66E               98       TYA
$E66F               9D F8 07 STA  $07F8,X  ; set sprite frame for sprite 2
$E672               88       DEY
$E673               BD AE E6 LDA  ship_sprite_colours,x  ; $E6AE,X
$E676               9D 27 D0 STA  $D027,X  ; set colours of sprites 0, 1 and 2
$E679               CA       DEX
$E67A               10 F2    BPL  loopback_ship_sprite_colours  ; $E66E
$E67C               A9 1D    LDA  #$1D  ; dec29
$E67E               85 08    STA  genvarB  ; $08

loopy1:
$E680               A2 04    LDX  #$04
loopy2:
$E682               BD 00 D0 LDA  $D000,X  ; $d004/$d002/$d000 = sprite2/1/0 x-pos, 
$E685               C9 38    CMP  #$38  ; dec56
$E687               F0 03    BEQ  skip_ship_move  ; $E68C
$E689               DE 00 D0 DEC  $D000,X  ; glide ships to left on title screen
skip_ship_move:
$E68C               CA       DEX
$E68D               CA       DEX
$E68E               10 F2    BPL  loopy2  ; $E682
$E690               20 59 E7 JSR  timer_loop  ; $E759
$E693               20 59 E7 JSR  timer_loop  ; $E759
$E696               20 36 E5 JSR  paddle_and_function_key_reading_routine  ; $E536
$E699               C9 01    CMP  #$01
$E69B               F0 CA    BEQ  exit_from_title_screen_due_to_paddle_fire  ; $E667
$E69D               C6 08    DEC  genvarB  ; $08
$E69F               D0 DF    BNE  loopy1  ; $E680
$E6A1               4C 3E E6 JMP  write_line_routine  ; $E63E

title_sprites_xpos:
 :000E6A4 C5 00 E2 00 FF

title_sprites_ypos:
 :000E6A9 A2 00 B2 00 C2

ship_sprite_colours:
 :000E6AE 07 03 05                                          | ...
  - 07 = Yellow (freighter)
  - 03 = Cyan (cruiser)
  - 05 = Green (pt-boat)

set_scr_and_clr_ptr_locations_based_on_ship_xy_pos:
//-------------------------------------------------
$E6B1               48       PHA
$E6B2               A5 11    LDA  xpos_local  ; $11  ; x-pos of current ship
$E6B4               4A       LSR
$E6B5               4A       LSR  ; divide by 4
$E6B6               85 13    STA  txt_x_pos  ; $13
$E6B8               A5 12    LDA  ypos_local  ; $12  ; y-pos of current ship
$E6BA               4A       LSR
$E6BB               4A       LSR
$E6BC               4A       LSR  ; divide by 8
$E6BD               85 14    STA  txt_y_pos  ; $14
$E6BF               24 48    BIT  ships_xpos+3  ; $48

adjust_scr_and_clr_ptr_locations:
//-------------------------------
  $E6C0               48       PHA  ; preserve A on stack
  ; (if falling through from prior function, the BIT will skip this line)
$E6C1               8A       TXA
$E6C2               48       PHA  ; preserve X on stack
$E6C3               A6 14    LDX  $14
$E6C5               BD DC ED LDA  scr_ptr_low,X  ; $EDDC,X
$E6C8               18       CLC
$E6C9               65 13    ADC  $13
$E6CB               85 02    STA  scr_ptr_lo  ; $02
$E6CD               85 04    STA  clr_ptr_lo  ; $04
$E6CF               A0 00    LDY  #$00
$E6D1               BD F5 ED LDA  scr_row_ptr_hi,x  ; $EDF5,X
$E6D4               69 00    ADC  #$00
$E6D6               85 03    STA  scr_ptr_hi  ; $03
$E6D8               69 D4    ADC  #$D4
$E6DA               85 05    STA  clr_ptr_hi  ; $05
$E6DC               68       PLA
$E6DD               AA       TAX  ; restore X from stack
$E6DE               68       PLA  ; restore A from stack
$E6DF               60       RTS

add_points_to_score_then_update_high_score_and_reprint:
//-----------------------------------------------------
$E6E0               A4 16    LDY  real_game_mode_flag  ; $16  ; was set to #$ff in start_game
$E6E2               D0 01    BNE  +skip_if_in_real_game_mode  ; $E6E5
// if we are in attract mode, bail out early (we won't add anything to the score)
$E6E4               60       RTS
+skip_if_in_real_game_mode:
$E6E5               F8       SED
$E6E6               18       CLC
$E6E7               75 1D    ADC  p1_score_lo,x  ; $1D,X
$E6E9               95 1D    STA  p1_score_lo,x  ; $1D,X
$E6EB               B5 1F    LDA  p1_score_hi,x  ; $1F,X
$E6ED               69 00    ADC  #$00
$E6EF               95 1F    STA  p1_score_hi,x ; $1F,X
$E6F1               A5 21    LDA  high_score_lo  ; $21
$E6F3               38       SEC
$E6F4               F5 1D    SBC  p1_score_lo,x  ; $1D,X
$E6F6               A5 22    LDA  high_score_hi  ; $22
$E6F8               F5 1F    SBC  p1_score_hi,x  ; $1F,X
$E6FA               B0 08    BCS  +skip_set_high_score  ; $E704  ; branch if we didn't beat high score
set_high_score:
$E6FC               B5 1D    LDA  p1_score_lo,x  ; $1D,X
$E6FE               85 21    STA  high_score_lo  ; $21
$E700               B5 1F    LDA  p1_score_hi,x  ; $1F,X
$E702               85 22    STA  high_score_hi  ; $22
+skip_set_high_score:
$E704               D8       CLD


print_all_scores:
//---------------
$E705               A9 01    LDA  #$01
$E707               85 14    STA  txt_y_pos  ; $14
$E709               85 13    STA  txt_x_pos  ; $13
$E70B               20 C0 E6 JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0

print_player1_score:
$E70E               A0 02    LDY  #$02  ; the x-location to start drawing digits from
$E710               A5 1D    LDA  p1_score_lo  ; $1D
$E712               A6 1F    LDX  p1_score_hi  ; $1F
$E714               20 26 E7 JSR  print_two_digits_in_X_and_two_digits_in_A_and_two_trailing_zeroes  ; $E726

print_high_score:
$E717               A0 10    LDY  #$10
$E719               A5 21    LDA  high_score_lo  ; $21
$E71B               A6 22    LDX  high_score_hi  ; $22
$E71D               20 26 E7 JSR  print_two_digits_in_X_and_two_digits_in_A_and_two_trailing_zeroes  ; $E726

print_player2_score:
$E720               A0 1E    LDY  #$1E  ; (30) the x-location to start drawing digits from
$E722               A5 1E    LDA  p2_score_lo  ; var6  ; $1E
$E724               A6 20    LDX  p2_score_hi  ; var8  ; $20


print_two_digits_in_X_and_two_digits_in_A_and_two_trailing_zeroes:
//----------------------------------------------------------------
$E726               20 31 E7 JSR  print_two_digits_in_X_and_two_digits_in_A  ; $E731
$E729               A9 46    LDA  #$46  ; #$46 = '0' char
$E72B               91 02    STA  ($02),Y
$E72D               C8       INY
$E72E               91 02    STA  ($02),Y  ; Is this to put two trailing '0' chars at the end of the score?
$E730               60       RTS


print_two_digits_in_X_and_two_digits_in_A:
---------------------
$E731               48       PHA
$E732               A9 00    LDA  #$00
$E734               85 08    STA  genvarB  ; $08
$E736               8A       TXA
$E737               20 3B E7 JSR  print_two_digits_in_A  ; $E73B
$E73A               68       PLA


print_two_digits_in_A:
---------------------
$E73B               48       PHA
$E73C               4A       LSR
$E73D               4A       LSR
$E73E               4A       LSR
$E73F               4A       LSR
$E740               20 46 E7 JSR  +inner_jsr  ; $E746  ; print digit in high nibble first
$E743               68       PLA
print_lower_nibble_digit_in_A:
-----------------------------
$E744               29 0F    AND  #$0F  ; then print digit in lower nibble
+inner_jsr:
$E746               D0 08    BNE  +skip1  ; $E750
$E748               A6 08    LDX  genvarB  ; $08
$E74A               D0 04    BNE  +skip1  ; $E750
$E74C               A9 26    LDA  #$26    ; #$26 = ' ' space char in char-map
$E74E               D0 05    BNE  +skip2  ; $E755
+skip1:
$E750               18       CLC
$E751               69 46    ADC  #$46  ; #$46 = '0' char in char-map  (so this could relate to printing score)
$E753               E6 08    INC  $08
+skip2:
$E755               91 02    STA  ($02),Y
$E757               C8       INY
$E758               60       RTS


timer_loop:
//---------
$E759               AD 0E DC LDA  $DC0E  ; CIA Control Register A - bit0 = start(1)/stop(0) timer
$E75C               4A       LSR
$E75D               B0 FA    BCS  timer_loop  ;  $E759
$E75F               EE 0E DC INC  $DC0E  ; after timer has stopped, restart it (turn bit0 back on)
$E762               60       RTS

maybe_unused_function:
//--------------------
// or maybe time waster function?
$E763               EA       NOP
$E764               EA       NOP
$E765               EA       NOP
$E766               EA       NOP
$E767               EA       NOP
$E768               EA       NOP
$E769               EA       NOP
$E76A               EA       NOP
$E76B               EA       NOP
$E76C               EA       NOP
$E76D               EA       NOP
$E76E               EA       NOP
$E76F               EA       NOP
$E770               EA       NOP
$E771               EA       NOP
$E772               EA       NOP
$E773               EA       NOP
$E774               EA       NOP
$E775               EA       NOP
$E776               EA       NOP
$E777               EA       NOP
$E778               EA       NOP
$E779               EA       NOP
$E77A               EA       NOP
$E77B               EA       NOP
$E77C               EA       NOP
$E77D               EA       NOP
$E77E               EA       NOP
$E77F               EA       NOP
$E780               EA       NOP
$E781               EA       NOP
$E782               60       RTS


read_paddle_fire_button:
//----------------------
$E783               AA       TAX  ; a = 0 always, so x = 0
$E784               A9 FF    LDA  #$FF
$E786               8D 00 DC STA  $DC00  ; Data Port A - Write Keyboard Column Values for keyboard scan
                                         ; Setting to #$FF seems to disable the keyboard column scan, so that $DC01 will read its
                                         ; alternate bitfields (and not row values)
$E789               AD 01 DC LDA  $DC01  ; Data Port B - Read Keyboard Row Values for keyboard scan
$E78C               3D 97 E7 AND  $E797,X  ; always pb E797 = #$04  (paddle fire button)
$E78F               D0 03    BNE  $E794  ; if bit3 was 1 (i.e., paddle fire not pressed) then jump
$E791               A9 FF    LDA  #$FF   ; bit3 was 0, so set A = FF to indicate paddle fire was pressed
$E793               2C A9 00 BIT  $00A9
  $E794               A9 00    LDA  #$00
$E796               60       RTS  ; If paddle fire not pressed, return A = 0
                                  ; If paddle fire is pressed, A = FF

 :000E797 04 08   | ..     ; 04 is used by $E797 for paddle 1 fire test
                           ; 08 is used by $E797 for paddle 2 fire test


init_game_screen:
//---------------
$E799               A2 00    LDX  #$00
-loop1:
$E79B               A9 26    LDA  #$26  ; This is the space ' ' char in their charater map
$E79D               9D 00 04 STA  $0400,X  ; clear the screen memory with space ' ' chars
$E7A0               9D 00 05 STA  $0500,X
$E7A3               9D 00 06 STA  $0600,X
$E7A6               9D E8 06 STA  $06E8,X
$E7A9               A9 01    LDA  #$01
$E7AB               9D 00 D8 STA  $D800,X  ; set colour memory to all 1 (white) value
$E7AE               9D 00 D9 STA  $D900,X
$E7B1               9D 00 DA STA  $DA00,X
$E7B4               9D E8 DA STA  $DAE8,X
$E7B7               CA       DEX
$E7B8               D0 E1    BNE  -loop1  ; $E79B
$E7BA               86 14    STX  $14
$E7BC               20 39 E8 JSR  draw_inline_text  ; $E839
 :000E7BF F8 26 26 36 32 27 3F 2B  38 26 47 26 26 26 26 26  | .&&62'?+8&G&&&&&
                    P  L  A  Y  E   R     1               
 :000E7CF 2E 2F 2D 2E 26 39 29 35  38 2B 26 26 26 26 26 36  | ./-.&9)58+&&&&&6
           H  I  G  H     S  C  O   R  E                 P
 :000E7DF 32 27 3F 2B 38 26 48 26  26 00 4C 05 E7 A9 00 85  | 2'?+8&H&&.L.....
           L  A  Y  E  R     2        
$E7E9               4C 05 E7 JMP  print_all_scores  ; $E705


draw_text_to_screen:
//------------------
$E7EC               A9 00    LDA  #$00
$E7EE               85 13    STA  txt_x_pos  ; $13
$E7F0               20 C0 E6 JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
$E7F3               A9 01    LDA  #$01  ; The current colour to draw the text in (defaults to white)
$E7F5               48       PHA        ; this var is pushed onto the stack
$E7F6               A0 00    LDY  #$00
$E7F8               84 13    STY  $13
-loop1:
$E7FA               B1 06    LDA  (ret_ptr_lo),y  ; ($06),Y  ; ptr to inline text
$E7FC               F0 09    BEQ  +end_of_string  ; $E807  ; if null-ptr / end-of-string, then branch
$E7FE               C9 F8    CMP  #$F8
$E800               90 02    BCC  $E804
$E802               E6 13    INC  $13
$E804               C8       INY
$E805               D0 F3    BNE  -loop1  ; $E7FA  ; branch until y increments back to zero (a max of 255 chars)
+end_of_string:
$E807               88       DEY  ; Y ought to equal the length of the string
$E808               98       TYA  ; A = Y = length of string
$E809               38       SEC
$E80A               E5 13    SBC  $13  ; A = length of string minus the count of special F8 chars
$E80C               4A       LSR       ; A = A / 2
$E80D               85 13    STA  $13  ; Store half the length of the string in $13
$E80F               A9 13    LDA  #$13  ; (19, half the screen width)
$E811               38       SEC
$E812               E5 13    SBC  $13  ; A = (half screen width) - (half string width)
                                       ;   = the x-position to assure string is horizontally centred
$E814               A8       TAY
draw_char_loop:
$E815               A2 00    LDX  #$00
$E817               A1 06    LDA  ($06,X)   ; pw 06 = $EFCD  (x=0, out: a = 35 = 'O')
$E819               F0 1C    BEQ  found_null ; $E837     ; A = null terminator?
$E81B               C9 F8    CMP  #$F8
$E81D               90 09    BCC  valid_char ; $E828   ; branch if A < #$f8
$E81F               29 07    AND  #$07  ; and with %0000 0111
$E821               BA       TSX  ; X = stack pointer low
$E822               E8       INX
$E823               9D 00 01 STA  $0100,X  ; A value of #$01 was pushed the stack earlier at $E7F3.
                                           ; This will reset this stack value to new value of the special string char and $07
$E826               B0 07    BCS  +skip1  ; $E82F  ; I think this always jumps, due to prior CMP#$F8 being true?
valid_char:
$E828               91 02    STA  (scr_ptr_lo),y  ; ($02),Y  ; pw 02 = 0478 , y = 4  (draw A char onto the screen)
$E82A               68       PLA
$E82B               48       PHA  ; aah, the stack var is the current colour to draw the text in
$E82C               91 04    STA  (clr_ptr_lo),y  ; ($04),Y  ; pw 04 = d878
$E82E               C8       INY
+skip1:
$E82F               E6 06    INC  ret_ptr_lo  ; $06  ; pb 06 = CD
$E831               D0 E2    BNE  draw_char_loop  ; $E815
$E833               E6 07    INC  ret_ptr_hi  ; $07  ; pb 07 = EF
$E835               D0 DE    BNE  draw_char_loop ; $E815

found_null:
$E837               68       PLA  ; drop the stack var for current text colour
$E838               60       RTS


draw_inline_text:
//---------------
$E839               68       PLA
$E83A               18       CLC
$E83B               69 01    ADC  #$01
$E83D               85 06    STA  ret_ptr_lo  ; $06
$E83F               68       PLA
$E840               69 00    ADC  #$00
$E842               85 07    STA  ret_ptr_hi  ; $07   ; seems to be pulling the return from jsr address into pw $06
$E844               20 EC E7 JSR  draw_text_to_screen  ; $E7EC

$E847               A5 07    LDA  ret_ptr_hi  ; $07  ; push the modified return location back onto the stack
$E849               48       PHA
$E84A               A5 06    LDA  ret_ptr_lo  ; $06
$E84C               48       PHA
$E84D               60       RTS


update_game_time_left:
//--------------------
$E84E               A5 27    LDA  decimal_secs_in_minutes_left  ; $27
$E850               05 28    ORA  minutes_left  ; $28
$E852               F0 1F    BEQ  print_remaining_game_time  ; $E873
$E854               C6 26    DEC  secs_in_minute_left  ; $26
$E856               10 1B    BPL  print_remaining_game_time  ; $E873
$E858               A9 3B    LDA  #$3B  ; dec59  ; (reset seconds in minute countdown?)
$E85A               85 26    STA  secs_in_minute_left  ; $26
$E85C               F8       SED
$E85D               A5 27    LDA  decimal_secs_in_minutes_left  ; $27
$E85F               38       SEC
$E860               E9 01    SBC  #$01
$E862               D8       CLD
$E863               85 27    STA  decimal_secs_in_minutes_left  ; $27
$E865               B0 0C    BCS  print_remaining_game_time  ; $E873
$E867               A9 59    LDA  #$59  ; value is used in 'decimal mode'
$E869               85 27    STA  decimal_secs_in_minutes_left  ; $27
$E86B               A5 28    LDA  game_time  ; $28
$E86D               F8       SED
$E86E               E9 00    SBC  #$00
$E870               D8       CLD
$E871               85 28    STA  game_time  ; $28


print_remaining_game_time:
//------------------------
$E873               A9 12    LDA  #$12  ; (18)
$E875               85 13    STA  txt_x_pos  ; $13
$E877               A9 18    LDA  #$18  ; (24)
$E879               85 14    STA  txt_y_pos  ; $14
$E87B               20 C0 E6 JSR  adjust_scr_and_clr_ptr_locations  ; $E6C0
$E87E               A0 00    LDY  #$00
$E880               A9 01    LDA  #$01
$E882               85 08    STA  genvarB  ; $08
$E884               A5 28    LDA  minutes_left  ; $28
$E886               20 44 E7 JSR  print_lower_nibble_digit_in_A  ; $E744
$E889               A9 42    LDA  #$42  ; ':' char
$E88B               91 02    STA  (scr_ptr_lo),y  ; ($02),Y
$E88D               C8       INY
$E88E               A5 27    LDA  decimal_secs_in_minutes_left  ; $27
$E890               4C 3B E7 JMP  print_two_digits_in_A  ; $E73B


random_num_gen_into_A:
---------------------
// NOTE: randomval_lsb is constantly incremented inside the game_loop routine on every frame/iteration
//       (perhaps to improve the randomness provided by this routine)
$E893               8A       TXA  ; ship-index?
$E894               48       PHA
$E895               A2 0B    LDX  #$0B  ; dec11  ; loop over 10 times
-retry:
$E897               06 1B    ASL  randomval_lsb  ; $1B
$E899               26 1C    ROL  randomval_msb  ; $1C  ; treat randomval_lsb+randomval_msb like a 16-bit number we rol to the left (multiply by 2)
$E89B               2A       ROL  ; rol whatever was left in Areg (usually some index/iterator value, usually ranging 0-7?)
$E89C               2A       ROL  ; i.e., multiply this 'random-ish' value by 4
$E89D               45 1B    EOR  randomval_lsb  ; $1B  ; flip some bits in the lsb of this 16-bit value
$E89F               2A       ROL  ; multiply this 'random-ish' A value by 2
$E8A0               45 1B    EOR  randomval_lsb  ; $1B  ; flip some more bits in the lsb of this 16-bit value
$E8A2               4A       LSR
$E8A3               4A       LSR  ; divide 'random-ish' A value by 4
$E8A4               49 FF    EOR  #$FF  ; flip all the bits in 'random-ish' A
$E8A6               29 01    AND  #$01  ; at this point, a=0 or 1  (only care about bit0 of regA)
$E8A8               05 1B    ORA  randomval_lsb  ; $1B  ; this could 'potentially' set bit0 of lsb of 16-bit value
$E8AA               85 1B    STA  randomval_lsb  ; $1B  ; so maybe it's a way to assure some balance between odd & even numbers?
$E8AC               CA       DEX
$E8AD               D0 E8    BNE  -retry  ; $E897  ; loop from 11 to 1  ; repeat this randomizing recipe 10 times
$E8AF               68       PLA
$E8B0               AA       TAX  ; restore prior regX value
$E8B1               A5 1B    LDA  randomval_lsb  ; $1B  ; we return regA as our 'random' result
$E8B3               60       RTS


set_sprite_position:
-------------------
// A = ship/buoy sprite index
//   - ships are from sprite index 0-3
//   - buoys are from sprite index 4-7
// xpos_local = curr ship/buoy xpos
// ypos_local = curr ship/buoy ypos
$E8B4               AA       TAX
$E8B5               0A       ASL  ; multiply by 2
$E8B6               A8       TAY
$E8B7               A5 11    LDA  xpos_local  ; $11
$E8B9               18       CLC
$E8BA               69 0C    ADC  #$0C  ; add 12
$E8BC               0A       ASL
$E8BD               99 00 D0 STA  $D000,Y  ; store in sprite x-pos of desired sprite
$E8C0               B0 09    BCS  +skip1  ; $E8CB
$E8C2               BD 40 EE LDA  and_bitfields,x  ; $EE40,X
$E8C5               2D 10 D0 AND  $D010  ; sprite 0-7 xpos msb  ; turn off sprite xpos msb
$E8C8               4C D1 E8 JMP  +skip2  ; $E8D1
+skip1:
$E8CB               BD 38 EE LDA  or_bitfields  ; $EE38,X  ; turn on sprite xpos msb
$E8CE               0D 10 D0 ORA  $D010
+skip2:
$E8D1               8D 10 D0 STA  $D010  ; set sprite xpos msb to desired value (either on/off)
$E8D4               A5 12    LDA  ypos_local  ; $12
$E8D6               18       CLC
$E8D7               69 32    ADC  #$32  ; dec50  ; adjust ship y-pos to absolute sprite coordinates
$E8D9               99 01 D0 STA  $D001,Y  ; set sprite ypos
$E8DC               60       RTS


turn_on_sprite_A:
----------------
$E8DD               AA       TAX
$E8DE               BD 38 EE LDA  or_bitfields,x  ; $EE38,X
$E8E1               0D 15 D0 ORA  $D015
$E8E4               8D 15 D0 STA  $D015  ; sprite display enable
$E8E7               60       RTS


turn_off_sprite_A:
-----------------
$E8E8               AA       TAX
$E8E9               BD 40 EE LDA  and_bitfields,x  ; $EE40,X
$E8EC               2D 15 D0 AND  $D015
$E8EF               8D 15 D0 STA  $D015  ; sprite display disable
$E8F2               60       RTS

allow_interrupts:
----------------
$E8F3               58       CLI
$E8F4               60       RTS

interrupt_precursor:
-------------------
$E8F5               78       SEI
$E8F6               A9 00    LDA  #$00
$E8F8               8D 21 D0 STA  $D021
$E8FB               8D 20 D0 STA  $D020
$E8FE               A9 00    LDA  #$00
$E900               8D 15 D0 STA  $D015  ; sprite display enable (hide them all?)
$E903               60       RTS

interrupt_routine:
-----------------
$E904               48       PHA
$E905               8A       TXA
$E906               48       PHA
$E907               A6 1A    LDX  $1A
$E909               BD 28 E9 LDA  raster_colours,x  ; $E928,X
$E90C               8D 21 D0 STA  $D021
$E90F               8D 20 D0 STA  $D020
$E912               BD 2C E9 LDA  raster_locations,x  ; $E92C,X
$E915               8D 12 D0 STA  $D012  ; read/write raster value for compare irq
$E918               E8       INX
$E919               8A       TXA
$E91A               29 03    AND  #$03
$E91C               85 1A    STA  $1A
$E91E               AD 19 D0 LDA  $D019  ; vic interrupt flag register
$E921               8D 19 D0 STA  $D019
$E924               68       PLA
$E925               AA       TAX
$E926               68       PLA
$E927               40       RTI

raster_colours:
// used within interrupt routine
 :000E928 03 0E 06 00
  - [0] = 03 (cyan)
  - [1] = 0e (light blue)
  - [2] = 06 (blue)
  - [3] = 00 (black)


raster_locations:
 :000E92C 46 8A DA 14                                       | F...

---------------------

init_sid:
--------
$E930               A2 18    LDX  #$18  ; (24)
$E932               BD DC EB LDA  sid_init_values,x  ; $EBDC,X
$E935               9D 00 D4 STA  $D400,X
$E938               CA       DEX
$E939               10 F7    BPL  $E932
$E93B               60       RTS


v1_reset_and_gate_off:
---------------------
// we've spawned a pt boat, so turn off prior ocean sound (to make way for pt boat beep-beep later)
$E93C               A9 06    LDA  #$06
$E93E               85 2A    STA  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
$E940               A9 00    LDA  #$00
$E942               8D 00 D4 STA  $D400  ; v1_freq_lo
$E945               8D 01 D4 STA  $D401  ; v1_freq_hi
$E948               A9 50    LDA  #$50   ; %0101 0000
$E94A               8D 06 D4 STA  $D406  ; v1_env_sus_rel
$E94D               A9 40    LDA  #$40   ; %0100 0000
$E94F               8D 04 D4 STA  $D404  ; v1_ctrl_reg  (select pulse, gate off)
$E952               60       RTS


play_fire_shoot_sound_on_v2:
//--------------------------
$E953               A9 03    LDA  #$03
$E955               85 2B    STA  whatis3  ; $2B
$E957               A9 81    LDA  #$81  ; %1000 0001
$E959               8D 0B D4 STA  $D40B  ; v2_ctrl_reg  (noise wave, gate on)
$E95C               60       RTS

trigger_voice3_sound:
//-------------------
$E95D               A9 03    LDA  #$03
$E95F               85 2C    STA  whatis4  ; $2C
$E961               A9 81    LDA  #$81  ; %1000 0001
$E963               8D 12 D4 STA  $D412  ; This is turning gate on for voice3  (perhaps to trigger explosion sound?)
$E966               60       RTS

assess_sound_states:
-------------------
  ' assesses whether to turn off any player fire/shot or ship explosion sounds
  ' also assesses whether to switch v1 to play the beep-beep of the P.T. boat
$E967               A5 2D    LDA  whatis5  ; $2D
$E969               F0 03    BEQ  +skip1  ; $E96E
$E96B               C6 2D    DEC  whatis5  ; $2D
$E96D               60       RTS
+skip1:
$E96E               A9 03    LDA  #$03
$E970               85 2D    STA  whatis5  ; $2D
$E972               A5 2B    LDA  whatis3  ; $2B
$E974               F0 09    BEQ  +skip2  ; $E97F
$E976               C6 2B    DEC  whatis3  ; $2B
$E978               D0 05    BNE  +skip3  ; $E97F
$E97A               A9 80    LDA  #$80  ; %1000 0000
$E97C               8D 0B D4 STA  $D40B  ; v2_ctrl_reg  (noise wave, gate off)  ; turn off player fire/shoot sound?
+skip2:
$E97F               A5 2C    LDA  whatis4  ; $2C
+skip3:
$E981               F0 09    BEQ  +skip4  ; $E98C
$E983               C6 2C    DEC  whatis4  ; $2C
$E985               D0 05    BNE  +skip4  ; $E98C
$E987               A9 80    LDA  #$80  ; %1000 0000
$E989               8D 12 D4 STA  $D412  ; v3_ctrl_reg  (noise wave, gate off)  ; turn off explosion sound?
+skip4:
$E98C               A2 03    LDX  #$03
-loop1:
$E98E               B5 39    LDA  ships_visibility,x  ; $39,X
$E990               F0 08    BEQ  +skip5  ; $E99A
$E992               30 06    BMI  +skip5  ; $E99A
$E994               B5 51    LDA  ships_type,x  ; $51,X  ; possibly index to the type of ship on screen
$E996               C9 02    CMP  #$02
$E998               F0 0F    BEQ  +skip6  ; $E9A9
+skip5:
$E99A               CA       DEX
$E99B               10 F1    BPL  -loop1  ; $E98E
$E99D               A2 06    LDX  #$06
-loop2:
$E99F               BD DC EB LDA  sid_init_values,x  ; $EBDC,X
$E9A2               9D 00 D4 STA  $D400,X  ; reset sid voice1 values (ocean sound?)
$E9A5               CA       DEX
$E9A6               10 F7    BPL  -loop2  ; $E99F
$E9A8               60       RTS
+skip6:
$E9A9               C6 2A    DEC  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
$E9AB               10 04    BPL  +skip7  ; $E9B1
$E9AD               A9 05    LDA  #$05
$E9AF               85 2A    STA  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
+skip7:
$E9B1               A5 2A    LDA  idx_to_v1_ptboat_beep_beep_freq_array  ; $2A
$E9B3               0A       ASL  multiply by 2
$E9B4               AA       TAX
$E9B5               BD 2C EE LDA  v1_ptboat_beep_beep_freq_array,x  ; $EE2C,X
$E9B8               8D 00 D4 STA  $D400  ; v1_freq_lo
$E9BB               BD 2D EE LDA  v1_ptboat_beep_beep_freq_array+1,x  ; $EE2D,X
$E9BE               8D 01 D4 STA  $D401  ; v1_freq_hi
$E9C1               A9 41    LDA  #$41  ; %0100 0001
$E9C3               8D 04 D4 STA  $D404  ; v1_ctrl_reg  ; (pulse wave, gate on)  ; seems like the beep-beep of the P.T. boat
$E9C6               60       RTS


start_game:
//---------
$E9C7               20 93 EB JSR  init_game_vars  ; $EB93
$E9CA               A9 FF    LDA  #$FF  ; turn on flag to say we are in real game (and not in attract mode)
$E9CC               85 16    STA  real_game_mode_flag  ; $16
$E9CE               A5 17    LDA  initial_game_time  ; $17
$E9D0               85 28    STA  minutes_left  ; $28
$E9D2               85 33    STA  last_paddle_fire_state  ; $33
$E9D4               85 34    STA  last_paddle_fire_state+1  ; $34
$E9D6               A9 00    LDA  #$00
$E9D8               85 1D    STA  p1_score_lo  ; $1D
$E9DA               85 1E    STA  p2_score_lo  ; $1E
$E9DC               85 1F    STA  p1_score_hi  ; $1F
$E9DE               85 20    STA  p2_score_hi  ; $20
$E9E0               20 7D E5 JSR  prepare_game_screen ; $E57D
$E9E3               20 30 E9 JSR  init_sid  ; $E930
$E9E6               A9 3F    LDA  #$3F  ; %0011 1111
$E9E8               8D 18 D4 STA  $D418 ; filter bandpass+low-pass, volume = 15
$E9EB               20 58 EB JSR  game_loop  ; $EB58
$E9EE               A9 00    LDA  #$00   ; (no filter, zero volume)
$E9F0               8D 18 D4 STA  $D418  ; sid_sel_filter_and_vol
$E9F3               A9 0A    LDA  #$0A
$E9F5               85 14    STA  txt_y_pos  ; $14
$E9F7               20 39 E8 JSR  draw_inline_text  ; $E839

 :000E9FA 2D 27 33 2B 26 26 35 3C  2B 38 00 
           G  A  M  E        O  V   E  R

$EA05               A2 96    LDX  #$96
$EA07               20 59 E7 JSR  timer_loop  ; $E759
$EA0A               CA       DEX
$EA0B               D0 FA    BNE  $EA07
jump_here_after_cold_start:
$EA0D               A9 00    LDA  #$00  ; turn off flag to say we are in attract mode game (and not in real game mode)
$EA0F               85 16    STA  real_game_mode_flag  ; $16
$EA11               20 CD E5 JSR  midway_in_preparing_game_screen  ; $E5CD
$EA14               A8       TAY
$EA15               D0 4A    BNE  $EA61
$EA17               20 93 EB JSR  init_game_vars  ; $EB93
$EA1A               A9 20    LDA  #$20
$EA1C               85 27    STA  decimal_secs_in_minutes_left  ; $27
$EA1E               A2 01    LDX  #$01
$EA20               20 93 E8 JSR  random_num_gen_into_A  ; $E893
$EA23               C9 28    CMP  #$28  ; dec40
$EA25               B0 F9    BCS  $EA20  ; if a >= 40 then loop
$EA27               95 35    STA  players_xpos,x  ; $35,X  ; place both player subs at some random 0-39 char xpos
$EA29               CA       DEX
$EA2A               10 F4    BPL  $EA20
$EA2C               20 7D E5 JSR  prepare_game_screen  ; $E57D
$EA2F               A9 0A    LDA  #$0A
$EA31               85 14    STA  txt_y_pos  ; $14
$EA33               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EA36 2D 27 33 2B 26 26 35 3C  2B 38 00
           G  A  M  E        O  V   E  R

$EA41               A9 0F    LDA  #$0F
$EA43               85 14    STA  txt_y_pos  ; $14
$EA45               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EA48 36 3B 39 2E 26 43 2C 47  43 26 3A 35 26 28 2B 2D  | 6;9.&C,GC&:5&(+-
           P  U  S  H     -  F  1   -     T  O     B  E  G
 :000EA58 2F 34 00
           I  N

$EA5B               20 58 EB JSR  game_loop  ; $EB58
$EA5E               A8       TAY
$EA5F               F0 AC    BEQ  jump_here_after_cold_start  ; $EA0D
$EA61               20 99 E7 JSR  init_game_screen  ; $E799
$EA64               A9 00    LDA  #$00
$EA66               8D 15 D0 STA  $D015  ; sprite display enable (hide all sprites)
$EA69               8D 0D D4 STA  $D40D  ; v2_env_gen sus/rel
$EA6C               8D 14 D4 STA  $D414  ; v3_env_gen sus/rel
$EA6F               20 F3 E8 JSR  allow_interrupts  ; $E8F3
$EA72               A9 01    LDA  #$01
$EA74               85 14    STA  txt_y_pos  ; $14
$EA76               20 39 E8 JSR  draw_inline_text  ; $E839

// trailing two zeroes of p1 score + highscore + p2 score
// ------------------------------------------------------
 :000EA79 F8 26 26 26 26 46 46 26  26 26 26 26 26 26 26 26  | .&&&&FF&&&&&&&&&
                          0  0                            
 :000EA89 26 26 26 46 46 26 26 26  26 26 26 26 26 26 26 26  | &&&FF&&&&&&&&&&&
                    0  0                                  
 :000EA99 26 46 46 00
              0  0

$EA9D               A9 05    LDA  #$05
$EA9F               85 14    STA  txt_y_pos  ; $14
$EAA1               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EAA4 43 26 36 3B 39 2E 26 43  00 
           -     P  U  S  H     -

$EAAD               E6 14    INC  txt_y_pos  ; $14
$EAAF               E6 14    INC  txt_y_pos  ; $14
$EAB1               E6 14    INC  txt_y_pos  ; $14
$EAB3               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EAB6 2C 47 26 3A 35 26 39 3A  27 38 3A 26 2D 27 33 2B  | ,G&:5&9:'8:&-'3+
           F  1     T  O     S  T   A  R  T     G  A  M  E
 :000EAC6 41 00
           .

$EAC8               E6 14    INC  txt_y_pos  ; $14
$EACA               E6 14    INC  txt_y_pos  ; $14
$EACC               E6 14    INC  txt_y_pos  ; $14
$EACE               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EAD1 2C 49 26 3A 35 26 26 2F  34 29 38 2B 27 39 2B 26  | ,I&:5&&/4)8+'9+&
           F  3     T  O        I   N  C  R  E  A  S  E  
 :000EAE1 00

$EAE2               E6 14    INC  txt_y_pos  ; $14
$EAE4               E6 14    INC  txt_y_pos  ; $14
$EAE6               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EAE9 26 2C 4B 26 3A 35 26 26  2A 2B 29 38 2B 27 39 2B  | &,K&:5&&*+)8+'9+
              F  5     T  O         D  E  C  R  E  A  S  E
 :000EAF9 26 00

$EAFB               E6 14    INC  txt_y_pos  ; $14
$EAFD               E6 14    INC  txt_y_pos  ; $14
$EAFF               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EB02 26 36 32 27 3F 2F 34 2D  26 3A 2F 33 2B 41 00
              P  L  A  Y  I  N  G      T  I  M  E  .

$EB11               A9 00    LDA  #$00
$EB13               85 27    STA  decimal_secs_in_minutes_left  ; $27
$EB15               A9 17    LDA  #$17  ; dec23
$EB17               85 14    STA  txt_y_pos  ; $14
$EB19               20 39 E8 JSR  draw_inline_text  ; $E839

 :000EB1C 36 32 27 3F 2F 34 2D 26  3A 2F 33 2B 00
           P  L  A  Y  I  N  G      T  I  M  E

$EB29               A5 17    LDA  initial_game_time  ; $17
$EB2B               85 28    STA  minutes_left  ; $28
-retry_loop1:
$EB2D               20 73 E8 JSR  print_remaining_game_time  ; $E873
-retry_loop2:
$EB30               20 68 E5 JSR  parent_routine_that_does_key_paddle_input  ; $E568
$EB33               C9 01    CMP  #$01   ; was paddle-fire or F1 pressed?
$EB35               D0 03    BNE  skippy  ; $EB3A  ; if not, branch
$EB37               4C C7 E9 JMP  start_game  ; $E9C7
+skippy:
$EB3A               C9 03    CMP  #$03  ; was F3 pressed? (increase time)
$EB3C               D0 0D    BNE  +skip_next  ; $EB4B  ; if not, branch
$EB3E               A5 28    LDA  $28
$EB40               C9 09    CMP  #$09
$EB42               F0 EC    BEQ  -retry_loop2  ; $EB30  ; if already 9 minutes, can't increase further, branch back
$EB44               E6 17    INC  initial_game_time  ; $17
$EB46               E6 28    INC  minutes_left  ; $28
$EB48               4C 2D EB JMP  -retry_loop1  ; $EB2D
+skip_next:
                 ; we're assuming if it's not paddle-fire, F1 or F3, then at this point, it must be F5 (decrease time)
$EB4B               A5 28    LDA  minutes_left  ; $28
$EB4D               C9 01    CMP  #$01
$EB4F               F0 DF    BEQ  -retry_loop2  ; $EB30
$EB51               C6 17    DEC  initial_game_time  ; $17
$EB53               C6 28    DEC  minutes_left  ; $28
$EB55               4C 2D EB JMP  -retry_loop1  ; $EB2D


game_loop:
//--------
-loopback:
$EB58               AD 1E D0 LDA  $D01E  ; sprite-to-sprite collision detect
$EB5B               85 18    STA  buff_spr2spr_coll  ; $18
$EB5D               AD 1F D0 LDA  $D01F  ; sprite-to-background collision detect
$EB60               85 19    STA  buff_spr2back_coll  ; $19
$EB62               20 00 E0 JSR  ship_logic  ; $E000  ; has logic to spawn new ships when needed
$EB65               20 C8 E1 JSR  buoy_logic  ; $E1C8
$EB68               20 7D E2 JSR  handle_missile_firing_and_player_movement  ; $E27D
$EB6B               20 CE E3 JSR  redraw_player_submarines  ; $E3CE
$EB6E               20 5F E4 JSR  bullet_redraw_and_ship_assessment  ; $E45F
$EB71               A5 16    LDA  real_game_mode_flag  ; $16
$EB73               F0 03    BEQ  +skip_if_in_attract_mode  ; $EB78
$EB75               20 67 E9 JSR  assess_sound_states  ; $E967
+skip_if_in_attract_mode:
$EB78               20 4E E8 JSR  update_game_time_left  ; $E84E
$EB7B               20 59 E7 JSR  timer_loop  ; $E759
$EB7E               A5 16    LDA  real_game_mode_flag  ; $16
$EB80               D0 0A    BNE  +if_in_real_game_then_skip_exit_attract_check  ; $EB8C
exit_attract_check:
$EB82               E6 1B    INC  randomval_lsb  ; $1B
$EB84               20 36 E5 JSR  paddle_and_function_key_reading_routine  ; $E536
$EB87               A8       TAY
$EB88               C9 01    CMP  #$01
$EB8A               F0 06    BEQ  +skip_to_end  ; $EB92  ; was paddle-fire or F1 pressed?
+if_in_real_game_then_skip_exit_attract_check:
$EB8C               A5 28    LDA  minutes_left  ; $28
$EB8E               05 27    ORA  decimal_secs_in_minutes_left  ; $27
$EB90               D0 C6    BNE  -loopback  ; $EB58
+skip_to_end:
$EB92               60       RTS


init_game_vars:
//--------------
$EB93               A2 82    LDX  #$82
$EB95               A9 00    LDA  #$00
$EB97               8D 15 D0 STA  $D015  ; sprite display enable/disable  (this will disable them all)
-loop1:
$EB9A               95 22    STA  $22,X  ; reset vars in range of $22 to $A4 to zero
$EB9C               CA       DEX
$EB9D               D0 FB    BNE  -loop1  ; $EB9A
$EB9F               A9 04    LDA  #$04
$EBA1               85 31    STA  p1_num_missiles  ; $31
$EBA3               85 32    STA  p2_num_missiles  ; $32
$EBA5               A9 00    LDA  #$00
$EBA7               85 61    STA  buoys_xpos  ; $61
$EBA9               A9 44    LDA  #$44
$EBAB               85 62    STA  buoys_xpos+1  ; $62
$EBAD               A9 60    LDA  #$60
$EBAF               85 65    STA  buoys_ypos  ; $65
$EBB1               85 66    STA  buoys_ypos+1  ; $66
$EBB3               A9 01    LDA  #$01
$EBB5               85 5D    STA  buoys_visibility  ; $5D
$EBB7               85 5E    STA  buoys_visibility+1  ; $5E
$EBB9               A9 3B    LDA  #$3B  ; dec59
$EBBB               85 26    STA  secs_in_minute_left  ; $26
$EBBD               60       RTS

vic_init_values:
 :000EBBE 1B 00 00 00 00 08 00 10  FF 00 FF 00 0F 00 00 03  | ................
 :000EBCE 00 00 00 00 00 00 00 00  00 00 00 00 00 00        | ..............
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
          (i.e., expand sprites 0-3 horz - for the ships)
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
 :000EBDC 88 13 00 08 81 00 21 98  3A 00 08 80 8C 4B B0 04  | ......!.:....K..
 :000EBEC 00 08 80 00 FA 00 96 F4  30                       | ........0

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
$EBF5               78       SEI
$EBF6               D8       CLD
$EBF7               A2 2F    LDX  #$2F
$EBF9               9A       TXS  ; Why stack pointer so low? Aah, to make room for char-data copied into $0130 and onwards at $EC5C
$EBFA               A2 1D    LDX  #$1D
$EBFC               BD BE EB LDA  vic_init_values,x  ; $EBBE,X
$EBFF               9D 11 D0 STA  $D011,X
$EC02               CA       DEX
$EC03               10 F7    BPL  $EBFC
$EC05               AD 1E D0 LDA  $D01E  ; sprite-to-sprite collision detect (read it to reset the value)
$EC08               AD 1F D0 LDA  $D01F  ; sprite-to-background collision detect (read it to reset the value)
$EC0B               20 30 E9 JSR  init_sid  ; $E930
$EC0E               A9 7F    LDA  #$7F   ; %0111 1111
$EC10               8D 0D DC STA  $DC0D  ; cia_irq_ctrl_reg (only allow IRQ, not others)
$EC13               A9 00    LDA  #$00   ; %0000 0000
$EC15               8D 0F DC STA  $DC0F  ; cia_ctrl_reg_B (use clk, timer b count system 2 clks, continuous, pulse, no, stop)
$EC18               A2 00    LDX  #$00
$EC1A               8E 03 DC STX  $DC03  ; ddr_port_b
$EC1D               CA       DEX
$EC1E               8E 02 DC STX  $DC02  ; ddr_port_a
$EC21               A9 E5    LDA  #$E5   ; %1110 0101
$EC23               85 01    STA  $01    ; (cassette-motor=off, cassette-switch=closed, char-rom-in=no, kernal-rom=off, basic-rom=on)
$EC25               A9 2F    LDA  #$2F   ; %0010 1111
$EC27               85 00    STA  $00    ; mos 6510 ddr (1=output, 0=input)
$EC29               A9 06    LDA  #$06
$EC2B               8D 04 DC STA  $DC04  ; timer_a_low_byte
$EC2E               A9 47    LDA  #$47
$EC30               8D 05 DC STA  $DC05  ; timer_a_high_byte
$EC33               A9 18    LDA  #$18   ; %0001 1000
$EC35               8D 0E DC STA  $DC0E  ; cia_ctrl_reg_a (todclk=60Hz, serialio=input, tmracnt=system2clk, forceloadtmra=yes
                                         ;                 tmramode=oneshot, tmraoutputmode=pulse, outonpb6=no, startstoptmra=stop)
$EC38               A9 01    LDA  #$01
$EC3A               8D 1A D0 STA  $D01A  ; irq_mask_reg (raster_compare_irq = enabled)
$EC3D               A2 02    LDX  #$02
$EC3F               A9 00    LDA  #$00   ; initialise-to-zero all global variables in zero-page
$EC41               95 00    STA  $00,X
$EC43               E8       INX
$EC44               D0 FB    BNE  $EC41
$EC46               A9 03    LDA  #$03
$EC48               85 17    STA  initial_game_time  ; $17
$EC4A               BD 5C EC LDA  char_data_group1,x  ; $EC5C,X
$EC4D               9D 30 01 STA  $0130,X  ; copy across charset to vicii-bank 0, starting at charidx $26 (' ' space char)
$EC50               BD D4 EC LDA  char_data_group2,x  ; $ECD4,X
$EC53               9D A8 01 STA  $01A8,X  ; copy across charset to vicii-bank 0, starting at charidx $35 (letter 'O')
$EC56               E8       INX
$EC57               D0 F1    BNE  $EC4A
$EC59               4C 0D EA JMP  jump_here_after_cold_start  ; $EA0D

char_data_group1:
//---------------
  - starting at chridx $26
 :000EC5C 00 00 00 00 00 00 00 00  38 6C C6 C6 FE C6 C6 00  | ........8l......
 :000EC6C FC 66 66 7C 66 66 FC 00  3C 66 C0 C0 C0 66 3C 00  | .ff|ff..<f...f<.
 :000EC7C F8 64 66 66 66 64 F8 00  FE 60 60 7C 60 60 FE 00  | .dfffd...``|``..
 :000EC8C FE 60 60 7C 60 60 F0 00  3C 66 C0 DE C6 66 3C 00  | .``|``..<f...f<.
char idx $26 address: $0130
+--------+--------+--------+--------+--------+--------+--------+--------+
|        |  ***   |******  |  ****  |*****   |******* |******* |  ****  |
|        | ** **  | **  ** | **  ** | **  *  | **     | **     | **  ** |
|        |**   ** | **  ** |**      | **  ** | **     | **     |**      |
|        |**   ** | *****  |**      | **  ** | *****  | *****  |** **** |
|        |******* | **  ** |**      | **  ** | **     | **     |**   ** |
|        |**   ** | **  ** | **  ** | **  *  | **     | **     | **  ** |
|        |**   ** |******  |  ****  |*****   |******* |****    |  ****  |
|        |        |        |        |        |        |        |        |
+--------+--------+--------+--------+--------+--------+--------+--------+

 :000EC9C C6 C6 C6 FE C6 C6 C6 00  3C 18 18 18 18 18 3C 00  | ........<.....<.
 :000ECAC 1E 0C 0C 0C CC CC 78 00  C6 CC D8 F0 D8 CC C6 00  | ......x.........
 :000ECBC F0 60 60 60 60 60 FE 00  C6 EE FE D6 C6 C6 C6 00  | .`````..........
 :000ECCC C6 E6 F6 DE CE C6 C6 00                           | ........
char idx $2E address: $0170
+--------+--------+--------+--------+--------+--------+--------+
|**   ** |  ****  |   **** |**   ** |****    |**   ** |**   ** |
|**   ** |   **   |    **  |**  **  | **     |*** *** |***  ** |
|**   ** |   **   |    **  |** **   | **     |******* |**** ** |
|******* |   **   |    **  |****    | **     |** * ** |** **** |
|**   ** |   **   |**  **  |** **   | **     |**   ** |**  *** |
|**   ** |   **   |**  **  |**  **  | **     |**   ** |**   ** |
|**   ** |  ****  | ****   |**   ** |******* |**   ** |**   ** |
|        |        |        |        |        |        |        |
+--------+--------+--------+--------+--------+--------+--------+

char_data_group2:
//---------------
 :000ECD4 7C EE C6 C6 C6 EE 7C 00  FC 66 66 7C 60 60 F0 00  | |.....|..ff|``..
 :000ECE4 38 64 C2 C2 CA 64 3A 00  FC C6 C6 FC D8 CC C6 00  | 8d...d:.........
 :000ECF4 7C C6 C0 7C 06 C6 7C 00  7E 18 18 18 18 18 3C 00  | |..|..|.~.....<.
 :000ED04 C6 C6 C6 C6 C6 C6 7C 00  C6 C6 C6 6C 6C 38 38 00  | ......|....ll88.
char idx $35 address: $01A8
+--------+--------+--------+--------+--------+--------+--------+--------+
| *****  |******  |  ***   |******  | *****  | ****** |**   ** |**   ** |
|*** *** | **  ** | **  *  |**   ** |**   ** |   **   |**   ** |**   ** |
|**   ** | **  ** |**    * |**   ** |**      |   **   |**   ** |**   ** |
|**   ** | *****  |**    * |******  | *****  |   **   |**   ** | ** **  |
|**   ** | **     |**  * * |** **   |     ** |   **   |**   ** | ** **  |
|*** *** | **     | **  *  |**  **  |**   ** |   **   |**   ** |  ***   |
| *****  |****    |  *** * |**   ** | *****  |  ****  | *****  |  ***   |
|        |        |        |        |        |        |        |        |
+--------+--------+--------+--------+--------+--------+--------+--------+

 :000ED14 C6 C6 C6 D6 D6 FE 6C 00  C6 C6 6C 38 6C C6 C6 00  | ......l...l8l...
 :000ED24 C6 C6 6C 7C 38 38 38 00  FE C6 0C 38 60 C6 FE 00  | ..l|888....8`...
 :000ED34 00 00 00 00 18 18 00 00  00 18 18 00 18 18 00 00  | ................
 :000ED44 00 00 00 7E 7E 00 00 00  0C 18 30 30 30 18 0C 00  | ...~~.....000...
char idx $3D address: $01E8
+--------+--------+--------+--------+--------+--------+--------+--------+
|**   ** |**   ** |**   ** |******* |        |        |        |    **  |
|**   ** |**   ** |**   ** |**   ** |        |   **   |        |   **   |
|**   ** | ** **  | ** **  |    **  |        |   **   |        |  **    |
|** * ** |  ***   | *****  |  ***   |        |        | ****** |  **    |
|** * ** | ** **  |  ***   | **     |   **   |   **   | ****** |  **    |
|******* |**   ** |  ***   |**   ** |   **   |   **   |        |   **   |
| ** **  |**   ** |  ***   |******* |        |        |        |    **  |
|        |        |        |        |        |        |        |        |
+--------+--------+--------+--------+--------+--------+--------+--------+

 :000ED54 30 18 0C 0C 0C 18 30 00  7C C6 CE D6 E6 C6 7C 00  | 0.....0.|.....|.
 :000ED64 18 38 18 18 18 18 3C 00  7C C6 C6 0C 38 E0 FE 00  | .8....<.|...8...
 :000ED74 7C C6 06 1C 06 C6 7C 00  0C 1C 2C 4C FE 0C 0C 00  | |.....|...,L....
 :000ED84 FE C0 C0 FC 06 C6 7C 00  1C 30 60 FC C6 C6 7C 00  | ......|..0`...|.
char idx $45 address: $0228
+--------+--------+--------+--------+--------+--------+--------+--------+
|  **    | *****  |   **   | *****  | *****  |    **  |******* |   ***  |
|   **   |**   ** |  ***   |**   ** |**   ** |   ***  |**      |  **    |
|    **  |**  *** |   **   |**   ** |     ** |  * **  |**      | **     |
|    **  |** * ** |   **   |    **  |   ***  | *  **  |******  |******  |
|    **  |***  ** |   **   |  ***   |     ** |******* |     ** |**   ** |
|   **   |**   ** |   **   |***     |**   ** |    **  |**   ** |**   ** |
|  **    | *****  |  ****  |******* | *****  |    **  | *****  | *****  |
|        |        |        |        |        |        |        |        |
+--------+--------+--------+--------+--------+--------+--------+--------+

 :000ED94 7E C6 0C 18 18 18 18 00  7C C6 C6 7C C6 C6 7C 00  | ~.......|..|..|.
 :000EDA4 7C C6 C6 7E 06 0C 38 00  00 3F 7F FF FF 7F 3F 00  | |..~..8..?....?.
 :000EDB4 00 FF FF FF FF FF FF 00  00 FF FF FF FF FF FF 00  | ................
 :000EDC4 00 8C CC FF FF CC 8C 00  60 80 40 29 CF 09 09 09  | ........`.@)....
char idx $4D address: $0268
+--------+--------+--------+--------+--------+--------+--------+--------+
| ****** | *****  | *****  |        |        |        |        | **     |
|**   ** |**   ** |**   ** |  ******|********|********|*   **  |*       |
|    **  |**   ** |**   ** | *******|********|********|**  **  | *      |
|   **   | *****  | ****** |********|********|********|********|  * *  *|
|   **   |**   ** |     ** |********|********|********|********|**  ****|
|   **   |**   ** |    **  | *******|********|********|**  **  |    *  *|
|   **   | *****  |  ***   |  ******|********|********|*   **  |    *  *|
|        |        |        |        |        |        |        |    *  *|
+--------+--------+--------+--------+--------+--------+--------+--------+

some_unused_char_maybe:
//---------------------
  - This looks like HAL (HAL Laboratories?)
 :000EDD4 A4 EE AA 00 20 20 38 00                           | ....  8.
+--------+
|* *  *  |
|*** *** |
|* * * * |
|        |
|  *     |
|  *     |
|  ***   |
|        |
+--------+

scr_row_ptr_lo:
//-------------
 :000EDDC 00 28 50 78 A0 C8 F0 18  40 68 90 B8 E0 08 30 58  | .(Px....@h....0X
 :000EDEC 80 A8 D0 F8 20 48 70 98  C0                       | .... Hp..

scr_row_ptr_hi:
//-------------
 :000EDF5 04 04 04 04 04 04 04 05  05 05 05 05 05 06 06 06  | ................
 :000EE05 06 06 06 06 07 07 07 07  07                       | .........

    E.g., taking the same index of each array gets you:
        scr_row_ptr[0] = $0400
        scr_row_ptr[1] = $0428
        scr_row_ptr[2] = $0450
        scr_row_ptr[3] = $0478
        scr_row_ptr[4] = $04A0
        scr_row_ptr[5] = $04C8
        scr_row_ptr[6] = $04F0
        scr_row_ptr[7] = $0518
        scr_row_ptr[8] = $0540
        scr_row_ptr[9] = $0568
        scr_row_ptr[10] = $0590
        scr_row_ptr[11] = $05B8
        scr_row_ptr[12] = $05E0
        scr_row_ptr[13] = $0608
        scr_row_ptr[14] = $0630
        scr_row_ptr[15] = $0658
        scr_row_ptr[16] = $0680
        scr_row_ptr[17] = $06A8
        scr_row_ptr[18] = $06D0
        scr_row_ptr[19] = $06F8
        scr_row_ptr[20] = $0720
        scr_row_ptr[21] = $0748
        scr_row_ptr[22] = $0770
        scr_row_ptr[23] = $0798
        scr_row_ptr[24] = $07C0

ship_type_widths:  (used by ADC at $e091 and compared against #$a0 = 160)
 :000EE0E 18 18 10 
  - dec: 24, 24, 16
    [0] = 24 (width of freighter)
    [1] = 24 (width of cruiser)
    [2] = 16 (width of pt-boat)

unknown_data:
 :000EE11 00 0A                                             | ..

map_gap_from_existing_ship_to_new_ship:  (used by lda at $e181)
 :000EE13 20 46 68 20 24 58 20 24  30 
  - groups of 3 (relating to ship-type of existing ship closest to spawn edge)
  - i.e., map[3][3], where:
    - 1st idx is existing_ship_type
    - 2nd idx is newly_spawned_ship_type
  - The rough gist is, if the existing nearest ship is slow, and the new ship is faster, then we'll need a bigger gap?
    - [0] = 20 46 68  (if existing ship was a freighter, use this group)
        - #$20 (32) = gap needed if newly spawned ship is a freighter and nearest existing ship is freighter
        - #$46 (70) = gap needed if newly spawned ship is a cruiser and nearest existing ship is freighter
                        - since cruiser is slightly faster than freighter, we need a slightly bigger gap
        - #$68 (104) = gap needed if newly spawned ship is a pt-boat and nearest existing ship is freighter
                        - since pt-boat is much faster than freighter, we need an even bigger gap
    - [1] = 20 24 58  (if existing ship was a cruiser, use this group)
        - #$20 (32) = gap needed if newly spawned ship is a freighter and nearest existing ship is a cruiser
        - #$24 (36) = gap needed if newly spawned ship is a cruiser and nearest existing ship is a cruiser
        - #$58 (88) = gap needed if newly spawned ship is a pt-boat and nearest existing ship is a cruiser
    - [2] = 20 24 30  (if existing ship was a pt-boat, use this group)
        - #$20 (32) = gap needed if newly spawned ship is a freighter and nearest existing ship is a pt-boat
        - #$24 (36) = gap needed if newly spawned ship is a cruiser and nearest existing ship is a pt-boat
        - #$30 (48) = gap needed if newly spawned ship is a pt-boat and nearest existing ship is a pt-boat

ships_movement_delay:
 :000EE1C 02 01 00 
  - [0] = 02 (move freighter along every 3 frames - slow)
  - [1] = 01 (move cruiser along every 2 frames - faster)
  - [2] = 00 (move pt-boat along every 1 frame - fastest)

ship_scores:
 :000EE1F 02 05 0A
    ; Freighter = 200 points
    ;   Cruiser = 500 points
    ; P.T. boat = 1000 points

possible_buoy_y_positions:
 :000EE22 60 80                                             | `.

    $60 = 96
    $80 = 128

screen_offsets_for_each_missile_indicator:
// (in the indicator group of 4 per player)
 :000EE24 2F 07 2A 02

    $2F = 47
    $07 = 7
    $2A = 42
    $02 = 2

missile_char_offsets:
// as each missile is drawn with custom-chars in a 2x2 group, these relative screen offsets
// can quickly refer to each char offset of the 2x2 group
 :000EE28 00 28 01 29
  - $00 = 0
  - $28 = 40
  - $01 = 1
  - $29 = 41

v1_ptboat_beep_beep_freq_array:
 :000EE2C 00 00 E8 4E 00 00 00 00  00 00 E8 4E
  - [0] = $0000
  - [1] = $4EE8
  - [2] = $0000
  - [3] = $0000
  - [4] = $0000
  - [5] = $4EE8


or_bitfields:
 :000EE38 01 02 04 08 10 20 40 80
   - $01 = %0000 0001
   - $02 = %0000 0010
   - $04 = %0000 0100
   - $08 = %0000 1000
   - $10 = %0001 0000
   - $20 = %0010 0000
   - $40 = %0100 0000
   - $80 = %1000 0000

and_bitfields:
 :000EE40 FE FD FB F7 EF DF BF 7F
   - $FE = %1111 1110
   - $FD = %1111 1101
   - $FB = %1111 1011
   - $F7 = %1111 0111
   - $EF = %1110 1111
   - $DF = %1101 1111
   - $BF = %1011 1111
   - $7F = %0111 1111


submarine_charset1:
 :000EE48 00 00 00 3F FF FF 3F 00  01 07 07 FF FF FF FF 00  | ...?..?.........
 :000EE58 80 E0 E0 FF FF FF FF 00  00 00 00 FC FF FF FC 00  | ................
 :000EE68 00 00 00 00 00 00 00 00
+--------+--------+--------+--------+--------+
|        |       *|*       |        |        |
|        |     ***|***     |        |        |
|        |     ***|***     |        |        |
|  ******|********|********|******  |        |
|********|********|********|********|        |
|********|********|********|********|        |
|  ******|********|********|******  |        |
|        |        |        |        |        |
+--------+--------+--------+--------+--------+

submarine_charset2:
 :000EE70                          00 00 00 0F 3F 3F 0F 00  | ............??..
 :000EE78 00 01 01 FF FF FF FF 00  60 F8 F8 FF FF FF FF 00  | ........`.......
 :000EE88 00 00 00 FF FF FF FF 00  00 00 00 00 C0 C0 00 00  | ................
+--------+--------+--------+--------+--------+
|        |        | **     |        |        |
|        |       *|*****   |        |        |
|        |       *|*****   |        |        |
|    ****|********|********|********|        |
|  ******|********|********|********|**      |
|  ******|********|********|********|**      |
|    ****|********|********|********|        |
|        |        |        |        |        |
+--------+--------+--------+--------+--------+

submarine_charset3:
 :000EE98 00 00 00 03 0F 0F 03 00  00 00 00 FF FF FF FF 00  | ................
 :000EEA8 18 7E 7E FF FF FF FF 00  00 00 00 FF FF FF FF 00  | .~~.............
 :000EEB8 00 00 00 C0 F0 F0 C0 00  
+--------+--------+--------+--------+--------+
|        |        |   **   |        |        |
|        |        | ****** |        |        |
|        |        | ****** |        |        |
|      **|********|********|********|**      |
|    ****|********|********|********|****    |
|    ****|********|********|********|****    |
|      **|********|********|********|**      |
|        |        |        |        |        |
+--------+--------+--------+--------+--------+

submarine_charset4:
 :000EEC0                          00 00 00 00 03 03 00 00  | ................
 :000EEC8 00 00 00 FF FF FF FF 00  06 1F 1F FF FF FF FF 00  | ................
 :000EED8 00 80 80 FF FF FF FF 00  00 00 00 F0 FC FC F0 00  | ................
+--------+--------+--------+--------+--------+
|        |        |     ** |        |        |
|        |        |   *****|*       |        |
|        |        |   *****|*       |        |
|        |********|********|********|****    |
|      **|********|********|********|******  |
|      **|********|********|********|******  |
|        |********|********|********|****    |
|        |        |        |        |        |
+--------+--------+--------+--------+--------+

submarine_charset_idx:
// choose between submarine_charset1/2/3/4
 :000EEE8 00 28 50 78

// small_missile_char_data_start  = EEEC
// medium_missile_char_data_start = EF2C 
// big_missile_char_data_start    = EF6C
// These are #$40 apart

small_missile_char_data_x_offset0:
 :000EEEC 00 00 40 E0 E0 E0 E0 40  00 00 00 00 00 00 00 00 
+--------+--------+
|        |        |
|        |        |
| *      |        |
|***     |        |
|***     |        |
|***     |        |
|***     |        |
| *      |        |
+--------+--------+

small_missile_char_data_x_offset2:
 :000EEFC 00 00 10 38 38 38 38 10
+--------+--------+
|        |        |
|        |        |
|   *    |        |
|  ***   |        |
|  ***   |        |
|  ***   |        |
|  ***   |        |
|   *    |        |
+--------+--------+

small_missile_char_data_x_offset4:
 :000EF0C 00 00 04 0E 0E 0E 0E 04   
+--------+--------+
|        |        |
|        |        |
|     *  |        |
|    *** |        |
|    *** |        |
|    *** |        |
|    *** |        |
|     *  |        |
+--------+--------+

small_missile_char_data_x_offset6:
 :000EF1C 00 00 01 03 03 03 03 01
+--------+--------+
|        |        |
|        |        |
|       *|        |
|      **|*       |
|      **|*       |
|      **|*       |
|      **|*       |
|       *|        |
+--------+--------+

medium_missile_char_data_x_offset0:
 :000EF2C 60 60 F0 F0 F0 F0 F0 60 
+--------+--------+
| **     |        |
| **     |        |
|****    |        |
|****    |        |
|****    |        |
|****    |        |
|****    |        |
| **     |        |
+--------+--------+

medium_missile_char_data_x_offset2:
 :000EF3C 18 18 3C 3C 3C 3C 3C 18
+--------+--------+
|   **   |        |
|   **   |        |
|  ****  |        |
|  ****  |        |
|  ****  |        |
|  ****  |        |
|  ****  |        |
|   **   |        |
+--------+--------+

medium_missile_char_data_x_offset4:
 :000EF4C 06 06 0F 0F 0F 0F 0F 06
+--------+--------+
|     ** |        |
|     ** |        |
|    ****|        |
|    ****|        |
|    ****|        |
|    ****|        |
|    ****|        |
|     ** |        |
+--------+--------+

medium_missile_char_data_x_offset6:
 :000EF5C 01 01 03 03 03 03 03 01
+--------+--------+
|       *|*       |
|       *|*       |
|      **|**      |
|      **|**      |
|      **|**      |
|      **|**      |
|      **|**      |
|       *|*       |
+--------+--------+

big_missile_char_data_x_offset0:
 :000EF6C 30 78 FC FC FC FC FC 78
+--------+--------+
|  **    |        |
| ****   |        |
|******  |        |
|******  |        |
|******  |        |
|******  |        |
|******  |        |
| ****   |        |
+--------+--------+

big_missile_char_data_x_offset2:
 :000EF7C 0C 1E 3F 3F 3F 3F 3F 1E
+--------+--------+
|    **  |        |
|   **** |        |
|  ******|        |
|  ******|        |
|  ******|        |
|  ******|        |
|  ******|        |
|   **** |        |
+--------+--------+

big_missile_char_data_x_offset4:
 :000EF8C 03 07 0F 0F 0F 0F 0F 07
+--------+--------+
|      **|        |
|     ***|*       |
|    ****|**      |
|    ****|**      |
|    ****|**      |
|    ****|**      |
|    ****|**      |
|     ***|*       |
+--------+--------+

big_missile_char_data_x_offset6:
 :000EF9C 00 01 03 03 03 03 03 01
+--------+--------+
|        |**      |
|       *|***     |
|      **|****    |
|      **|****    |
|      **|****    |
|      **|****    |
|      **|****    |
|       *|***     |
+--------+--------+


missiles_colour_table:
 :000EFAC 07 07 07 07 08 08 08 08                           | ........
  - a choice between yellow or light brown, with index from 0-7
  - player1's 4 missiles will all be yellow
  - player2's 4 missiles will all be light brown

map_2x2_ypos_to_chardata_offset_for_missile_size:
// the offset into the missile char data to reference either small (#$00), medium (#$40) or big (#$80) missiles
 :000EFB4 00 00 00 00 00 40 40 40  80 80 80 80

missile_speed_at_indexed_2x2_ypos:
// At the lower part of the screen, the missile moves faster, #$02 = 2 pixels per frame
// At the mid and upper parts of the screen, the missile moves slower, #$01 = 1 pixel per frame
// the #$03 speed seems unused
 :000EFC0 01 01 01 01 01 01 02 02  02 02 03 03

mission_text1:
 :000EFCC 3F 35 3B 38 26 33 2F 39  39 2F 35 34 26 2F 39 26  | ?5;8&3/99/54&/9&
           Y  O  U  R     M  I  S   S  I  O  N     I  S  
 :000EFDC 3A 35 26 2A 2B 39 3A 38  35 3F 26 27 39 26 33 27  | :5&*+9:85?&'9&3'
           T  O     D  E  S  T  R   O  Y     A  S     M  A
 :000EFEC 34 3F 00                                          | 4?.
           N  Y

mission_text2:
 :000EFEF 2B 34 2B 33 3F 26 39 2E  2F 36 39 26 27 39 26 36  | +4+3?&9./69&'9&6
           E  N  E  M  Y     S  H   I  P  S     A  S     P
 :000EFFF 35 39 39 2F 28 32 2B 26  28 2B 2C 35 38 2B 26 3A  | 599/(2+&(+,58+&:
           O  S  S  I  B  L  E      B  E  F  O  R  E     T
 :000F00F 2F 33 2B 26 38 3B 34 39  00                       | /3+&8;49.
           I  M  E     R  U  N  S

mission_text3:

 :000F018 35 3B 3A 41 26 2C 2F 38  2B 26 3A 35 38 36 2B 2A  | 5;:A&,/8+&:586+*
           O  U  T  .     F  I  R   E     T  O  R  P  E  D
 :000F028 35 2B 39 26 28 3F 26 36  38 2B 39 39 2F 34 2D 26  | 5+9&(?&68+99/4-&
           O  E  S     B  Y     P   R  E  S  S  I  N  G  
 :000F038 3A 2E 2B 00                                       | :.+.
           T  H  E

mission_text4:

 :000F03C 28 3B 3A 3A 35 34 26 35  34 26 3A 2E 2B 26 36 27  | (;::54&54&:.+&6'
           B  U  T  T  O  N     O   N     T  H  E     P  A
 :000F04C 2A 2A 32 2B 41 26 2F 3A  26 3A 27 31 2B 39 26 49  | **2+A&/:&:'1+9&I
           D  D  L  E  .     I  T      T  A  K  E  S     3
 :000F05C 26 39 2B 29 35 34 2A 39  00                       | &9+)54*9.
              S  E  C  O  N  D  S

mission_text5:

 :000F065 2C 35 38 26 2B 27 29 2E  26 3A 35 38 36 2B 2A 35  | ,58&+').&:586+*5
           F  O  R     E  A  C  H      T  O  R  P  E  D  O
 :000F075 26 32 35 27 2A 41 00
              L  O  A  D  .

mission_text6:
 :000F07C 26 00                                             | &.
          <emptyline>

mission_text7:
 :000F07E FF 26 26 26 26 26 26 26  26 26 43 26 26 2C 38 2B  | .&&&&&&&&&C&&,8+
    <yellow>                              -        F  R  E
 :000F08E 2F 2D 2E 3A 2B 38 42 26  26 48 46 46 26 36 35 2F  | /-.:+8B&&HFF&65/
           I  G  H  T  E  R  :         2  0  0     P  O  I
 :000F09E 34 3A 39 00                                       | 4:9.
           N  T  S

mission_text8:
 :000F0A2 FB 26 26 26 26 26 26 26  26 26 43 26 26 29 38 3B  | .&&&&&&&&&C&&)8;
      <cyan>                              -        C  R  U
 :000F0B2 2F 39 2B 38 26 26 42 26  26 4B 46 46 26 36 35 2F  | /9+8&&B&&KFF&65/
           I  S  E  R        :         5  0  0     P  O  I
 :000F0C2 34 3A 39 00                                       | 4:9.
           N  T  S

mission_text9:
 :000F0C6 FD 26 26 26 26 26 26 26  26 26 43 26 26 36 41 3A  | .&&&&&&&&&C&&6A:
     <green>                              -        P  .  T
 :000F0D6 41 26 28 35 27 3A 42 26  47 46 46 46 26 36 35 2F  | A&(5':B&GFFF&65/
           .     B  O  A  T  :      1  0  0  0     P  O  I
 :000F0E6 34 3A 39 00                                       | 4:9.
           N  T  S

no_idea_yet:
 :000F0EA 00 FF FF FF FF FF                                 | ......

read_paddle_position:
--------------------
$F0F0               AA       TAX  ; X = player index (0=player1, 1=player2)
$F0F1               38       SEC
$F0F2               A9 C8    LDA  #$C8  ; dec200
$F0F4               FD 19 D4 SBC  $D419,X  ; adc paddle1 pos ($d419) or paddle2 pos ($d41a)
$F0F7               B0 02    BCS  +branch_if_>=200  ; $F0FB  ; branch if subtraction didn't cause a borrow (i.e. if paddle pos didn't surpass #$c8 / 200)
$F0F9               A9 00    LDA  #$00  ; if paddle-pos surpassed #$c8/200, then we set it to #$00
+branch_if_>=200:
$F0FB               85 08    STA  genvarB  ; $08  ; otherwise paddle is set to be #$C8 minus paddle-pos
                                               ; I.e., keep in the range of 0 to 200
$F0FD               4A       LSR  ; A=0 to 100
$F0FE               18       CLC
$F0FF               65 08    ADC  genvarB  ; $08  A = 1.5 * genvarB (range: 0 to 300)
$F101               6A       ROR  ; A = 0.75 * genvarB  (range: 0 to 150?)
                                  ; I wonder about carry-flag being on sometimes and going to bit7
                                  ; Aah, this logic is fine, the carry-bit becomes like a 'high byte',
                                  ; and the ROR pushes the bit0 of this high byte into our low byte reg A.
$F102               A0 00    LDY  #$00
$F104               84 08    STY  genvarB  ; $08
$F106               A0 03    LDY  #$03
// Seems like prior x-pos of the player's submarine is added to the current paddle pos three times
// So the carry bits accumulate in genvarB. So genvarB is like the 'high byte' of this addition.
// Later, when the two ror's occur, it's like a division by 4, which brings it all back to the 8-bit range.
;
; I sense this is a smoothing filter, to prevent too much jitter on the paddles, by putting a heavier weighting
; on the prior xpos (x3) and smaller weighter on the newer xpos (x1), then divide by 4 to average it out.
;
; NOTE: I think the 0-150 range for sub movement relates to how the submarine_charset1/2/3/4 move the sub by increments of
; 2 pixels (not one). So the units of this amount aren't pixels by units of 2-pixels (or pixel pairs, if you prefer)
-retry1:
$F108               18       CLC
$F109               75 FE    ADC  filtered_player_xpos,x  ; $FE,X  ; let's assume filtered_player_xpos is initialised to zero, nothing gets added
$F10B               90 02    BCC  +skip1  ; $F10F     ; for this assumed initial case, we'll branch)
$F10D               E6 08    INC  genvarB  ; $08  ; genvarB will contain how many times a carry happened (how many times the adc passed 255)
+skip1:
$F10F               88       DEY
$F110               D0 F6    BNE  -retry1  ; $F108
; So A = 3 x (old xpos) + new paddle xpos (in 2-pixel units)
$F112               66 08    ROR  genvarB  ; $08
$F114               6A       ROR
$F115               66 08    ROR  genvarB  ; $08
$F117               6A       ROR  ; shift A right twice (/4), and in bits7-6, place the genvarB count of how many carries occurred
                                  ; this
$F118               38       SEC
$F119               E9 02    SBC  #$02   ; A=(0to150 range) - 2 = (-2 to 148 range)
$F11B               B0 02    BCS  +skip2  ; $F11F  ; branch if sbc didn't cause borrow (A-2 was >= 0)
; I suppose it could only get here if genvarB was 0 (i.e., that count of carries in the y-loop was zero)
$F11D               A9 00    LDA  #$00  ; so if no carries occurred, store a value of #$00
                                        ; i.e., assure range is 0 to 148
+skip2:
$F11F               95 FE    STA  filtered_player_xpos,x  ; $FE,X  ; This stores the smoothed/filtered x-pos of the player's sub in 0-148 range
$F121               60       RTS

some_unknown_data:
// doesn't appear to be used anywhere
 :000F122 FF FF FF

set_sprite_colour:
//----------------
$F125               BD 2C F1 LDA  $F12C,X
$F128               9D 27 D0 STA  $D027,X
$F12B               60       RTS

sprite_colours:
 :000F12C 03 0B 0D
    [0] = 03 = cyan
    [1] = 0B = dark grey
    [2] = 0D = light green

void_data:
 :000F12F FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF
...repeat
 :000FB70 FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF

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

 :000FB80 49 00 00 10 80 00 00 00  00 00 C0 00 00 CC 00 18  | I...............
 :000FB90 CC 00 18 CC 00 18 CE 00  D8 FE 07 F9 BB 3F BF EE  | .............?..
 :000FBA0 FF EB FF FE FF FF FE 7F  FF FC 7F FF F8 3F FF F0  | .............?..
 :000FBB0 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
| *  *  *                |
|   *    *               |
|                        |
|        **              |
|        **  **          |
|   **   **  **          |
|   **   **  **          |
|   **   **  ***         |
|** **   *******      ***|
|*****  ** *** **  ******|
|* ********* *** ********|
|*** * ***************** |
|*********************** |
| *********************  |
| ********************   |
|  ******************    |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FBC0 00 00 00 00 00 00 00 00  00 01 40 00 22 00 00 08  | ..........@."...
 :000FBD0 60 00 00 60 00 03 60 00  03 7C 00 03 6E 1E 03 7A  | `..`..`..|..n..z
 :000FBE0 08 E7 FF 1F FF FF FE FF  FF FC 7F FF F8 3F FF F0  | .............?..
 :000FBF0 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                        |
|                        |
|                        |
|       * *              |
|  *   *                 |
|    *    **             |
|         **             |
|      ** **             |
|      ** *****          |
|      ** ** ***    **** |
|      ** **** *     *   |
|***  ***********   *****|
|*********************** |
|**********************  |
| ********************   |
|  ******************    |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FC00 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  | ................
 :000FC10 00 00 00 00 00 00 00 00  01 00 00 01 80 00 01 E0  | ................
 :000FC20 00 03 50 00 33 FF 00 3F  FE 00 1F FC 00 1F F8 00  | ..P.3..?........
 :000FC30 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|       *                |
|       **               |
|       ****             |
|      ** * *            |
|  **  **********        |
|  *************         |
|   ***********          |
|   **********           |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FC40 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  | ................
 :000FC50 00 00 00 00 00 00 00 00  00 00 00 0C 00 00 13 38  | ...............8
 :000FC60 00 26 64 00 6B E0 00 7D  CE 00 D9 E3 00 F7 77 00  | .&d.k..}......w.
 :000FC70 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|    **                  |
|   *  **  ***           |
|  *  **  **  *          |
| ** * *****             |
| ***** ***  ***         |
|** **  ****   **        |
|**** *** *** ***        |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FC80 00 00 92 00 01 08 00 00  00 00 03 00 00 33 00 00  | .............3..
 :000FC90 33 18 00 33 18 00 73 18  E0 7F 1B FC DD 9F FF 77  | 3..3..s........w
 :000FCA0 FD 7F FF D7 7F FF FF 3F  FF FE 1F FF FE 0F FF FC  | .......?........
 :000FCB0 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                *  *  * |
|               *    *   |
|                        |
|              **        |
|          **  **        |
|          **  **   **   |
|          **  **   **   |
|         ***  **   **   |
|***      *******   ** **|
|******  ** *** **  *****|
|******** *** ********* *|
| ***************** * ***|
| ***********************|
|  ********************* |
|   ******************** |
|    ******************  |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FCC0 00 00 00 00 00 00 00 00  00 00 02 80 00 00 44 00  | ..............D.
 :000FCD0 06 10 00 06 00 00 06 C0  00 3E C0 78 76 C0 10 5E  | .........>.xv..^
 :000FCE0 C0 F8 FF E7 7F FF FF 3F  FF FF 1F FF FE 0F FF FC  | .......?........
 :000FCF0 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                        |
|                        |
|                        |
|              * *       |
|                 *   *  |
|             **    *    |
|             **         |
|             ** **      |
|          ***** **      |
| ****    *** ** **      |
|   *     * **** **      |
|*****   ***********  ***|
| ***********************|
|  **********************|
|   ******************** |
|    ******************  |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FD00 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  | ................
 :000FD10 00 00 00 00 00 00 00 00  00 00 80 00 01 80 00 07  | ................
 :000FD20 80 00 0A C0 00 FF CC 00  7F FC 00 3F F8 00 1F F8  | ...........?....
 :000FD30 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                *       |
|               **       |
|             ****       |
|            * * **      |
|        **********  **  |
|         *************  |
|          ***********   |
|           **********   |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FD40 34 1E 00 5A 33 00 C5 5D  00 9F 22 00 22 56 00 41  | 4..Z3..].."."V.A
 :000FD50 59 00 1D 60 00 32 CE 00  47 D1 00 0D FC 00 13 EA  | Y..`.2..G.......
 :000FD60 00 26 E5 00 4F B0 00 17  F8 00 2F D4 00 DD DF 00  | .&..O...../.....
 :000FD70 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|  ** *     ****         |
| * ** *   **  **        |
|**   * * * *** *        |
|*  *****  *   *         |
|  *   *  * * **         |
| *     * * **  *        |
|   *** * **             |
|  **  * **  ***         |
| *   ***** *   *        |
|    ** *******          |
|   *  ***** * *         |
|  *  ** ***  * *        |
| *  ***** **            |
|   * ********           |
|  * ****** * *          |
|** *** *** *****        |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FD80 13 48 D8 26 02 8C 71 9B  86 64 C5 B6 35 63 04 FB  | .H.&..q..d..5c..
 :000FD90 87 3B 6C 6E 66 33 A9 EC  19 A2 18 0C E7 30 07 99  | .;lnf3.......0..
 :000FDA0 E0 03 18 C0 07 99 E0 0C  DB 30 18 7E 18 30 3C 0C  | .........0.~.0<.
 :000FDB0 7F FF FE EE E7 77 EE E7  77 EE E7 77 7F FF FE 20  | .....w..w..w...
+------------------------+
|   *  ** *  *   ** **   |
|  *  **       * *   **  |
| ***   **  ** ***    ** |
| **  *  **   * ** ** ** |
|  ** * * **   **     *  |
|***** ***    ***  *** **|
| ** **   ** ***  **  ** |
|  **  *** * *  **** **  |
|   **  ** *   *    **   |
|    **  ***  ***  **    |
|     ****  **  ****     |
|      **   **   **      |
|     ****  **  ****     |
|    **  ** ** **  **    |
|   **    ******    **   |
|  **      ****      **  |
| ********************** |
|*** *** ***  *** *** ***|
|*** *** ***  *** *** ***|
|*** *** ***  *** *** ***|
| ********************** |
+------------------------+

 :000FDC0 21 48 C4 46 02 82 D1 10  81 A0 05 37 90 03 05 E0  | !H.F.......7....
 :000FDD0 00 3B 6C 42 22 73 A1 CC  D9 A2 08 48 E5 30 87 99  | .;lB"s.....H.0..
 :000FDE0 E8 63 18 C2 03 98 1E 48  DB 30 08 76 08 30 30 0C  | .c.....H.0.v.00.
 :000FDF0 43 9E 0E C2 E2 45 E0 67  45 8E A4 77 57 FC FE 20  | C....E.gE..wW..
+------------------------+
|  *    * *  *   **   *  |
| *   **       * *     * |
|** *   *   *    *      *|
|* *          * *  ** ***|
|*  *          **     * *|
|***               *** **|
| ** **   *    *   *   * |
| ***  *** *    ***  **  |
|** **  ** *   *     *   |
| *  *   ***  * *  **    |
|*    ****  **  **** *   |
| **   **   **   **    * |
|      ***  **      **** |
| *  *   ** ** **  **    |
|    *    *** **     *   |
|  **      **        **  |
| *    ***  ****     *** |
|**    * ***   *  *   * *|
|***      **  *** *   * *|
|*   *** * *  *   *** ***|
| * * *********  ******* |
+------------------------+

 :000FE00 1B 5B C8 06 02 80 51 10  86 20 05 36 50 00 05 E0  | .[....Q.. .6P...
 :000FE10 00 3B 6C 00 22 72 00 40  D8 00 0C 40 00 01 84 00  | .;l."r.@...@....
 :000FE20 2B 62 00 03 80 00 1E 48  12 31 08 02 09 30 30 0C  | +b.....H.1...00.
 :000FE30 C3 9E 0E 4A E0 45 60 6E  45 0E 94 11 1D 25 58 20  | ...J.E`nE....%X
+------------------------+
|   ** ** * ** ****  *   |
|     **       * *       |
| * *   *   *    *    ** |
|  *          * *  ** ** |
| * *                 * *|
|***               *** **|
| ** **            *   * |
| ***  *          *      |
|** **               **  |
| *                     *|
|*    *            * * **|
| **   *               **|
|*                  **** |
| *  *      *  *   **   *|
|    *         *     *  *|
|  **      **        **  |
|**    ***  ****     *** |
| *  * * ***      *   * *|
| **      ** ***  *   * *|
|    *** *  * *     *   *|
|   *** *  *  * * * **   |
+------------------------+

 :000FE40 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  | ................
 :000FE50 00 00 00 00 00 07 C0 00  1F F8 00 2F FC 00 57 AF  | .........../..W.
 :000FE60 00 46 E3 00 8F F1 80 9D  F8 80 2F D5 00 DD DF 80  | .F......../.....
 :000FE70 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 12  | ................
+------------------------+
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|                        |
|     *****              |
|   **********           |
|  * **********          |
| * * **** * ****        |
| *   ** ***   **        |
|*   ********   **       |
|*  *** ******   *       |
|  * ****** * * *        |
|** *** *** ******       |
|                        |
|                        |
|                        |
|                        |
|                        |
+------------------------+

 :000FE80 03 FF C0 04 42 20 05 5E  A0 04 46 A0 05 5E 20 C3  | ....B .^..F..^ .
 :000FE90 FF C3 60 7E 06 30 3C 0C  18 7E 18 0C DB 30 07 99  | ..`~.0<..~...0..
 :000FEA0 E0 03 18 C0 07 99 E0 0C  DB 30 18 7E 18 30 3C 0C  | .........0.~.0<.
 :000FEB0 7F FF FE EE E7 77 EE E7  77 EE E7 77 7F FF FE 20  | .....w..w..w...
+------------------------+
|      ************      |
|     *   *    *   *     |
|     * * * **** * *     |
|     *   *   ** * *     |
|     * * * ****   *     |
|**    ************    **|
| **      ******      ** |
|  **      ****      **  |
|   **    ******    **   |
|    **  ** ** **  **    |
|     ****  **  ****     |
|      **   **   **      |
|     ****  **  ****     |
|    **  ** ** **  **    |
|   **    ******    **   |
|  **      ****      **  |
| ********************** |
|*** *** ***  *** *** ***|
|*** *** ***  *** *** ***|
|*** *** ***  *** *** ***|
| ********************** |
+------------------------+

void_data:
 :000FEC0 FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  | ................
...repeat
 :000FFF0 FF FF FF FF FF FF FF FF  FF FF


irq_pointers:
 :000FFFA 04 E9 F5 EB 04 E9                                 | ......
  - [0] = $E904 : interrupt_routine (NMI handler)
  - [1] = $EBF5 : cold_start_handler (Cold start handler)
  - [2] = $E904 : interrupt_routine (IRQ and BRK handler)

// in vim, type: nnoremap <F5>  :make seawolf.prg<CR>
