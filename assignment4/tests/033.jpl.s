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
	sub rsp, 64
	lea rdi, [rbp - 24]
	lea rsi, [rel const0] ; foo.png
	call _read_image
	lea rdi, [rbp - 48]
	sub rsp, 32
	mov rbx, [rbp - 24]
	mov [rsp], rbx
	mov rbx, [rbp - 24 + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - 24 + 16]
	mov [rsp + 16], rbx
	call _sepia
	add rsp, 32
	lea rdi, [rel const0] ; foo.png
	sub rsp, 32
	mov rbx, [rbp - 48]
	mov [rsp], rbx
	mov rbx, [rbp - 48 + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - 48 + 16]
	mov [rsp + 16], rbx
	call _write_image
	add rsp, 32
	mov rbx, [rel const1] ; 0
	mov [rbp - 56], rbx
	mov rax, [rbp - 56]
	add rsp, 64
	pop rbp
	ret
