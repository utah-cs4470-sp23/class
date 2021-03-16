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
const0: db `This should not be printed\n`, 0
const1: db `This should be printed\n`, 0
const2: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov dword [rbp - 4], 1
	mov dword [rbp - 8], 0
	cmp dword [rbp - 4], 0
	jne .jump1
	lea rdi, [rel const0] ; This should not be printed
	call _fail_assertion
.jump1:
	cmp dword [rbp - 8], 0
	jne .jump2
	lea rdi, [rel const1] ; This should be printed
	call _fail_assertion
.jump2:
	mov rbx, [rel const2] ; 0
	mov [rbp - 16], rbx
	mov rax, [rbp - 16]
	add rsp, 16
	pop rbp
	ret
