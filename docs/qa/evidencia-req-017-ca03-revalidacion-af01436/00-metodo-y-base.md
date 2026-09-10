# Evidencia — re-validación acotada de `REQ-017 CA-03` (promesa corregida de la MÁQUINA)

## Versión base y alcance

| | |
|---|---|
| **Commit medido** | `af0143600a85fc4a87389b2ae47586afd9c7a8a7` (`af01436`), rama `rel/registro-1.33.0` |
| **Árbol** | limpio en lo medido; el `git status` de la sesión trae cambios de **otras** comisiones (REQ-023, sección 39) que **no** entran en las rutas de este REQ |
| **Fecha** | 2026-09-10 |
| **Plataforma** | Linux 6.18.33.2-microsoft-standard-WSL2, `bash` 5.3.9, 8 núcleos, `linux-gnu-x86_64-bash5.3` |
| **Habilitante** | autorización EXPRESA del propietario del 2026-09-10, opción **(A)** de `D18` en `PENDING_APPROVAL.md`. Re-validación **fuera del contador** de `AGENTS.md` §6; las **tres vueltas siguen agotadas** y no se reescriben |
| **Alcance** | SÓLO la promesa corregida del párrafo de la cota de `CA-03` (write-back de `QA-017-31`). Ningún umbral, NFR, cota ni código se toca |

## Reutilización de evidencia y por qué no se re-midió

**Comprobación mecánica previa, condición de la reutilización:**

```
git diff f4a5f1f..af01436 -- hooks/ tools/ tests/ .github/ .arnes/ templates/ .claude-plugin/
```

sale **VACÍO**. Los tres commits del rango (`b55347e`, `67b06fe`, `af01436`) tocan sólo
`requirements/`, `docs/`, `CHANGELOG.md` y `PENDING_APPROVAL.md`. Por tanto **no** se re-midieron la
banda, el techo, los umbrales, el modo de medición ni las cinco corridas aisladas: siguen válidas las
de `docs/qa/evidencia-req-017-writeback-f4a5f1f/` (sobre `f4a5f1f`) y
`docs/qa/evidencia-req-017-modo-86a44c8/` (sobre `86a44c8`).

## Quality gates de `AGENTS.md` §7 — 3 de 3 en verde

| Gate | Comando | Resultado |
|---|---|---|
| Sintaxis del mecanismo | `for f in hooks/*.sh tools/*.sh; do bash -n "$f"; done` | **rc 0** |
| Registro de hooks | `jq -e . hooks/hooks.json` | **OK** |
| Versión y marketplace | `jq -e . .claude-plugin/plugin.json` + `marketplace.json` | **OK** |
| (extra) sintaxis de las 5 secciones `37-*` | `bash -n` | **OK** |

## Banco completo — `banco-completo.txt`

`ARNES_JOBS=6 bash tests/escenarios/hooks/run.sh` → **1057 PASS · 0 FAIL · 7 SKIP · rc 0**.

Cuadre idéntico al de la vuelta 3 (1057 PASS · 1 FAIL · 6 SKIP = 1064 casos): **1057 + 0 + 7 = 1064**.
El write-back no movió ningún veredicto.

**Sobre el `FAIL` de `REQ-023 CA-09 (iii)`: esta corrida lo dio como SKIP, y eso NO se usa para
justificar nada.** No se re-corrió el banco buscando verde (instrucción expresa del propietario). Se
anota como dato y nada más: confirma la no-determinación ya medida en la vuelta 3 (FAIL · SKIP · PASS ·
PASS sobre código idéntico) y su decisión sigue separada y en manos del propietario. **Una corrida en
verde no es evidencia de que el FAIL fuera falso.**

## P1 — la promesa PRESENTE: ¿emite plataforma y carga en TODAS las ramas de emisión?

**Método.** `razon37`, `banda37`, `mil37` y `num37` se extraen **literalmente por rango de línea** del
archivo real (`sed -n '34p;246p;268,278p;294,330p'` sobre
`tests/escenarios/hooks/secciones/37-coste-del-escaner-2-las-razones.sh`) → `fn-reales.sh`. **No hay
transcripción a mano**: una copia manual sería una segunda sede que se desfasa, que es el defecto que
este REQ mide en otros sitios (`QA-017-23`). Los dos `mue` son los **literales** de los llamadores de
`CA-03` (líneas 344 y 385), con el par ya resuelto. Guion: `p1-ramas.sh`; salida: `p1-salida-ramas.txt`.

