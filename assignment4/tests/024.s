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
const0: db `true = `, 0
const1: db `Failure printing to the screen.`, 0
const2: db `bool`, 0
const3: db `\n`, 0
const4: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 80
	lea rbx, [rel const0] ; true = 
	mov [rbp - 16], rbx
	mov rdi, [rbp - 16]
	call _print
	mov [rbp - 20], eax
	cmp qword [rbp - 20], 0
	jne .jump1
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump1:
	lea rbx, [rel const2] ; bool
	mov [rbp - 36], rbx
	mov dword [rbp - 40], 1
	mov rdi, [rbp - 36]
	lea rsi, [rbp - 40]
	call _show
	mov [rbp - 44], eax
	cmp qword [rbp - 44], 0
	jne .jump2
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump2:
	lea rbx, [rel const3] ; 

	mov [rbp - 60], rbx
	mov rdi, [rbp - 60]
	call _print
	mov [rbp - 64], eax
	cmp qword [rbp - 64], 0
	jne .jump3
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump3:
	mov rbx, [rel const4] ; 0
	mov [rbp - 72], rbx
	mov rax, [rbp - 72]
	add rsp, 80
	pop rbp
	ret
Compilation succeeded: assembly complete
