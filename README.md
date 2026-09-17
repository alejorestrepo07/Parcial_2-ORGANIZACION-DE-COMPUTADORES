# Examen Parcial 2 - Organización de Computadores

**Institución:** EAFIT
**Autor:** Alejandro Restrepo Osorio
**Curso:** Organización de Computadores (S2666-0322)
**Docente:** Edison Valencia Díaz

---

## Descripción del Proyecto

Este repositorio contiene la solución técnica al segundo parcial práctico de la asignatura. El objetivo principal es demostrar el dominio sobre la arquitectura del computador Hack y su repertorio de instrucciones en lenguaje ensamblador (`.asm`), abordando dos problemas clásicos de bajo nivel: operaciones aritméticas complejas sin hardware dedicado y manipulación avanzada de Entrada/Salida (I/O) mapeada en memoria mediante un terminal de texto.

---

## 1. Módulo Matemático: `Sqrt.asm`

Este programa calcula la parte entera de la raíz cuadrada de un número entero positivo (N mayor o igual a cero).

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

## 2. Módulo de Gráficos e I/O Continua: `GlyphMatrix.asm`

Este programa gestiona la interacción en tiempo real con el usuario mediante un ciclo infinito de *Polling* (sondeo) sobre el teclado. Como requerimiento avanzado (Punto 3 extra), el sistema opera como un **Terminal de Texto Continuo**, dibujando patrones de 32x32 píxeles y gestionando dinámicamente un cursor de hardware.

### Teclas Asignadas

*   **Caracteres de dibujo:** `A` (Alejandro), `R` (Restrepo), y `O` (Osorio).
*   **Retroceso (Backspace):** `Espacio` (ASCII 32). Borra el último carácter ingresado y retrocede el cursor.
*   **Limpieza de Pantalla (Clear):** `C` (ASCII 67). Formatea el lienzo completo y reinicia el sistema.

### Arquitectura y Lógica de Hardware

1. **Sondeo Ininterrumpido y Anti-Rebote (Debounce):** El código interroga el registro `RAM[24576]`. Para evitar múltiples impresiones accidentales dada la alta velocidad de reloj del emulador, se implementó una estricta subrutina `WAIT_RELEASE` que pausa la ejecución gráfica hasta que el usuario libere físicamente la tecla.
2. **Cursor Dinámico y Salto de Línea (Wrap-around):** En lugar de escribir en coordenadas estáticas, se utiliza un puntero en memoria gráfica. La pantalla aloja una grilla estricta de 16x8 caracteres. Al alcanzar la columna 16, el sistema calcula matemáticamente un desplazamiento del puntero para ejecutar un salto de línea (retorno de carro) automático y fluido.
3. **Bloqueo por Pantalla Llena (Halt):** Un contador de control monitorea la ocupación del *framebuffer*. Al renderizar el carácter número 128 (renglón 8 completo), el sistema bloquea el ingreso de nuevos glifos para prevenir desbordamientos de memoria hacia el teclado u otros registros críticos.
4. **Retroceso Inteligente (Backspace):** El algoritmo de la barra espaciadora no solo limpia el bloque de 32x32 ceros, sino que recalcula el cursor a la inversa. Si el retroceso ocurre en el primer carácter de una línea, el algoritmo procesa un salto de línea en reversa hacia el renglón superior.
5. **Rutina de Limpieza (`CLEAR_MATRIX`):** Mediante la tecla `C`, el sistema inyecta ceros lógicos en los 8192 registros del bloque `SCREEN`, borrando cualquier glifo remanente, reseteando los contadores de filas y devolviendo el cursor a su estado inicial. 

### Cómo Probarlo
1. Cargue el archivo `GlyphMatrix.asm` en el **CPU Emulator**.
2. **Importante:** Configure la simulación ajustando `Animate` en **No Animation** y la barra de velocidad en **Fast**. 
3. Ejecute el programa e ingrese múltiples letras para ver el comportamiento continuo y los saltos de línea.
4. Presione espacio en distintos puntos para validar el retroceso dinámico del puntero.
5. Llene la pantalla por completo para verificar el bloqueo de memoria, y utilice la tecla `C` mayúscula para formatear el panel.