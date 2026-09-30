# ADR-015 — Una edición de `requirements/` que la puerta no puede reconstruir se deniega; supersede la premisa «un `Edit` cuyo `old_string` no está literal falla y no escribe nada»
Fecha: 2026-09-30
Estado: aceptada; superada **en parte** por [ADR-016](ADR-016-identidad-del-destino-y-archivo-ilegible.md) (2026-09-30), sólo en la consecuencia «(=)» sobre el archivo que no se puede leer entero (SEC-002). La decisión de este ADR no cambia.

## Contexto
**La decisión que se supersede.** REQ-001 (2026-09-05) hizo que `guard-completado` reconstruyera el
documento resultante de un `Edit`/`MultiEdit` y dejó, **como respaldo**, el análisis del fragmento
cuando la reconstrucción no era posible porque el `old_string` no estaba literal en el archivo:
- REQ-001 **CA-11** contrató ALLOW para un `old_string` inexistente con `new_string` = `completado`,
  con esta premisa: «la herramienta fallará entera y no escribirá nada, así que no hay transición que
  juzgar»;
- REQ-001 **CA-10**: «el fallback sigue vivo»;
- REQ-001 **CA-12**: un `Edit` sobre una ruta inexistente «cae al análisis del fragmento y no bloquea»;
- REQ-007 **CA-46 (c)**: «no elimina el fallback».

**La premisa es falsa, medida en tres pasos:**
1. **QA-023-01** (`docs/qa/REQ-023.md`, vuelta 1, 2026-09-29): el `Edit` del CLI 2.1.284 normaliza las
   comillas tipográficas y desescapa `\uXXXX` antes de aplicar la edición. Leído en el binario y
   emulado.
2. **QA-023-02**: por esa vía la puerta deja cerrar un REQ sin ninguna puerta, a nivel de hook, en la
   candidata 1.35.0, en `713ac68`, en 1.33.2 y en `v1.34.0`. El auditor lo registró como **SEC-117**
   (`docs/seguridad/registro-seguridad.md` § R-045, §3; `instrumento`, severidad crítica,
   preexistente).
3. **Reproducción en el host real**, hecha por la coordinadora el 2026-09-29. Registro previo en
   `6c947ef` y resultado en `1c8c81c`, en la rama local `evidencia/prueba-despacho-2026-09-14`,
   carpeta `sec117-real/`. Entorno: Claude Code **2.1.285**, `claude -p`, WSL2, el `Edit` real del host
   y el `guard.sh` del candidato sin cambios. Una ejecución por caso:
   - **control positivo:** `old_string` literal → deny, y el archivo no cambia;
   - **caso sospechoso:** comillas rectas donde el archivo tiene tipográficas → el hook sale sin
     decisión, el host aplica el `Edit` —su `tool_response.oldString` muestra la normalización— y un
     REQ `critico` queda `completado` con QA y seguridad pendientes, un `contrato` abierto y la cola
     ocupada;
   - **control legítimo:** se permite y se aplica.

   **No ensayado en el host:** el escape `\uXXXX`, `MultiEdit`, el editor interactivo, Windows y otras
   versiones del CLI.

**Lo que decidió el propietario.**
- **Tercera autorización** (2026-09-29, `PENDING_APPROVAL.md` § Resueltas): reparar SEC-117 antes de
  publicar. La propiedad: «cuando el hook no puede reconstruir una edición de un REQ protegido porque no
  encuentra literalmente el texto anterior, esa incertidumbre no puede convertirse en permiso
  silencioso». Sin depender sólo de encontrar «estado: completado» en `new_string` y sin imitar la
  normalización del host.
- **Cuarta autorización** (2026-09-30, § Resueltas, decisión 6): opción (A). Se versionan esos
  contratos con este ADR, se reabre REQ-001 según §9, se adapta el banco y QA y seguridad cubren
  también REQ-001 y REQ-007.

