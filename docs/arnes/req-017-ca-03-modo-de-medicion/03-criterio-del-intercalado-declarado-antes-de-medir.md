# Criterio del MODO INTERCALADO de CA-03, declarado ANTES de tomar ninguna medida
Declarado 2026-09-09 por el `desarrollador`, sobre `rel/registro-1.33.0` @ `3e49b98`, antes
de escribir una línea de código y antes de la primera medición. Continúa
`00-criterio-k-declarado-antes-de-medir.md` (misma ventana, otro comisionado): esa evidencia
**se reutiliza y no se re-deriva**.

## Qué se implementa (y qué NO se mueve, escrito antes para no poder moverlo después)
`CA-03` (write-back del 2026-09-09) contrata el **modo** de medición: las dos series
—`S` y `2S`— **intercaladas a, b, a, b, … dentro de la MISMA invocación de la sonda**, en
**las dos** mediciones del criterio (la directa y el fail-before contra `v1.32.1`).

**La única variable que se mueve es el MODO.** Quedan fijos, y su valor de hoy es el que
tienen que seguir teniendo mañana:

| parámetro | valor de hoy | quién lo fija |
|---|---|---|
| techo del cociente | 2 600 ‰ (2,600×) | CA-03, `operativo`, dirección **bajar** |
| suelo por serie | 50 000 µs | `requirements/README.md`, vía `sonda-reloj.sh` |
| estadístico | **mínimo** de las series | CA-03 / `REQ-021 CA-02` |
| par de tamaños | S = 70 000 y 2S = 140 000 B | CA-03 |
| `k` medición directa | 20 | el **suelo** (con k=10 la serie corta se queda en ~49 ms) |
| `k` fail-before | 1 | el **suelo** (el árbol cuadrático lo cruza de sobra) |
| `r` (series) | **3** | se queda como está: cambiarlo movería un segundo parámetro |

`r` no se toca **a propósito**, y va declarado antes de medir porque es la tentación
obvia: la evidencia de `01-evidencia.md` muestra que subir `k` o `r` **empeora** la
dispersión en bloque, y que el remedio medido es el **modo**. Si el modo no alcanza, la
salida que CA-03 contrata es la **abstención con cifras**, no un segundo parámetro.

## Regla de emisión que se implementa (la banda), y su propiedad de seguridad
Con el **mínimo y el máximo** de cada término la corrida acota la banda de cocientes
compatible con lo medido: **`lo = mín(2S)/máx(S)`** … **`hi = máx(2S)/mín(S)`**.

- **PASS** sólo si **toda** la banda cae del lado conforme de la dirección de esa medición.
- **FAIL** sólo si **toda** cae del lado no conforme.
- Si el techo cae **dentro** de la banda → **SKIP** citando **banda, cociente y techo**.

Direcciones (una por medición, y por eso el juez es **uno** con la dirección como dato):
la **directa** es conforme cuando el cociente **no pasa** del techo (PASS ⟺ `hi ≤ techo`);
el **fail-before** es conforme cuando **sí** lo pasa (PASS ⟺ `lo > techo`).

**Propiedad de seguridad que se declara ANTES y se prueba con un par discriminante:** la
guarda sólo puede **estrechar**. Como `lo ≤ coc ≤ hi` por construcción, un PASS con guarda
implica el mismo veredicto sin guarda en las dos direcciones, así que la guarda **no puede
convertir un FAIL en PASS**. Se exige **ejecutarlo** —no argumentarlo—: este REQ lleva tres
afirmaciones de esa clase que resultaron falsas al ejecutarlas.

## Cómo se compara bloque contra intercalado (declarado antes de la primera medida)
1. **Round-robin intercalado** de las dos configuraciones dentro de la misma ronda —nunca
   una tanda de bloque y después una de intercalado—, `N = 5` rondas por configuración.
2. **`loadavg` publicado fila a fila**, el que emite la propia sonda en cada invocación.
   Una cifra de reloj sin su carga no es atribuible (lección de `01-evidencia.md`).
3. Estadístico de comparación: **mediana y MAD**, **nunca el rango** — el rango es monótono
   no decreciente en el número de muestras, así que compararlo entre configuraciones premia
   a la que menos veces se midió.
4. Magnitudes que se comparan, las dos: **(a)** la **anchura de banda** `hi/lo` de cada
   invocación, que es la que **decide** PASS o abstención; **(b)** la dispersión
   **entre rondas** del cociente.

## Umbral de la afirmación «el intercalado estrecha», fijado antes de verlo
Se afirma **sólo** si `mediana(hi/lo)` del intercalado es menor que la del bloque **y** la
diferencia de medianas supera **MAD(bloque) + MAD(intercalado)**. Si no, se publica
**«no discriminado»** con las cuatro cifras. No hay tercera lectura.

## Lo que NO se hace, declarado antes para que no se pueda hacer después
1. **No se repite hasta obtener verde.** Las `N = 5` rondas de después de implementar son
   el resultado, diga lo que diga. Si la banda contiene al techo, eso **es** la abstención
   que CA-03 ordena y se publica con sus cifras y su cota (no más de 2 consecutivas).
2. **No se sube el techo, no se baja el suelo, no se cambia el estadístico, no se toca `k`.**
3. **Ningún caso se hace opt-in** (el propietario lo rechazó expresamente para CA-03 el
   2026-09-09) y **no se retira ninguna prueba**: `CASOS_ESPERADOS_SECCION` sólo puede
   **crecer** en esta comisión.
4. **`CA-04` no se toca**: sus cuatro razones siguen midiéndose en bloque, con la misma `k`,
   el mismo techo y **el mismo veredicto**. Lo único que cambia en ellas es que su mensaje
   publica también el **máximo** de cada término, que es evidencia y no juez.
5. **No se toca `hooks/`, `tools/`, `.arnes/`, la sonda, `AGENTS.md` ni ninguna plantilla.**
   La sede del modo intercalado ya existe (`sr_intercala`, `tests/util/sonda-reloj.sh:399`)
   y **se usa**, no se reescribe.

## Lo que se publica en la línea del veredicto, en TODAS las ramas
`modo` (bloque | intercalado), `k`, series, el **mínimo y el máximo** de cada término, la
**banda**, el cociente, el techo, y la **plataforma** y la **carga** que publica la sonda
—esta última es la exigencia (ii) de la remediación de `SEC-064`: una abstención que no
dice **de qué máquina** es no se puede sumar con otra—.
