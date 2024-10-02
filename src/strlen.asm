; strlen.asm
global strlen
; Function to calculate string length
; input - rsi
; output - rax
strlen:
    xor rax, rax
.loop:
    cmp byte [rsi + rax], 0
    je .end
    inc rax
    jmp .loop
.end:
    ret
