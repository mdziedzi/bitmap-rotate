.data
        input:      .asciiz "/Users/marcin/mips/arkoLab1/src16.bmp"
        output: .asciiz "/Users/marcin/mips/arkoLab1/output1.bmp"
.text
main:
	la $a0, input	#print
	li $v0, 4
	syscall
	
	
	
	li $v0, 10	#exit
	syscall