section .text
    global rotate

; Function: rotate
; Input: rdi = 64-bit value to rotate, rsi = shift amount (0 to 63)
; Output: rax = result of the rotated value
rotate:
    push rcx
    push rbx
    test rsi, rsi            ; Check if the shift value is 0
    jz .return_val           ; If shift is 0, return the original value in rdi

    ; Perform the right rotation
    mov rax, rdi             ; Copy value to rax
    mov rcx, rsi             ; Move shift amount to rcx for shifting
    shr rax, cl              ; Right shift rax by the shift amount

    ; Calculate (64 - shift)
    mov rbx, 64              ; Load 64 into rbx
    sub rbx, rcx             ; rbx = 64 - shift

    ; Perform the left shift
    mov rcx, rbx             ; Move (64 - shift) into rcx
    mov rbx, rdi             ; Copy the original value to rbx
    shl rbx, cl              ; Left shift rbx by (64 - shift)

    or rax, rbx              ; Combine the shifted values (rotate operation)

.return_val:
    pop rbx
    pop rcx
    ret                      ; Return the result in rax

