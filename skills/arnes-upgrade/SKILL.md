---
name: arnes-upgrade
description: Pone al día el andamiaje de un proyecto ya inicializado con la versión instalada del arnés, mediante un merge a tres vías contra la plantilla de origen. Nunca sobrescribe trabajo humano; ante la duda se detiene. Trabaja en español.
---

# arnes-upgrade — poner al día un proyecto existente

## Por qué existe

Los hooks, los agentes y las skills viven **en el plugin** y se actualizan solos. Los ~10
archivos que `arnes-init` copió al proyecto —`AGENTS.md`, `.arnes/config.json`,
`requirements/README.md`…— **quedan congelados**.

La consecuencia es una deriva garantizada en cada versión: **la máquina empieza a exigir cosas
que el `AGENTS.md` del proyecto no describe**, y los agentes, que leen esos archivos, no se
enteran de las capacidades nuevas.

## El modelo: merge a tres vías

No es «comparar con la plantilla nueva». Son **tres** documentos:

| | Qué es |
|---|---|
| **base** | La plantilla de la versión **desde la que migra** el proyecto |
| **nuestro** | El archivo tal como está hoy en el proyecto |
| **suyo** | La plantilla de la versión **destino** |

La base es lo que permite distinguir *«esto lo escribió una persona»* de *«esto es andamiaje
que nadie tocó»*. Sin base no hay forma de saberlo, y **sin saberlo no se toca nada**.

**De dónde sale la base**, en este orden:
1. `.arnes/plantillas-origen/` del propio proyecto, si `arnes-init` la dejó. Es la fuente
   preferida: no depende de tener acceso al repositorio del plugin.
2. El repositorio del arnés, en el tag de la versión de origen
   (`git show v1.16.0:templates/AGENTS.md.tpl`).

Si ninguna de las dos está disponible, **el estado es `UNKNOWN` y la migración se detiene** —
nunca se adivina. Y al terminar, deja en `.arnes/plantillas-origen/` las plantillas de la
versión destino, para que la siguiente migración tenga base.

## Clasificación: cuatro estados

Para cada sección gestionada, comparando los tres documentos:

| Estado | Evidencia | Acción |
|---|---|---|
| **NUEVO** | No existía en la base y sí en el destino | Añadir |
| **INTACTO** | Existe en el proyecto **idéntica** a la base | Actualizar |
| **MODIFICADO** | Existe en el proyecto y **difiere** de la base | **Conflicto** |
| **ELIMINADO** | Existía en la base y **no está** en el proyecto | **Conflicto** |

**Por qué `ELIMINADO` es conflicto y no «volver a añadir»:** una sección ausente pudo borrarse
**a propósito** —«este proyecto no usa eso»—. Reponerla revierte una decisión humana en
silencio. Si no existía en la base, entonces sí es `NUEVO` y se añade.

## Tres resultados, nunca dos

```
SAFE      -> se aplica solo
CONFLICTO -> se detiene y se pregunta
UNKNOWN   -> se detiene y se pregunta
```

**`UNKNOWN` es tan terminal como `CONFLICTO`, y esto no es negociable.** Nunca conviertas
incertidumbre en decisión: si no puedes recuperar la base, si una sección no se localiza con
seguridad, o si el archivo tiene una estructura que no reconoces, **el estado es `UNKNOWN` y
paras**. Una comprobación que no puede responder no dice «no sé», dice «sí» — y aquí eso
significaría pisar trabajo de una persona.

## Procedimiento

### Fase 1 — Inventario (no toca nada)
- Origen: `arnes_version` de `.arnes/config.json`; si falta, `.arnes-initialized`; si tampoco,
  **pregunta**.
- Destino: `version` de `.claude-plugin/plugin.json` del plugin instalado.
  **Comprueba que el plugin instalado es el actual antes de usarlo como destino.** No se
  actualiza solo: medido, un proyecto corría 1.13.0 con 1.21.0 publicada, un mes atrás y sin
  ninguna señal. Migrar hacia un plugin viejo deja al proyecto al día **con una versión que ya
  no es la de nadie**, y la siguiente migración partirá de esa base.
- Si coinciden: informa que está al día y **para**. Idempotente.
- **Acredita la versión de origen antes de usarla** (ver abajo). Toda la migración cuelga de
  ese número.
