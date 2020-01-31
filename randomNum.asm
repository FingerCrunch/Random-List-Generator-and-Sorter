TITLE CS271 Program 4     (randomNum.asm)

; Author: Eric Riemer
; Last Modified: 8/4/2019
; OSU email address: riemere@oregonstate.edu
; Course number/section: CS271 - 400
; Assignment Number: 4                Due Date: 8/4/2019
; Description: Generates Random Numbers

INCLUDE Irvine32.inc

;Constants
RANGE_HIGH EQU 200		;highest number of random numbers generated
RANGE_LOW EQU 15		;lowest number off random numbers generated
INT_HIGH EQU 999		;highest ranndom integer
INT_LOW EQU 100			;lowest random integer
TRUE EQU 1				;true
FALSE EQU 0				;false
ARRAY_SIZE EQU 200		;size of random number array
.data

;Variables
progTitle BYTE "Random Number Sorter",0
author	  BYTE "Programmed by Eric Riemer",0
intro1	  BYTE "This program generates random numbers in the range [100 .. 999],",0
intro2	  BYTE "displays the original list, sorts the list, and calculates the",0
intro3    BYTE "median value. Finally, it displays the list sorted in descending order.",0
range     BYTE "Please choose the number of random integers to be generated between 15 and 200.",0
error	  BYTE "Out of Range.",0
unsortedTitle BYTE "Unsorted Random Numbers:",0   
sortedTitle BYTE "Sorted Random Numbers:",0
goodbyeMessage BYTE "Thanks for using my program. Have a nice day!",0
number	  DWORD ?
array     DWORD ARRAY_SIZE DUP(?)
space     BYTE "  ",0
median    BYTE "Median: ",0
count     DWORD ?
.code
main PROC
	;Introduction
	call introduction

	;Get the Number of Integers to be displayed by user
	push OFFSET number
	call getUserData
		;calls subroutine to validate the number is in range

	;generate the number of random numbers specified and store them in an array
	push OFFSET array
	push number
	call randomGen

	;display the unsorted list of integers
	push OFFSET array
	push number
	push OFFSET unsortedTitle
	call dispList

	;sort the list in descending order (largest first)
	push OFFSET array
	push number
	call listSort
	
	;Calculate and display the median value, rounded the the nearest integer
	push OFFSET array
	push number
	call calcMedian

	;display the sorted list, 10 numbers per line
	push OFFSET array
	push number
	push OFFSET sortedTitle
	call dispList

	exit	; exit to operating system
main ENDP

;Function: prints the intro message and prompts the user to specify how many composite numbers to display
;Receives: progTitle, author, intro1, intro2, intro3
;Returns: nothing
;Preconditions: none
;Registers Altered: edx

introduction PROC
	mov edx, OFFSET progTitle
	call WriteString
	call Crlf
	mov edx, OFFSET author
	call WriteString
	call Crlf
	mov edx, OFFSET intro1
	call WriteString
	call Crlf
	mov edx, OFFSET intro2
	call WriteString
	call Crlf
	mov edx, OFFSET intro3
	call WriteString
	call Crlf
	mov edx, OFFSET range
	call WriteString
	call Crlf
	ret
introduction ENDP

;Function: gets the number of composite numbers from the user and validates its in the range 1-300
;Receives: UPPER_LIMIT, LOWER_LIMIT, TRUE, FALSE, number
;Returns: saves the validated number in the variable "number"
;Preconditions: none
;Registers Altered: eax, edx
getUserData PROC
	;...........
	push ebp
	mov ebp, esp
	pushad
	getLoop:							;loops to validate user input is between 1 and 300
		call ReadInt
		mov [ebp + 8], eax				;move user entered number into the variable "number"
		push [ebp + 8]					;push user entered number onto the stack
		call validate					;call validate procudure, which returns 1 if the number is valid, and 0 if the number is invalid

		cmp eax, FALSE					;compare eax to FALSE (0)
		je OOR							;if eax equals FALSE(ie. invalid), jump to Out of Range(OOR) label to loop again
		jmp endLoop						;else, the number is valid jump to end of procedure

		OOR:							;Out of Range Label (OOR)
			mov edx, OFFSET error		;print error message
			call WriteString
			call Crlf
			mov edx, OFFSET range		;pompt the user to enter a number between 1-300
			call WriteString
			call Crlf
			jmp getLoop					;jumps back to the top of the loop

		endLoop:

	popad	
	pop ebp
	ret 4
getUserData ENDP

;Function: validates that the user entered number is in the range 15 to 200
;Receives: number, UPPER_LIMIT, LOWER_LIMIT, TRUE, FALSE
;Returns: eax = 1 (TRUE) or eax = 0 (FALSE)
;Preconditions: none
;Registers Altered: eax
validate PROC
	;...........
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]
	getLoop:							;loops to validate user input is between 1 and 300
		cmp eax, RANGE_LOW				;compare user input to 1
		jl OOR							;if user input is less than 1, jump to Out of Range(OOR) label
		cmp eax, RANGE_HIGH	    		;compare user input to 300
		jg OOR							;if user input is greater than 300, jump to Out of Range(OOR) label
		jmp endLoop

		OOR:							;Out of Range Label (OOR)
			mov eax, FALSE				;INVALID DATA (SET EAX = 0)
			jmp return

		endLoop:
			mov number, eax				;stores the value in eax to the variable "number"
			mov eax, TRUE

		return:

		pop ebp
		ret 4
validate ENDP

