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
const0: dq 5
const1: db `int`, 0
const2: db `\n`, 0
const3: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, [rel const0] ; 5
	mov [rbp - 8], rbx
	mov rbx, [rbp - 8 + 0]
	mov [rbp - 16 + 0], rbx
	mov rbx, [rbp - 16 + 0]
	mov [rbp - 24 + 0], rbx
	mov rbx, [rbp - 24 + 0]
	mov [rbp - 32 + 0], rbx
	lea rdi, [rel const1] ; int
	lea rsi, [rbp - 32]
	call _show
	lea rdi, [rel const2] ; \n
	call _print
	mov rbx, [rel const3] ; 0
	mov [rbp - 40], rbx
	mov rax, [rbp - 40]
	add rsp, 48
	pop rbp
	ret
