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
     `docs/ESTADO.md` **en cada parada de agente y de subagente**. Es un archivo que él mantiene y
     que a partir de ahora tiene una parte que se reescribe sola. Se apaga con
     `estado_derivado.activo: false`.
     **Lo que garantiza y lo que no, dicho exacto** (corregido dos veces: en 1.32.0 esta nota decía
     «idempotentes, no se corrompen», **medido falso**; en 1.32.1 su mitad «No» declaraba abierta la
     carrera de publicación, que ya está cerrada):
     - **Sí:** el bloque es **derivado**, se recalcula entero desde el disco y no acumula estado, así
       que dos paradas seguidas escriben lo mismo; el hook sólo toca lo que hay **entre sus
       marcadores** y publica con un `mv` sobre el destino, así que una parada aislada no deja el
       archivo a medias; y **desde 1.32.1** el temporal de publicación lleva una componente propia
       del **proceso**, así que dos paradas **simultáneas** tampoco comparten archivo ni se pisan
       (hasta 1.32.0 el temporal tenía **nombre fijo** y por ahí se perdió el texto **humano** del
       archivo **1 de 25** vueltas del banco — si venías de una versión anterior, lee «Hacia
       1.32.1»).
     - **No:** dos paradas simultáneas **no están serializadas**, y no se pretende que lo estén: si
       dos publican a la vez **gana la última**, y eso es conforme porque el bloque se deriva del
       mismo disco. Y si al proceso lo **matan** sin darle salida, su temporal puede sobrevivir
       hasta la parada siguiente, que lo retira.
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
- **La puerta de git pasa a ver las formas ENVUELTAS.** Hasta ahora sólo miraba el primer token
  de cada orden y no conocía las palabras reservadas del shell, así que `if …; then git clean -fd;
  fi`, `{ git clean -fd; }`, `for … do git clean -fd; done`, `sleep 0 & git clean -fd`,
  `nohup git clean -fd` y una orden partida con `\` + salto de línea **pasaban**. Ahora se
  deniegan, igual que la forma desnuda. **Qué notará el proyecto:** un guión o un agente que
  limpiara dentro de un `if` o de un bucle recibirá ahora la denegación que ya recibía sin
  envolver. **No cambia ningún permitido:** `echo git clean -f`, un `grep` de un texto que
  mencione el comando y `if …; then git status; fi` siguen pasando. Sigue **fuera de cobertura**
  un subcomando que llega por variable (`G=clean; git $G -f`), los scripts y los intérpretes.
- **Con el manifiesto ROTO, el git destructivo pasa a DENEGARSE.** Si `.arnes/config.json` existe
  y no se puede leer como objeto JSON, la puerta ya no se apaga: aplica la **lista por defecto del
  arnés** y deniega, diciendo que está en modo degradado. Antes permitía, y eso convertía una coma
  de más en un interruptor de apagado. **Ojo al borde:** un proyecto con `git.activo: false` al
  que se le rompa el manifiesto **también** pasará a denegar; la salida es reparar el JSON
  (`jq -e . .arnes/config.json`), que es la única escritura que la avería deja pasar. Con el
  manifiesto sano, `git.activo: false` sigue apagando la puerta igual que siempre. Y mientras dure
  la avería, el bloque derivado de `docs/ESTADO.md` lo dice en una línea, en vez de no escribirse.
- **La forma LARGA de un flag se deniega igual que la corta.** Un proyecto (o un agente) que
  escribiera `git clean --force`, `git clean --force -d` o `git stash save "wip"` los verá ahora
  **denegados**: son el mismo comando destructivo que `clean -f` y que `stash push`, escritos de
  otra manera. La equivalencia funciona en los **dos** sentidos y también sobre una lista propia:
  si declaras `git.prohibidos: ["push --force"]`, `git push -f` queda denegado igual. **No cambia
  ningún permitido:** `clean --dry-run`, `clean -n`, `stash list`, `restore --staged` y los demás
  siguen pasando, y lo que va detrás de `--` es un pathspec, no una opción (`git clean -- --force`
  borra un archivo llamado `--force` y sigue permitido). Si el proyecto tenía un guión de limpieza
  con la forma larga, o lo comitea antes o pide la limpieza al humano fuera de la sesión.
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
  la línea entera (`"seccion": "## Historial de cambios"`), no un prefijo. **Si te equivocas, te
  lo dirá:** un archivo que casa el `glob` pero no contiene la sección declarada no se toca y
  produce un aviso por stderr con el archivo y la sección, más una línea en el bloque derivado de
  `docs/ESTADO.md`. Ese aviso es la señal de que el mapeo está mal, no de que el arnés falle.
- **La parada rota ANTES de derivar el bloque de estado.** Nada que migrar: el bloque describe
  ahora el disco de después de la rotación, que es el que vas a leer en la sesión siguiente.
- `requirements/README.md`: `Seguridad: con-hallazgos` pasa a ser un valor **válido** —los REQ que
  ya lo escribían dejan de ser una anomalía **sin editarlos**, y sigue sin cerrar un REQ crítico—;
  párrafos nuevos **la fecha del veredicto también va en el paréntesis**, el **aviso al escribir
  un valor fuera del vocabulario** y el **recorte a 40 caracteres** del bloque derivado.
  `AGENTS.md` §13: dos filas nuevas en la tabla y los dos párrafos correspondientes.
- **Un manifiesto con una clave del tipo equivocado ahora avisa.** `"exigir_fecha": "true"` (la
  cadena en vez del booleano), un `limites.bash_max_analisis` decimal o en forma exponencial, unos
  `codigo_app.globs` que no son un array: siguen cayendo al valor por defecto del arnés —eso no
  cambia— pero lo dicen por stderr, con la clave y el valor recibido. Si al instalar ves uno de
  esos avisos, el proyecto llevaba tiempo creyendo que declaraba algo que no declaraba. Y mientras
  `.arnes/config.json` esté **roto**, la única escritura que las puertas permiten es la del propio
  manifiesto: la reparación que el mensaje recomienda se puede hacer desde la sesión.
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

### Hacia 1.32.0
- **`requirements/README.md` gana una sección: «Cómo se escribe un criterio que no se desmiente».**
  Nombra por su nombre las tres formas de criterio que se desmienten solas —enumerar lo que el
  código reconoce, fijar un número sin declarar si es **operativo** o **de contrato**, y exigir
  **igualdad** donde un criterio de coste pide un **techo**—, cada una con su caso medido y su
  forma correcta. Se midieron: en un ciclo de este arnés, 7 de 20 hallazgos no fueron código
  defectuoso sino criterios que decían algo falso sobre lo construido, y uno costó una vuelta
  entera del bucle.
- **No hay nada que migrar.** Los REQ existentes **no se reabren ni se reescriben** para
  conformarlos: la regla rige para todo criterio que se **escriba o modifique desde ahora**.
  Reescribir contratos ya cerrados por un motivo de redacción es editar el contrato por comodidad.
- **De esa regla, nada que ejecutar y nada que apagar:** ningún hook nuevo, ninguna llave nueva en
  `.arnes/config.json` y ningún proceso añadido a ninguna ruta. Es una regla de redacción; la puerta
  no la comprueba. (El campo `Archivos:` de más abajo sí es nuevo en la cabecera, y también es
  **opcional** y tampoco lo comprueba ninguna puerta.)
- **La cabecera del REQ gana un campo, `Archivos:`, y su AUSENCIA NO BLOQUEA NADA.** Declara —rutas
  o globs relativos a la raíz, separados por comas, o el literal `(ninguno)`— lo que la
  implementación de ese REQ va a tocar. Lo lee `tools/arnes-paralelo.sh`, la herramienta nueva que
  responde si dos REQ son **disjuntos** o **colisionan** nombrando el archivo compartido, para poder
  despachar dos comisiones a la vez sin adivinar.
- **No es una puerta, y esto es deliberado.** Ningún hook lo lee: `guard-completado` y `guard-codigo`
  dan exactamente los mismos veredictos que en 1.31.0, y un REQ sin el campo **cierra igual que
  siempre**. Lo único que pierde es la posibilidad de paralelizarse: la herramienta lo declara `sin
  declarar` y lo trata como que colisiona con todos. El fail-closed vive en la herramienta, donde el
  coste de equivocarse es volver a la serie — **salvo el hueco medido del punto siguiente**.
- **Y ese fail-closed tiene una excepción abierta: escribe las rutas SIN decoración de Markdown.**
  Vale para todo el espacio del campo menos uno: cuando `Archivos:` lleva el marcado **elemento por
  elemento** —`` `a.sh`, `b.sh` ``, `_a.sh_, _b.sh_` o `**a.sh**, **b.sh**`—, el desenvoltorio
  arranca el par **exterior**, que pertenece a dos elementos distintos, y la herramienta responde
  `disjunto` con rc 0 sobre rutas que no existen (**SEC-020**, del propio arnés, `contrato`,
  **abierto**, ventana 1.33.0). No es una promesa de la máquina en ninguna dirección —es un fallo
  declarado—: las rutas se declaran **desnudas**, y un `disjunto` sobre un campo decorado no se toma
  por bueno; se limpia el campo y se vuelve a preguntar. Envolver la línea **entera**
  (`` `a.sh, b.sh` ``) sí se lee bien, y decorar **un solo** elemento también; lo que corrompe el
  mapa es el marcado repetido por elemento.
- **No hay migración obligatoria de los REQ existentes.** No hace falta abrir los REQ ya escritos
  para ponerles el campo; se añade cuando convenga paralelizar ese REQ, y a partir de ahí forma
  parte de la Definition of Ready del analista (una revisión humana, no una comprobación de
  runtime). Los REQ `completado` no se tocan.
- **Y lo que la herramienta NO responde, escrito en su propia salida:** evalúa **archivos**, nunca el
  **orden de fases**. Un `disjunto` no autoriza a correr el `auditor-seguridad` a la vez que el
  `qa-tester`. Esa regla vive en `AGENTS.md` §6 —que también gana el párrafo de despacho y las tres
  exclusiones con su motivo, espejado en `templates/AGENTS.md.tpl`— y es aparte.
- **La forma del hallazgo (`enumeración` · `número` · `igualdad`) se anota en el log de QA
  (`docs/qa/<versión>.md`), nunca en el paréntesis de la clase** de `Hallazgos abiertos:`. Ese
  paréntesis es la entrada de `guard-completado` y no cambia.
- **Lo que además llega por plantilla y hay que revisar si lo personalizaste:**
  `templates/requirements-README.md.tpl` (la misma sección), `templates/AGENTS.md.tpl` §9 (un punto
  nuevo, «criterio más estrecho que lo construido», que apunta a la sección y no la transcribe) y
  las definiciones de los tres agentes que la aplican — `analista-requerimientos` (tres casillas
  nuevas en su Definition of Ready), `qa-tester` (un criterio mal formado es hallazgo de clase
  `contrato` **antes** de probar, y el QA no reescribe el criterio) y `auditor-seguridad` (un
  control se describe por propiedad, nunca por enumeración). Si personalizaste alguno, el merge a
  tres vías te lo marcará: conserva tu texto y añade lo nuevo, que es aditivo.

**El banco de este repositorio pasa a archivos por sección — y en tu proyecto no hay nada que
migrar.** En ArnesJuan, `tests/escenarios/hooks/run.sh` era un solo archivo de 4.096 líneas con 33
secciones y 683 casos: dos comisiones de QA no podían despacharse a la vez porque las dos habrían
escrito en él. Desde 1.32.0 `run.sh` es sólo el **corredor** (ayudantes compartidos, canario global,
descubrimiento y cuadres) y los casos viven en `tests/escenarios/hooks/secciones/NN-<slug>.sh`, que
el corredor descubre con un glob de bash.

**Los proyectos no heredan el banco.** `arnes-init` y `arnes-upgrade` llevan plantillas, skills,
agentes y playbooks; `tests/escenarios/hooks/` es el banco **de este repositorio**, y nunca se copió
a ningún proyecto. Por tanto: **ninguna migración, ningún archivo que mover, ninguna ruta que
cambiar**. Si tu proyecto tiene su propio banco de pruebas, esta versión no lo toca.

**Si copiaste el patrón —un `run.sh` con secciones en subshell— puedes aplicarlo, y las tres
invariantes siguen siendo las mismas** (están escritas en `tests/escenarios/hooks/README.md` de
este repositorio). Lo que la partición cambia es dónde se cumplen, no si se cumplen:

1. *Un JSON vacío es FAIL, nunca `allow`*: los ayudantes que ejecutan un hook viven **en el
   corredor**, que pasa a ser el sitio único donde se los busca. El corredor comprueba sobre el
   texto de cada archivo que ninguna sección define su propio juez sin guarda, siguiendo la
   **cadena de llamadas** dentro del archivo —así que da igual en cuántas funciones se parta el
   ayudante—. **Y ahí está su límite, que va dicho porque es la mitad honesta de la promesa:** la
   comprobación es **estática y sobre funciones**. Un juez escrito como código suelto al nivel del
   archivo, o armado por indirección —una variable con el nombre del hook, un `eval`—, se le escapa.
   Es una **barandilla contra el descuido, no una jaula**: ensanchar el patrón compraría dos formas
   fingiendo comprar la clase, y produce falsos positivos sobre código correcto (`ADR-002` de este
   repositorio). Lo que de verdad protege es la comprobación de vacío en el corredor, y ésa sí se
   verifica **por mutación en todos los archivos**.
2. *El cuadre*: cada archivo declara `CASOS_ESPERADOS_SECCION` y el corredor exige **su** número
   **y** el total. Es lo que se gana: el ABORT dice ahora **qué archivo** perdió casos.
3. *Cada sección en su subshell, los ayudantes al nivel superior*: ahora la frontera es un archivo,
   así que pesa más. Y hace falta una cuarta: una sección que **muere a mitad** produce las mismas
   cero líneas que una que pasó limpia, así que el subshell deja una marca al llegar al final del
   archivo y su ausencia aborta la vuelta nombrando el archivo.

**Y la trampa que costó una tarde, por si repites el patrón:** el corredor no puede llamar `i` a su
índice de bucle. Seis secciones usaban `i` como contador propio y lo pisaban, así que el corredor
escribía la marca de otra sección y declaraba muertas a seis que habían pasado limpias. Todo lo que
el corredor necesita **después** del `source` lleva prefijo `ARNES_`.

### Hacia 1.32.1
- **Nada que migrar en archivos del proyecto, pero MÍRATE tu `docs/ESTADO.md` antes de seguir.** Esta
  versión cierra una carrera de publicación del hook de continuidad: el temporal por el que publicaba
  se llamaba **igual siempre** —se derivaba sólo de la ruta del destino—, así que **dos paradas de
  agente simultáneas escribían el mismo archivo** y, tras el `mv` de una, la escritura tardía de la
  otra caía sobre el destino ya publicado **desde el primer byte**. En `docs/ESTADO.md` el primer
  byte es justo donde vive lo que escribiste tú, que es lo único del archivo que el arnés **no puede
  volver a derivar**.
- **Qué puede haberte pasado, y no es hipotético:** si corriste una versión afectada **despachando
  agentes en paralelo** (o con subagentes que paran a la vez), **pudiste perder texto de tu
  `docs/ESTADO.md`** sin ningún aviso — el bloque derivado se reescribe solo y aparece completo, así
  que el archivo no *parece* roto. Medido en este arnés: **1 pérdida en 25** vueltas completas de su
  banco de pruebas, y **0 en 92** ejecuciones dirigidas — el perfil de una carrera, que es por lo que
  no salta cuando lo buscas.
- **Cómo recuperarlo si tenías el archivo versionado en git** (y si no lo tenías, ésta es la razón
  para tenerlo):
  ```
  git log --oneline -- docs/ESTADO.md          # busca la última versión con tu texto
  git show <sha>:docs/ESTADO.md > /tmp/estado-antes.md
  diff /tmp/estado-antes.md docs/ESTADO.md     # lo tuyo vive FUERA de los marcadores ARNES:DERIVADO
  ```
  Se recupera **a mano** y sólo lo de fuera de los marcadores: el bloque de dentro se vuelve a
  derivar en la parada siguiente, así que no hace falta restaurarlo. **No** uses `git checkout` del
  archivo entero si desde entonces escribiste cosas nuevas.
- **Qué versiones están afectadas.** La pertenencia **no es una lista escrita a mano**: se decide por
  el historial de `hooks/estado-derivado.sh`, es decir **toda versión publicada cuyo temporal de
  publicación tiene nombre fijo**. Comprobado tag a tag en este repositorio: desde **1.23.0** —donde
  nació el hook— hasta **1.32.0** inclusive; ejemplos **no exhaustivos** de las más recientes:
  **1.30.3, 1.31.0, 1.32.0**. Se verifica en un comando:
  ```
  git show v1.31.0:hooks/estado-derivado.sh | grep -n 'destino.arnes.tmp'   # afectada si aparece
  ```
- **Y si tienes la ROTACIÓN encendida, mírate también sus artefactos.** `hooks/rotar-artefactos.sh`
  tenía la misma forma en sus cuatro puntos de publicación, así que el origen recortado (tu
  `CHANGELOG.md`, o el documento cuya sección rotas) y el archivo de historia podían recibir la
  escritura tardía de otra parada. Viene **apagada** por defecto: si nunca la encendiste, aquí no
  tienes nada que revisar.
- **Qué cambia en el código, y qué no.** El temporal pasa a llamarse
  `<destino>.arnes.tmp.<pid del proceso>`, **sigue en el directorio del destino** —un `mv` entre
  sistemas de archivos deja de ser atómico— y si un temporal sobrevive a su dueño lo retira la parada
  siguiente, comprobando antes que ese proceso ya no está vivo. **El contenido del bloque no cambia
  ni una línea**, la idempotencia es la misma, el hook sigue sin bloquear la parada, sigue inerte sin
  `.arnes/config.json` y sigue apagándose con `estado_derivado.activo: false`. **No hay llave nueva
  en el manifiesto y no hay nada que decidir.**
- **Y no se añadió ningún `flock` ni ninguna serialización**, a propósito: el bloque es **derivado**,
  así que con dos paradas a la vez **gana la última** y eso es conforme. Un candado traería una
  dependencia y un modo de fallo nuevos para proteger un contenido que se recalcula solo.

- **Y AUDITA TUS REQ CERRADOS.** Sin eufemismos, y es la frase entera:
  **en una versión afectada pudiste cerrar un REQ `critico` sin auditoría de seguridad aprobada.**
  El mecanismo: la puerta de cierre leía el interior de un
  comentario HTML de la cabecera como si fuera una declaración de campo, así que un
  `Seguridad: aprobado` **citado** dentro de un `<!-- … -->` —incluso diciendo el comentario que era
  histórico— desbancaba al veredicto vigente y el REQ cerraba. Vale para **cualquier** campo de la
  cabecera por el mismo camino: el veredicto de QA, la clase de un hallazgo bloqueante, el nivel de
  rigor, la sensibilidad. **Y el sitio lo empeora:** el lugar donde alguien escribe «este veredicto
  es histórico» es precisamente un comentario, así que quien mejor documentaba la historia de sus
  veredictos se exponía más.
- **QUÉ HAY QUE AUDITAR, Y SE DICE ANTES QUE NINGÚN COMANDO: la pregunta es de ESTADO, no de vía.**
  Lo que tienes que revisar es una **propiedad** de tus requerimientos:
  **cuáles de tus REQ en estado terminal NO cerrarían hoy**, leídos con el lector de esta versión.
  Ésa —y no la presencia de una forma concreta de escritura en el documento— es la pregunta que
  acredita que no estuviste expuesto: es una discrepancia entre «está cerrado» y «hoy no cerraría»,
  así que **no envejece con la vía siguiente que alguien descubra**, porque no describe ninguna vía.

  **Ningún comando de este apartado la responde todavía.** La comprobación por estado —un modo de
  `tools/arnes-lectura.sh` que conteste «REQ en estado terminal que hoy no cerrarían»— llega en
  **1.33.0**. Hasta entonces se hace a mano y así: para cada REQ en estado terminal, lee su cabecera
  —lo que hay antes del primer `## `— y comprueba que el veredicto **vigente** autorizaba ese cierre.
  Si no lo autorizaba, ese REQ cerró sin la firma que decía tener: reábrelo (`AGENTS.md` §9 — un
  cambio de requerimiento reabre el trabajo) y que la auditoría lo firme de verdad. **No borres el
  texto y sigas:** el cierre indebido ya ocurrió, y lo que hay que rehacer es la revisión.
