## [1.36.1] — 2026-10-15 · Hotfix: un `cp`, `mv` o `install` suelto sobre un archivo existente que no está protegido vuelve a pasar —la regresión de 1.35.0, F-137-10—, con lo protegido en `deny` y el alcance del arreglo a la vista; y dos fallos en abierto preexistentes, SEC-135 (alta) y SEC-136 (media), declarados con su versión de reparación

> Origen: GitHub (commit de versión) · usuario: Juan · agentes: `analista-requerimientos`, `desarrollador`,
> `qa-tester` y `auditor-seguridad` (Opus 5.5; `qa-tester` en Opus por la decisión del propietario de `AGENTS.md`
> §5) y la coordinadora (Opus 5.5) · gobernado por la instalación estable **1.36.0**

**Estas notas no publican nada.** El propietario lo dejó escrito: «la publicación (fusión, tag v1.36.1) es mía»
(P-032-6 (3), `PENDING_APPROVAL.md` § Resueltas). **CI (`hooks-en-linux`) del PR #61:** sobre `a86a315`, cuyo
código es el aprobado por QA y seguridad, **success** (run `38818908273`: 2823 PASS, 0 FAIL, 39 SKIP, 2 de ellos
INCONCLUSO de rendimiento, que no acreditan). Antes, sobre `0f717d6`, **failure** (run `38798052406`) por un solo
caso, la sonda de reloj de REQ-017 CA-08 (ii) con 1,304× frente al techo de 1,25×: es **INS-032-1**, medido no
atribuible al cambio (más abajo), y **no se desmiente** con la corrida verde posterior. La corrida sobre la cabeza
final, que sólo añade registro y estas notas, llega con su push.

**De dónde salen.** Las decisiones del propietario están literales en `PENDING_APPROVAL.md` § Resueltas: la
autorización del hotfix (2026-10-13, P-137-H con tres ajustes), P-032-1 y P-032-2 (2026-10-14) y P-032-3 a P-032-6
(2026-10-15). El contrato vive en `requirements/REQ-032.md`, que es la sede de todo lo que sigue.

---

### Qué cambia

**El código de 1.36.1 es el de `77b71f7`.** Se construyó en `9e97bd7` (fase 1), `759ff50` y `264dfa9` (pasada
correctiva, vuelta 1) y `77b71f7` (vuelta 2), y sólo toca `hooks/lib.sh`, `hooks/guard-codigo.sh` y
`hooks/guard-completado.sh`. Es un parche: no cambia la identificación del destino (REQ-007 CA-47) ni ninguna otra
puerta.

#### La regresión que se repara (F-137-10)

**Desde 1.35.0, un `cp`, `mv` o `install` sobre un archivo existente se denegaba a quien no es el agente de
código** —la sesión coordinadora y los demás subagentes—, también con `cp -T`, aunque el archivo no estuviera
protegido. El agente de código, con su `agent_id`, pasaba. El motivo citaba la ruta **con una barra final**
(«no se pudo determinar a que archivo escribe '…/REQ-007.md/'»). La causa: el detector juzgaba siempre, además del
destino, su forma de directorio `destino/`, y desde 1.35.0 esa forma, sobre un archivo, no se puede determinar y
se deniega.

- **Medido:** 1.33.2 no la tenía; 1.35.0 y 1.36.0, sí. Las demás versiones, no medidas.
- **Efecto:** fallaba del lado cerrado —no abría permisos— y bloqueaba escrituras legítimas en todos los proyectos
  con esas versiones. La redirección (`cat S > destino`) seguía pasando.

#### El arreglo y su alcance exacto (REQ-032 CA-15)

**El arreglo sólo actúa sobre un `cp`, `mv` o `install` suelto y sin caracteres de shell** (P-032-6). En ese caso,
y sólo en ese, la puerta juzga el archivo destino y deja de juzgar la forma `destino/`. **El destino mismo se
juzga siempre.** Tienen que cumplirse **todas** estas condiciones:

1. **Una sola invocación, con la orden como primera palabra, escrita literalmente:** `cp`, `mv` o `install`.
2. **Sin caracteres de shell, sin tuberías, sin encadenar (`;`, `&&`, `||`, `&`), sin subshells, sin
   redirecciones y en una sola línea.** El comando sólo puede llevar letras y cifras ASCII, el blanco y
   `. / _ + , : @ % = -` (sede: `_arnes_cmd_llano`, `hooks/lib.sh`).
3. **Opciones sólo de una lista cerrada:** cortas `-f -i -n -p -v -r -R -a -u`, solas o agrupadas sólo con esas
   letras, y largas exactas `--force --interactive --no-clobber --verbose --recursive --archive --update` (sin
   `=`). Ninguna lleva argumento. La propuso el desarrollador y la aprobó QA.
4. **El destino es un archivo regular** —un enlace simbólico a uno cuenta como ese archivo— **con un solo enlace
   duro**.

Y, en lo construido, al menos dos operandos, con el destino como último operando.

