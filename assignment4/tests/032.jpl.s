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
const0: db `foo.png`, 0
const1: dq 10
const2: db `Please do not modify foo.png, it should be 10x10\n`, 0
const3: dq 0

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	lea rdi, [rbp - 24]
	lea rsi, [rel const0] ; foo.png
	call _read_image
	mov rbx, [rel const1] ; 10
	mov [rbp - 32], rbx
	mov rbx, [rel const1] ; 10
	mov [rbp - 40], rbx
	mov rdi, [rbp - 32]
	mov rsi, [rbp - 40]
	sub rsp, 32
	mov rbx, [rbp - 24]
	mov [rsp], rbx
	mov rbx, [rbp - 24 + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - 24 + 16]
	mov [rsp + 16], rbx
	call _has_size
	add rsp, 32
	mov [rbp - 44], eax
	cmp dword [rbp - 44], 0
	jne .jump1
	lea rdi, [rel const2] ; Please do not modify foo.png, it should be 10x10
	call _fail_assertion
.jump1:
	mov rbx, [rel const3] ; 0
	mov [rbp - 52], rbx
	mov rax, [rbp - 52]
	add rsp, 64
	pop rbp
	ret
