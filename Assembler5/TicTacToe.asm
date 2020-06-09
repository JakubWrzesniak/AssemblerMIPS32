.data

znaki: 			.word 'X', 'O'
initialCharcter: 	.asciiz "Wybierz : X lub O\n" 
initialNumOfGames: 	.asciiz "\nPodaj ilosc rozgrywek(1-5)\n"
choiceValue: 		.asciiz "\nTwój ruch: "
computerMove: 		.asciiz "\nRuch komputera:\n\n"
oneMoreGame: 		.asciiz "\nCzy chcesz zagrac jeszcze raz?\n1-tak\n0-nie\n"
win: 			.asciiz "\nZwyciestwo!!!\n"
lose: 			.asciiz "\nPrzegrana :(\n"
drow: 			.asciiz "\n!Remis!\n"
compRes: 		.asciiz "\nPunkty komputera: " 
userRes: 		.asciiz "\nUzyskane punkty: "
nextLine: 		.asciiz "\n"
exception1: 		.asciiz "\nWybrano nieistniejaca wartosc\nWybierz ponownie wartosc:\n"
exception2: 		.asciiz "\nWybrana pozaycja jest juz zajeta. Wybierz inna pozycje. \n"

.text

main:
	# $s0 adres tablicy
	# $s1 punkty komputera
	# $s2 rozmiar tablicy
	# $s3 znak wybrany przez uzytkownika
	# $s4 znak uzywany przez komputer
	# $s5 ilosc rund
	# $s6 wybrana przez uzytkownika pozycja
	# $s7 punkty u¿ytkownika
			
	#Zainicjowanie tablicy
	lui $s0, 0X1004 #adres poczatku tablicy
	ori $s0, 0x0000
	li $t7, 0 	#wartoœæ indeksu tablicy
	li $s2, 9	#maksymalny rozmiar tablicy
	
	
	
	#Wybranie znaku przez u¿ytkownika 
	la $t1, init
	jalr $t3, $t1	
	
	#Podanie iloœci rund
	jal gamesNumber
	
	game:
	#Wpisanie w tablice wartoœci od 1 do 9 
	li $t7,0
	jal setNumberInArray
	
	
	
	#Wyswietelnie tablicy
	jal showArray
	
	#Gra w kó³ko i krzy¿yk 
	li $t6,0 #Wyzerowanie licznika
	j run
	
run:	
	
	#Wyswietlenie prosby o padanie pola
	la $a0, choiceValue
	jal showString
	
	#Pobranie numeru pola od u¿ytkownika
	li $v0, 5
	syscall
	
	#Sprawdzenie czy podana liczba mieœci siê w zakresie 1-9 
	bgt $v0,9, numberException
	blt $v0,0, numberException
	
	#Dodanie znaku na odpowiedniej pozycji w tablicy
	move $s6,$v0
	move $a0,$s6
	move $a1,$s3
	jal addToArray
	
	#Wyswietlenie aktualnej tabeli
	jal showArray
	
	#Sprawdzenie czy jest zwysiezca
	jal checking

	#Jezeli jest 5 raunda to porgram ju¿ nie wykonuju ruchu
	li $t0, 4
	beq $t6,$t0,again
	
	#Ruch komputera
	jal checkPositions
	
	#wyswietlenie komunikatu
	la $a0,computerMove
	jal showString
	
	#WyswietelnieTablicy
	jal showArray
	#sprawdzenie czy komputer nie wygra³
	jal checking
	
	#zwiekszenie numeru rundy o 1
	addi $t6 ,$t6,1
	b run

#Sprawdzenie czy jest zwyciezca
#rozpatrywane sa wszystkie kombinacje 
checking:
	
	move $a0,$ra
	jal push
	blt $t6,2,res #wykonanie tylko powyzej drugiej rundy
	#sprawdzenie wygranej
	li $a1,0
	li $a2,1
	li $a3,2
	jal checkWinner
	li $a1,3
	li $a2,4
	li $a3,5
	jal checkWinner
	li $a1,6
	li $a2,7
	li $a3,8
	jal checkWinner
	li $a1,0
	li $a2,3
	li $a3,6
	jal checkWinner
	li $a1,1
	li $a2,4
	li $a3,7
	jal checkWinner
	li $a1,2
	li $a2,5
	li $a3,8
	jal checkWinner
	li $a1,0
	li $a2,4
	li $a3,8
	jal checkWinner
	li $a1,2
	li $a2,4
	li $a3,6
	jal checkWinner
	res:
	jal pop
	jr $v0