- Recupera las plantillas **base** y **destino**. Si alguna no se puede: `UNKNOWN`.
- **Exige el árbol de git limpio.** Si hay cambios sin comitear, para: el respaldo y la
  reversión los da git, y con el árbol sucio no se puede distinguir lo tuyo de lo mío.

#### La versión de origen es una afirmación, no una evidencia

`arnes_version` lo escribe quien migra, y **ninguna puerta lo comprueba**. Un campo escrito a
mano que nadie verifica acaba mintiendo — es la misma clase de defecto que
`Sensible a seguridad: **sí**`, que declaraba una cosa y valía otra.

Aquí miente en el peor sitio posible: es de donde sale la **base** del merge. Si el número es
falso, la base se recupera igual —sólo que la equivocada— y entonces todo `INTACTO` y todo
`MODIFICADO` de la Fase 2 se calculan contra un documento que este proyecto nunca tuvo. La
migración no falla: **acierta en el procedimiento y se equivoca en todo el resultado.**

*(Caso real, 2026-09-04: un proyecto declaraba `1.15.0` con el plugin instalado en `1.14.0` —
una versión que ni siquiera estaba presente.)*

**Tres resultados, y sólo el primero permite seguir sin decir nada:**

| | Cuándo | Qué se hace |
|---|---|---|
| **CONFIRMADO** | `.arnes/plantillas-origen/` existe y es **idéntica** a la del tag declarado | Se sigue |
| **CORROBORADO** | No hay plantillas de origen, pero los marcadores concuerdan | Se sigue **diciéndolo**: la base es reconstruida, no guardada |
| **DESMENTIDO** | Los marcadores contradicen lo declarado, o el tag no existe | `UNKNOWN` — **para y pregunta** |

**Contradicción barata que se comprueba primero:** si el origen declarado es **posterior** al
plugin instalado, es imposible que ese plugin lo escribiera. No lo resuelvas tú — es señal de
que el campo se editó a mano.

**Los marcadores** son rasgos que sólo pueden existir a partir de una versión, así que su
presencia acota el origen por abajo y su ausencia —en un archivo por lo demás intacto— lo acota
por arriba:

| Marcador en el proyecto | Implica origen ≥ |
|---|---|
| `requirements/README.md` tiene la sección **Nivel de rigor** | 1.19.0 |
| `requirements/README.md` nombra `Hallazgos abiertos:` | 1.16.0 |
| `AGENTS.md` §13 tiene la fila «la transición a `completado` no se hace por shell» | 1.16.0 |
| `AGENTS.md` §6 nombra la auditoría `(preventiva)` | 1.21.0 |
| `.arnes/config.json` tiene `plantillas_origen` | 1.21.0 |
| `.arnes/config.json` tiene la clave `"git"` con `"prohibidos"` | 1.31.0 |
| `requirements/README.md` nombra `con-hallazgos` en el vocabulario de `Seguridad:` | 1.31.0 |

*(Los tres primeros están comprobados contra los tags: ausentes en la versión anterior,
presentes desde la que se indica. Si añades marcadores, compruébalos igual — un marcador mal
fechado desmiente declaraciones correctas, que es peor que no tener marcador.)*

Un marcador **presente** cuyo origen declarado es anterior desmiente la declaración: el proyecto
ya venía de más adelante. Un marcador **ausente** en un archivo que por lo demás coincide con la
plantilla declarada la desmiente también, en la otra dirección.

**No conviertas esto en adivinar la versión.** Los marcadores sirven para **desmentir**, que es
barato y seguro; reconstruir el número exacto a partir de ellos es inferencia, y la inferencia
es justo lo que esta skill evita. Si desmienten lo declarado, el resultado es `UNKNOWN` y se
pregunta — no se sustituye por la que a ti te parezca.

### Fase 2 — Plan (no toca nada)
Clasifica **cada** sección en `NUEVO` / `INTACTO` / `MODIFICADO` / `ELIMINADO` / `UNKNOWN`, con
su archivo, su acción propuesta y la evidencia que la sostiene. Escríbelo en
`.arnes/migracion.md`.

**Si hay algún `UNKNOWN`, no se aplica nada.** Los `CONFLICTO` se listan para el humano.

### Fase 3 — Aplicar
Sólo las operaciones marcadas `SAFE` en el plan. **Está prohibido hacer cualquier cambio que no
esté en el plan** — nada de «ya que estoy, mejoro esto».

