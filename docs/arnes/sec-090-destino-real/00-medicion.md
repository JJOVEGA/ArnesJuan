# `SEC-090` medido contra el destino REAL de `#48`, no contra `main`

**Versión base de la medición.** `origin/main` = `10eac80` · `origin/rel/registro-1.33.0` =
`1dfe31b` · `origin/feat/1.34-reparaciones-astra` = `3c52d6d`. Medido el 2026-09-11.

## El hecho que cambia la premisa

`SEC-090` escribió su forzador como «**antes de fusionar `#48` a `main`**». Esa fusión no es la
que está autorizada: el destino real del PR es **`rel/registro-1.33.0`**.

| Hecho | Cifra | Cómo se obtuvo |
|---|---|---|
| Destino de `#48` | `rel/registro-1.33.0` | `gh pr view 48 --json baseRefName` |
| Cabeza del destino | `1dfe31b` | `git log --oneline -1 origin/rel/registro-1.33.0` |
| Merge-base destino↔rama | **`1dfe31b`** | `git merge-base origin/rel/registro-1.33.0 origin/feat/1.34-reparaciones-astra` |
| Estado de fusión | `CLEAN` / `MERGEABLE` | `gh pr view 48 --json mergeable,mergeStateStatus` |

La merge-base **es** la cabeza del destino: `#48` es **fast-forward** y **no hay conflicto**. El
archivo `docs/seguridad/registro-seguridad.md` no se resuelve en esta fusión; se adelanta entero.

## Definiciones, no menciones

Un identificador **citado** dentro del bloque de otro hallazgo no lo **define**. Contar presencias
con `grep -oE '\b(SEC|R)-[0-9]{3}\b'` da un resultado falso — este error ya se cometió una vez
sobre este mismo archivo. Se cuenta **definición** = identificador en una línea de encabezado:

```sh
git show <ref>:docs/seguridad/registro-seguridad.md \
  | grep -E '^#{1,6} ' | grep -oE '\b(SEC|R)-[0-9]{3}\b' | sort -u
```

| Ref | Presencias | **Definiciones** |
|---|---|---|
| `origin/main` | 96 | **86** |
| `origin/rel/registro-1.33.0` (destino) | 116 | **113** |
| `origin/feat/1.34-reparaciones-astra` (rama) | 124 | **116** |

## El inventario, elemento por elemento

**Definidos en `main` y NO en la rama — 3:** `R-029`, `R-030`, `SEC-088`.

**Definidos en el destino y NO en la rama — 0.** La rama ya es **superconjunto** de su destino:
fusionar `#48` en `rel/registro-1.33.0` **no pierde ningún identificador**.

**Definidos en `main` y NO en el destino — 4:** `R-029`, `R-030`, `SEC-087`, `SEC-088`.
(`SEC-087` sí está definido en la rama; llegó en `3c52d6d`.)

**Definidos en la rama y NO en `main` — 30.** Por eso `main` **no** es superconjunto, y por eso
«tomar `main` como espina» tal como lo redactó `SEC-090` cambiaría un archivo de 116 definiciones
por uno de 86. La operación con el mismo efecto y sin esa pérdida es: **espina = la copia de la
rama, más los 3 bloques que sólo define `main`**.

**Definidos en ambos con contenido distinto — 5:** `R-016` (main 421 L / rama 344 L), `R-017`
(197 / 202), `SEC-055` (55 / 65), `SEC-056` (32 / 37), `SEC-087` (59 / 26). Cada uno exige
reconciliación explícita; ninguno se resuelve eligiendo el estado más favorable.

## Dónde vive el riesgo de verdad

`SEC-090` es **real** y su remediación **sigue siendo necesaria** — pero el acto que la materializa
es la fusión posterior **`rel/registro-1.33.0` → `main`**, no ésta. Hacer la reconciliación ahora,
sobre la rama, es lo conservador: deja el archivo ya reconciliado antes de que ese acto ocurra.

## Aprobaciones vigentes

Entre la cabeza aprobada `6e3bb90` y la actual `3c52d6d` cambian **11 archivos y ninguno es
código ni contrato**:

```sh
git diff --name-only 6e3bb90 3c52d6d \
  | grep -E '^(hooks/|tools/|\.github/|tests/|requirements/|templates/|\.arnes/|\.claude-plugin/)'
# -> sin salida
```

Sólo `CHANGELOG.md`, artefactos de evidencia de QA y el bloque `R-031` del registro, todo aditivo
(968 inserciones, 0 borrados). Por tanto `QA: aprobado` (vuelta 1 de 2), `Seguridad: aprobado`
(`R-031`) y `hooks-en-linux pass`, emitidos sobre `6e3bb90`, **siguen siendo aplicables al código
de `3c52d6d`**.
