// GlyphMatrix.asm
// Autor: Alejandro Restrepo Osorio (A.R.) - Trabajo Individual
// Letras: A (65), R (82), O (79)
// Funciones: Espacio (32) para Backspace, 'C' (67) para Limpiar Pantalla
// Proposito: Interfaz de escritura continua tipo terminal con limites de pantalla

// INICIALIZACION DE PUNTEROS Y VARIABLES

(INIT)
    @SCREEN
    D=A
    @cursor         // Puntero dinamico de escritura en pantalla
    M=D
    
    @colCount       // Seguimiento de caracteres horizontales (Max 16)
    M=0
    
    @rowCount       // Seguimiento de lineas verticales (Max 8)
    M=0

// BUCLE PRINCIPAL DE SONDEO (POLLING)

(MAIN_LOOP)
    @KBD
    D=M
    
    // Si no hay lectura en el buffer, continua el sondeo
    @MAIN_LOOP
    D;JEQ
    
    // Comando de borrado individual / Backspace (Espacio = ASCII 32)
    @32
    D=D-A
    @BACKSPACE
    D;JEQ
    
    @KBD
    D=M
    // Comando de limpieza total (Tecla 'C' = ASCII 67)
    @67
    D=D-A
    @CLEAR_MATRIX
    D;JEQ
    
    // VALIDACION DE PANTALLA LLENA
    // Si rowCount == 8, ignorar letras y forzar espera de liberacion.
    // Como esto esta despues de Espacio y 'C', esas dos siguen funcionando.
    @rowCount
    D=M
    @8
    D=D-A
    @WAIT_RELEASE
    D;JEQ
    
    @KBD
    D=M
    // Evaluacion caracter 'A' (ASCII 65)
    @65
    D=D-A
    @DRAW_A
    D;JEQ
    
    @KBD
    D=M
    // Evaluacion caracter 'R' (ASCII 82)
    @82
    D=D-A
    @DRAW_R
    D;JEQ

    @KBD
    D=M
    // Evaluacion caracter 'O' (ASCII 79)
    @79
    D=D-A
    @DRAW_O
    D;JEQ
    
    // Ignorar entradas no mapeadas
    @MAIN_LOOP
    0;JMP

// GESTION DE BORRADO (BACKSPACE)

(BACKSPACE)
    // 1. Verificar si el cursor esta en la posicion inicial (nada que borrar)
    @cursor
    D=M
    @16384
    D=D-A
    @WAIT_RELEASE
    D;JEQ
    
    // 2. Verificar si la pantalla esta llena (Cursor bloqueado en borde)
    @rowCount
    D=M
    @8
    D=D-A
    @BACKSPACE_FROM_FULL
    D;JEQ
    
    // 3. Verificar si estamos al inicio de una linea normal
    @colCount
    D=M
    @BACKSPACE_LINE_WRAP
    D;JEQ

(BACKSPACE_SAME_LINE)
    // Borrado en la misma linea: retroceder 1 columna (2 palabras)
    @colCount
    M=M-1
    @2
    D=A
    @cursor
    M=M-D
    @ERASE_GLYPH
    0;JMP

(BACKSPACE_LINE_WRAP)
    // Borrado con salto de linea inverso
    @15
    D=A
    @colCount
    M=D             // Mueve la columna al limite derecho (15)
    
    @rowCount
    M=M-1           // Decrementa la fila actual
    
    // Retorno del puntero: -994 palabras
    // (Retrocede 1024 del salto de fila, pero avanza 30 a la col 15 -> -994)
    @994
    D=A
    @cursor
    M=M-D
    
    @ERASE_GLYPH
    0;JMP

(BACKSPACE_FROM_FULL)
    // Borrado especial cuando la maquina se bloqueo en el caracter 128.
    // Como el programa no aplico el salto de +992, solo restamos 2 palabras.
    @7
    D=A
    @rowCount
    M=D
    
    @15
    D=A
    @colCount
    M=D
    
    @2
    D=A
    @cursor
    M=M-D
    
    @ERASE_GLYPH
    0;JMP

