.data
	header:	.space 16
        input:      .asciiz "/Users/marcin/mips/arkoLab1/src16.bmp"
        output: .asciiz "/Users/marcin/mips/arkoLab1/output1.bmp"
.text
main:
	la $a0, input	#print
	li $v0, 4
	syscall
	
	
	#bedziemy otwierac plik
	la $a0, input	#input file path
	li $a1, 0	#flaga do czytania
	li $a2, 0	#flaga mode nwm o co chodzi
	li $v0, 13
	syscall
	move $t1, $v0	#zapisujemy deskryptor pliku
	
fileHeader:	
	move $a0, $t1	#czytamy deskryptor pliku
	la $a1, header	#address of input buffer
	li $a2, 2	#tyle characters bedziemy czytac
	li $v0, 14	#czytanie z pliku
	syscall
	
	#bedziemy czytac rozmiar
	move $a0, $t1	#deskryptor
	la $a1, header	#do bufora
	li $a2, 4	#tyle czytamy
	li $v0, 14	#przeczytalismy size bitmapy
	syscall
	lw $s0, header	#zapisujemy to co przeczytalismy (wartosci)
	
	#ladujemy 4 bajty - to sa bajty aplikacji chyba niepotrzebne
      	move $a0, $t1	#deskruptor
      	la $a1, header   #do bufora
      	li $a2, 4		#tyle cytamy
      	li $v0, 14  #read from file     
      	syscall 

	#ladujemy offset do $s1 - 
       	move $a0, $t1	#deskryptor
      	la $a1, header   
     	li $a2, 4
     	li $v0, 14  #read from file     
      	syscall 
      	lw $s1, header	#zapisujemy to co przeczytaliśmy
      	
      	
	
	
	
	
	li $v0, 10	#exit
	syscall