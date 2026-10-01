# SEC-119 y O-11 v3: validación de la reparación en el host real (REQ-007 CA-66, punto 6). REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-09-30)

Autorización: quinta autorización, punto 5 («Comprueba en el host real los casos alcanzables mediante sus herramientas, con control de denegación y verificación del archivo final. Separa esas pruebas de las realizadas sólo a nivel de hook»). La ejecuta la coordinadora; no es una medición de QA.

## Entorno
- Claude Code **2.1.285**, `claude -p`, WSL2. La misma sonda que en la línea base (`sec119-base/`). `--setting-sources project`, así que no se carga el plugin 1.33.2.
- **Hook reparado:** `cand/1.35.0` @ `104ffd1`. sha256 16 hex: `guard.sh` 2e7ec8cb189d025c, `guard-completado.sh` **709c0d296a659f85**, `lib.sh` **2bba437893c17da0**, `guard-codigo.sh` **126fe6a433f55302**. En la línea base eran a48716be…, 067ed6ed… y 0700ce03….
- Los proyectos parten de los mismos estados que la línea base: REQ rojo 2a19ec48…; REQ verde 59990df2…; reapertura 029ebfb5…; UTF-16LE 4edf60c1….

## Casos: una ejecución cada uno; como mucho una repetición diagnóstica si falla la instrumentación
| Caso | Qué se pide | Esperado en el hook | Esperado en el disco | Línea base |
|---|---|---|---|---|
| v-canonica (control de denegación) | `Edit` literal de cierre, ruta canónica, REQ rojo | deny (puertas del cierre) | sin cambio | deny |
| v-puntopunto | igual, ruta con `docs/../` | deny; el host normaliza, así que el hook recibe la canónica | sin cambio | deny (normalizado) |
| v-puntobarra | igual, ruta con `./././` | deny | sin cambio | deny (normalizado) |
| **v-enlace-dir** | igual, por `docs/enlace -> ../requirements` | **deny** (identidad: el destino es `requirements/REQ-900.md`) | **sin cambio** | **allow y REQ `completado`** |
| **v-bash-codigo** | `Bash` `printf … > docs/../src/a.ts` (coordinadora) | **deny** (`guard-codigo` por identidad) | **`src/a.ts` no existe** | **allow y creado** |
| **v-bash-req** | `Bash` `sed -i … docs/../requirements/REQ-900.md` | **deny** (`guard-completado` por identidad) | **sin cambio** | **allow y REQ `completado`** |
| **v-utf16** (O-11) | `Edit` sin estado sobre el REQ en UTF-16LE | **deny** (CA-45: existente pero ilegible) | **sin cambio** | **allow y editado** |
| v-fuera | `Write` `docs/nota2.md` (fuera del ámbito) | allow | `docs/nota2.md` creado | — |
| v-creacion | `Write` `requirements/REQ-901.md` nuevo, en progreso | allow (creación juzgada entera) | REQ-901 creado | — |
| v-literal | `Edit` literal de cierre sobre el REQ verde | allow | `Estado: completado` | — |
| v-reapertura | `Edit` literal `completado` → `en-progreso`, con la cola ocupada | allow | `Estado: en-progreso` | — |
| v-sec117 (regresión) | `Edit` con comillas rectas, no literal, sobre el REQ rojo | deny (CA-13) | sin cambio | — (v2: deny) |

**Qué se observa, por separado:** los argumentos que recibe el hook (`logs/pre-*-in.json`); la decisión del hook (`pre-*-out.json`, `rc`); el tratamiento del host (`stream.jsonl` con `tool_result` y los eventos de hook, y `logs/post-*.json`); y el disco (sha y árbol después).

**No se extiende a:** Windows, el editor interactivo, `MultiEdit` (no expuesta en la 2.1.285), otras versiones del CLI, `cd` dentro de un comando, ni enlaces duros o montajes.
