global main
global _main
extern _sub_ints
extern _sub_floats
extern _has_size
extern _sepia
extern _blur
extern _resize
extern _crop
extern _get_time
extern _fail_assertion
extern _print
extern _show
extern _read_image
extern _write_image

section .data
const0: db `foo.png`, 0
const1: dq 20
const2: dq 5
const3: dq 15
const4: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 128
	lea rdi, [rbp - 24]
	lea rsi, [rel const0] ; foo.png
	call _read_image
	mov rbx, [rel const1] ; 20
	mov [rbp - 32], rbx
	mov rbx, [rel const1] ; 20
	mov [rbp - 40], rbx
	lea rdi, [rbp - 64]
	mov rsi, [rbp - 32]
	mov rdx, [rbp - 40]
	sub rsp, 32
	mov rbx, [rbp - 24]
	mov [rsp], rbx
	mov rbx, [rbp - 24 + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - 24 + 16]
	mov [rsp + 16], rbx
	call _resize
	add rsp, 32
	mov rbx, [rel const2] ; 5
	mov [rbp - 72], rbx
	mov rbx, [rel const2] ; 5
	mov [rbp - 80], rbx
	mov rbx, [rel const3] ; 15
	mov [rbp - 88], rbx
	mov rbx, [rel const3] ; 15
	mov [rbp - 96], rbx
	lea rdi, [rbp - 120]
	mov rsi, [rbp - 72]
	mov rdx, [rbp - 80]
	mov rcx, [rbp - 88]
	mov r8, [rbp - 96]
	sub rsp, 32
	mov rbx, [rbp - 64]
	mov [rsp], rbx
	mov rbx, [rbp - 64 + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - 64 + 16]
	mov [rsp + 16], rbx
	call _crop
	add rsp, 32
	lea rdi, [rel const0] ; foo.png
	sub rsp, 32
	mov rbx, [rbp - 120]
	mov [rsp], rbx
	mov rbx, [rbp - 120 + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - 120 + 16]
	mov [rsp + 16], rbx
	call _write_image
	add rsp, 32
	mov rbx, [rel const4] ; 0
	mov [rbp - 128], rbx
	mov rax, [rbp - 128]
	add rsp, 128
	pop rbp
	ret
