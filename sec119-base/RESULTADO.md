# SEC-119 y O-11: resultado de la LÍNEA BASE en el host real con el hook sin reparar (2026-09-30; registros previos `794d50b` y `b4c7e18`)

Claude Code **2.1.285**, `claude -p`, WSL2. Hook del candidato con el código de `9596e39`, sin reparar. Una ejecución por caso, sin repeticiones. En los nueve `init`, el plugin 1.33.2 no se cargó.

| Caso | Lo que envió el modelo (`tool_use`) | **Lo que recibió el hook del host** | Decisión del hook | Herramienta y disco |
|---|---|---|---|---|
| h0-control-req | `Edit` `<proj>/requirements/REQ-900.md` | la misma | deny (QA pendiente) | bloqueado; REQ sin cambio |
| h1-puntopunto | `Edit` `<proj>/docs/../requirements/REQ-900.md` | **`<proj>/requirements/REQ-900.md`: el host normalizó** | deny | bloqueado; sin cambio |
| h2-puntobarra | `Edit` `<proj>/./././requirements/REQ-900.md` | **`<proj>/requirements/REQ-900.md`: el host normalizó** | deny | bloqueado; sin cambio |
| **h3-enlace-dir** | `Edit` `<proj>/docs/enlace/REQ-900.md` (`docs/enlace -> ../requirements`) | **la misma, sin resolver el enlace** | **sin decisión (allow)** | **aplicado: el REQ `critico` con QA y Seguridad `pendiente`, `contrato` y cola ocupada queda `Estado: completado`** |
| h4c-control-codigo | `Write` `<proj>/src/a.ts` | la misma | deny (`guard-codigo`) | bloqueado |
| h4-codigo-puntopunto | `Write` `<proj>/docs/../src/a.ts` | **`<proj>/src/a.ts`: el host normalizó** | deny | bloqueado |
| **h5-utf16** (O-11) | `Edit` `Prioridad: alta` → `media` sobre un REQ en UTF-16LE | la misma ruta | sin decisión (allow; el hook no puede leer el archivo) | **aplicado: la herramienta editó el UTF-16LE y lo conservó en UTF-16LE** |
| **h6-bash-codigo** | `Bash` `printf 'prueba\n' > docs/../src/a.ts` | **el comando literal** | **sin decisión (allow)** | **`src/a.ts` creado por la coordinadora** |
| **h7-bash-req** | `Bash` `sed -i 's/…/Estado: completado/' docs/../requirements/REQ-900.md` | **el comando literal** | **sin decisión (allow)** | **el REQ en rojo queda `Estado: completado`** |

## Conclusiones, limitadas a lo ensayado
1. **En el CLI 2.1.285, el host normaliza léxicamente el `file_path` de `Edit` y `Write`** (`..` y `./`) antes de dárselo al hook. Por `Edit` y `Write`, esas formas de SEC-119 **no se alcanzan desde el host**: sólo por inyección directa al hook (QA y R-045-A). `MultiEdit` no está expuesta.
2. **El host no resuelve los enlaces simbólicos.** SEC-119 por directorio enlazado **se alcanza desde el host**, y cierra un REQ `critico` con todo en rojo.
3. **El host no normaliza el texto de un comando de `Bash`.** SEC-119 por `..` en `Bash` **se alcanza desde el host**, en las dos puertas: código protegido creado y REQ cerrado por shell.
4. **O-11:** **la herramienta escribe un archivo que el hook no puede leer** (REQ en UTF-16LE). La relación que el propietario pidió no suponer queda **observada**: «el hook no puede leer» no implica «la herramienta no puede escribir».

**No se extiende a:** Windows, el editor interactivo, otras versiones del CLI, `MultiEdit`, `././` o `//` por `Bash` (sólo se ensayó `..`), ni otros cwd.
