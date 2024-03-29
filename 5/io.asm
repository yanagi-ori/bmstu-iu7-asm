PUBLIC input_unsigned_oct
PUBLIC Number

DSEG SEGMENT PARA PUBLIC 'DATA'
	InputMSG            db "Input unsigned octal number: ", '$'
    NumberErrorMSG      db "Incorrect number. Please, try again.", '$'
	Number				dw 0                       	; число занимает 16 бит, старший бит может рассматриваться как знаковый при выводе в знаковом представлении
	Endline             db 13, 10, '$'
DSEG ENDS

CSEG2 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG2, DS:DSEG               

input_unsigned_oct proc far
	mov dx, OFFSET InputMSG
    mov ah, 09h
    int 21h                                

    mov dx, OFFSET Endline
	int 21h

    xor bx, bx                              ; зануляем регистр, в который мы будем вводить наше число

    mov cx, 5                               ; в 16 бит влезет максимум 5 восьмеричных цифр (по 3 бита каждая)
    mov ah, 01h                             ; выставляем функцию ввода символа

    int 21h                                 ; вводим 1-ю цифру числа
    cmp al, '0'                             
    jne next_check

    xor al, al                              ; если 1-я цифра равна 0, то в al помещаем 0 и вставляем число
    inc cx                                  ; восьмеричная цифра в начале, если она равна 0 или 1, занимает 1 бит, а в оставшиеся 15 можно записать ещё 5 цифр, т.е. всего в числе их будет 6, поэтому в цикле будет 6 итераций (вставок цифр)
    jmp insert_digit

    next_check:
    	cmp al, '1'
    	jne input_digits_loop                   ; если 1-я цифра не равна 0 или 1, то обрабатываем символ в цикле как обычно

    	mov al, 1                               ; если 1-я цифра равна 1, то в al помещаем 1 и вставляем число
    	inc cx
    	jmp insert_digit                        ; восьмеричная цифра в начале, если она равна 0 или 1, занимает 1 бит, а в оставшиеся 15 можно записать ещё 5 цифр, т.е. всего в числе их будет 6, поэтому в цикле будет 6 итераций (вставок цифр)
    
    	input_digits_loop:

        	cmp al, 13
        	je exit_success                	; нажатие enter является признаком окончания ввода

        	sub al, '0'            		; вычитаем '0', чтобы получить из кода символа само число (цифру)

        	cmp al, 7
        	ja exit_failure                 ; если цифра не восьмеричная, выходим, печатая сообщение об ошибке

        	insert_digit:
        	mov dx, cx                      ; сохраняем значение счётчика цикла в регистр dx
        	mov cl, 3
        	shl bx, cl                      ; сдвигаем число на 3 двоичных разряда влево
        	mov cx, dx                      ; восстанавливаем значение счётчика цикла из регистра dx

        	add bl, al                   	; помещаем введённную цифру в конец числа
        
        	int 21h                      	; вводим символ
            
        	loop input_digits_loop

    	cmp al, 13                              ; после цифр ожидаем enter
    	jne exit_failure
    
    	exit_success:
    		mov Number, bx                          ; помещаем полученное число в Number только при полностью успешном вводе
    		ret
    
    	exit_failure:
    		mov dx, OFFSET Endline
	mov ah, 09h
	int 21h

	mov dx, OFFSET NumberErrorMSG           
	int 21h

    mov dx, OFFSET Endline
	int 21h
    
    ret
input_unsigned_oct endp
CSEG2 ENDS
END