- **Los barridos POR VÍA que sí puedes correr hoy — y lo que cada uno NO encuentra.** Ayudan a
  empezar por los sospechosos; **no** sustituyen a la pregunta de arriba:
  ```
  # Barrido POR VÍA (una sola): los REQ cuya cabecera abre un comentario BIEN ESCRITO.
  awk 'FNR==1 { cab=1 } /^## / { cab=0 } cab && /<!--/ { print FILENAME": "FNR": "$0 }' requirements/*.md
  # Y el informe del arnés, que lee la cabecera como la lee la puerta y nombra lo que no se lee
  # como está escrito (incluidas las dos vías del retorno de carro, desde 1.32.1).
  tools/arnes-lectura.sh
  ```
  **Estos comandos interrogan una VÍA, no la propiedad**, y el mecanismo tiene una vía nueva cada
  vez: **no hallar nada NO acredita ausencia de exposición.** Vías conocidas al publicar esta versión
  que el `awk` de arriba **no encuentra** —ejemplos **no exhaustivos**; el sitio único donde viven es
  `docs/seguridad/registro-seguridad.md`, SEC-024 y SEC-025—, las dos por un retorno de carro suelto,
  invisible en tu editor y que un renderizador de HTML puede además **esconder** entero:
  - el **delimitador de apertura fabricado**, `<!` + CR + `--`: no hay ningún `<!--` que casar, y lo
    que el autor aparcó dentro del comentario gobernaba;
  - la **clave fabricada**, `Seg` + CR + `uridad: aprobado`: no necesita comentario ninguno y cerraba
    un REQ `critico` desde **1.30.3**.

  Las dos las **deniega** 1.32.1 de aquí en adelante. Si el `awk` no saca nada, **no has terminado**:
  vuelve a la pregunta de estado.
