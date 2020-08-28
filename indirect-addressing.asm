TITLE Random Numbers	(program04.asm)

; Author: Kevin Joy
; Last Modified: 8/2/20
; OSU email address: joyke@oregonstate.edu
; Course number/section: CS271/400
; Assignment Number: 4		       Due Date: 8/2/20
; Description: Get a user range, generate random integers in the range, display the list, sort the list in descending order
	; calulate and display the median, display the sorted list.

INCLUDE Irvine32.inc

min = 10
max = 200
lo = 100
hi = 999

.data
intro_1				BYTE	"Random Numbers by Kevin Joy",0
intro_2				BYTE	"This program will take a user input int & display random ints between 100 and 999. It will then sort the list, calculate, and display the median value. Finally it will display the sorted list in descending order.",0
prompt_1			BYTE	"How many integers do you want to generate?",0
prompt_2			BYTE    "Please enter an integer between 10 and 200: ",0
prompt_3			BYTE	"You entered an invalid number. Please enter an integer between 10 and 200: ",0
median_txt			BYTE	"The median value is ",0			
title_unsorted		BYTE	"Unsorted Array:",0
title_sorted		BYTE	"Sorted Array:",0
num_of_random		DWORD	?							; user input number integer determining number of random floating point numbers to be displayed.
rand_number_1		DWORD	?							; store the random floating point number
list				DWORD	200 Dup(0)					; initialize empty array
sorted_list			DWORD	200 Dup(0)					; initialize empty array	
list_indx			DWORD	-4							; initialize list index below 0, increment by DWORD
int_len				DWORD	0							; recursive count to determine integer length
column_buffer		DWORD	0							; spaces to print between columns
column_count		DWORD	1							; keeps track of column count for writing to console
columns				DWORD   10							; number of columns to display
highest_value		DWORD	0							; stores highest value for sort
highest_address		DWORD	?							; stores the address of highest value for sort

.code
main PROC
	call			randomize							; initialize the randomize seed
	FINIT
 
  ; displays the introduction					
	call			introduction		

  ; gets user input data						
	push			OFFSET num_of_random			
	call			getData					

  ; validates user input data					
	push			OFFSET num_of_random
	push			num_of_random					
	push			min								
	push			max									
	call			validate
	
  ; fills an array with randomly generated numbers					
	push			rand_number_1					
	push			OFFSET list							
	push			OFFSET list_indx				
	push			lo									
	push			hi								
	push			OFFSET rand_number_1				
	push			num_of_random						
	call			generateNums
			
  ; displays unsorted array in column format		
	push			columns								
	push			OFFSET column_buffer				
	push			OFFSET int_len						
	push			OFFSET column_count					
	push			num_of_random					
	push			OFFSET title_unsorted			
	push			OFFSET list						
	call			displayList			
	
  ; sorts array in descending order
	push			OFFSET highest_address				
	push			OFFSET highest_value			
	push			OFFSET list							
	push			num_of_random					
	call			sortList		

  ; calculates and displays the median
	push			num_of_random						
	push			OFFSET list							
	call			displayMedian						

	
  ; displays sorted array in column format
	push			columns								
	push			OFFSET column_buffer			
	push			OFFSET int_len						
	push			OFFSET column_count					
	push			num_of_random						
	push			OFFSET title_sorted				    
	push			OFFSET list						
	call			displayList

	


	exit	; exit to operating system
main ENDP


; description: Prints program name and programmer name.
; receives: none
; returns: none
; preconditions: none
; registers changed: edx

introduction PROC

	mov				edx, OFFSET intro_1
	call			WriteString
	call			CrLf
	call			CrLf
	mov				edx, OFFSET intro_2
	call			WriteString
	call			CrLf
	call			CrLf

	ret
introduction ENDP


; description: prompts the user to enter an integer between 10 and 200
; receives: address of the paramater passed on the stack 
; returns: user input value
; preconditions: none
; registers changed: eax, ebx, edx

getData PROC											
	push			ebp									; set up stack frame
	mov				ebp, esp
	
  ;get an integer for range
	mov				ebx, [ebp+8]						; get address of num_of_random
	mov				edx, OFFSET prompt_1
	call			WriteString
	call			CrLf
	mov				edx, OFFSET prompt_2
	call			WriteString
	call			ReadInt
	call			CrLf
	mov				[ebx], eax							; store user input at address in ebx

	pop				ebp
	ret				4
getData ENDP


; description: validates that the user input is an integer that falls between 10 and 200
; receives: value of user input, value of min, value of max, address of user input, all pushed on the stack
; returns: a valid user input integer
; preconditions: an integer value has been passed to the procedure
; registers changed: eax, ebx, ecx