### Fase 4 — Verificar (releyendo el disco)
Vuelve a leer **todos** los archivos tocados y comprueba:
1. Cada operación del plan está aplicada.
2. Ninguna sección `MODIFICADO` cambió.
3. No desapareció contenido que estuviera antes.
4. La versión registrada es la de destino.

**No des por hecho que se aplicó porque lo escribiste.** El acto de editar no es la prueba de
que se editó bien; la prueba es volver a leer. Es la misma regla que el arnés aplica a todo lo
demás: se acredita por contenido, no porque el comando dijera que sí.

### Fase 5 — Registrar
**Sólo ahora** actualiza `arnes_version` en `.arnes/config.json` y deja constancia en el
`CHANGELOG.md` del proyecto, con origen y destino. Ese campo es el registro de la migración: si
se sube antes de verificar, la siguiente ejecución creerá que está hecho y el proyecto quedará
a medias sin que nadie lo note.

## Si se interrumpe a mitad

`.arnes/migracion.md` conserva el plan y qué se aplicó. Al reanudar hay **dos** caminos válidos
y ninguno más:

- **Continuar** desde la primera operación no aplicada.
- **Revertir** con git y empezar de cero.

**Nunca** *«parece que algunas cosas ya están, sigo desde donde me parezca»*: eso vuelve a
inferir el estado del contenido, que es justo lo que el plan existe para evitar. Cada operación
se comprueba antes de aplicarla —¿ya está en su forma final?— para que reanudar no duplique
nada.

## Migraciones conocidas

### Hacia 1.16.0
- `AGENTS.md` §6: tope de vueltas **por REQ, sin reiniciarse**; tabla de **clases de hallazgo**.
- `AGENTS.md` §13: filas de enforcement nuevas (cierre por Bash, clase del hallazgo).
- `requirements/README.md`: campo `Hallazgos abiertos:` y sección **Clases de hallazgo**.
- `PENDING_APPROVAL.md`: si conserva el ejemplo comentado **bajo** `## Pendientes`, sácalo de
  la sección.

### Hacia 1.19.0

> **CONFLICTO conocido — el vocabulario del rigor choca.** Un proyecto que ya tenía su
> propia escala de rigor **no la puede mapear sin decidir**, y esto no es cosmético:
>
> | | Escala propia típica del proyecto | Plugin 1.19.0+ |
> |---|---|---|
> | Niveles | dos — crítico / normal | tres — `ligero` / `estandar` / `critico` |
> | Se declara en | `Sensible a seguridad:` | `Rigor:` |
> | Qué gobierna | cuánta demostración se exige | **qué agentes corren** |
> | QA | siempre | **`ligero` lo salta** |
>
> El día que el proyecto escriba `Rigor: ligero`, la máquina se saltará QA mientras su
> `AGENTS.md` sigue prometiendo que QA revisa siempre. Es la deriva que advierte §13, y
> aparece **justo al migrar**. El mapeo se reescribe en el vocabulario de tres, y se
> **pregunta** —no se infiere— qué trabajo del proyecto puede prescindir de QA. Si la
> respuesta es «ninguno», es una respuesta válida: no se declara `ligero` en ningún REQ.
- `requirements/README.md`: campo `Rigor:` en la plantilla y sección **Nivel de rigor**.
- `AGENTS.md` §6: bloque del nivel de rigor y el marcador `{{CRITERIO_RIGOR_CRITICO}}` —
  **pregunta al usuario qué es crítico en su dominio**, no lo inventes.
- `AGENTS.md` §13: fila «el rigor se puede subir, nunca bajar».

### Hacia 1.20.0

> **1.20.0 nunca se publicó**: su contenido llegó dentro de 1.21.0. Ningún proyecto puede estar
> *en* 1.20.0, así que esto no es un destino — es un **paso** que se aplica junto con el
> siguiente al migrar desde 1.19.0 o antes.
- `AGENTS.md` §6: bloque **el orden no es una sugerencia** —seguridad no firma lo que QA no ha
  validado— con la **excepción nombrada** de la auditoría preventiva.
- `AGENTS.md` §13: fila «Seguridad no firma lo que QA no ha validado».
- `requirements/README.md`: el valor `preventiva` en el campo `Seguridad:` y el
  párrafo **el orden importa**.

  Esta migración **no es cosmética**: el hook empieza a denegar una escritura que antes pasaba,
  y la salida —declarar la auditoría preventiva— sólo existe si el proyecto la tiene escrita.
  Un proyecto sin migrar verá un `deny` cuya excepción no está en su `AGENTS.md`.

