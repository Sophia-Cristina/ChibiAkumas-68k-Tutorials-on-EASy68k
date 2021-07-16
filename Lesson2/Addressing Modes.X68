*-----------------------------------------------------------
* Title      : ChibiAkumas Lesson 2
* Written by : ySPHAx
* Date       : 16/07/2021 d/m/y
* Description: Lot of ways to mess up with memories.
*-----------------------------------------------------------
    ;ORG    $1000
    
; ###############################################################
; ###############################################################
; ###############################################################

UserRAM equ $00FF0000   ; This was declared inside the "SrcGEN\V1_HEADER.ASM", but was
                        ; used in the code in the video. However, i prefer 'UserRAM'
                        ; than 'UserRam'.

START:                  ; That is on the Mega Driver head from the Chibi's source files
; #####################
; ####### PREPARATION
; #####################

;TestData
    lea TestData,a0         ; A0 gains an address: '7A'
                            ; A0 also gets the values from 'TestData'
                            
    move.l #$00FF00F0,a1    ; Then A1 is now '00FF00F0'.
                            ; It seems we are registering it in RAM
                            ; and problably based on Genesis mapping.
    
    move.l #$1F,d0          ; D0 become '0000001F' (LONG)
    
FillTestData:
    ; #######
    move.b (a0),d7          ; SINCE I'M NOT USING Chibi's MONITOR, I'M GOING TO USE D7
    ; #######
    move.b (a0)+,(a1)+      ; A0 increments one, like '++A0', it is now '7B',
                            ; and it adds the value of (a0) into (a1).
    
    dbra d0,FillTestData    ; Get back to the below 'FillTestData' 31 (1F in D0)
                            ; times, decreasing.
                            ; It is akin to:
                            ;       'int D0 = 31; for (int A0 = 0; A0 == D0; ++A0) {}'

; Since i don't know much about assembly, i think this code is either for
; ChibiAkumas' monitor, or this system is about what he mentions in his
; video at 1m05s:
; https://www.youtube.com/watch?v=SmrOPJbpnDw&list=PLp_QNRIYljFqbJk96Ow1t7ObusLchrBvH&index=2

;    dc.l $00FF00F0         ; !!! Error: Selected line does not have a valid address !!!    
;    dc.w $4                ; Simulator call both lines above as an illegal instruction!
    
    clr.l d0                ; Clear LONG, before it, 'D0' became '0000FFFF',
                            ; I think it was a subtraction overflow from loop.
                            
    move.l #$00FF0100,a1    ; Now A1 is address: '00FF0100'
    move.l #$00000001,d1    ; Now 'D1 = 01', but i yet have to know the reason.

; ###############################################################
    
; ####### EXAMPLE 1 - INTERMEDIATE #######
; In this example we've moved #$12345678 directly into D0
; - this is known as immediate addressing!

    move.l #$12345678,d0

; ####### EXAMPLE 2 - ABSOLUTE #######

; Absolute addressing is where we read from a 'fixed' memory address...
; Of course the address is specified WITHOUT a # symbol

; On a 68000 system, we need to be sure what we're doing, and what will actually
; be at the address we're reading/writing to... 

    move.w $00FF0100,d0
    
; IMAGE:
;   move.w $00FF0100,d0 ---> $00FF0100 = F0 -> Big Endian
;                        |-> $00FF0101 = F1 -> RESULT: D0 = $0000F0F1
;                        ... $00FF0102 = F2 .. .....................

; In this example we've loaded a WORD (+16 bits - 2 bytes) from
; memory address $FF0100 - the middle of our test data...

; Note: the 68000 is BIG ENDIAN... this means D0 ends up with the value $F0F1
; (on a little endian system it would be $F1F0).

; ******* However, i have not cleaned D0 from 'EXAMPLE 1', and that was a good
; reason to understand why sometimes you have to clean addresses, so i let it.
; And the result should be: $1234F0F1 *******

; ####### EXAMPLE 3 - DIRECT ADDRESSING #######

; Data register direct is where the source is the value held in a Data Register D0-D7

    move.l d1,d0            ; RESULT: D0 = $00000001;

; ####### EXAMPLE 4 - ADDRESS DIRECT #######

