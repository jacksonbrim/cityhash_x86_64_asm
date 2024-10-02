section .text
    global shiftmix

; Function: shiftmix
; Input: rdi = 64-bit value
; Output: rax = result of val ^ (val >> 47)
shiftmix:
    mov rax, rdi             ; Move the input value from rdi to rax
    mov rcx, 47              ; Set the shift amount (47 bits) into rcx
    shr rdi, cl              ; Shift the original value in rdi by 47 bits
    xor rax, rdi             ; XOR the original value in rax with the shifted value in rdi
    ret                      ; Return the result in rax

