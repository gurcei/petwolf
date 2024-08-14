// ======================
// BASIC STUB FOR SEAWOLF
// ======================

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
    jmp $FFFC   ; cold start handler


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
