# Reconciliación de `docs/seguridad/registro-seguridad.md` entre las dos líneas — evidencia de `SEC-090`

> Artefacto de evidencia de la revisión **`R-032`** (2026-09-11), `auditor-seguridad`.
> Autorización expresa del propietario (2026-09-11) para reconciliar este archivo.
> **Alcance de escritura de la comisión:** únicamente `docs/seguridad/registro-seguridad.md` y
> artefactos nuevos bajo `docs/seguridad/`. No se tocó `hooks/`, `tools/`, `.github/`,
> `.arnes/config.json`, `.claude-plugin/`, `tests/`, `requirements/` ni `templates/`.
> Corrobora y extiende la medición previa de `docs/arnes/sec-090-destino-real/00-medicion.md`.

## 1. Versión base — las tres cabezas sobre las que se midió

| Copia | Ref | Commit |
|---|---|---|
| Línea publicada | `origin/main` | `10eac802d2987d2b718c3a48295dd116dfec60a7` |
| Destino real de `#48` | `origin/rel/registro-1.33.0` | `1dfe31bcb71dcf914f2124f40536bcde2d4019a3` |
| Rama de `#48` (espina) | `origin/feat/1.34-reparaciones-astra` | `3c52d6d74a82e0a11831cf0e3c8f38583aa36749` |

`git merge-base origin/rel/registro-1.33.0 origin/feat/1.34-reparaciones-astra` → **`1dfe31b`**,
que **es** la cabeza del destino: `#48` es *fast-forward*, `mergeStateStatus: CLEAN`. El árbol
resultante de la fusión **es** el árbol de la rama; la verificación de §5 no es una predicción.

## 2. Método — comandos exactos, suficientes para re-derivar sin preguntar

```sh
# extracción de las tres copias
for r in main rel/registro-1.33.0 feat/1.34-reparaciones-astra; do
  git show "origin/$r:docs/seguridad/registro-seguridad.md" > "$(basename "$r").md"
done

# DEFINICIÓN = identificador en línea de encabezado. Una mención dentro del bloque de
# otro hallazgo NO define; contar con grep plano sobre todo el archivo da un falso.
grep -nE '^#{1,6} ' X.md | grep -oE '\b(R|SEC)-[0-9]{3}\b' | sort -u   # definiciones
grep -oE '\b(R|SEC)-[0-9]{3}\b' X.md | sort -u                         # menciones

# BLOQUE de un identificador: desde su encabezado hasta el siguiente de nivel IGUAL O MENOR
awk -v s="$LINEA" 'NR==s{match($0,/^#+/);lvl=RLENGTH;inb=1;print;next}
  inb && /^#{1,6} /{match($0,/^#+/); if(RLENGTH<=lvl) exit} inb{print}' X.md

# FILAS DEL ÍNDICE (la sección cambió de sede entre las dos líneas, ver §4/R-016)
awk '/^### 2\. Índice/{s=1} s&&/^### 3\./{exit} s' main.md   | grep -oE '^\| `[A-Z]+-[0-9-]+`'
awk '/^## Índice/{s=1}   s&&/^## Revisión R-001/{exit} s' rama.md | grep -oE '^\| `[A-Z]+-[0-9-]+`'

# COMPROBACIÓN POR CONJUNTOS (no por lista)
cat main.defs dest.defs rama.defs | sort -u > union.defs
comm -23 union.defs final.defs      # perdidos: debe salir vacío
```

## 3. Conteos medidos

| Medida | `main` | destino | rama | resultado |
|---|---|---|---|---|
| Definiciones | 86 | 113 | 116 | **120** (119 de la unión + `R-032`) |
| Menciones | 96 | 116 | 124 | 125 |
| Filas del índice | 37 | 49 | 49 | **52** |
| Líneas | 6 210 | 8 583 | 8 808 | 9 428 |

**Diferencias de conjunto que decidieron la operación:**

- `destino \ rama` (definiciones) = **∅** → la rama ya era superconjunto de su destino.
- `main \ rama` (definiciones) = **`R-029`, `R-030`, `SEC-088`** → lo único realmente en riesgo.
- `destino \ main` (definiciones) = **31 identificadores** → **`main` NO es superconjunto**, luego
  «tomar `main` como espina», como decía la remediación literal de `SEC-090`, habría perdido 31
  identificadores para salvar 3. **La espina correcta es la rama.**

## 4. Inventario elemento por elemento

### 4.1 Trasplantado desde `main` — 2 bloques, verbatim

