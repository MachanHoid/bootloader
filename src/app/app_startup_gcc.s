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
	.file	"app_startup_gcc.cpp"
	.text
	.global	g_pfnVectors
	.section	.isr_vector,"a"
	.align	2
	.type	g_pfnVectors, %object
	.size	g_pfnVectors, 620
g_pfnVectors:
	.word	_appestack
	.word	_Z8ResetISRv
	.word	_ZL5NmiSRv
	.word	_ZL8FaultISRv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	0
	.word	0
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	0
	.word	0
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
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
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	0
	.word	0
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.word	_ZL17IntDefaultHandlerv
	.text
	.align	1
	.global	_Z8ResetISRv
	.arch armv7e-m
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_Z8ResetISRv, %function
_Z8ResetISRv:
	.fnstart
.LFB0:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	.save {r7, lr}
	.pad #8
	sub	sp, sp, #8
	.setfp r7, sp, #0
	add	r7, sp, #0
	ldr	r3, .L4
	str	r3, [r7, #4]
	ldr	r3, .L4+4
	str	r3, [r7]
.L3:
	ldr	r3, [r7]
	ldr	r2, .L4+8
	cmp	r3, r2
	bcs	.L2
	ldr	r2, [r7, #4]
	adds	r3, r2, #4
	str	r3, [r7, #4]
	ldr	r3, [r7]
	adds	r1, r3, #4
	str	r1, [r7]
	ldr	r2, [r2]
	str	r2, [r3]
	b	.L3
.L2:
	.syntax unified
@ 212 "app_startup_gcc.cpp" 1
	ldr r0, =_appbss
ldr r1, =_appebss
mov r2, #0
.thumb_func
zero_loop:
cmp r0, r1
it lt
strlt r2, [r0], #4
blt zero_loop
@ 0 "" 2
	.thumb
	.syntax unified
	bl	main
	nop
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L5:
	.align	2
.L4:
	.word	_appldata
	.word	_appdata
	.word	_appedata
	.fnend
	.size	_Z8ResetISRv, .-_Z8ResetISRv
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZL5NmiSRv, %function
_ZL5NmiSRv:
	.fnstart
.LFB1:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
.L7:
	b	.L7
	.cantunwind
	.fnend
	.size	_ZL5NmiSRv, .-_ZL5NmiSRv
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZL8FaultISRv, %function
_ZL8FaultISRv:
	.fnstart
.LFB2:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
.L9:
	b	.L9
	.cantunwind
	.fnend
	.size	_ZL8FaultISRv, .-_ZL8FaultISRv
	.align	1
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZL17IntDefaultHandlerv, %function
_ZL17IntDefaultHandlerv:
	.fnstart
.LFB3:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
.L11:
	b	.L11
	.cantunwind
	.fnend
	.size	_ZL17IntDefaultHandlerv, .-_ZL17IntDefaultHandlerv
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
