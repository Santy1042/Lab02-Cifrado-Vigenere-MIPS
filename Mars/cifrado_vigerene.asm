.data
input_file:	.asciiz "input.txt"
buffer:		.space 2048

msg_clave:	.asciiz "Ingrese la clave: "
clave:		.space 100	# Reserva de espacio en memoria para la clave


# $s1 contiene la cadena a cifrar
# $s2 contiene la clave para el cifrado
# $s3 contiene la longitud de la clave
# 

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
	
	
	la $t0, clave	# Carga la dirección base de la clave
	li $t2, 10
	
long_clave:
	lb $t1, 0($t0)
	beq $t1, $t2, cifrar	# Compara si hay salto de linea, de serlo, es que acabo la clave o es nula la longitud
	beq $t1, $zero, cifrar	# Compara si hay terminador nulo, de serlo, es que acabo la clave
	addi $t0, $t0, 1
	addi $s3, $s3, 1		# $s3 ahora contiene la longitud de la clave
	j long_clave
	
	
cifrar:
	lb $t0, clave	# Vuelve a la dirección base de la clave
	lb $t1, buffer	# Lee el primer byte de la cadena a cifrar

	addi $t2, $t0, -97	# Se resta 97 a ambas para obtener valores entre 0-25
	addi $t3, $t1, -97	# $t2 y $t3 contienen valores de 0-25 (alfabeto) mientras que $t0 y $t1 contienen el caracter
	
	add $t4, $t2, $t3	# Suma de los valores de 0-25
	
	slti $t5, $t4, 26	# Compara si la suma es mayor a 26
	bne $t5, $zero, volver_ascii
	addi $t4, $t4, -26
	
	volver_ascii: addi $t4, $t4, 97		# Se suma nuevamente 97 para volver a la codificacion ascii
	
	li $v0, 11	# Se carga el servicio 11 encargado de imprimir un caracter
	move $a0, $t4	# Se mueve el valor del caracter a $a0
	syscall

exit:	li $v0, 10
	syscall
