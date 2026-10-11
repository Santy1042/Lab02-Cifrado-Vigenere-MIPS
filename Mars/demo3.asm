.data
input_file:	.asciiz "texto.txt"
output_file:	.asciiz "salida.txt"
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
	move $s2, $v0
	
	li $v0, 16	# Close file
	move $a0, $s0
	syscall
	
	li $v0, 13	# Open file
	la $a0, output_file
	li $a1, 1	# Wite only
	syscall
	move $s1, $v0
	
	li $v0, 15	# Write to file
	move $a0, $s1
	la $a1, buffer
	move $a2, $s2
	syscall
	
	li $v0, 16	# Close file
	move $a0, $s1
	syscall

exit:	li $v0, 10
	syscall
