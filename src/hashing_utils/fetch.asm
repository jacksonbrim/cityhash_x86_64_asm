section .text
    global fetch64
    global fetch32

; Function: fetch64
; Input: rdi = pointer to memory location
; Output: rax = 64-bit value loaded from memory
fetch64:
    mov rax, [rdi]         ; Load 64 bits (8 bytes) from the memory address in rdi into rax
    ret                    ; Return the value in rax

; Function: fetch32
; Input: rdi = pointer to memory location
; Output: rax = 32-bit value loaded from memory (zero-extended to 64 bits)
fetch32:
    mov eax, [rdi]         ; Load 32 bits (4 bytes) from the memory address in rdi into eax (zero-extends into rax)
    ret                    ; Return the value in rax