- **Qué versiones están afectadas.** La pertenencia **no es una lista escrita a mano**: se decide por
  el historial del **lector de cabecera** (`arnes_norm_clave` en `hooks/lib.sh`), es decir **toda
  versión publicada que tolera el énfasis de Markdown en la CLAVE del campo y no tiene noción de
  cita**. Comprobado tag a tag en este repositorio: desde **1.31.0** —donde nació esa tolerancia—
  hasta **1.32.0** inclusive; las anteriores no leían la clave decorada, así que la cita no las
  alcanzaba. Se verifica en un comando, tag a tag:
  ```
  git show v1.31.0:hooks/lib.sh | grep -c 'arnes_norm_clave'   # >0 = tolera la clave decorada
  git show v1.31.0:hooks/lib.sh | grep -c 'arnes_sin_cita'     # 0  = sin noción de cita -> AFECTADA
  ```
  Las dos condiciones a la vez: la primera sin la segunda es la ventana del defecto.
- **Qué cambia en el código, y qué no.** El interior de un rango `<!-- … -->` de la cabecera **no
  declara campo**, en los dos lectores del arnés a la vez (`hooks/lib.sh` y su transcripción
  `hooks/campos-req.awk`). Un rango que **abre y no cierra** dentro de la cabecera deja una cabecera
  que no se puede medir, y la puerta **deniega** citando el rango — nunca permite por *ausencia* del
  campo que el comentario se tragó. **Lo que NO cambia:** la tolerancia de la clave decorada sigue
  gobernando **fuera** de los rangos (cerró un fail-open real y recortarla lo reabriría), la regla de
  «última aparición» de los campos y la de «primera» para el estado se conservan, y un `## ` sigue
  terminando la cabecera aunque viva dentro de un comentario. **No hay llave nueva en el manifiesto y
  no hay nada que decidir.**
