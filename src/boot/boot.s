	.cpu cortex-m4
	.eabi_attribute 27, 1
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"boot.cpp"
	.text
	.align	1
	.global	main
	.arch armv7e-m
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	main, %function
main:
	.fnstart
.LFB0:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L3
	ldr	r3, [r3]
	ldr	r2, .L3
	orr	r3, r3, #32
	str	r3, [r2]
	ldr	r3, .L3+4
	ldr	r3, [r3]
	ldr	r2, .L3+4
	orr	r3, r3, #2
	str	r3, [r2]
	ldr	r3, .L3+8
	ldr	r3, [r3]
	ldr	r2, .L3+8
	orr	r3, r3, #2
	str	r3, [r2]
	ldr	r3, .L3+4
	ldr	r3, [r3]
	ldr	r2, .L3+4
	orr	r3, r3, #4
	str	r3, [r2]
	ldr	r3, .L3+8
	ldr	r3, [r3]
	ldr	r2, .L3+8
	orr	r3, r3, #4
	str	r3, [r2]
	ldr	r3, .L3+4
	ldr	r3, [r3]
	ldr	r2, .L3+4
	orr	r3, r3, #8
	str	r3, [r2]
	ldr	r3, .L3+8
	ldr	r3, [r3]
	ldr	r2, .L3+8
	orr	r3, r3, #8
	str	r3, [r2]
.L2:
	ldr	r3, .L3+12
	movs	r2, #2
	str	r2, [r3]
	bl	_Z5Delayv
	ldr	r3, .L3+12
	movs	r2, #0
	str	r2, [r3]
	bl	_Z5Delayv
	b	.L2
.L4:
	.align	2
.L3:
	.word	1074783752
	.word	1073894684
	.word	1073894400
	.word	1073893432
	.cantunwind
	.fnend
	.size	main, .-main
	.align	1
	.global	_Z5Delayv
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_Z5Delayv, %function
_Z5Delayv:
	.fnstart
.LFB1:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	movs	r3, #0
	str	r3, [r7, #4]
.L7:
	ldr	r3, [r7, #4]
	ldr	r2, .L9
	cmp	r3, r2
	ite	ls
	movls	r3, #1
	movhi	r3, #0
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L8
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
	b	.L7
.L8:
	nop
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
.L10:
	.align	2
.L9:
	.word	399999
	.cantunwind
	.fnend
	.size	_Z5Delayv, .-_Z5Delayv
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
