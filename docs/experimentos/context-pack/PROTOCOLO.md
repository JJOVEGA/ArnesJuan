# Experimento: ¿resuelve un agente un REQ leyendo menos proyecto?

**Hipótesis:** un pack derivado que diga *dónde mirar* reduce las lecturas perdidas y los
consumidores no leídos, sin sustituir la lectura del código.

**Lo que NO es:** una feature. Si no gana, se borra la rama.

## Línea base (A) — gratis, antes de tocar nada
Las transcripciones de los REQ ya completados existen. Por REQ, contar:
`Read`, `Grep`, `Glob`, tokens de entrada/salida, archivos leídos que **no** están en el diff
final (lecturas perdidas), y consumidores del diff que el agente **no** leyó (lo que QA
habría encontrado). Ése es el número que hoy nadie tiene.

**Primer día, antes que nada:** `git log --grep=REQ-` en el proyecto. Si los commits no
nombran su REQ, la arista `implementa` sale vacía y el pack se degrada. Hacia adelante se
impone con el `pre-commit` que ya existe; hacia atrás no hay nada que hacer.

## Tratamiento (B)
1. `tools/arnes-contexto.sh REQ-NNN . > .arnes/contexto/REQ-NNN.md` para 5 REQ **ya
   completados** que toquen módulos compartidos.
2. Una línea en la ficha del desarrollador: *si existe `.arnes/contexto/<REQ>.md`, léelo
   primero y expande sólo con evidencia; anota qué te faltó.*
3. Rejugar los 5 REQ desde su estado anterior hasta la primera modificación correcta.

## Medir (en las transcripciones, derivado)
tokens entrada/salida · Read/Grep/Glob/total · **lecturas perdidas** · **consumidores no
leídos** · tiempo a primera modificación correcta · tiempo total · regresiones en QA.

## Decisión
Si B no gana en **lecturas perdidas** y **consumidores no leídos**, se mata. Los tokens son
secundarios: el pack cuesta ~1 000 y sustituye Glob y el Grep inicial, no los Read.

## Qué NO se construye aunque gane
Motor de consultas · nodos `module` · aristas REQ→NFR/ADR (ya están en el REQ) ·
`depende_de` conceptual · parser propio · SQLite · avisos o puertas · elevación automática
de rigor · nada para el analista.
