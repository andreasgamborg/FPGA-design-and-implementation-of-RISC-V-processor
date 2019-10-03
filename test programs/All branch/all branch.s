	.text	
	li x1, 33
	li x2, 66
	li x3, 11
	li x4, 22
	beq x2,x1, f
	blt x4, x3, f
	bgt x3, x2, f
	bne x1, x4, t
f:	
	li x1, 42
t:
	ecall

