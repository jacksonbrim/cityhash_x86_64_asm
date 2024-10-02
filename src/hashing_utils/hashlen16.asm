section .data
    kmul dq 0x9ddfea08eb382d69
section .text
    global hashlen16
    global hashlen16_128to64

; Function: hashlen16
; Input: 
;   rdi = 64-bit value u
;   rsi = 64-bit value v
; Output: 
;   rax = 64-bit hashed value
hashlen16_128to64:
    mov rdx, [rel kmul]

; Function: hashlen16
; Input: 
;   rdi = 64-bit value u
;   rsi = 64-bit value v
;   rdx = 64-bit value mul (multiplier)
; Output: 
;   rax = 64-bit hashed value
hashlen16:
    ; a = (u ^ v) * mul
    push rcx
    push rbx
    mov rax, rdi             ; rax = u
    xor rax, rsi             ; rax = u ^ v
    imul rax, rdx            ; rax = (u ^ v) * mul

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

    pop rbx
    pop rcx
    ret                      ; Return the result

