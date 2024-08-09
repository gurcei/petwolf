; HAL LAB RANDOM NUMBER GENERATOR TESTER
; --------------------------------------
; 9TH AUGUST 2024
;
; ASSEMBLE WITH MEGA-A, THEN RUN WITH MEGA-R
;
; IT WILL BUILD A FILE 'RANDOM TEST' ON YOUR DISK
;
; LOAD IT WITH BLOAD 'RANDOM TEST',B0
;
; RUN IT WITH BANK 0 : SYS $1600

COUNT_TABLE = $1800
TABLE_PTR = $FE
LOOP_COUNTER = $17F0
VAL_LSB = $17F2
VAL_MSB = $17F3

    *=$1600,'RANDOM TEST'

;----
.INIT
;----

    ; RESET COUNT TABLE
    ; -----------------
    LDX #$00
    LDA #$00

.RESET_TABLE_LOOP
;----------------
    STA COUNT_TABLE,X
    STA COUNT_TABLE + $100,X
    INX
    BNE .RESET_TABLE_LOOP

    ; RESET LOOP COUNTER
    ; ------------------
    STX LOOP_COUNTER
    STX LOOP_COUNTER + 1

    SEI

    ; SET TABLE_PTR TO POINT TO COUNT_TABLE
    ; -------------------------------------
    LDA #<COUNT_TABLE
    STA TABLE_PTR
    LDA #>COUNT_TABLE
    STA TABLE_PTR + 1

    ; START MAIN PROGRAM
    ; ------------------
    LDX #$00

.LOOPBACK
;--------
    JSR .RANDOM_NUM_GEN_INTO_A
    TAY

    ; ADD 1 TO INDEXED TABLE ENTRY
    ; ----------------------------
    CLC
    LDA #$01
    ADC (TABLE_PTR),Y
    STA (TABLE_PTR),Y
    INC TABLE_PTR + 1
    LDA #$00
    ADC (TABLE_PTR),Y
    STA (TABLE_PTR),Y
    DEC TABLE_PTR + 1

    ; INCREMENT X WITHIN RANGE 0 TO 3
    ; -------------------------------
    INX
    TXA
    AND #$03
    TAX

    ; INCREMENT LOOP COUNTER
    ; ----------------------
    CLC
    LDA #$01
    ADC LOOP_COUNTER
    STA LOOP_COUNTER
    LDA #$00
    ADC LOOP_COUNTER + 1
    STA LOOP_COUNTER + 1

    ; ASSESS IF WE SHOULD PRINT OUTPUT EVERY 256 ITERATIONS?
    ; -----------------------------------------------------
    LDA LOOP_COUNTER
    BNE .SKIP_TO_ASSESS

    JSR .PRINT_RESULTS

    ; ASSESS IF WE'VE DONE 65536 ITERATIONS
    ; -------------------------------------
.SKIP_TO_ASSESS
;--------------
    LDA LOOP_COUNTER
    ORA LOOP_COUNTER + 1
    BNE .LOOPBACK

    JSR .PRINT_RESULTS

    ; END PROGRAM
    ; -----------
    CLI
    RTS


;-------------
.PRINT_RESULTS
;-------------
    PHA
    TXA
    PHA
    TYA
    PHA

    ; PRINT RESULTS ON SCREEN
    ; -----------------------
    LDA #147   ; CLEAR SCREEN
    JSR $FFD2

    ; PRINT LOOP COUNTER
    ; ------------------
    LDA LOOP_COUNTER + 1
    JSR .PRINT_VAL_REG_A
    LDA LOOP_COUNTER
    JSR .PRINT_VAL_REG_A
    LDA #$0D
    JSR $FFD2
    LDA #$0D
    JSR $FFD2  ; TWO CARRIAGE RETURNS

    LDY #$00   ; I'LL USE THIS AS THE INDEX INTO THE TABLE FOR NOW
.PRINT_LOOP
;----------
    ; PRINT CURRENT INDEX
    ; -------------------
    TYA
    JSR .PRINT_VAL_REG_A

    ; PRINT COLON AND SPACE
    ; ---------------------
    LDA #58  ; COLON
    JSR $FFD2
    ; LDA #32  ; SPACE
    ; JSR $FFD2

    ; PRINT VALUE AT TABLE INDEX
    ; --------------------------
    LDA (TABLE_PTR),Y
    STA VAL_LSB
    INC TABLE_PTR + 1
    LDA (TABLE_PTR),Y
    STA VAL_MSB
    DEC TABLE_PTR + 1

    JSR .PRINT_VAL_REG_A
    LDA VAL_LSB
    JSR .PRINT_VAL_REG_A

    ; INCREMENT INDEX
    ; ---------------
    INY

    ; DECIDE IF PRINTING A TAB OR CARRIAGE RETURN
    ; -------------------------------------------
    TYA
    AND #$07
    BEQ .DO_CARRIAGE_RETURN
    LDA #$09    ; PETSCII TAB KEY
    JSR $FFD2
    JMP .SKIP
.DO_CARRIAGE_RETURN
    LDA #$0D
    JSR $FFD2
.SKIP
    CPY #$00
    BNE .PRINT_LOOP

    ; WAIT FOR USER INPUT?
    ; -------------------
    JSR $FFCF

    PLA
    TAY
    PLA
    TAX
    PLA

    RTS


;---------------
.PRINT_VAL_REG_A
;---------------
  PHA
  LSR
  LSR
  LSR
  LSR

  JSR .PRINT_NIBBLE
  PLA
  AND #$0F
  JSR .PRINT_NIBBLE
  RTS


;------------
.PRINT_NIBBLE
;------------
  CMP #$0A

  BCC .IS_NUMERIC

  ; IS ALPHA
  SEC
  SBC #$0A
  CLC
  ADC #65   ; LETTER 'A' IN PETSCII
  JSR $FFD2
  RTS
.IS_NUMERIC
;----------
  ADC #48   ; NUMBER '0' IN PETSCII
  JSR $FFD2
  RTS


;---------------------
.RANDOM_NUM_GEN_INTO_A
;---------------------
    TXA
    PHA
    LDX #$0B
.RAND_RETRY
;----------
    ASL $1B
    ROL $1C
    ROL
    ROL
    EOR $1B
    ROL
    EOR $1B
    LSR
    LSR
    EOR #$FF
    AND #$01
    ORA $1B
    STA $1B
    DEX
    BNE .RAND_RETRY
    PLA
    TAX
    LDA $1B
    RTS

*
