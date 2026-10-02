.intel_syntax noprefix

.section .rodata

# HTTP GET Response
resp_get:
    .ascii "HTTP/1.1 200 OK\r\n"
    .ascii "Content-Type: text/html; charset=utf-8\r\n"
    .ascii "Connection: close\r\n"
    .ascii "\r\n"
    .ascii "<!DOCTYPE html><html><head>"
    .ascii "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    .ascii "<style>body{font-family:sans-serif;padding:20px;background:#121212;color:#eee;text-align:center;}</style>"
    .ascii "</head><body>"
    .ascii "<h1>Hello from ASM!</h1>"
    .ascii "<p>Handcrafted GET response.</p>"
    .ascii "</body></html>"
resp_get_len = . - resp_get

# HTTP POST Response
resp_post:
    .ascii "HTTP/1.1 200 OK\r\n"
    .ascii "Content-Type: text/html; charset=utf-8\r\n"
    .ascii "Connection: close\r\n"
    .ascii "\r\n"
    .ascii "<!DOCTYPE html><html><head>"
    .ascii "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    .ascii "<style>body{font-family:sans-serif;padding:20px;background:#1a2e1a;color:#a3f7a3;text-align:center;}</style>"
    .ascii "</head><body>"
    .ascii "<h1>POST Received!</h1>"
    .ascii "<p>Processed in child process.</p>"
    .ascii "</body></html>"
resp_post_len = . - resp_post

# HTTP 405 Reponse
resp_405:
    .ascii "HTTP/1.1 405 Method Not Allowed\r\n"
    .ascii "Content-Type: text/html; charset=utf-8\r\n"
    .ascii "Connection: close\r\n"
    .ascii "\r\n"
    .ascii "<!DOCTYPE html><html><body><h1>405 Method Not Allowed</h1></body></html>"
resp_405_len = . - resp_405

	
.section .text
.global _start

_start:
	# socket(AF_INET, SOCK_STREAM, 0);
	mov rdi, 2
	mov rsi, 1
	mov rdx, 0
	mov rax, 41
	syscall

	cmp rax, 0
	jl exit_error
	mov r12, rax

	# bind(server_fd, &addr, sizeof(addr)) ;
	sub rsp, 16
	mov WORD PTR [rsp], 2
	mov WORD PTR [rsp+2], 0x5000
	mov DWORD PTR [rsp+4], 0
	mov QWORD PTR [rsp+8], 0
	mov rdi, r12
	mov rsi, rsp
	mov rdx, 16
	mov rax, 49
	syscall

	add rsp, 16
	cmp rax, 0
	jl exit_error

	mov rdi, r12
	mov rsi, 16
	mov rax, 50
	syscall
	cmp rax, 0
	jl exit_error

loop:
	mov rax, 43
	mov rdi, r12
	mov rsi, 0
	mov rdx, 0
	syscall

	mov r13, rax
	cmp r13, 0
	jl loop

	mov rax, 57
	syscall

	cmp rax, 0
	jl exit_error
	je child_process

	mov rdi, r13
	mov rax, 3
	syscall
	jmp loop

child_process:
	mov rdi, r12
	mov rax, 3
	syscall

	# read(client_fd, buffer, sizeof(buffer) - 1) ;
	sub rsp, 0x800
	mov rdi, r13
	mov rsi, rsp
	mov rdx, 0x800
	mov rax, 0
	syscall

	cmp rax, 4
	jl close

	cmp dword ptr [rsi], 0x20544547
	je handle_get

	cmp dword ptr [rsi], 0x54536F50
	je handle_post

	jmp handle_405


handle_get:
	mov rax, 1
	mov rdi, r13
	lea rsi, [resp_get]
	mov rdx, resp_get_len
	syscall
	jmp close

handle_post:
	mov rax, 1
	mov rdi, r13
	lea rsi, [resp_post]
	mov rdx, resp_post_len
	syscall
	jmp close

handle_405:
	mov rax, 1
	mov rdi, r13
	lea rsi, [resp_405]
	mov rdx, resp_405_len
	syscall
	jmp close

close:	
	mov rdi, r13
	mov rax, 3
	syscall

	
exit_error:	
	mov rax, 60
	xor rdi, rdi
	syscall
