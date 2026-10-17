.data
input_file:		.asciiz "input.txt"
criptogram_file:	.asciiz "criptogram.txt"
output_file:		.asciiz "deciphered.txt"
buffer:			.space 2048
output_buffer:		.space 2048

msg_menu:	.asciiz "\n------------------------------------------------------------------------------------\n MENU \n 1). Cifrar \n 2). Descifrar \n 3. Salir \n ------------------------------------------------------------------------------------"
msg_option:	.asciiz "\n\nIngrese una opcion: "
msg_clave:	.asciiz "Ingrese la clave: "

msg_error_apertura: .asciiz "Error: no se pudo abrir el archivo.\n"

clave:		.space 100	# Reserva de espacio en memoria para la clave

# $s1 contiene la cadena a cifrar
# $s2 contiene la clave para el cifrado
# $s3 contiene la longitud de la clave
# $s4 contiene la direccion base de la clave
# $s5 contiene el criptograma
# $s6 contiene la cadena cifrada

.text

# ------------------------------------------------------------------------------------
#	MENU
# ------------------------------------------------------------------------------------	
menu:
	li $v0, 4	# Print string
	la $a0, msg_menu
	syscall
	
	li $v0, 4	# Print string
	la $a0, msg_option
	syscall
	
	li $v0, 5	# Read integer
	syscall
	move $s7, $v0	# $s7 ahora contiene la opción

	li $t0, 1	
	
	beq $s7, $t0, opt_cifrar
	addi $t0, $t0, 1
	
	beq $s7, $t0, opt_descifrar
	addi $t0, $t0, 1
	
	beq $s7, $t0, exit
	j menu
	
opt_cifrar:
	la $a0, input_file # Nombre del archivo a leer
	jal read_archivo
	
	jal input_clave
	
	la $t0, clave	# Vuelve a la dirección base de la clave
	la $t1, buffer	# Vuelve a la dirección base de la cadena
	la $s5, output_buffer # Dirección base del buffer para el archivo de salida
	li $t8, 0	# Contador longitud clave
	li $t9, 0	# Contador longitud palabra
	jal procesar
	
	la $a0, criptogram_file # Nombre del archivo a escribir
	jal write_archivo
	
	j exit
	
opt_descifrar:
	la $a0, criptogram_file
	jal read_archivo
	
	jal input_clave
	
	la $t0, clave	# Vuelve a la dirección base de la clave
	la $t1, buffer	# Vuelve a la dirección base de la cadena
	la $s5, output_buffer # Dirección base del buffer para el archivo de salida
	li $t8, 0	# Contador longitud clave
	li $t9, 0	# Contador longitud palabra
	jal procesar
	
	la $a0, output_file
	jal write_archivo
	
	j exit
	
# ------------------------------------------------------------------------------------
#	ARCHIVOS ENTRADA
# ------------------------------------------------------------------------------------
# Función encargada de abrir y leer un archivo

read_archivo:		
	li $v0, 13	# Syscall para abrir el archivo
			# El nombre del archivo se envia desde el jal
	li $a1, 0	# Modo de read-only (Solo lectura)
	syscall
	move $s0, $v0	
	
	li $t7, -1
	beq $v0, $t7, error_apertura
	
	li $v0, 14	# Syscall para leer el contenido del archivo
			# El identificador del archivo ya está en $a0
	la $a1, buffer
	move $a0, $s0 
	li $a2, 2048
	syscall
	move $s1, $v0	# $s1 ahora tiene el contenido del archivo
	
	li $v0, 16
	move $a0, $s0 	# Syscall para cerrar el archivo cuando temrinamos de usarlo
	syscall
	jr $ra
	
# ------------------------------------------------------------------------------------
#	CLAVE
# ------------------------------------------------------------------------------------		
	
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
	li $s3, 0
	
