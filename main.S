.equ CODE_SEG, 8
.equ DATA_SEG, gdt_data - gdt_start

.CODE16
        cli                    ;Clear interrupt flag
        /* Tell the processor where our Global Descriptor Table is in memory. */
        lgdt gdt_descriptor
        /* Set PE (Protection Enable) bit in CR0 (Control Register 0),
        * effectively entering protected mode.
        */
        mov %cr0, %eax
        orl $0x1, %eax
        mov %eax, %cr0

        ljmp $CODE_SEG, $protected_mode

gdt_start:
gdt_null:                  ; El descriptor nulo
        .long 0x0             ; 'dd' significa doble word (4 bytes)
        .long 0x0
gdt_code:                  ; El  segmento descriptor de codigo

        .word 0xffff          ; Limite (bits 0 -15)
        .word 0x0             ; Base (bits 0 -15)
        .byte 0x0             ; Base (bits 16 -23)
        .byte 10011010b       ; 1001(P DPL S) 1010(type codigo no 
                           ;accedido)
        .byte 11001111b       ; 1100 ( G D/B 0 AVL)  ,1111  Limite
                           ; (bits 16 -19)
        .byte 0x0             ; Base (bits 24 -31)

gdt_data:                  ; El  segmento descriptor de datos

        .word 0xffff          ; Limite (bits 0 -15)
        .word 0x0             ; Base (bits 0 -15)
        .byte 0x0             ; Base (bits 16 -23)
        .byte 10010010b       ;  1001(P DPL S) 0010(type codigo no 
                           ;accedido)
        .byte 11001111b       ; 1100 ( G D/B 0 AVL)  ,1111  Limite 
                           ;(bits 16 -19)
        .byte 0x0             ; Base (bits 24 -31)
gdt_end:

gdt_descriptor:
        .word gdt_end - gdt_start /*- 1 */; El tamaño de la tabla gdt es uno menos del calculado
        .long gdt_start       ; Dirección de comienzo del  GDT

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

.CODE32
protected_mode:
        /* Setup the other segments.
        * Those movs are mandatory because they update the descriptor cache:
        * http://wiki.osdev.org/Descriptor_Cache
        */
        mov $DATA_SEG, %ax
        mov %ax, %ds
        mov %ax, %es
        mov %ax, %fs
        mov %ax, %gs
        mov %ax, %ss
        /* TODO detect the last memory address available properly.
        * It depends on how much RAM we have.
        */
        mov $0X7000, %ebp
        mov %ebp, %esp

        ;//______________________________________________________________

        mov $message, %ecx
	mov vga_current_line, %eax
	mov $0, %edx
	#;Number of horizontal lines. 
        mov $25, %ebx
        div %ebx
        mov %edx, %eax
        #;ancho de linea * bytes por caracter en pantalla
        mov $160, %edx
        mul %edx
        #;0xb8000 == direccion de memoria de video magica que se muestra en la pantalla
        lea 0xb8000(%eax), %edx
        #;color
        mov $0x2a, %ah
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
.asciz "Esta computadora se destruirá en 3 2 1 ...."


/*
switch_to_pm:
         cli                     ;Apagamos las interrupciones hasta que hayamos  
                                 ; conmutado a modo protegido
         lgdt [ gdt_descriptor ] ; Cargamos la dirección y tamaño de la tabla GDT
         mov eax, cr0            ; Ponemos el bit 0 en uno del reg cr0 para pasar a modo protegido
         or eax, 0x1
         mov cr0, eax
         jmp CODE_SEG : init_pm  ; Hacemos un salto largo al nuevo segmento  de 32 bits
                                            ; El CPU fuerza a limpiar el cache

.CODE32
init_pm :
         mov ax, DATA_SEG 
         mov ds, ax 
         mov ss, ax 
         mov es, ax
         mov fs, ax
         mov gs, ax
         mov ebp, 0x90000        ; Inicializamos el stack
         mov esp, ebp

print:
        mov ebx, MSG_PROT_MODE
        call print_string_pm ; Usamos  nuestra rutina para imprimir en PM.
        jmp $ ; Hang.
; Variables Globales
MSG_REAL_MODE db " Comienza en  16 - bit Modo Real " , 0
MSG_PROT_MODE db " Paso exitosamente a 32 - bit Modo protegido ", 0 */