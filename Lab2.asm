;****************************************************************************
; Archvo:	Lab1
; Dispositivo:	PIC16F887
; Autor:	Daniel González 
; Carnet:	171506
; Compilador:	pic-as (v2.30), MPLABX v5.40
;    
; Programa:	contador en el puerto A
; Hardware:	LEDs en el puerto A 
;
; Creado:	2 feb, 2021
; Ultima modificación: 2 feb, 2021
;*****************************************************************************    
PROCESSOR 16F887
#include <xc.inc>


; configuración word1
 CONFIG FOSC=XT	    //Oscilador interno sin salidas
 CONFIG WDTE=OFF    //WDT disabled (reinicio repetitivo del pic)
 CONFIG PWRTE=ON    //PWRT enabled (espera de 72ms al iniciar)
 CONFIG MCLRE=OFF   //el pin de MCLR se utiliza como I/O 
 CONFIG CP=OFF	    //Sin protección de código 
 CONFIG CPD=OFF	    //Sin protección de datos
 
 CONFIG BOREN=OFF   //Sin reinicio cuando el voltaje de alimentación baja de 4v
 CONFIG IESO=OFF    //Reinicio sin cambio de reloj de interno a externo
 CONFIG FCMEN=OFF   //Cambio de reloj externo a interno en caso de fallo 
 CONFIG LVP=ON	    //Programacion en bajo voltaje permitida 
 
;configuración word2
  CONFIG WRT=OFF	//Protección de autoescritura 
  CONFIG BOR4V=BOR40V	//Reinicio abajo de 4V, (BOR21V=2.1V) 

;------------------------------
  PSECT udata_bank0 ;common memory
    cont:	DS  2 ;1 byte apartado
    ;cont_big:	DS  1;1 byte apartado
  
  PSECT resVect, class=CODE, abs, delta=2
  ;----------------------vector reset------------------------
  ORG 00h	;posición 000h para el reset
  resetVec:
    PAGESEL main
    goto main
  
  PSECT code, delta=2, abs
  ORG 100h	;Posición para el código

;---------------configuración main------------------------------
  main: 
    call    conf_ensa	    ;Llama a la configuración de entradas y salidas
    
    banksel PORTA  
;----------ciclo---------------------
 ciclo: 
    btfsc   PORTA, 4	;Cuando no este presionado 
    call    inc_portA
    btfsc   PORTA, 5	;Revisa si no esta presionado 
    call    dec_portA
    
    btfsc   PORTB, 4	;Revisa cuando no este presionado 
    call    inc_portB
    btfsc   PORTB, 5	;Revisa si no esta presionado 
    call    dec_portB
    
    btfsc   PORTC, 5
    call    ARebo_sum
    
    btfsc   STATUS, 1	;Carry 
    bsf	    PORTC, 4
    
    btfss   STATUS, 1	;Carry 
    bcf	    PORTC, 4
    
    goto    ciclo    ;ciclo Infinito 
;------------sub rutinas----------------------------------
 inc_portA:
    call    delay_small	;Antirebote con delay y el bit test file
    btfsc   PORTA, 4	;Revisa de nuevo si no esta presionado
    goto    $-1		;ejecuta una linea atrás	        
    incf    PORTA
    return
 dec_portA:
    call    delay_small
    btfsc   PORTA, 5	;Revisa de nuevo si no esta presionado
    goto    $-1		;ejecuta una linea atrás	        
    decf    PORTA
    return
 inc_portB:
    call    delay_small
    btfsc   PORTB, 4	;Revisa de nuevo si no esta presionado
    goto    $-1		;ejecuta una linea atrás	        
    incf    PORTB
    return
 dec_portB: 
    call    delay_small
    btfsc   PORTB, 5	;Revisa de nuevo si no esta presionado
    goto    $-1		;ejecuta una linea atrás	        
    decf    PORTB
    return
;--------------------SUMA-------------------------------
ARebo_sum:
    btfsc   PORTC, 5
    goto    ARebo_sum
    call    sumar
    return
    
sumar:
    movf    PORTA, w
    addwf   PORTB, w
    movwf   PORTC
    return 
;---------configuración principal, entradas y salidas----------------------
 conf_ensa:
    bsf	    STATUS, 5   ;banco  11
    bsf	    STATUS, 6
    clrf    ANSEL	;pines digitales
    clrf    ANSELH
    ;Cambiar instrucciones para poner las cosas a analogos                         
    bsf	    STATUS, 5	;banco 01
    bcf	    STATUS, 6
    movlw   0xF0	;Movemos literal a F 11110000B
    movwf   TRISA	;bits menos significativos del puerto A como salidas
    movlw   0xF0
    movwf   TRISB	;bits menos significativos de puerto B como salidas
    movlw   01100000B
    movwf   TRISC

    bcf	    STATUS, 5	;banco 00
    bcf	    STATUS, 6
    movlw   0x00
    movwf   PORTA	;Valor incial 0 en puerto A
    movlw   0x00
    movwf   PORTB	;Valor incial 0 en puerto B
    movlw   0x00
    movwf   PORTC	;Valor incial 0 en puerto C
    return
;------------------delays------------------------   
 delay_big:
    movlw	50		;valor inical del contador 
    movwf	cont+1
    call	delay_small	;rutina de delay
    decfsz	cont+1, 1	;decrementar el contador 
    goto	$-2		;ejecutar dos líneas atrás
    return
    
 delay_small:
    movlw	150		;valor incial
    movwf	cont
    decfsz	cont, 1		;decrementar
    goto	$-1		;ejecutar línea anterior
    return
    
end