validate PROC										
	push			ebp
	mov				ebp, esp

	mov				eax, [ebp+16]				; value of num_of_random
	mov				ebx, [ebp+12]				; value of min conatant
	mov				ecx, [ebp+8]				; value of max constant

	cmp				eax, ebx
	jb				invalid
	cmp				eax, ecx
	ja				invalid
	jmp				valid

invalid:
	push			[ebp+20]					; address num_of_random
	push			[ebp+16]					; value num_of_random
	push			[ebp+12]					; value of min constant
	push			[ebp+8]						; value of max constant
	call			enterAgain

valid:

	pop				ebp
	ret				16
validate ENDP


; description: validates that the user input is an integer that falls between 10 and 200
; receives: address of user input, value of user input, value of min, value of max, all pushed on stack
; returns: user input value
; preconditions: an invalid input was passed to the calling procedure
; registers changed: none (saved on stack)

enterAgain PROC										
	push			ebp
	mov				ebp, esp
	push			eax
	push			ebx
	push			edx
	
	mov				ebx, [ebp+20]						; address of num_of_random
	mov				edx, OFFSET prompt_3
	call			WriteString
	call			ReadDec
	call			CrLf
	mov				[ebx], eax							; store user input at address in ebx

	push			[ebp+20]							; address of num_of_random
	push			[ebx]								; value of num_of_random
	push			[ebp+12]							; value of min constant
	push			[ebp+8]								; value of max constant
	call			validate

	pop				edx
	pop				ebx
	pop				eax
	pop				ebp
	ret				16
enterAgain ENDP


; description: generates as user input amount of random numbers and passes them to fillArray
; receives: value of user input, address of rand_number_1, value of hi, value of low, address of list_indx, address of list, value of rand_number_1
; returns: user input amount of random numbers
; preconditions: a valid user input integer was passed to the procedure
; registers changed: eax, ecx

generateNums PROC
	push			ebp
	mov				ebp, esp

	mov				ecx, [ebp+8]						; value of num_of_random
randNumLoop:
  ; get random int
	mov				eax, [ebp+24]						; address of list_indx
	mov				ebx, 4
	add				[eax], ebx							; increment value stored at address in eax by DWORD
	mov				eax, [ebp+16]						; value of hi
	sub				eax, [ebp+20]						; value of lo	
	add				eax, 1
	call			RandomRange
	add				eax, [ebp+20]						; set base of range by value of lo
	mov				ebx, [ebp+12]						; address of rand_number_1
	mov				[ebx], eax							; value held in address stored in ebx (rand_number_1)

	mov				eax, [ebp+24]
	push			[eax]								; value of list_indx
	mov				eax, [ebp+12]
	push			[eax]								; value of rand_number_1
	push			[ebp+28]							; address of list
	call			fillArray

	loop			randNumLoop	

	pop				ebp
	ret				28
generateNums ENDP


; description: inserts integers into an array
; receives: value of list_indx, value of random_number_1, address of list
; returns: an array of integers 
; preconditions: an integer must be passed to the array
; registers changed: none (saved on stack)

fillArray PROC										
	push			ebp
	mov				ebp, esp
	push			eax
	push			ebx

	mov				eax, [ebp+16]						; value of current list_index
	add				[ebp+8], eax						; add current list_indx value to the address of the base of list array
	
	mov				eax, [ebp+8]						; address of current index in list array
	mov				ebx, [ebp+12]						; move to ebx the value of rand_number_1
	mov				[eax], ebx							; move the value of rand_number_1 to the value stored in address in eax

	pop			ebx
	pop			eax
	pop			ebp
	ret			12
fillArray ENDP


; description: displays an array of integers in 10 columns with 3 spaces between each column
; receives: number of columns, address of column_buffer, address of int_len, address of column_count, value of num_of_random, address of title text, address of list
; returns: nothing (prints to screen)
; preconditions: an array containing integers must be passed in
; registers changed: eax, ecx, ebx, edx

displayList	PROC	
	push			ebp
	mov				ebp, esp

	mov				edx, [ebp+12]					; address of title
	call			WriteString
	call			CrLf

  ; re-initialize variables 
	mov				edx, [ebp+20]
	mov				ebx, 1
	mov				[edx], ebx						; re-initialize column_count to 1

	mov				edx, [ebp+24]
	mov				ebx, 0
	mov				[edx], ebx						; re-initialize int_len to 0

	mov				edx, [ebp+28]
	mov				ebx, 0
	mov				[edx], ebx						; re-initialize column_buffer to 0

	mov				ebx, [ebp+8]					; address of base of list array
	mov				ecx, [ebp+16]					; value of numb_of_random
