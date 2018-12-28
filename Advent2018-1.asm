*************************
*Advent of Code 2018 #1	*
*	Nightfox			*
*************************

; Input is a list of numbers prefaced with +/- for each number separated 
; By new line characters
; Output is the total sum, saved to memory location labelled "output"

bufferSize = 4096		Assume the input file doesn't exceed 4096 bytes 

start:
	clr.l d0
	move.l 4,a6
	lea dosName,a1
	jsr -552(a6) 		OpenLibrary dos.library
	move.l d0,dosBase
	move.l d0,a6
	move.l #inputFile,d1	Filename to open
	move #1005,d2		Open existing file -- error if doesn't exist
	jsr -30(a6)		Open file
	tst d0
	beq exit		If we can't open the file, exit program please
	move.l d0,inputFileHandle
	move.l d0,d1
	move.l #inputBuffer,d2
	move.l #bufferSize,d3
	jsr -42(a6)		Read file and save to buffer

initLoop:
	clr.l d0		D0 is the accumulator
	lea inputBuffer,a0	A0 is the current character pointer
	
readLoop:
	clr.l d2		D2 is the current number
	move.b (a0)+,d1		Load char into D1 then increment buffer pointer
	beq.w closeFile		If end of file, close the file
	cmp.b #'+',d1		If we see a +,
	beq.w add		Then jump to add routine
	cmp.b #'-',d1		If we see a -,
	beq.w subtract		Then jump to subtract routine
	bra.w closeFile		Else, we just close (error in input file) 

add:
	bsr.w loadNumber
	add.l d2,d0		Add the number to the accumulator
	tst.b d1		Check the current character
	bne.w readLoop		If it's not 0 (null) then process next datum
	bra.w closeFile		Else we are done

subtract:
	bsr.w loadNumber
	sub.l d2,d0		Subtract the number from the accumulator
	tst.b d1		Check the current character
	bne.w readLoop		If it's not 0 (null) then process next datum
	bra.w closeFile		Else we are done

loadNumber:
	move.b (a0)+,d1		Load next character
	cmp.b #'0',d1		
	bhs .isNumber		If number >= '0' continue number processing
	rts			Else return
.isNumber:
	mulu #10,d2		Multiply current num by 10 to insert the new #
	sub.b #$30,d1		Subtract $30 to convert char to int
	add.b d1,d2		Add numbers together
	bra.w loadNumber	Loop to process next number

closeFile:
	move.l d0,output
	move.l inputFileHandle,d1
	jsr -36(a6)		Close file

exit:
	move.l 4.w,a6
	move.l dosBase,a1 		
	jsr -414(a6)		CloseLibrary dos.library
	clr.l d0		Return 0
	rts			Exit program

inputFile:
	dc.b 'DF0:input.txt',0 	Assume we have input.txt on root of floppy 

inputBuffer:
	dcb.b bufferSize,0

	EVEN
output:
	dc.l 0

inputFileHandle:
	ds.l 1

bufferOffset:
	dc.w 0

dosBase:
	ds.l 1

dosName:
	dc.b 'dos.library',0

