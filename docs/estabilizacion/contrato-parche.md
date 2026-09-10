# Candidato de estabilización sobre v1.33.0

Estado: candidato validado localmente; no es una versión publicada ni un cierre de hallazgos.

Base de código: `810128abd5d5b1ca9a240bde98192a9a0c51447c` (tag v1.33.0).
Traspaso consultado: `1dfe31bcb71dcf914f2124f40536bcde2d4019a3`.
Autorización: el propietario pidió tomar el relevo el 2026-09-10, tras detener
Claude, para preparar cambios y pruebas en una copia aislada. No incluye publicar.

## Alcance verificable

1. **D16 / QA-016-04:** un nivel de rigor válido con evidencia parentética final
   conserva el mismo nivel que sin esa evidencia. Se usa la normalización común.
   `critico (por suelo)` en un REQ no sensible no cae a `estandar`.
   Ausencia y valores realmente desconocidos conservan la derivación de v1.33.0;
   endurecer esa política queda fuera de este candidato.
2. **SEC-084:** al cambiar el valor efectivo de Seguridad a aprobado, la guarda
   aplica el control de orden existente también si la clave tiene decoración
   aceptada por el lector o si Edit sustituye sólo el valor. QA pendiente o
   con-hallazgos deniega; QA aprobado permite. No se añade una lista alternativa
   de claves al disparador.
3. **Ediciones legítimas:** mencionar campos en el cuerpo o editar texto ajeno
   a la firma no se trata como una nueva firma sólo porque exista una aprobación
   antigua en la cabecera. Seguridad preventiva conserva su conducta.
4. **Vías:** ejercer Write, Edit y MultiEdit contra el hook real, con archivos y
   sustituciones válidas. Los controles comprueban decisión y diagnóstico.
5. **Discriminación:** las regresiones del parche fallan en la base y pasan en
   la candidata. El banco existente y su autoprueba se conservan; no se cambian
   techos de rendimiento ni se repite hasta conseguir verde.

## Límite de seguridad y compatibilidad

Este candidato no garantiza frescura de la firma respecto del commit, no resuelve
homóglifos ni la ausencia de QA (SEC-083), y no modifica rotación, manifiesto,
workflow, estados de los REQ existentes ni sus aprobaciones. Una firma ya presente
no se revalida por una edición de prosa. La comprobación de ausencia heredada no
se presenta como protección nueva.

Las referencias D16/SEC-084 proceden del traspaso y del registro de seguridad de
[1dfe31b](https://github.com/JJOVEGA/ArnesJuan/tree/1dfe31bcb71dcf914f2124f40536bcde2d4019a3).
No se copian datos ni informes de proyectos consumidores.

## Entrega

Diff aplicable sobre la base, pruebas reproducibles y revisión independiente.
Las revisiones realizadas aquí no se presentan como firmas de QA Opus del
pipeline de Claude. No se cambia el número de versión ni se marca ningún REQ
completado. La aprobación de publicación y el portado a 1.34.0 quedan pendientes.

## Resultado local — 2026-09-10

La nueva sección de regresión da 17 PASS en la candidata; sobre la base del tag
da 6 PASS y 11 FAIL. Las secciones relacionadas dan 39 PASS. `bash -n`, los JSON
del plugin y `git diff --check` pasan.

El banco completo de la candidata terminó en 889 PASS, 3 FAIL y 9 SKIP. Los tres
FAIL tienen el mismo identificador que los observados contra la base en esta
máquina: CA-04 de recorte y los dos casos de descendencia de REQ-021 CA-04.1.
El banco no está verde, por lo que este resultado no autoriza una publicación.
