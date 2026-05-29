org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7E00

main_loop:
    call print_prompt
    call read_line
    ; Echo the input back
    mov si, buffer
    call print_string
    call print_newline

    ; Check for "hello"
    lea si, buffer
    lea di, hello_str
    call strcmp
    je say_hello

    ; Check for "ver"
    lea si, buffer
    lea di, ver_str
    call strcmp
    je say_ver

    ; Check for "fill_screen"
    lea si, buffer
    lea di, clear_str
    call strcmp
    je clear_screen

    ; Check for "info"
    lea si, buffer
    lea di, info_str
    call strcmp
    je say_info
   
    ; Check for "help"
    lea si, buffer
    lea di, help_str
    call strcmp
    je say_help

    ; Unknown command
    lea si, unknown_str
    call print_string
    call print_newline
    jmp main_loop

say_info:
    lea si, info_msg
    call print_string
    call print_newline
    jmp main_loop

say_hello:
    lea si, hello_msg
    call print_string
    call print_newline
    jmp main_loop

say_ver:
    lea si, ver_msg
    call print_string
    call print_newline
    jmp main_loop

say_help:
    lea si, help_msg
    call print_string
    call print_newline
    jmp main_loop

; Subroutine: print prompt
print_prompt:
    lea si, prompt
    call print_string
    ret

; Subroutine: print string (null-terminated)
print_string:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 7
    int 0x10
    jmp print_string
.done:
    ret

; Subroutine: print newline (CR+LF)
print_newline:
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    int 0x10
    ret


read_line:
    lea di, buffer
    mov cx, 20
    xor bx, bx     ; length counter
.read_char:
    mov ah, 0x00
    int 0x16      ; wait for key
    mov al, al
    cmp al, 0x0D  ; Enter
    je .done_read
    cmp al, 0x08  ; Backspace
    jne .check_backspace
    ; handle backspace
    cmp bx, 0
    je .read_char
    dec bx
    dec di
    mov ah, 0x02
    mov bh, 0
    mov dl, 0x08
    int 0x10
    jmp .read_char

.check_backspace:
    ; store character
    stosb
    inc bx
    loop .read_char
.done_read:
    mov al, 0
    stosb
    ret

; Routine: clear_screen_with_callback
; Input:
;   DX = address of callback function
; Usage:
;   mov dx, callback_address
;   call clear_screen_with_callback

clear_screen:
    push ax
    push es
    push cx
    push di

    mov ax, 0xB800
    mov es, ax

    mov cx, 2000
    xor di, di

    mov al, 0x20
    mov ah, 0x07

clear_loop:
    mov es:[di], ah
    mov es:[di+1], al
    add di, 2
    loop clear_loop
    jmp main_loop

    pop di
    pop cx
    pop es
    pop ax
    ret

; Subroutine: compare strings (AL in si, DI in di)
strcmp:
    push si
    push di
.compare_loop:
    lodsb
    mov bl, [di]
    inc di
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    jmp .compare_loop
.not_equal:
    stc
    pop di
    pop si
    ret
.equal:
    clc
    pop di
    pop si
    ret

; Data
prompt:      db 'CMD>', 0
hello_str:   db 'hello', 0
ver_str:     db 'ver', 0
clear_str:   db 'fill_screen', 0
info_str:    db 'info', 0
start_str:   db 'OS', 0
help_str:    db 'help', 0

help_msg:    db 'Cmd: help, info, ver, fill_screen', 0
info_msg:    db 'MEM: 512bytes', 0
ver_msg:     db 'BootSec OS', 0
hello_msg:   db 'Hello!', 0
unknown_str: db 'Unknown command', 0
buffer:      times 20 db 0

times 510-($-$$) db 0
dw 0xAA55
