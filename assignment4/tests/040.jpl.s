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
const0: dq 77

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	call _get_time
	movsd [rbp - 8], xmm0
	call _get_time
	movsd [rbp - 16], xmm0
	mov rbx, [rel const0] ; 77
	mov [rbp - 24], rbx
	mov rax, [rbp - 24]
	add rsp, 32
	pop rbp
	ret
