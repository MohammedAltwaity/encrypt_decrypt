;Neptun : VLDGY0
;Name : Al-Twaity Mohammed

section .data
    inputMsg db "Enter text to encrypt: ", 0
    outputMsg db "Encrypted text: ", 0
    decryptMsg db "Decrypted text: ", 0
    newline db 10, 0        ; new line char
    key db 3                ; number of shif Caesar cipher

section .bss
    buffer resb 256         ; buffer fo user input
    encrypted resb 256      ; buffer for encrypted text
    decrypted resb 256      ; buffer for decrypted text
    length resb 1           ; length of input text

section .text
    global _start

_start:
    ; Display input prompt
    mov eax, 4             
    mov ebx, 1              
    mov ecx, inputMsg       ; message to display
    mov edx, 23             ; message length
    int 0x80

    ; Read user input
    mov eax, 3              ; syscall: read
    mov ebx, 0              ; file descriptor: stdin
    mov ecx, buffer         ; store input here
    mov edx, 256            ; max length
    int 0x80
    mov [length], eax       ; Save the length of the input

    ; Encrypt the input
    mov esi, buffer         ; pointer to input
    mov edi, encrypted      ; pointer to encrypted output
    mov ecx, [length]       ; length of input
    call encrypt

    ; Print encrypted message
    mov eax, 4
    mov ebx, 1
    mov ecx, outputMsg
    mov edx, 17
    int 0x80

    ; Print the encrypted text
    mov eax, 4
    mov ebx, 1
    mov ecx, encrypted
    mov edx, [length]
    int 0x80

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Decrypt the text
    mov esi, encrypted      ; pointer to encrypted text
    mov edi, decrypted      ; pointer to decrypted output
    mov ecx, [length]       ; length of encrypted text
    call decrypt

    ; Print decrypted message
    mov eax, 4
    mov ebx, 1
    mov ecx, decryptMsg
    mov edx, 17
    int 0x80

    ; Print the decrypted text
    mov eax, 4
    mov ebx, 1
    mov ecx, decrypted
    mov edx, [length]
    int 0x80

    ; Exit program
    mov eax, 1              ; syscall: exit
    xor ebx, ebx            ; status: 0
    int 0x80

encrypt:
    ; Encrypt function
encrypt_loop:
    cmp ecx, 0              ; Check if all characters are processed
    jz encrypt_done

    mov al, [esi]           ; Load the current character
    cmp al, 0x41            ; Check if uppercase 'A'
    jl check_lowercase      ; Skip to check for lowercase if not uppercase
    cmp al, 0x5A            ; Check if uppercase 'Z'
    jg check_lowercase      ; Skip if not uppercase

    ; Handle uppercase letters (A-Z)
    add al, byte [key]      ; Apply Caesar cipher shift
    cmp al, 0x5A            ; Check if wraparound needed
    jle no_wrap_encrypt_upper
    sub al, 26              ; Wrap around for uppercase letters
no_wrap_encrypt_upper:
    mov [edi], al           ; Store encrypted character
    inc esi                 ; Move to the next input character
    inc edi                 ; Move to the next output character
    dec ecx                 ; Decrement counter
    jmp encrypt_loop

check_lowercase:
    cmp al, 0x61            ; Check if lowercase 'a'
    jl no_encrypt           ; Skip if not lowercase
    cmp al, 0x7A            ; Check if lowercase 'z'
    jg no_encrypt           ; Skip if not lowercase

    ; Handle lowercase letters (a-z)
    add al, byte [key]      ; Apply Caesar cipher shift
    cmp al, 0x7A            ; Check if wraparound needed
    jle no_wrap_encrypt
    sub al, 26              ; Wrap around for lowercase letters
no_wrap_encrypt:
no_encrypt:
    mov [edi], al           ; Store encrypted character
    inc esi                 ; Move to the next input character
    inc edi                 ; Move to the next output character
    dec ecx                 ; Decrement counter
    jmp encrypt_loop
encrypt_done:
    ret

decrypt:
    ; Decrypt function
decrypt_loop:
    cmp ecx, 0              ; Check if all characters are processed
    jz decrypt_done

    mov al, [esi]           ; Load the current character
    cmp al, 0x41            ; Check if uppercase 'A'
    jl check_lowercase_decrypt ; Skip to check for lowercase if not uppercase
    cmp al, 0x5A            ; Check if uppercase 'Z'
    jg check_lowercase_decrypt ; Skip if not uppercase

    ; Handle uppercase letters (A-Z)
    sub al, byte [key]      ; Reverse Caesar cipher shift
    cmp al, 0x41            ; Check if wraparound needed
    jge no_wrap_decrypt_upper
    add al, 26              ; Wrap around for uppercase letters
no_wrap_decrypt_upper:
    mov [edi], al           ; Store decrypted character
    inc esi                 ; Move to the next input character
    inc edi                 ; Move to the next output character
    dec ecx                 ; Decrement counter
    jmp decrypt_loop

check_lowercase_decrypt:
    cmp al, 0x61            ; Check if lowercase 'a'
    jl no_decrypt           ; Skip if not lowercase
    cmp al, 0x7A            ; Check if lowercase 'z'
    jg no_decrypt           ; Skip if not lowercase

    ; Handle lowercase letters (a-z)
    sub al, byte [key]      ; Reverse Caesar cipher shift
    cmp al, 0x61            ; Check if wraparound needed
    jge no_wrap_decrypt
    add al, 26              ; Wrap around for lowercase letters
no_wrap_decrypt:
no_decrypt:
    mov [edi], al           ; Store decrypted character
    inc esi                 ; Move to the next input character
    inc edi                 ; Move to the next output character
    dec ecx                 ; Decrement counter
    jmp decrypt_loop
decrypt_done:
    ret
