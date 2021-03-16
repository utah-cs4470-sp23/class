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
const0: db `line 1\n`, 0
const1: db `line 2\n`, 0
const2: db `^ If those are on the same line, you need to add newlines to strings you print\n`, 0
const3: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rdi, [rel const0] ; line 1
	call _print
	lea rdi, [rel const1] ; line 2
	call _print
	lea rdi, [rel const2] ; ^ If those are on the same line, you need to add newlines to strings you print
	call _print
	mov rbx, [rel const3] ; 0
	mov [rbp - 8], rbx
	mov rax, [rbp - 8]
	add rsp, 16
	pop rbp
	ret