**Las restricciones: fuera de eso, la orden sigue decidiéndose como en v1.36.0**, que sobre un archivo existente
es `deny` para quien no es el agente de código. Ejemplos **no exhaustivos**:
- con caracteres de shell: comillas, `$`, `#`, `<`, `>`, `*` o un salto de línea;
- encadenada o en tubería: `cp S docs/notas.md && echo hecho`, `cp … ; ls`, `cp … | cat`;
- con un prefijo o la ruta de la orden: `\cp`, `command cp`, `sudo`, `nice`, `env`, `timeout … cp`, `VAR=x cp`,
  `/bin/cp`;
- con `-t`, `-T`, `--`, `-` o cualquier opción fuera de la lista; en particular, **`cp -T` sigue denegándose**;
- con un nombre que lleva caracteres **no ASCII** (una tilde);
- con un destino que tiene **más de un enlace duro**, también entre dos archivos no protegidos (restricción
  aceptada por el propietario).

**La salida**, en palabras del propietario: «escribir el comando sin esos caracteres o usar una redirección
simple» (P-032-4 (B)); es decir, el `cp` suelto, o `cat S > destino`. **Las quita 1.36.2**, que leerá el destino
con la gramática de la orden.

#### El movimiento declarado (M-032), y lo que no cambia

**El único paso de `deny` a `allow`** es la clase M-032 (REQ-032 CA-09). La forman los `cp`, `mv` e `install` que
cumplen las cuatro condiciones, sobre un archivo existente **no protegido**, que v1.36.0 denegaba sólo por la
forma `destino/`. **Restituye lo que daba 1.33.2.** Sus casos, con las tres órdenes: el REQ con ruta absoluta y
relativa, un archivo de `docs/`, el mismo `cp` emitido por `qa-tester` o por `analista-requerimientos`, y un
enlace simbólico a un archivo no protegido (CA-02, F1–F3 y F6–F8).

**Lo que no cambia —lo protegido sigue en `deny`—**, en v1.36.0 y en 1.36.1:
- un archivo protegido, para quien no es el agente de código, por cualquier ruta que la identidad del destino
  reconozca: relativa, con `..`, con barras repetidas, por un directorio enlazado, o por un enlace simbólico o
  **duro** que lleva a él;
- cerrar un REQ por `cp` con el estado terminal en el comando, que se sigue derivando a `Edit`/`Write`;
- un destino que es un directorio, que se sigue juzgando como `directorio/`; un destino que no existe; y lo que no
  se puede determinar.

**Medido por seguridad** (R-059 §1): un barrido de 700 comandos llanos ejecutados de verdad no encontró **ninguna
escritura** de un archivo protegido que v1.36.0 no permitiera.

**V7, el único efecto sobre algo protegido:** `mv src/a.ts docs/notas.md` —con `docs/notas.md` existente y no
protegido— pasa de `deny` a `allow` y **retira el origen protegido** `src/a.ts`. Lo clasificó R-059 §2 como
`instrumento` respecto de REQ-032, porque:
- los **orígenes** de `mv` nunca se juzgaron: `mv src/a.ts docs/nuevo.md`, `rm src/a.ts` y `unlink src/a.ts` ya
  pasaban en 1.33.2, 1.35.0 y 1.36.0;
- **V7 mismo era `allow` en 1.33.2**, y es parte de lo que M-032 restituye;
- en v1.36.0 se llega al mismo estado con `cat src/a.ts > docs/notas.md; rm src/a.ts`.

Su raíz es SEC-136 (abajo).

#### El coste

**Un proceso (`find`), sólo en la rama del destino existente de `cp`/`mv`/`install`**, para leer el número de
enlaces. **0 procesos añadidos en el camino común.** Si `find` falta, falla o no devuelve el archivo, no se afirma
«un solo enlace» y la decisión es la de v1.36.0. Medido por QA, misma corrida:
- `ls -la` y `npm run build`: 1 frente a 1;
- `cp S docs/notas.md`: 3 frente a 3;
- enlace duro: 4 frente a 3.

Reloj frente a v1.36.0: máximo 1,077×, dentro del techo de 1,25×.

---

### Dos fallos en abierto preexistentes, declarados (no los introduce ni los empeora 1.36.1)

#### SEC-135 — `contrato` · severidad **ALTA** (R-059 §3) · se repara en **1.36.2**

**Quien no es el agente de código escribe código protegido con `cp`, `mv` o `install` escritos de formas
cotidianas.** Medido en 1.33.2, 1.35.0, 1.36.0 y 1.36.1, que no lo empeora: da la misma decisión que v1.36.0. Dos
mecanismos; ejemplos **no exhaustivos**:
- **(i) el último operando no es el destino:** `cp S src/a.ts 2>/dev/null`, `2>&1`, un comentario final
  (`cp S src/a.ts # nada`), `< directorio`, `cp -rt src docs/sub`. También crea código protegido, y vale con `mv`;
