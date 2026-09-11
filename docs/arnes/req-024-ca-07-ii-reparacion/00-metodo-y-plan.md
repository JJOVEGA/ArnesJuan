# REQ-024 CA-07 (ii) — método y plan de medición

> **Este archivo se escribió ANTES de mirar ningún resultado.** Las repeticiones y el
> criterio de lectura quedan fijados aquí para que la interpretación no se elija después
> (AGENTS.md §14.B.1 y §14.B.7).

## Versión base

| qué | valor |
|---|---|
| worktree | `/home/juan/dev/ArnesJuan-1.34-reparaciones` |
| rama | `feat/1.34-reparaciones-astra` |
| commit medido (sujeto A) | `69fc96a` |
| línea base (sujeto B) | tag `v1.33.0` (`hooks/` y `tools/` materializados con `git ls-tree`/`git show`, igual que `mat40`) |
| máquina | WSL2, 8 núcleos lógicos, bash 5.x |
| instrumento | `tests/util/sonda-reloj.sh`, sin modificar |

## La pregunta

¿El cociente de ~1,25–1,33× observado en CI es **coste real** del código de la rama, o es
**dispersión del instrumento** alrededor de un cociente verdadero por debajo del techo?

Tres FAIL medidos (1,320× sobre `67b06fe`, 1,257× sobre `0caeac5`, 1,321× sobre `69fc96a`,
que es **código idéntico** a `0caeac5`) y seis PASS sobre la misma rama. Eso acota y no cierra.

## El discriminante: la distribución NULA

Un cociente no se juzga contra una intuición, se juzga contra la distribución que el mismo
instrumento produce cuando el cociente verdadero es **exactamente 1,000×**. Esa distribución
se obtiene midiendo **el mismo árbol contra sí mismo materializado dos veces**:

- **`AB`** — rama (`69fc96a`) contra `v1.33.0`. Es la medida real del criterio.
- **`AA`** — rama contra una **segunda copia** de la rama, en otro directorio. Cociente
  verdadero = 1,000× por construcción. **Es la distribución nula.**
- **`BB`** — `v1.33.0` contra una segunda copia de `v1.33.0`. Segunda nula, y control de que
  la nula no depende de qué árbol se use.

Las dos copias van en **directorios distintos** porque `AB` también compara directorios
distintos: si el efecto fuera de ruta, caché o inodo, `AA` lo vería igual.

### Cómo se lee (fijado aquí, antes de medir)

1. Si el recorrido de `AA` **cubre** el intervalo donde caen los `AB` —en particular si `AA`
   alcanza o supera 1,250×— entonces el instrumento, a `k=4 r=6`, **no resuelve** el factor
   que vigila: el FAIL es dispersión y la reparación es del instrumento.
2. Si `AA` se queda pegado a 1,000× (recorrido estrecho) y los `AB` se desplazan claramente
   por encima, es **coste real**: hay hallazgo contra el código y la reparación del
   instrumento no basta.
3. Caso mixto (`AA` disperso **y** `AB` desplazado por encima de `AA`): hay las dos cosas;
   se declara y se presenta la decisión.

## Fase 2 — la medición de alta precisión (el camino de acreditación)

El mínimo sobre `r` series es un estimador cuyo sesgo baja con `r`. La fase 2 sube
`k` de 4 a 8 y `r` de 6 a 30 sobre los **mismos** sujetos. Sirve para dos cosas: estimar el
cociente **verdadero** de `AB` (que es lo que decide si hay regresión de código) y comprobar
que la nula `AA` colapsa hacia 1,000× al aumentar `r` —lo que confirmaría que lo de la fase 1
es varianza del instrumento y no un efecto sistemático—.

## Repeticiones, y por qué esas — ELEGIDAS ANTES DE MIRAR

