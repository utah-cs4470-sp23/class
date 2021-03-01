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
const0: db `foo.png`, 0
const1: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	lea rbx, [rel const0] ; foo.png
	mov [rbp - 16], rbx
	lea rdi, [rbp - 40]
	mov rsi, [rbp - 16]
	call _read_image
	mov rbx, [rel const1] ; 0
	mov [rbp - 48], rbx
	mov rax, [rbp - 48]
	add rsp, 48
	pop rbp
	ret
Compilation succeeded: assembly complete
