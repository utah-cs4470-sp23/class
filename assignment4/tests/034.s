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
const1: dq 20
const2: dq 5
const3: dq 15
const4: db `Failure writing to `foo.png``, 0
const5: dq 0

section .text

_main:
	push rbp
	mov rbp, rsp
	sub rsp, 176
	lea rbx, [rel const0] ; foo.png
	mov [rbp - 16], rbx
	lea rdi, [rbp - 40]
	mov rsi, [rbp - 16]
	call _read_image
	lea rbx, [rel const0] ; foo.png
	mov [rbp - 56], rbx
	mov rbx, [rel const1] ; 20
	mov [rbp - 64], rbx
	mov rbx, [rel const1] ; 20
	mov [rbp - 72], rbx
	lea rdi, [rbp - 96]
	mov rsi, [rbp - 64]
	mov rdx, [rbp - 72]
	sub rsp, 32
	mov rbx, [rbp - {loc}]
	mov [rsp], rbx
	mov rbx, [rbp - {loc} + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - {loc} + 16]
	mov [rsp + 16], rbx
	call _resize
	add rsp, 32
	mov rbx, [rel const2] ; 5
	mov [rbp - 104], rbx
	mov rbx, [rel const2] ; 5
	mov [rbp - 112], rbx
	mov rbx, [rel const3] ; 15
	mov [rbp - 120], rbx
	mov rbx, [rel const3] ; 15
	mov [rbp - 128], rbx
	lea rdi, [rbp - 152]
	mov rsi, [rbp - 104]
	mov rdx, [rbp - 112]
	mov rcx, [rbp - 120]
	mov r8, [rbp - 128]
	sub rsp, 32
	mov rbx, [rbp - {loc}]
	mov [rsp], rbx
	mov rbx, [rbp - {loc} + 8]
	mov [rsp + 8], rbx
	mov rbx, [rbp - {loc} + 16]
	mov [rsp + 16], rbx
	call _crop
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
	mov [rbp - 156], eax
	cmp qword [rbp - 156], 0
	jne .jump1
	mov rdi, [rel const4] ; Failure writing to `foo.png`
	call _fail_assertion
.jump1:
	mov rbx, [rel const5] ; 0
	mov [rbp - 164], rbx
	mov rax, [rbp - 164]
	add rsp, 176
	pop rbp
	ret
Compilation succeeded: assembly complete
