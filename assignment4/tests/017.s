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
const2: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [rel const0] ; hi

	mov [rbp - 16], rbx
	mov rdi, [rbp - 16]
	call _print
	mov [rbp - 20], eax
	cmp qword [rbp - 20], 0
	jne .jump1
	mov rdi, [rel const1] ; Failure printing to the screen.
	call _fail_assertion
.jump1:
	mov rbx, [rel const2] ; 0
	mov [rbp - 28], rbx
	mov rax, [rbp - 28]
	add rsp, 32
	pop rbp
	ret
Compilation succeeded: assembly complete