### Hacia 1.21.0
- Nada que migrar en los archivos del proyecto, pero **sí hay que revisar los REQ que
  ya existen**: hasta 1.20.0, un `Sensible a seguridad:` con marcado —`**sí**`— o con un
  comentario tras el valor **no se reconocía**, y esos REQ nunca activaron la puerta de
  seguridad. Al actualizar empiezan a activarla. Busca en `requirements/` los valores que
  no sean `sí`/`no` limpios y comprueba si alguno cerró sin auditoría.

### Hacia 1.22.0
- `.arnes/config.json`: bloque `estado_derivado` (`activo`, `archivo`). Si falta, el hook usa
  `docs/ESTADO.md` y se activa igual — no hace falta migrar para que funcione.
- `docs/ESTADO.md`: no se toca. El hook **añade** su bloque entre marcadores la primera vez que
  para un agente. **Avísale al usuario de que ese archivo pasa a tener una parte que se
  reescribe sola**, porque si edita ahí dentro perderá lo que escriba.
- Si el proyecto no tiene la carpeta del archivo destino, el hook **no la crea** y no pasa nada.
- `.arnes/config.json`: bloque `rotacion`. Viene **apagado** (`activo: false`), así que migrar no
  cambia nada por sí solo. **Pregunta al usuario** si quiere encenderlo y para qué artefactos —
  no lo decidas tú: mover secciones de la bitácora de su proyecto es su decisión. Y si la
  enciende, **pregunta también el `orden`**: un CHANGELOG es `nuevo-primero`, un registro que se
  añade al final es `nuevo-al-final`, y equivocarse archiva lo más reciente.

### Hacia 1.24.0
- Nada que migrar en archivos del proyecto. Pero **avísale al usuario de dos cosas antes de
  terminar**, porque dos revisores pidieron saberlas antes y no después:
  1. La continuidad (`estado_derivado`) **viene encendida** y reescribe un bloque en
     `docs/ESTADO.md` **en cada parada de agente y de subagente**. Con agentes en paralelo hay
     reescrituras concurrentes: idempotentes, no se corrompen, pero es un archivo que él mantiene.
     Se apaga con `estado_derivado.activo: false`.
  2. La rotación **viene apagada**. Si sus bitácoras pesan (medido: 1,4 MB y 1,3 MB en un
     proyecto), es donde más gana — pero la enciende él, con su `orden`.

### Hacia 1.25.0
- Nada que migrar. **Avísale al usuario** de que los comandos Bash de lectura ya no arrancan el
  guardián, y de que la cobertura de Bash es algo menor que antes en un punto concreto: escrituras
  escondidas tras `npx`, `docker exec`, `bash -c` o `xargs -n1`. Si su proyecto depende de que esas
  formas se detecten, puede añadir en `.claude/settings.json` un hook `PreToolUse` con
  `matcher: "Bash"` sin `if` hacia el `guard.sh` del plugin — recupera el catch-all a cambio del coste.

### Hacia 1.26.0
- Nada obligatorio. Pero si el proyecto tenía `rotacion` encendida con más de un artefacto,
  **pregúntale si alguno crece en dirección contraria**: ahora cada uno declara su `orden`,
  `umbral_bytes` y `conservar_secciones` pasándolo de cadena a objeto. Antes compartían uno solo, y
  para el que creciera al revés la rotación archivaba lo más reciente.
- El bloque derivado empieza a mostrar la versión del plugin y a avisar si `arnes_version` del
  proyecto no coincide. **Actualiza `arnes_version` al terminar la migración** o el aviso quedará
  puesto para siempre — es la Fase 5, y ahora se nota si se salta.

### Hacia 1.27.0
- Nada que migrar. Pero **si el proyecto tenía la rotación encendida sobre algún artefacto con
  finales de línea CRLF**, comprueba dos cosas antes de darla por buena: que el origen se haya
  recortado de verdad, y que su `-archivo.md` no tenga secciones repetidas de pasadas anteriores.
  Hasta 1.26.0 ese caso añadía al archivo sin recortar el origen, y repetía en cada parada.
  Si hay duplicados, se limpian a mano: el contenido nunca se perdió, sólo se copió de más.