- **(ii) el detector no reconoce la orden:** `\cp S src/a.ts`, `find src -name a.ts -exec cp S {} \;` y el
  **subshell** `(cp S src/a.ts)`.

Es ALTA porque falla en abierto la garantía central de `guard-codigo` y **no exige intención**: `2>/dev/null` es de
los añadidos más habituales. **Se repara en 1.36.2**, con el contrato que fijó el propietario (P-032-6 (1)): «toda
invocación efectiva de cp/mv/install, se escriba como se escriba, se juzga por su destino real; si no se puede
determinar, deny». Incluye reconocer `\cp`, `command cp`, `(cp …)`, los subshells, `find -exec` y `xargs`. **Hasta
entonces:** no confíes en la puerta para estas formas; el efecto queda en `git status`.

#### SEC-136 — `contrato` · severidad **media** (R-059 §4) · se repara en **1.36.2** (en parte) y **1.37**

**Ninguna puerta de `Bash` juzga la retirada de un archivo protegido.** Quien no es el agente de código lo borra o
lo saca de su sitio con `rm`, `unlink`, el origen de `mv` o `git rm`. Medido en 1.33.2, 1.35.0 y 1.36.0. **Y
`rm .arnes/config.json` deja inertes todas las puertas**, porque sin manifiesto los hooks son inertes por diseño.
Es media porque el efecto es visible (`git status`, git lo devuelve si estaba comiteado), salvo esa instancia.

Por decisión del propietario (P-032-6 (2)):
- **en 1.36.2:** se juzga el origen de `mv`, se declara en `AGENTS.md` §13, y borrar, mover o vaciar
  `.arnes/config.json` se deniega a todo agente;
- **en 1.37:** `rm`, `unlink` y `git rm`, con la puerta posterior (pieza b). Con un requisito escrito: esa puerta
  no puede depender sólo del manifiesto que vigila, y si el manifiesto desaparece en un proyecto que lo tenía, eso
  mismo es un evento a denegar o revertir.

---

### Límites y hallazgos `instrumento`

- **O-59-1:** restituir 1.33.2 incluye `cp` hacia un REQ existente o hacia `PENDING_APPROVAL.md`, cuyo
  **contenido** no se juzga desde `Bash`. Un archivo que dice `Estado: completado` cierra el REQ igual que
  `cat … > …` ya lo hacía en v1.36.0 (límite de `AGENTS.md` §13: la detección lee el texto del comando; la
  respuesta es la puerta posterior).
- **O-59-2:** el número de enlaces depende del sistema de archivos. Sin medir en Windows/MSYS ni en `drvfs`/`9p`.
- **O-59-3:** `find` se toma del `PATH`, que es la frontera de confianza del entorno ya declarada (SEC-131).
- **O-59-4:** `cd src && cp ../S a.ts` y `X=src/a.ts; cp S $X` vuelven a la decisión de v1.36.0, que es `allow`
  y escribe `src/a.ts`: son de la familia de SEC-135.
- **INS-032-1, INS-032-2 e INS-032-3** (`instrumento`, no atribuibles al cambio). Son el reloj de REQ-017 CA-08
  (ii) —mediana 1,009 frente a v1.36.0— y dos sondas de REQ-021 (calibración y descendencia) que no ejecutan
  ningún hook. Van a la revisión de las sondas de 1.37.
- **PR-137-1** (proceso, `instrumento`): una línea de `hooks/lib.sh` se editó por consola en vez de con `Edit`,
  declarada por el `desarrollador`.
- **Windows/MSYS y el host, sin medir.** Todo lo medido es Linux/WSL2.

---

### Firmas

| | Resultado | Sede |
|---|---|---|
| QA | **aprobado**, vuelta 2 de 3, código `77b71f7`: QA-032-01 y QA-032-02 cerrados; banco 2849 PASS, 0 FAIL, 13 SKIP (cuadre 2862); autoprueba 117/0; gates en verde; ningún `allow` → `deny` frente a v1.36.0 | `docs/qa/REQ-032.md`, V1–V10 |
| Seguridad | **R-059, aprobado, sin veto**: el paso de `deny` a `allow` queda acotado a destinos no protegidos y declarado; abre SEC-135 y SEC-136 | `docs/seguridad/registro-seguridad.md`, R-059 |

En `Hallazgos abiertos:` de REQ-032 quedan INS-032-1, SEC-135 y SEC-136, los tres `instrumento` respecto de ese
REQ. SEC-135 y SEC-136 siguen siendo `contrato` en su sede y **no se dan por cerrados**.

---

### Hacia 1.36.2 y 1.37

- **1.36.2, inmediato** (abierto al publicar 1.36.1): SEC-135 entero; el origen de `mv` y `.arnes/config.json` de
  SEC-136; y quitar las restricciones de 1.36.1, leyendo el destino con la gramática de la orden.
- **1.37:** `rm`, `unlink` y `git rm` de SEC-136, con la puerta posterior.
- `main` se fusiona en `cand/1.37.0` **después de 1.36.2**, para que 1.37 lleve los dos arreglos juntos.
