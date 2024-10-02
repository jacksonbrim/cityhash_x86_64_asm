; print_number.asm

section .data
    digit_table db '0123456789'


section .text
    global print_number
; Function to print a 64-bit number
; Input: rax - number to print
print_number:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32         ; Reserve stack space for digits

    mov r12, rax	; Save the number to print
    mov r13, 0          ; Digit counter
    mov r14, 10          ; Divisor

    ; Special case for zero
    test r12, r12
    jnz .divide_loop
    mov byte [rsp], '0'
    mov r13, 1
    jmp .print_loop

.divide_loop:
    xor rdx, rdx        ; Clear upper 64 bits of dividend
    mov rax, r12
    div r14              ; Divide rax by 10, quotient in rax, remainder in rdx
    mov r15, rdx         ; Save remainder
    mov dl, [digit_table + r15]  ; Get ASCII digit
    mov [rsp + r13], dl ; Store digit
    inc r13
    mov r12, rax	; Update the quotient
    test r12, r12       ; Check if quotient is zero
    jnz .divide_loop

.print_loop:
    ; Print the digits in reverse order
    dec r13
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    lea rsi, [rsp + r13]; Address of current digit
    mov rdx, 1          ; Length to print
    syscall
    test r13, r13
    jnz .print_loop

    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret
