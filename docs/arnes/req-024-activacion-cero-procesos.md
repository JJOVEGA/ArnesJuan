# REQ-024 · ¿Existe una vía de activación que no añada ningún proceso? — MEDIDO

**Respuesta: SÍ.** Existe, es la **llave de manifiesto** —el candidato que el analista creía en
tensión con `CA-07 (i)`— y cuesta **0 procesos añadidos** tanto en la evaluación de la puerta como en
la parada, si la llave se **pliega en la llamada a `jq` que ya existe** en
`arnes_parse_manifest` (y, para la parada, en la de `arnes_parse_manifest_estado`).

- **Versión base:** rama `rel/registro-1.33.0`, commit **`4f51293`** (`4f5129325559c0551ede697e4b267f3baee949e3`).
- **Fecha:** 2026-09-09. **Agente:** `desarrollador`. **Encargo:** comprobación de **factibilidad**, no implementación.
- **Alcance:** responde el punto **5** de «Qué queda sin verificar» de `requirements/REQ-024.md`
  («que los dos ADR puedan decidir algo que cumpla `CA-07 (i)` no está demostrado»). **No re-deriva
  ningún criterio**: eso es del `analista-requerimientos`.
- **Nada del árbol de producción se ha modificado.** Los prototipos se construyeron y midieron
  **en `/tmp`** (directorio de trabajo de la sesión) sobre copias de `hooks/`; `git status` de
  `hooks/`, `tools/` y `tests/` quedó limpio.

## 1. Lo que corrige de la premisa escrita en REQ-024

`CA-07 (i)` y el punto 5 de «Qué queda sin verificar» razonan sobre esta premisa:

> «el manifiesto se lee hoy con `arnes_jq_file` en `hooks/guard-completado.sh:548`, dentro de las
> quality gates, que corren **después**»

Es **cierta pero incompleta**, y lo que falta invierte la conclusión. Leído en `4f51293`, la puerta
lee el manifiesto **dos** veces y la **primera** es anterior a todo lo demás:

| Orden | Ruta:línea | Qué hace | Procesos |
|---|---|---|---|
| 1 | `hooks/guard-completado.sh:20` | `. "$DIR/lib.sh"` | 0 (mismo shell) |
| 2 | `hooks/guard-completado.sh:64` | `arnes_parse_manifest` → **una** llamada a `jq` (`hooks/lib.sh:52-102`) que ya trae 10 claves | 1 `jq` |
| 3 | `hooks/guard-completado.sh:233` | `arnes_campos_req` → los cinco campos de cabecera | 0 |
| 4 | `hooks/guard-completado.sh:379-382`, `:389`, `:486-490` | la resolución de la ausencia (la clase de `CA-01`) | 0 |
| 5 | `hooks/guard-completado.sh:548` | `arnes_jq_file` de las quality gates | 1 `jq` |

La llave de activación se necesita en el paso **4**, y en el paso **2** ya hay una lectura del
manifiesto **memoizada** (`ARNES_MANIFEST_LISTO`) que ocurre **antes**. Añadir un elemento al array
de esa llamada **no añade una invocación**: `jq` se invoca una vez, con un programa más largo. La
parada tiene la misma forma: `hooks/estado-derivado.sh:41` llama a `arnes_parse_manifest_estado`
(`:390-430`), que es **una** llamada a `jq` con cinco claves.

## 2. Método (comandos exactos)

Sonda: `tests/util/sonda-procesos.sh` **reutilizada, no reescrita** (envoltorios en el `PATH`, un
registro `clave=valor`; cuenta invocaciones de binarios, no reloj).

Fixture (copia del manifiesto base del banco, `tests/escenarios/hooks/run.sh:75-83`), en `/tmp`:

- `proj/` — manifiesto **con** `{"ausencia":{"exigir_declaracion":true}}` (proyecto que **activa**).
- `proj-sin/` — el mismo manifiesto con `del(.ausencia)` (proyecto que **no activa nada**, `CA-05`).
- `proj-roto/` — `{"agentes":{,}` (manifiesto ilegible: control de fail-closed).
- `proj-tipo/` — la llave como **cadena** `"true"` en vez de booleano (control de tipo, QA-106/QA-107).
- `REQ-400.md` — cabecera con las **seis** claves del lector (`Estado`, `Sensible a seguridad`, `QA`,
  `Seguridad`, `Rigor`, `Hallazgos abiertos`): las tres versiones deciden **ALLOW**, así que el
  camino medido es el **mismo** de punta a punta.
- `REQ-300.md` — **sin** `QA:` (un campo de la clase que hoy abre).
- Entrada: el `Edit` que cierra el REQ, con la misma forma que `json47` de
  `tests/escenarios/hooks/secciones/37-coste-del-escaner-5-el-camino-normal.sh:139`.

Árboles comparados (copias de `hooks/` de `4f51293`):

- **`base`** — sin tocar.
- **`protoA`** — la llave **plegada** en la llamada a `jq` que ya existe, más un consumidor con
  `case` y expansión de parámetros (0 forks).
