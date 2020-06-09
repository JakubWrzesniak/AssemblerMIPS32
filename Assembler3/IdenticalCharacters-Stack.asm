.data 
	text1 : .space 128
	text2: .space 128
	result: .space 128
	info_text1: .asciiz "Podaj pierwszy tekst :\n"
	info_text2: .asciiz "\nPodaj drugi tekst:\n"
	exceptionText_1: .asciiz "\nPodane teksty sa roznej dlugosci. Niestety nie mozna ich porowanc\n"
	ask_1: .asciiz "\nCzy powtorzyc dzialanie? \n0-tak\n1-nie\n"
	info_result: .asciiz "\nOtrzymano tekst: \n"
	info_counter1: .asciiz "\nIlosc identycznych znakow: "
	info_counter2: .asciiz "\nIlosc roznych znakow: "
	
.text
	
main:
	#pobranie piwerszego tesktu
	la $a0, info_text1
	li $a1, 128
	la $a2, text1
	li $v0, 4
	jal getData
	
	#pobranie drugiego tekstu
	la $a0, info_text2
	li $a1, 128
	la $a2, text2
	li $v0, 4
	jal getData
	
	la $t0, text1 #przekazanie do rejestru wartosci adresu tekstu 1
	
	#znalezienie adresu ostatniego znaku pierwszego tekstu
	la $a0, text1
	jal findTextEnd
	move $s0, $v0 # zapisanie wyniku do rejestru $s0 
	
	#Obliczenie dlugosci tekstu1 i zapisanie jej do rejestru $s1
	sub $s1, $s0, $t0
	addu $s1, $s1, 1
	
	la $t0, text2 #przekazanie do rejestru wartosci adresu tekstu 2
	
	#znalezienie adresu ostatniego znaku drugiego tekstu  tekstu
	la $a0, text2
	jal findTextEnd
	move $s2, $v0 # zapisanie wyniku do rejestru $s2 
	
	#Obliczenie dlugosci tekstu1 i zapisanie jej do rejestru $s3
	sub $s3, $s2, $t0
	addu $s3, $s3, 1
	
	#sprawdzenie czy podane teksty sa rownej dlugosci
	bne $s1, $s3, exception_1
	
	move $s7, $sp #zapisanie do wartoœci rejestru adresu dna stosu
	
	#podanie wartoœci dla funckji task1
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	jal task1
	
	#przenisienie wynikow funkcji do rejestrow tymczasowych
	move $t0, $v0
	move $t1,$v1
	
	#Dodanie wartosci koñca lini do bufora z rezultatem 
	add $t2,$zero,10
	sb $t2,($a0)
	
	#wyœwietlenie komunikatu z otrzymanym rezultate
	la $a0,info_result
	la $a1,result
	li $a2,4
	jal showResults
	
	#wyswietelnie komunikatu z iloscia takich samych znakow
	la $a0,info_counter1
	move $a1,$t0
	li $a2,1
	jal showResults
	
	#wyswietelnie komunikatu z iloscia roznych znakow
	la $a0,info_counter2
	move $a1,$t1
	li $a2,1
	jal showResults
	
	j exit
	
#wyswietlenie komunikatu i pobranie tekstu od uzytkonika
#Zapisuje podany tekst w adresie podanym w rejestrze $a2
# $a0 - adres wyswietlonego tekstu
# $a1 - dlugosc tekstu do pobrania
# $a2 - adres w pamieci do przechowania podanego tekstu  
getData:
	syscall 
	
	add $a0, $a2, $zero 
	addi $v0, $zero, 8
	syscall
	
	jr $ra

#Poszukiwanie odresu ostatniego znaku w tekscie
# $a0 - adres lañcucha 
findTextEnd:
	lb $v0 , ($a0)
	beqz $v0,endFindTextEnd
	beq $v0,10,endFindTextEnd
	addu $a0, $a0 ,1
	b findTextEnd
	
#Odjecie wartosci jeden od podanego adresu (znaku 0 lub koñca lini )
#przeniesienie wartoœci do rejestru $v0
endFindTextEnd:
	subu $a0, $a0, 1
	move $v0,$a0
	jr $ra

#funckja bada czy podane tkesty, maja na tych smaych pozycjach identyczne znaki 
# $a0 - adres ostatniego znaku tekstu1
# $a1 - adres istatniego znaku tekstu2
# $a2 - dlugosci tekstow
#Funkcja zwraca ci¹g znaków do bufora. oraz licze tych smaych oraz liczbe roznych wystapien znaku na danej pozycji

task1:
	beqz $a2, exit_task1
	lb $t0, ($a0)
	lb $t1, ($a1)
	beq $t0,$t1,addCharToStack
	j addDolarToStack

#dodawanie do stosu znaku 	
addCharToStack:
	sub $sp,$sp,4
	sw $t1,($sp)
	subi $a2,$a2,1
	sub $a0,$a0,1
	sub $a1,$a1,1
	addu $s4,$s4,1
	j task1
#dodawanie do stosa znaków $ i * 
addDolarToStack:
	sub $sp,$sp,4
	add $t0,$zero,0x00000024
	sw $t0,($sp)
	subi $a2,$a2,1
	sub $a0,$a0,1
	sub $a1,$a1,1
	addu $s5,$s5,1
	j task1

exit_task1:
	#przeniesienie wartosci do rejestrow zawirajacych rezultat funkcji 
	move $v0, $s4
	move $v1, $s5
	la $a0, result
	j addResultToBuffer
	
#Dodawanie do bufera ciagu znakow pobranych ze stosu
# w rejestzre $a0 przekazujemy adres bufra przechowujacego resultat
addResultToBuffer:
	lb $t0, ($sp) # za³aduj znak ze sotsu do $t0
	sb $t0,($a0) #przenies znak do bufora
	beq $sp,$s7, exit_addResultToBuffer #wyjdz jezeli wskaŸnik stosu pokrywa sie z poczatkowym stanem stosu
	add $sp,$sp,4 #zwieksz wskaznik stosu o 4 s³owa 
	addi $a0,$a0,1 #zwieksz adres o jedno s³owo 
	b addResultToBuffer
exit_addResultToBuffer:
	jr $ra

#wyswietlenie wynikow programu
showResults:
	li $v0, 4
	syscall
	move $a0, $a1
	move $v0, $a2
	syscall
	
	jr $ra 

#wyjatek dotyczacy wprowadzenia tekstow o roznej dlugosci
exception_1:
	li $v0,4
	la $a0, exceptionText_1
	syscall  # wyswietelnie informacji o wyjatku
	la $a0, ask_1
	syscall #wyswietlenie zapytania o ponowne podanie danych 
	li $v0,5
	syscall
	beqz $v0,main #jezeli wprowadzono 0 powrot do poczatku programu 
	
	j exit
	
#wyjscie z programu
exit:
	li $v0, 10
	syscall
