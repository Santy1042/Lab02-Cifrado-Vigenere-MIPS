# Laboratorio 2 - Programación en ensamblador MIPS
## Fase 1. Comprensión del problema y requisitos

**Curso:** Arquitectura de Computadores y Laboratorio  
**Periodo:** 2026-2  
**Entrega indicada en el enunciado:** 18 de octubre de 2026, 23:59

> **Propósito de este cuaderno:** servir como material de estudio y registro de las decisiones del equipo. Antes de usar estas notas en el informe, revisen que reflejen fielmente las decisiones que realmente tome el equipo y agreguen sus propias observaciones y resultados. El enunciado indica que la solución debe ser original y no generada, ni siquiera parcialmente, por aplicaciones basadas en modelos de lenguaje. Por eso, este cuaderno organiza los requisitos y conceptos, pero no contiene una implementación de la solución.

---

## 1. Objetivo de la fase

Este cuaderno organiza la comprensión del Laboratorio No. 2 de Arquitectura de Computadores y Laboratorio. En esta primera fase todavía no se implementa el programa: se aclara qué problema debe resolver, cuáles son los requisitos explícitos y qué decisiones de diseño deberá tomar el equipo.

Al terminar esta fase, deberíamos poder explicar con nuestras propias palabras:

- Qué problema resuelve el cifrado de Vigenère.
- Qué debe recibir y producir cada opción del programa.
- Qué requisitos son obligatorios y cuáles son decisiones que el equipo debe justificar.
- Qué conocimientos de MIPS necesitaremos estudiar en las siguientes fases.

## 2. ¿Qué solicita el laboratorio?

El equipo debe diseñar, programar, ensamblar, simular y verificar un programa en MIPS de 32 bits que cifre y descifre mensajes usando Vigenère en el simulador MARS. El programa debe permitir elegir entre cifrar y descifrar, pedir la clave durante la ejecución y usar los archivos definidos por el enunciado.

### Flujo general solicitado

1. Iniciar el programa y mostrar el menú.
2. Si se elige **cifrar**, leer `input.txt`, solicitar la clave, transformar el mensaje y escribir el resultado en `criptogram.txt`.
3. Si se elige **descifrar**, leer `criptogram.txt`, solicitar la clave, recuperar el mensaje y escribirlo en `deciphered.txt`.
4. Definir cómo responderá el programa al terminar una operación o si ocurre un error. El tratamiento específico de errores no está establecido en el enunciado.

## 3. Concepto de Vigenère

Vigenère es un cifrado por sustitución polialfabético: una palabra clave determina el desplazamiento usado para transformar cada letra del mensaje. Para el ejemplo del enunciado se usa el alfabeto inglés de 26 letras, numerado desde 0 hasta 25: a=0, b=1, ..., z=25. La clave se repite hasta cubrir la longitud del mensaje.

### Fórmulas indicadas en el enunciado

- **Cifrado:** \(P_i = (M_i + D_i) \bmod 26\)
- **Descifrado:** \(M_i = (P_i - D_i) \bmod 26\)

Donde:

- \(M_i\): posición de la letra del mensaje original.
- \(P_i\): posición de la letra cifrada (criptograma).
- \(D_i\): desplazamiento correspondiente a la letra de la clave.
- \(i\): posición que se está procesando.
- \(26\): cantidad de letras del alfabeto usado en el ejemplo.

El módulo permite que las posiciones permanezcan dentro del intervalo de 0 a 25. En el descifrado, la resta puede ser negativa antes de aplicar el módulo; cómo normalizarla en MIPS se estudiará en una fase posterior.

### Ejemplo del documento del profesor

El mensaje `smartphone` y la clave `cipher` producen el criptograma `uupyxgjwcl`. La clave se repite para cubrir las diez letras del mensaje.

| Elemento | Valores, de la posición 0 a la 9 |
|---|---|
| Mensaje | `s m a r t p h o n e` |
| Posiciones del mensaje | `18 12 0 17 19 15 7 14 13 4` |
| Clave repetida | `c i p h e r c i p h` |
| Desplazamientos | `2 8 15 7 4 17 2 8 15 7` |
| Resultado numérico | `20 20 15 24 23 6 9 22 2 11` |
| Criptograma | `u u p y x g j w c l` |

### Idea clave

El descifrado debe usar la misma clave y revertir el desplazamiento del cifrado. Una prueba importante, cuando el equipo implemente su propio programa, será cifrar un mensaje y luego descifrar el resultado para comprobar que se recupera el texto inicial bajo la política de caracteres acordada.

## 4. Requisitos explícitos

| Tema | Requisito del enunciado |
|---|---|
| **Entorno** | Ensamblador MIPS de 32 bits, ejecutado y probado con MARS. |
| **Menú** | Al iniciar, ofrecer como mínimo las opciones «Cifrar un mensaje» y «Descifrar un criptograma». |
| **Entrada al cifrar** | Leer el mensaje original desde input.txt; el archivo contiene exclusivamente texto en inglés y tiene un tamaño máximo de 2048 bytes. |
| **Clave** | Solicitar la palabra clave al usuario durante la ejecución. |
| **Cifrado** | Cifrar todos los caracteres del mensaje. El enunciado no define cómo extender la fórmula del alfabeto de 26 letras a otros caracteres; la política aplicada debe ser consistente y justificarse. |
| **Salida del cifrado** | Escribir el resultado en criptogram.txt. |
| **Entrada al descifrar** | Leer el criptograma desde criptogram.txt. |
| **Salida del descifrado** | Escribir el mensaje recuperado en deciphered.txt. |
| **Estructura** | Organizar la solución mediante procedimientos para facilitar la comprensión y reutilización. |
| **Convención MIPS** | Respetar la convención de uso de registros y documentar los bloques de código, incluyendo el papel de los registros. |
| **Evaluación del diseño** | Justificar las decisiones de diseño. También se consideran la interacción con el usuario y el número de instrucciones ejecutadas. |

