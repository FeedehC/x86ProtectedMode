VIDEO_MEMORY equ 0xb8000 + 160
WHITE_ON_BLACK equ 0x0f
; Imprime una cadena de caracteres terminadas en null apuntada por  EBX
print_string_pm:
           pusha
           mov edx, VIDEO_MEMORY    ;Se inicializa EDX a la segunda
                                    ;linea de la memoria de video.
print_string_pm_loop:
           mov al, [ebx]            ;El caracter apuntado por  EBX 
                                    ;se mueve a  AL
           mov ah, WHITE_ON_BLACK   ;Carga AH con el atributo de
                                    ;video
           cmp al, 0                ;si (al = 0) fin de la cadena
           je print_string_pm_done  ;si no salta a done
           mov [edx] , ax           ;Almacena el caracter en la
                                    ;memoria de video
           add ebx, 1               ;Incremento EBX al proximo
                                    ;caracter.
           add edx, 2               ;Apunto al proximo caracter
                                    ;en la memoria de video.
           jmp print_string_pm_loop ;loop a proximo caracter.
print_string_pm_done:
           popa
           ret  