; BD Calculator
; Nikhil Jain

#include <p16f887.inc>

num1 equ 0x20
num2 equ 0x21
op equ 0x22
outputcount equ 0x23
temp equ 0x24
result equ 0x25
multiplycounter equ 0x26


	ORG 0
	GOTO main
	ORG 4
	GOTO isr

main: 
; initialize all variables
	clrf num1
	clrf num2
	clrf op
	clrf result

; set PORTC as inputs
	banksel TRISC
	clrf TRISC
	comf TRISC
; set PORTA as inputs
	banksel TRISA
	clrf TRISA
	comf TRISA
	banksel ANSEL
	clrf ANSEL

	banksel PORTD
	clrf PORTD
; set PORTD as output
	banksel TRISD
	clrf TRISD
; set port e as input
	banksel TRISE
	clrf TRISE
	comf TRISE

; set PORTB as output
	banksel TRISB
	clrf TRISB
	banksel ANSELH
	clrf ANSELH

	call num1_input
	nop
	nop
	nop
	nop

	call op_input
	nop
	nop
	nop
	nop

	call num2_input
	nop
	nop
	nop
	nop
	nop

	call which_operation ; selects subroutine depending on op register





num1_input:
; only input if user pressed send key (PORTA = xx1x xxxx)
; first check if send key is pressed
; if it is, then input it
; else, continue checking
	banksel PORTA
	btfss PORTA, 0 ; check 5rd bit in porta
	goto num1_input ; if button is not pressed
; if button is pressed
	banksel PORTC
	movf PORTC, 0
	xorlw 0x0f ; MASKING -- THE ENCODER IS ACTIVE LOW, AND ONLY CONNECTED TO LOWER BYTE OF PORTC
	andlw 0x0f ; clear first 4 bits
	movwf num1

	movwf PORTB ; ; ; ; ;

	nop
	nop	
	nop
	nop	; Use this time to disable the "send" switch enable
	nop
	nop
	return 


num2_input:
	banksel PORTA
	btfss PORTA, 0 ; check 5rd bit in porta
	goto num2_input ; if button is not pressed
; if button is pressed
	banksel PORTC
	movf PORTC, 0
	xorlw 0x0f ; MASKING -- THE ENCODER IS ACTIVE LOW, AND ONLY CONNECTED TO LOWER BYTE OF PORTC
	andlw 0x0f ; clear first 4 bits
	movwf num2
	nop
	nop	
	nop
	nop	; Use this time to disable the "send" switch enable
	nop
	nop
	return 



op_input:
	banksel PORTA
	nop
	nop
	nop	
	btfss PORTA, 0 ; enable bit
	goto op_input
; button is pressed
	nop
	nop
	nop	
	banksel PORTC
	movf PORTC, 0
	andlw 0xC0 ; masking, get rid of the rest of the bits
	movwf op
		
	nop
	nop
	nop	
	nop
	nop
	nop	
	return

which_operation: 

	movf op, 0
	; is the operation 0, aka addition?
	xorlw 0x00
	btfsc STATUS, Z
	goto add ; yes it is, go to addition

	movf op, 0
	; is the operation 1, aka subtraction?
	xorlw 0x40
	btfsc STATUS, Z
	goto subtract

	movf op, 0
	; is the operation 2, aka multiply?
	xorlw 0x80
	btfsc STATUS, Z
	goto multiply

	movf op, 0
	; finally, is the operation 3, aka divide?
	xorlw 0xC0
	btfsc STATUS, Z
	goto divide


add:
	nop
	nop
	nop

	movf num1, 0
	addwf num2, 0
	movwf result
	banksel PORTD
	movwf PORTD
	return

subtract:
	nop
	nop
	nop
	nop
	nop

	movf num2, 0
	subwf num1, 0
	movwf result
	movwf PORTD
	return

;; 2'S COMPLEMENT STUFF DOES NOT WORK	

	; check for negative result
	; meaning carry = 0 and z = 0
	; if so, then perform 2's complement (inverse + 1)
	btfsc STATUS, C
	movwf PORTD
	
	comf PORTD, 1
	incf PORTD, 1	
	
	return

multiply:
	nop
	; check if num2 = 0
	movf num2, 0
	xorlw 0x00
	btfsc STATUS, Z
	return	
; num > 0
	movf num1, 0
	addwf result
	decfsz num2
	goto multiply

	; done multiplying
	movf result, 0
	movwf PORTD
	return

	
	

divide: 
	nop
	nop
	nop
	
	; is num2 = 0?
	movf num2, 0
	xorlw 0x00
	btfsc STATUS, Z
	return
	
	incf result
	movf num2, 0
	subwf num1, 1
; is num1 < num2? (handles remainders)
	btfsc STATUS, C
	goto divide
	
; yes, yes it is
	decf result
	movf result, 0
	movwf PORTD
	return




isr:
	nop
	retfie
	end


