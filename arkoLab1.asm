.data
	header:	.space 16
        input:      .asciiz "/Users/marcin/mips/arkoLab1/src.bmp"
        output: .asciiz "/Users/marcin/mips/arkoLab1/output1.bmp"
        newLine: .asciiz "\n"
        buffer: .space 300
.text
main:
###
	la $a0, input	#print
	li $v0, 4
	syscall
###
	
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
      	
      	#*****#
      	
      	#Alokujemy pamiec, gdzie czytane beda informacje.
      	move $a0, $s0	#to co wyczytalismy z pilku input
      	li $v0, 9	#alokacja pamieci
      	syscall
      	move $t0 ,$v0	#t0 zawiera adres zaalokowanej pamieci
      	
      	#czytamy dane z pliku do naszego miejsca zaalokowanego na stosie.
      	move $a0, $t1	#deskryptor pliku
      	move $a1, $t0	#do tego adresu czytamy
      	move $a2, $s0	#tyle bajtow mamy przeczytac, czyli rozmiar calego pliku
      	li $v0, 14  #read from file     
      	syscall 
      	
      	#caly plik input jest juz w pamieci
      	# $t1, $s0, $s1 - free
      	
      	#******#
   	
   	#zamykam plik
   	move $a0, $t1	#deskryptor
   	li $v0, 16	#zamkniecie pliku
   	syscall
   	
      	lw $s3 , 4($t0) #czytam szerokosc bitmapy - skladuje w s3
      	lw $s4 , 8($t0) #czytam wysokosc bitmapy - skladuje w s4
      	
#{
	la $a0, newLine	#print
	li $v0, 4
	syscall
	
      	move $a0, $s3	#print
	li $v0, 1
	syscall
	
	la $a0, newLine	#print
	li $v0, 4
	syscall
   	
   	move $a0, $s4	#print
	li $v0, 1
	syscall
#}   	
      	
	#s5 = rozmiar wiersza(w bajtach) orginalnego obrazka(po dodaniu paddingu)
      li $t3, 0
      add $t3, $s3, 31
      srl $t3, $t3, 5
      sll $t3, $t3, 2
      move $s5, $t3
      #t3 nadal to tymczasowy element
      # s3 rozmiar wiersza to w obroconej bitmapie
      #s6 to rozmiar wiersza obroconej kolumny(po dodaniu paddingu)
      li $t3, 0
      add $t3, $s4, 31
      srl $t3, $t3, 5
      sll $t3, $t3, 2
      move $s6, $t3
      	
      	
      	      	
#{
	la $a0, newLine	#print
	li $v0, 4
	syscall
	
      	move $a0, $s5	#print
	li $v0, 1
	syscall
	
	la $a0, newLine	#print
	li $v0, 4
	syscall
	
      	move $a0, $s6	#print
	li $v0, 1
	syscall
      	
#}
      #w 7 skladujemy rozmiar bitmapy, ktora powinnismy zaalokowac(wiersze * kolumny)
      mul $s7, $s6, $s3 
      #alokujemy pamiec na nowa bitmape.
      #t2 zawiera adres nowej pamieci
      move    $a0,    $s7
      li    $v0, 9
      syscall
      move $t2 ,$v0
      
#{
	la $a0, newLine	#print
	li $v0, 4
	syscall
	
      	move $a0, $s7	#print
	li $v0, 1
	syscall
      	
#}
      
      
      
      #{
	la $a0, newLine	#print
	li $v0, 4
	syscall
	
      	move $a0, $s1	#print
	li $v0, 1
	syscall
      	
#}
      #ustawianie wskaznika pliku - jest ustawiony na tablice pikseli obecnie.
      sub $s1,	$s1, 14
      add $t0,	$t0, $s1 
      	
      	
      	#{
	la $a0, newLine	#print
	li $v0, 4
	syscall
	
      	move $a0, $s1	#print
	li $v0, 1
	syscall
      	
#}
      	
#t0 wskaznik ktorego nie zmieniamy!
      # w t1 mamy sobie tymczasowy wskaznik 
      
      move $t6, $s3 # bedziemy zmniejszali co 1. zaladowany jest iloscia bitow, ktore powinny byc w wierszu! :) 
      move $t1, $t0 # 
      lb $t4, ($t1) # do tymczasowego chodzenia po row
      li $t5, 1 #t5 bada w ktorym jestesmy wierszu
      li $t3, 0x80 # przygotowana maska
      # musimy ustawic na ostatni wiersz. wierszy jest tyle, ile kolumn oryginalnej. Wartosc trzymana jest w S3.
      #skaczymy za kazdym razem o padding dla nowej, czyli: s6
      	

      	
      	
      	
      	
      
  
	#******#
	
	li $v0, 10	#exit
	syscall