### Hacia 1.28.0
- **Urgente si el proyecto corrió 1.25.0, 1.26.0 o 1.27.0:** durante esas versiones una redirección por
  Bash (`echo ... > archivo`) **no pasaba por ningún guardián**. Revisa en el `git log` de ese periodo si
  algún REQ cambió a `completado` o si se tocó código de `codigo_app.globs` desde consola por alguien
  que no fuera el agente de código. La puerta vuelve a existir al instalar 1.28.0; lo que pasó mientras
  no existía hay que mirarlo a mano.
- Nada que migrar en archivos del proyecto.

### Hacia 1.29.0
- **Si el proyecto corre en Linux o macOS:** hasta 1.28.0 ningún hook se ejecutaba (bit de ejecución
  ausente). Revisa el periodo como si no hubiera habido arnés: cierres de REQ, ediciones de
  `codigo_app.globs` por quien no fuera el agente de código, y commits sin entrada de CHANGELOG.
- **Si algún REQ `ligero` se cerró entre 1.19.0 y 1.28.0:** comprueba que sus quality gates estaban
  en verde y que no había aprobaciones humanas pendientes. La puerta no lo miraba.
- **Si `estado_derivado.archivo` o alguna `ruta` de rotación sale del proyecto** (`..`, absoluta, `~`),
  desde ahora se ignora en silencio. Avísale al usuario para que la corrija.
- `QA:` ausente sigue permitido. **Pregunta** si quiere que la migración añada `QA: pendiente` a los
  REQ que no lo declaran: es el paso previo para que una versión futura exija el campo.

### Hacia 1.29.2
- Nada que migrar. Si el proyecto tiene `docs/` o algún directorio de bitácoras como **enlace
  simbólico hacia fuera del repositorio**, desde ahora el arnés no escribe ahí (y sale 0). Avísale
  al usuario: o mueve el destino dentro del proyecto, o acepta que la continuidad y la rotación no
  operen sobre ese directorio.

### Hacia 1.29.3
- Nada que migrar. **Si el proyecto apagó `estado_derivado` por coste** (hasta 1.29.2 el bloque
  tardaba ~90 s por parada con REQ grandes), dile al usuario que puede volver a encenderlo: la
  extracción pasa a una sola pasada de `awk`. Que lo mida en su máquina antes de dar nada por hecho.
- Si sus REQ pesan decenas de KB porque documentan su historia dentro del archivo, **menciónalo**:
  ese coste lo paga cada agente que lea el REQ, no sólo el hook. La rotación de la historia del REQ
  está diseñada y no construida; no lo hagas a mano.

### Hacia 1.30.0
- **Cambio de semántica, y hay que revisar los REQ.** Los campos valen sólo antes del primer `## `.
  Corre `tools/arnes-lectura.sh` y mira: (a) REQ cuyos veredictos vivan **debajo** de una sección —
  hasta hoy se leían, desde hoy no: hay que subirlos a la cabecera—; (b) REQ cuya historia tenga
  líneas `Campo:` a columna cero —hasta hoy se leían **como veredicto**; conviene saber si alguno
  cerró así—. Pregúntale al usuario antes de mover nada.
- `requirements/README.md`: párrafo **los campos valen sólo en la cabecera**. `AGENTS.md` §13: fila nueva.

### Hacia 1.30.1
- Nada que migrar en archivos del proyecto: los dos arreglos son del plugin. Pero **avísale al
  usuario de dos cosas si tiene la rotación encendida**:
  1. Hasta 1.30.0, `umbral_bytes` contaba **caracteres**, no bytes. Un artefacto en UTF-8 con
     acentos pesaba en la cuenta menos de lo que pesa en disco, así que **pudo dejar de rotar sin
     avisar**. Desde 1.30.1 mide bytes: es posible que el primer arranque rote un artefacto que
     llevaba tiempo quieto. Que lo mire antes de dar la rotación por rota.
  2. `tools/arnes-lectura.sh` deja de decir que todo está bien cuando no lo está: un `.md` sin
     ninguna línea vuelve a contarse como archivo **sin `Estado:`**. Si el informe del proyecto
     empieza a señalar archivos que antes callaba, es esto y no un cambio en sus REQ.

