# Evidencia — REQ-017, vuelta 3 de 3, sobre el write-back de `CA-03` y `CA-08 (ii)`

## Versión base

| Qué | Valor |
|---|---|
| Commit medido | **`f4a5f1f`** (`La cota de SEC-064 en su sede declarada con cifra propia (1, no 2), y la cola re-derivada`) |
| Rama | `rel/registro-1.33.0` |
| Árbol | limpio salvo `docs/ESTADO.md`, que reescribe el hook `Stop` del arnés (bloque derivado) |
| Tramos del write-back | `a139155` (`CA-03`, el párrafo de la cota) y `f4a5f1f` (`CA-08 (ii)`, la cota con cifra 1) |
| Vuelta anterior | `86a44c8` (`QA: con-hallazgos`, 2026-09-10) |
| Fecha de medición | 2026-09-10 |
| Máquina | `linux-gnu-x86_64-bash5.3`, WSL2 (`6.18.33.2-microsoft-standard-WSL2`), `nproc` = 8 |

## Método — cómo re-derivar cada cifra sin preguntar

### 1. Que ningún código cambió (precondición del reuso de la vuelta 2)

```
git diff 86a44c8..f4a5f1f -- hooks/ tools/ tests/ .github/ .arnes/ templates/ .claude-plugin/
```

**Salida vacía, `rc=0`.** Los 16 archivos que cambian entre los dos commits son `CHANGELOG.md`,
`PENDING_APPROVAL.md`, `docs/` (7) y `requirements/` (2). Por eso **no se re-midió** la banda, el
techo, los umbrales ni el modo intercalado: se reusa `docs/qa/evidencia-req-017-modo-86a44c8/`.

### 2. Quality gates de `AGENTS.md` §7

Las tres del manifiesto, corridas literalmente como las declara `.arnes/config.json`:

```
for f in hooks/*.sh tools/*.sh; do bash -n "$f" || exit 1; done
jq -e . hooks/hooks.json >/dev/null
jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null
```

**Las tres en verde.**

### 3. Banco completo y autoprueba

```
bash tests/escenarios/hooks/run.sh            # -> banco-completo.txt
bash tests/escenarios/hooks/autoprueba-corredor.sh   # -> autoprueba.txt
```

- Banco: **1057 PASS · 1 FAIL · 6 SKIP**, total 1064, **`rc=1`**. `loadavg` al arrancar **3.36**.
- Autoprueba: **106 PASS · 0 FAIL**, `rc=0` ⇒ el cuadre de `CA-18` y el `CASOS_ESPERADOS`
  **no se rompieron** con el write-back.
- El `FAIL` **no es de REQ-017**: es `REQ-023 CA-09 (iii)` sobre `arnes_campo_linea`. Lista de SKIP
  (nunca el total) en `banco-completo.txt`.

### 4. Flakiness de `REQ-023 CA-09 (iii)` — cuatro corridas, mismo código

```
for i in 1 2 3; do bash tests/escenarios/hooks/run.sh 'CA-09 (iii)'; done   # -> flaky-req023-ca09-iii.txt
```

| Corrida | `loadavg` | `arnes_campo_linea` | mediana |
|---|---|---|---|
| banco completo | 3.36 | **FAIL** | 1.159× |
| 1 | 1.44 | **SKIP** | 0.988× |
| 2 | 2.61 | **PASS** | ~0.93× (margen 0.037 > dispersión 0.035) |
| 3 | 2.79 | **PASS** | ~0.93× (margen 0.064 > dispersión 0.015) |

**FAIL → SKIP → PASS → PASS sobre código idéntico.** El techo `1.000×` vive dentro del ruido: la
misma patología que `REQ-017 CA-08 (ii)` describe («el techo vive dentro del ruido del instrumento»).

### 5. `QA-017-27` reproducido — la abstención publica la carga de OTRA medición

No se editó ningún archivo del proyecto. Se **extrajeron, byte a byte y en sólo lectura**, las
funciones reales a un arnés de pruebas del scratchpad:

```
SEC=tests/escenarios/hooks/secciones/37-coste-del-escaner-2-las-razones.sh
sed -n '/^num37() {/,/^}/p' "$SEC"      # + mil37, mide37, mide37i, banda37, razon37
sed -n '/^sonda_num() {/,/^}/p' tests/escenarios/hooks/run.sh   # + sonda_lee
```

Guiones conservados aquí: `harness-funciones-reales.sh` y `driver-qa-017-27.sh`.
Se ejecuta con `SP=<dir> bash driver-qa-017-27.sh`.

**Escenario:** la medición **directa** mide de verdad; el fail-before **no mide** porque el tag
v1.32.1 está ausente (rama `HER37_OK != si`, `:370-371`, donde `mide37i` **no se invoca**).

**Observado** (`qa-017-27-reproducido.txt`):

```
tras la DIRECTA (medicion REAL): MED37_PLAT=<linux-gnu-x86_64-bash5.3> MED37_CARGA=<2.67>
  PASS  ...doblar la línea no cuadruplica  ... plataforma=linux-gnu-x86_64-bash5.3 carga=2.67
  SKIP  ...fail-before...  no hay con qué medir: no hay línea base v1.32.1 ...
        · modo=intercalado k=1 series=3 · plataforma=linux-gnu-x86_64-bash5.3 carga=2.67
```