**Resultado: 13 de 13 ramas de emisión emiten `plataforma=` y `carga=`, y 0 de 13 publican la cota.**
Cubiertas las 5 ramas de abstención de `razon37` (falta un término · bajo el suelo · banda sin el
máximo · dirección de banda no reconocida · techo dentro de la banda), PASS y FAIL en las dos
direcciones (`no-excede` y `excede`) y la vía sin banda.

**Corroborado sobre el banco REAL** (`banco-seccion-37-2.txt`): los dos casos de `CA-03` publican
`modo=intercalado k=20|1 series=3 · plataforma=linux-gnu-x86_64-bash5.3 carga=1.06` y **no** la cota.

## P2 — la CONDICIÓN DE VERDAD del par, rama por rama

**Método.** `mide37i` se extrae literal (`sed -n '209,240p'`), y `sonda_lee`/`sonda_num` del corredor
real (`sed -n '417p;432,482p' tests/escenarios/hooks/run.sh`). Se reproduce el flujo de los dos
llamadores. Guion: `p2-condicion-verdad.sh`; salida: `p2-salida-condicion-verdad.txt`.

| Rama de `CA-03` | Lo que el REQ afirma | Lo medido | ¿Fiel? |
|---|---|---|---|
| **Habiendo medido** | «el par **es** el de esa medición» | dos `mide37i` sobre el mismo árbol con carga forzada en medio publican pares **distintos**, en **dos corridas independientes**: `carga=0.77`→`3.48` (loadavg 0.77→4.32) y `carga=0.55`→`3.28` (loadavg 0.59→3.28; ésta es la guardada). **El par cambia con la medición**: no se hereda | **sí** |
| **Sin línea base** | «el par emitido es el de la medición **directa** de la misma corrida» | con `HER37_OK=no`, `mide37i` **no se llama** y el fail-before publica `carga=4.32`, **idéntica a la de la directa**, sin haber medido nada | **sí** (es `QA-017-27`, **abierto**; el REQ lo **describe**, no lo cierra) |
| **Fallo antes de leer el registro** | «el par sale `plataforma=n/a carga=n/a`» | `mide37i /no/existe/lib.sh` → `rc 1`, `MED37_PLAT` vacío, mensaje `plataforma=n/a carga=n/a` | **sí** |
| **Suelo de 50 ms** | «lo que el par vale **no está medido**, y por eso **no se afirma** nada» | rama **alcanzable** y confirmada (con `k=1`: A=9000/8457 µs, B=4203/4220 µs en las dos corridas, ambos bajo 50000). **Lo medido aquí, por primera vez:** el par **sí** es el de esa medición (`mide37i` devuelve 0 con `estado=suelo` tras refijar el par) | **sí, y no afirma nada de más** — la abstención del REQ es la dirección conservadora |

**Limitación de este arnés, declarada.** El extracto de `sonda_lee` invoca `sonda_es_util`, que queda
fuera del rango extraído (`command not found`, rc 127). Su efecto es que el `if` que valida el campo
`vivos` **no se ejercita**: mi extracto es **más permisivo** que el real en un campo que **no toca**
`plataforma` ni `carga`, y `sonda_lee` retorna 0 igual. El resultado observable coincide con el del
banco real, que sí tiene esa función. **No invalida la medición**; se declara para que nadie la
reproduzca creyendo que corrió el lector entero.

## Hallazgo — la promesa vieja sobrevive en TRES sedes más, una de ellas DENTRO de `CA-03`

Lo decisivo no es la frase corregida, sino la promesa **completa** (instrucción (3) del encargo).

**SEDE A — `requirements/REQ-017.md:62`, § «Qué se publica junto al cociente», del PROPIO `CA-03`:**

> «…y la **plataforma** y la **carga** que la propia sonda publica en cada invocación (**esta última
> mitad es la exigencia (ii) de la remediación de `SEC-064` citada abajo**…)»

introducida por «Ejemplos **no exhaustivos**, **ya construidos** o exigidos aquí».

