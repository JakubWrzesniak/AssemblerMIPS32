.data

input_data : .space 51
set_data: .asciiz "Witaj w programie szyfracyjnym Vigeners'a \nPodaj wiadomosc(max 50 znakow)\n"
input_key: .space 9
set_key: .asciiz "\nPodaj Klucz(max 8 znakow)\n"
menu: .asciiz "\nS - szyfrowanie \nD - deszyfrowanie\n"
exception1 : .asciiz "\nWybrana opcja nie istnieje"
exception2: .asciiz "\nPodano nieprawidlowy znak w kluczu."
newLine: .asciiz "\n"

.text
main: 
	jal get_sentence #Pobranie wyrazenia do szyfrowania
	jal get_key	#pobranie klucza
	jal key_len	#Obliczenie d�ugo�ci i sprawdzenie poprawno�ci klucza
	jal get_option #Wybor opcji S/D
	li 	$s1, 0 #ustawienie licznika na 0 
	j 	dzialanie
	
get_sentence:
	#Wyswietlenie informacji
	la 	$a0 , set_data
	li 	$v0, 4
	syscall
	
	#Pobranie wiadomosci
	li 	$v0, 8			 	
	la 	$a0, input_data		
	li 	$a1, 51
	syscall
	
	la 	$t0, input_data #przekazanie adresu �a�cucha 
	
	jr $ra #powr�t do main

get_option:
	#Wyswietlenie menu
	la $a0 , menu
	li $v0, 4
	syscall
		 	 
	#Wybor opcji
	li $v0, 12	
	syscall
	move $t5,$v0
	
	#Wy�wietlenie pustej lini
	la $a0, newLine
	li $v0, 4
	syscall
	
	#Sprawdzenie czy zosta�a wybrana jedna z dw�ch opcji
	beq $t5, 83 ,exit_get_option
	beq $t5, 68 ,exit_get_option
	
	#Wyswietlenie ifnormacji o wyjatku
	la $a0 , exception1
	li $v0, 4
	syscall
	
	#Ponowne wybranie opcji
	b get_option
	
exit_get_option:
	jr  $ra #Powr�t do main

get_key:
	#Zapytanie o podanie Klucza
	la $a0 , set_key
	li $v0, 4
	syscall
	
	#Odczytanie Klucza
	li $v0, 8			 	
	la $a0, input_key		
	li $a1, 9
	syscall
	
	#Przekazanie �a�cucha znak�w do dw�ch rejestr�w
	la $t1, input_key
	la $t3, input_key
	jr  $ra

key_len:

	lb $t2, ($t3) #Przechowanie znaku z adresu
	
	#Je�eli klucz ko�czy si� LF lub 0 wyj�cie z p�tli
	beq $t2, 10,key_len_end
	beqz $t2,key_len_end
	
	#b��d e�eli znak z klucza jest poza znakami a-z 
	ble $t2, 96, niedopuszczalnyZnakKlucza
	bge $t2, 123, niedopuszczalnyZnakKlucza
	
	#Obliczanie d�ugo�ci klucza
	addu $t3,$t3,1
	add  $s0,$s0,1
	
	b key_len
key_len_end:
	jr $ra

dzialanie:
	#Odczytanie warto�ci znaku o raz znaku klucza
	lb $t2,($t0)
	lb $t3,($t1)
	
	#sprawdzenie i ewentualna zamiana wielkosci znaku 
	jal poprawnaWielkoscZnaku
	
	#Je�eli klucz ko�czy si� LF lub 0 wyj�cie z p�tli
	beq $t2,10,exit
	beqz $t2,exit
	
	#Zap�tlenie klucza
	beq $s0,$s1, overFlow
	
	#skok j�zeli odczytany znak nie jest litera
	ble $t2, 96, niedopuszczalnyZnak
	bge $t2, 123, niedopuszczalnyZnak
	
	#Dodanie do licznika 1
	add $s1,$s1,1
	
	#Zamaiana klucza na warto�� przesuni�cia
	sub $t3,$t3,97
	
	#Wyb�r opcji
	beq $t5, 83, szyfrowanie
	beq $t5, 68, deszyfrowanie
	
	
	
	#wyjscie z programu
	j exit

szyfrowanie:
	# Dodanie do warto�ci znaku warto�ci klucza
	add $t2,$t2,$t3 
	jal wyswietlenie_wartosci
	#przesuni�cie adres�w o 1
	add $t0,$t0,1
	add $t1,$t1,1
	#powr�t do dzia�ania
	b dzialanie
deszyfrowanie:
	# Odejmowanie do warto�ci znaku warto�ci klucza
	sub $t2,$t2,$t3
	jal wyswietlenie_wartosci
	#przesuni�cie adres�w o 1
	add $t0,$t0,1
	add $t1,$t1,1
	#powr�t do dzia�ania
	b dzialanie
	
niedopuszczalnyZnak:
	#Pominiecie niedopuszczalnego znaku (system go ignoruje)
	add $t0,$t0,1
	#powr�t
	j dzialanie
	
niedopuszczalnyZnakKlucza:
	#Wyswietlenie wyj�tku
	la $a0, exception2
	li $v0, 4
	syscall
	#ustawienie warto�ci powrotu na get_key by ponownie pobra� klucz
	#Ustawienie warto�ci powrotu na (jal get_key) w mian:
	add $ra,$zero,0x00400008
	j get_key

overFlow:
	#Ustawienie adresu na poczatek klucza
	sub $t1, $t1, $s0
	#wyzerowanie licznika
	add $s1, $zero,$zero
	b dzialanie
	
wyswietlenie_wartosci:
	#je�eli znak wykroczy� poza zakres(ponad z)
	sgt $t6,$t2,122
	beq $t6,1,redukcja1
	#je�eli znak wykroczy� poza zakres(poni�ej a)
	slti $t6,$t2,97
	beq $t6,1,redukcja2		
	#wy�wietlenie wartoci char
	li $v0, 11
	la $a0,($t2)
	syscall 
	
	jr $ra

poprawnaWielkoscZnaku:
	#Je�eli znak jest poni�ej warto�ci Z
	ble $t2,90, poprawnaWielkoscZnaku2
	jr $ra
	
poprawnaWielkoscZnaku2:
	#Je�eli znak jest powy�ej warto�ci A 
	bge $t2,65,zmniejszanieLitery
	jr $ra
	
zmniejszanieLitery:
	#Przesuni�cie znaku o 32 ( zmiana z du�ej na ma�� liter�)
	add $t2,$t2,32
	jr $ra

redukcja1:
	#cofni�dzie znaku na pocz�tek alfabaetu 
	sub $t2,$t2,26
	b wyswietlenie_wartosci
	
redukcja2:
	#przesuni�cie znaku na koniec alfabetu 
	add $t2,$t2,26
	b wyswietlenie_wartosci
exit:
	li $v0, 10
	syscall