- **Fase 1: 25 repeticiones por condición** (`AB`, `AA`, `BB`), a los parámetros **exactos**
  del caso actual (`--k 4 --r 6`). Motivos: (a) 25 puntos dan el recorrido empírico con
  resolución ≈ 4 %, suficiente para distinguir un **desplazamiento** de 0,25× de una
  **dispersión** — que es la única pregunta de la fase 1—; (b) es del mismo orden que las
  muestras con las que este repositorio ya derivó parámetros de reloj (56 repeticiones para
  `KRAZ47` en REQ-017), así que no inventa una escala nueva; (c) cuesta ≈ 2 min por
  condición, así que caben las tres condiciones sin recortar ninguna.
- **Fase 2: 9 repeticiones por condición** (`AB`, `AA`), a `--k 8 --r 30`. Motivo: cada
  invocación cuesta ≈ 30× más que una de la fase 1, y con 9 puntos ya se ve si el recorrido
  **colapsa** respecto a la fase 1; la fase 2 no busca resolución de cola, busca el centro.
- **Ninguna corrida se descarta.** Se guardan todas, también las que salgan incómodas
  (memoria `variabilidad-no-desmiente-un-fail`).

## Método — comandos exactos para re-derivar

```bash
W=/home/juan/dev/ArnesJuan-1.34-reparaciones
bash docs/arnes/req-024-ca-07-ii-reparacion/medir.sh fase1 25
bash docs/arnes/req-024-ca-07-ii-reparacion/medir.sh fase2 9
```

`medir.sh` materializa los tres árboles con el mismo procedimiento que `mat40`
(`git ls-tree -r <ref> -- hooks tools` + `git show`), fabrica el mismo fixture `ENT40`
(un `Write` sobre `REQ-951` completado con los cuatro campos) y llama a
`tests/util/sonda-reloj.sh` con los sujetos intercalados. Escribe un registro por línea en
`corridas/<fase>-<condicion>.txt`, con el registro **íntegro** de la sonda.

---

## ADENDA (escrita al descubrirlo, no al elegir un resultado): el sujeto de las fases 1 y 2 NO era el del banco

Al ejecutar el caso reparado dentro del corredor, la sonda devolvió `estado=suelo` con series de
~46 ms, contra los ~133 ms que daban las fases 1 y 2. La causa está en `hooks/lib.sh` línea 173:

> `# Raíz del proyecto: prioriza $CLAUDE_PROJECT_DIR; si no, el campo cwd del input.`

Dentro del banco, `seccion_nueva` **exporta** `CLAUDE_PROJECT_DIR` al proyecto limpio de la
sección, así que el sujeto que el caso mide **no** trabaja sobre el proyecto del `cwd` del JSON
—el que lleva el corpus de 31 REQ— sino sobre uno **vacío**. `medir.sh` no exportaba nada, así
que las fases 1 y 2 midieron un sujeto **2,8× más pesado** que el real.

**Qué se hace con eso, y por qué no se borra:** las fases 1 y 2 **se conservan enteras**. Siguen
siendo una réplica válida de la pregunta sobre un sujeto vecino, y su nula sirve de control. Pero
**no** son la evidencia que decide: para eso se añaden las fases 3 (sujeto fiel, `k=4 r=6`, en
reposo y bajo contención) y 4 (sujeto fiel, `k=8 r=30` — la acreditación), con **las mismas 25 y
9 repeticiones** ya fijadas arriba y el **mismo criterio de lectura**. Lo que cambia es el
sujeto, que estaba mal; no el número de repeticiones ni cómo se interpretan, que es lo que esta
adenda existe para no tocar.

```bash
bash docs/arnes/req-024-ca-07-ii-reparacion/medir.sh fase3  25   # sujeto fiel, reposo
bash docs/arnes/req-024-ca-07-ii-reparacion/medir.sh fase3c 25   # sujeto fiel, contención
bash docs/arnes/req-024-ca-07-ii-reparacion/medir.sh fase4   9   # sujeto fiel, k=8 r=30
```
