# HW2: Insertion Sort 
# Veronica Shei

.data
prompt1: 	.asciiz "\nInitial array is: "
prompt2: 	.asciiz "\nInsertion sort is finished!"
left_bracket: 	.asciiz "\n[ "
right_bracket: 	.asciiz "]"
space: 	.asciiz " "
	
# char * data[] = {"Joe", "Jenny", "Jill", "John", "Jeff", "Joyce",
#		"Jerry", "Janice", "Jake", "Jonna", "Jack", "Jocelyn",
#		"Jessie", "Jess", "Janet", "Jane"};

	.align 5
array:	.asciiz "Joe"		# create the array
	.align 5
	.asciiz "Jenny" 
	.align 5
	.asciiz "Jill"
	.align 5
	.asciiz "John"
	.align 5
	.asciiz "Jeff"
	.align 5
	.asciiz "Joyce"
	.align 5
	.asciiz "Jerry"
	.align 5
	.asciiz "Janice"
	.align 5
	.asciiz "Jake"
	.align 5
	.asciiz "Jonna"
	.align 5
	.asciiz "Jack"
	.align 5
	.asciiz "Jocelyn"
	.align 5
	.asciiz "Jessie"
	.align 5
	.asciiz "Jess"
	.align 5
	.asciiz "Janet"
	.align 5
	.asciiz "Jane"
	.align 5
	.word 0
	
	.align 2		# addresses should start on a word boundary
array_pointer: .space 64	# 16 pointers to strings: 16*4 = 64
array_pointer_end:		# points to the end of the ptr array
				# 16 words in the array, sets up an array of pointers
				# to each data segment

# int size = 16;
size: 	.word 16

# int i, j;
# int i and j for the for loops in insertSort
i: 	.word array_pointer	# pointer for the element currently being sorted
j: 	.word array_pointer	# pointer for the position of i

.text
# int main(void)
main:
# char * data[] = {"Joe", "Jenny", "Jill", "John", "Jeff", "Joyce",
#		"Jerry", "Janice", "Jake", "Jonna", "Jack", "Jocelyn",
#		"Jessie", "Jess", "Janet", "Jane"};
# int size = 16;
# initialize the space so that each word 
# points to the address of the next string found in the array
la	$t0, array_pointer	# load the array_pointer into $t0
la	$t1, array_pointer_end	# load the end of the array into $t1
la	$t2, array		# load the array into $t2

initialize_pointer:
sw	$t2, 0($t0)			# store the first element from the array into $t2
addi	$t0, $t0, 4			# increment the pointer to point to the next string
addi	$t2, $t2, 32			# increment to the next element in the data
blt	$t0, $t1, initialize_pointer	# branch to target if  $t0 < $t1, recursive call to initialize_pointer
					# checks to see whether or not the array has ended
# printf("Initial array is:\n");
la	$a0, prompt1			# load the first prompt into $a0 for printing
li	$v0, 4				# print_string syscall
syscall					# run the syscall

# print the size
lw	$a0, size			# load the size into $a0 for printing
li	$v0, 1				# print_int syscall
syscall					# run the syscall

# print_array(data, size);
la	$a1, array_pointer		# tells the program the max. # of characters to read
jal 	print

# insertSort(data, size);
jal	insertion_sort			# jumps to the insertion sort function to sort the array

# printf("Insertion sort is finished!\n");
la	$a0, prompt2			# load prompt2 into $a0 for printing
li	$v0, 4				# print_string syscall
syscall					# run the syscall

# print_array(data, size);
la	$a1, array_pointer		# tells the program the max. # of characters to read
jal	print				# jump to the print function

main_exit:
# exit(0);
li	$v0, 10				# exit syscall
syscall					# run the syscall

# void print_array(char * a[], const int size);
print: 
# int i=0;
print_prolog:
subi	$sp, $sp, 16		# subtract 16 from the stack pointer to allocate space for 4 registers
sw	$ra, 12($sp)		# save the return address

# printf("[");
# prints the left bracket
la	$a0, left_bracket	# load the left_bracket into $a0 for printing
li	$v0, 4			# print_string syscall
syscall				# run the syscall

print_program:
# while(i < size)
# checks to see if the array has hit the end
la	$t1, array_pointer_end	# load the end of the array into $t1
beq	$a1, $t1, print_epilog	# if the end of the array (i) equals 
				# the max # of characters (size) jump to print_epilog

# printf("  %s", a[i++]);
# prints each string
la	$a0, ($a1)		# load the address of array_pointer into $a0
lw	$a0, ($a0)		# load the value of array_pointer into $a0
li	$v0, 4			# print_string syscall
syscall				# run the syscall

