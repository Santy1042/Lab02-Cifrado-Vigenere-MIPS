.data
input_file:		.asciiz "input.txt"		# Archivo del cual se va a extraer la cadena a cifrar
criptogram_file:	.asciiz "criptogram.txt"	# Archivo en que se guardara la cadena cifrada
output_file:		.asciiz "deciphered.txt"	# Archivo en el cual se guardara la cadena descifrada

buffer:			.space 2049	# Buffer maximo de 2048 bytes, un byte mas para comprobar desbordamientos
output_buffer:		.space 2048

msg_menu:	.asciiz "\n------------------------------------------------------------------------------------\n MENU \n 1). Cifrar \n 2). Descifrar \n 3). Salir \n ------------------------------------------------------------------------------------"
msg_option:	.asciiz "\n\nIngrese una opcion: "
msg_clave:	.asciiz "Ingrese la clave: "	

msg_opcion_invalida: .asciiz "\n[Error]: Opcion invalida. Intenta de nuevo.\n"
msg_error_apertura: .asciiz "\n[Error]: no se pudo abrir el archivo.\n"
msg_archivo_grande: .asciiz "\n[Error]: el archivo supera los 2048 bytes.\n"
msg_archivo_vacio: .asciiz "\n[Error]: el archivo esta vacio.\n"
msg_clave_vacia: .asciiz "\n[Error]: la clave no puede estar vacia.\n"
msg_clave_max: .asciiz "\n[Error]: la clave no puede superar los 100 caracteres.\n"
msg_error_escritura: .asciiz "\n[Error]: no se pudo escribir en el archivo.\n"

msg_exito_cifrado:	.asciiz "\n[Exito] Mensaje cifrado y guardado correctamente en criptogram.txt\n"
msg_exito_descifrado:	.asciiz "\n[Exito] Criptograma descifrado y guardado correctamente en deciphered.txt\n"
msg_salida:		.asciiz "\nSaliendo del programa...\n"

clave:		.space 101	# Clave maxima de 100 bytes, un byte mas para comprobar desbordamientos

# $s0 contiene el identificador del archivo dependiendo lo que se quiera hacer (Cifrar o Descifrar)
# $s1 contiene la cantidad de caracteres/bytes leídos del archivo (longitud de la cadena)
# $s2 contiene la dirección base de la clave en memoria
# $s3 contiene la longitud de la clave
# $s5 contiene la dirección en memoria del buffer de salida (output_buffer)
# $s7 contiene la opción elegida en el menú

.text

# ------------------------------------------------------------------------------------
#	MENU
# ------------------------------------------------------------------------------------	
menu:
	li $v0, 4	# Imprime el mensaje del menu
	la $a0, msg_menu
	syscall
	
	li $v0, 4	# Imprime el mensaje para pedir una opción
	la $a0, msg_option
	syscall
	
	li $v0, 5	# Lee la opción
	syscall
	move $s7, $v0	# $s7 ahora contiene la opción

	li $t0, 1	# Se carga un registro temporal para comparar
	
	beq $s7, $t0, opt_cifrar 	# Se compara si es 1 (Cifrar), si no, sigue
	addi $t0, $t0, 1
	
	beq $s7, $t0, opt_descifrar	# Se compara si es 2 (Descifrar), si no, sigue
	addi $t0, $t0, 1
	
	beq $s7, $t0, exit		# Se compara si es 3 (Salir), si no, la opción es invalida y le envía a un mensaje
	j opcion_invalida
	
opt_cifrar:
	la $a0, input_file 	# Se envía el nombre del archivo a leer
	jal read_archivo		# Se lee el archivo
	
	jal input_clave		# Si la lectura de archivo tiene exito, se pìde la clave
	
	# Se preparan todos los registros necesarios para el cifrado
	
	la $t0, $s2	# Dirección base de la clave
	la $t1, buffer	# Dirección base de la cadena
	la $s5, output_buffer # Dirección base del buffer para el archivo de salida
	li $t8, 0	# Contador longitud clave
	li $t9, 0	# Contador longitud palabra
	jal procesar	# Procesamiento de la cadena con la clave, en este caso, cifrando
	
	la $a0, criptogram_file		# Se envía el nombre del archivo a escribir
	jal write_archivo		# Se escribe el resultado (Criptograma) en el archivo
	
	li $v0, 4			# Imprime el mensaje de exito si todo lo anterior se hizo correctamente
	la $a0, msg_exito_cifrado	
	syscall
	
	j menu		# Vuelve al menú para elegir otra opción
	
