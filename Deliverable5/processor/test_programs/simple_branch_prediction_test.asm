###############################################
# This program uses simple branches to check whether branch prediction is working or not.

	addi $1, $0, 10	
	addi $2, $0, 15
	bne  $1, $2, END
	j MODIFY
	addi $2, $0, 35
	addi $3, $0, 10
	addi $4, $0, 10
MODIFY : addi $1, $0, 17
	addi $2, $0, 17
	addi $11 $0, 17
	addi $12, $0, 17

END:	sw $1, 0($0)
		sw $2, 4($0)



EoP:	beq	 $11, $11, EoP 	#end of program (infinite loop)
###############################################