- **Un aviso nuevo en `tools/arnes-lectura.sh`, y a propósito NO es una anomalía.** El informe nombra
  ahora la línea que **gobierna** un campo cuando esa línea trae la clave decorada o sangrada,
  aunque su valor sea impecable — el caso típico lo produce el **corte de un párrafo**, no su
  contenido. Va en su propio bloque y **no cambia el código de salida**: si además existe **otra**
  declaración del mismo campo y la que manda es la decorada, entonces sí es anomalía y el informe
  sale ≠ 0, porque el documento dice dos cosas y la máquina elige una. Un informe que grita por lo
  inofensivo deja de leerse, y con él lo que sí importa.

### Hacia 1.34.0
- **Y AUDITA TUS REQ CERRADOS. Sin eufemismos, y es la frase entera: en una versión afectada
  pudiste cerrar un REQ `critico` sin validación de QA y sin auditoría de seguridad aprobada.** El
  mecanismo: un carácter que nadie ve en el diff, insertado **dentro de la clave** de una línea de la
  cabecera, hacía que el lector **no** resolviera esa línea como el campo que declara — y la puerta
  resolvía la **ausencia** de ese campo del lado que **abre**. Medido
  (`docs/seguridad/registro-seguridad.md`, **SEC-047**): `Sensible a seguridad: sí` con un **BOM**
  delante, más un `Rigor: ligero` escrito debajo, cerraba a `completado` un REQ con `QA: pendiente`
  y `Seguridad: pendiente`, porque el **suelo de rigor** desaparecía junto con el campo; y un
  carácter invisible delante de `Hallazgos abiertos:` retiraba un hallazgo de clase `contrato` que
  bloqueaba el cierre. Vale para **cualquier** campo de la cabecera por el mismo camino: el
  veredicto de QA, el de seguridad, la clase de un hallazgo, el nivel de rigor, la sensibilidad y el
  propio `Estado:`. **Y no hace falta malicia:** un BOM lo añade PowerShell al redirigir a un
  archivo, y un **blanco de más** —`Sensible a  seguridad`— lo teclea cualquiera y no se ve en
  ningún editor.
