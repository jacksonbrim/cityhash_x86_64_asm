; main.asm

section .data
    msg db "String: "
    msg_len equ $ - msg
    hash_msg db 10, "City Hash: "
    hash_len equ $ - hash_msg

section .bss
    string resq 1

section .text
    global _start
    extern strlen
    extern cityhash64
    extern print_number
    extern print_hex


_start:
    ; Get the arg count from rsp
    mov rdi, [rsp]	; argc is stored at rsp
    cmp rdi, 2		; Ensure we have at least 2 args (including the program name)
    jl error_exit

    ; Get the string (second argument, argv[1])
    mov rsi, [rsp + 16] ; argv[0] is at rsp + 8, argv[1] is at rsp + 16, etc.
    mov [string], rsi

     ; Print hashing string message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; Print string
    mov rsi, [string]
    call strlen
    mov rdx, rax	; store the length of the string in rdx
    mov rax, 1
    mov rdi, 1
    mov rsi, [string]
    syscall
 
    mov r12, rdx	; preserve string length
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, 10 ; newline
    mov rdx, 1
    syscall

    ; Print hashing string message
    mov rax, 1
    mov rdi, 1
    mov rsi, hash_msg
    mov rdx, hash_len
    syscall

    mov rdi, [string]	; store pointer to string
    mov rsi, r12	; save string length
    call cityhash64
    ; result in rax
    call print_hex

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, 10 ; newline
    mov rdx, 1
    syscall


    jmp exit

   
error_exit:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
