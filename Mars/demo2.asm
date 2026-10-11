.data
input_file:	.asciiz "texto.txt"
buffer:		.space 2048

.text
main:	li $v0, 13	# Open file
	la $a0, input_file
	li $a1, 0	# Read only
	syscall
	move $s0, $v0
	
	li $v0, 14	# Read from file
	move $a0, $s0
	la $a1, buffer
	li $a2, 2048
	syscall
	
	li $v0, 16	# Close file
	move $a0, $s0
	syscall
	
	


exit:	li $v0, 10
	syscall