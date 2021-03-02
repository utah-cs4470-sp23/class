;;; Compile me with nasm -felf64 hello.s (or macho64 or win64 instead of elf64)
;;; Then clang hello.o runtime.o -o a.out
;;; Then ./a.out
;;; You should see "Hello, World!" printed

global _main
extern _print

section .data
const0: db `Hello, World!\n`, 0
const1: dq 0

section .text
_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rdi, [rel const0] ; Hello, World!
	call _print
	mov rbx, [rel const1] ; 0
	mov [rbp - 8], rbx
	mov rax, [rbp - 8]
	add rsp, 16
	pop rbp
	ret