#Sprawdzenie pozycji, która wybra³ u¿ytkownik
checkPositions:
	move $a0, $ra
	jal push
	beq $s6 ,1 , checkPos1
	beq $s6 ,2 , checkPos2
	beq $s6 ,3 , checkPos3
	beq $s6 ,4 , checkPos4
	beq $s6 ,5 , checkPos5
	beq $s6 ,6 , checkPos6
	beq $s6 ,7 , checkPos7
	beq $s6 ,8 , checkPos8
	beq $s6 ,9 , checkPos9
	
#Próba zablokowania wygranej przez u¿ytkownika w zale¿onoœci od ruchu 
checkPos1:
	#pobranie wartoœci z tabablicy z pozycji 2
	li $a0,1
	jal getArrayValue
	beq $v0, $s3, add3#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,2
	jal getArrayValue
	beq $v0, $s3, add2#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,3
	jal getArrayValue
	beq $v0, $s3, add7#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add9#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,6
	jal getArrayValue
	beq $v0, $s3, add4#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,8
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add7
	
checkPos2:
	li $a0,0
	jal getArrayValue
	beq $v0, $s3, add3#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,2
	jal getArrayValue
	beq $v0, $s3, add1#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add8#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,7
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add7
checkPos3:
	li $a0,0
	jal getArrayValue
	beq $v0, $s3, add2#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,1
	jal getArrayValue
	beq $v0, $s3, add1#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add7#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,5
	jal getArrayValue
	beq $v0, $s3, add8#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,6
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,8
	jal getArrayValue
	beq $v0, $s3, add6#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add9
checkPos4:
	li $a0,0
	jal getArrayValue
	beq $v0, $s3, add7#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add6#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,5
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,6
	jal getArrayValue
	beq $v0, $s3, add1#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add1
checkPos5:
	li $a0,0
	jal getArrayValue
	beq $v0, $s3, add9#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,1
	jal getArrayValue
	beq $v0, $s3, add8#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,2
	jal getArrayValue
	beq $v0, $s3, add7#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,3
	jal getArrayValue
	beq $v0, $s3, add6#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,5
	jal getArrayValue
	beq $v0, $s3, add4#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,6
	jal getArrayValue
	beq $v0, $s3, add3#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,7
	jal getArrayValue
	beq $v0, $s3, add2#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,8
	jal getArrayValue
	beq $v0, $s3, add1#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add9
checkPos6:
	li $a0,2
	jal getArrayValue
	beq $v0, $s3, add9#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,3
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add4#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,8
	jal getArrayValue
	beq $v0, $s3, add3#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add1
checkPos7:
	li $a0,0
	jal getArrayValue
	beq $v0, $s3, add4#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,2
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,3
	jal getArrayValue
	beq $v0, $s3, add1#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add3#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,7
	jal getArrayValue
	beq $v0, $s3, add9#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,8
	jal getArrayValue
	beq $v0, $s3, add8#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add9
checkPos8:
	li $a0,1
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add2#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,6
	jal getArrayValue
	beq $v0, $s3, add9#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,8
	jal getArrayValue
	beq $v0, $s3, add7#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add3
checkPos9:
	li $a0,0
	jal getArrayValue
	beq $v0, $s3, add5#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,2
	jal getArrayValue
	beq $v0, $s3, add6#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,4
	jal getArrayValue
	beq $v0, $s3, add1#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,5
	jal getArrayValue
	beq $v0, $s3, add3#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,6
	jal getArrayValue
	beq $v0, $s3, add8#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	li $a0,7
	jal getArrayValue
	beq $v0, $s3, add7#jezeli jest tam znaku uzytkownika, to blokuj jego dzialania
	j add3
		
#Dodawanie znaku komputera na odpowiedniej pozycji 
add1:	
	li $a0,0
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add2
	beq $v0, $s4, add9
	move $a1,$s4
	jal setArrayValue

add2:
	li $a0,1
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add3
	beq $v0, $s4, add3 
	move $a1,$s4
	jal setArrayValue
add3:
	li $a0,2
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add6
	beq $v0, $s4, add6 
	move $a1,$s4
	jal setArrayValue