opt_descifrar:
	la $a0, criptogram_file		# Se envía el nombre del archivo a leer
	jal read_archivo			# Se lee el archivo
	
	jal input_clave			# Si la lectura de archivo tiene exito, se pìde la clave
	
	# Se preparan todos los registros necesarios para el cifrado
	
	la $t0, $s2	# Dirección base de la clave
	la $t1, buffer	# Dirección base de la cadena
	la $s5, output_buffer # Dirección base del buffer para el archivo de salida
	li $t8, 0	# Contador longitud clave
	li $t9, 0	# Contador longitud palabra
	jal procesar	# Procesamiento de la cadena con la clave, en este caso, descifrando
	
	la $a0, output_file		# Se envía el nombre del archivo a escribir
	jal write_archivo		# Se escribe el resultado (Criptograma) en el archivo
	
	li $v0, 4			# Imprime el mensaje de exito si todo lo anterior se hizo correctamente
	la $a0, msg_exito_descifrado
	syscall
	
	j menu		# Vuelve al menú para elegir otra opción
	
# ------------------------------------------------------------------------------------
#	ARCHIVOS ENTRADA
# ------------------------------------------------------------------------------------

read_archivo:		
	li $v0, 13	# Syscall para abrir el archivo
			# El nombre del archivo se envia desde el jal con la opción
	li $a1, 0	# Modo de read-only (Solo lectura)
	syscall
	move $s0, $v0	# $s0 ahora contiene el identificador del archivo 
	
	li $t7, -1	# Si el identificador es negativo (-1) hubo un error, se envía el mensaje
	beq $v0, $t7, error_apertura
	
	li $v0, 14	# Syscall para leer el contenido del archivo
	move $a0, $s0	# Se mueve a $a0 el identificador que está en $s0
	la $a1, buffer
	li $a2, 2049
	syscall
	move $s1, $v0	# $s1 ahora contiene la cadena del archivo
	
	li $t7, 2049			# Registro temporal para comprobar buffer lleno
    	beq $s1, $t7, buffer_lleno	# Si el contenido leido es igual a 2049, está lleno y se va al mensaje de error
	
	beq $v0, $zero, archivo_vacio	# Si el contenido leido es igual a 0, está vacío y se va al mensaje de error
	
	li $v0, 16
	move $a0, $s0 	# Syscall para cerrar el archivo cuando temrinamos de usarlo
	syscall
	jr $ra	# Vuelve para continuar con las instrucciones
	
# ------------------------------------------------------------------------------------
#	CLAVE
# ------------------------------------------------------------------------------------		
	
input_clave:
	li $v0, 4	# Imprime el mensaje para pedir la clave
	la $a0, msg_clave
	syscall

	li $v0, 8	# Lee la clave
	la $a0, clave	 
	li $a1, 101	
	syscall
	la $s2, clave	# $s2 ahora contiene la dirección base de la clave
	
	la $t0, clave	# Carga la dirección base de la clave en $t0 para su posterior uso
	li $t2, 10	# Carga el salto de linea para comprobar el final de la clave
	li $t3, 9	# Carga el tabulador para comprobar el final de la clave
	li $s3, 0	# $s3 inicia en 0 para guardar la longitud de la clave
	
long_clave:
	lb $t1, 0($t0)			# Lee 1 byte de la clave
	beq $t1, $t2, final_clave	# Compara si hay salto de linea, de serlo, es que acabo la clave
	beq $t1, $t3, final_clave	# Compara si hay tabuladores, de serlo, es que acabo la clave
	beq $t1, $zero, final_clave	# Compara si hay terminador nulo, de serlo, es que acabo la clave
	addi $t0, $t0, 1			# Aumenta la dirección de la clave para leer el siguiente byte
	addi $s3, $s3, 1			# Se le suma 1 a $s3 para almacenar la longitud de la cadena
	j long_clave
	   
final_clave:
	beq $s3, $zero, clave_vacia	# Se compara si la longitud es 0, de serlo, la clave está vacía
	li $t7, 101			# Se comprueba si la longitud es 101, de serlo, se alcanzó el maximo de 100 bytes
	beq $s3, $t7, clave_max
	jr $ra				# Vuelve para continuar con las instrucciones
	
# ------------------------------------------------------------------------------------
#	PROCESAMIENTO DE CARACTERES
# ------------------------------------------------------------------------------------	

