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
const1: dq 7

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rdi, [rbp - 24]
	lea rsi, [rel const0] ; foo.png
	call _read_image
	mov rbx, [rel const1] ; 7
	mov [rbp - 32], rbx
	mov rax, [rbp - 32]
	add rsp, 32
	pop rbp
	ret