### Hacia 1.30.2
- Nada que migrar en archivos del proyecto. **Sí hay que revisar los REQ ya cerrados**, porque un
  agujero se cierra y eso cambia lo que se pudo colar antes:
  - **Un `MultiEdit` podía cerrar un REQ aprobando sólo la línea del historial.** La cabecera
    seguía en `pendiente` y el hook leía como cabecera un fragmento de la historia. Corre
    `tools/arnes-lectura.sh` y busca REQ `completado` cuya **cabecera** no lleve los veredictos que
    su historia sí menciona: pudieron cerrarse así. **Pregunta antes de tocar nada.**
  - Desde ahora el hook **reconstruye el documento resultante** (Edit, MultiEdit y `replace_all`)
    y juzga la cabecera de ese resultado. Efecto visible y deseado: una línea de historia como
    `Estado: completado (revertido)` deja de hacer correr las puertas sobre un REQ que sigue en
    revisión.
  - **Falso positivo que desaparece:** un heredoc cuyo cuerpo mencione `cp README.md src/…` como
    **texto** ya no se deniega. Si el proyecto había partido comandos o cambiado su forma de
    escribir resúmenes para esquivar aquel deny, díselo: puede volver a escribirlos como quiera.

### Hacia 1.30.3
- **Nada que migrar en archivos del proyecto.** Ninguna plantilla cambia; `arnes-upgrade` no tiene
  nada que aplicar. Todo lo que sigue son **cambios de conducta de los hooks**, que es lo que hay
  que avisar antes de terminar:
  1. **Un `Edit` que sustituye sólo el VALOR pasa a `deny`.** Cerrar un REQ cambiando
     `en-revisión` → `completado` con `QA:`/`Seguridad:` pendientes, con la cola de
     `PENDING_APPROVAL.md` abierta o con una quality gate roja **antes devolvía `allow`**. Es la
     forma más natural de cerrar un REQ a mano, así que el agujero estaba donde más se pisa:
     **corre `tools/arnes-lectura.sh` y revisa los REQ `completado` con veredictos pendientes**,
     porque hasta hoy pudieron cerrarse así. Pregunta antes de mover nada.
  2. **Un heredoc SIN citar que escriba código protegido pasa a `deny`** para quien no sea el
     agente de código. `cat <<EOF` / `$(echo x > src/generated.ts)` / `EOF` crea el archivo de
     verdad —bash expande el cuerpo— y hasta ahora ninguna puerta lo veía. Con el delimitador
     **citado o escapado** (`<<'EOF'`, `<<"EOF"`, `<<\EOF`) el cuerpo sigue siendo literal y no se
     analiza: si un flujo del proyecto choca, esa es la salida.
  3. **Un `Write` que sólo CITA el estado en el cuerpo deja de denegarse.** La transición se lee en
     la **cabecera** del documento resultante, así que un criterio que escriba
     `Estado: completado (ejemplo)` dentro del texto ya no dispara nada.
  4. **Un `Write` sobre un REQ que EN DISCO ya estaba `completado` deja de denegarse.** No hay
     transición que juzgar. Avisa de la consecuencia: **reabrir un REQ cerrado que cambia es
     responsabilidad del write-back (`AGENTS.md` §9), no de la puerta** — la máquina ya no lo va a
     recordar por nadie.
  5. **Presupuesto fail-closed de 64 KiB sobre el texto analizable de Bash.** Se cuentan el texto
     del comando **fuera** de los heredocs más las líneas del cuerpo de heredocs **sin citar** que
     lleven `$( )` o acentos graves. Por encima, el hook **no analiza y deniega** con el motivo y la
     salida (heredoc citado, archivo de script, o partir el comando): una puerta que no puede medir
     no deja pasar, y agotar el tiempo de un `PreToolUse` deja pasar **todo**. Los heredocs
     **citados no cuentan**, así que escribir un archivo grande con `cat > x <<'EOF'` sigue siendo
     barato y sigue en `allow`.
     - `limites.bash_max_analisis` en `.arnes/config.json` **sólo puede SUBIR** el techo; bajarlo no
       hace nada. Es **opcional** y **no está en la plantilla** todavía: si el proyecto la necesita,
       se añade a mano al manifiesto y se le dice por qué.
     - **Advertencia que hay que dar:** en `guard-completado` el deny por presupuesto alcanza
       **también al agente de código**, porque la regla de ese guardián —nadie cierra un REQ desde
       la shell— alcanza a todos y sin análisis no se puede saber si el comando toca
       `requirements/`.

