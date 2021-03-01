global _main
extern _sub_ints
extern _sub_floats
extern _has_size
extern _sepia
extern _blur
extern _resize
extern _crop
extern _read_image
extern _print
extern _write_image
extern _show
extern _fail_assertion
extern _get_time

section .data
const0: dq 1

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rel const0] ; 1
	mov [rbp - 8], rbx
	mov rax, [rbp - 8]
	add rsp, 16
	pop rbp
	ret
Compilation succeeded: assembly complete
