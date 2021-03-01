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
const0: db `hi\n`, 0
const1: db `Failure printing to the screen.`, 0
const2: db `[`, 0
const3: db `float`, 0
const4: db `s] print "hi"\n\n`, 0
const5: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 112
	call _get_time
	movsd [rbp - 8], xmm0
	lea rbx, [rel const0] ; hi

	mov [rbp - 24], rbx
	mov rdi, [rbp - 24]
	call _print
	mov [rbp - 28], eax
	cmp qword [rbp - 28], 0
	jne .jump1
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump1:
	call _get_time
	movsd [rbp - 36], xmm0
	movsd xmm0, [rbp - 36]
	movsd xmm1, [rbp - 8]
	call _sub_floats
	movsd [rbp - 44], xmm0
	lea rbx, [rel const2] ; [
	mov [rbp - 60], rbx
	mov rdi, [rbp - 60]
	call _print
	mov [rbp - 64], eax
	cmp qword [rbp - 64], 0
	jne .jump2
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump2:
	lea rbx, [rel const3] ; float
	mov [rbp - 80], rbx
	mov rdi, [rbp - 80]
	lea rsi, [rbp - 44]
	call _show
	mov [rbp - 84], eax
	cmp qword [rbp - 84], 0
	jne .jump3
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump3:
	lea rbx, [rel const4] ; s] print "hi"


	mov [rbp - 100], rbx
	mov rdi, [rbp - 100]
	call _print
	mov [rbp - 104], eax
	cmp qword [rbp - 104], 0
	jne .jump4
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump4:
	mov rbx, [rel const5] ; 0
	mov [rbp - 112], rbx
	mov rax, [rbp - 112]
	add rsp, 112
	pop rbp
	ret
Compilation succeeded: assembly complete
