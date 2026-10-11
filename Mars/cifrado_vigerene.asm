.data
input_file:	.asciiz "input.txt"
buffer:		.space 2048

msg_clave:	.asciiz "Ingrese la clave: "
clave:		.space 100	# Reserva de espacio en memoria para la clave

# $s1 contiene la cadena a cifrar
# $s2 contiene la clave para el cifrado
# $s3 contiene la longitud de la clave
# $s4 contiene la direccion base de la clave

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
	la $s4, clave
	
	la $t0, clave	# Carga la dirección base de la clave
	li $t2, 10
	
long_clave:
	lb $t1, 0($t0)
	beq $t1, $t2, prep_cifrado	# Compara si hay salto de linea, de serlo, es que acabo la clave o es nula la longitud
	beq $t1, $zero, prep_cifrado	# Compara si hay terminador nulo, de serlo, es que acabo la clave
	addi $t0, $t0, 1
	addi $s3, $s3, 1		# $s3 ahora contiene la longitud de la clave
	j long_clave
	
prep_cifrado:
	la $t0, clave	# Vuelve a la dirección base de la clave
	la $t1, buffer	# Vuelve a la dirección base de la cadena
	
	li $t8, 0	# Contador longitud clave
	li $t9, 0	# Contador longitud palabra
	
cifrar:	
	beq $t9, $s1, exit	# Compara si se llego al final de la cadena, de serlo se acaba la ejecucion (temporal)
	beq $t8, $s3, reset	# Compara si se llego al final de la clave, de serlo se vuelve a la direccion base
	
	lb $t2, 0($t0)	# Lee el byte de la clave
	lb $t3, 0($t1)	# Lee el byte de la cadena
	
	# Se resta 97 a ambas para obtener valores entre 0-25
	addi $t4, $t2, -97	
	addi $t5, $t3, -97	
	# $t2 y $t3 contienen valores de 0-25 (alfabeto) mientras que $t0 y $t1 contienen el caracter
	
	add $t6, $t4, $t5	# Suma de los valores de 0-25
	
	slti $t7, $t6, 26	# Compara si la suma es menor a 26
	bne $t7, $zero, volver_ascii
	addi $t6, $t6, -26
	
	volver_ascii: addi $t6, $t6, 97		# Se suma nuevamente 97 para volver a la codificacion ascii
	
	li $v0, 11	# Se carga el servicio 11 encargado de imprimir un caracter
	move $a0, $t6	# Se mueve el valor del caracter a $a0
	syscall
	
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j cifrar
	
	# Se aumenta en 1 tanto los contadores como las direcciones para que pueda seguir su camino
	
	reset:
	la $t0, clave	# Se devuelve $t0 a la dirección base de la clave
	li $t8, 0	# Se carga ese primer byte de la clave
	j cifrar		# Continua cifrando
	

exit:	li $v0, 10
	syscall