- **`protoB`** — la misma llave leída con una llamada a `jq` **propia** en el camino de evaluación
  (la forma ingenua; es el **control discriminante**: si la sonda no la ve, no está midiendo).
- **`protoC`** — activación **sin manifiesto**: la exigencia alcanza al REQ que ya declara al menos
  un campo de la clase (candidato (c) del ADR).

Medición (una invocación por combinación; el conteo de procesos no tiene ruido, se repitió **3**
vueltas y salió idéntico):

```sh
tests/util/sonda-procesos.sh --dir-trabajo "$SC" --etiqueta "$ETIQ" \
  --sujeto "CLAUDE_PROJECT_DIR='$SC/$ARBOL' bash '$SC/$VERSION/hooks/guard-completado.sh' < '$SC/$JSON'"
# y para la parada:
tests/util/sonda-procesos.sh --dir-trabajo "$SC" --etiqueta parada \
  --sujeto "CLAUDE_PROJECT_DIR='$SC/proj' bash '$SC/$VERSION/hooks/stop.sh' < '$SC/stop.json'"
# el conteo restringido a jq añade: --binarios jq
```

El prototipo `protoA` es literalmente esto (dos hunks en `hooks/lib.sh`):

```diff
@@ arnes_parse_manifest (hooks/lib.sh:82) @@
                                        (if $m.veredictos.caducan_con_codigo == true then "true" else "false" end),
+                                       (if $m.ausencia.exigir_declaracion == true then "true" else "false" end),
                                        (if $m.git.activo == false then "false" else "true" end),
@@ el bloque de lectura (hooks/lib.sh:135) @@
     IFS= read -r ARNES_VER_FECHA;     IFS= read -r ARNES_VER_CADUCAN
+    IFS= read -r ARNES_AUS_EXIGE
```

más el equivalente en `hooks/estado-derivado.sh:404` y `:423` para la parada, y en
`hooks/guard-completado.sh`, justo antes de la rama de veredictos, el consumidor:

```sh
if [ "${ARNES_AUS_EXIGE:-false}" = "true" ]; then
  for _campo in QA Seguridad "Hallazgos abiertos" "Sensible a seguridad" Rigor; do
    case "$_campo" in QA) _v="$qa" ;; Seguridad) _v="$seg" ;; "Hallazgos abiertos") _v="$ARNES_HALL" ;;
      "Sensible a seguridad") _v="$sens" ;; Rigor) _v="$rigor" ;; esac
    [ -n "$_v" ] || arnes_deny "ARNES: no se puede completar '$rel': falta el campo '$_campo:' en la cabecera."
  done
fi
```

## 3. Lo medido

**Procesos por evaluación de la puerta** (mismo fixture, misma decisión ALLOW en las cuatro filas;
3 vueltas, valores idénticos):

| Versión | Camino | Todos los binarios | Sólo `jq` | Añadidos |
|---|---|---|---|---|
| `base` | `proj` / REQ-400 (ALLOW) | **5** | **4** | — (línea base) |
| `protoA` (plegada) | `proj` / REQ-400 (ALLOW) | **5** | **4** | **0** |
| `protoB` (jq propio) | `proj` / REQ-400 (ALLOW) | **6** | **5** | **+1** |
| `protoC` (sin manifiesto) | `proj` / REQ-400 (ALLOW) | **5** | **4** | **0** |
| `base` | `proj-sin` / REQ-400 (ALLOW) | **5** | — | — |
| `protoA` | `proj-sin` / REQ-400 (ALLOW) | **5** | — | **0** |

**Procesos por parada** (`stop.sh`, mismo fixture; 3 vueltas idénticas):

| Versión | Procesos | Añadidos |
|---|---|---|
| `base` | **7** | — |
| `protoA` (llave plegada también en `arnes_parse_manifest_estado`) | **7** | **0** |

**El control discriminante vale:** la sonda **sí** ve un `fork` de más —`protoB` da 6 frente a 5, y
5 frente a 4 contando sólo `jq`—, así que el `0` de `protoA` no es la ceguera del instrumento. Sobre
el camino de **denegación** (REQ-300, donde las dos versiones deciden igual entre sí) la diferencia
se reproduce: `protoA` 4, `protoB` 5.

**Y la decisión es la que los criterios piden** (control positivo, negativo y de equivalencia, misma
corrida):

| Versión | `proj` (activado) REQ-400 | `proj` REQ-300 (sin `QA:`) | `proj-sin` REQ-400 | `proj-sin` REQ-300 |
|---|---|---|---|---|
| `base` | ALLOW | **ALLOW** (el defecto de hoy) | ALLOW | **ALLOW** |
| `protoA` | ALLOW | **DENY**, y el motivo **nombra** `'QA:'` | ALLOW | **ALLOW** (idéntico a la heredada) |
| `protoC` | ALLOW | DENY | ALLOW | **DENY** ← no conserva la conducta heredada |

## 4. Los otros dos candidatos: también son 0 procesos, y los dos chocan con `CA-05`

