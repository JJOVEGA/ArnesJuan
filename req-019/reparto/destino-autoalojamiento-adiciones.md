

<!-- Propuesta REQ-019 vía A: bloques que llegarían VERBATIM a este archivo, por sección de destino -->

### (añadido a §«Las dos copias»)

**Este repositorio se desarrolla a sí mismo (autoalojamiento controlado).** La versión estable instalada del plugin —la que corre los hooks de esta sesión— gobierna el desarrollo de la siguiente. La versión que se está modificando nunca es su propio guardián durante esa misma ejecución. El procedimiento completo vive en `docs/gobernanza/autoalojamiento.md`.

### (añadido a §«Política de rigor»)

> **Cómo se aplica, y por qué así:** con el parámetro `model` de la herramienta `Agent` al despachar
> el subagente, que tiene precedencia sobre el frontmatter. **No** se edita `agents/qa-tester.md` del
> plugin: ese archivo lo heredan todos los proyectos que instalan el arnés, y esta decisión es de
> este repositorio, no suya. Misma frontera que el resto de la política de autoalojamiento.

### (añadido a §«Lo que enseñó el ciclo 2»)

Medido: el ciclo 2 corrió casi entero en serie —tiempo de reloj ≈ tiempo
de agente— no porque una regla lo prohibiera, sino porque nadie podía afirmar sin adivinar qué dos
comisiones no iban a pisarse; y adivinar bien tres veces y mal la cuarta cuesta más que la serie.
