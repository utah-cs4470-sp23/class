global main
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
const0: dq 1
const1: dq 5

section .text
main:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rel const0] ; 1
	mov [rbp - 8], rbx
	mov rbx, [rel const1] ; 5
	mov [rbp - 16], rbx
	mov rdi, [rbp - 16]
	mov rsi, [rbp - 8]
	call _sub_ints
	mov [rbp - 24], rax
	mov rax, [rbp - 24]
	add rsp, 32
	pop rbp
	ret
Compilation succeeded: assembly complete
