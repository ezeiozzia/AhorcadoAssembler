.8086
.model small
.stack 100h
.data

 ;LVariables fun_palabra.
 archivo db "palabras.txt",24h
 filehandler db 00h,00h
 leer_caracter db 20h
 
 ;Variables fun_aleatorio
 var_aleatorio db 0,24h

.code

;declaracion de funciones para exteriorizar
public fun_palabra

main proc
	; Vacìo, es libreria.
main endp

fun_palabra proc  
;Recibe el offset para guardar la palabra leida por stack.

	push bp
	mov bp, sp	
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
		
	mov si, ss:[bp+4]
	call fun_aleatorio 	
	add ax, 30h
	push ax

	lea dx,archivo
  	mov ah,3dH
  	mov al,0
  	int 21H
  	mov word ptr[filehandler], ax

caracter:
	mov ah,3FH
  	mov bx, word ptr [filehandler]
  	mov cx,1
  	lea dx,leer_caracter
  	int 21H

  	cmp ax,0
  	je final_archivo
  	mov dl,leer_caracter
  	pop ax
  	cmp dl, al
  	je lee_pal
  	push ax
  	jmp caracter

lee_pal:
	mov ah,3FH
  	mov bx, word ptr [filehandler]
  	mov cx,1
  	lea dx,leer_caracter
  	int 21H

  	cmp ax,0
  	je palabra_final
  	mov dl,leer_caracter
  	cmp dl, 0Dh
  	je palabra_final
  	mov [si], dl
  	inc si
  	jmp lee_pal  	

final_archivo:
	pop ax

palabra_final:
	mov ah, 3Eh
	mov bx, word ptr [filehandler]
	int 21h

	mov bx, offset filehandler
	mov byte ptr[bx], 00h
	inc bx
	mov byte ptr[bx], 00h

	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
fun_palabra endp

fun_aleatorio proc
;Crea un numero aleatorio entre cero y nueve.
;Devuelve el numero en ax(al).
	push cx
	push dx
	pushf

	mov ah, 2ch
	int 21h

	xor ax, ax
	mov al, dl
	mov cl, 0ah
	div cl
	xor ah, ah
	
	popf
	pop dx
	pop cx
	ret
fun_aleatorio endp

end main 