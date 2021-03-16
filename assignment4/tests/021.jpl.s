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
const0: dq 1
const1: db `int`, 0
const2: db `\n`, 0
const3: dq 2
const4: db `^ If you see '12' you need to print a newline after show commands\n`, 0
const5: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rel const0] ; 1
	mov [rbp - 8], rbx
	lea rdi, [rel const1] ; int
	lea rsi, [rbp - 8]
	call _show
	lea rdi, [rel const2] ; \n
	call _print
	mov rbx, [rel const3] ; 2
	mov [rbp - 16], rbx
	lea rdi, [rel const1] ; int
	lea rsi, [rbp - 16]
	call _show
	lea rdi, [rel const2] ; \n
	call _print
	lea rdi, [rel const4] ; ^ If you see '12' you need to print a newline after show commands
	call _print
	mov rbx, [rel const5] ; 0
	mov [rbp - 24], rbx
	mov rax, [rbp - 24]
	add rsp, 32
	pop rbp
	ret