- **QUÉ HAY QUE AUDITAR, Y SE DICE ANTES QUE NINGÚN COMANDO: la pregunta es de ESTADO, no de vía.**
  Lo que tienes que revisar es una **propiedad** de tus requerimientos: **cuáles de tus REQ en estado
  terminal NO cerrarían hoy**, leídos con el lector de esta versión. Ésa —y no la presencia de un
  carácter concreto en el documento— es la pregunta que acredita que no estuviste expuesto: es una
  discrepancia entre «está cerrado» y «hoy no cerraría», así que **no envejece con la vía siguiente
  que alguien descubra**, porque no describe ninguna vía.

  **Ningún comando de este apartado la responde todavía, y el que se anunció no llegó.** La
  comprobación por estado —un modo de `tools/arnes-lectura.sh` que conteste «REQ en estado terminal
  que hoy no cerrarían»— **no existe en 1.34.0**: sigue en «Fuera de alcance» de `REQ-016` como
  `instrumento` con dueño `desarrollador`, y el apartado «Hacia 1.32.1» de esta misma skill la
  anunciaba para 1.33.0, que se publicó sin ella. Se dice aquí porque una guía que arrastra una
  promesa vencida manda a buscar un comando que no existe. Hasta que exista, la pregunta se responde
  **a mano** y en este orden, con las dos herramientas de abajo: el informe dice **qué líneas no se
  pueden medir**, y para cada REQ en estado terminal que aparezca ahí, el campo que ese carácter
  borró **no estaba gobernando cuando cerró** — reescribe la línea con la clave limpia y comprueba
  si el veredicto **vigente** autorizaba ese cierre. Si no lo autorizaba, ese REQ cerró sin la firma
  que decía tener: reábrelo (`AGENTS.md` §9 — un cambio de requerimiento reabre el trabajo) y que la
  validación y la auditoría lo firmen de verdad. **No borres el carácter y sigas:** el cierre
  indebido ya ocurrió, y lo que hay que rehacer es la revisión.
