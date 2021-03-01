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
const0: dq 2
const1: db `float`, 0
const2: db `\n`, 0
const3: dq 0

section .text
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	call _get_time
	movsd [rbp - 8], xmm0
	mov rbx, [rel const0] ; 2
	mov [rbp - 16], rbx
	call _get_time
	movsd [rbp - 24], xmm0
	movsd xmm0, [rbp - 24]
	movsd xmm1, [rbp - 8]
	call _sub_floats
	movsd [rbp - 32], xmm0
	lea rdi, [rel const1] ; float
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
Compilation succeeded: assembly complete
