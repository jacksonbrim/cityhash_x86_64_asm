; hashlen_33_to_64.asm
section .data
    %include "constants.inc"

section .text
    global hashlen33to64
    extern fetch64
    extern rotate
    extern shiftmix
; Function: hashlen17to32
; Inputs:
;   rdi = pointer to string (const char *s)
;   rsi = length of the string (size_t len)
; Outputs:
;   rax = 64-bit hashed value
hashlen33to64:
    ; mul = k2 + len * 2
    mov rax, rsi	; load len
    shl rax, 1		; len * 2
    mov rcx, k2		; load k2
    add rax, rcx	; (len * 2) + k2
    mov r15, rax	; r15 = mul
    .set_mul:

    ; a = Fetch64(s) * k2;
    call fetch64
    imul rax, rcx	
    mov r8, rax		; r8 = a
    .a_set:
    
    ; b = Fetch64(s + 8);
    add rdi, 8		; s + 8
    call fetch64
    mov r9, rax		; r9 = b = Fetch64(s + 8)
    .b_set:

    ; e = Fetch64(s + 16) * k2);
    add rdi, 8		; (s + 8) + 8 = s + 16
    call fetch64	
    imul rax, rcx	; fetch64(s + 16) * k2 
    mov r12, rax	; r12 = e
    .e_set:
    ; no longer need k2

    ; f = Fetch64(s + 24) * 9
    add rdi, 8		; (s + 16) + 8 =  s + 24
    call fetch64
    imul rax, 9		; Fetch64(s + 24) * 9
    mov r13, rax	; r13 = f
    .f_set:

    ; g = Fetch64(s + len - 8);
    sub rdi, 32		; (s + 24) - 32 = s - 8
    add rdi, rsi	; (s - 8) + len = s + len - 8
    call fetch64
    mov r14, rax	; Fetch64(s + len - 8);
    .g_set:

    ; c = Fetch64(s + len - 24);
    sub rdi, 16		; (s + len - 8) - 16 = s + len - 24
    call fetch64
    mov r10, rax	; Fetch64(s + len - 24);
    .c_set:

    ; d = Fetch64(s + len - 32);
    sub rdi, 8		; (s + len - 24) - 8 = s + len - 32
    call fetch64
    mov r11, rax	; Fetch64(s + len - 32);
    .d_set:

    ; h = Fetch64(s + len - 16) * mul;
    add rdi, 16		; (s + len - 32) + 16 = s + len - 16
    call fetch64
    imul rax, r15
    mov rbx, rax	; rbx = h = Fetch64(s + len - 16) * mul
    .h_set:

    ; u = Rotate(a + g, 43) + (Rotate(b, 30) + c) * 9;
    ; Rotate(b, 30) + c) * 9
    mov rdi, r9		; load b into 1st arg
    mov rsi, 30
    call rotate
    add rax, r10		
    imul rax, 9		; (Rotate(b, 30) + c) * 9)
    mov rcx, rax	; store intermediate value

    mov rdi, r8		; load a into 1st arg
    add rdi, r14	; a + g
    mov rsi, 43
    call rotate
    add rcx, rax	; rcx = u = Rotate(a + g, 43) + ((Rotate(b, 30) + c) * 9)
    .u_set:

    ; v = ((a + g) ^ d) + f + 1
    mov rdx, r8		; load a
    add rdx, r14	; a + g
    xor rdx, r11	; (a+g)^d
    add rdx, r13
    add rdx, 1		; rdx = v = ((a + g) ^ d) + f + 1
    .v_set:

    ; w = bswap_64((u + v) * mul) + h - frees u
    ; rcx = u
    add rcx, rdx	; (u + v)
    imul rcx, r15	; (u + v) * mul
    bswap rcx		; 
    add rcx, rbx	; rcx = w = bswap_64((u + v) * mul) + h
    .w_set:

    ; y = (bswap_64((v + w) * mul) + g) * mul; - frees g, v, & w (r14, rdx, rcx)
    add rcx, rdx	; v + w
    imul rcx, r15	; (v + w) * mul
    bswap rcx		; bwap_64((v + w)
    add rcx, r14	; (bwap_64((v + 2) * mul) + g)
    imul rcx, r15	; (bwap_64((v + 2) * mul) + g) * mul
    ; rcx = y = (bswap_64((v+w)*mul) + g) * mul;
    .y_set:

    ; x = Rotate(e + f, 42) + c; | frees f
    add r12, r13	; e + f
    mov rdi, r12	; load 1st arg
    mov rsi, 42		; load 2nd arg
    call rotate
    add rax, r10	; Rotate(e + f, 42) + c;
    mov r13, rax	; r13 = x
    .x_set:

    ; z = e + f + c | frees c
    add r12, r10	; r12 = z = (e + f) + c
    .z_set:

    ; a = bswap_64((x + z) * mul + y) + b;
    mov r10, r13	; load x
    add r10, r12	; x + z
    imul r10, r15	; (x + z) * mul
    add r10, rcx	; (x + z) * mul + y
    bswap r10		; bswap_64((x + z) * mul + y)
    add r10, r9		; a = r10 = bswap_64((x + z) * mul + y) + b
    .finalize_a:

    ; b = ShiftMix((z + a) * mul + d + h) * mul;
    mov rdi, r12	; load z into argument
    add rdi, r10	; (z + a)
    imul rdi, r15	; (z + a) * mul
    add rdi, r11	; (z + a) * mul + d
    add rdi, rbx	; (z + a) * mul + d + h
    call shiftmix
    imul rax, r15	; b = rax = ShiftMix((z + a) * mul + d + h) * mul;
    .finalize_b:

    add rax, r13	; b + x

    .return:
    ret
