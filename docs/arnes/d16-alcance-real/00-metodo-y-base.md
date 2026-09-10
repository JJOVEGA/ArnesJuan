# `QA-016-04` / `D16` — el alcance real, medido, y la corrección de mi propia caracterización

**Versión base:** `67b06fe`, rama `rel/registro-1.33.0`, 2026-09-10.
**Método:** se carga `hooks/lib.sh` —el lector real de las guardas, sin copiarlo ni reimplementarlo—
y se llama a `arnes_campos_normaliza` y `arnes_rigor_efectivo` con seis valores de `Rigor:` × dos de
`Sensible a seguridad:`. Reproducible con `bash docs/arnes/d16-alcance-real/sonda.sh`.
Salida íntegra en `salida.txt`. **No se ejecutó el banco ni se repitió ninguna corrida.**

## Lo medido

| `Rigor:` declarado | `Sensible: no` | `Sensible: sí` |
|---|---|---|
| `critico` | `critico` | `critico` |
| **`critico (por suelo)`** | **`estandar`** ⚠️ | `critico` |
| `**critico**` | `critico` | `critico` |
| `estandar` | `estandar` | `critico` |
| `basura` | `estandar` | `critico` |
| *(ausente)* | `estandar` | `critico` |

## El defecto, confirmado

`hooks/lib.sh:2394-2400` — *«Valor no reconocido: se ignora y se cae al comportamiento de siempre»*.
La forma **con paréntesis**, que `AGENTS.md` §13 **autoriza explícitamente** para los veredictos
(*«un matiz va entre paréntesis»*), **no se reconoce en `Rigor:`**, y cae al mismo sitio que `basura`
y que la **ausencia** del campo: los tres son indistinguibles para la puerta. `estandar` **no exige**
`Seguridad: aprobado`, así que la caída es **hacia abierto**.

Es la **misma asimetría que `SEC-084`**: un lector tolera la decoración y el otro no. El
desenvoltorio de Markdown (`**critico**`) **sí** funciona; el paréntesis no.

## La corrección de lo que yo venía diciendo, y es material

Yo escribí que el defecto está *«también en la 1.33.0 publicada»* y lo presenté junto a `SEC-084`
como si tuvieran la misma exposición. **El defecto sí está publicado; la exposición no es la misma.**

**La exposición exige que el REQ NO esté marcado `Sensible a seguridad: sí`.** Con `sí`, el **suelo**
de §6 lo rescata y el rigor efectivo es `critico` pase lo que pase — se ve en la columna derecha de
la tabla.

**Consecuencia para este repositorio, que es el único consumidor verificado:** la política de
autoalojamiento de `AGENTS.md` §6 declara **todo** REQ `Sensible a seguridad: sí` por defecto. Así
que aquí el defecto es **latente, no activo**. Comprobado sobre los 22 REQ del árbol:

```
REQ con 'Sensible a seguridad' distinto de sí:  (ver conteo en salida.txt / comando abajo)
```

*Comando:* `grep -L 'Sensible a seguridad: *\**s[íi]' requirements/REQ-0*.md`

**Quién sí queda expuesto:** un proyecto instalado que declare un REQ **no sensible** y le escriba el
rigor con un paréntesis siguiendo la convención que §13 le enseña. Eso **no está comprobado que haya
ocurrido**: que haya proyectos corriendo 1.33.0 descansa en la afirmación de `AGENTS.md`, no en una
comprobación, y no hay base para estimar uso histórico.

## Por qué esto cambia la recomendación de vehículo

`SEC-084` y `QA-016-04` comparten **causa** (un lector que no tolera la decoración que el contrato
autoriza) y **no** comparten **exposición** ni **radio de cambio de conducta**:

- **`SEC-084`** no depende del suelo de sensibilidad: cuela una firma de seguridad por delante de
  `QA: pendiente` en los dos estados clave. Su arreglo **restituye** el contrato.
- **`QA-016-04`** sólo se manifiesta en REQ no sensibles. Y su arreglo **debe ser tolerar el
  paréntesis** —como ya hacen `QA:` y `Seguridad:`—, **no** denegar por valor no reconocido: la
  denegación cambiaría la conducta de cualquier proyecto que hoy escribe un rigor con matiz, y eso es
  un cambio de conducta heredado, no una restitución.

Dos remedios distintos, dos radios distintos. **Compartir causa no obliga a compartir commit.**