; Address register direct is where the source
; is the value held in a Address Register A0-A7

    move.l a1,d0            ; RESULT: D0 = $00FF0100;
                            ; Although, in the website image the result is different,
                            ; The 'Before' collum, A1 is euqal to '$00FF0100'.
                            ; In the image of his monitor, '00:00FF0100'.

; ####### EXAMPLE 5 - ADDRESS REGISTER INDIRECT ADDRESSING #######

; Address Register indirect looks at the data held at the
; address in the address register...

; ******* We used that in the 'FillTestData' *******
; *** Basically, it is like using a dereferenc from a pointer.
; int a; int* A1 = &a; // suppose &a = '0x00ff0100';

    move.w (a1),d0          ; RESULT: '$00FFF0F1'
                            ; Same change from 'EXAMPLE 2', big endian value inside
                            ; what is addressed by A1.

; ####### EXAMPLE 6 - ADDRESS REGISTER INDIRECT WITH POST-INCREMENT #######

; In the video he talks that the increment is based on "b, w, l",
; so keep that in mind, for example, '.b (An)+' will change as '++An',
; but '.w (An)+' will change as 'An += sizeof(w); // An += 2'.

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; When used with SP/A7 This is effectively the 68000 POP command.
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    move.l (a1)+,d0         ; RESULT: '$F0F1F2F3'
    
    move.l a1,d7            ; RESULT: '$00FF0104' ---> An += 4 // An += sizeof(l)
                            ; That is not in the video or tutorial, but
                            ; D7 is my monitor, hehehe...
                            
; ******* NOTE: In the website he uses '.w', but i used '.l', so
;               in the tutorial he gets only '$0000F0F1', while in
;               my version it is '$F0F1F2F3'. *******

; ###############################################################
; Because A7 is the stack pointer it works differently to other
; Address registers - if we write 1 byte to A7 with Postincrement,
; it will actually move 2... This is because it needs to stay byte
; aligned to work with Words and Longs.
; ###############################################################
                            
; ####### EXAMPLE 7 - ADDRESS REGISTER WITH PRE-DECRIMENT #######

; Pretty alike 'EXAMPLE 6', but with decrement.
; Also, i'll add his A7 example in the video:
; https://youtu.be/SmrOPJbpnDw?t=764

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; When used with a WRITING command and SP/A7 This is effectively
; the 68000 PUSH command.
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    move.l -(a1),d0         ; RESULT: '$F0F1F2F3'
    
    move.l a1,d7            ; RESULT: '$00FF0100' ---> An -= 4 // An -= sizeof(l)
                            ; That is not in the video or tutorial, but
                            ; D7 is my monitor, hehehe...

; #######
; CODES HERE ARE ON THE VIDEO:
    move.l #UserRAM+$200,a2
    move.l #UserRAM+$300,a7
    move.b -(a2),d0         ; RESULT: '$00FF01FF'
                            ; A2 will be decreased by 1 byte
                            ; |___> An -= 1 // An -= sizeof(char)
    move.b -(a7),d0         ; RESULT: '$00FF02FE'
                            ; A7 will be decremented by TWO BYTES - A7 is special
    move.l a7,a3            ; RESULT: 'A3 = A7 = $00FF02FE'
; #######

; ####### EXAMPLE 8 - ADDRESS REGISTER INDIRECT, WITH 16-BIT DISPLACEMENT #######

; This is another inderect addressing mode, however with a 'fixed' displacement
; - the data is read from the Address register plus the offset - however the
; address register is unchanged.

; This is similar to (IY+n) on the Z80... It can also be used for reading values
; pushed onto the stack.

    move.b (2,A1),d0        ; RESULT: '$F0F1F2F2'
                            ; A1 maintains equal to '$00FF0100'

; In this example a byte was read from A1+2.... Note A1 was unchanged...
; The displacement does not have to be positive - it can also be negative.

; *******
; NOTE:
; * From the table in his website, there is codes that changed format,
; below it is written like this:
;   |Address register indirect, with 16-bit displacement|
;   |-------> NEW: (dd,An) | EX.: (5,A0) | OLD: d(An) <-------|
;   |Read a value from the address in A0, shifted by fixed value d|
; *******

; ####### EXAMPLE 9 - ADDRESS REGISTER INDIRECT WITH INDEXING AND 8-BIT DISPLACEMENT #######

; This is the most advanced addressing mode available... the address
; in the Address register is used PLUS the Data register PLUS a fixed
; offset ... The value is read from the resulting address...