add4:
	li $a0,3
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add5
	beq $v0, $s4, add7 
	move $a1,$s4
	jal setArrayValue
add5:
	li $a0,4
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add6
	beq $v0, $s4, add2  
	move $a1,$s4
	jal setArrayValue
add6:
	li $a0,5
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add9
	beq $v0, $s4, add4  
	move $a1,$s4
	jal setArrayValue
add7:
	li $a0,6
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add8
	beq $v0, $s4, add8   
	move $a1,$s4
	jal setArrayValue
add8:
	li $a0,7
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add9
	beq $v0, $s4, add2   
	move $a1,$s4
	jal setArrayValue
add9:
	li $a0,8
	jal getArrayValue
	#sprawdzenie czy w danym miejscu nie znajduje siê siê ju¿ znak
	beq $v0, $s3 ,add3
	beq $v0, $s4, add5  
	move $a1,$s4
	jal setArrayValue


#funkcja sprawdz czy w podanych trzech polach znjaduja sie te same znaki
# $a1, $a2, $a3 - przeszukwiane pola
checkWinner:
	move $a0, $ra
	jal push
	#zapisanie pierwszej wartoœci
	move $a0,$a1
	jal getArrayValue
	move $a1, $v0
	#zapisanie drugiej wartoœci
	move $a0,$a2
	jal getArrayValue
	move $a2, $v0
	#zapisanie trzeciej wartoœci
	move $a0,$a3
	jal getArrayValue
	move $a3, $v0
	
	seq $t8,$a1,$a2 #jezeli pierwsza i druga wartoœc s¹ ró¿ne to wyjdŸ z funkcji
	beqz $t8,return
	seq $t9,$a2,$a3 #sprawdzenie równoœci drugiej i trzeciej wartoœci
	seq $v0,$t8,$t9 #sprawdzenie czy obie równoœci da³y ten sam rezultat
	
	bnez $v0,winner #jezeli zasz³a równoœc w pierwszym i drugim warunku to mamy zwyciêzce
	return:
	jal pop
	jr $v0

#Remis, wyœwietlenie komunikatu
drows:
	la $a0,drow
	jal showString
	j again
#Zwyciêzca
winner:
	beq $a1,$s3,w #Jezeli w przeszukiwanych polach by³ znak wybrany przez u¿ytkownika to jest on zwyciêzc¹ 
	beq $a1,$s4,l #jezeli nie to zwyciêzc¹ musi byæ komputer
	w:
	la $a0,win
	addi $s7,$s7,1
	b r
	l:
	la $a0,lose
	addi $s1,$s1,1
	r:
	jal showString
	j again
	
#Zapytanie u¿ytkownika czy chce zagraæ jeszcze raz
again:
	subi $s5,$s5,1
	bgtz $s5 game
	j exit

#ustawienie w tablicy kolejnych liczb od 1-9 oznaczaj¹cyh pozycje 
setNumberInArray:
	beq $t7,$s2,done
	li $t0,0
	sll $t0,$t7,2
	add  $t0, $t0, $s0 
	addi $t1, $t7,49 #Dodanie 49 do liczby (ascii)
	sw   $t1,0($t0)
	addi $t7, $t7, 1
	j setNumberInArray
	
init:	
	#zapisanie do rejestru adresu tabli zewieraj¹cej dostêpne znaki
	la $t0, znaki
	#Wybor X lub O
	la $a0, initialCharcter
	jal showString
	#pobranie od uzytkowanik x lub o 
	li $v0, 8
	li $a1, 2
	syscall 
	
	lb $t1, 0($a0) #zapisanie do rejestrue wartoœci wyboru u¿ytkownika 
	lb $t2, 0($t0) #zapisanie do rejestru wartoœci "X"
	#skok je¿eli wybrano x
	beq $t1,$t2,chosenX
	lb $t2, 4($t0) #zapisanie do rejestru wartoœci "O"
	#Skok je¿eli wybrano O
	beq $t1,$t2,chosenO
	#wyœwietlenie wyj¹tku, je¿eli wybrano znak spoza tablic znaki 
	la $a0,exception1
	jal showString 
	b init
	
#Ustawienie wyborów
chosenX:
	lb $s3, 0($t0) #u¿ytkownik wybiera X
	lb $s4, 4($t0) #komputerowwi zostaje przydzielone O
	jr $t3
