*-----------------------------------------------------------
* Title      : ChibiAkumas Lesson 1
* Written by : ySPHAx
* Date       : 15/07/2021 dmy
* Description: Learning 68k assembly with ChibiAkumas tuto.
*              https://www.chibiakumas.com/68000/
*-----------------------------------------------------------

    ;ORG    $1000 ; Looking in the emulator, it looks like it begins at
                 ; address number 1000.
    
; things which start with '#' are number, or else, memory address
; If you add '%' after, it is binary number: #%00001111
; If you add '$' after, it is Hex number: #$4000

; b = byte (8), w = word (16) and l = long (32)
; move.l = move LONG

; JSR jumps to a subroutine; is the equivalent of GOSUB in basic or CALL in z80

; ###############################################################
; ###############################################################
; ###############################################################

START:                     ; first instruction of program
* Put program code here

; #####################
; ####### MOVE COMMANDS
; #####################

    move.l #$70,d0         ; Load D0 with HEX ($) as LONG (32 bits)
    move.l #70,d1          ; Load D1 with DECIMAL (45 in hex) as LONG (32 bits)
;    jmp * ; 'jmp *' tricks 68k to infinite loop, maybe akin to 'while(1)'

; Check image (no image on github) to understand the text below:
; * You can clean with 'move.l #0,d0' and then 'move.l d0,d1' *

;When we didn't specify any length with D3 - the assembler assumed we were
;working at 16 bits... however I'd reccomend for clarity that you always
;specify B W or L for your own clarity... NOTE: Some commands ALWAYS work
;as L or B commands - like LEA or SBCD... so do not assume anything!

; ###############################################################

;VERY IMPORTANT!
;When you copy a B or W from one register to another - the remaining bits will
;be unchanged! this can cause problems... for example if you do
;    Move.B #0,D1
;    Add.L D0,D1
;You will not be able to rely on the value of D1.... why? because the top 24
;bits of D0 could have been ANYTHING.... and you just added them to D1! -
;either you should have done Add.B - or Cleared the top bits of D0

;NOTE: There is no 24bit command - even though all our addresses are 24 bit
;- so we need to use Long commands (32 bit) for address registers!

; ###############################################################

;There is one similar command we may want to use... CLR.L D0...
;This clears (sets to 0) a register, and works with B, W or L...
;VASM will NOT automatically convert MOVE.L #0,D0 to CLR.L D0...
;It converts to MoveQ #0,D0 because MoveQ is faster.

    clr.l d1                ; Set d1 to 0

; ###############################################################

;setting an address we really should use MoveA... this is because the Move
;command cannot set an Address register...
;if we do Move.L $00111111,A0 it WILL work... even though it shouldn't!
;Why? because VASM is kind - it knows we should have used MoveA - so it
;converts it for us.

    moveA.l #$70707070,a0   ; Load A0 with Hex 70707070

; ###############################################################

;another is MoveQ.L - which only works with L (32 bit) this will set a
;register to a value between -127 and 128... why use it? well it's FAST!
;MoveQ will compile to 2 bytes  where as Move.L would take 6...
;BUT VASM is kind again! it will detect if you could have used the
;MoveQ.L command - and convert your code to it automatically...

    moveQ.l #$01,d1 ; Move Quick Long -128 to 127

; ###############################################################

; #####################
; ####### ADD AND SUB
; #####################
    clr.l d0        ; In the tuto, looks like he remade the code,
                    ; i'm just going to clean it.
    move.l #$15,d0  ; So he register 15 in HEX to d0
    add.l #3,d0     ; Add 3 (decimal) to d0
    sub.l #3,d0     ; Sub 3 (decimal) to d0, make sure to check
                    ; by line on the simulator, or else, it wont
                    ; even look like something happened.
                    
; We aren't using VASM (i think, i don't know the compiler of
;'EASy68k'), so, check if it will work correctly.

;Like with Move, there are some 'Special versions' we should use...
;Like AddI and SubI with a # number (immediate number) or
;AddA / SubA for addreses - but once again VASM will worry about
;that for us!

    addI.l #1,d0    ; Technically, we should use AddI with '#'
    subI.l #1,d0    ; Technically, we should use SubI with '#'

;One more interesting one is ADDQ and SUBQ... These allow the
;addition or subtraction of a value up to 8... If you're familiar
;with Z80 - these are effectively our inc and dec commands -
;they're super fast, and compile to 2 bytes (the minimum for the
;68000) - and we can inc or dec by up to 7 in one go!...
;These work with Data Registers, and Address Registers...
;That said - the Assembler wil work out when we could have used
;them if we don't!

    addQ.l #7,d0    ; 0 to 7, only faster
    subQ.l #7,d0
    
; ###############################################################

; #####################
; ####### STORE BACK TO MEMORY
; #####################

;The 68000 is a bit different to the 8 bits... usually there will
;be an 'Operating system' doing memory management for us,  and
;this may mean we don't know where our program ends up running,
;or what RAM we've been given for out variables...

;Fortunately there is a simple solution... the LEA command will
;Load the Effective Address of a 'label' - the result... we don't
;need to worry about where the data really is!...

;Labels always appear at the far left of the code - and mark a
;'defined line' of the code... But don't worry too much about
;'Labels' yet - we'll cover them in a later lesson.

;In this example 'UserRam' is a 'label' pointing to some RAM we
;want to use - and store some data into that ram...

;Note in this example we're working at the Byte level.

UserRAM

    lea UserRAM+100,a0  ; Show memory; I think this was for his monitor
                        ; Since it does t he same as the code below the
                        ; move below.
    moveq.l #1,d0
    
    LEA UserRAM+100,a0  ; Load 3 bytes into A0, A1, and A2
    LEA UserRAM+101,a1
    LEA UserRAM+102,a2

    move.b #$11,d0
    move.b d0,(a0)      ; Save D0 to address in A0
    move.b #$22,(a1)    ; Save $22 directly to address in A1
    
    move.b #$33,d2      ; Load $33 into D2
    add.b (a0),d2       ; add value from address in A0
    add.b (a1),d2       ; add value from address in A1
    move.b d2,(a2)      ; Save A2 to address in A2; maybe he wanted to say 'Save D2'
    
    lea UserRAM+100,a0  ; Show memory after all those commands
    moveq.l #1,d0
    
; * As i noticed (not in the tuto), the address don't change the number in
; the simulator, it just change the value at the address.
; To test it better, i'll move the UserRAM and it should be the same as D2 *

    ;move.l (a2),d0             ; I guess it should be BYTE
    move.b (a2),d0              ; Yes, i think it is an endian problem
    ;move.l UserRAM+102,d1      ; Ops...
    ;move.l (UserRAM+102),d1    ; Ops again...
    lea UserRAM+102,a0          ; Now A2 is the same as A0 in the address
                                ; register
    move.b (a0),d1              ; This was LONG before, now it is BYTE

; ###############################################################

; ###############################################################
; ###############################################################
; ###############################################################

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