long_clave:
	lb $t1, 0($t0)
	beq $t1, $t2, final_clave	# Compara si hay salto de linea, de serlo, es que acabo la clave o es nula la longitud
	beq $t1, $zero, final_clave	# Compara si hay terminador nulo, de serlo, es que acabo la clave
	addi $t0, $t0, 1
	addi $s3, $s3, 1		# $s3 ahora contiene la longitud de la clave
	j long_clave
	
final_clave:
	jr $ra
	
# ------------------------------------------------------------------------------------
#	PROCESAMIENTO DE CARACTERES
# ------------------------------------------------------------------------------------	

procesar:	
	beq $t9, $s1, fin_procesar	# Compara si se llego al final de la cadena, de serlo, vuelve para continuar el proceso
	beq $t8, $s3, reset	# Compara si se llego al final de la clave, de serlo se vuelve a la direccion base
	
	lb $t2, 0($t0)	# Lee el byte de la clave
	lb $t3, 0($t1)	# Lee el byte de la cadena
	
	 # Preservar tabulador (ASCII 9)
    	li   $t7, 9
    	beq  $t3, $t7, copiar_control

    	# Preservar salto de linea (ASCII 10)
    	li   $t7, 10
    	beq  $t3, $t7, copiar_control

    	# Preservar retorno de carro (ASCII 13)
    	li   $t7, 13
    	beq  $t3, $t7, copiar_control
	
	# Se resta 97 a ambas para obtener valores entre 0-25
	addi $t4, $t2, -32	
	addi $t5, $t3, -32	
	# $t2 y $t3 contienen valores de 0-25 (alfabeto) mientras que $t0 y $t1 contienen el caracter
	
	li $t7, 1	# Se compara la opción que se escogió para un camino u otro
	beq $s7, $t7, cifrar	# Si la opciòn es 1, se cifra la letra, si no, se descifra
	
	sub  $t6, $t5, $t4	# Proceso de descifrar
    	slt  $t7, $t6, $zero
    	beq  $t7, $zero, volver_ascii
    	addi $t6, $t6, 95
    	j volver_ascii
    	
cifrar:
	add  $t6, $t4, $t5	# Proceso de cifrar
    	slti $t7, $t6, 95
    	bne  $t7, $zero, volver_ascii
    	addi $t6, $t6, -95
	
volver_ascii: 
	addi $t6, $t6, 32		# Se suma nuevamente 97 para volver a la codificacion ascii
	
	sb $t6, 0($s5)
	addi $s5, $s5, 1
	
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j procesar
	
	# Se aumenta en 1 tanto los contadores como las direcciones para que pueda seguir su camino
	
copiar_control:
    sb   $t3, 0($s5)
    addi $s5, $s5, 1
    addi $t1, $t1, 1
    addi $t9, $t9, 1
    j    procesar

reset:
	la $t0, clave	# Se devuelve $t0 a la dirección base de la clave
	li $t8, 0	# Se carga ese primer byte de la clave
	j procesar

fin_procesar:
	jr $ra
	
# ------------------------------------------------------------------------------------
#	ARCHIVOS SALIDA
# ------------------------------------------------------------------------------------	
	
write_archivo:
	li $v0, 13	# Se abre el archivo como escritura-crear (write-create)
			# El nombre del archivo se envia desde el jal
	li $a1, 1	# Modo de write-create (Leer y crear)
	syscall
	move $a0, $v0
	
	li $t7, -1
	beq $v0, $t7, error_apertura
	
	li $v0, 15	# Syscall para escribir en el archivo el cifrado que se obtuvo 
			# El identificador del archivo ya está en $a0
	la $a1, output_buffer
	move $a2, $t9	# Cantidad de caracteres que se cifraron, obntenidos anteriromente
	syscall
	
	li $v0, 16	# Syscall para cerrar el archivo cuando temrinamos de usarlo
	syscall
	jr $ra
	
# ------------------------------------------------------------------------------------
#	SALIDA && MENSAJES
# ------------------------------------------------------------------------------------	
error_apertura:
    li $v0, 4
    la $a0, msg_error_apertura
    syscall
    j menu

exit:	li $v0, 10
	syscall
