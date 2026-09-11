# `SEC-084` y `QA-024-19`: qué se reproduce hoy, qué ya estaba corregido y qué se repara

**Versión base de la medición.** Worktree `/home/juan/dev/ArnesJuan-1.34-reparaciones`, rama
`feat/1.34-cierre-alcance`, **`HEAD = 6327b8c`**. `hooks/` y `tests/` son **idénticos** en
`6327b8c` y en `e53de46` (`git diff --stat e53de46 HEAD -- hooks tests` sale **vacío**), así que
todo lo que este artefacto llama «la base» vale para los dos. Árboles históricos comparados:
`v1.33.0` (`8a4ecb3`… por tag), `v1.33.1` (`b0eb678`), `v1.33.2` (`5c453cb`), `db53011`,
`aece716`, `ce714c7`. Medido el **2026-09-11**, Linux/WSL2, bash 5.3.

---

## 1. Método — cómo re-derivar cada cifra sin preguntar

Los árboles históricos se materializan **desde el repositorio**, no se copian de ningún sitio:

```bash
S=<directorio de trabajo>
cd /home/juan/dev/ArnesJuan-1.34-reparaciones
for ref in v1.33.0 v1.33.1 v1.33.2 db53011 aece716 ce714c7 e53de46; do
  mkdir -p "$S/t-$ref"; git archive "$ref" hooks | tar -x -C "$S/t-$ref"
done
```

La puerta se ejerce **de verdad** —no se lee el código—, con un proyecto de prueba mínimo. Éste es
el arnés completo; `$W` apunta al árbol cuyos hooks se juzgan:

```bash
P="$S/proj"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$P"
printf '# REQ-050\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: pendiente\n' \
  > "$P/requirements/REQ-050.md"

probar() {   # <new_string> -> decision y si hubo aviso
  local j out dec msg
  j=$(jq -n --arg fp "$P/requirements/REQ-050.md" --arg ns "$1" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"x",new_string:$ns}}')
  out=$(printf '%s' "$j" | "$W/hooks/guard-completado.sh" 2>/dev/null)
  printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && dec=DENY || dec=ALLOW
  msg=$(printf '%s' "$out" | jq -r '.systemMessage // empty')
  printf '%-32s %-5s aviso=%s\n' "$1" "$dec" "$([ -n "$msg" ] && echo si || echo NO)"
}
```

**El control que acredita que la puerta estaba activa** va en **todas** las corridas y es el del
auditor: `Seguridad: aprobado` sobre un REQ con `QA: pendiente` debe dar **DENY**. Sin él, un «no
se reproduce» puede significar que el mecanismo ni se invocó.

El cierre se mide aparte, porque «gobierna» no es lo mismo que «se firma»: un `critico` cuyo
**único** veredicto de seguridad va escrito en la forma bajo prueba, y un `Edit` que cambia
`Estado: en-revisión` por `Estado: completado`. **ALLOW = esa forma gobierna.**

---

## 2. Cuál de las tres situaciones existe — y son dos a la vez

| | Hallazgo | Situación | Por qué |
|---|---|---|---|
| **(c)** | `SEC-084`, su **vector medido** (clave decorada firma, nadie la juzga, y **gobierna** el cierre) | **ya corregido en el código; lo desactualizado es el registro** | `v1.33.1` (`b0eb678`) sustituyó el disparador del ORDEN; `#48` (`d1b3cc3`) lo portó a 1.34.0 |
| **(a)** | `QA-024-19` (la clave en **minúscula** evade el disparador y **nada avisa**) | **se reproduce íntegro** en `HEAD` y en `v1.33.2` **publicada** | el disparador del **aviso** nunca se tocó |
| **(b)** | **variante que el arreglo anterior no cubrió**: la clave **decorada** con un valor fuera de vocabulario **no produce aviso** | **se reproduce** en `HEAD` y en `v1.33.2` | `v1.33.1` cambió **una** de las dos sedes; la otra siguió siendo la misma cadena literal |

### El cambio que ya existía, localizado

```
$ git diff aece716 e53de46 -- hooks/guard-completado.sh | grep -E "grep -q 'Seguridad|ARNES_SEG_CRUDO|seg_antes"
-    if grep -q 'Seguridad:' <<< "$nuevo"; then
+    arnes_seguridad_cabecera "$disk"; seg_antes="$ARNES_SEG_CABECERA"
+    if [ "$ARNES_SEG_CRUDO" != "$seg_antes" ]; then
```

**Lo que quedó sin cubrir, y es toda la reparación de hoy.** La cadena literal sobrevivió
**verbatim** en la OTRA sede del mismo archivo. Recuento de apariciones por árbol
(`grep -n "grep -q 'Seguridad:'" hooks/guard-completado.sh`):

| árbol | línea 252 (**aviso**) | línea 275/334 (**orden**) |
|---|---|---|
| `v1.33.0`, `ce714c7`, `aece716` | presente | **presente** |
| `v1.33.1`, `v1.33.2`, `db53011`, `e53de46`, `HEAD` | **presente** | retirado |

Y la gemela `grep -q 'QA:'` (línea 249) nunca se tocó en ningún árbol.

