global _start

BUF_SIZE equ 16384

section .bss
	buffer resb BUF_SIZE

section .text
_start:
	mov rdi, buffer

	mov rsi, [rsp + 16]
	mov rdi, buffer
	mov rdx, BUF_SIZE
	
.inner_loop:
	cmp rdx, 0x0
	jz .continue
	
	mov al, [rsi]
	cmp al, 0x00
	jz .else
	
	mov [rdi], al
	inc rsi
	inc rdi
	dec rdx
	jmp .inner_loop
	
.else:
	mov [rdi], 0x0A
	inc rdi
	dec rdx
	mov rsi, [rsp + 16]
	jmp .inner_loop

.continue:
	mov rdi, 1
	mov rsi, buffer
	mov rdx, BUF_SIZE

.write_loop:
	mov rax, 1
	syscall
	jmp .write_loop
