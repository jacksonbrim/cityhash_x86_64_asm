; city_hash.asm
section .data
    %include "constants.inc"

section .text
    global cityhash64
    extern strlen
    extern fetch64
    extern shiftmix 
    extern rotate 
    extern hashlen0to16
    extern hashlen17to32
    extern hashlen33to64
    extern hashlen16 
    extern hashlen16_128to64
    extern weak_hash_len_32_base 

; Inputs:
;   rdi = s = pointer to the input string
;   rsi = len = length of the string
; Outputs:
;   rax = 64-bit hash of the string
cityhash64:
    ; Save callee-saved registers that will be modified
    ; rbp, r12 - r15
    push rbp		; save base pointer
    mov rbp, rsp	; establish new stack frame

    push rbx
    push r12
    push r13
    push r14
    push r15

    cmp rsi, 64
    jbe .return_below_64_bytes


    mov rcx, rdi	; save rdi pointer (s)
    mov r10, k1		; load k1

    ; x = Fetch64(s + len - 40);
    add rdi, rsi	; rdi = s + len
    sub rdi, 40		; rdi = s + len - 40
    call fetch64
    mov r8, rax		; r8 = x = Fetch64(s + len - 40)
    .set_x:

    ; y = Fetch64(s + len - 16) + Fetch64(s + len - 56);
    mov rdi, rcx	; rdi = s
    add rdi, rsi	; rdi = s + len
    sub rdi, 16		; s + len - 16
    call fetch64
    mov r9, rax		; r9  = Fetch64(s + len - 16)

    mov rdi, rcx	; s
    add rdi, rsi	; s + len
    sub rdi, 56		; s + len - 56
    call fetch64	; Fetch64(s + len - 56)
    ; result
    add r9, rax		; r9 =  y = Fetch64(s + len - 16) + Fetch(s + len - 56)
    .set_y:

    ; z = HashLen16(Fetch64(s + len - 48) + len, Fetch64(s + len - 24))
    ; first arg
    mov rdi, rcx	; s
    add rdi, rsi	; s + len
    sub rdi, 48		; s + len - 48
    call fetch64	; Fetch64(s + len - 48)
    add rax, rsi	; Fetch64(s + len - 48) + len
    mov rdx, rax	; save first arg

    ; second arg
    mov rdi, rcx	; s
    add rdi, rsi	; s + len
    sub rdi, 24		; s + len - 24
    mov r13, rsi	; save len 
    call fetch64	; rax = Fetch64(s + len - 24) - 2nd arg
    
    mov rdi, rdx	; store first arg
    mov rsi, rax	; store second arg

    call hashlen16_128to64 

    ; restore rsi
    mov rsi, r13	; len

    ; store result
    mov r12, rax		; r12 = z = Hashlen16(..., ...)

    .set_z:

    ; v = WeakHashLen32WithSeeds(s + len - 64, len, z))
    mov rdi, rcx	; s
    add rdi, rsi	; s + len
    sub rdi, 64		; s + len - 64 - 1st arg
    ; rsi already loaded - 2nd arg
    mov r13, rsi	; save rsi
    mov rdx, r12	; load z - 3rd arg
    call weak_hash_len_32_base
    ; rax -> v.first, rdx -> v.second
    mov rsi, r13	; restore rsi
    ; store results
    mov r13, rax	; r13 = v.first
    mov r14, rdx	; r14 = v.second
    .set_v:

    ; w = WeakHashLen32WithSeeds(s + len - 32, y + k1, x))
    mov rdi, rcx	; s
    add rdi, rsi	; s + len
    sub rdi, 32		; s + len - 32	- 1st arg
    mov r15, rsi	; save rsi
    mov rsi, r9		; load y
    add rsi, r10	; rsi = y + k1 = 2nd arg
    mov rdx, r8		; load x - 3rd arg

    call weak_hash_len_32_base
    ; rax -> w.first, rdx -> w.second

    mov rsi, r15	; restore rsi
    ; store results
    mov r11, rax	; r11 = w.first
    mov r15, rdx	; r14 = w.second
    .set_w:

    ; x -> r8
    ; y -> r9
    ; z -> r12
    ; v -> r13, r14
    ; w -> r11, r15
    ; rsi -> original s pointer
    ; rcx -> original s pointer
    ; rbx -> nothing
    ; r10 -> k1
    ; rax, rdx (functions)

    ; x = x * k1 + Fetch64(s)
    ; reset rdi
    mov rdi, rcx	; rdi = s
    call fetch64	; fetch64(s)
    mov rdx, r10	; load k1
    imul rdx, r8	; k1 * x
    add rax, rdx	; fetch64(s) + (k1 * x)
    mov r8, rax		; r8 = x = x * k1 + fetch64(s)
    .updated_x:

    ; rdi = s
    ; rsi = len
    
    ; len = (len - 1) & ~static_cast(size_t>(63);
    ; ~static_cast<size_t>(63) is the bitwise NOT value of 63 (0x3F)
    ; turns 63 into 0xFFFFFFFFFFFFFFC0 in 64-bit representation
    dec rsi			; len - 1
    and rsi, ~63		; clear lower bits of rcx (equivalent to rcx &= ~0x3f)

    mov rcx, rsi	; save rsi
    mov rbx, rdi	; save rdi = s

    ; free regs for temps
    ; rcx, rbx, rax, rdx, r10
    .loop:

	; x = Rotate(x + y + v.first + Fetch64(s + 8), 37) * k1;
	; Fetch64(s + 8)
	mov rdi, rbx
	add rdi, 8	; s + 8
	call fetch64
	add rax, r13	; fetch64(s + 8) + v.first
	add rax, r9	; fetch64(s + 8) + v.first + y
	add rax, r8	; x = fetch64(s + 8) + v.first + y + x
	mov rdi, rax	; load first arg
	mov rsi, 37
	call rotate
	imul rax, r10	; x = Rotate(..., 37) * k1
	mov r8, rax	; r8 = x
	.update_x:

	; y = Rotate( y + v.second + Fetch64(s + 48), 42) * k1;
	; Fetch64(s + 48)
	mov rdi, rbx	; s
	add rdi, 48	; s + 48
	call fetch64
	add rax, r14	; fetch64(s + 48) + v.second
	add rax, r9	; fetch64(s + 48) + v.second + y
	mov rdi, rax	; load first arg
	mov rsi, 42
	call rotate
	imul rax, r10	; y = Rotate(..., 42) * k1
	mov r9, rax	; r9 = y

	.update_y:

	; x ^= w.second
	xor r8, r15
	.second_update_x:
	; y += v.first + Fetch64(s + 40);
	; Fetch64(s + 40)
	mov rdi, rbx	; s
	add rdi, 40	; s + 40
	call fetch64	; fetch64(s + 40)
	add r9, rax	; y += fetch64(s + 40)
	add r9, r13	; y += v.first + Fetch64(s + 40);
	.second_update_y:


	; z = Rotate(z + w.first, 33) * k1;
	mov rax, r12	; load z
	add rax, r11	; z + w.first
	mov rdi, rax	; load (z + w.first) - first arg
	mov rsi, 33	; load 33 - second arg
	call rotate
	imul rax, r10
	mov rdi, r12	; restore rdi
	mov r12, rax	; z = Rotate(z + w.first, 33) * k1; - new z value
	.update_z:

	; v = WeakHashLen32WithSeeds(s, v.second * k1, x + w.first);
	mov rdi, rbx	; s - first arg
	imul r14, r10	; v.second * k1 - 2nd arg
	mov rsi, r14	; load second arg
	mov rdx, r8	; load third arg
	add rdx, r11	; x + w.first - 3rd arg

	call weak_hash_len_32_base
	; rax = v.first, rdx = v.second
	

	mov r13, rax	; r13 = v.first
	mov r14, rdx	; r14 = v.second


	.update_v:

	; w = WeakHashLen32WithSeeds(s + 32, z + w.second, y + Fetch64(s + 16));
	; 3rd arg - y + Fetch64(s + 16)
	mov rdi, rbx	; s
	add rdi, 16	; rdi = s + 16
	call fetch64
	add rax, r9	; rax = y + Fetch64(s + 16) - 3rd arg

	; 2nd arg - z + w.second
	mov rsi, r12
	add rsi, r15	; rsi = z + w.second

	; 1st arg
	mov rdi, rbx	; rdi = s
	add rdi, 32	; rdi = s + 32

	mov rdx, rax	; load 3rd arg into rdx

	call weak_hash_len_32_base
	; rax = w.first, rdx = w.second

	mov r11, rax	; r11 = w.first
	mov r15, rdx	; r15 = w.second

	.update_w:

	; std::swap(z, x)
	xchg r12, r8	; swap z and x

	add rbx, 64	; s += 32
	sub rcx, 64	; len -= 64
	.update_s:

	test rcx, rcx
	jnz .loop

.return_above_64_bytes:
    ; return Hashlen16(HashLen16(v.first, w.first) + ShiftMix(y) * k1 + z,
    ;			Hashlen16(v.second, w.second) + x);
    ; x = r8
    ; y = r9
    ; k1 = r10
    ; z = r12
    ; v = r13, r14
    ; w = r11, r15
    ; ShiftMix(y) * k1 + z
    mov rdi, r9		; load y
    call shiftmix
    imul rax, r10	; ShiftMix(y) * k1
    add rax, r12	; (ShiftMix(y) * k1) + z
    mov r9, rax		; r9 = ShiftMix(y) * k1 + z

    mov rdi, r13	; v.first - first arg
    mov rsi, r11	; w.first - second arg
    call hashlen16_128to64
    add r9, rax		; r9 = Hashlen16(v.first, w.first) + ShiftMix(y) * k1 + z - first arg

    mov rdi, r14	; v.second - first arg
    mov rsi, r15	; w.second - second arg
    call hashlen16_128to64
    add rax, r8		; rax = Hashlen16(v.second, w.second) + x - second arg

    mov rdi, r9		; first arg
    mov rsi, rax	; second arg
    call hashlen16_128to64
    ; result in rax

    jmp .end

.return_below_64_bytes:
    cmp rsi, 32
    jbe .return_0_to_32_bytes

    ; string is 33 to 64 bytes
    call hashlen33to64
    ; result in rax
    jmp .end

.return_0_to_32_bytes:
    cmp rsi, 16
    jbe .return_0_to_16_bytes

    ; string is 17 to 32 bytes
    call hashlen17to32
    ; result in rax
    jmp .end

.return_0_to_16_bytes:
    ; string is 0 to 16 bytes
    call hashlen0to16
    jmp .end

.end:
    ; Function epilogue
    ; Restore callee-saved registers in reverse order
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    pop rbp             ; Restore base pointer
    ret