## Decisión
**No reconstruible → deny.** Un `Edit` o `MultiEdit` sobre un archivo de `requirements_dir` que la
puerta no puede reconstruir se **deniega**, sea cual sea su `new_string`, sin buscar cadenas y sin
imitar la normalización del host. Lo reconstruible se juzga como siempre, reapertura incluida.

**La norma vive en un solo sitio: `requirements/REQ-023.md` CA-13.** Allí están la definición
comprobable de «reconstruible», el motivo, los casos, el cambio de compatibilidad y la validación en el
host. Este ADR registra la decisión y su porqué, y no la transcribe.

**Lo que supersede:** la premisa de REQ-001 CA-11 y el respaldo por fragmentos de REQ-001 CA-10 y CA-12
y de REQ-007 CA-46 (c), **dentro de `requirements_dir`**. Los cuatro se versionan con enlace a este ADR.
Se registra como ADR por `AGENTS.md` §9: cambia la decisión base de REQ-001 y la conducta sobre
ediciones que hasta ahora pasaban.

## Alternativas consideradas
- **La regla ancha sobre el fragmento no reconstruible** (denegar si la edición menciona el estado
  terminal; opción B de la decisión 6). **No:** no cumple la propiedad. Derivado leyendo, sin medirlo:
  un valor terminal escrito con `\uXXXX`, que el host desescapa, o una edición que retira la línea
  `Estado` que gobierna para que gobierne otra terminal, siguen dando permiso silencioso. El
  propietario la rechazó expresamente.
- **Emular la búsqueda del host** (normalizar comillas, desescapar…). **No:** el propietario lo excluye.
  Además, toda emulación parcial deja pasar lo que no emula y depende de la versión del CLI, que cambia
  sin aviso.
- **No reparar ahora y publicar la limitación.** **No:** el propietario lo rechazó (ficha 3, tercera
  autorización).

## Consecuencias
- (+) Una edición que la puerta no puede medir ya no recibe permiso silencioso. Por construcción cubre
  también dos cosas que QA observó:
  - la línea `Estado:` entera pero decorada, con punto final o entre comillas invertidas (O-2), que ya
    no es reconstruible;
  - la creación por `Edit` con `old_string` vacío (O-3), que se juzga entera, como un `Write`.
- (−) **Compatibilidad:** un `Edit`/`MultiEdit` no literal dentro de `requirements_dir` se deniega
  aunque no toque el estado. Vale también al reabrir y en archivos que no son REQ, como
  `requirements/README.md`.
  - *Mitigación:* el motivo dice qué edición falló y enseña su `old_string` escapado, para copiarlo
    literal del archivo.
  - Queda declarado en REQ-023 CA-13, en la guía de actualización y en las notas de la versión.
- (−) **REQ-001 se reabre** (§9, `en-revisión`): se versionan CA-10, CA-11 y CA-12, y sus firmas
  anteriores cubren sólo el contrato anterior al 2026-09-30. También se versiona **REQ-007 CA-46 (c)**.
- (−) **El banco se adapta**, sin retirar casos para obtener verde, según la cuarta autorización:
  - los casos que fabrican un `old_string` no literal sobre `requirements/` y miden otra puerta pasan a
    ediciones literales;
  - los que miden la reconstrucción fallida la conservan y comprueban la denegación nueva;
  - ninguno pasa a deny en bloque.
- (=) No cambian `Write`, la vía de `Bash`, el presupuesto de reconstrucción, los bytes de control ni el
  archivo que no se puede leer entero (SEC-002).
  *(Superado el 2026-09-30 por ADR-016 en lo del archivo que no se puede leer entero: un `Edit`/`MultiEdit`
  sobre él se deniega, y la norma vive en REQ-007 CA-45. El texto de arriba se conserva.)*
- (=) Este ADR no afirma que la reparación esté verificada. Eso lo acreditan QA, seguridad y la
  validación en el host que exige REQ-023 CA-13 (vii), cada uno en su sede.