### Hacia 1.31.0
- **Una sola novedad nace ENCENDIDA, y hay que decírsela al usuario:** `guard-git.sh` deniega a
  **cualquier** agente —incluida la sesión coordinadora— `git clean -f`, `reset --hard`,
  `checkout .`, `restore .` y `stash` en sus formas destructivas. No alcanza a `stash list`,
  `stash show`, `restore --staged`, `clean -n` ni a ningún `git` de lectura. Es la única puerta
  activa por defecto porque su daño es el único irreversible: git no devuelve lo que nunca se
  comiteó. **Pregunta** si el proyecto necesita el comportamiento anterior: se apaga con
  `git.activo: false`, o se sustituye la lista con `git.prohibidos` (`[]` es una decisión
  declarada y válida). Que la puerta exista **no** sustituye la regla humana: comitear tras cada
  aterrizaje.
- `.arnes/config.json`: bloques nuevos `veredictos` (los dos interruptores **apagados**), `git`
  (encendido, arriba) y `limites` (**opcional**, sólo si un comando legítimo topa con el techo de
  análisis de Bash; bórralo si no lo necesitas). `rotacion.artefactos` admite además la forma de
  **sección** (`glob` + `seccion`). **Pregunta antes de encender `veredictos.*`:** exigen que los
  veredictos lleven fecha `AAAA-MM-DD` en su paréntesis de evidencia, y los REQ ya firmados
  probablemente no la llevan —mídelo con `tools/arnes-lectura.sh`—; un proyecto que lo encienda
  sin re-validar no cierra ningún REQ hasta hacerlo. Puede ser justo lo que quiere: se decide, no
  se hereda.
- **Rotación de sección: se añade APAGADA y no cambia nada de lo que ya rotaba.** Un proyecto que
  rotaba artefactos enteros por secciones `## ` sigue igual (la forma anterior del manifiesto se
  respeta). Si se activa la forma nueva, el nombre de la sección se compara **exacto**: declara
  la línea entera (`"seccion": "## Historial de cambios"`), no un prefijo.
- `requirements/README.md`: `Seguridad: con-hallazgos` pasa a ser un valor **válido** —los REQ que
  ya lo escribían dejan de ser una anomalía **sin editarlos**, y sigue sin cerrar un REQ crítico—;
  párrafos nuevos **la fecha del veredicto también va en el paréntesis**, el **aviso al escribir
  un valor fuera del vocabulario** y el **recorte a 40 caracteres** del bloque derivado.
  `AGENTS.md` §13: dos filas nuevas en la tabla y los dos párrafos correspondientes.
- Corre `tools/arnes-lectura.sh` **después** de instalar: hasta 1.30.3 reportaba como anómalo todo
  `Estado:` con paréntesis de evidencia, y no lo era. Si el proyecto tenía muchas «anomalías», es
  probable que la mayoría desaparezcan solas.
- El bloque derivado de `docs/ESTADO.md` se regenera en la siguiente parada: **no hay nada que
  migrar a mano** por el recorte de celdas.
- **La cola de aprobaciones del bloque derivado puede BAJAR sin que nadie haya resuelto nada.**
  Hasta 1.30.3 el bloque contaba **viñetas** y la puerta contaba encabezados `###`: una entrada
  real del formato documentado valía **4** en el bloque y **1** en la puerta. Ahora las dos usan
  la misma regla —la de la puerta—, así que el número puede caer de golpe. **No hay nada que
  migrar a mano:** el bloque se regenera en la siguiente parada. Si la cola no se puede leer
  entera (un byte NUL, un archivo sin permiso), el bloque dice `sin datos` y la puerta **deniega**
  el cierre: antes contaba 0 y dejaba pasar.
- **Un REQ con la cabecera decorada empieza a ser JUZGADO.** La **clave** de un campo se lee ahora
  con la misma tolerancia que su valor (sangrado, tabulador y énfasis de Markdown: `**Estado:**`,
  `Estado :`, `` `Estado:` ``). Hasta 1.30.3 esas formas dejaban el campo **vacío**, y un campo
  vacío no exigía nada. **Paso de migración: corre `tools/arnes-lectura.sh` ANTES de actualizar**
  para ver qué REQ cambian de lectura — los que aparecían como «nota sin Estado» pasan a contar
  como REQ, con sus veredictos y su rigor.
