# Examen Parcial 2 - Organización de Computadores

**Institución:** EAFIT
**Autor:** Alejandro Restrepo Osorio
**Curso:** Organización de Computadores (S2666-0322)
**Docente:** Edison Valencia Díaz

---

## Descripción del Proyecto

Este repositorio contiene la solución técnica al segundo parcial práctico de la asignatura. El objetivo principal es demostrar el dominio sobre la arquitectura del computador Hack y su repertorio de instrucciones en lenguaje ensamblador (`.asm`), abordando dos problemas clásicos de bajo nivel: operaciones aritméticas complejas sin hardware dedicado y manipulación de Entrada/Salida (I/O) mapeada en memoria.

---

## 1. Módulo Matemático: `Sqrt.asm`

Este programa calcula la parte entera de la raíz cuadrada de un número entero positivo ($N \ge 0$).

### Flujo de Ejecución y Algoritmo

Debido a que la ALU (Unidad Lógico Aritmética) del sistema Hack no posee operaciones nativas para multiplicaciones o divisiones, la extracción de la raíz se resolvió implementando un algoritmo puramente aditivo basado en la sumatoria de números impares consecutivos.

1. **Lectura y Preservación:** El programa lee el radicando desde `RAM[0]`. Para cumplir estrictamente con los requerimientos de memoria, este valor original se preserva intacto en una variable temporal, garantizando que los datos de entrada no sufran mutaciones.
2. **Ciclo de Restas:** Se inicializa un contador en cero y un sustraendo en 1 (el primer número impar). En cada iteración, se resta el impar actual del residuo del radicando.
3. **Condición de Salida:** Si la resta arroja un resultado negativo, el ciclo se rompe. El valor acumulado en el contador corresponde exactamente a la raíz cuadrada entera.
4. **Almacenamiento:** El resultado final se escribe limpiamente en el registro `RAM[1]` antes de ingresar a un bucle infinito de terminación segura.

### Cómo Probarlo
1. Cargue el archivo `Sqrt.asm` en el **CPU Emulator**.
2. Modifique el valor de `RAM[0]` con el número a evaluar (ej: 16, 25, 100).
3. Ejecute el programa y verifique la salida correcta en `RAM[1]`.

---

## 2. Módulo de Gráficos e I/O: `GlyphMatrix.asm`

Este programa gestiona la interacción en tiempo real con el usuario mediante un ciclo infinito de *Polling* (Sondeo) sobre el teclado, dibujando directamente en la memoria de video (framebuffer) patrones de 32x32 píxeles.

### Iniciales y Asignación

Al tratarse de una entrega individual, se aplicó la regla de alternancia dictada en la rúbrica utilizando el primer nombre y el primer apellido del autor. Adicionalmente, se integraron letras extra para demostrar el control sobre los saltos condicionales y el mapeo gráfico:

*   **Teclas activas:** `A`, `R`, `O`, `S`, `G`.
*   **Tecla de limpieza:** `Espacio` (ASCII 32).

### Arquitectura del Código

1. **Sondeo Ininterrumpido (`MAIN_LOOP`):** El código interroga constantemente el registro `RAM[24576]` (Teclado). Al capturar un valor, realiza una serie de restas sucesivas para identificar el código ASCII.
2. **Escritura en Pantalla (`DRAW_...`):** Si se detecta un *hit* con alguna letra registrada, el flujo de ejecución salta a su subrutina específica. El programa utiliza un puntero (alojado en `R0`) configurado en la dirección base de `SCREEN` (16384). El dibujo se realiza inyectando patrones hexadecimales precalculados en palabras de 16 bits, avanzando 32 registros para saltar a la siguiente fila de la pantalla.
3. **Rutina de Limpieza (`CLEAR_MATRIX`):** Se diseñó un bucle compacto de 32 iteraciones controlado por el registro `R1`. Esta rutina inyecta ceros lógicos en el bloque de memoria gráfica para borrar cualquier glifo remanente y restaurar el lienzo a su estado inicial.
4. **Optimización de Instrucciones tipo A:** A nivel de diseño, los mapas de bits se estructuraron espacialmente para evitar valores hexadecimales que requirieran encender el bit 15 (valores mayores a 32767). Esto eliminó la necesidad de rutinas complejas de pre-cálculo y máscaras a nivel de bits, reduciendo la carga computacional de forma drástica.

### Cómo Probarlo
1. Cargue el archivo `GlyphMatrix.asm` en el **CPU Emulator**.
2. **Importante:** Configure la simulación en modo acelerado ajustando `Animate` en **No Animation** y la barra de velocidad en **Fast**. El renderizado gráfico en Java causa latencia severa si se deja activado el *Program flow*.
3. Ejecute el programa.
4. Haga clic sobre la representación del teclado en la interfaz del emulador.
5. Ingrese las teclas asignadas (asegúrese de utilizar mayúsculas, ej: `Shift + A`) para renderizar los glifos.
6. Presione la barra espaciadora para ejecutar la rutina de limpieza.