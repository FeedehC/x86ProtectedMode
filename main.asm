;.CODE16
%include "print_string_pm.asm"
gdt_start:
        gdt_null:          ; El descriptor nulo
        dd 0x0             ; 'dd' significa doble word (4 bytes)
        dd 0x0
gdt_code:                  ; El  segmento descriptor de codigo

        dw 0xffff          ; Limite (bits 0 -15)
        dw 0x0             ; Base (bits 0 -15)
        db 0x0             ; Base (bits 16 -23)
        db 10011010b       ; 1001(P DPL S) 1010(type codigo no 
                           ;accedido)
        db 11001111b       ; 1100 ( G D/B 0 AVL)  ,1111  Limite
                           ; (bits 16 -19)
        db 0x0             ; Base (bits 24 -31)

gdt_data:                  ; El  segmento descriptor de datos

        dw 0xffff          ; Limite (bits 0 -15)
        dw 0x0             ; Base (bits 0 -15)
        db 0x0             ; Base (bits 16 -23)
        db 10010010b       ;  1001(P DPL S) 0010(type codigo no 
                           ;accedido)
        db 11001111b       ; 1100 ( G D/B 0 AVL)  ,1111  Limite 
                           ;(bits 16 -19)
        db 0x0             ; Base (bits 24 -31)
gdt_end:

gdt_descriptor:
        dw gdt_end - gdt_start - 1 ; El tamaño de la tabla gdt es uno menos del calculado
        dd gdt_start       ; Dirección de comienzo del  GDT

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

switch_to_pm:
         cli                     ;Apagamos las interrupciones hasta que hayamos  
                                 ; conmutado a modo protegido
         lgdt [ gdt_descriptor ] ; Cargamos la dirección y tamaño de la tabla GDT
         mov eax, cr0            ; Ponemos el bit 0 en uno del reg cr0 para pasar a modo protegido
         or eax, 0x1
         mov cr0, eax
         jmp CODE_SEG : init_pm  ; Hacemos un salto largo al nuevo segmento  de 32 bits
                                            ; El CPU fuerza a limpiar el cache
;.CODE32
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
MSG_PROT_MODE db " Paso exitosamente a 32 - bit Modo protegido ", 0 