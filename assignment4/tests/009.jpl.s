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
const0: dq 7
const1: dq 3
const2: dq 9
const3: dq 2
const4: dq 4
const5: dq 6
const6: dq 1

section .text
main:
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 112
	mov rbx, [rel const0] ; 7
	mov [rbp - 8], rbx
	mov rbx, [rel const1] ; 3
	mov [rbp - 16], rbx
	mov rdi, [rbp - 8]
	mov rsi, [rbp - 16]
	call _sub_ints
	mov [rbp - 24], rax
	mov rbx, [rel const2] ; 9
	mov [rbp - 32], rbx
	mov rdi, [rbp - 24]
	mov rsi, [rbp - 32]
	call _sub_ints
	mov [rbp - 40], rax
	mov rbx, [rel const3] ; 2
	mov [rbp - 48], rbx
	mov rbx, [rel const4] ; 4
	mov [rbp - 56], rbx
	mov rbx, [rel const5] ; 6
	mov [rbp - 64], rbx
	mov rbx, [rel const6] ; 1
	mov [rbp - 72], rbx
	mov rdi, [rbp - 64]
	mov rsi, [rbp - 72]
	call _sub_ints
	mov [rbp - 80], rax
	mov rdi, [rbp - 56]
	mov rsi, [rbp - 80]
	call _sub_ints
	mov [rbp - 88], rax
	mov rdi, [rbp - 48]
	mov rsi, [rbp - 88]
	call _sub_ints
	mov [rbp - 96], rax
	mov rdi, [rbp - 40]
	mov rsi, [rbp - 96]
	call _sub_ints
	mov [rbp - 104], rax
	mov rax, [rbp - 104]
	add rsp, 112
	pop rbp
	ret
