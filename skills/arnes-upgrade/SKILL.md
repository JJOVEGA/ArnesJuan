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

*(1.17.0 y 1.18.0 no requieren migración: sólo tocaron el plugin.)*

## Reglas
- No inventes contenido de proyecto. Ante una decisión —un umbral, un nombre, una política—
  **pregunta**.
- No toques el `CHANGELOG.md` ni `docs/ESTADO.md` del proyecto salvo para dejar constancia de
  la migración: son su bitácora, no andamiaje.
- Si el proyecto personalizó una plantilla, se respeta. Se informa, no se corrige.
