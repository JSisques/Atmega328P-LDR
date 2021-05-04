
SER R16															;Ponemos a 1 R16
OUT DDRB, R16													;Sacamos por los puertos B el valor de R16
RCALL config_ADC												;Llamamos a la función para configurar el ADC

main:
	LDS R17, ADCSRA												;Cargamos en R17 el valor de ADCSRA, control y estatus
	ORI R17, (1 << ADSC)										;Activamos el bit de conversion ADC por software
	STS ADCSRA, R17												;Guardamos el valor de R17 en la variable ADCSRA

esperaADC:
	CLR R17														;Ponemos R17 a ceros
	LDS R17, ADCSRA												;Almacenamos en R17 el valor de ADCSRA, para comprobar si la conversion ha terminado
	SBRC R17, ADSC												;Si el bit ADSC esta activo la conversion aun no ha terminado
	RJMP esperaADC												;Saltamos a la etiqueta esperaADC si la conversion no ha terminado

	LDS R16, ADCH												;Almacenamos en R16 el valor de conversion en 8 bits
	
	CPI R16, 128												;Comparamos R16 con el valor 128 (la mitad de un registro)
	BRPL encender												;Saltamos a encender si lo anterior es mayor

	CLR R20														;Establecemos R20 todo a ceros
	OUT PORTB, R20												;Sacamos por el puerto B el valor de R20
	RJMP seguir													;Saltamos a la etiqueta seguir

encender:
	SER R20														;Ponemos todo a uno en el R20
	OUT PORTB, R20												;Sacamos por el puerto B el valor de R20

seguir:
	RJMP main													;Saltamos a la función main

config_ADC:
	PUSH R16													;Hacemos una copia de seguridad de R16 en la pila

	LDI R16, (1 << ADEN)										;Activamos el ADC
	ORI R16, (0 << ADATE)										;Deshabilitamos el autodisparo del conversor
	ORI R16, (0 << ADIE)										;Deshabilitamos la interrupcion de conversion completada
	ORI R16, (1 << ADPS2)|(1 << ADPS1)|(1 << ADPS0)				;Bits de configuración para la velocidad del reloj
	STS ADCSRA, R16												;Guardamos la configuracion anterior en la variable ADCSRA
	ORI R16, (0 << ADTS2)|(0 << ADTS1)|(1 << ADTS0)				;Bits de configuracion para conversiones automaticas, en este caso usamos Analog Comparator
	STS ADCSRB, R16												;Guardamos lo anterior en la variable ADCSRB
	LDI R16, (1 << MUX0)										;Seleccionamos el canal de entrada en este caso el A1 Mux4:0 = 0001
	ORI R16, (0 << REFS1) | (1 << REFS0)						;Establecemos la tensión máxima en este caso los 5V internos
	ORI R16, (1 << ADLAR)										;Resolucion de 8 bits para el ADC
	STS ADMUX, R16												;Guardamos lo anterior en la variable ADMUX
	LDI R16, (1 << ADC1D)										;Desactivamos el input digital para el canal 1 (ahorra energia)
	STS DIDR0, R16												;Guardamos lo anterior en la variable DIDR0
	LDI R16, (0 << PRADC)										;Desactivamos la reducción de energia
	STS PRR, R16												;Guardamos lo anterior en la variable PRR
	
	POP R16														;Recuperamos el valor de R16 guardado en la pila														
	RET