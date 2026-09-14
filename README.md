# Evidencia — prueba funcional de la vía proporcional (2026-09-14)

**Rama de evidencia, huérfana, separada del candidato.** No contiene el candidato: el plugin
probado es `rel/via-proporcional @ b3efa23`, cargado desde una copia `git archive b3efa23` con
`--plugin-dir`. Ningún credencial ni archivo global de autenticación: los listados `antes/despues.tsv`
están filtrados (`credential|token|auth|keychain|.key`) y las salidas se escanearon sin coincidencias.

## Qué hay
- `diagnostico-carga/` — la sesión mínima que acreditó la carga exclusiva del candidato (`init` con un
  solo plugin, `path=…/plugin-b3efa23`, `1 enabled, 0 disabled`).
- `sonda-escrituras/` — la sonda previa: escritura dentro del cwd creada, fuera **denegada por permisos**.
- `proyectos-base/` — los dos proyectos temporales tal como arrancó cada caso (CON = plantilla del
  candidato, declara la vía; SIN = plantilla de `f387b1c`, no la declara). Manifiesto real → hooks activos.
- `casos/<caso>/` — `prompt.txt` (sólo la tarea; sin nombrar agentes ni la regla), `salida.jsonl`
  (stream-json completo), `rc.txt`, `fin.txt`, `diff-vs-base.patch`, `estado-final/`.
- `casos/analisis.txt`, `casos/atribucion.txt` — despachos y write-back atribuidos por `parent_tool_use_id`.

## Flags de cada sesión
Ver `casos/flags.txt`: `--plugin-dir … --setting-sources project,local --strict-mcp-config
--tools Read,Edit,Write,Glob,Grep,Agent --permission-mode acceptEdits --max-budget-usd 8
--output-format stream-json --verbose`. Seis sesiones en paralelo, cada una sobre copia fresca de su base.

## Resultado (esperado según la política acordada · observado)
| Caso | Esperado | Observado | |
|---|---|---|---|
| CON-1 ordinaria | dev → QA sin analista; write-back del dev | `desarrollador → qa-tester`; write-back por el desarrollador | ✔ |
| CON-2 dinero, REQ estandar | dev → QA → seguridad | `desarrollador → qa-tester`; seguridad **no entró** (QA no aprobó); REQ quedó `estandar`/`Sensible: no`/`Seguridad: n/a`: **nadie subió el rigor** | parcial — `I-2`/`SEC-094` en la cabecera |
| CON-3 REQ nuevo | analista primero | `analista → desarrollador → qa-tester`; REQ-003 `critico`/`sí`/`Seguridad: pendiente` | ✔ |
| SIN-1 ordinaria | analista hace el write-back | `analista → qa-tester`; write-back por el analista | ✔ |
| SIN-2 dinero | procedimiento anterior | `analista → desarrollador → qa-tester`; **el analista subió el rigor a `critico`**; `bloqueado` + PENDING | ✔ (contraste con CON-2) |
| SIN-3 REQ nuevo | analista primero | `analista`; REQ-003 `borrador`, `critico`/`sí`; gate humano | ✔ |

## Limitaciones — leer antes de usar esto
1. **Sin `Bash`, QA no pudo ejecutar pruebas** (CON-1, CON-2, CON-3, SIN-2 lo declaran: «sin herramienta
   Bash»). Es un artefacto de la restricción del arnés de prueba, no de la política; detuvo la cadena
   antes del auditor en CON-2 y CON-3. Esos veredictos de QA **no acreditan ni desacreditan** la vía.
2. La coordinadora es la sesión `-p` con las instrucciones del proyecto temporal, **no** una coordinadora
   consumidora real. Los agentes **sí** son los del candidato (carga acreditada).
3. `Bash`: 0 intentos en las seis sesiones. Denegaciones reales de hooks sobre `Edit`/`Write`: 0. Los
   recuentos anteriores que decían lo contrario eran un detector casando texto de `Read`.
4. Única escritura fuera de un proyecto: el scratchpad por sesión del CLI (`/tmp/claude-1000/…/scratchpad/`).
5. Efectos en `~/.claude`: `.claude.json` reescrito por sesión (backups), `file-history/`, transcripciones,
   `known_marketplaces.json` (`lastUpdated`), `policy-limits.json`, `remote-settings.json`. Intactos: los seis
   worktrees, el candidato, `enabledPlugins` y el caché del estable.

## Coste
6 sesiones · 21,38 USD · 84 min 59 s de agente · 25 min de pared (14:44:43Z → 15:09:54Z).

---

# Adenda 2026-09-14 (tarde) — CON-2 repetido en entorno aislado con `Bash` y runtime real

