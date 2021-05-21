        .equ CODE_SEG, 8
        .equ DATA_SEG, gdt_data - gdt_start

        .code16
        cli                     #;Limpio la bandera de interrupciones
        
        lgdt gdt_descriptor     #;Indico al procesador donde está la tabla GDT en memoria
 
        mov %cr0, %eax          #;Se setea el bit menos significativo de CR0 sin afectar los demás
        orl $0x1, %eax
        mov %eax, %cr0

        ljmp $CODE_SEG, $protected_mode         

        gdt_start:
        gdt_null:                     #; El descriptor nulo
                .long 0x0             #; 'dd' o '.long' significa doble word (4 bytes)
                .long 0x0
        gdt_code:                     #; El  segmento descriptor de codigo

                .word 0xffff          #; Limite (bits 0 -15)
                .word 0x0             #; Base (bits 0 -15)
                .byte 0x0             #; Base (bits 16 -23)
                .byte 0b10011010      #; 1001(P DPL S) 1010(type codigo no accedido)
                .byte 0b11001111      #; 1100 ( G D/B 0 AVL)  ,1111  Limite(bits 16 -19)
                .byte 0x0             #; Base (bits 24 -31)

        gdt_data:                     #; El  segmento descriptor de datos

                .word 0xffff          #; Limite (bits 0 -15)
                .word 0x0             #; Base (bits 0 -15)
                .byte 0x0             #; Base (bits 16 -23)
                .byte 0b10010010      #;  1001(P DPL S) 0010(type codigo no accedido)
                .byte 0b11001111      #; 1100 ( G D/B 0 AVL)  ,1111  Limite (bits 16 -19)
                .byte 0x0             #; Base (bits 24 -31)
        gdt_end:

        gdt_descriptor:
                .word gdt_end - gdt_start -1 #; El tamaño de la tabla gdt es uno menos del calculado
                .long gdt_start              #; Dirección de comienzo del  GDT
        vga_current_line:
                .long 0

        .code32
        protected_mode:

                mov $DATA_SEG, %ax          #; Se carga el valor de DATA_SEG en todos los segmentos (menos CS que se actualiza en el ljmp)
                mov %ax, %ds
                mov %ax, %es
                mov %ax, %fs
                mov %ax, %gs
                mov %ax, %ss

                mov $0X7000, %ebp
                mov %ebp, %esp

                #; Configuración VGA memoria de video

                mov $message, %ecx
                mov vga_current_line, %eax
                mov $0, %edx
                mov $25, %ebx                   #; Numero de lineas horizontales
                div %ebx
                mov %edx, %eax
                mov $160, %edx                  #; Ancho de linea * bytes por caracter en pantalla
                mul %edx
                lea 0xb8000(%eax), %edx         #; 0xb8000 == direccion de memoria de video de monitores multicolor
                mov $0x4f, %ah                  #; El primer byte es el color de fondo y el segundo color de letras
        loop:
                mov (%ecx), %al
                cmp $0, %al
                je end
                mov %ax, (%edx)
                add $1, %ecx
                add $2, %edx
                jmp loop
        end:
                hlt
        message:
        .asciz "Esta computadora se autodestruira en 3 2 1 ...."


