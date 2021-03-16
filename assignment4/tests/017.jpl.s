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
const0: db `hi\n`, 0
const1: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rdi, [rel const0] ; hi
	call _print
	mov rbx, [rel const1] ; 0
	mov [rbp - 8], rbx
	mov rax, [rbp - 8]
	add rsp, 16
	pop rbp
	ret
