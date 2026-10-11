.data
input_file:	.asciiz "input.txt"
buffer:		.space 2048

msg_clave:	.asciiz "Ingrese la clave: "
clave:		.space 100	# Reserva de espacio en memoria para la clave

.text
read_input:
	li $v0, 13	# Open file
	la $a0, input_file
	li $a1, 0	# Read only
	syscall
	move $s0, $v0
	
	li $v0, 14	# Read from file
	move $a0, $s0
	la $a1, buffer
	li $a2, 2048
	syscall
	move $s1, $v0	# $s1 ahora contiene la cadena a cifrar
	
	li $v0, 16	# Close file
	move $a0, $s0
	syscall
	
input_clave:
	li $v0, 4	# Print string
	la $a0, msg_clave
	syscall

	li $v0, 8	# Read string
	la $a0, clave	 
	li $a1, 100	# Caracteres máximos a leer
	syscall
	la $s2, clave	# $s2 ahora contiene la clave para el cifrado
	
read_clave:
	
	


exit:	li $v0, 10
	syscall
