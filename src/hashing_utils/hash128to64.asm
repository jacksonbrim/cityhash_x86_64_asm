; hash128to64.asm
section .data
    kMul dq 0x9ddfea08eb382d69

section .text
    global hash128to64

; Function: hashlen16
; Input: 
;   rdi = 64-bit value u
;   rsi = 64-bit value v
; Output: 
;   rax = 64-bit hashed value
hash128to64:
    ; a = (u ^ v) * mul
    mov rax, rdi             ; rax = u
    xor rax, rsi             ; rax = u ^ v
    mov rdx, kMul	     ; load Kmul
    imul rax, rdx            ; rax = (u ^ v) * kMul

    ; a ^= (a >> 47)
    mov rcx, rax             ; rcx = a
    shr rcx, 47              ; rcx = a >> 47
    xor rax, rcx             ; rax = a ^ (a >> 47)

    ; b = (v ^ a) * mul
    mov rcx, rsi             ; rcx = v
    xor rcx, rax             ; rcx = v ^ a
    imul rcx, rdx            ; rcx = (v ^ a) * mul

    ; b ^= (b >> 47)
    mov rbx, rcx             ; rbx = b
    shr rbx, 47              ; rbx = b >> 47
    xor rcx, rbx             ; rcx = b ^ (b >> 47)

    ; b *= mul
    imul rcx, rdx            ; rcx = b * mul

    ; Return the final result in rax
    mov rax, rcx             ; rax = final hashed value (b)
    ret                      ; Return the result

