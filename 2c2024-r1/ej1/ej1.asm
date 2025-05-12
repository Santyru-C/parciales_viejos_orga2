extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = mapa_t           mapa [rdi]
	; r/m64 = attackunit_t*    compartida [rsi]
	; r/m64 = uint32_t*        fun_hash(attackunit_t*) [rdx]

	; NOTA: poner siempre el prologo y el epilogo primero para no olvidarse
	push rbp
	mov rbp, rsp 
	push r12 ;vamos a usarlo para almacenar el mapa
	push r13 ; para almacenar i
	push r14 ; para almacenar compartida
	push r15 ; para almacenar el hash de copartida
	push rbx ; para almacenar el puntero a la funcion
	sub rsp, 8
	; prologo

	mov r12, rdi ; mapa
	xor r13, r13 ; establecemos i en 0
	mov r15, rsi ; compartida
	mov rbx, rdx ; fun_hash

	mov rdi, r14
	call rbx ;obtenemos el hash de compartida
	mov r15d, eax ;NOTA, SERA POR ESTO EL ERROR?

	; comenzamos el loop
	; existen mejores maneras de hacer un loop en un array en assembly
	; por ejemplo como lo hicimos con el trabajo de asm
	; ya que x86-64 lo almacena como una tira
	; el que rompe las pelotas es c

	while_optimizar:
		cmp r13, 255 * 255 ; corroboramos de no pasarnos de los valores en la superficie
		je end_loop
		;NOTA: recordemos que en c la aritmetica de punteros es automática peeero
		;esto no sucede en asm por lo que vamos a tener que sumar el tamaño de la
		;estructura e ir multiplicadola por el iterador para ir recorriendo el
		;array de la estructura
		
		mov rdi, [r12 + 8 * r13] ; obtenemos el puntero a la unidad actual
		test rdi, rdi ; nos fijamos si es nulo
		je next_iteration ;si es nulo hacemos continue
		
		push rdi; guardamos actual en el stack porque quiero guardarlo por la iteracion
		sub rsp, 8

		call rbx ;llamo a la funcion con el puntero a actual guardado en rdi nos dará el hash en rax

		add rsp, 8
		pop rdi ; ahora vuelvo a obtener mi puntero a actual en rdi (si este no fuera volatil todo seria mas facil)

		cmp rdi, r14 ;comparamos si el puntero almacenado en ambos es el mismo
		je next_iteration ; si es el mismo, continue

		cmp r15d, eax
		jne siga
		inc byte[r14 + 14] ; NOTA: para los operaciones inc o dec hay que declarar los bytes a modificar
		dec byte[rdi + 14]
		mov [r12 + 8 * r13], r14 ; NOTA: r14 es un REGISTRO que guarda un PUNTERO a un attackunit_t

		siga:
		
		cmp byte[rdi + 14], 0
		jne next_iteration
		call free

	next_iteration:
		inc r13
		jmp while_optimizar
	
	end_loop:
	
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp; epilogo
	;NOTA: ante cualquier error FIJARSE PRIMERO SI HICIMOS BIEN EL PROLOGO Y EL EPILOGO
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; r/m64 = mapa_t           mapa
	; r/m64 = uint16_t*        fun_combustible(char*)
	ret

global modificarUnidad
modificarUnidad:
	; r/m64 = mapa_t           mapa
	; r/m8  = uint8_t          x
	; r/m8  = uint8_t          y
	; r/m64 = void*            fun_modificar(attackunit_t*)
	ret