chosenO:
	lb $s3, 4($t0) #U¿ytkownik wybiera O
	lb $s4, 0($t0) #Komputerowi zostaje przydzielony X
	jr $t3

#zapisywanie podanje wartoœci na podanej pozycji w tablicy(X lub O)
# $a0 - pozcyja
# $a1 - znak do dodania 
addToArray:
	
	subi $a0, $a0, 1  #zmniejszenie podanej pozycji o 1 
	sll $t0, $a0,2	
	add $t0, $t0, $s0 #zapisanie do rejestru $t0 adresu sprawdzanej pozycji w tablicy
	lb $t1, 0($t0) 	  #Pobranie wartoœci zpaisanej w danym mijescu w tablicy
	#Jezli w danym mijescu w tablicy jest X lub O to brnachuj do wyjatku
	beq $s3, $t1, wrongPosException	
	beq $s4, $t1, wrongPosException
	#Zapisanie na podanej pozycji odpowiedniego znaku 
	sw $a1, 0($t0)
	jr $ra
#Podanie przez uzytkownika liczby rund
gamesNumber:
	move $a0, $ra
	jal push
	la $a0, initialNumOfGames
	jal showString
	jal pop
	move $ra,$v0
	
	#pobranie numeru od u¿ytkownika
	li $v0,5 
	syscall
	
	#sprawdzenie poprawnosci wartoœci
	bgt $v0, 5, numberException
	blt $v0, 1, numberException
	
	move $s5,$v0
	jr $ra
#wyj¹tek w przypadku wporwadzenia liczby spoza zakresu
numberException:
	move $a0,$ra
	jal push
	la $a0,exception1
	jal showString
	jal pop
	move $ra, $v0
	addi $ra, $ra, -4
	jr $ra

#Wyj¹tek w przypadku gdy u¿ytkownik chce postawiæ znak na ju¿ zajêtym miejscu
wrongPosException:
	#zapisanie wartoœci rejestru $ra na stos
	move $a0,$ra
	jal push
	#wyswietlenie komunikatu wyj¹tku
	la $a0,exception2
	jal showString
	#pobranie wartoœci ze stosu
	jal pop
	move $ra, $v0
	
	j run
#Pobranie z tablicy wartosci na zadanej pozycji
# $a0 - pozycja
getArrayValue:
	move $t0,$a0
	sll $t0,$t0,2
	add $t0, $t0, $s0
	lb  $v0, 0($t0)
	jr $ra
#Dodanie do tablicy danej wartoœci na danej pozycji
# $a0 - pozycja	
# $a1 - wartosc do zapisania
setArrayValue:
	move $t0, $a0
	sll $t0,$t0,2
	add $t0, $t0, $s0
	sw $a1,($t0)
	jal pop
	jr $v0
#Wyswietlenie tablicy 3X3
showArray:
	move $a0, $ra
	jal push
	#ustawienie licznikow na 0
	li $t7, 0
	li $a1, 0 
	j printArray
printArray:
	beq $s2,$t7,donePrintArray
	li $t0,0
	sll $t0,$t7,2
	add  $t0, $t0, $s0
	move   $a0, $t0
	jal showString
	addi $t7, $t7, 1
	beq $a1,2, printNextLine #Co trzeci znak zostaje wyswietlony znak nowej lini
	addi $a1, $a1,1
	j printArray
donePrintArray:
	jal pop
	jr $v0	
done:
	jr $ra
push:
	subi $sp , $sp , 4
	sw $a0, 0($sp)
	jr $ra
pop:
	lw $v0, 0($sp)
	addi $sp ,$sp, 4
	jr $ra 
	
#Wyswietlenie znaku nowej lini
printNextLine:
	la $a0, nextLine
	li $v0, 4
	syscall
	li $a1, 0
	j printArray
#Wyœwietlenie tekstu
#$a0 - tekst do wyœwietlenia
showString: 
	li $v0,4
	syscall
	jr $ra

#Wyjscie z progrmu 
exit:	
	#Wyœwietlenie wyniku ¿ytkownika
	la $a0,userRes
	jal showString
	li $v0, 1
	move $a0,$s7
	syscall
	#Wyœwietlenie wyniku komputeraz
	la $a0,compRes
	jal showString
	li $v0,1
	move $a0,$s1
	syscall
	#Wyjscie z programu 
	li $v0,10 
	syscall 
	