printLoop:
	mov				eax, [ebx]						; value held in address held in ebx (value in current list index)

  ; get len of number
	push			[ebp+24]						; pass int_len by address
	push			[ebx]							; value of current index of list
	call			int_len_recursion			
	
  ; determine number of spaces to print for column alignment
	mov				edx, [ebp+24]					; address of int_len
	push			[edx]							; value of int_len
	push			[ebp+28]						; address of column_buffer
	call			number_of_spaces_to_print


  ; print individual cell
	mov				edx, [ebp+28]					; address of column_buffer
	push			[ebp+20]						; address of column_count
	push			[ebp+32]						; value of columns
	push			[edx]							; pass value of column_buffer
	push			[ebx]							; pass value of current index of list
	call			print_cell


	add				ebx, 4							; increment array address by DWORD
	loop			printLoop

	call			CrLf
	call			CrLf

	pop				ebp
	ret				28
displayLIST ENDP


; description: recursively divide the given integer by 10 until it is less than or equal to 9. Recursion count is integer length.
; receives:  current index of list, int_len address
; returns: int_len
; preconditions: the current index in is_prime is determined to be composite, setting the bool flag is_composite to true
; registers changed: none (saved on stack)

int_len_recursion PROC
	push			ebp
	mov				ebp, esp
	push			eax
	push			ebx
	push			ecx
	push			edx

	mov				ecx, [ebp+12]					; address of int_len
	mov				edx, 0
	mov				[ecx], edx						; re-initialize int_len to 0
	mov				edx, 1
	add				[ecx],	edx						; add 1 to value of int_len
	mov				eax, [ebp+8]					; value stored in current index of list array
divide_again:
	cmp				eax, 9
	jbe				int_len_found
	mov				ebx, 10
	mov				edx, 0
	div				ebx
	mov				edx, 1
	add				[ecx], edx
	jmp				divide_again
int_len_found:

	pop				edx
	pop				ecx
	pop				ebx
	pop				eax
	pop				ebp
	ret				8
int_len_recursion ENDP


; description: calculates the number of spaces to insert between columns by subtracting integer length from 6
; receives: value of int_len, address of column_buffer
; returns: column_buffer
; preconditions: an integer must be passed into the procedure
; registers changed: none (saved to stack)

number_of_spaces_to_print PROC
	push			ebp
	mov				ebp,esp
	push			eax
	push			ebx

	mov				eax, 6								
	mov				ebx, [ebp+12]					; value of int_len
	sub				eax, ebx						; value of int_len
	mov				ebx, [ebp+8]					; address of column_buffer
	mov				[ebx], eax						; change value of column_buffer to 6 - int_len

	pop				ebx
	pop				eax
	pop				ebp
	ret				8
number_of_spaces_to_print ENDP


; description: prints each indivual cell in a column/row on the console
; receives: address of column_count, value of columns, value of column_buffer, value of integer in current index of array
; returns: nothing (writes to console)
; preconditions: columns must be determined, value of column_buffer must be determined, value of current index must be determined
; registers changed: none (saved to stack)

print_cell	PROC
	push			ebp
	mov				ebp, esp
	push			eax
	push			ebx
	push			ecx
	push			edx

	mov				eax, [ebp+8]					; value of integer in list at current index
	call			WriteDec	

	mov				ebx, [ebp+20]					; address of column_count
	mov				ecx, [ebp+12]					; value of column_buffer
col_buffer:
	mov				edx, [ebp+16]					; value of columns
	cmp				[ebx], edx						; value of current column to column count
	je				end_row
	mov				al, ' '
	call			WriteChar
	loop			col_buffer
	jmp				end_print_cell

end_row:
	mov				edx, 0
	mov				[ebx], edx						; re-initialize current column to 0 (will increment to 1 on end)
	call			CrLf
end_print_cell:
	mov				eax, 1
	add				[ebx], eax

	pop				edx
	pop				ecx
	pop				ebx
	pop				eax
	pop				ebp
	ret				16
print_cell ENDP


; description: sorts an array in descending order using selection sort
; receives: address of highest_address, address of highest_value, address of list
; returns: sorted array
; preconditions: an array must be populated first
; registers changed: eax, ebx, ecx, edx

sortList PROC
	push			ebp
	mov				ebp,esp

	mov				eax, [ebp+12]				; address of index 0 of list
	mov				ecx, [ebp+8]				; value of num
sort_loop:
	mov				ebx, eax
	mov				edx, 4						
	add				ebx, edx					; index of find_greatest loop
