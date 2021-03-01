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
const0: dq 2
const1: db `[`, 0
const2: db `Failure printing to the screen.`, 0
const3: db `float`, 0
const4: db `s] let x = 2\n`, 0
const5: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 112
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
	lea rbx, [rel const1] ; [
	mov [rbp - 48], rbx
	mov rdi, [rbp - 48]
	call _print
	mov [rbp - 52], eax
	cmp qword [rbp - 52], 0
	jne .jump1
	mov rdi, [rel const2] ; Failure printing to the screen.
	call _fail_assertion
.jump1:
	lea rbx, [rel const3] ; float
	mov [rbp - 68], rbx
	mov rdi, [rbp - 68]
	lea rsi, [rbp - 32]
	call _show
	mov [rbp - 72], eax
	cmp qword [rbp - 72], 0
	jne .jump2
	mov rdi, [rel const2] ; Failure printing to the screen.
	call _fail_assertion
.jump2:
	lea rbx, [rel const4] ; s] let x = 2

	mov [rbp - 88], rbx
	mov rdi, [rbp - 88]
	call _print
	mov [rbp - 92], eax
	cmp qword [rbp - 92], 0
	jne .jump3
	mov rdi, [rel const2] ; Failure printing to the screen.
	call _fail_assertion
.jump3:
	mov rbx, [rel const5] ; 0
	mov [rbp - 100], rbx
	mov rax, [rbp - 100]
	add rsp, 112
	pop rbp
	ret
Compilation succeeded: assembly complete