(ERASE_GLYPH)
    // Limpieza del bloque 32x32 en la posicion actualizada del cursor
    @cursor
    D=M
    @R0
    M=D
    
    @32
    D=A
    @R1
    M=D             // Contador de 32 filas de pixeles

(ERASE_LOOP)
    @R0
    A=M
    M=0             // Borra palabra izquierda
    A=A+1
    M=0             // Borra palabra derecha
    
    @32
    D=A
    @R0
    M=M+D           // Desciende a la siguiente fila del framebuffer
    
    @R1
    M=M-1
    D=M
    @ERASE_LOOP
    D;JGT
    
    @WAIT_RELEASE
    0;JMP


// RUTINA DE LIMPIEZA TOTAL DE PANTALLA ('C')

(CLEAR_MATRIX)
    @SCREEN
    D=A
    @R0
    M=D
    
    @8192           // Totalidad de palabras del mapa de bits de 512x256
    D=A
    @R1
    M=D

(CLEAR_MATRIX_LOOP)
    @R0
    A=M
    M=0
    @R0
    M=M+1
    @R1
    M=M-1
    D=M
    @CLEAR_MATRIX_LOOP
    D;JGT
    
    // Restablecimiento de variables de control tras limpieza total
    @INIT
    0;JMP


// GESTION DE MATRIZ BIDIMENSIONAL Y CURSOR

(UPDATE_CURSOR)
    // Desplazamiento horizontal (2 palabras = 32 pixeles)
    @2
    D=A
    @cursor
    M=M+D
    
    // Incremento y evaluacion de limite de columna
    @colCount
    M=M+1
    D=M
    
    @16
    D=D-A
    @NEXT_LINE
    D;JEQ
    
    @WAIT_RELEASE
    0;JMP

(NEXT_LINE)
    @colCount
    M=0             // Retorno de carro (Reset de columna)
    
    @rowCount
    M=M+1           // Salto de linea
    D=M
    
    // Evaluacion de fin de pantalla (8 lineas maximas)
    @8
    D=D-A
    @WAIT_RELEASE
    D;JEQ           // Si se alcanzan 8 lineas, bloquea el avance del cursor
    
    // Calculo de salto de memoria para nueva fila:
    // 32 palabras * 32 pixeles = 1024 avance total.
    // Restamos 32 palabras ya recorridas = 992 palabras netas.
    @992
    D=A
    @cursor
    M=M+D
    
    @WAIT_RELEASE
    0;JMP


// RUTINA ANTI-REBOTE (DEBOUNCE DE HARDWARE)

(WAIT_RELEASE)
    @KBD
    D=M
    @WAIT_RELEASE
    D;JGT           // Bloquea el flujo hasta liberar la tecla
    @MAIN_LOOP
    0;JMP


// RENDERIZADO DE CARACTER 'A' (32px Alto)

(DRAW_A)
    @cursor
    D=M
    @R0
    M=D
    
    // Filas 1-2 (Espaciado superior)
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 3-6 (Punta superior)
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 7-16 (Cuerpo superior)
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 17-20 (Travesaño central)
    @16380
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @16380
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @16380
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @16380
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 21-30 (Piernas)
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Fila 31 (Espaciado inferior)
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Fila 32 (Base final estricta)
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    
    @UPDATE_CURSOR
    0;JMP


// RENDERIZADO DE CARACTER 'R' (32px Alto)

(DRAW_R)
    @cursor
    D=M
    @R0
    M=D
    
    // Filas 1-2
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 3-6
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 7-16
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 17-20
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4092
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 21-30
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Fila 31
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Fila 32
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    
    @UPDATE_CURSOR
    0;JMP

// RENDERIZADO DE CARACTER 'O' (32px Alto)

(DRAW_O)
    @cursor
    D=M
    @R0
    M=D
    
    // Filas 1-2
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 3-6
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 7-26 (Bordes verticales)
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @12292
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Filas 27-30
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    @4080
    D=A
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Fila 31
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    @32
    D=A
    @R0
    M=M+D
    
    // Fila 32
    D=0
    @R0
    A=M
    M=D
    A=A+1
    M=0
    
    @UPDATE_CURSOR
    0;JMP