procesar:	
	beq $t9, $s1, fin_procesar	# Compara si se llego al final de la cadena, de serlo, vuelve para continuar el proceso
	beq $t8, $s3, reset	# Compara si se llego al final de la clave, de serlo se vuelve a la direccion base para volverla a usar hasta el final de la cadena
	
	lb $t2, 0($t0)	# Lee el byte de la clave
	lb $t3, 0($t1)	# Lee el byte de la cadena
	
    	li   $t7, 9			# Se compara si es un tabulador (Ascii 9), de serlo se mantiene
    	beq  $t3, $t7, copiar_control

    	li   $t7, 10			# Se compara si es un salto de linea (Ascii 10), de serlo se mantiene
    	beq  $t3, $t7, copiar_control

    	li   $t7, 13			# Se compara si es un retorno (Ascii 13), de serlo se mantiene por si la codificacion del salto de linea es doble
    	beq  $t3, $t7, copiar_control
	
	# Se resta 32 a ambas para obtener valores entre 32-126 correspondientes a los valores imprimibles ascii
	addi $t4, $t2, -32	
	addi $t5, $t3, -32	
	
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
	addi $t6, $t6, 32		# Se suma nuevamente 32 para volver a la codificacion ascii
	
	sb $t6, 0($s5)			# Se guarda el byte para su posterior escritura en ela rchivo
	addi $s5, $s5, 1
	
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j procesar
	
	# Se aumenta en 1 tanto los contadores como las direcciones para que pueda seguir su camino
	
copiar_control:		# Función auxiliar para preservar los tabuladores, saltos de linea y retornos
    sb   $t3, 0($s5)
    addi $s5, $s5, 1
    addi $t1, $t1, 1
    addi $t9, $t9, 1
    j    procesar

reset:
	move $t0, $s2	# Se devuelve $t0 a la dirección base de la clave
	li $t8, 0	# Se carga ese primer byte de la clave
	j procesar	# Sigue procesando

fin_procesar:
	jr $ra		# Vuelve para continuar con las instrucciones
	
# ------------------------------------------------------------------------------------
#	ARCHIVOS SALIDA
# ------------------------------------------------------------------------------------	
	
write_archivo:
	li $v0, 13	# Se abre el archivo como escritura-crear (write-create)
			# El nombre del archivo se envia desde el jal
	li $a1, 1	# Modo de write-create (Leer y crear)
	syscall
	move $s0, $v0	# $s0 ahora contiene el identificador del archivo
	
	li $t7, -1			# Si el identificador es negativo (-1) hubo un error, se envía el mensaje
	beq $s0, $t7, error_apertura
	
	li $v0, 15	# Syscall para escribir en el archivo el cifrado que se obtuvo 
	move $a0, $s0		
	la $a1, output_buffer
	move $a2, $t9	# Cantidad de caracteres que se cifraron, obntenidos anteriromente
	syscall
	
	li $t7, -1			# Se ompara si la cantidad de bytes escritos es negativa o diferente al total de la cadena, de serlo hubo un error de escritura
    	beq $v0, $t7, error_escritura
    	bne $v0, $t9, error_escritura
	
	li $v0, 16	# Syscall para cerrar el archivo cuando temrinamos de usarlo
	move $a0, $s0
	syscall
	jr $ra		# Vuelve para continuar con las instrucciiones
	
# ------------------------------------------------------------------------------------
#	MENSAJES DE ERRORES
# ------------------------------------------------------------------------------------	
opcion_invalida:			# Mensaje de error por si la opción es invalida
    li $v0, 4
    la $a0, msg_opcion_invalida
    syscall
    j menu

error_apertura:				# Mensaje de error por si hay un error de apertura de archivo
    li $v0, 4
    la $a0, msg_error_apertura
    syscall
    j menu
    					# Mensaje de error por si el buffer llegó a su maximo
buffer_lleno:
    li $v0, 4
    la $a0, msg_archivo_grande
    syscall

    # Cerrar el archivo abierto
    li $v0, 16
    move $a0, $s0
    syscall

    j menu
    
archivo_vacio:				# Mensaje de error por si el buffer está vacio, por ende el archivo
    li $v0, 4
    la $a0, msg_archivo_vacio
    syscall
    
    # Cerrar el archivo abierto
    li $v0, 16
    move $a0, $s0
    syscall
    
    j menu
    
clave_vacia:				# Mensaje de error por si la clave está vacía
    li $v0, 4
    la $a0, msg_clave_vacia
    syscall
    j menu
 		
clave_max:				# Mensaje de error por si la clave llegó a su maximo
    li $v0, 4
    la $a0, msg_clave_max
    syscall
    j menu
    
error_escritura:			# Mensaje de error por si hubo un error en la escritura del archivo
    li $v0, 4
    la $a0, msg_error_escritura
    syscall
    
    # Cerrar el archivo abierto
    li $v0, 16
    move $a0, $s0
    syscall
    
    j menu
    
# ------------------------------------------------------------------------------------
#	SALIDA
# ------------------------------------------------------------------------------------	

exit:	li $v0, 4			# Imprime el mensaje de despedida
	la $a0, msg_salida
	syscall
	
	li $v0, 10			# Acaba la ejecución
	syscall