- **El ACENTO deja de ser parte del valor de un campo, y eso CAMBIA la lectura en todos los
  proyectos.** Hasta 1.30.3 la normalización plegaba una sola pareja de letras (`Í`/`í`), así que
  `en-revision` sin tilde no casaba con el `en-revisión` del manifiesto y `Rigor: estándar` no se
  reconocía. Ahora se pliegan **todas** las vocales acentuadas y con diéresis, en mayúscula y en
  minúscula, y en las dos formas de guardado Unicode (precompuesta y descompuesta: un archivo
  guardado en macOS puede traer la tilde descompuesta y nada lo delata a la vista). **No se
  pliega** la `ñ` —es otra letra, no una `n` con adorno— ni los separadores: `en revision`,
  `enrevision` y `en-revisión-parcial` siguen siendo valores distintos y siguen marcándose.
  **Dos consecuencias, y las dos hay que decírselas al usuario:**
  1. *Avisos que hoy aparecen dejarán de aparecer sin que nadie edite nada.* No hay nada que
     migrar. Si el proyecto tenía REQ con `Estado:`, `Rigor:` o veredictos escritos sin tilde,
     estaban saliendo como «valor que ninguna puerta reconoce» y eran perfectamente válidos.
  2. *En un proyecto cuyo `estados.completado` lleve ACENTO pueden aparecer **DENY nuevos** donde
     antes pasaba.* No es una regresión: es el cierre de un fallo **en abierto**. Escribir ese
     estado sin tilde hacía que la puerta **no viera la transición**, y un REQ crítico podía
     quedar cerrado sin veredicto de seguridad.
  **Qué revisar antes de actualizar:** corre `tools/arnes-lectura.sh` y guarda la salida; después
  de actualizar, vuelve a correrlo y compara. Los REQ que desaparecen de la lista de anomalías son
  los que estaban mal leídos. Y mira si `estados.completado` de tu manifiesto lleva tilde: si la
  lleva, revisa los REQ que ya declaran ese estado escrito sin ella — desde 1.31.0 la puerta los ve.
- **Un manifiesto ROTO deja de permitirlo todo en silencio.** Si `.arnes/config.json` **existe**
  pero no se puede leer como objeto JSON —inválido, vacío, `null` o un array—, el arnés avisa por
  stderr **siempre** y **deniega** toda escritura que las puertas tendrían que juzgar. Hasta 1.30.3
  se permitía todo sin decir nada, y además las variables del manifiesto se rellenaban con campos
  del **input** de la llamada. Un manifiesto **ausente** sigue dejando los hooks inertes, que es una
  decisión legítima del proyecto; uno roto no puede, porque el proyecto sí declaró invariantes.
  **Paso de migración: `jq -e . .arnes/config.json` antes de actualizar.** Si falla, arréglalo o
  borra el archivo; con 1.31.0 no vas a poder escribir hasta entonces.
- **No se escribe a través de un enlace simbólico.** Si la ruta de un `Edit`/`Write`/`MultiEdit`
  apunta a un enlace simbólico **dentro** del proyecto, se deniega con ese motivo. El arnés juzga
  la ruta escrita, no su destino, así que un enlace en una ruta libre que apuntara a código
  protegido recibía el veredicto de su nombre. No se resuelve el destino a propósito: costaría un
  proceso en toda edición y abriría una carrera entre la comprobación y la escritura. **Qué
  revisar:** `find . -type l -not -path './.git/*'` — si el proyecto edita habitualmente a través
  de enlaces, dilo antes de actualizar; la salida es escribir sobre la ruta real.
- **`limites.bash_max_analisis` tiene ahora un máximo.** Si el manifiesto declara un valor por
  encima del máximo operativo del arnés, se aplica **el máximo** y se avisa por stderr; y un valor
  que no sea un **número** en el JSON (`"999999"` entrecomillado) cae al techo por defecto, también
  con aviso. Un techo más alto dejaría de responder antes de que el hook muera, y un hook muerto no
  deniega. Si el proyecto declaró un número enorme «por si acaso», bórralo: no hacía lo que parecía.

*(1.17.0 y 1.18.0 no requieren migración: sólo tocaron el plugin.)*

## Reglas
- No inventes contenido de proyecto. Ante una decisión —un umbral, un nombre, una política—
  **pregunta**.
- No toques el `CHANGELOG.md` ni `docs/ESTADO.md` del proyecto salvo para dejar constancia de
  la migración: son su bitácora, no andamiaje.
- Si el proyecto personalizó una plantilla, se respeta. Se informa, no se corrige.
