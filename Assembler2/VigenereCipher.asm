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
	jal key_len	#Obliczenie d³ugoœci i sprawdzenie poprawnoœci klucza
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
	
	la 	$t0, input_data #przekazanie adresu ³añcucha 
	
	jr $ra #powrót do main

get_option:
	#Wyswietlenie menu
	la $a0 , menu
	li $v0, 4
	syscall
		 	 
	#Wybor opcji
	li $v0, 12	
	syscall
	move $t5,$v0
	
	#Wyœwietlenie pustej lini
	la $a0, newLine
	li $v0, 4
	syscall
	
	#Sprawdzenie czy zosta³a wybrana jedna z dwóch opcji
	beq $t5, 83 ,exit_get_option
	beq $t5, 68 ,exit_get_option
	
	#Wyswietlenie ifnormacji o wyjatku
	la $a0 , exception1
	li $v0, 4
	syscall
	
	#Ponowne wybranie opcji
	b get_option
	
exit_get_option:
	jr  $ra #Powrót do main

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
	
	#Przekazanie ³añcucha znaków do dwóch rejestrów
	la $t1, input_key
	la $t3, input_key
	jr  $ra

key_len:

	lb $t2, ($t3) #Przechowanie znaku z adresu
	
	#Je¿eli klucz koñczy siê LF lub 0 wyjœcie z pêtli
	beq $t2, 10,key_len_end
	beqz $t2,key_len_end
	
	#b³¹d e¿eli znak z klucza jest poza znakami a-z 
	ble $t2, 96, niedopuszczalnyZnakKlucza
	bge $t2, 123, niedopuszczalnyZnakKlucza
	
	#Obliczanie d³ugoœci klucza
	addu $t3,$t3,1
	add  $s0,$s0,1
	
	b key_len
key_len_end:
	jr $ra

dzialanie:
	#Odczytanie wartoœci znaku o raz znaku klucza
	lb $t2,($t0)
	lb $t3,($t1)
	
	#sprawdzenie i ewentualna zamiana wielkosci znaku 
	jal poprawnaWielkoscZnaku
	
	#Je¿eli klucz koñczy siê LF lub 0 wyjœcie z pêtli
	beq $t2,10,exit
	beqz $t2,exit
	
	#Zapêtlenie klucza
	beq $s0,$s1, overFlow
	
	#skok jêzeli odczytany znak nie jest litera
	ble $t2, 96, niedopuszczalnyZnak
	bge $t2, 123, niedopuszczalnyZnak
	
	#Dodanie do licznika 1
	add $s1,$s1,1
	
	#Zamaiana klucza na wartoœæ przesuniêcia
	sub $t3,$t3,97
	
	#Wybór opcji
	beq $t5, 83, szyfrowanie
	beq $t5, 68, deszyfrowanie
	
	
	
	#wyjscie z programu
	j exit

szyfrowanie:
	# Dodanie do wartoœci znaku wartoœci klucza
	add $t2,$t2,$t3 
	jal wyswietlenie_wartosci
	#przesuniêcie adresów o 1
	add $t0,$t0,1
	add $t1,$t1,1
	#powrót do dzia³ania
	b dzialanie
deszyfrowanie:
	# Odejmowanie do wartoœci znaku wartoœci klucza
	sub $t2,$t2,$t3
	jal wyswietlenie_wartosci
	#przesuniêcie adresów o 1
	add $t0,$t0,1
	add $t1,$t1,1
	#powrót do dzia³ania
	b dzialanie
	
niedopuszczalnyZnak:
	#Pominiecie niedopuszczalnego znaku (system go ignoruje)
	add $t0,$t0,1
	#powrót
	j dzialanie
	
niedopuszczalnyZnakKlucza:
	#Wyswietlenie wyj¹tku
	la $a0, exception2
	li $v0, 4
	syscall
	#ustawienie wartoœci powrotu na get_key by ponownie pobraæ klucz
	#Ustawienie wartoœci powrotu na (jal get_key) w mian:
	add $ra,$zero,0x00400008
	j get_key

overFlow:
	#Ustawienie adresu na poczatek klucza
	sub $t1, $t1, $s0
	#wyzerowanie licznika
	add $s1, $zero,$zero
	b dzialanie
	
wyswietlenie_wartosci:
	#je¿eli znak wykroczy³ poza zakres(ponad z)
	sgt $t6,$t2,122
	beq $t6,1,redukcja1
	#je¿eli znak wykroczy³ poza zakres(poni¿ej a)
	slti $t6,$t2,97
	beq $t6,1,redukcja2		
	#wyœwietlenie wartoci char
	li $v0, 11
	la $a0,($t2)
	syscall 
	
	jr $ra

poprawnaWielkoscZnaku:
	#Je¿eli znak jest poni¿ej wartoœci Z
	ble $t2,90, poprawnaWielkoscZnaku2
	jr $ra
	
poprawnaWielkoscZnaku2:
	#Je¿eli znak jest powy¿ej wartoœci A 
	bge $t2,65,zmniejszanieLitery
	jr $ra
	
zmniejszanieLitery:
	#Przesuniêcie znaku o 32 ( zmiana z du¿ej na ma³¹ literê)
	add $t2,$t2,32
	jr $ra

redukcja1:
	#cofniêdzie znaku na pocz¹tek alfabaetu 
	sub $t2,$t2,26
	b wyswietlenie_wartosci
	
redukcja2:
	#przesuniêcie znaku na koniec alfabetu 
	add $t2,$t2,26
	b wyswietlenie_wartosci
exit:
	li $v0, 10
	syscall
