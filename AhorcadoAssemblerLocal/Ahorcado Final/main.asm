.8086
.model small
.stack 100h

.data
	; Mensajes del juego.
	mjs_LU db "Letras: ",24h
	mjs_tema db "Tema: ",24h
	mjs_pts db "Aciertos: ",24h
	mjs_vidas db "Vidas: ",24h 

	; Imagenes del juego.
	img_menu db "Fondo_M.bmp",0h
	img_Credits db "Fondo_C.bmp",0h
	img_GW db "Fondo_W.bmp",0h
	img_GO db "Fondo_O.bmp",0h
	img_1 db "Fondo_1.bmp",0h
    img_2 db "Fondo_2.bmp",0h
    img_3 db "Fondo_3.bmp",0h
    img_4 db "Fondo_4.bmp",0h
    img_5 db "Fondo_5.bmp",0h
    img_6 db "Fondo_6.bmp",0h
    img_7 db "Fondo_7.bmp",0h
  	
  	; Variables. 
	pal_ad db 20 dup (24h),24h
    pal_txt db 20 dup(24h),24h
    letra_us db 26 dup("-"),24h
    vidas db 36h
    pal_ac db 30h

.code
	extrn imprimePantalla:proc
	extrn fun_palabra:proc
	extrn tam_ad:proc
main proc 
	mov ax, @data
	mov ds, ax 
	mov ax, 0013h
	mov bx, 0000h
	int 10h

comienzo: 
	mov dx, offset img_menu
	call menu
	cmp al, 41h					; a o A Nuevo juego.
	je juego
	cmp al, 53h					; s o S Creditos.
	je creditos1
	cmp al, 44h					; d o D Salir.
	je fin1
	cmp al, 61h
	je juego
	cmp al, 73h
	je creditos1
	cmp al, 64h
	je fin1

juego:
	mov dx, offset pal_txt
	push dx
	call fun_palabra
	pop dx
	mov dx, offset pal_ad
	push dx
	mov dx, offset pal_txt
	push dx
	call tam_ad
	mov dx, offset img_1
	call screen

jugada: 
	mov ah, 08h
	int 21h 
	call minuscula
	cmp al, 61h
	jge es_letra
	jmp jugada

es_letra:
	cmp al, 7ah
	jle es_letra_2
	jmp jugada

es_letra_2:
	mov si, offset letra_us
	call l_usadas
	mov di, offset pal_txt
	mov si, offset pal_ad 
	call valida_letra
	cmp ah, 01h
	je esta
	jmp no_esta

esta:
	mov di, offset pal_txt
	mov si, offset pal_ad
	call ganador
	cmp ah, 01h
	je gano
	jmp no_gano
creditos1:
	jmp creditos
fin1:
	jmp fin
gano:
	mov dx, offset img_GW
	call imprimePantalla
	mov ah, 2dh
	mov al, 1ah
	mov si, offset letra_us
	call limpia_vec
	mov ah, 24h
	mov al, 14h
	mov si, offset pal_txt
	call limpia_vec
	mov ah, 24h
	mov al, 14h
	mov si, offset pal_ad
	call limpia_vec
	mov vidas, 36h
	mov al, pal_ac
	inc al
	mov pal_ac, al 
	mov ah, 08h
	int 21h
	jmp juego

no_gano:
	mov al, vidas
	cmp al, 36h
	je i1
	cmp al, 35h
	je i2
	cmp al, 34h
	je i3
	cmp al, 33h
	je i4
	cmp al, 32h
	je i5
	cmp al, 31h
	je i6
	cmp al, 30h
	je i7
	jmp jugada

no_esta: 
	mov al, vidas
	dec al
	mov vidas, al
	cmp al, 36h
	je i1
	cmp al, 35h
	je i2
	cmp al, 34h
	je i3
	cmp al, 33h
	je i4
	cmp al, 32h
	je i5
	cmp al, 31h
	je i6
	cmp al, 30h
	je i7
	jmp fin

i1:
	mov dx, offset img_1
	call screen
	jmp jugada
i2:
	mov dx, offset img_2
	call screen
	jmp jugada
i3:
	mov dx, offset img_3
	call screen
	jmp jugada
i4:
	mov dx, offset img_4
	call screen
	jmp jugada
i5:
	mov dx, offset img_5
	call screen
	jmp jugada
i6:
	mov dx, offset img_6
	call screen
	jmp jugada
i7:
	mov dx, offset img_GO
	call imprimePantalla
	mov ah, 2dh
	mov al, 1ah
	mov si, offset letra_us
	call limpia_vec
	mov ah, 24h
	mov al, 14h
	mov si, offset pal_txt
	call limpia_vec
	mov ah, 24h
	mov al, 14h
	mov si, offset pal_ad
	call limpia_vec
	mov vidas, 36h
	mov pal_ac, 30h
	mov ah, 08h
	int 21h
	jmp comienzo

creditos: 
	mov dx, offset img_Credits
	call imprimePantalla
	mov ah, 08h
	int 21h
	jmp comienzo
fin: 
	mov ax, 4c00h
	int 21h 
main endp 

menu proc
;Recibe el offset de la imagen del menu en dx; 
;Imprime el menu y valida la entrada. 

	;push ax	
	;push bx
	;push cx
	;push dx
	;push si
	;push di
	pushf

	call imprimePantalla

