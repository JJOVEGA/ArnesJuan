# QA-023-09 en el host real, DESPUÉS de la reparación de la sexta autorización. REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-10-01)

**Motivo.** La sexta autorización (`PENDING_APPROVAL.md` § Resueltas, `fb6eaab`), punto 2, pide: «Reutiliza el caso del host real. No presentes su denegación anterior por ruta irresoluble como protección acreditada ni extiendas las conclusiones a hosts no ensayados.» El caso es `cwd-nl` de `sec119-v3b` (`7a3cb6e`). Con el hook de `43b948a`, el `cwd` llegó con el salto de línea literal, y el hook juzgó `'y'` en lugar de la ruta canónica. Denegó por «no se pudo determinar a que archivo escribe 'y'», y **esa denegación no acredita nada**. La ejecuta la coordinadora; no es una medición de QA.

**Entorno.** Claude Code 2.1.285, `claude -p`, WSL2, uid 1000. La misma sonda que en `sec119-v3b` (`plugin-sonda`, que pasa la entrada sin cambios al `guard.sh` del worktree). `--setting-sources project`, así que el plugin 1.33.2 no se carga. Hook: el del commit `cd6afa6` con la reparación del desarrollador, sha256 de 16 hex: `guard-completado.sh` `743469771cc85be1`, `lib.sh` `12d4762fadc84710`, `guard-codigo.sh` `8da615c2f778f591`, `guard.sh` `2e7ec8cb189d025c`. Proyecto temporal: el mismo de v3b (manifiesto con `src/*` como código, cola ocupada, REQ-900 `critico` en rojo con sha256 `2a19ec48a860d1df…`).

| Caso | Pasos, en la misma sesión | Qué decide la reparación | Esperado |
|---|---|---|---|
| **r6-req** (el caso `cwd-nl` de v3b, reutilizado) | `Bash` que crea y entra en un directorio cuyo nombre lleva un salto de línea; `Read`; `Write` por la ruta canónica que cierra el REQ en rojo | si el hook juzga la **ruta canónica** | **deny por el motivo propio del REQ** (QA pendiente), con un motivo que **no** cita un fragmento del `cwd`; REQ sin cambio |
| **r6-codigo** (la otra puerta) | el mismo `Bash`; `Write` de la coordinadora a `<proj>/src/a.ts` | ídem, en `guard-codigo` | deny que cita `src/a.ts` como código de la app; `src/a.ts` no se crea |
| **r6-fuera** (control legítimo) | el mismo `Bash`; `Write` a `<proj>/docs/nota-r6.md`, fuera del ámbito protegido | que la reparación no deniegue lo legítimo | allow; `docs/nota-r6.md` creado |

**Qué se observa, por separado:**
- lo que recibe el hook: `logs/pre-*-in.json`, sobre todo `cwd` y `tool_input.file_path`;
- la decisión y su motivo: `pre-*-out.json`;
- el tratamiento del host: `stream.jsonl`;
- el disco: `sha-antes.txt` y `sha-despues.txt`, y `arbol-despues.txt`.

Una ejecución por caso, los tres a la vez; sin repeticiones. **Fallo de instrumentación:** que el `cwd` de la entrada del `Write` no lleve el salto de línea (el caso no ejercería nada), o que el modelo no siga los pasos.

**Sin «antes» en el host para r6-codigo y r6-fuera.** Lo que el hook de `43b948a` habría decidido en esos dos casos se deduce del mecanismo, pero no se ejecuta en el host. Su fail-before es a nivel de hook, en el banco.

**No se extiende a:** Windows, el editor interactivo, `MultiEdit` (no expuesta en la 2.1.285), otras versiones del CLI, otros caracteres de control ni otros nombres de directorio.