| # | Bloque | Origen (`main`) | Líneas | Definiciones que aporta | Colocación |
|---|---|---|---|---|---|
| 1 | `## Revisión R-029 — parche v1.33.2 (QA-P48-01), hotfix/1.33.2-rigor @ 17ec674` | `:5783-6032` | 250 | `R-029`, **`SEC-087`** (§2, sede), **`SEC-088`** (§3, sede) | tras `R-028`, antes de `R-030` |
| 2 | `## Revisión R-030 — re-firma del parche v1.33.2 tras la corrección de SEC-087 @ d82d6cd` | `:6033-6210` | 178 | `R-030` | tras `R-029`, antes de `R-031` |

`SEC-087` y `SEC-088` **no tienen bloque propio de nivel `##`**: son subsecciones `###` dentro de
`R-029`. Trasplantar `R-029` es lo que los trae; escribirlos aparte habría fabricado sedes nuevas.
El orden resultante `R-028` → `R-029` → `R-030` → `R-031` → `R-032` es además el cronológico.

### 4.2 Las cinco diferencias de contenido — decisión de cada una

| # | id | `main` | destino | rama | Qué difiere | Decisión y motivo |
|---|---|---|---|---|---|---|
| 1 | `R-016` | 421 L | 459 L | 344 L | La rama **movió** `### 2. Índice` a una sección `##` estable al inicio y dejó puntero; el destino añadió sobre `main` 10 líneas de `R-028` que estrechan el titular de `SEC-055` | **Rama.** `rama = destino − índice movido + puntero`. El índice no se pierde: vive arriba con 43 filas frente a las 33 de `main`, superconjunto verificado. El añadido de `R-028` está incluido |
| 2 | `R-017` | 197 L | 197 L | 202 L | `main` ≡ destino **byte a byte**; la rama añade 5 líneas de nota de mantenimiento sobre la nueva sede del índice | **Rama**, estrictamente mayor. Nada de `main` se pierde |
| 3 | `SEC-055` | 55 L | 65 L | 65 L | destino ≡ rama; a `main` le faltan las 10 líneas de la precisión de `R-028`, que **estrecha el enunciado sin cambiar el alcance** y deja el hallazgo `abierto` | **Rama.** Contiene íntegro el texto de `main` más la corrección posterior |
| 4 | `SEC-056` | 32 L | 32 L | 37 L | `main` ≡ destino; la rama añade la nota de sede, que dice de sí misma que **no cierra ni reclasifica** | **Rama**, estrictamente mayor |
| 5 | `SEC-087` | 59 L | — | 26 L | **No son dos redacciones del mismo texto.** `main` = **sede** del hallazgo (clase, severidad, contraejemplo medido, remediación). Rama = **entrada de cambio de estado** (`R-031` §5), que declara que la sede vive en `main` y que **no la trasplanta** para no fabricar una definición divergente | **Las dos, porque no compiten.** Patrón normal del registro: sede en una revisión, cambio de estado en otra posterior. El trasplante de `R-029` es lo que le da referente a `R-031` §5, que hasta ahora apuntaba a una sede ausente |

En 1–4 la relación es de **inclusión**, no de divergencia: el bloque de la rama **contiene** el de
`main`. No hubo que fundir redacciones ni se sacrificó evidencia, condición de cierre ni historial.

### 4.3 Filas de índice añadidas — 3

| Fila | Clase | Estado | Por qué |
|---|---|---|---|
| `SEC-087` | contrato | `mitigado` | Cerrado en `R-031` §5; **no estaba indexado en ninguna de las tres copias** |
| `SEC-088` | contrato | **`abierto`** | `contrato` y abierto; **no estaba indexado en ninguna de las tres copias**. Era el identificador cuya pérdida volvía invisible un bloqueante |
| `SEC-090` | contrato | `mitigado` | No se indexó a sí mismo al abrirse; se cierra en `R-032` |

Sello de la tabla actualizado `R-028` → `R-032`. **Recuento bloqueante: 25 `abierto` + 8
`en-mitigación` = 33** (antes 32). **Sube**, y sube porque el trasplante hace visible `SEC-088`.

### 4.4 Filas de `main` no presentes literalmente — 12, todas SUPERSEDIDAS, ninguna perdida

Cada una existe en el resultado con estado **más reciente**, por revisiones posteriores de la línea
de release (`R-026`, `R-027`, `R-028`). Es la disciplina del índice: *una fila no se borra nunca,
cambia de estado*.