# adds a space
la	$a0, space		# load spaces into $a0 for printing
li	$v0, 4			# print_string syscall
syscall

# i++, increment the i for the while loop
addi	$a1, $a1, 4		# increment the array pointer by 4 to point to the next element
b	print_program		# recrusive call to the print_program branch to keep running the while loop

print_epilog:
# printf(" ]\n");
# prints the right bracket
la	$a0, right_bracket	# loads the right_bracket into $a0 for printing
li	$v0, 4			# print_string syscall
syscall				# run the syscall

lw	$ra, 12($sp)		# restore the return address from 12($sp) to $ra
addi	$sp, $sp, 16		# move the stack pointer back to the original location, pop the stack
jr	$ra			# return to the next instruction that was saved in print_prolog

# void insertSort(char *a[], size_t length) {
insertion_sort:
insert_prolog:
subi	$sp, $sp, 16		# move the stack pointer by -16 to accomodate for 4 registers
sw	$ra, 12($sp)		# store the return address

insert_program:
# for(i = 1; i < length; i++) {
outer_loop:	
# uses i to iterate through the address of each element currently being sorted
# i < length
la	$t0, i			# load the address of i into $t0
lw	$t0, ($t0)		# load the contents of i into $t0
la	$t1, array_pointer_end	# load the end of the array
beq	$t0, $t1, insert_epilog	# if i equals the length of the array jump out of the for loop

# j = i-1;
la	$t0, i			# load the address of i into $t0
lw	$t0, ($t0)		# load the contents of i into $t0
sw	$t0, j			# stores j into $t0 for the inner for loop

# i++
la	$t0, i			# load the address of i into $t0
lw	$t0, ($t0)		# load the contents of i into $t0
addi	$t0, $t0, 4		# increment i by 4 to move to the next element
sw	$t0, i			# stores the location of i into $t0

# for (j = i-1; j >= 0 && str_lt(value, a[j]); j--) {
inner_loop:
# iterates through the array to find where to insert the element
# j >= 0
lw	$t0, j			# get the address of j in the array_pointer
la	$t1, array_pointer	# load the array_pointer into $t1
ble	$t0, $t1, outer_loop	# exit the inner_loop if  $t0 <= $t1, i.e. if j is <= array_pointer

# str_lt(value, a[j]);
# compare the two strings to see if this is the right place to insert the string
lw	$t0, j			# get the address of j in the array_pointer
subi	$t1, $t0, 4		# go to the address right before j, i.e. the element before j
lw	$t2, ($t0)		# address in array_pointer, which is where j is located
lw	$t3, ($t1)		# the previous address in array_pointer, which is what j is being compared to

# int str_lt (char *x, char *y) {
# for (; *x!='\0' && *y!='\0'; x++, y++) {
li	$t6, 0			# load the value of 0 into $t6, base value for us to keep track of 
				# the number of times we've looped through compare_strings
compare_strings:
lb	$t4, ($t2)		# value of j in the array
lb	$t5, ($t3)		# value of j-1 in the array to compare with the value of j

# if ( *x < *y ) return 1;
blt	$t4, $t5, switch	# if the value at j is higher than switch the order of the two elements
# if ( *y < *x ) return 0;
bgt	$t4, $t5, outer_loop	# if the value at j-1 is greater then break out of the inner loop
				# if the values are equal, incerement x to continue checking characters
				# in the array
				
# x++
addi	$t2, $t2, 1		# increment the character at j by 1 for the next comparision

# y++
addi	$t3, $t3, 1		# increment the character at j-1 by 1 for the next comparision
addi	$t6, $t6, 1		# counter to keep track of the # of times compare_strings has run

# *y!='\0';
bge	$t6, 9, outer_loop	# if $t6 is equal to the max. # of comparisions break out into the outer loop
b	compare_strings		# recursive call to compare_strings to compare the next elements

switch:
# a[j+1] = a[j];
# inserts the element at the right place
sub	$t2, $t2, $t6		# realign back to the beginning of the word for the element at j
sub	$t3, $t3, $t6		# realign back to the beginning of the word for the element at j-1
sw	$t2, ($t1)		# switch the addresess 
sw	$t3, ($t0)		# switch the addresses

#j--
la	$t0, j			# load the address of j into $t0
lw	$t0, ($t0)		# load the contents of j into $t0
subi	$t0, $t0, 4		# decrease j down to the next element
sw	$t0, j			# store the new location of j
b	inner_loop		# recursive call to loop through the inner_loop again

insert_epilog:
lw	$ra, 12($sp)		# restore the return address from 12($sp) to $ra
addi	$sp, $sp, 16		# return the stack pointer to the original location, pop the stack
jr	$ra			# jump to the return address, i.e. the previous function





