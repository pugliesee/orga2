extern malloc

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 148

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0;
USUARIO_SEGUIDORES_OFFSET EQU 8; 
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16; 
USUARIO_SEGUIDOS_OFFSET EQU 24; 
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32; 
USUARIO_BLOQUEADOS_OFFSET EQU 40; 
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48; 
USUARIO_ID_OFFSET EQU 52; 
USUARIO_SIZE EQU 56

; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
global trendingTopic 
trendingTopic:
    .prologo:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    ; Preservo los valores originales
    mov r12, rdi    ; User
    mov r13, rsi    ; Función "esSobresaliente"

    xor rsi, rsi 
    mov rdi, [r12 + USUARIO_FEED_OFFSET]        ; Feed
    mov esi, dword [r12 + USUARIO_ID_OFFSET]    ; ID
    mov rcx, r13
    call cuantos_tuits_trending_topic

    ; Ahora acá tengo en RAX la cantidad de tuits del usuario que tengo en R12 que son TRENDING TOPIC
    cmp eax, dword 0
    jne .memoria
    ; Como es 0, devuelvo NULL en RAX
    xor rax, rax
    jmp .epilogo

    .memoria:
    inc rax
    imul rax, 8 ; sizeof(tuit_t*) = 8
    call malloc

    ; Ahora en RAX tengo el tuit_t** que quiero devolver
    mov r14, rax    ; tuit_t**
    xor r15, r15    ; Index

    mov r8, [r12 + USUARIO_FEED_OFFSET] ; feed
    mov rbx, [r8 + FEED_FIRST_OFFSET]   ; actual

    .ciclo:
        cmp rbx, qword 0
        je .fin

        mov rdi, [rbx + PUBLICACION_VALUE_OFFSET]   ; tuit

        mov r8d, dword [rdi + TUIT_ID_AUTOR_OFFSET]
        mov r9d, dword [r12 + USUARIO_ID_OFFSET]
        cmp r8d, r9d
        jne .proximo

        ; Falta chequear si el tuit es TRENDING TOPIC en esta altura del programa
        call r13
        cmp al, byte 1
        jne .proximo

        ; En el caso de que aún NO hayamos saltado a la etiqueta PROXIMO es porque la publicación
        ;  es del usuario que recibí por parámetro y el tuit es TRENDING TOPIC
        mov rdi, [rbx + PUBLICACION_VALUE_OFFSET]   ; tuit
        mov [r14 + r15 * 8], rdi
        inc r15
        
        .proximo:
        mov rbx, [rbx + PUBLICACION_NEXT_OFFSET]    ; actual = actual->next
        jmp .ciclo

    .fin:
    mov qword [r14 + r15 * 8], qword 0
    mov rax, r14

    .epilogo:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; uint32_t cuantos_tuits_trending_topic(feed_t* feed, uint32_t user_id, uint8_t (*esTuitSobresaliente)(tuit_t *))
global cuantos_tuits_trending_topic
cuantos_tuits_trending_topic:
    .prologo:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15    ; Stack alineado

    ; Preservamos valores originales
    mov r12, [rdi + FEED_FIRST_OFFSET]    ; actual
    mov r13, rsi                          ; user_id
    mov r14, rcx                          ; esTuitSobresaliente

    xor r15, r15    ; Contador
    .ciclo:
        cmp r12, 0
        je .fin

        mov rdi, [r12 + PUBLICACION_VALUE_OFFSET]   ; tuit
        
        mov r8d, dword [rdi + TUIT_ID_AUTOR_OFFSET]
        mov r9d, r13d
        cmp r8d, r9d
        jne .proximo

        ; Solo nos queda ver si es sobresaliente
        call r14
        cmp al, byte 0
        je .proximo

        inc r15

        .proximo:
        mov r12, [r12 + PUBLICACION_NEXT_OFFSET]
        jmp .ciclo

    .fin:
    mov rax, r15

    .epilogo:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