Los tres candidatos que `REQ-024` («Decisiones delegadas», punto 1) deja al ADR:

| Candidato | Procesos añadidos | Veredicto |
|---|---|---|
| (a) **llave de manifiesto**, plegada en la lectura existente | **0** (medido) | **Conforme.** Conserva la conducta heredada cuando la llave no está (medido: `proj-sin` decide idéntico a `base`) |
| (b) defecto que cambia con la versión + ventana | **0** por construcción (una constante en el código, ninguna lectura nueva) | **No conforme en 1.34.0:** cambia el defecto, y `CA-05` lo prohíbe en esta versión |
| (c) exigencia sólo sobre los REQ que ya declaran algún campo de la clase | **0** (medido, `protoC`) | **No conforme por sí solo:** medido, `protoC` **DENIEGA** REQ-300 también en el proyecto **sin migrar** — un proyecto que no hace nada **sí nota** el cambio, contra `CA-05` |

Es decir: el candidato barato en procesos y el candidato conforme con `CA-05` son **el mismo**, y es
el que el analista tenía por más probable y por más caro. La tensión de `CA-07 (i)` **se disuelve**;
no hace falta la salida contratada («es hallazgo contra el diseño y el ADR vuelve al analista»).

## 5. Que ahorre el proceso no basta: lo que se comprobó para que no apague una puerta

La lección de 1.25.0 (`AGENTS.md` §13) es que ahorrar un proceso con un filtro **apagó dos
guardianes**. Aquí el ahorro **no filtra nada**: no evita ninguna llamada, sólo alarga el programa de
una llamada que ya era obligatoria e incondicional. Comprobado, en el mismo fixture:

- **La lectura sigue siendo incondicional.** `arnes_parse_manifest` corre en `:64` para
  `Edit`/`Write`/`MultiEdit` y en `:51` para la vía `Bash` que excede el presupuesto de análisis.
  El único camino que no la paga es el `Bash` que no escribe nada, que tampoco juzga cabeceras.
- **El fail-closed del manifiesto ilegible sigue en pie:** con `proj-roto`, `base` y `protoA`
  responden **DENY** las dos, con el mismo aviso. Añadir la clave no crea un camino que atraviese
  `arnes_deny_manifiesto_roto` (`:67`).
- **Premisa que el implementador NO puede olvidar, y que el prototipo dejó abierta a propósito:**
  con la llave escrita como **cadena** `"true"` en vez de booleano, `protoA` cae a
  **no-activado y ALLOW sin decir nada** (medido en `proj-tipo`: ni aviso por `stderr`). Es
  exactamente la clase QA-106/QA-107 que `hooks/lib.sh:64-71` documenta. El arreglo cuesta **0
  procesos** —añadir la clave a la lista de tipos del **mismo** programa `jq`, la que emite el
  `arnes_warn` por clave con tipo equivocado—, pero hay que escribirlo: sin eso, la activación se
  puede apagar con una errata y en silencio.

## 6. Qué quedó sin medir

1. **El banco completo contra el prototipo: no se corrió** (instrucción del encargo; cifra verificada
   del árbol limpio: `920 PASS · 0 FAIL · 4 SKIP`, `rc=0`, 924). Esta medición acredita el **coste en
   procesos** y las decisiones del **fixture**, no la no-regresión de las 50 secciones.
2. **`CA-07 (ii)`, el reloj de la ruta crítica (`≤ 1,25×`): no medido**, por instrucción (hay una
   auditoría corriendo en el árbol y una medición de reloj se contaminaría). Sigue siendo, como dice
   el propio REQ, el número más expuesto de los cuatro.
3. **`CA-07 (iii)` y `(iv)`, los cocientes de duplicación del lector de la cola: no medidos.** Este
   documento sólo responde `(i)`, y sólo por la vía de **activación**.
4. **Plataforma: sólo Linux.** El conteo de procesos es una magnitud portable —lo que cambia entre
   plataformas es el **precio** de cada `fork`, no cuántos hay—, pero el prototipo no se ha ejercido
   en Windows/MSYS.
5. **El consumidor medido es un prototipo, no el diseño de `CA-02`.** La tabla del **sitio único**
   —que los dos sitios de hoy (`hooks/guard-completado.sh` y `hooks/lib.sh`) **deriven** de ella, y no
   una tercera transcripción— no está construida. Lo medido es que **consultarla desde los dos sitios
   cuesta 0 forks**, que es la premisa que `CA-02` declaraba «verificada por cota».
6. **`Estado` y el rigor efectivo no se ejercieron campo a campo.** El prototipo exige los cinco
   campos que `arnes_campos_req` devuelve; qué dirección —gobernar o denegar— corresponde a cada uno
   sigue siendo la decisión del **ADR de la dirección de la ausencia**, y no se toca aquí.
7. **Los prototipos viven en `/tmp` y no sobreviven a la sesión.** Lo que permite reconstruirlos son
   los tres hunks de §2 y los comandos de medición; no hay rama ni parche guardado.
