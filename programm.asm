.NOLIST
.INCLUDE "m32Adef.inc" ; Header for 
;.list

.def temp = r16
.def leds = r17
.def one = r18

.cseg

main:
	ldi		temp, low(RAMEND) ; Инициализация стека
	out		SPL, temp 
	ldi		temp, high(RAMEND) 
	out		SPH, temp

; Init PD
	ldi		temp, 0b11111100 ; All in, 1 - out
	out		DDRA, temp
	ldi		temp, 0b00000011
	out		PORTA, temp ; 
;	ldi		temp, 0b00000010 ; All in, 1 - out
;	out		DDRD, temp
;	ldi		temp, 0b00000010
;	out		PORTD, temp ; All H-Z, 1 - 5v

; Output PB
	ldi		temp, 0xFF
	out		DDRC, temp     ; Включаем PB на выход
	ldi		temp, 0
	out		PORTC, temp     ; Disable all diods

	; ldi		temp, 0x80     ; Загружаем в temp 1000 0000
	; out		ACSR, temp     ; Отключаем компаратор

	lds      temp, MCUCSR         ; Read MCUCSR 
    sbr      temp, 1<<JTD         ; Set jtag disable flag 
    out      MCUCSR, temp         ; Write MCUCSR 
    out      MCUCSR, temp         ; and again as per 

	lds      temp, ASSR         
    sbr      temp, 0<<AS2       
    out      ASSR, temp         
    out      ASSR, temp         
	nop

	ldi		leds, 0
	ldi		one, 1

start:

no_button:
	in temp, PINA
	sbrs temp, 0
	  rjmp button_left
	sbrs temp, 1
	  rjmp button_right

	rjmp no_button

button_right:
	LSL leds
	add leds, one
	out PORTC, leds
	rjmp button_press_loop

button_left:
	; TODO: watch C flag!
	LSR leds
	out PORTC, leds
	rjmp button_press_loop

button_press_loop:
	in temp, PINA
	sbrs temp, 0
		rjmp button_press_loop
	sbrs temp, 1
		rjmp button_press_loop

	rjmp no_button