## Entorno (`entorno-aislado/`)
- **Runtime:** Node `v24.21.0` LTS, tarball oficial de nodejs.org, instalado **sólo** bajo el directorio de ensayo
  (sin PATH global, sin sudo). Integridad por **tres vías**: `sha256` contra `SHASUMS256.txt` oficial (TLS);
  `gpg: Good signature` del releaser con la clave obtenida por su ID desde `keys.openpgp.org` a un `GNUPGHOME`
  temporal; y **huella `5BE8A3F6…D356` presente en la lista oficial de release keys** del README de Node
  (`release-key-en-README-oficial.txt`). El anillo de claves del usuario no se tocó.
- **El sandbox propio del CLI no se activó** ni por `--settings` ni por `.claude/settings.json` del proyecto
  (`node` seguía pidiendo aprobación; el debug no lo menciona). Motivo no determinado. Sondas en `sondas/`.
- **Aislamiento efectivo: `bwrap`** (`bwrap-endurecido.txt`): `/` de sólo lectura; escribibles **sólo** el
  proyecto, el scratchpad del CLI (`/tmp/claude-1000`), `~/.claude.json` y los directorios de contabilidad
  de `~/.claude` (`projects`, `file-history`, `shell-snapshots`, `backups`); **tmpfs sobre `~/.claude`** para
  que cualquier archivo nuevo ahí sea efímero; `~/.claude/plugins` y `settings.json` de sólo lectura; `/tmp`
  en tmpfs; `node` y la copia del candidato de sólo lectura. **Verificado** con `touch` directo y con una
  sonda del CLI: worktrees y plugin estable → `EROFS`; `./dentro.txt` → creado; `node` → ejecuta;
  `~/.claude/CLAUDE.md-PRUEBA` → no existe fuera tras salir. `Bash` habilitado con `--allowedTools Bash`
  **dentro** de ese bwrap; sin `--dangerously-skip-permissions`.

## CON-2b (`casos/CON-2b/`) — mismo candidato `b3efa23`, misma base, mismo prompt
| Pregunta | Observado | Evidencia |
|---|---|---|
| ¿QA termina? | **Sí.** Ejecutó `node --test` (5/5 del desarrollador en verde) y siguió probando: encontró un **defecto real de redondeo** (`11×0.015×100 = 16.4999…` → subfactura un céntimo en 2 030 de 20 000 montos), abrió `QA-2026-09-14-01` clase **`usuario/dinero`**, añadió una regresión roja (6 pruebas, 1 fallo) y firmó `QA: con-hallazgos` | `docs/qa/REQ-002.md` (222 líneas), 22 comandos `Bash` todos dentro del proyecto |
| ¿Entra seguridad? | **No se despachó.** Coordinadora y QA clasificaron la vía como **fila 3** («toca dinero → `desarrollador → QA → auditor-seguridad`») y **se detuvieron en QA `con-hallazgos`**: §6 no deja que seguridad firme lo que QA no validó. La coordinadora escaló a `PENDING_APPROVAL.md` y dejó escrito que tras el arreglo sigue «QA → auditor-seguridad» | `analisis.txt`, `PENDING_APPROVAL.md` |
| ¿Quién corrige rigor, sensibilidad y exigencia de seguridad? | **Nadie.** Cabecera final: `Rigor: estandar` · `Sensible a seguridad: no` · `Seguridad: n/a`. El desarrollador reescribió `Sensible: no`; QA escribió **`Seguridad: n/a`** en la misma entrega en que su log dice «fila 3 → `critico`». Ningún rol de la cadena tiene la facultad: el auditor sube el rigor y el analista fija la sensibilidad, y ninguno estaba | ediciones de cabecera atribuidas por `parent_tool_use_id` en `analisis.txt` |
| ¿Se intenta cerrar antes de resolver esas obligaciones? | **No.** La única coincidencia con «`Estado: completado`» es la fila del Historial que describe la transición ya hecha («completado → en-revisión»). `guard-completado` **no denegó nada**; la cabecera nunca valió `completado` | `analisis.txt`; recuento de denegaciones reales = 0 |

**Lectura contra la política acordada:** la vía se **clasifica** bien (fila 2 y fila 3, manda la más restrictiva)
y la cadena se detiene donde debe; pero **el contrato del REQ no adquiere la obligación de seguridad** —
`I-2`/`SEC-094` reproducidos **en ejecución real**, no en lectura—. En SIN-2, con analista, el rigor sí subió a
`critico`. La diferencia entre las dos corridas es exactamente el rol que la vía retira.

**Coste:** 3,85 USD · 12 min 52 s · 25 turnos. **Efectos:** worktrees, candidato y plugin estable intactos;
`~/.claude/session-env` apareció a las 15:59Z, **antes** de CON-2b, durante las sondas sin bwrap (contabilidad
del CLI); `latest` en el proyecto es el symlink que `--debug-file` crea hacia `debug.log`.