| id | en `main` | en el resultado |
|---|---|---|
| `DEV-014-01` | `abierto` | `mitigado` (cerrado por QA 2026-09-08) |
| `DEV-014-02` | `abierto` | `mitigado` (ídem) |
| `SEC-014` | `mitigado`, discrepancia | `mitigado`, discrepancia **re-medida en `R-028`** |
| `SEC-031` | `en-mitigación` | `en-mitigación` + referencias de write-back detalladas |
| `SEC-032` | `en-mitigación` | ídem |
| `SEC-034` | `en-mitigación` | ídem |
| `SEC-035` | `en-mitigación` | ídem |
| `SEC-036` | `en-mitigación` | ídem |
| `SEC-050` | `abierto` | `mitigado` (cierre en `R-027`) |
| `SEC-052` | `mitigado`, discrepancia | `mitigado`, **discrepancia resuelta** |
| `SEC-054` | `abierto` | `mitigado` (cierre en `R-028`) |
| `SEC-055` | `abierto` | `abierto` + precisión de ubicación de `R-028` |

Las otras 4 líneas de `main` no presentes literalmente son las **4 líneas de la reubicación del
índice** (el encabezado `### 2.` y 3 líneas de referencia cruzada), reestructuración **preexistente
de la rama**, no de esta reconciliación.

## 5. Verificación final de la propiedad

| Comprobación | Resultado |
|---|---|
| Definiciones en `main ∪ destino ∪ rama` | **119** |
| Definiciones en el resultado | **120** (= 119 + `R-032`, la revisión nueva) |
| Definiciones **perdidas** | **0** |
| **Menciones** perdidas | **0** |
| Revisiones `## Revisión R-xxx` duplicadas | **0** |
| Identificadores con **dos sedes de apertura** | **0** |
| Filas del índice de `main` ausentes del resultado | **0** |
| Filas del índice del destino ausentes del resultado | **0** |
| Filas del índice duplicadas | **0** |

Conjunto antes ∪ conjunto después: `comm -23 union.defs final.defs` → vacío; la única entrada de
`comm -13` es `R-032`. Todo por **conjuntos**, no recorriendo una lista.

## 6. Tres premisas de `SEC-090` corregidas por la medición

1. **El forzador nombra una fusión que no es ésta.** `#48` va a `rel/registro-1.33.0`, no a `main`,
   y es *fast-forward* sin conflicto. La base declarada `5e53f12` no es la vigente (`1dfe31b`).
2. **`main` no podía ser la espina** (le faltan 31 definiciones de esta línea).
3. **`SEC-086` y `SEC-089` no existen como hallazgos en ninguna copia**: son declaraciones de
   «próximo libre». «Se perderían `SEC-086`…`SEC-089`» y «último hallazgo de `main`: `SEC-089`»
   leen una declaración de numeración como si fuera una sede.

**Las tres se detectaron porque la condición exigía una PROPIEDAD y no la lista de cuatro** — y la
lista estaba mal en dos de sus cuatro elementos. Un criterio por enumeración habría «pasado»
buscando cuatro cosas de las que dos no existen. Es el argumento del propio `requirements/README.md`
§«Cómo se escribe un criterio que no se desmiente», confirmado sobre un caso real.

## 7. Deuda que esta reconciliación NO cierra

**Write-back del `AGENTS.md` §9 — PENDIENTE, no implementado.** Que «la resolución de un
archivo-índice preserve todo identificador previo» quede como **NFR** sigue sin hacerse; el auditor
no escribe en `requirements/`.

- **Dueño:** `analista-requerimientos` (redacción); `auditor-seguridad` (verificación).
- **Forzador:** la siguiente fusión que toque este archivo entre dos líneas divergentes, o el cierre
  de la ventana 1.34.0, lo que ocurra antes.
- **Forma exigida:** por **propiedad** («ninguna resolución de este archivo pierde un identificador
  presente en cualquiera de las copias de entrada»), citando el sitio único de la lista exhaustiva,
  con ejemplos marcados **no exhaustivos**. Redactarlo como «se conservan `R-029`, `R-030` y
  `SEC-088`» reproduciría el defecto que §6 acaba de medir.

**Alcance de la firma de cierre de `SEC-090`:** acredita **estas tres cabezas**. Si la línea
publicada vuelve a avanzar sobre este archivo, la propiedad de superconjunto deja de estar medida y
debe re-verificarse. La **clase** del problema sigue abierta y vive en este write-back.

**No es objeto de esta reconciliación** la no-exhaustividad **general** del índice: es `SEC-085`,
abierto, con dueño propio.