- **(1) El informe del arnés, que lee la cabecera con EL MISMO lector que la puerta:**
  ```
  tools/arnes-lectura.sh          # sale ≠ 0 si hay anomalías; una de ellas es «cabecera no medible»
  ```
  Nombra el REQ, la clave tal como la declara, **lo insertado en `\xNN`** —en el archivo es
  invisible y el diff no lo muestra— y la consecuencia («la puerta de cierre DENIEGA»). No es un
  barrido por vía: pasa cada línea por el normalizador de los hooks, así que no depende de qué
  carácter sea. **Y tampoco responde la pregunta de estado:** dice qué líneas no se pueden medir, no
  qué REQ cerrados no cerrarían hoy — un cierre indebido también puede venir de un veredicto que ya
  no autoriza, de una aprobación pendiente o de un hallazgo bloqueante, y de eso este informe no
  habla.
- **(2) Un barrido POR VÍA, con lo que NO encuentra escrito aquí mismo y no en otra página:**
  ```
  # Barrido POR VÍA (una sola): líneas de la cabecera cuyo SEGMENTO DE CLAVE lleva un byte no ASCII,
  # un byte de control, un tabulador o un blanco de más. `cat -v` para VER lo invisible.
  LC_ALL=C awk 'FNR==1 { cab = 1 } /^## / { cab = 0 }
    cab && !/^#/ && index($0, ":") > 1 && index($0, ":") <= 32 {
      k = substr($0, 1, index($0, ":") - 1)
      if (k ~ /[\200-\377]|[\001-\010\013-\037]|\t|  /) printf "%s:%d: %s\n", FILENAME, FNR, $0
    }' requirements/*.md | cat -v
  ```
  **Este comando interroga una VÍA, no la propiedad**, y el mecanismo tiene una vía nueva cada vez:
  **no hallar nada NO acredita ausencia de exposición.** Vías conocidas al publicar esta versión que
  este barrido **no encuentra** —ejemplos **no exhaustivos**; el sitio único donde viven es
  `docs/seguridad/registro-seguridad.md`: **SEC-047** para la clave con algo insertado, **SEC-024**
  y **SEC-025** para el retorno de carro suelto—:
  - **un byte ASCII imprimible ajeno al alfabeto de las claves, que la puerta SÍ deniega.** Medido:
    `QA-: aprobado` y `Q.A: aprobado` disparan la guarda de esta versión y este barrido **no los
    ve**, porque no llevan ningún byte raro;
  - la **sustitución de una letra por un homóglifo** (`Еstado:` con la `Е` cirílica), que el barrido
    sí nombra y que **ninguna** versión deniega —tampoco 1.34.0—: es clase abierta con dueño en el
    registro, así que verla aquí no significa que la puerta te proteja de ella.

  **Y al revés, para que su ruido no se lea como hallazgo:** el barrido nombra líneas **legítimas**
  —`Módulo:` y `Versión destino:` llevan letra no ASCII por plantilla—, así que una salida no vacía
  tampoco es por sí misma una exposición: medido sobre los 27 REQ de este repositorio saca **53
  líneas** —27 de `Módulo:` y 26 de `Versión destino:`— y **todas** son legítimas. Quien separa las
  dos cosas es el informe de (1), porque lee con el lector de la puerta.
