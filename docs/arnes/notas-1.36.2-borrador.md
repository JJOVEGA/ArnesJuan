## [1.36.2] — 2026-10-16 · Hotfix mínimo: el manifiesto `.arnes/config.json` no se borra, no se mueve y no se vacía por las formas llanas de `Bash` ni por un `Write` sin contenido, y mover un archivo protegido cuenta como escribirlo; SEC-135 a SEC-138 declarados con su versión de reparación

> Origen: borrador del `analista-requerimientos` (REQ-033) · agentes: `analista-requerimientos` y `qa-tester` en Sonnet (excepción del propietario, P-137-J), `desarrollador` y `auditor-seguridad` · gobernado por la instalación estable **1.36.1**.
> **Estas notas no publican nada:** la fusión, el tag y la publicación son del propietario.

**Qué cambia** (REQ-033, CA-01 y CA-02). Antes, con 1.36.1, `rm`, `mv` y `: >` sobre el manifiesto pasaban —en este repositorio, también al agente de código; en un proyecto consumidor que no lo incluye en `codigo_app.globs`, a **todo agente**—, y sin manifiesto todas las puertas quedan inertes. Ahora, a **todo agente**, el manifiesto no se puede borrar, mover ni vaciar **por las formas llanas de `Bash`** (`rm`, `unlink`, `git rm`, `mv`, `: >`, `truncate`, `cp /dev/null`, `tee`, `sed -i`; ejemplos no exhaustivos) **ni por un `Write` sin contenido**. Y el **origen** de `mv` se juzga como escritura de ese archivo. Los cinco casos medidos (v1.36.1 → 1.36.2):

| Caso | Agente | v1.36.1 | 1.36.2 |
|---|---|---|---|
| `rm .arnes/config.json` | coordinadora y agente de código | allow | deny |
| `mv .arnes/config.json x` | coordinadora y agente de código | allow | deny |
| `: > .arnes/config.json` | agente de código | allow | deny |
| `mv hooks/lib.sh docs/x.md` | coordinadora | allow | deny |
| `mv hooks/lib.sh docs/PLAN.md` | coordinadora | allow | deny |

Ningún veredicto pasa de `deny` a `allow` (R-060 §1). **No** se dice «el manifiesto no se puede borrar» a secas: lo que no cambia está debajo.

**Coste por rama** (CA-06, cifras operativas; el camino común no cambia: 0 procesos añadidos, de contrato, y 1,25× de reloj):

| Rama | Procesos añadidos | Reloj medido |
|---|---|---|
| `mv` con origen protegido | +1 | ≈ 1,11–1,19× |
| `rm` del manifiesto | +1 | ≈ 1,24× |
| `Write` del manifiesto con contenido | +1 | ≈ 1,20× |
| `Write` vacío del manifiesto | +2 | ≈ 1,22× |

Techo declarado de reloj por rama: 1,30× (máximo medido 1,26×). La sección 49 juzga todas las ramas.

**Lo que NO cambia, con su versión**
- **SEC-135** (`contrato`, severidad **alta**, preexistente; a la **pieza b de 1.37**, la puerta posterior): `cp`/`mv`/`install` con `2>/dev/null`, el comentario final, `< directorio`, `-rt`, `\cp`, `find -exec`, el subshell `(cp …)` y `xargs` escriben código protegido a quien no es el agente de código; y, de la misma familia, las **rutas entre comillas**, el `cd` dentro del comando, los **globs** y las **llaves** no se ven (QA-033-02), igual que en 1.36.1.
- **SEC-136** (`contrato`, media): `rm`, `unlink` y `git rm` de **cualquier archivo distinto del manifiesto** siguen sin juzgarse. A 1.37.
- **SEC-137** (`contrato`, media): mover el **directorio** que contiene código protegido (`mv hooks docs/h`, `git mv hooks …`) no se juzga como origen; con barra final (`mv hooks/ docs/h`) sí. A 1.37.
- **SEC-138** (`contrato`, media): el manifiesto **sigue pudiéndose dejar sin reglas por `Edit`/`Write`** con contenido (`{}`, o un `Edit` que lo vacía). En un proyecto cuyo `codigo_app.globs` **no** incluye `.arnes/config.json` —la forma que genera `arnes-init`— **cualquier agente** puede hacerlo, y el motivo del `deny` nuevo («el agente de código lo escribe con Edit/Write») no es cierto allí; corregirlo es de 1.37.
- **Recomendación para proyectos consumidores: añadir `.arnes/config.json` a `codigo_app.globs`.**
- `AGENTS.md` §13 no cambia en 1.36.2.

**Los cuatro puntos del dictamen de seguridad (R-060)**
1. El manifiesto no se puede borrar, mover ni vaciar por las formas llanas de `Bash` ni por un `Write` sin contenido, a ningún agente; no «a secas».
2. Sigue pudiéndose dejar sin reglas con `Edit`/`Write` con contenido, y en un proyecto que no lo incluye en `codigo_app.globs` lo puede hacer cualquier agente (SEC-138).
3. Las rutas entre comillas, el `cd` dentro del comando, los globs y las llaves no se ven, igual que en 1.36.1 (QA-033-02, SEC-135).
4. El origen de `mv` se juzga cuando es el archivo protegido; mover el directorio que lo contiene no (SEC-137), y `rm` de código protegido tampoco (SEC-136), a 1.37.

**Restricciones aceptadas.** Un manifiesto ya roto puede repararse (y vaciarse) por `Bash` (REQ-007 CA-60); borrarlo o moverlo sigue denegado. Sobre-denegaciones raras: `grep rm|ln|truncate .arnes/config.json` (el nombre de la orden como patrón con el manifiesto de operando) y `git rm -r --cached .`. Leer el manifiesto (`cat`, `jq`, `git diff/log/show`, `wc`) no se deniega.

**Firmas.** QA: aprobado tras **una** pasada correctiva (QA-033-01 y QA-033-02, resueltos por write-back y por la sección 49 juzgando todas las ramas). Seguridad: **`aprobado`** (R-060 y su adenda, 2026-10-16): R-060 dio «con hallazgos, sin veto»; SEC-137 y SEC-138 se resolvieron sólo con texto (este REQ y estas notas), y el auditor re-firmó sobre el mismo código (`hooks/` sin cambio desde `b8d8e46`). SEC-135 a SEC-138 quedan `instrumento` respecto de REQ-033 y abiertos en su sede, para 1.37. Lo gobierna la instalación estable **1.36.1**; la 1.36.2 no se gobierna a sí misma.
