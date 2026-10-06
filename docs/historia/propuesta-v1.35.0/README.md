# Historia — `propuesta-v1.35.0/` (movida aquí el 2026-10-06)

Estos dos archivos vivían en la raíz del repositorio, en `propuesta-v1.35.0/`, durante la ventana 1.35.0:

- `TRASPASO.md` — el traspaso de la sesión del 2026-10-03 (estado, decisiones, trabajo sin comitear, fuentes por sección).
- `plan-implementacion.md` — el plan de implementación de la novena autorización, que quedó **incompleto y nunca autorizó implementación** (le faltan §3 y §7).

Se movieron con `git mv` en el paso 7 (cierre) de 1.36.0, por el plan de versión del propietario («limpieza de `propuesta-v1.35.0/` a `docs/historia` o evidencia»). **No se reescribieron.** Las citas a la ruta antigua en `CHANGELOG.md`, `docs/ESTADO.md` (bloques de historia), `PENDING_APPROVAL.md`, `docs/qa/REQ-023.md`, `docs/seguridad/registro-seguridad.md` y `docs/arnes/v1.35.0-propuesta-sec-047.md` son registros históricos y conservan la ruta de entonces a propósito.

Los otros archivos que ese directorio tuvo (`README`, `SEC-047.diff`, `evidencia/`, las sondas) estaban sin seguimiento en git y ya no están en el disco; la propuesta histórica de SEC-047 sigue en `docs/arnes/v1.35.0-propuesta-sec-047.{md,diff}` y `-humo.txt`.
