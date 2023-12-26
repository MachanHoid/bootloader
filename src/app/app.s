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
	.file	"app.cpp"
	.text
	.section	.text._ZN4GPIOC2EPVmS1_S1_h,"axG",%progbits,_ZN4GPIOC5EPVmS1_S1_h,comdat
	.align	1
	.weak	_ZN4GPIOC2EPVmS1_S1_h
	.arch armv7e-m
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN4GPIOC2EPVmS1_S1_h, %function
_ZN4GPIOC2EPVmS1_S1_h:
	.fnstart
.LFB1:
	@ args = 4, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #20
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	str	r3, [r7]
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #8]
	str	r2, [r3]
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	str	r2, [r3, #4]
	ldr	r3, [r7, #12]
	ldr	r2, [r7]
	str	r2, [r3, #8]
	ldr	r3, [r7, #12]
	ldrb	r2, [r7, #24]
	strb	r2, [r3, #12]
	ldr	r3, [r7, #12]
	mov	r0, r3
	adds	r7, r7, #20
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.cantunwind
	.fnend
	.size	_ZN4GPIOC2EPVmS1_S1_h, .-_ZN4GPIOC2EPVmS1_S1_h
	.weak	_ZN4GPIOC1EPVmS1_S1_h
	.thumb_set _ZN4GPIOC1EPVmS1_S1_h,_ZN4GPIOC2EPVmS1_S1_h
	.section	.text._ZN4GPIO6enableEv,"axG",%progbits,_ZN4GPIO6enableEv,comdat
	.align	1
	.weak	_ZN4GPIO6enableEv
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN4GPIO6enableEv, %function
_ZN4GPIO6enableEv:
	.fnstart
.LFB3:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	ldr	r3, [r3]
	ldr	r2, [r3]
	ldr	r3, [r7, #4]
	ldrb	r3, [r3, #12]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [r7, #4]
	ldr	r3, [r3]
	orrs	r2, r2, r1
	str	r2, [r3]
	nop
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.cantunwind
	.fnend
	.size	_ZN4GPIO6enableEv, .-_ZN4GPIO6enableEv
	.section	.text._ZN4GPIO18setDirectionOutputEv,"axG",%progbits,_ZN4GPIO18setDirectionOutputEv,comdat
	.align	1
	.weak	_ZN4GPIO18setDirectionOutputEv
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN4GPIO18setDirectionOutputEv, %function
_ZN4GPIO18setDirectionOutputEv:
	.fnstart
.LFB4:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	ldr	r3, [r3, #4]
	ldr	r2, [r3]
	ldr	r3, [r7, #4]
	ldrb	r3, [r3, #12]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [r7, #4]
	ldr	r3, [r3, #4]
	orrs	r2, r2, r1
	str	r2, [r3]
	nop
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.cantunwind
	.fnend
	.size	_ZN4GPIO18setDirectionOutputEv, .-_ZN4GPIO18setDirectionOutputEv
	.section	.text._ZN4GPIO5writeEh,"axG",%progbits,_ZN4GPIO5writeEh,comdat
	.align	1
	.weak	_ZN4GPIO5writeEh
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN4GPIO5writeEh, %function
_ZN4GPIO5writeEh:
	.fnstart
.LFB5:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	str	r0, [r7, #4]
	mov	r3, r1
	strb	r3, [r7, #3]
	ldrb	r2, [r7, #3]	@ zero_extendqisi2
	ldr	r3, [r7, #4]
	ldrb	r3, [r3, #12]	@ zero_extendqisi2
	asrs	r3, r3, #1
	lsls	r2, r2, r3
	ldr	r3, [r7, #4]
	ldr	r3, [r3, #8]
	str	r2, [r3]
	nop
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.cantunwind
	.fnend
	.size	_ZN4GPIO5writeEh, .-_ZN4GPIO5writeEh
	.section	.text._ZN6BlinkyC2ER4GPIOm,"axG",%progbits,_ZN6BlinkyC5ER4GPIOm,comdat
	.align	1
	.weak	_ZN6BlinkyC2ER4GPIOm
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN6BlinkyC2ER4GPIOm, %function
_ZN6BlinkyC2ER4GPIOm:
	.fnstart
.LFB7:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #20
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #8]
	str	r2, [r3]
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	str	r2, [r3, #4]
	ldr	r3, [r7, #12]
	mov	r0, r3
	adds	r7, r7, #20
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.cantunwind
	.fnend
	.size	_ZN6BlinkyC2ER4GPIOm, .-_ZN6BlinkyC2ER4GPIOm
	.weak	_ZN6BlinkyC1ER4GPIOm
	.thumb_set _ZN6BlinkyC1ER4GPIOm,_ZN6BlinkyC2ER4GPIOm
	.section	.text._ZN6Blinky3runEv,"axG",%progbits,_ZN6Blinky3runEv,comdat
	.align	1
	.weak	_ZN6Blinky3runEv
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN6Blinky3runEv, %function
_ZN6Blinky3runEv:
	.fnstart
.LFB9:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
.L9:
	ldr	r3, [r7, #4]
	ldr	r3, [r3]
	movs	r1, #2
	mov	r0, r3
	bl	_ZN4GPIO5writeEh
	ldr	r0, [r7, #4]
	bl	_ZN6Blinky5delayEv
	ldr	r3, [r7, #4]
	ldr	r3, [r3]
	movs	r1, #0
	mov	r0, r3
	bl	_ZN4GPIO5writeEh
	ldr	r0, [r7, #4]
	bl	_ZN6Blinky5delayEv
	b	.L9
	.cantunwind
	.fnend
	.size	_ZN6Blinky3runEv, .-_ZN6Blinky3runEv
	.section	.text._ZN6Blinky5delayEv,"axG",%progbits,_ZN6Blinky5delayEv,comdat
	.align	1
	.weak	_ZN6Blinky5delayEv
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	_ZN6Blinky5delayEv, %function
_ZN6Blinky5delayEv:
	.fnstart
.LFB10:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #20
	add	r7, sp, #0
	str	r0, [r7, #4]
	movs	r3, #0
	str	r3, [r7, #12]
.L12:
	ldr	r3, [r7, #4]
	ldr	r2, [r3, #4]
	ldr	r3, [r7, #12]
	cmp	r2, r3
	ite	hi
	movhi	r3, #1
	movls	r3, #0
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L13
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
	b	.L12
.L13:
	nop
	adds	r7, r7, #20
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
	.cantunwind
	.fnend
	.size	_ZN6Blinky5delayEv, .-_ZN6Blinky5delayEv
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv4-sp-d16
	.type	main, %function
main:
	.fnstart
.LFB11:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #32
	add	r7, sp, #8
	add	r0, r7, #8
	movs	r3, #2
	str	r3, [sp]
	ldr	r3, .L16
	ldr	r2, .L16+4
	ldr	r1, .L16+8
	bl	_ZN4GPIOC1EPVmS1_S1_h
	add	r3, r7, #8
	mov	r0, r3
	bl	_ZN4GPIO6enableEv
	add	r3, r7, #8
	mov	r0, r3
	bl	_ZN4GPIO18setDirectionOutputEv
	add	r1, r7, #8
	mov	r3, r7
	ldr	r2, .L16+12
	mov	r0, r3
	bl	_ZN6BlinkyC1ER4GPIOm
	mov	r3, r7
	mov	r0, r3
	bl	_ZN6Blinky3runEv
	movs	r3, #0
	mov	r0, r3
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L17:
	.align	2
.L16:
	.word	1073893432
	.word	1073894400
	.word	1073894684
	.word	400000
	.cantunwind
	.fnend
	.size	main, .-main
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