## 5. Requisitos de entrega y evaluación

- **Informe:** PDF con la descripción del diseño e implementación, pseudocódigo, diagrama u otra representación ilustrativa, procedimientos y su funcionalidad, entradas y salidas, decisiones justificadas, resultados, observaciones y conclusiones. Se deben adjuntar el código fuente MIPS y los anexos pertinentes.
- **Peso del informe:** 30 % de la calificación global.
- **Sustentación:** 70 % de la calificación global e incluye verificar que la solución funcione. Ambos integrantes deben demostrar dominio del algoritmo, MIPS, registros, direccionamiento, pila, procedimientos, `syscall` y MARS.
- **Equipos con identificador par:** video de máximo 8 minutos, con participación equitativa de ambos integrantes; el informe debe incluir el enlace.
- **Equipos con identificador impar:** sustentación síncrona ante profesor o monitor durante la semana posterior a la entrega, en horario y medio por acordar.

## 6. Decisiones que debemos resolver

El enunciado pide cifrar «todos los caracteres», pero los ejemplos y fórmulas describen el alfabeto inglés de 26 letras. No debemos asumir silenciosamente cómo aplicar el algoritmo a espacios, signos de puntuación, números, mayúsculas o saltos de línea. El equipo debe elegir una política, verificar que sea coherente en cifrado y descifrado y justificarla en el informe.

| Pregunta de diseño | Por qué importa | Decisión del equipo / notas |
|---|---|---|
| Caracteres | Afecta qué valores puede transformar la fórmula de módulo 26. | _Pendiente_ |
| Avance de la clave | Define qué carácter de la clave se aplica a la siguiente letra del mensaje. | _Pendiente_ |
| Formato de entrada | Afecta la fidelidad del texto recuperado y el procesamiento del búfer. | _Pendiente_ |
| Validación de la clave | Evita operaciones indefinidas o desplazamientos inesperados. | _Pendiente_ |
| Errores de archivo | Permite distinguir fallos de entrada/salida de una ejecución correcta. | _Pendiente_ |
| Interacción | Define la experiencia de uso y el flujo de control del programa. | _Pendiente_ |

### Registro de decisiones acordadas

Completar cuando el equipo haya discutido las preguntas anteriores. Evitar registrar como definitiva una decisión que todavía no se haya probado.

- Política para letras mayúsculas: **Pendiente**
- Política para espacios y puntuación: **Pendiente**
- Regla para avanzar la clave: **Pendiente**
- Validación de la clave: **Pendiente**
- Manejo de errores de archivo: **Pendiente**
- Comportamiento del menú: **Pendiente**

## 7. Archivos guía recibidos

Los ejemplos entregados por el usuario servirán principalmente en las fases técnicas posteriores:

- `demo1.asm`: declaración de datos, direcciones de memoria e instrucciones para almacenar/leer bytes y palabras.
- `demo2.asm`: apertura y lectura de un archivo, uso de un búfer de 2048 bytes y cierre del archivo.
- `demo3.asm`: lectura, seguimiento de la cantidad de bytes leídos, escritura a un archivo y cierre de archivos.

Estos ejemplos no implementan Vigenère; sirven como referencias puntuales para estudiar memoria y entrada/salida en MARS.

## 8. Lista de verificación de la fase 1

- [ ] Podemos explicar con nuestras palabras qué es Vigenère.
- [ ] Entendemos el significado de cada variable de las fórmulas.
- [ ] Podemos reproducir y explicar el ejemplo `smartphone` + `cipher` = `uupyxgjwcl`.
- [ ] Identificamos los nombres y funciones de los archivos de entrada y salida.
- [ ] Revisamos todos los requisitos explícitos del enunciado.
- [ ] Anotamos las decisiones abiertas que el enunciado no especifica.
- [ ] Acordamos qué debemos preguntarle al profesor, si alguna ambigüedad persiste.

## 9. Fuente de esta fase

**Fuente principal:** Universidad de Antioquia, Departamento de Ingeniería de Sistemas, *Arquitectura de Computadores y Laboratorio - 2026-2, Laboratorio No. 2: Programación en ensamblador MIPS*, pp. 1-5. En particular: descripción y fórmulas (pp. 1-3), condiciones de implementación y originalidad (pp. 3-4), informe y sustentación (pp. 4-5).

**Nota de trabajo:** esta sección resume el enunciado. Las decisiones concretas del equipo, el pseudocódigo definitivo, la implementación, los resultados de prueba y las conclusiones deberán reflejar el trabajo real realizado por ustedes.

---

### Para comenzar la fase 2

Cuando estén listos, pasarán a diseñar en equipo el pseudocódigo y el flujo del programa sin traducirlos todavía a instrucciones MIPS. Antes de cerrar la fase 1, conviene resolver especialmente la política para caracteres que no sean letras minúsculas, porque el enunciado exige cifrar todos los caracteres, pero no define cómo extender las fórmulas a ellos.
