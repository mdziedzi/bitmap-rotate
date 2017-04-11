.eqv oldBmpAdr $s1
.eqv newBmpAdr $t1
.eqv descriptor $s0
.eqv widthCounter $t4
.eqv heightCounter $t6
.eqv start $t0
			.data
wielkosc:		.space 4
			.align 4
bpp:			.space 2 # bits per pixel
			.align 2
header:		.space 124
			.align 4
sciezka1:		.asciiz "/Users/marcin/mips/kot.bmp"
wiadomosc1:		.asciiz "Podaj sciezke dostepu obrazka\n"
wiadomosc_blad1:	.asciiz "Blad zwiazany z plikiem wejsciowym. Podaj nazwe jeszcze raz\n"
wiadomosc_blad3:	.asciiz "Blad wczytywania\n"
plik_we:		.space 100
			.align 4
plik_wy:		.align 4
			.asciiz "/Users/marcin/mips/out.bmp"
			.text
			.globl main

		# s0 - descriptor
		# rozmiar - header + 4
		# offset - header + 12
		# szerokość - header + 20
		# wysokość - header + 24
		# s1- adres starej bitmapy
		# s2 - szerokość nowej bitmapy
		# s3 - wysokość nowej bitmapy
		# t1 - adres nowej bitmapy
		# t2 - tymczasowy adres starej bitmapy
		# t3 - tymczasowy adres nowej bitmapy

main:
		#wyswietl sciezke
		li $v0, 4
		la $a0, sciezka1
		syscall
		
		#otworzenie pliku wejsciowego
		li $v0, 13
		la $a0, sciezka1
		li $a1, 0
		li $a2, 0
		syscall

		# jesli nie udalo się otworzyć pliku - wyrzuć bład
		bltz $v0, blad1

		# descriptor do $s0
		move descriptor, $v0

		#odczytanie naglowka
		li $v0, 14
		la $a0, (descriptor)
		# aby wyrownac adresy do podzielnych przez 4
		la $a1, header + 2	#addres of input file
		li $a2, 122		#maximum number to read
		syscall
		#jesli nie udalo się odczytać wszystkich bajtów - błąd
		bltz $v0, blad3

		# zaalokowanie pamieci na bitmapę
		lw $t7, header + 36
		li $v0, 9
		la $a0, ($t7)
		#la $a0, header + 36
		syscall
		
		# adres pamięci do s1
		move oldBmpAdr, $v0

wczytaj_bajty:
		# wczytanie bajtów do zaalokowanej pamięci
		li $v0, 14	#read from file
		la $a0, (descriptor)
		la $a1, (oldBmpAdr)	# adress of input file
		#la $a2, ($t7)
		la $a2, header + 36	# tyle tam, czyli size tablicy
		syscall
		# jesli nie udalo się odczytać wszystkich bajtów - błąd
		bltz $v0, blad3

		# zamknięcie pliku, s0 niepotrzebne
		li $v0, 16
		la $a0, (descriptor)
		syscall

		# szerokość nowej bitmapy do s2 = wysokosc + padding
		lw $s2, header + 24

		# ładuję do s0 wartość bits per pixel
		lh $s0, header + 30
		sh $s0, bpp
		mul $s2, $s2, $s0	#w s2 bedzie szerokosc nowej bitmapy ale w bitach
		#padding
		addi $s2, $s2, 31
		srl $s2, $s2, 5
		sll $s2, $s2, 2		

		# wysokość nowej bitampy = szerokość oryginalnej, do s3
		lw $s3, header + 20

		# obliczam rozmiar nowej bitmapy
		mul $s4, $s2, $s3
		sw $s4, wielkosc

		#alokacja pamięci dla nowej bitmapy
		li $v0, 9
		lw $s4, wielkosc
		la $a0, ($s4)
		#la $a0, wielkosc
		syscall

		# ustawienie t1 na wskaźnik do nowej bitmapy
		move newBmpAdr, $v0

		# ustawienie tymczasowych wskaźników na bitmapy
		move $t2, oldBmpAdr
		move $t3, newBmpAdr

		# ustawienie wskaznika nowej bitmapy na lewy gorny rog
		lw $t5, wielkosc
		sub $t5, $t5, $s2	#odejmuje wiersz starej bitmapy
		add $t3, $t3, $t5	#ide na sam koniec
		# zapamietanie adresu na lewy gorny rog nowej bitmapy
		move  start, $t3

		#przepisywanie pikseli w odpowiedniej kolejności
		li widthCounter, 0
		li heightCounter, 0

		# w s4 wartość paddingu dla starego wiersza, którą będziemy pomijać w pętli
		lh $s0, bpp
		lw $s4, header + 20	#height
		mul $s4, $s4, $s0
		addi $s4, $s4, 31
		srl $s4, $s4, 5
		sll $s4, $s4, 2
		srl $s0, $s0, 3		#zamiana bits per pixel na bytes per pixel
		sh $s0, bpp
		lw $t7, header + 20	#height
		mul $t7, $t7, $s0	#wys w bajtach bez padingu
		sub $s4, $s4, $t7	#wychodzi czysty padding




