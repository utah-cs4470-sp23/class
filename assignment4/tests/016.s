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
const0: db `This should not be printed`, 0
const1: db `This should be printed`, 0
const2: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov dword [rbp - 4], 1
	mov dword [rbp - 8], 0
	cmp qword [rbp - 4], 0
	jne .jump1
	mov rdi, [rel const0] ; This should not be printed
	call _fail_assertion
.jump1:
	cmp qword [rbp - 8], 0
	jne .jump2
	mov rdi, [rel const1] ; This should be printed
	call _fail_assertion
.jump2:
	mov rbx, [rel const2] ; 0
	mov [rbp - 16], rbx
	mov rax, [rbp - 16]
	add rsp, 16
	pop rbp
	ret
Compilation succeeded: assembly complete