; If you want to do a command like  (A0,D0) then use this mode with a
; ZERO displacement - eg (0,A0,D0).

; In this example D1=1 and our displacement is 2... The result is we're
; reading in from A1+3:

    clr.l d0                ; So the result is the same of his website...
    move.b (2,a1,d1),d0     ; RESULT: '$000000F3'
                            ; IMAGE:
                            ; $00FF0100 |        F0
                            ; $00FF0101 v + 2    F1
                            ; $00FF0102 v + D1   F2
                            ; $00FF0103 *        F3 <--- RESULT!
                            ; // int n = 2; a1 += n + d1; // a1 += 3;
    clr.l d7
    move.b (0,a1,d0),d7     ; RESULT: '$000000FF'

; As before A1, and D1 are unchanged by this command.

; ###############################################################
; When we specify MOVE (2,A1,D1),D0 then D1 will be treated as a
; WORD register... So if D1=$00010001 it will actually be treated
; as $0001.
; If we want to use the full Long, we need to specify the whole of
; D0 we need to specif MOVE (2,A1,D1.L),D0;
; ###############################################################

; ####### EXAMPLE 10 - PROGRAM COUNTER RELATIVE ADDRESSING WITH A 16-BIT OFFSET #######

; The 'Program Counter' is the current position in the program...
; This addressing mode allows for data to be read from and address
; relative to the program counter... This is useful for 'relocatable code'...
; Where you don't know where your program will actually end up running...

; That said, it's possible you will never need this addressing mode, so don't
; worry about it if you don't understand it!

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Note: This command can only be used for READING
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    move.w (2,pc),d0         ; RESULT: '$00000000'
                             ; IMAGE:
                             ; PC     |          ??
                             ; PC     |  + 1     ??
                             ; PC     v  + 2     68
                             ; PC * Big Endian   69
                             ; ---> RESULT: 'D0 = $'

; In this example we're going to load bytes $68 and $69 into registers
; D0 and D1...
; For D0 we're going to specify the offset as a number...

    move.w (PCTestData,pc),d0   ; RESULT: '$00006869'
    
; For D1 we'll use the more reliable option of using a label.

    move.w (8,pc),d1             ; RESULT: '$000000FF'

; ###############################################################
; It's important to bear in mind that our assembler may well be
; doing optimizations of our code, and we cannot predict how many
; bytes each command will take, therefore it's better to use a
; label to specify the offset in real word code than the (8,pc)
; we used here in this example.
; ###############################################################

; #######
;   EXAMPLE 11 - PROGRAM COUNTER RELATIVE ADDRESSING
;   WITH AN 8-BIT OFFSET PLUS AN INDEX REGISTER
; #######

; This 'Program Counter' Relative addressing mode is similar,
; however it also allows for a Data register to be added to the
; offset and the result read from the final address... The Address
; and Data register are unchanged.

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Note: This command can only be used for READING
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

; In this example we're going to load a byte from the 'Test Data'
; adding the D1 register as an offset (D1=1).

    move.l #1,d1                 ; D1 = 1;
    move.b (2,pc,d1),d0          ; RESULT: '$0000683B'
                                 ; Result in the website is '$00006869'
                                 ; and '$00000069'.

; The first time we'll do this using a label...

    move.b (PCTestData,pc,d1),d0 ; RESULT: '$0000683B'

; The second using a numerical value...
; Either way the result is the same.
; In the example we'll read a byte from the 'Test Data' - offset by
; D1 (1)... The result is we'll load in byte $69 into D0 and D2.

    move.b (8,pc,d1),d2          ; RESULT: '$0000003B'

; ###############################################################
; The PC relative modes are something you can do without - they
; were never used in Grime 68000.

; But you need to know about them as they're pretty powerful!
; They save space, and allow for relocatable code... It's also
; important to understand there are MORE addressing modes on the
; later processors... But we're only covering the 68000 in these
; tutorials.
; ###############################################################

; ###############################################################
; ###############################################################
; ###############################################################

    SIMHALT             ; halt simulator

; ###############################################################

; #####################
; ####### VARIABLES AND CONSTANTS
; #####################

TestData:
    dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
    dc.b $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF

PCTestData:
    dc.b $68,$69,$70

; ###############################################################

; ###############################################################
    END    START        ; !!!!!!! last line of source !!!!!!!
; ###############################################################
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
