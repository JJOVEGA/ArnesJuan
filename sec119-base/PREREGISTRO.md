# SEC-119 y O-11: LÍNEA BASE en el host real con el hook actual, ANTES de reparar. REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-09-30)

Autorización: `PENDING_APPROVAL.md` § Resueltas, quinta autorización, punto 2, que pide distinguir «lo que recibe realmente el hook desde el host», «lo que sólo se ha inyectado directamente al hook» y «la ruta utilizada finalmente por la herramienta». La ejecuta la coordinadora; no es una medición de QA. Hasta hoy, SEC-119 y O-11 sólo estaban medidos **inyectando** JSON al hook (QA y R-045-A).

## Entorno
- **Host:** WSL2 Linux 6.18.33.2; bash 5.3.9; jq 1.8.2. **Claude Code 2.1.285**, `claude -p`.
- **Aislamiento:** `--setting-sources project`, así que el plugin 1.33.2 no se carga. `--plugin-dir plugin-sonda`, la misma sonda de `sec117-real/` (`sonda-pre.sh` 80b6ec83534e81da, `sonda-post.sh` f34a33d484d3e728). Herramientas permitidas: `Read,Edit`, salvo en los casos h4, que usan sólo `Write`.
- **Hook:** el `guard.sh` del candidato en `1ebe1c1`, con el código de hooks de `9596e39` **sin la reparación**. sha256 16 hex: `guard-completado.sh` a48716bedc919e48, `lib.sh` 067ed6edd983096b, `guard-codigo.sh` 0700ce03a9e37f7c.
- **Sesión:** la principal del CLI, sin `agent_type`, así que el hook la trata como la coordinadora. Para `guard-codigo`, eso significa que no puede escribir en `src/`.

## Casos: una ejecución cada uno, como mucho una repetición diagnóstica
| Caso | Ruta pedida en `file_path` | Operación | Si SEC-119 es alcanzable desde el host | Si el host normaliza la ruta antes del hook |
|---|---|---|---|---|
| h0-control-req | `<proj>/requirements/REQ-900.md` (canónica) | `Edit` literal que cierra el REQ en rojo (QA y seguridad pendientes, `contrato`, cola ocupada) | deny (control de las puertas) | deny |
| h1-puntopunto | `<proj>/docs/../requirements/REQ-900.md` | igual | **allow** → el REQ queda `completado` | deny |
| h2-puntobarra | `<proj>/./././requirements/REQ-900.md` | igual | **allow** | deny |
| h3-enlace-dir | `<proj>/docs/enlace/REQ-900.md`, con `docs/enlace -> ../requirements` | igual | **allow** | deny si el host resuelve el enlace; allow si no |
| h4c-control-codigo | `<proj>/src/a.ts` (canónica) | `Write` de la coordinadora | deny (control de `guard-codigo`) | deny |
| h4-codigo-puntopunto | `<proj>/docs/../src/a.ts` | `Write` de la coordinadora | **allow** → se crea `src/a.ts` | deny |
| h5-utf16 (O-11) | `<proj>/requirements/REQ-900.md`, REQ en verde en **UTF-16LE con BOM** (el hook lo lee como ilegible, porque tiene NUL) | `Edit` sin tocar el estado: `Prioridad: alta` → `Prioridad: media` | hoy el hook permite (regla ancha: no menciona el terminal) | — |

**Qué responde h5:** si la herramienta **puede escribir** un archivo que el hook **no puede leer**. Es la relación que el propietario pide no suponer. Hay dos resultados posibles: el `Edit` se aplica, o el host lo rechaza (por codificación, o porque el `old_string` no se encuentra).

## Qué se observa, por separado
1. **Lo que recibe realmente el hook desde el host:** `logs/pre-*-in.json`, sobre todo `tool_input.file_path`, literal.
2. **La decisión del hook:** `pre-*-out.json` y `pre-*-rc.txt`.
3. **El tratamiento del host y la ruta que usó finalmente la herramienta:** `stream.jsonl` (el `tool_result` y los eventos de hook) y `logs/post-*.json` (`tool_response.filePath`).
4. **El disco:** `REQ-900-despues.md`, `sha-despues.txt` frente a `sha-antes.txt`, y `src-despues.txt`.

**Fallo de instrumentación:** que el modelo normalice por su cuenta la ruta pedida. Se ve en `pre-*-in.json`.

**No se extiende a:** Windows, el editor interactivo, `MultiEdit` (no expuesta en la 2.1.285) ni otras versiones del CLI.

## Adenda, antes de ejecutarla: dos casos por `Bash` (2026-09-30)
En los siete primeros casos el host 2.1.285 **normalizó** las rutas con `..` y `././` antes del hook, pero **no** resolvió el directorio enlazado. Un comando de `Bash` es texto que el host no normaliza como ruta, así que se añaden dos casos, con `--allowedTools Bash` y el resto de herramientas prohibidas:

| Caso | Comando | Si es alcanzable desde el host | Si el hook lo juzgara por el destino |
|---|---|---|---|
| h6-bash-codigo | `printf 'prueba\n' > docs/../src/a.ts` (coordinadora) | allow → se crea `src/a.ts` | deny (`guard-codigo`) |
| h7-bash-req | `sed -i 's/^Estado: en-revisión (tras “R-4”)$/Estado: completado/' docs/../requirements/REQ-900.md` | allow → el REQ en rojo queda `completado` | deny (`guard-completado` desvía a `Edit`/`Write` el cierre por shell) |

Se observa lo mismo que en los otros casos: `logs/pre-*-in.json` (`tool_input.command`), la decisión, el `tool_result` y el disco.