przepisywanie_kolumny:
		#licznik zliczający liczbę przepisanych bitów piksela
		li $t7, 0
przepisz_bajty:
		lb $t5, ($t2)
		sb $t5, ($t3)
		addi $t7, $t7, 1	#increment
		lh $s0, bpp
		beq $t7, $s0, dalej	#po 3 zapisanym bajcie (pelny pixel)
		# przesuwam się o kolejny bit w starej bitmapie i nowej bitmapie
		addi $t2, $t2, 1
		addi $t3, $t3, 1
		j przepisz_bajty
dalej:
		#cofamy się do początku pixela
		lh $s0, bpp		#bpp = 3
		subi $s0, $s0, 1
		sub $t3, $t3, $s0	#odejmuje od wskaznika 2

		#przeskakuję do kolejnego wiersza
		addi heightCounter, heightCounter, 1
		#jesli jesteśmy w ostatnim elemencie kolumny, przeskok do nowej
		beq heightCounter, $s3, nowa_kolumna	#s3 - wys nowej bmp
		addi $t2, $t2, 1	# wskaznik starej idzie do przodu
		sub $t3, $t3, $s2	# s2 wys nowwej kolumny
		j przepisywanie_kolumny

nowa_kolumna:

		# ustawiamy się na lewy gorny rog nowej bitmapy, przeskakujemy o element w prawo do sąsiedniej kolumny
		move $t3, start
		li heightCounter, 0
		addi widthCounter, widthCounter, 1
		# ładuję wysokość starego obrazka do t7
		lw $t7, header + 24
		# jesli wszystkie kolumny przepisane - wyjdz z petli
		beq widthCounter, $t7, koncz
		move $s5, widthCounter
		# o tyle bajtów muszę się przesunąć
		lh $s0, bpp	#3
		mul $s5, $s5, $s0
		add $t3, $t3, $s5
		# pomijamy bity paddingu w starej bitmapie
		add $t2, $t2, $s4 # $s4 czysty padding
		#przesuwamy się o kolejną pozycję w starej bitmapie
		addi $t2, $t2, 1
		j przepisywanie_kolumny

koncz:
		lh $s0, bpp
		# ustaw nową długość, szerokość i rozmiar bitmapy
		lw $s4, header + 20
		lw $s5, header + 24
		sw $s5, header + 20
		sw $s4, header + 24
		lw $s4, wielkosc
		sw $s4, header + 36
		addi $s4, $s4, 122
		sw $s4, header + 4	#caly plik

		#otworzenie pliku wyjsciowego o podanej nazwie
		li $v0, 13
		la $a0, plik_wy
		li $a1, 1
		li $a2, 0
		syscall

		# descriptor do s7
		move $s7, $v0

		# zapisanie obrazka do pliku
		li $v0, 15
		move $a0, $s7
		# zapisanie nagłówka
		la $a1, header
		addi $a1, $a1, 2
		li $a2, 122
		syscall
		# zapisanie bitmapy
		li $v0, 15
		move $a0, $s7
		move $a1, newBmpAdr
		lw $s4, wielkosc
		move $a2, $s4
		syscall

		# zamknięcie pliku
		li $v0, 16
		move $a0, $s7
		syscall
		j koniec

blad1:
		# wyswietl wiadomość o błędzie
		li $v0, 4
		la $a0, wiadomosc_blad1
		syscall
		j koniec

blad3:
		li $v0, 4
		la $a0, wiadomosc_blad3
		syscall
        j koniec
        
koniec:
		li $v0, 10
		syscall
