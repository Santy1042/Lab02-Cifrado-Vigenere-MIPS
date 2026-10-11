.data
string1: .ascii "Declarar un mensaje extendido"
myword:	.word 100

.text
	la $t2, myword	# Pointer to data segment
	
	li $t0, 0x11	# Init register $t0 to 0x11
	sb $t0, 0($t2)	# Save LSByte from $t0 in memory
	
	li $t0, 0x22
	sb $t0, 1($t2)
	
	li $t0, 0x33
	sb $t0, 2($t2)
	
	li $t0, 0x44
	sb $t0, 3($t2)
	
	lw $t0, 0($t2)
	
	