;Function: generates random numbers and stores them in an array
;Receives: number (value), array (reference), count
;Returns: 
;Preconditions: none
;Registers Altered: ecx, ebp, esi, eax
randomGen PROC
	;...........
	push ebp
	mov ebp, esp
	pushad
	call Randomize						;initializes the starting seed value of RandomRange
	mov ecx, [ebp + 8]					;sets loop counter equal to the number of random numbers to be generated
	mov esi, [ebp + 12]					;sets esi to base offset of the array
	L1:
		loopAgain:
			mov eax, INT_HIGH
			call RandomRange			;generates a random number less than 999 and puts it in eax
			cmp eax, INT_LOW
			jl	loopAgain				;loops again if number is less than 100
			mov [esi], eax				;moves random number from eax into the array
			add esi, TYPE DWORD			;move to next element in array
			loop L1						;loops L1
	popad
	pop ebp
	ret 8
randomGen ENDP

;Function: displays the list of random numbers
;Receives: number (value), array (reference), unsortedTitle (reference)
;Returns: prints numbers in array to screen
;Preconditions: none
;Registers Altered: edx, ecx, esi, eax
dispList PROC
	;...........
	push ebp
	mov ebp, esp
	pushad
	mov count, 0				;sets new line counter
	mov edx, [ebp + 8]			;prints the title message
	call WriteString
	call Crlf
	mov ecx, [ebp + 12]			;set the loop counter to the number of items in the array
	mov esi, [ebp + 16]			;move the offset of the array into esi
	Looper:
		mov eax, [esi]			;move the element in the array to eax
		call WriteDec			;print the current element in the array
		mov edx, OFFSET space	;print a space between numbers
		call WriteString
		add esi, TYPE DWORD		;move to next element in array
		inc count
		mov eax, count
		mov edx, 0								
		mov ebx, 10	
		div ebx							;divide the composite number count by 10 to determine if it is divisible by 10
		cmp edx, 0						;if the composite number % 10 equals 0, print new line
		jne nextLoop					;else, loop again
		call Crlf
		nextLoop:
		loop Looper
	call Crlf
	popad
	pop ebp
	ret 12
dispList ENDP

;Function: sorts the list in descending order
;Receives: number (value), array (reference)
;Returns: array sorted in descending order
;Preconditions: none
;Registers Altered: ecx, esi
;Sources Referenced: 
;		Title: Assembly Language for x86 Processors, 7th Edition
;		Author: Irvine, Kip
;		Chapter: 9.5
;		Page: 375
;		Program Title: BubbleSort

listSort PROC
	push ebp
	mov ebp, esp
	pushad
	mov ecx, [ebp + 8]			;set loop counter
	dec ecx						;decrement the count by 1
	Lbl1:
		push ecx				;save the outer loop counter
		mov esi, [ebp + 12]		;set esi to first element in array

	Lbl2:
		mov eax, [esi]			;move the element in the array to eax
		cmp [esi + 4], eax		;compare the current element to the next element in the array
		jl Lbl3					;if current element is less than the next element, don't do anything and loop again
		xchg eax, [esi + 4]		;else, swap the elements
		mov [esi], eax			

	Lbl3:
		add esi, 4				;move to next element in the array
		loop Lbl2				;loop the inner loop

		pop ecx					;pop outer loop counter into ecx
		loop Lbl1				;loop the outer loop

	popad
	pop ebp
	ret 8
listSort ENDP

;Function: calculates the median of a sorted list
;Receives: number (value), array (reference)
;Returns: array sorted in descending order
;Preconditions: none
;Registers Altered: ecx, esi, eax, ebx
calcMedian PROC
	;...........
	push ebp
	mov ebp, esp
	mov edx, OFFSET median		;print median message
	call WriteString

	mov esi, [ebp + 12]			;set esi to the first element in the array
	mov edx, 0					;clear edx
	mov eax, [ebp + 8]			;move the number of elements into eax
	mov ecx, 2					;divide the number of elements in the array by 2
	div ecx

	cmp edx, 0					;check if quotient is even
	je evenMedian				;if even, jump to even median label

	mov ebx, 4					;multiply quotient by 4 to find the median element location in array
	mul ebx
	add esi, eax				;add the offset of the median element, setting esi to the location of the median 
	mov eax, [esi]				;move the median into eax to be printed
	call WriteDec
	call Crlf

	
	evenMedian:
		mov ebx, 4				;multiply quotient by 4 to find the 2nd median element location in array
		mul ebx					
		add esi, eax			;add the offset of the 2nd median element, setting esi to the location of the 2nd median 
		mov eax, [esi]			;move the second median into eax
		mov ebx, [esi - 4]		;move the first median into ebx
		add eax, ebx			;add the first and second medians
		mov ebx, 2				;divide by 2
		div ebx
		cmp edx, 1				;if the remainder is 1, jump to round up label
		je roundUp
		call WriteDec			;else, print the median
		call Crlf
		jmp return

	roundUp:
		inc eax					;round the median value up
		call WriteDec			;print the meidan value
		call Crlf

	return:

	pop ebp
	ret 8
calcMedian ENDP

;Function: prints goodbye message
;Receives: goodbyeMessage 
;Returns: nothing
;Preconditions: none
;Registers Altered: edx
goodbye PROC
	;...........
	call Crlf
	mov edx, OFFSET goodbyeMessage	;prints goodbye message
	call WriteString
	call Crlf
	ret
goodbye ENDP

END main

