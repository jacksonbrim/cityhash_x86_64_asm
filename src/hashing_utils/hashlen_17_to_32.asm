section .data
    ; Include constants
    %include "constants.inc"

section .text
    global hashlen17to32

    extern fetch64                ; Fetch64 function to load 64-bit values from memory
    extern rotate                 ; Rotate function for rotating 64-bit values
    extern hashlen16              ; HashLen16 function for final hash calculation

    
; Function: hashlen17to32
; Inputs:
;   rdi = pointer to string (const char *s)
;   rsi = length of the string (size_t len)
; Outputs:
;   rax = 64-bit hashed value

hashlen17to32:
    ; Step 1: Compute mul = k2 + len * 2
    mov rax, rsi                  ; rax = len
    shl rax, 1                    ; rax = len * 2

    ; use k2 3 times
    mov r9, k2			  ; load 64-bit constant
    add rax, r9			  ; rax = mul = k2 + len * 2
    mov rdx, rax                  ; Store mul in rdx
    ; use mul 2 times

    ; Step 2: Load a = Fetch64(s) * k1
    ; use a 2 times
    ; s is already in rdi
    call fetch64                  ; Fetch64(s)
    mov rbx, k1			  ; load constant
    imul rax, rbx		  ; rax = a = Fetch64(s) * k1
    mov rbx, rax                   ; rbx = a

    ; Step 3: Load b = Fetch64(s + 8)
    ; rdi = s
    ; use b 2 times
    add rdi, 8                    ; s + 8
    call fetch64                  ; Fetch64(s + 8)
    mov r10, rax                   ; r10 = b

    ; Step 4: Load c = Fetch64(s + len - 8) * mul
    ; use c twice
    sub rdi, 16                    ; rdi = s + 8 - 16 = s - 8
    add rdi, rsi                   ; rdi = (s - 8) + len = s + len - 8
    call fetch64                  ; Fetch64(s + len - 8)
    imul rax, rdx                 ; rax = c = Fetch64(s + len - 8) * mul
    mov r11, rax                  ; r11 = c

    ; Step 5: Load d = Fetch64(s + len - 16) * k2
    ; d is used once
    ; rdi = (s + len - 8)
    sub rdi, 8                    ; rdi = (s + len - 8 ) - 8 = (s + len - 16)
    call fetch64                  ; Fetch64(s + len - 16)
    imul rax, r9		  ; rax = d = Fetch64(s + len - 16) * k2
    mov rcx, rax                  ; rcx = d

    ; Step 6: Perform Rotate(a + b, 43) + Rotate(c, 30) + d
    mov rax, rbx                  ; rax = a
    add rax, r10                   ; rax = a + b
    mov rdi, rax                  ; Move (a + b) into rdi for Rotate
    mov rsi, 43                   ; Rotate by 43
    call rotate                   ; rax = Rotate(a + b, 43)
    add rax, rcx		  ; rax = Rotate(a + b, 43) + d
    mov r8, rax                   ; Store result in r8 (Rotated(a + b, 43) + d)

    ; Rotate c by 30
    ; 1st argument for Hashlen16(u, v, w)
    mov rdi, r11                  ; rdi = c
    mov rsi, 30                   ; Rotate by 30
    call rotate                   ; rax = Rotate(c, 30)
    add r8, rax                   ; rax = Rotate(a + b, 43) + Rotate(c, 30) + d

    ; Step 7: Compute second argument for HashLen16: a + Rotate(b + k2, 18) + c
    mov rax, r10                  ; rax = b
    add rax, r9                   ; rax = b + k2
    mov rdi, rax                  ; rdi = b + k2
    mov rsi, 18                   ; Rotate by 18
    call rotate                   ; rax = Rotate(b + k2, 18)
    add rax, r11                   ; rax = Rotate(b + k2, 18) + c
    add rax, rbx		  ; rax = a + Rotate(b + k2, 18) + c

    ; Step 8: Call HashLen16 with the two computed values
    mov rdi, r8                   ; First argument for HashLen16 (from Step 6)
    mov rsi, rax                   ; Second argument for HashLen16 (from Step 7)
    mov rdx, rdx                  ; Pass mul as the third argument
    call hashlen16                ; Call HashLen16

    ; Return the result in rax
    ret

