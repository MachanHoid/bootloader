	.cpu cortex-m4
	.arch armv7e-m
	.fpu fpv4-sp-d16
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
	.file	"startup_gcc.c"
	.text
	.bss
	.align	2
pui32Stack:
	.space	256
	.size	pui32Stack, 256
	.global	g_pfnVectors
	.section	.isr_vector,"a"
	.align	2
	.type	g_pfnVectors, %object
	.size	g_pfnVectors, 620
g_pfnVectors:
	.word	pui32Stack+256
	.word	ResetISR
	.word	NmiSR
	.word	FaultISR
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	0
	.word	0
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.word	IntDefaultHandler
	.text
	.align	1
	.global	ResetISR
	.syntax unified
	.thumb
	.thumb_func
	.type	ResetISR, %function
ResetISR:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	ldr	r3, .L4
	str	r3, [r7, #4]
	ldr	r3, .L4+4
	str	r3, [r7]
	b	.L2
.L3:
	ldr	r2, [r7, #4]
	adds	r3, r2, #4
	str	r3, [r7, #4]
	ldr	r3, [r7]
	adds	r1, r3, #4
	str	r1, [r7]
	ldr	r2, [r2]
	str	r2, [r3]
.L2:
	ldr	r3, [r7]
	ldr	r2, .L4+8
	cmp	r3, r2
	bcc	.L3
	.syntax unified
@ 292 "startup_gcc.c" 1
	    ldr     r0, =_bss
    ldr     r1, =_ebss
    mov     r2, #0
    .thumb_func
zero_loop:
        cmp     r0, r1
        it      lt
        strlt   r2, [r0], #4
        blt     zero_loop
@ 0 "" 2
	.thumb
	.syntax unified
	ldr	r3, .L4+12
	ldr	r3, [r3]
	ldr	r2, .L4+12
	orr	r3, r3, #15728640
	str	r3, [r2]
	bl	main
	nop
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L5:
	.align	2
.L4:
	.word	_ldata
	.word	_data
	.word	_edata
	.word	-536810104
	.size	ResetISR, .-ResetISR
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.type	NmiSR, %function
NmiSR:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
.L7:
	b	.L7
	.size	NmiSR, .-NmiSR
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.type	FaultISR, %function
FaultISR:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
.L9:
	b	.L9
	.size	FaultISR, .-FaultISR
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.type	IntDefaultHandler, %function
IntDefaultHandler:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
.L11:
	b	.L11
	.size	IntDefaultHandler, .-IntDefaultHandler
	.align	1
	.global	delay
	.syntax unified
	.thumb
	.thumb_func
	.type	delay, %function
delay:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #20
	add	r7, sp, #0
	str	r0, [r7, #4]
	movs	r3, #0
	str	r3, [r7, #12]
	b	.L13
.L14:
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
.L13:
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	cmp	r2, r3
	bgt	.L14
	nop
	nop
	adds	r7, r7, #20
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.size	delay, .-delay
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.type	app_int_handler, %function
app_int_handler:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	ldr	r3, .L18
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L18+4
	ldr	r3, [r3]
	ldr	r2, .L18+4
	orr	r3, r3, #32
	str	r3, [r2]
	ldr	r3, .L18+8
	ldr	r3, [r3]
	ldr	r2, .L18+8
	orr	r3, r3, #2
	str	r3, [r2]
	ldr	r3, .L18+12
	ldr	r3, [r3]
	ldr	r2, .L18+12
	orr	r3, r3, #2
	str	r3, [r2]
	ldr	r3, .L18+8
	ldr	r3, [r3]
	ldr	r2, .L18+8
	orr	r3, r3, #4
	str	r3, [r2]
	ldr	r3, .L18+12
	ldr	r3, [r3]
	ldr	r2, .L18+12
	orr	r3, r3, #4
	str	r3, [r2]
	ldr	r3, .L18+8
	ldr	r3, [r3]
	ldr	r2, .L18+8
	orr	r3, r3, #8
	str	r3, [r2]
	ldr	r3, .L18+12
	ldr	r3, [r3]
	ldr	r2, .L18+12
	orr	r3, r3, #8
	str	r3, [r2]
	movs	r3, #0
	str	r3, [r7, #4]
	b	.L16
.L17:
	ldr	r3, .L18+16
	movs	r2, #2
	str	r2, [r3]
	ldr	r0, .L18+20
	bl	delay
	ldr	r3, .L18+16
	movs	r2, #0
	str	r2, [r3]
	ldr	r0, .L18+20
	bl	delay
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
.L16:
	ldr	r3, [r7, #4]
	cmp	r3, #1
	ble	.L17
	nop
	nop
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L19:
	.align	2
.L18:
	.word	1073763356
	.word	1074783752
	.word	1073894684
	.word	1073894400
	.word	1073893432
	.word	400000
	.size	app_int_handler, .-app_int_handler
	.ident	"GCC: (Arm GNU Toolchain 12.2.MPACBTI-Rel1 (Build arm-12-mpacbti.34)) 12.2.1 20230214"