---

## 3. Fail-before / pass-after, caso por caso

### 3.1 Acto de FIRMAR sobre `QA: pendiente` (control positivo en la misma corrida)

| forma escrita | esperado | `v1.33.0` | `v1.33.2` (publicada) | `HEAD` antes | **`HEAD` después** |
|---|---|---|---|---|---|
| `Seguridad: aprobado` **(control)** | DENY | DENY | DENY | DENY | **DENY** |
| `_Seguridad_: aprobado` | DENY | ALLOW | DENY | DENY | **DENY** |
| `**Seguridad**: aprobado` | DENY | ALLOW | DENY | DENY | **DENY** |
| `*Seguridad*: aprobado` | DENY | ALLOW | DENY | DENY | **DENY** |
| `__Seguridad__: aprobado` | DENY | ALLOW | DENY | DENY | **DENY** |
| `seguridad: aprobado` | *no es firma* | ALLOW | ALLOW | ALLOW | **ALLOW + AVISO** |
| `SEGURIDAD: aprobado` | *no es firma* | ALLOW | ALLOW | ALLOW | **ALLOW + AVISO** |
| `Notas: trabajo en curso` **(control −)** | ALLOW | ALLOW | ALLOW | ALLOW | **ALLOW** |

### 3.2 El AVISO — la sede que el arreglo anterior no tocó

| forma escrita | esperado | `v1.33.2` | `HEAD` antes | **`HEAD` después** |
|---|---|---|---|---|
| `Seguridad: aprobado-ish` **(control)** | aviso | aviso | aviso | **aviso** |
| `_Seguridad_: aprobado-ish` | aviso | **ninguno** | **ninguno** | **aviso** |
| `**Seguridad**: aprobado-ish` | aviso | **ninguno** | **ninguno** | **aviso** |
| `` `Seguridad`: aprobado-ish `` | aviso | **ninguno** | **ninguno** | **aviso** |
| `**QA**: aprobadisimo` | aviso | **ninguno** | **ninguno** | **aviso** |
| `_Seguridad_: preventiva` **(discrim.)** | ninguno | ninguno | ninguno | **ninguno** |

### 3.3 Acto de CIERRE — no se mueve ni una celda

`critico` cuyo **único** veredicto de seguridad está escrito así. **ALLOW = gobierna.**

| forma escrita | `v1.33.2` | `HEAD` antes | **`HEAD` después** |
|---|---|---|---|
| `Seguridad: aprobado` **(control)** | ALLOW | ALLOW | **ALLOW** |
| `_Seguridad_: aprobado` | ALLOW | ALLOW | **ALLOW** |
| `**Seguridad**: aprobado` | ALLOW | ALLOW | **ALLOW** |
| `seguridad: aprobado` | DENY | DENY | **DENY** |
| `SEGURIDAD: aprobado` | DENY | DENY | **DENY** |
| `Seguridad: pendiente` **(control −)** | DENY | DENY | **DENY** |

**El cierre sigue fail-closed y eso es deliberado.** La reparación **no ensancha el lector**: la
minúscula sigue sin ser el campo, el REQ sigue sin declararlo y la ausencia sigue denegando. Lo
único que cambia es que **deja de ser mudo**.

---

## 4. Que los dos conjuntos coinciden — por propiedad, no por lista

La reparación no enumera formas. Añade **una** función en `hooks/lib.sh`,
**`arnes_declara_clave <texto> <clave>`**, que recorre la cabecera con **el lector**
(`arnes_campo_linea` → `arnes_norm_clave`) y responde:

- **`lee`** — el lector lee esa línea **como ese campo**. Es el conjunto que gobierna, y no se
  escribe en ninguna parte: se **pregunta**. Una forma que el lector acepte mañana entra sola.
- **`desfase`** — hay una línea que **una persona** lee como ese campo y el lector **no**: plegada
  la clave con `arnes_norm_campo` —el mismo plegado que el arnés ya aplica a los valores (blancos,
  marcado, ortografía y caja)— coincide con la clave, y **sin plegar** no.
- **`no`** — esa clave no aparece.

Y la clave se pasa por su **constante** (`$ARNES_CLAVE_QA`, `$ARNES_CLAVE_SEG`), nunca tecleada:
una clave que cambie de nombre en `ARNES_CLAVES` mueve **las dos** guardas a la vez.

**Verificación de la propiedad, por sus dos bordes.** No basta con que casen tres cadenas:

| entrada | respuesta | comprobado |
|---|---|---|
| `_seguridad_: aprobado` (decoración **y** caja a la vez) | `desfase` + aviso | sí |
| `SeGuRiDaD: aprobado` (caja arbitraria, no minúscula) | `desfase` + aviso | sí |
| `Qa: aprobado` | `desfase` + aviso | sí |
| `Sensible a seguridad: si` (**otra clave** que contiene la palabra) | `no` — **sin aviso** | sí |
| `Notas de seguridad: ninguna` | `no` — **sin aviso** | sí |
| `qa-tester: juan` | `no` — **sin aviso** | sí |
| `Modulo:`, `Archivos:` | `no` — **sin aviso** | sí |
| `seguridad: aprobado` **y** `Seguridad: pendiente` en la misma cabecera | `lee` manda — **sin aviso** | sí |
| `seguridad: aprobado` **tras** el primer `## ` | `no` — **sin aviso** | sí |

