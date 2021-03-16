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
const0: dq 3.0
const1: dq 1.0
const2: db `time:\n`, 0
const3: db `float`, 0
const4: db `\n`, 0
const5: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 160
	call _get_time
	movsd [rbp - 8], xmm0
	call _get_time
	movsd [rbp - 16], xmm0
	call _get_time
	movsd [rbp - 24], xmm0
	call _get_time
	movsd [rbp - 32], xmm0
	call _get_time
	movsd [rbp - 40], xmm0
	mov rbx, [rel const0] ; 3.0
	mov [rbp - 48], rbx
	mov rbx, [rel const1] ; 1.0
	mov [rbp - 56], rbx
	movsd xmm0, [rbp - 48]
	movsd xmm1, [rbp - 56]
	call _sub_floats
	movsd [rbp - 64], xmm0
	call _get_time
	movsd [rbp - 72], xmm0
	movsd xmm0, [rbp - 72]
	movsd xmm1, [rbp - 40]
	call _sub_floats
	movsd [rbp - 80], xmm0
	lea rdi, [rel const2] ; time:
	call _print
	lea rdi, [rel const3] ; float
	lea rsi, [rbp - 80]
	call _show
	lea rdi, [rel const4] ; \n
	call _print
	call _get_time
	movsd [rbp - 88], xmm0
	movsd xmm0, [rbp - 88]
	movsd xmm1, [rbp - 32]
	call _sub_floats
	movsd [rbp - 96], xmm0
	lea rdi, [rel const2] ; time:
	call _print
	lea rdi, [rel const3] ; float
	lea rsi, [rbp - 96]
	call _show
	lea rdi, [rel const4] ; \n
	call _print
	call _get_time
	movsd [rbp - 104], xmm0
	movsd xmm0, [rbp - 104]
	movsd xmm1, [rbp - 24]
	call _sub_floats
	movsd [rbp - 112], xmm0
	lea rdi, [rel const2] ; time:
	call _print
	lea rdi, [rel const3] ; float
	lea rsi, [rbp - 112]
	call _show
	lea rdi, [rel const4] ; \n
	call _print
	call _get_time
	movsd [rbp - 120], xmm0
	movsd xmm0, [rbp - 120]
	movsd xmm1, [rbp - 16]
	call _sub_floats
	movsd [rbp - 128], xmm0
	lea rdi, [rel const2] ; time:
	call _print
	lea rdi, [rel const3] ; float
	lea rsi, [rbp - 128]
	call _show
	lea rdi, [rel const4] ; \n
	call _print
	call _get_time
	movsd [rbp - 136], xmm0
	movsd xmm0, [rbp - 136]
	movsd xmm1, [rbp - 8]
	call _sub_floats
	movsd [rbp - 144], xmm0
	lea rdi, [rel const2] ; time:
	call _print
	lea rdi, [rel const3] ; float
	lea rsi, [rbp - 144]
	call _show
	lea rdi, [rel const4] ; \n
	call _print
	mov rbx, [rel const5] ; 0
	mov [rbp - 152], rbx
	mov rax, [rbp - 152]
	add rsp, 160
	pop rbp
	ret
