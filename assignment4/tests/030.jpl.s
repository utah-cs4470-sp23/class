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
const1: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 112
	lea rdi, [rbp - 24]
	lea rsi, [rel const0] ; foo.png
	call _read_image
	mov rbx, [rbp - 24 + 0]
	mov [rbp - 48 + 0], rbx
	mov rbx, [rbp - 24 + 8]
	mov [rbp - 48 + 8], rbx
	mov rbx, [rbp - 24 + 16]
	mov [rbp - 48 + 16], rbx
	mov rbx, [rbp - 48 + 0]
	mov [rbp - 72 + 0], rbx
	mov rbx, [rbp - 48 + 8]
	mov [rbp - 72 + 8], rbx
	mov rbx, [rbp - 48 + 16]
	mov [rbp - 72 + 16], rbx
	mov rbx, [rbp - 72 + 0]
	mov [rbp - 96 + 0], rbx
	mov rbx, [rbp - 72 + 8]
	mov [rbp - 96 + 8], rbx
	mov rbx, [rbp - 72 + 16]
	mov [rbp - 96 + 16], rbx
	mov rbx, [rel const1] ; 0
	mov [rbp - 104], rbx
	mov rax, [rbp - 104]
	add rsp, 112
	pop rbp
	ret
