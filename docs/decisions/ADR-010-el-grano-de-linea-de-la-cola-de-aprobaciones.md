# ADR-010 — El grano de línea de la cola de aprobaciones se mantiene, y el banco lo mide
Fecha: 2026-09-09
Estado: propuesta (gate humano pendiente: la rama que se descarta cambiaría un contrato en estado terminal)

> **El papel, que es lo estable.** Éste es el **«ADR del grano de la cola»** que `REQ-024`
> encarga. El número se estampó al crearlo, por el mismo motivo que `ADR-009`.

## Contexto

El arnés tiene **dos** nociones de comentario HTML y son **dos contratos distintos**:

- **La cabecera de un REQ** (`arnes_sin_cita`, `hooks/lib.sh`) tiene grano de **rango**:
  sustituye el `<!-- … -->` por un espacio y **sigue juzgando el resto de la línea**. La regla
  cruza líneas y su transcripción declarada es `hooks/campos-req.awk`.
- **La cola de aprobaciones** (`arnes_cola_pendientes`, `hooks/lib.sh`) tiene grano de
  **línea**: una línea que contenga el par **se descarta entera**. Lo documenta `REQ-009`
  (`CA-04`/`CA-07`) y es lo que decide **cuántas entradas bloquean el cierre**.

La frontera estaba escrita **a propósito** en el propio código, con su precio delante:
«un cambio de conteo en la cola es un cambio de veredicto en la puerta». Lo que faltaba era
**decidirla** y que la máquina la **midiera**, porque un comentario no es una prueba.

**La forma medida sobre la que los dos lectores deciden AL CONTRARIO**, y es una sola:

```
### [2026-09-05] (dev) — Real <!-- nota -->
```

La cabecera de un REQ retira el rango y le queda `### [2026-09-05] (dev) — Real`, que **cuenta**
como entrada bajo la regla de la cola. La cola **descarta la línea entera** y cuenta **0**.
Verificado ejecutando las dos funciones sobre esa misma cadena en esta comisión.

Y el forzador de que esto se decidiera ahora: `SEC-051` remediación 1 propone **unificar** las
dos nociones, y quien implementara el bloque B de `REQ-024` iba a estar editando esa misma
función con esa propuesta delante, sugiriéndole unificar «de paso». `REQ-023 CA-12` nombró esa
deriva como la más probable de su vecindad.

## Decisión

**Se MANTIENE la frontera de grano de línea. El conteo de la cola no cambia en 1.34.0.**

Y con ella, tres cosas concretas:

1. La declaración escrita de `hooks/lib.sh` **cita este ADR** y **nombra la forma medida**, en
   vez de dejar la frontera en una nota sin dueño.
2. **El banco MIDE la diferencia entre los dos lectores sobre esa misma forma**
   (`tests/escenarios/hooks/secciones/31-cola-una-sola-regla.sh`, caso `REQ-024 CA-10`): aplica
   `arnes_sin_cita` a la línea y comprueba que lo que queda **cuenta** bajo la regla de la cola,
   mientras `arnes_cola_pendientes` sobre la misma línea cuenta **0**. Si algún día se unifican,
   **falla una prueba** en vez de descubrirse en una auditoría — y obliga a pasar por un ADR
   nuevo y por el write-back de `REQ-009`.
3. Los dos **defectos** de la cola que `REQ-024` sí arregla (`CA-08`, el rango que abre y no
   cierra devolviendo `0` con `rc=0`; `CA-09`, el cierre huérfano que retiraba una entrada) se
   arreglan **sin tocar el grano**: se resuelven con el estado que el bucle de una sola pasada ya
   lleva. Verificado ejecutando: el ejemplo multilínea comentado de la plantilla sigue contando
   **0** (`REQ-009 CA-07`) y la anotación cerrada dentro de su línea sigue contando **0**.

## Alternativas consideradas

- **Cruzar la frontera: unificar la cola con el escáner de la cabecera** (remediación 1 de
  `SEC-051`). *Por qué sí:* retiraría una transcripción y sería la técnica conforme para el techo
  de coste de `REQ-024 CA-07 (iv)` —`arnes_sin_cita` está medido en **1,06** de cociente de
  duplicación por longitud de línea, frente a **2,63–3,65** de la forma que indexa carácter a
  carácter—. *Por qué no, y no es una preferencia:* cambia el **conteo** de la cola, o sea el
  **veredicto** de la puerta, o sea el contrato de `REQ-009 CA-04/CA-07`, que está en **estado
  terminal**. Eso obliga a devolver `REQ-009` a `en-progreso`, a un write-back del analista y a
  re-recorrer el ciclo — en un REQ propio, con su dueño y su ventana, **no dentro de la comisión
  que tenía el archivo abierto**. `REQ-024 CA-10` lo prohíbe expresamente para esta versión.
- **Dejarlo como estaba: la frontera en un comentario, sin ADR y sin prueba.** Es el estado que
  produjo el forzador. Un comentario no impide que la comisión siguiente unifique «de paso», y
  entonces el cambio de veredicto se descubre en una auditoría. Se descarta.
- **Arreglar `CA-08`/`CA-09` reutilizando `arnes_sin_cita` desde la cola.** Era la salida barata
  y **no era conforme**: `arnes_sin_cita` tiene grano de rango, así que usarlo cruza la frontera
  por la puerta de atrás. La salida elegida es la tercera que `REQ-024 CA-07` describe —conservar
  el grano de línea y no añadir ningún recorrido de rango—, y resultó ser también la más barata:
  el cociente de duplicación por longitud de línea del lector de la cola quedó medido en
  **1,98×** (mediana de 5 tomas, MAD 0,037, par 1000 → 2000 bytes), por debajo del techo de
  2,2× que `CA-07 (iv)` contrata.

## Consecuencias

- (+) La frontera deja de ser una nota y pasa a ser una **decisión con prueba**: una divergencia
  futura rompe el banco.
- (+) `REQ-009` **no se reabre** y su contrato terminal queda intacto.
- (+) Los dos defectos de la cola se cierran sin mover ni un conteo: `CA-05` de REQ-024 midió que
  los 31 REQ de un proyecto sin migrar reciben el **mismo** veredicto que en `v1.33.0`.
- (−) **La segunda transcripción sigue existiendo** (dos nociones de comentario en el mecanismo).
  No se maquilla: es el precio de conservar un contrato terminal, y `REQ-024 CA-11 (i)` sólo
  contrata que **no crezca** — medido: los consumidores tienen **0** transcripciones propias y en
  `hooks/lib.sh` siguen siendo exactamente **dos** funciones, nombradas por el banco.
- (−) **El cambio de conducta de la forma medida queda pendiente**, con dueño (`desarrollador`
  para el lector, `analista-requerimientos` para el write-back), ventana (**no antes de 1.35.0**,
  la que fije un ADR posterior) y clase `instrumento`. Está nombrado en «Fuera de alcance» de
  `REQ-024`.