- **Qué versiones están afectadas.** La pertenencia **no es una lista escrita a mano**: se decide por
  el historial del **lector de cabecera** (`hooks/lib.sh`), es decir **toda versión publicada cuyo
  lector no pregunta si algo se insertó dentro de la clave**. Se verifica tag a tag en un comando:
  ```
  git show v1.33.0:hooks/lib.sh | grep -c '_arnes_clave_oculta'   # 0 = AFECTADA
  ```
  Comprobado así en este repositorio: **todas hasta 1.33.0 inclusive** dan **0** (ejemplos **no
  exhaustivos** de las más recientes: **1.31.0, 1.32.0, 1.32.1, 1.33.0**), y `SEC-047` midió las
  filas que abren en `v1.30.3`, `v1.31.0`, `v1.32.0` y `v1.32.1`. La guarda nace en **1.34.0**.
- **Qué cambia en el código, y qué no.** Una línea de la cabecera cuya **clave** lleva algo insertado
  dentro deja la cabecera **sin medir**, y la puerta **deniega** citando esa línea y lo insertado en
  `\xNN` — **dentro de lo que la guarda alcanza, que no es toda la clase: la vía del homóglifo de
  arriba PERMITE, y permite por ausencia del campo que el homóglifo borró.** Donde la guarda sí
  alcanza, **no** permite por *ausencia* del campo que ese carácter borró. Y qué alcanza lo decide una
  propiedad y no una lista de caracteres:
  retirado de la clave lo ajeno al alfabeto de las claves **y después todos sus blancos**, **si lo que queda es una clave del lector leída también sin sus blancos**,
  entonces alguien insertó algo dentro; si esa reconstrucción **no** devuelve ninguna clave —porque lo
  retirado **sustituía una letra**, y reponer *qué* letra exigiría **elegir entre candidatos**— la
  guarda **calla** y la puerta resuelve por **ausencia**. Sitio único de las vías abiertas y de las
  fronteras, con su clase, dueño y vencimiento: `docs/seguridad/registro-seguridad.md` § **R-024**
  (**SEC-078** la vía, **SEC-079** la promesa que se midió falsa). **Lo
  que NO cambia, tres fronteras deliberadas y lista no exhaustiva:** el CR/LF **final** sigue siendo transporte —un REQ
  guardado entero en CRLF cierra igual que en LF—, el **cuerpo** del REQ no se restringe (esto es la
  cabecera y nada más) y **reabrir** un REQ no se bloquea nunca. Y una clave legítima no cambia de
  veredicto: `Módulo:`, `Versión destino:` y la clave **decorada** o sangrada siguen gobernando
  exactamente como antes. **No hay llave nueva en el manifiesto y no hay nada que decidir.**
- **`AGENTS.md`: sección nueva `## 14. Reglas de trabajo de la sesión coordinadora`**, entre los
  marcadores `<!-- arnes:coordinacion:inicio -->` y `<!-- arnes:coordinacion:fin -->` (nombres **de
  contrato**: esta migración se hace **por** ellos, y cambiarlos exige ADR). Trae la comprobación de
  antes de despachar, las siete reglas, la separación de responsabilidades y las **vías de lectura
  con su estado de verificación**. Estado **`NUEVO`** según la tabla de «Clasificación: cuatro
  estados» de esta misma skill —el bloque **no existía en ninguna base**, así que **se añade**—, y
  por eso en la primera migración no hay `INTACTO` ni `ELIMINADO` que decidir.
- **Se añade al FINAL del archivo, como sección propia, y no se renumera nada.** Las referencias
  `§N` del propio `AGENTS.md`, de los agentes y de los REQ apuntan **por número**: insertar el
  bloque en medio y correr los títulos las rompe **en silencio**, sin que falle nada. Y si el
  `AGENTS.md` del proyecto ya tiene una sección `## 14.` propia, el número está tomado: **`UNKNOWN`,
  se detiene y se pregunta** — no se renumera la sección del proyecto ni se cuelga el bloque sin
  título.
