; Libreria 'grafico.asm' es la que alberga todas las funciones necesarias para imprimir un frame BMP en pantalla.
; la unica funcion publica es la 'imprimePantalla'.


; Pasos a seguir para generar imagen BMP utilizando Photoshop:
; 1. Abrir Photoshop y la imagen a convertir xd.
; 2. Convertir la resolucion: -> Imagen -> Tamaño de Imagen (anchura 320 x altura 200).
; 3. Configurar colores: -> Imagen -> Modo -> Color Indexado (colores 256).
; 4. Guardar imagen: -> Guardar Como (.bmp).

.8086
.model small
.stack 100h


.data
    filehandle dw ?
    Header db 54 dup (0)
    Palette db 256*4 dup (0)
    ScrLine db 320 dup (0)

.code
    public imprimePantalla
    public tam_ad
main proc
    ; Libreria.
main endp

tam_ad proc
    push bp
    mov bp, sp
    push bx
    push cx
    push si
    push ax
    pushf

    mov bx, ss:[bp+4] ;palabraBuscada
    mov si,ss:[bp+6] ;palabraMostrada

palabra:
    cmp byte ptr[bx],24h
    je listo
    cmp byte ptr[bx],20h
    je espacio
    cmp byte ptr[bx],61h
    jl noesletra
    cmp byte ptr[bx],7ah
    jg noesletra
    jmp guion

noesletra:
    inc bx
    jmp palabra

guion:
    mov byte ptr[si],2dh
    inc bx
    inc si
    jmp palabra

espacio:
    mov byte ptr[si],20h
    inc si
    inc bx
    jmp palabra

listo:
    popf
    pop ax
    pop si
    pop cx
    pop bx
    pop bp
    ret 4
tam_ad endp


proc imprimePantalla
; Entrada: DX = offset de la variable donde se almacena el nombre del archivo BMP que se quiere imprimir.
; Salida:

    push bp
    mov bp, sp
    pushf
    ; Guardamos en stack los siguientes registros solamente en esta funcion ya que las demas funciones estan ligadas a esta.
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    ; Procesamos el archivo BMP:
    call cargaDelArchivo
    call lecturaDelHeader
    call lecturaDelPalette
    call copiaDelPalette
    call copiaDelBitmap
    call cierreDelArchivo

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    pop bp
    ret
endp imprimePantalla

proc cargaDelArchivo
; Proceso 'cargaDelArchivo' se utiliza para abrir la imagen BMP y guardar el handler en [filehandler].
; Entrada: DX = offset de la variable donde se almacena el nombre del archivo BMP que se quiere imprimir.
; Salida: [filehandle] con el handle del archivo bmp.

    push bp
    mov bp, sp
    pushf

    xor al, al
    mov ah, 03Dh
    int 21h

    mov [filehandle], ax

    popf
    pop bp
    ret
endp cargaDelArchivo

proc lecturaDelHeader
; Entrada:
; Salida:
    push bp
    mov bp, sp
    pushf

    ; Leemos el header del archivo BMP, son 54 bytes.
    mov ah, 03Fh
    mov bx, [filehandle]
    mov cx, 054
    mov dx, offset Header
    int 21h

    popf
    pop bp
    ret
endp lecturaDelHeader

proc lecturaDelPalette
; Entrada:
; Salida:

    push bp
    mov bp, sp
    pushf

    ; Leemos el palette de colores del archivo BMP, son 256 colores * 4 bytes (400h).
    mov ah, 03Fh
    mov cx, 400h
    mov dx, offset Palette
    int 21h

    popf
    pop bp
    ret
endp lecturaDelPalette

proc copiaDelPalette
; Copiamos el palette de colores en la memoria de video.
; Entrada:
; Salida:

    push bp
    mov bp, sp
    pushf

    ; Copiamos el primer color en el puerto 3C8h:
    mov dx, 3C8h
    mov al, 000
    out dx, al

    ; Copiamos el palette en el puerto 3C9h:
    mov dx, 3C9h
    mov si, offset Palette
    mov cx, 256
    loopPalette:
        ; Nota: los colores en un archivo BMP son guardados como BGR en vez de RGB. 

        ; Copiamos el color rojo en el puerto:
        mov al, [si+2]
        shr al, 2
        out dx, al

        ; Copiamos el color verde en el puerto:
        mov al, [si+1]
        shr al, 2
        out dx, al

        ; Copiamos el color azul en el puerto:
        mov al, [si]
        shr al, 2
        out dx, al

        add si, 4
        ; Hay un caracter null despues de cada color.
    loop loopPalette

    popf
    pop bp
    ret
endp copiaDelPalette

proc copiaDelBitmap
; Entrada:
; Salida:

    push bp
    mov bp, sp
    pushf

    ; Los graficos BMP son guardados al reves.
    ; Leemos linea por linea los graficos (son 200 lineas en el formato VGA), mostrando las lineas desde abajo para arriba.

    mov ax, 0A000h
    mov es, ax
    mov cx, 200
    loopImprimeBMP:
        push cx

        mov di, cx
        shl cx, 006
        shl di, 008
        add di, cx

        ; Leemos una linea:
        mov ah, 03Fh
        mov cx, 320
        mov dx, offset ScrLine
        int 21h

        ; Limpiamos el flag de direccion:
        cld

        ; Copiamos la linea en la memoria de video:
        mov cx, 320
        mov si, offset ScrLine
        rep movsb

        pop cx
    loop loopImprimeBMP

    popf
    pop bp
    ret
endp copiaDelBitmap

proc cierreDelArchivo
; Proceso 'cierreDelArchivo' se utiliza para cerrar el archivo abierto indicado en filehandler, y dejando el handler libre para abrir otros archivos.
; Entrada:
; Salida:

    push bp
    mov bp, sp
    pushf

    mov ah, 03Eh
    mov bx, [filehandle]
    int 21h

    popf
    pop bp
    ret
endp cierreDelArchivo

end main 