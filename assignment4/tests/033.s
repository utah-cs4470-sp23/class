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
const0: db `foo.png`, 0
const1: dq 3.14
const2: db `Failure writing to `foo.png``, 0
const3: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 112
	lea rbx, [rel const0] ; foo.png
	mov [rbp - 16], rbx
	lea rdi, [rbp - 40]
	mov rsi, [rbp - 16]
	call _read_image
	lea rbx, [rel const0] ; foo.png
	mov [rbp - 56], rbx
	mov rbx, [rel const1] ; 3.14
	mov [rbp - 64], rbx
	lea rdi, [rbp - 88]
	movsd xmm0, [rbp - 64]
	sub rsp, 32
	mov rbx, [rbp - {loc}]
	mov [rsp], rbx
	mov rbx, [rbp - {loc} + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - {loc} + 16]
	mov [rsp + 16], rbx
	call _blur
	add rsp, 32
	mov rdi, [rbp - 56]
	sub rsp, 32
	mov rbx, [rbp - {loc}]
	mov [rsp], rbx
	mov rbx, [rbp - {loc} + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - {loc} + 16]
	mov [rsp + 16], rbx
	call _write_image
	add rsp, 32
	mov [rbp - 92], eax
	cmp qword [rbp - 92], 0
	jne .jump1
	mov rdi, [rel const2] ; Failure writing to `foo.png`
	call _fail_assertion
.jump1:
	mov rbx, [rel const3] ; 0
	mov [rbp - 100], rbx
	mov rax, [rbp - 100]
	add rsp, 112
	pop rbp
	ret
Compilation succeeded: assembly complete
