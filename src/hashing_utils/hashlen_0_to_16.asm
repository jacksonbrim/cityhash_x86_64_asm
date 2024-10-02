section .data
    ; Include constants
    %include "constants.inc"

section .text
    global hashlen0to16
    global greater_or_equal_to_8 
    global len_less_than_8
    global len_less_than_4

    extern fetch64                ; Fetch64 external function
    extern fetch32                ; Fetch32 external function
    extern rotate                 ; Rotate function (already implemented)
    extern hashlen16              ; Murmur-inspired HashLen16 function
    extern shiftmix               ; ShiftMix function (already implemented)


; Function: hashlen0to16
; Input:
;   rdi = pointer to string (char *s)
;   rsi = length of the string (size_t len)
; Output:
;   rax = 64-bit hashed value
hashlen0to16:
    cmp rsi, 8                    ; Check if len >= 8
    jl len_less_than_8            ; If len < 8, jump to next case

greater_or_equal_to_8:
    ; len >= 8
    ; mul = k2 + len * 2
    mov rax, rsi                  ; rax = len
    shl rax, 1                    ; rax = len * 2
    mov r9, k2                   ; Load k2 into r9
    add rax, r9                  ; rax = mul = k2 + len * 2
    mov r8, rax                  ; r8 = mul

    ; a = Fetch64(s) + k2
    call fetch64                  ; Fetch64(s), s already in rdi, result in rax
    add rax, r9                  ; rax = a = Fetch64(s) + k2
    mov rbx, rax                  ; rbx = a

    ; b = Fetch64(s + len - 8)
    mov rcx, rsi                  ; rcx = len
    sub rcx, 8                    ; rcx = len - 8
    add rdi, rcx                  ; rdi = s + len - 8
    call fetch64                  ; Fetch64(s + len - 8)
    mov rdx, rax                  ; rdx = b

    ; c = Rotate(b, 37) * mul + a
    mov rdi, rdx                  ; rdi = b
    mov rsi, 37                   ; rsi = shift amount
    call rotate                   ; Rotate(b, 37)
    imul rax, r8                 ; rax = Rotate(b, 37) * mul
    add rax, rbx                  ; rax = c = Rotate(b, 37) * mul + a
    mov rcx, rax		 ; rcx = c

    ; d = (Rotate(a, 25) + b) * mul
    mov rdi, rbx                  ; rdi = a
    mov rsi, 25                   ; rsi = shift amount for rotate
    call rotate                   ; Rotate(a, 25)
    add rax, rdx                  ; rax = Rotate(a, 25) + b
    imul rax, r8                 ; rax = d = (Rotate(a, 25) + b) * mul (d value is now in rax)

    ; Call HashLen16(c, d, mul)
    mov rdi, rcx                  ; rdi = c
    mov rsi, rax                  ; rsi = d
    mov rdx, r8                  ; rdx = mul
    call hashlen16                ; HashLen16(c, d, mul) result is returned in rax
    ret                           ; Return the 64-bit hashed result


len_less_than_8:
    cmp rsi, 4                    ; Check if len >= 4
    jl len_less_than_4            ; If len < 4, jump to next case

    ; len >= 4
    ; mul = k2 + len * 2
    mov rax, rsi                  ; rax = len
    shl rax, 1                    ; rax = len * 2
    mov rbx, k2                   ; Load k2 into rbx
    add rax, rbx                  ; rax = mul = k2 + len * 2

    ; Save mul in rdx for later
    mov rdx, rax                  ; rdx = mul

    ; a = Fetch32(s)
    call fetch32                  ; Fetch32(s), result in rax
    mov rcx, rax                  ; rcx = a

    ; Return HashLen16(len + (a << 3), Fetch32(s + len - 4), mul)

    ; Shift a by 3 and add len
    shl rcx, 3                    ; rcx = a << 3
    add rcx, rsi                  ; rcx = len + (a << 3)

    ; Prepare to fetch s + len - 4
    sub rsi, 4                    ; rsi = len - 4
    add rdi, rsi                  ; rdi = s + len - 4
    call fetch32                  ; Fetch32(s + len - 4), result in rax
    mov rsi, rax                  ; rsi = Fetch32(s + len - 4)


    ; Call HashLen16(len + (a << 3), Fetch32(s + len - 4), mul)
    ; rdi = len + (a << 3)
    mov rdi, rcx		  ; rdi = rcx = len + (a << 3)
    ; rsi = Fetsh32(s + len - 4)
    ; rdx = mul
    call hashlen16                ; HashLen16(rcx, rsi, rdx)
    ret                           ; Return the result


len_less_than_4:
    cmp rsi, 0                    ; Check if len == 0
    jz .len_is_zero               ; If len == 0, jump to return k2

    ; len > 0
    ; Fetch individual bytes
    ; convert length to zero-indexing
    movzx rax, byte [rdi]         ; rax = uint8_t a = s[0]
    mov rcx, rsi                  ; rcx = len
    shr rcx, 1                    ; rcx = len >> 1
    ; rcx = b = s[len >> 1]
    movzx rcx, byte [rdi + rcx]   ; rcx = uint8_t b = s[len >> 1]

    ; rdx = c = s[len - 1]
    movzx rdx, byte [rdi + rsi - 1] ; rdx = uint8_t c = s[len - 1]

    ; y = a + (b << 8)
    shl rcx, 8                    ; rcx = b << 8
    add rax, rcx                  ; rax = y = a + (b << 8)

    ; z = len + (c << 2)
    shl rdx, 2                    ; rdx = c << 2
    add rdx, rsi                  ; rdx = z = len + (c << 2)

    ; return ShiftMix(y * k2 ^ z * k0) * k2
    mov rcx, rax                  ; rcx = y
    mov rbx, k2			  ; Load k2
    imul rcx, rbx                 ; rcx = y * k2
    mov rbx, rdx                  ; rbx = z
    mov rdx, k0                   ; Load k0
    imul rbx, rdx                 ; rbx = z * k0
    xor rcx, rbx                  ; rcx = y * k2 ^ z * k0

    mov rdi, rcx                  ; Pass the result of (y * k2 ^ z * k0) to ShiftMix
    call shiftmix                 ; Apply ShiftMix
    mov rbx, k2                   ; Load k2
    imul rax, rbx                 ; Multiply result by k2
    ret                           ; Return the 64-bit hashed result

.len_is_zero:
    mov rax, k2                   ; Load k2 into rax
    ret                           ; Return k2 for len == 0

