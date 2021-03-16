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
const0: db `bool`, 0
const1: db `\n`, 0
const2: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov dword [rbp - 4], 1
	lea rdi, [rel const0] ; bool
	lea rsi, [rbp - 4]
	call _show
	lea rdi, [rel const1] ; \n
	call _print
	mov rbx, [rel const2] ; 0
	mov [rbp - 12], rbx
	mov rax, [rbp - 12]
	add rsp, 16
	pop rbp
	ret
