/*
* Prelab1.asm
*
* Autor : Axel Leonel
* Descripción: Contador biario de 4 bits sin acarreo
*/

//Configuraciones previas
.include "M328PDEF.inc"
.cseg
.org    0x0000

// Configuración de la pila
LDI     R16, LOW(RAMEND)
OUT     SPL, R16        // Cargar 0xff a SPL
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16        // Cargar 0x08 a SPH

SETUP:
	//Deshabilitar comunicacion serial TX RX
	LDI		R16, 0x00
	STS		UCSR0B, R16

    // Configurar puertos (DDRx, PORTx, PINx)

    // Configuracion Puerto Salida D
    LDI     R16, 0xFF
    OUT     DDRD, R16   // PD0-PD7 OUT (leds)
    LDI     R16, 0x00
    OUT     PORTD, R16	// PD0-PD7 LOW

	// Configuracion Puerto Salida C
	LDI     R16, 0xFF
    OUT     DDRC, R16   // PD0-PD7 OUT (leds)
    LDI     R16, 0x00
    OUT     PORTC, R16	// PD0-PD7 LOW

	// Configuracion Puerto Entrada B
    LDI     R16, 0x00
    OUT     DDRB, R16   // PB0-PB7 IN (pushbuttons)
    LDI     R16, 0xFF
    OUT     PORTB, R16	// PB0-PB7 Pull-ups (habilitados)
	NOP
	NOP

    IN     R17, PINB // R17 guarda el estado de los botones
	LDI		R19, 0x00 // Contador 1
	LDI		R20, 0x00 // Contador 2
	LDI		R21, 0x00 // Registro Auxiliar
	LDI		R22, 0x00 // Registro que almacenara la suma
LOOP:
	// Definicion de MAIN
    IN      R16, PINB	// Leer a 0ms
    CP      R17, R16	// Comparar R17 y R16 (En un principio ambos son 0xFF)
    BREQ    LOOP		// Salta a la siguiente linea si r17 y r16 son iguales
    CALL    DELAY		// Llamar Subrutina DELAY

	// Repetir lectura por ANTIREBOTE
    IN      R16, PINB   // Leer a 20ms
    CP      R17, R16	
    BREQ    LOOP		//Saltara a la siguiente linea si el boton sigue presionado

	// Contador 1
	MOV     R17, R16    // Guardando Estado nuevo de botones
	SBRS	R16, 0		//Si el registro 0 de R16 es cero (botón 1 presionado) ve a Incremento 1
	CALL	INCREMENTO1
	SBRS	R16, 1		//Si el registro 1 de R16 es cero (botón 2 presionado) ve a Decremento 1
	CALL	DECREMENTO1

	// Contador 2
	SBRS	R16, 2		//Si el registro 2 de R16 es cero (botón 3 presionado) ve a Incremento 2
	CALL	INCREMENTO2
	SBRS	R16, 3		//Si el registro 3 de R16 es cero (botón 4 presionado) ve a Decremento 4
	CALL	DECREMENTO2

	// Suma Contador 1 + Contador 2
	
	SBRS	R16, 4		//Si el registro 4 de R16 es cero (botón 5 presionado) ve a Sumarlos
	CALL	SUMAR

	// Combinar ambos contadores
	CALL	COMBINACION

	//Finalizar el MAIN
    RJMP    LOOP

INCREMENTO1:
	INC		R19		// Incrementar R19 (sumar uno)
	CPI		R19, 0b00010000		// Si R19 supera 0x0F entonces volver a 0
	BREQ	SETCERO1		
	OUT		PORTD, R19		// Mostrar en PORTD
	RET	

DECREMENTO1:
	DEC		R19		// Decrementar R19 (restar uno)
	OUT		PORTD, R19
	RET	

INCREMENTO2:
	INC		R20		// Incrementar R20 (sumar uno)
	CPI		R20, 0b00010000		// Si R20 supera 0x0F entonces volver a 0
	BREQ	SETCERO2
	OUT		PORTD, R20		// Mostrar en PORTD
	RET	

DECREMENTO2:
	DEC		R20		// Decrementar R20 (restar uno)
	OUT		PORTD, R20
	RET	

SETCERO1:
	LDI		R19, 0x00
	RET

SETCERO2:
	LDI		R20, 0x00
	RET

COMBINACION:
    MOV		R21, R20    // Almacenar R20 en R21 de forma auxiliar
    LSL		R21         // Correr a la izquierda x 4
    LSL		R21         
    LSL		R21         
    LSL		R21         
    ADD		R21, R19    // Unir 4 bits de R21 (sus ultimos 4 seran 0s) y los 4 bits menores de R19 (sus primeros 4 bits son 0s)
    OUT		PORTD, R21  // Mostrar en PORTD (leds) la combinacion de ambos contadores
    RET

SUMAR:
	CALL	SETCERO3
	ADD		R22, R19	// Sumar los valores del contador 1 (R19) con contador 2 (R20) y almacenar en registro 22
	ADD		R22, R20	
	OUT		PORTC, R22	// Mostrar en PORTC (leds suma) la combinacion de ambos, puede haber un carry
	RET

SETCERO3:
	LDI		R22, 0x00
	RET

// Delay (tres subdelays)
DELAY:
    LDI     R18, 0
SUBDELAY1:
    INC     R18
    CPI     R18, 0
    BRNE    SUBDELAY1
    LDI     R18, 0
SUBDELAY2:
    INC     R18
    CPI     R18, 0
    BRNE    SUBDELAY2
    LDI     R18, 0
SUBDELAY3:
    INC     R18
    CPI     R18, 0
    BRNE    SUBDELAY3
    LDI     R18, 0
SUBDELAY4:
    INC     R18
    CPI     R18, 0
    BRNE    SUBDELAY4
    RET