Lo que la reparación **no** cubre, y va dicho aquí y no en otro documento: un **homóglifo** dentro
de la clave **no** se reconstruye —reponer *qué* letra exigiría elegir entre candidatos—, así que
sigue cayendo en `no` y **sin aviso**. **Medido, con su control en la misma corrida:**
`Ѕeguridad: aprobado` (con la `Ѕ` cirílica, `U+0405`) → **ALLOW sin aviso**; la misma frase sin el
homóglifo, `seguridad: aprobado` → **ALLOW con aviso**. Es la misma frontera deliberada que
`AGENTS.md` §13 ya declara para la guarda de medibilidad, y este trabajo **no la mueve**.

---

## 5. Coste

Medido con `tests/util/sonda-procesos.sh`, misma máquina y misma corrida:

| entrada | base | reparado |
|---|---|---|
| edición que escribe **los dos** veredictos fuera de vocabulario | `procesos=11` | **`procesos=9`** |
| edición que escribe **uno** | `procesos=10` | **`procesos=9`** |
| edición que **no toca ningún veredicto** (camino normal) | `procesos=8` | **`procesos=8`** |

**Cero procesos añadidos y hasta dos retirados**: sustituye dos `grep` —dos forks por edición— por
un recorrido en bash puro que además **para en el primer `## `**, donde el `grep` leía el documento
entero. La guarda de entrada es la del propio lector (sin `:` no hay campo), así que un texto sin
dos puntos no paga ni el recorrido.

---

## 6. Banco y quality gates

**Sección nueva `42-disparador-y-lector.sh`**, 20 casos. `CASOS_ESPERADOS` de `run.sh`:
**1095 → 1115**.

| corrida | resultado | cuadre |
|---|---|---|
| sección 42 contra **`HEAD` base** (`ARNES_HOOKS_DIR` al árbol base) | **12 PASS · 8 FAIL** | — |
| sección 42 contra **`v1.33.2` publicada** | **12 PASS · 8 FAIL** | — |
| sección 42 contra el árbol **reparado** | **20 PASS · 0 FAIL** | — |
| **banco entero**, árbol **base** aislado (copia con `hooks/` y `run.sh` revertidos) | **1083 PASS · 0 FAIL · 12 SKIP** | 1095 ✓ |
| **banco entero**, árbol **reparado** | **1107 PASS · 0 FAIL · 8 SKIP** | 1115 ✓ |

**Los 8 discriminantes** son los cuatro avisos de clave decorada (§3.2) y los cuatro de desfase
(§4). Los 12 restantes **fijan lo que no se puede mover**: el cierre fail-closed con la minúscula
y su control positivo, el orden que sigue denegando la firma decorada, y los tres falsos positivos.

**La diferencia de SKIP (12 → 8) NO es de esta reparación y se conserva como lo que es:
variabilidad de los instrumentos de tiempo.** Los cuatro casos que cambian —`REQ-017 CA-03`,
`REQ-017 CA-09`, `REQ-017 CA-08 (ii)` «6 líneas» y `REQ-024 CA-07 (iii)`— **pasaron a PASS en una
segunda corrida del propio árbol base**, sin cambiar nada. Ninguno pasó de PASS a FAIL ni de PASS a
SKIP en ninguna dirección. No se investiga más: el instrumento de rendimiento está fuera de alcance
por instrucción del propietario.

**Quality gates de `AGENTS.md` §7**, las tres en verde: `bash -n` sobre `hooks/*.sh` y `tools/*.sh`;
`jq -e . hooks/hooks.json`; `jq -e . .claude-plugin/plugin.json` y `marketplace.json`. Y
`tests/escenarios/hooks/autoprueba-corredor.sh`: **106 PASS · 0 FAIL**, con la fila de `CA-18`
`42-disparador-y-lector.sh  lineas=127  piso=59  techo=400 (gobierna N)`.

---

## 7. Otros campos con el mismo disparador

Barrido de `hooks/*.sh`, `hooks/*.awk` y `tools/*.sh` buscando claves usadas como **cadena** en
código vivo: **no queda ningún disparador de decisión por cadena literal**. Los tres usos que
aparecen (`tools/arnes-lectura.sh:196`, `:204`, `:208`) son **etiquetas de impresión** del informe,
no disparadores.

**Lo que sí queda para la cola, y no se toca aquí — un defecto, una reparación.** `Estado:`,
`Rigor:`, `Sensible a seguridad:` y `Hallazgos abiertos:` **no tienen aviso en absoluto**: escritos
con la caja cambiada se resuelven como ausencia y **nada lo comenta**, igual que pasaba con
`Seguridad:`. No es el mismo defecto —no hay disparador que desfasar, hay cobertura que no existe—
y `arnes_declara_clave` ya sirve para cerrarlo cuando se decida. *Dueño:* `desarrollador`.
*Forzador:* la primera cabecera que declare uno de esos cuatro con la caja cambiada.