La abstención del fail-before **no midió nada** y aun así publica `carga=2.67`: es la de la
**directa**. Confirma `QA-017-27` (abierto desde la vuelta 2, `instrumento`, dueño `desarrollador`).

**Segunda vía, misma clase** (`abstencion-sin-maquina.txt`): si `mide37i` falla **antes** de leer el
registro (`! -r "$lib"`, registro vacío, `sonda_lee` falla), `MED37_PLAT`/`MED37_CARGA` quedan
**vacías** y la abstención publica `plataforma=n/a carga=n/a`:

```
  SKIP  ...doblar la línea no cuadruplica  no hay con qué medir: no existe /no/existe/lib.sh
        ... · plataforma=n/a carga=n/a
```

### 6. Los seis mensajes de abstención de `CA-08 (ii)` — comprobados uno por uno

```
grep -n "plataforma\|carga\|loadavg\|uname" tests/escenarios/hooks/secciones/37-coste-del-escaner-5-el-camino-normal.sh
```

**Única aparición: `:236`, y es un comentario.** Los seis `echo "  SKIP ..."` de `:297`, `:307`,
`:313`, `:324`, `:334` y `:345` **no emiten `plataforma` ni `carga`**. La desviación que el analista
declaró en `CA-08` es **exacta**.

Contraste medido: los casos de `CA-03` (sección 37/2) **sí** los publican, porque `razon37` arma la
evidencia una vez y la saca en **todas** las ramas (`· $ev`, con `$mue` dentro).

### 7. El banco produce FAIL espurios cuando corre con filtro

```
bash tests/escenarios/hooks/run.sh 'CA-03'     # 2 FAIL
bash tests/escenarios/hooks/run.sh 'REQ-017'   # 3 FAIL
bash tests/escenarios/hooks/run.sh             # 1 FAIL (y es de REQ-023)
```

**Causa:** los autotests de `CA-03` (`:482` y siguientes) invocan `razon37` con el nombre sintético
`sonda-de-prueba`; `razon37:296` lleva su propia guarda de filtro
(`[ -n "$FILTRO" ] && ! ... grep -qi -- "$FILTRO" && return 0`), así que con `FILTRO` puesto las 10
invocaciones **no emiten nada**, `obs37b` queda vacío y el caso compara `<>` contra
`<PASS FAIL SKIP SKIP PASS FAIL SKIP SKIP SKIP SKIP >`.

**Dirección del fallo: fail-closed** (produce FAIL, nunca PASS). El CI **no** usa filtro
(`.github/workflows/banco.yml:92` corre `run.sh` sin argumentos), así que la puerta requerida no se
ve afectada; quien se ve afectado es el humano o el agente que itera con filtro.

### 8. Auditabilidad del contador de vueltas de §6 (desde el disco)

```
for c in 538c266 86a44c8 a139155 f4a5f1f; do git show "$c:requirements/REQ-017.md" | sed -n 's/^QA: //p' | head -1; done
```

| Commit | `QA:` que contiene |
|---|---|
| `538c266` | `con-hallazgos (2026-09-08, vuelta 3 de 3 —la última, AGENTS.md §6— sobre 19b1822...` |
| `86a44c8` | `aprobado (2026-09-08, **vuelta 1 de 3 del ciclo reabierto por §9**, sobre 538c266...` |
| `a139155` | `con-hallazgos (2026-09-10, sobre 86a44c8...` — **sin número de vuelta** |
| `f4a5f1f` | idéntico a `a139155` (el analista no tocó el campo `QA:`) |

**El recuento de la comisión queda confirmado:** vuelta 1 = `aprobado` del 2026-09-08, vuelta 2 =
`con-hallazgos` del 2026-09-10, **ésta es la 3**. Y el defecto de auditabilidad también: el veredicto
de la vuelta 2 **no declara su número**, así que el contador de §6 no se podía auditar desde el
disco. Corregido en el veredicto de esta vuelta.

### 9. Cola de aprobaciones

```
bash tools/arnes-lectura.sh | grep -i cola
#  cola de aprobaciones (PENDING_APPROVAL.md): 15 pendiente(s) — ningún REQ puede cerrarse
```

## Límites de esta evidencia, dichos expresamente

- **Una sola corrida del banco completo, sin warm-up**, en WSL2 con carga 3.36. No es representativa
  del runner de `hooks-en-linux` (4 vCPU, `ARNES_JOBS=6`). No se usa para acreditar rendimiento:
  se usa para comprobar que el write-back **no rompió** el cuadre, que es lo que se le pidió.
- **No se re-midió** la banda, el techo, los umbrales ni el modo: el código es byte a byte idéntico
  al de la vuelta 2 (§1) y esa evidencia se reusa.
- **No se midió en el CI real.** Las cotas de `CA-03` y `CA-08 (ii)` se comprueban sobre el historial
  de `hooks-en-linux`, que es externo a cualquier corrida local; hoy **nadie por máquina** emite esa
  cuenta, y eso está declarado en los dos criterios con dueño `desarrollador`.
- **`gh` sigue sin autenticar** en esta máquina, así que el historial de corridas de la puerta
  requerida **no se pudo consultar**. La comprobabilidad de las cotas se juzgó sobre el **texto** del
  criterio (¿nombra un observable externo, con dueño y vencimiento?), no ejecutándola.
