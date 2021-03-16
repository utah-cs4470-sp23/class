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
const0: dq 3.14
const1: dq 1.27
const2: dq 2.72
const3: dq 12.34
const4: dq 4

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	mov rbx, [rel const0] ; 3.14
	mov [rbp - 8], rbx
	mov rbx, [rel const1] ; 1.27
	mov [rbp - 16], rbx
	movsd xmm0, [rbp - 8]
	movsd xmm1, [rbp - 16]
	call _sub_floats
	movsd [rbp - 24], xmm0
	mov rbx, [rel const2] ; 2.72
	mov [rbp - 32], rbx
	mov rbx, [rel const3] ; 12.34
	mov [rbp - 40], rbx
	movsd xmm0, [rbp - 32]
	movsd xmm1, [rbp - 40]
	call _sub_floats
	movsd [rbp - 48], xmm0
	movsd xmm0, [rbp - 24]
	movsd xmm1, [rbp - 48]
	call _sub_floats
	movsd [rbp - 56], xmm0
	mov rbx, [rel const4] ; 4
	mov [rbp - 64], rbx
	mov rax, [rbp - 64]
	add rsp, 64
	pop rbp
	ret
