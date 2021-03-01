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
const1: db `t = `, 0
const2: db `Failure printing to the screen.`, 0
const3: db `int`, 0
const4: db `\n`, 0
const5: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 112
	mov rbx, [rel const0] ; 1
	mov [rbp - 8], rbx
	mov rbx, [rbp - 8 + 0]
	mov [rbp - 16 + 0], rbx
	mov rbx, [rbp - 16 + 0]
	mov [rbp - 24 + 0], rbx
	mov rbx, [rbp - 24 + 0]
	mov [rbp - 32 + 0], rbx
	lea rbx, [rel const1] ; t = 
	mov [rbp - 48], rbx
	mov rdi, [rbp - 48]
	call _print
	mov [rbp - 52], eax
	cmp qword [rbp - 52], 0
	jne .jump1
	mov rdi, [rel const2] ; Failure printing to the screen.
	call _fail_assertion
.jump1:
	lea rbx, [rel const3] ; int
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
	lea rbx, [rel const4] ; 

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