invalido: 
	mov ah, 08h
	int 21h

	cmp al, 61h
	je fin_menu
	cmp al, 73h
	je fin_menu
	cmp al, 64h
	je fin_menu
	cmp al, 41h
	je fin_menu
	cmp al, 53h
	je fin_menu
	cmp al, 44h
	je fin_menu

fin_menu: 
	popf
	;pop di
	;pop si
	;pop dx
	;pop cx
	;pop bx
	;pop ax
	ret
menu endp

screen proc
;Recibe en Dx el offset de la imagen.bmp a imprimir junto los mensajes.

	push ax	
	push bx
	;push cx
	push dx
	;push si
	;push di
	pushf

	call imprimePantalla

	; Cursor letras usadas:
	xor ax, ax 
	mov ah, 02h        									;Funcion de pos de cursor		
	mov dx, 0200h        								;Donde se posiciona el cursor
	int 10h

	mov ah, 09h
	mov dx, offset mjs_LU
	int 21h

	mov dx, offset letra_us
	int 21h

    ; palabra a adivinar.
    xor ax, ax 
    mov ah, 02h        									;Funcion de pos de cursor
    mov bx, 0000h	
	mov dx, 0a0bh        								;Donde se posiciona el cursor
	int 10h

	mov ah, 09h
	mov dx, offset pal_ad
	int 21h

    ; Cursor vidas
    xor ax, ax 
	mov ah, 02h        									;Funcion de pos de cursor				
	mov bx, 0000h
	mov dx, 131ah        								;Donde se posiciona el cursor
	int 10h

	mov ah, 09h
	mov dx, offset mjs_vidas
	int  21h

	mov ah, 02h
	mov dl, vidas
	int 21h

    ; Cursor palabras acertadas. 
    xor ax, ax 
	mov ah, 02h        									;Funcion de pos de cursor
	mov bx, 0000h
	mov dx, 151ah        								;Donde se posiciona el cursor
	int 10h

	mov ah, 09h
	mov dx, offset mjs_pts
	int  21h

	mov ah, 02h
	mov dl, pal_ac
	int 21h

	popf
	;pop di
	;pop si
	pop dx
	;pop cx
	pop bx
	pop ax
	ret
screen endp  

minuscula proc
	;Evalua un caracter que le llega en AL y si es una letra mayuscula,
	;la pasa a minuscula
	;push ax	
	;push bx
	;push cx
	;push dx
	;push si
	;push di
	pushf

	cmp al, 41h
	jge es_mayus
	jmp fin_minus

es_mayus: 
	cmp al, 5ah 
	jle es_mayus_2
	jmp fin_minus

es_mayus_2:
	add al, 20h

fin_minus: 
	popf
	;pop di
	;pop si
	;pop dx
	;pop cx
	;pop bx
	;pop ax
	ret
minuscula endp 

l_usadas proc
;Guarda el caracter ingresado en el vector letra_us.
;Recibe en si el offset del vector.
	push ax	
	;push bx
	;push cx
	push dx
	;push si
	;push di
	pushf

comp: 

	cmp al, [si]
	je ya_esta

	mov dl, [si]
	cmp dl, 2dh
	je cambia

	inc si 
	jmp comp

cambia: 
	mov [si], al

ya_esta: 
	popf
	;pop di
	;pop si
	pop dx
	;pop cx
	;pop bx
	pop ax
	ret
l_usadas endp

valida_letra proc
;Recibe el vector buscado en di y el mostrado en si.
;Valida si el caracter ingresado esta en la palabra buscada.
;Devuelve 01h en AH si esta en la palabra y 00h en Ah si no esta.
;Actualiza el vector que se muestra.
	;push ax	
	;push bx
	;push cx
	push dx
	;push si
	;push di
	pushf

	mov ah, 00h

vali_comp: 
	cmp [di], al
	je vista

	mov dl, [di]
	cmp dl, 24h
	je vali_fin

vali_vuelta:
	inc di 
	inc si
	jmp vali_comp

vista:
	mov ah, 01h
	mov [si], al
 	jmp vali_vuelta

vali_fin: 
	popf
	;pop di
	;pop si
	pop dx
	;pop cx
	;pop bx
	;pop ax
	ret
valida_letra endp

ganador proc
;Recibe el vector buscado(DI) y el mostrado(SI).
;Compara y si son iguales devuelve 01h en AH(ganado),
; de lo contrario devuelve 00h en AH. 

	;push ax	
	;push bx
	;push cx
	push dx
	;push si
	;push di
	pushf

	mov ah, 01h

gana_comp: 
	mov dl, [si]
	cmp dl, 24h
	je gana_fin
	cmp dl, [di]
	jne diferentes
	inc si
	inc di 
	jmp gana_comp

diferentes:
	mov ah, 00h

gana_fin:	
	popf
	;pop di
	;pop si
	pop dx
	;pop cx
	;pop bx
	;pop ax
	ret
ganador endp

limpia_vec proc 
;Rellena un vector recibio por parametro, con un caracter tambien recibido por registro.
;Recibe en SI el offset del vector a cargar, y en AX recibe dos parametros.
; En AH el caracter con el que debe rellenar y en AL el tamaño del vector.

	;push ax	
	;push bx
	push cx
	;push dx
	;push si
	;push di
	pushf

	mov cl, 00h

limpia_rellena:
	cmp cl, al
	je limpia_fin
	mov [si], ah 
	inc si
	inc cl 
	jmp limpia_rellena

limpia_fin:
	popf
	;pop di
	;pop si
	;pop dx
	pop cx
	;pop bx
	;pop ax
	ret
limpia_vec endp

end main