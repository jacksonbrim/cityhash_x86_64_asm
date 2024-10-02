; print_hex_number.asm

section .data
    hex_prefix db '0x', 0        ; Prefix for hex values
    hex_digits db '0123456789ABCDEF', 0 ; Lookup table for hex digits
    newline db 10, 0             ; Newline character

section .bss
    buffer resb 16               ; Buffer to store hexadecimal digits

section .text
    global print_hex

; Function to print the hexadecimal representation of a number in RAX
; Input: RAX = 64-bit unsigned integer
print_hex:
    push rbx                     ; Save registers we will use
    push rcx
    push rdx

    mov rbx, rax                 ; Copy the value to rbx for processing
    lea rsi, [buffer+15]         ; Load address of the last byte of the buffer (for reverse filling)
    mov rcx, 16                  ; We will print 16 hex digits (64 bits / 4 bits per hex digit)

.loop:
    mov rdx, rbx                 ; Move the value to rdx to isolate a nibble
    and rdx, 0xF                 ; Mask the lowest 4 bits (one hex digit)
    mov rax, [hex_digits + rdx]  ; Look up the hex character for this nibble
    mov byte [rsi], al           ; Store the character in the buffer
    dec rsi                      ; Move to the previous position in the buffer
    shr rbx, 4                   ; Shift the next nibble into place
    loop .loop                   ; Repeat until all 16 hex digits are processed

    ; Print the hex prefix ("0x")
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, hex_prefix          ; pointer to the prefix
    mov rdx, 2                   ; length of the prefix
    syscall

    ; Print the hexadecimal digits (starting from buffer)
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    lea rsi, [buffer]            ; pointer to the buffer
    mov rdx, 16                  ; length of the hexadecimal string (16 digits)
    syscall

    ; Print newline
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, newline             ; pointer to newline character
    mov rdx, 1                   ; length = 1 byte
    syscall

    ; Restore saved registers
    pop rdx
    pop rcx
    pop rbx

    ret                          ; Return from function

