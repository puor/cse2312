@ Jalyn Gilliam 1001170694
@ cse2312
@ Final Exam
@ Dr. McMurrough
@	
@
@ 1) scan for input values
@ 2) ABS(-5.7) = |-5.7| = 5.7
@		input 'a'
@ 3) SQUARE_ROOT(71.2) = sqrt(71.2) = 8.4380092
@		input 's'
@ 4) POW(1.5, 4) = 1.5**4 = 5.0625
@		input 'p'
@ 5) INVERSE(0.3) = 1/0.3 = 3.333333
@		input 'i'

.global main
.func main

main:
	BL _vscanf				@ jump to vault scanf
	VMOV S0, R0				@ move return value to FPU registers
	BL _getchar				@ operation input
	MOV R9, R0 				@ move operation character for later use
	BL _scanop				@ decifier operation input
	B main					@ continuous loop

_vscanf:
	PUSH {LR}				@ store original function return value
	SUB SP,SP,#4			@ make room on stack
	LDR R0, =f_format_str	@ R0 contains address of format string
	MOV R1, SP 				@ move SP to R1 to store entry on stack
	BL scanf				@ call scanf from stdlib
	LDR R0, [SP]			@ load value at SP into R0
	ADD SP, SP, #4			@ restore the stack pointer
	POP {PC}				@ return to calling function

_scanf:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =d_format_str	@ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_getchar:
	MOV R7, #3
	MOV R0, #0
	MOV R2, #1
	LDR R1, =read_char
	SWI 0
	LDR R0, [R1]
	AND R0, #0xFF
	MOV PC, LR

_scanop:
	PUSH {LR}				@ store original function return value
	CMP R9, #'a'			@ if R9 operation == absolute value
	BLEQ _abs				@ if R9 operation == absolute value
	CMP R9,#'s'				@ if R9 operation == square root
	BLEQ _sqrt				@ if R9 operation == square root
	CMP R9,#'p'				@ if R9 operation == power
	BLEQ _pow				@ if R9 operation == power
	CMP R9,#'i'				@ if R9 operation == inverse
	BLEQ _inv				@ if R9 operation == inverse
	POP {PC}				@ return to calling function

_printf:
	PUSH {LR}				@ store original function return value
	LDR R0, =printf_str		@ load string formating into R0
	BL printf 				@ call printf from stdlib
	POP {PC}				@ return to calling function


_abs:
	PUSH {LR}
	VABS.F32 S0, S0			@ abs(S1)
	VCVT.F64.F32 D4, S0		@ convert single to double
	VMOV R1, R2, D4			@ split double VFP register into two ARM registers
	BL _printf				@ print result
	POP {PC}

_sqrt:
	PUSH {LR}
	VSQRT.F32 S0, S0		@ sqrt(S0)
	VCVT.F64.F32 D4, S0 	@ convert single to double
	VMOV R1, R2, D4			@ split double VFP register into two ARM registers
	BL _printf				@ print result
 	POP {PC}

_pow:
	PUSH {LR}
	VMOV S2, S0				@ store original S0
	BL _scanf 				@ regular scan to get raise
	_powloop:
		CMP R0, #1			@ if the raise == 0
		BEQ _powprint		@ if the raise == 0, go to _powprint
		SUB R0, R0, #1		@ increment raise
		VMUL.F32 S0, S0, S2	@ multiply the changing S0 by the static S2
		B _powloop			@ go back to _powloop
	_powprint:
		VCVT.F64.F32 D4, S0	@ convert single to double
		VMOV R1, R2, D4		@ split double VFP register into two ARM registers
		BL _printf			@ print result
	POP {PC}

_inv:
	PUSH {LR}
	MOV R5, #1				@ set constant 1
	VMOV S2, R5				@ set constant 1
	VCVT.F32.U32 S2, S2		@ set constant 1
	VDIV.F32 S0, S2, S0		@ divide 1/S0
	VCVT.F64.F32 D4, S0		@ convert single to double
	VMOV R1, R2, D4			@ split double VFP register into two ARM registers
	BL _printf				@ print result
	POP {PC}

.data
f_format_str:		.asciz		"%f"
d_format_str:		.asciz		"%d"
read_char:			.asciz		 " "
printf_str:			.asciz		"%f\n"


