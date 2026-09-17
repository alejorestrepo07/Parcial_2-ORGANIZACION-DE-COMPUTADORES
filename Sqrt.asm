// Sqrt.asm
// Autor: Alejandro Restrepo Osorio (A.R.) - Trabajo Individual
// Proposito: Calcular la raiz cuadrada entera de RAM[0] y guardarla en RAM[1].
// Estrategia: Resta sucesiva de numeros impares (1, 3, 5...) hasta que el residuo sea negativo.
// El valor de RAM[0] se preserva intacto usando una variable temporal.

// ==========================================
// DEFINICION DE VARIABLES E INICIALIZACION
// ==========================================

    @R0
    D=M
    @tempN
    M=D         // tempN = RAM[0] (Preservamos el valor original)

    @count
    M=0         // count = 0 (Aca guardamos cuantas restas logramos hacer)

    @oddNum
    M=1         // oddNum = 1 (El primer numero impar a restar)

// ==========================================
// BUCLE PRINCIPAL DE CALCULO
// ==========================================
(LOOP_START)
    // Verificamos si (tempN - oddNum) < 0
    @tempN
    D=M
    @oddNum
    D=D-M       // D = tempN - oddNum
    
    @END_CALC
    D;JLT       // Si da negativo, ya no podemos restar mas, saltamos al final

    // Hacemos la resta oficial: tempN = tempN - oddNum
    @oddNum
    D=M
    @tempN
    M=M-D

    // Aumentamos el contador de raices: count++
    @count
    M=M+1

    // Calculamos el siguiente impar: oddNum = oddNum + 2
    @2
    D=A
    @oddNum
    M=M+D

    // Volvemos a iterar
    @LOOP_START
    0;JMP

// ==========================================
// FINALIZACION Y GUARDADO
// ==========================================
(END_CALC)
    // Pasamos el resultado final a RAM[1]
    @count
    D=M
    @R1
    M=D

// Bucle infinito de cierre (Buenas practicas de Hack)
(INFINITE_LOOP)
    @INFINITE_LOOP
    0;JMP