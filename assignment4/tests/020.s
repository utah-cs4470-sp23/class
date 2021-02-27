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
const0: db `3 = `, 0
const1: db `Failure printing to the screen.`, 0
const2: db `int`, 0
const3: dq 3
const4: db `\n`, 0
const5: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 80
	lea rbx, [rel const0] ; 3 = 
	mov [rbp - 16], rbx
	mov rdi, [rbp - 16]
	call _print
	mov [rbp - 20], eax
	cmp qword [rbp - 20], 0
	jne .jump1
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump1:
	lea rbx, [rel const2] ; int
	mov [rbp - 36], rbx
	mov rbx, [rel const3] ; 3
	mov [rbp - 44], rbx
	mov rdi, [rbp - 36]
	lea rsi, [rbp - 44]
	call _show
	mov [rbp - 48], eax
	cmp qword [rbp - 48], 0
	jne .jump2
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump2:
	lea rbx, [rel const4] ; 

	mov [rbp - 64], rbx
	mov rdi, [rbp - 64]
	call _print
	mov [rbp - 68], eax
	cmp qword [rbp - 68], 0
	jne .jump3
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump3:
	mov rbx, [rel const5] ; 0
	mov [rbp - 76], rbx
	mov rax, [rbp - 76]
	add rsp, 80
	pop rbp
	ret
Compilation succeeded: assembly complete
