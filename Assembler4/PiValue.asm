.data
in_text: .asciiz "Podaj dokladnosc liczby pi:\n" 
res_text: .asciiz "Przyblizenie liczby pi wynosi: "
init_denominator: .float 1.0
shift_denominator: .float 2.0
four: .float 4.0
negativ: .float -1.0
zero: .float 0
.text

main:
	#pobranie dok³adnoœci od u¿ytkownaika 
	la $a0, in_text
	jal showText
	jal readInt
	#zapisanie pobrnaej wartoœci w rejestrze $s0 
	move $s0, $v0
	
	#zapisanie do rejestrów wartoœci 1,2,4
	lwc1 $f20, init_denominator
	lwc1 $f22, shift_denominator
	lwc1 $f24, four
	lwc1 $f26, negativ
	lwc1 $f28, zero
	
	#dodanie na stos wartosci 0 - suma
	mov.s $f12, $f28
	jal push 
	
	#dodanie na stos wartosci 1 - dzielnik
	mov.s $f12, $f20
	jal push 
	
	j sum_calculate
	
sum_calculate:

	blez $s0, pi_value #petla if($s0 > 0)
	#Jezeli uzytkownik poda³ 0 lub liczbe ujemna, program zwraca zero 
	
	#pobranie dzielnika ze stosu i zapisanie go w rejetzre $f4
	jal pop
	mov.s $f4, $f0
	#pobranie sumy ze stosu i zapisanie jej w rejestrze $f6
	jal pop 
	mov.s $f6, $f0
	
	div.s $f8, $f20, $f4 #obliczenie ilorazu 1/dzielnik 
	add.s $f6, $f6, $f8 #Dodanie do sumy wniku z dzielenia
	mul.s $f4, $f4, $f26 #zmiana zanku licznika
	c.lt.s $f4,$f28 #sprawdzenie zaku mianownika
	
	add $ra,$zero,0x00400084 #zapisanie warosci wskaznika $pc
	bc1f addition  #dodawanie dla dodatniego mianownika
	add $ra,$zero,0x00400094
	bc1t subtracion #Odejmowanie dla ujemnego mianownika

	sub $s0, $s0,1 # zmieniszenie licznika pêtli $s0 

	#dodanie na stos sumy 
	mov.s $f12, $f6
	jal push 
	
	#dodanie na stos dzielnika 
	mov.s $f12, $f4
	jal push
	
	j sum_calculate #powtorzenie petlii
addition:
	add.s $f4, $f4, $f22 # zwiekszenie dzielnika o 2
	jr $ra
subtracion:
	sub.s $f4, $f4, $f22 # zmniejszenie dzielnika o 2
	jr $ra

pi_value:
	#pobranie ze stosu wartosci sumy
	lwc1 $f4, 4($sp)
	
	#mnozenie 4 * uzyskana_suma
	mul.s $f6 ,$f24, $f4
	
	#wyswuetlenie komunikatu
	la $a0,res_text
	jal showText

	#wyœwietlenie resultatu 
	li $v0, 2
	mov.s $f12, $f6
	syscall
	j exit 
	
#dodanie na stos	
push:
	subi $sp, $sp, 4
	swc1 $f12, 0($sp)
	jr $ra
#sciagniesie ze sotsu
pop:
	lwc1 $f0, 0($sp)
	addi $sp,$sp,4
	jr $ra	
#wyswuetlenie integera
readInt:
	li $v0,5
	syscall
	jr $ra
#wyœwietelnie tekstu
showText:
	li $v0, 4
	syscall
	jr $ra
#wyjœcie z programu
exit:
	li $v0, 10 
	syscall
	