find_greatest:
	mov				edx, [ebx]
	cmp				[eax], edx
	jge				inc_ebx
	
	push			eax
	mov				eax, [ebp+16]				; address of highest_value
	cmp				[eax], edx					; cmp highest value in loop to current index
	pop				eax
	jge				inc_ebx

	mov				edx, [ebx]					; [ebx] is value of highest value so far
	push			eax
	mov				eax, [ebp+16]				; address of highest_value variable
	mov				[eax], edx					; move value into highest_value
	
	mov				edx, ebx					; ebx address of highest value so far in loop
	mov				eax, [ebp+20]				; address of highest_address variable
	mov				[eax], edx					; move address into highest_address
	pop				eax

inc_ebx:			
	mov				edx, 4
	add				ebx, edx
	mov				edx, 0
	cmp				[ebx], edx
	je				greatest_found
	jmp				find_greatest

greatest_found:
	mov				edx, [ebp+16]				; address of highest value in loop	
	push			[edx]						; value index j
	push			[eax]						; value index i
	mov				edx, [ebp+20]				; address of the highest address
	push			[edx]						; address index j
	push			eax							; address index i
	call			exchangeElements

	mov				edx, 4
	add				eax, edx					; increment the index of list by 1, (eax + DWORD)
	mov				edx, [ebp+16]				
	push			eax
	mov				eax, 0
	mov				[edx], eax					; reinitialize highest value to 0
	pop				eax
	mov				edx, [ebp+20]
	mov				[edx], eax					; reinitialize highest value address to begining of search index					

	loop			sort_loop
	
	pop				ebp
	ret				16
sortList ENDP


; description: swaps the values of index i and index j of an array
; receives: offset of index i, offset of index j, value at index i, value at index j
; returns: array with swaped index i and index j
; preconditions: index i and index j of an array must be determined
; registers changed: none (saved to register)

exchangeElements PROC	
	push			ebp
	mov				ebp, esp
	push			eax
	push			ebx
	push			ecx
	push			edx

	mov				eax, [ebp+8]				; address of index i
	mov				ebx, [ebp+12]				; address of index j
	mov				ecx, [ebp+16]				; value of index i
	mov				edx, [ebp+20]				; value of index j

	mov				[eax], edx
	mov				[ebx], ecx


	pop				edx
	pop             ecx
	pop				ebx
	pop				eax
	pop				ebp
	ret				16
exchangeElements ENDP


; description: finds the median value/values and calculates the median in case of being an even number of array items
; receives: address of list, number of items in list
; returns: median
; preconditions: an array must be filled and sorted
; registers changed: eax, ebx, ecx, edx

displayMedian PROC	

	push			ebp
	mov				ebp, esp

	mov				edx, OFFSET median_txt
	call			WriteString

	mov				edx, 0
	mov				ecx, 0						; use ecx to store the median
	mov				eax, [ebp+12]				; number of items
	mov				ebx, 2
	div				ebx							; median item

  ; determine if number of items was odd or even
	cmp				edx, 0						
	je				even_num

  ; adjust median position for dword index in array
	mov				ebx, 4
	mul				ebx
	mov				ebx, [ebp+8]
	add				ebx, eax

  ; print median
	mov				eax, [ebx]
	jmp				print_med

even_num:
  ; adjust median position for dword index in array
	mov				ebx, 4
	mul				ebx
	mov				ebx, [ebp+8]
	add				ebx, eax

  ; print value on right side median
	mov				al, '('
	call			WriteChar
	mov				eax, [ebx-4]					
	call			WriteDec

  ; formatting
	mov				al, ' '
	call			WriteChar
	mov				al, '+'
	call			WriteChar
	mov				al, ' '
	call			WriteChar

  ; print value on left side of median
	mov				eax, [ebx]
	call			WriteDec
	mov				al, ')'
	call			WriteChar

  ; formatting
    mov				al, ' '
	call			WriteChar
	mov             al, '/'
	call			WriteChar
	mov				al, ' '
	call			WriteChar
	mov				al, '2'
	call			WriteChar
	mov				al, ' '
	call			WriteChar
	mov				al, '='
	call			WriteChar
	mov				al, ' '
	call			WriteChar

  ; calculate median
	add				ecx, [ebx]
	add				ecx, [ebx-4]
	mov				eax, ecx
	mov				ebx, 2
	div				ebx
	cmp				edx, 0						; if even, print. if odd add 1 to round to nearest decimal
	je				print_med				
	mov				ebx, 1
	add				eax, 1

print_med:
	call			WriteDec
	mov				al, '.'
	call			WriteChar
	call			CrLf
	call			CrLf

	pop				ebp
	ret				8
displayMedian ENDP

END main
