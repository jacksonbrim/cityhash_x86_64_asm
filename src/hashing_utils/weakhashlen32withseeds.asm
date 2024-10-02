section .data
    ; Include constants
    %include "constants.inc"

section .text
    global weak_hash_len_32_base 

    extern rotate                 ; rotate function (already implemented)
    extern fetch64                ; Fetch64 external function

; Function: WeakHashLen32WithSeeds
; Inputs:
;   rdi = pointer to string (char *s)
;   rsi = uint64 a
;   rdx = uint64 b
; Outputs:
;   rax = result.first
;   rdx = result.second
weak_hash_len_32_base:
    ; Save callee-saved registers that will be modified
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push rcx

    mov r12, rsi		; r12 = a
    mov r13, rdx		; r13 = b

    ; rdi = s pointer to string
    ; 1st arg
    call fetch64	; Fetch64(s)
    mov r14, rax	; r14 = w = Fetch64(s)

    ; 2nd arg
    add rdi, 8		; s + 8
    call fetch64	; Fetch64(s + 8)
    mov rsi, rax	; rsi = x = Fetch64(s + 8)

    ; 3rd arg
    add rdi, 8		; s + 16
    call fetch64	; Fetch64(s + 16)
    mov rdx, rax	; rdx = y = Fetch64(s + 16)

    ; 4th arg
    add rdi, 8		; s + 24
    call fetch64	; Fetch64(s + 24)
    mov rcx, rax	; rcx = z = Fetch64(s + 24)

    ; mov 1st arg into rdi
    mov rdi, r14

    ; continue to WeakHashLen32WithSeeds

; Function: WeakHashLen32WithSeeds
; Inputs:
;   rdi = w
;   rsi = x
;   rdx = y
;   rcx = z
;   r12  = a
;   r13  = b
; Outputs:
;   rax = result.first
;   rdx = result.second
weak_hash_len_32_with_seeds:
    ; Example operation: Compute some hash-like function
    ; a += w
    add r12, rdi
    ; b = rotate(b + a + z, 21);
    mov rdi, r13		; rdi = b
    add rdi, r12		; b = b + a
    add rdi, rcx		; b = b + a + z - 1st arg
    mov r14, rsi		; save rsi
    mov rsi, 21			; load shift - 2nd arg
    call rotate
    mov r13, rax		; b = rotate(b + a + z, 21)
    ; restore rsi
    mov rsi, r14		; rsi = x

    ; c = a
    mov r14, r12		; r14 = c
    
    ; a += x
    add r12, rsi		; a += x - frees x
    add r12, rdx		; a += y

    ; b += rotate(a, 44)
    mov rdi, r12		; rdi = a
    mov rsi, 44			; 
    call rotate
    add r13, rax		    ; b += rotate(a, 44)

    ; rax = a + z
    add r12, rcx		    ; a + z    
    mov rax, r12		    ; rax = a + z

    ; rdx = b + c
    add r13, r14		    ; b + c
    mov rdx, r13		    ; rdx = b + c

    ; Function epilogue
    pop rcx
    pop r14
    pop r13
    pop r12
    pop rbp             ; Restore base pointer
    ret