**SEDE B — `requirements/REQ-017.md:74`, párrafo NUEVO del MISMO `CA-03`:**

> «**No** aporta que la abstención publique **de qué máquina** es **su** medición: eso es una
> **exigencia declarada**, **no una propiedad ya presente**…»

**Por qué es contradicción objetiva y no cuestión de lectura, tres razones independientes:**

1. **El puntero interno apunta al párrafo que lo desmiente.** La sede A dice «citada **abajo**»; el
   párrafo de abajo es exactamente el que ahora niega que eso esté aportado.
2. **La sede A la lista entre lo «ya construido»** e identifica esa mitad con «la **remediación**»
   (presente); la sede B dice literalmente «**no una propiedad ya presente**».
3. **La medición le da la razón a la sede B**, no a la A: en la rama «sin línea base» el par es el de
   **otra** medición (P2), así que la mitad (ii) de `SEC-064` **no** está remediada.

**SEDE C — `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-las-razones.sh:169-171`** (comentario):

> «`MED37_PLAT` y `MED37_CARGA` salen del MISMO registro y **son la mitad (ii) de la remediación de
> SEC-064**»

**SEDE D — `docs/arnes/req-017-ca-03-modo-de-medicion/03-criterio-del-intercalado-declarado-antes-de-medir.md:83-85`:**

> «la **plataforma** y la **carga** que publica la sonda —esta última **es la exigencia (ii) de la
> remediación de `SEC-064`**…»

**Es la misma forma por tercera vez, con la sede cambiada.** `QA-017-24` se corrigió y reapareció como
`QA-017-31` con el objeto cambiado; `QA-017-31` se corrigió en **un** párrafo y sobrevive en **otro
párrafo del mismo criterio**. Aplica el refinamiento del propietario en `D5` por analogía directa:
*corregir un párrafo no basta si otro del mismo criterio sostiene la promesa retirada.*

## Lo que SÍ quedó acreditado (mitad (a) de `QA-017-31`)

La promesa **dejó de ser absoluta** y su condición de verdad es **verdadera en las cuatro ramas**,
medido por ejecución (P1 y P2). Esa mitad del hallazgo está resuelta. Lo que **no** lo está es la
mitad (b): que `CA-03` **declare cumplida** una mitad de `SEC-064` que `CA-08 (ii)` declara abierta.

## Coherencia `CA-03` ↔ `CA-08 (ii)` — la contradicción que abrió el hallazgo

Sobre la **mitad pendiente** de `SEC-064`, el párrafo **nuevo** de `CA-03` (`:74`) y `CA-08 (ii)`
(`:140`) dicen ahora **lo mismo**: las **dos** mitades siguen **abiertas**, con dueño `desarrollador` y
el vencimiento de `SEC-064`; las dos cierran **la instancia** y no **la clase**; y las dos declaran la
misma frontera («no invalida el veredicto de una corrida: limita la **agregación**»), que es **honesta**
—el veredicto lo decide la banda, no el par, y la cota se comprueba sobre corridas **consecutivas**—.
La contradicción persiste **sólo** contra la sede A, que es del mismo `CA-03`.

## Formas prohibidas de `requirements/README.md` — el texto nuevo no cae en ninguna

| Forma | Comprobación |
|---|---|
| **enumeración** sin marca ni puntero | los cuatro casos van como «Ejemplos **no exhaustivos**» + puntero al sitio único (el caso de la sección) y a `CA-06` para los motivos. **Conforme** |
| **número** sin declarar operativo/de contrato | ningún número nuevo; la cota sigue «no más de 2 … (**operativo**: se **baja**)». **Conforme** |
| **igualdad** donde corresponde techo | la cota es techo, nunca igualdad. **Conforme** |

**Ni umbral ni garantía nuevos:** la condición de verdad **debilita** una promesa sobre el instrumento;
no añade NFR ni cota. Cumple la prohibición del propietario para esta ventana.

## Fuera de alcance, y no se tocó

No se firmó `Seguridad:`; no se cerró `SEC-064` ni `QA-017-27`; no se reclasificó `QA-017-31`; no se
tocó código, umbral, NFR ni cota; no se marcó `completado` (la cola tiene pendientes); `REQ-017` sigue
`bloqueado` y su desbloqueo es de la coordinadora.
