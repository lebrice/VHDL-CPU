###############################################
# This program uses simple branches to check whether branch prediction is working or not.

	addi $1, $0, 10	
	addi $2, $0, 15
	bneq  $1, $2, END
	addi $1, $0, 30
	addi $2, $0, 35

END:	sw $1, 0($0)
		sw $2, 4($0)



EoP:	beq	 $11, $11, EoP 	#end of program (infinite loop)
###############################################