- **Antes de insertar se BUSCA, y ESO es la idempotencia: no la dan los marcadores.** Los marcadores
  hacen el bloque *identificable*; idempotente es la **conducta** de mirar primero. Se decide con la
  **cuenta** de los marcadores del `AGENTS.md` del proyecto —**el marcador completo, con sus
  delimitadores `<!--` y `-->`**, nunca la cadena desnuda: el porqué está medido más abajo—, no con
  la impresión de haberlo visto:

  | inicio / fin | Estado | Acción |
  |---|---|---|
  | 0 / 0 | `NUEVO` | añadir el bloque al final |
  | 1 / 1, contenido **idéntico** al de la plantilla destino | `INTACTO` | **no tocar nada** |
  | 1 / 1, contenido **distinto** | `MODIFICADO` | **conflicto: preguntar, no pisar** |
  | cualquier otra cuenta (2/1, 1/0, 0/1, o el cierre antes de la apertura) | `UNKNOWN` | **detenerse y preguntar** |

  «Idéntico» se decide **tras quitar el `\r` final** de cada línea, si lo hay —la misma
  normalización que `hooks/lib.sh` aplica (`linea="${linea%$'\r'}"`)—: un proyecto Windows cuyo
  editor normaliza el archivo entero a CRLF tras migrar tiene el bloque **intacto** y sin esa
  normalización se declara `MODIFICADO`, o sea un **conflicto falso** que hace preguntar por nada.
  Es un `\r` **final**; los demás bytes se comparan tal cual, y la comprobación de idempotencia
  entre dos corridas (`cmp`, abajo) sigue siendo **byte a byte**, sin normalizar nada.

  La fila `INTACTO` es la que hace que la **segunda** corrida no duplique nada, y la Fase 4 es la
  que lo acredita: correr, correr otra vez y comparar el archivo **byte a byte**.
- **El texto propio del proyecto no se pisa, tampoco el que esté DENTRO de los marcadores.** Un
  proyecto que escribió sus propias reglas de coordinación ahí dentro es `MODIFICADO`, y
  `MODIFICADO` es conflicto: se informa y se pregunta. **Una migración que sobrescribe ese texto no
  es una migración con un detalle mejorable: es un fallo de esta entrada**, y así se comprueba —con
  un caso que debe fallar si lo pisa.
- **Cómo se comprueba, sin fiarse de que el comando dijera que sí** (Fase 4, releyendo el disco):
  ```
  cp AGENTS.md /tmp/agents-antes.md
  grep -c '<!-- arnes:coordinacion:inicio -->' AGENTS.md   # 0 -> NUEVO ; 1 -> ya está ; >1 -> UNKNOWN
  grep -c '<!-- arnes:coordinacion:fin -->'    AGENTS.md   # la tabla decide con las DOS cuentas
  # ...aplicar sólo lo que el plan marcó SAFE, y volver a correr la migración...
  cmp /tmp/agents-tras-1a-corrida.md AGENTS.md     # sin salida = idempotente
  grep -c '<!-- arnes:coordinacion:inicio -->' AGENTS.md   # exactamente 1
  diff <(grep '^## [0-9]' /tmp/agents-antes.md) <(grep '^## [0-9]' AGENTS.md)   # sólo la línea de §14
  ```
- **Se cuenta el marcador COMPLETO, y es medido, no una preferencia de estilo.** Contar la cadena
  desnuda (`grep -c 'arnes:coordinacion:inicio'`) cuenta **menciones, no marcadores**: un
  `AGENTS.md` **sin** el bloque que cite esa cadena una vez —la nota de migración que el propio
  proyecto se escribió— devuelve **1**, la tabla lee «ya está» y **el proyecto nunca recibe las
  reglas, sin aviso**; con dos menciones devuelve `UNKNOWN` y detiene la migración sin motivo real.
  Medido sobre maquetas (cadena desnuda → marcador completo): proyecto sin bloque que menciona la
  cadena **1 → 0**; el mismo con dos menciones **2 → 0**; proyecto realmente migrado **1 → 1**;
  migrado que además menciona la cadena **2 → 1**. **Tampoco se ancla el patrón a la línea entera**
  (`^…-->$`): un espacio final dejado por un editor lo baja a **0**, y **0** manda a `NUEVO`, que
  *añade* el bloque y deja **dos** — un fallo en abierto peor que el que se cerraba. El residuo que
  queda con el marcador completo es un proyecto que **cite el marcador entero** en su prosa: da
  **2** → `UNKNOWN`, se detiene y se pregunta, que es el destino correcto de la duda.
  (Corridas y rutas: `docs/qa/REQ-027.md`, sección «Correcciones del desarrollador».)
- **Lo que NO cambia, dicho para que nadie busque una puerta que no existe:** el bloque no toca
  ninguna sección existente de `AGENTS.md`, no hay llave nueva en `.arnes/config.json`, ningún hook
  lo lee y **ninguna puerta lo comprueba** — es una regla escrita para quien coordina, no
  enforcement. Y mientras el proyecto no migre, **sus coordinadoras no tienen estas reglas**: cerrar
  eso es exactamente para lo que existe esta entrada.

*(1.17.0 y 1.18.0 no requieren migración: sólo tocaron el plugin.)*

## Reglas
- No inventes contenido de proyecto. Ante una decisión —un umbral, un nombre, una política—
  **pregunta**.
- No toques el `CHANGELOG.md` ni `docs/ESTADO.md` del proyecto salvo para dejar constancia de
  la migración: son su bitácora, no andamiaje.
- Si el proyecto personalizó una plantilla, se respeta. Se informa, no se corrige.
