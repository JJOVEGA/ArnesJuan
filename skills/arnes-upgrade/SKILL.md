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
1. Cada operación del plan está aplicada — y una que quedó en `CONFLICTO` o `UNKNOWN` **sin
   resolver es una operación no aplicada**, no un pendiente aparte.
2. Ninguna sección `MODIFICADO` cambió.
3. No desapareció contenido que estuviera antes.
4. La versión registrada es la de destino **si el plan quedó aplicado entero**; si quedó alguna
   operación sin aplicar, sigue siendo la de origen (Fase 5).

**No des por hecho que se aplicó porque lo escribiste.** El acto de editar no es la prueba de
que se editó bien; la prueba es volver a leer. Es la misma regla que el arnés aplica a todo lo
demás: se acredita por contenido, no porque el comando dijera que sí.

### Fase 5 — Registrar
**Sólo ahora** actualiza `arnes_version` en `.arnes/config.json` y deja constancia en el
`CHANGELOG.md` del proyecto, con origen y destino. Ese campo es el registro de la migración: si
se sube antes de verificar, la siguiente ejecución creerá que está hecho y el proyecto quedará
a medias sin que nadie lo note.

**Y sólo si el plan quedó aplicado entero.** Un `CONFLICTO` o un `UNKNOWN` que siga sin resolver
es **una operación del plan no aplicada**, así que la migración es **PARCIAL**: `arnes_version`
**conserva el valor de origen — no se escribe**, y el resultado parcial se **declara** en
`.arnes/migracion.md` y en el `CHANGELOG.md` del proyecto **con la lista de secciones
pendientes**. La versión se registra **sólo** cuando esas operaciones queden aplicadas, al
reanudar por **«Continuar»** (ver «Si se interrumpe a mitad»). El porqué es el de arriba visto
desde el otro lado: con la versión ya subida, la **Fase 1** de la siguiente ejecución encuentra
origen = destino, informa que está al día y **para** — el conflicto deja de existir para la vía
automática y sobrevive sólo en la prosa. Declarar «parcial» en el texto y subir el número a la
vez es decir dos cosas opuestas, y **el número es el dato que lee la máquina.**

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
  proyecto no coincide. **Actualiza `arnes_version` cuando el plan quede aplicado entero** o el
  aviso quedará puesto para siempre — es la Fase 5, y ahora se nota si se salta. Si la migración
  quedó **parcial**, el aviso es correcto y se mantiene hasta resolver lo pendiente: la versión
  **no** se sube para callarlo (Fase 5).

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

- **`AGENTS.md` §6 y §9, y los cuatro agentes: la VÍA PROPORCIONAL de reparación.** §6 gana una tabla
  que elige la vía **por el efecto del cambio** —documentación sin cambio de obligaciones · **reparación
  con causa, alcance y contrato claros: desarrollador → QA, sin comisión de analista** · cambio cuyo efecto alcanza **un criterio de `critico` del proyecto o una protección del arnés** (ejemplos declaradamente no exhaustivos): **+ seguridad** ·
  capacidad nueva o cambio de contrato: las cuatro fases—, y §9 deja de fijar en el analista **quién
  transcribe** el write-back.
  **LO PRIMERO, porque decide todo lo demás: instalar esta sección NO la autoriza.** La migración
  te trae §6 y §9 **descritas**; la vía sólo rige donde el **propietario del proyecto la declara**,
  y esa declaración es **un acto suyo**, no una consecuencia de que el texto llegue. **Ninguna fila
  del merge —tampoco `INTACTO` ni `NUEVO`— escribe esa autorización**: lo que se instala es la
  descripción y la **línea negativa**, que es el valor por defecto. Para declararla, la sede es
  **`AGENTS.md` §6, «La disciplina de la declaración»**, y la escribe el propietario, no esta skill.
  **Hasta que la declares, tu proyecto sigue exactamente con el procedimiento anterior:** analista →
  desarrollador → QA → seguridad, y **ningún agente puede omitir al analista**: migrar sin declarar
  **no cambia quién interviene en cada REQ**. Lo que sí cambia, declares o no, es el **texto** de §6
  y §9 y el de los agentes, que pasan a describir la vía y a condicionarla a esa declaración.
  **Las dos líneas —la afirmativa y la negativa— y toda la disciplina de redacción salen de UNA
  sede, y aquí no se copian ni se parafrasean: `AGENTS.md` §6, «La disciplina de la declaración».**
  Escríbelas **exactamente como manda esa sede**: de ahí salen las dos redacciones literales, la
  prohibición de **inventar una tercera**, la de **dejar la declaración comentada** —un comentario
  sigue siendo texto, y una declaración apagada no es una declaración— y la regla de que una
  **negación**, una **postergación** o una **decisión pendiente** **no autorizan aunque contengan la
  frase entera**. **No escribas esa línea «en tus palabras»:** es el único texto cuya **redacción
  es** el control.
  **Cómo la declaras, si la quieres:** sustituye la línea negativa por la **afirmativa** de esa
  sede, con tu nombre y la fecha. Y si no la quieres, **deja la línea como está**: no hay nada que
  borrar. Ni la **tabla de vías**, ni la descripción, ni la propia comprobación de §6 son evidencia
  de autorización — todas **llegan instaladas**, y deducir de ellas el permiso es exactamente el
  fallo que esto evita.
  **Y define «contrato claro»**: incluye que `Rigor:`, `Sensible a seguridad:` y las revisiones
  exigidas sean **coherentes con el efecto** de la reparación; una clasificación insuficiente o
  contradictoria devuelve al analista **sólo esa decisión** antes de continuar, sin repetir el
  análisis ni dar facultades nuevas a otros roles.
  **Y los agentes cambian con ella, porque la política también los gobierna:** el `desarrollador`
  recibe el write-back de la vía de reparación **en la misma entrega**; el `qa-tester` deja de leer
  que el write-back es siempre del analista y conserva su obligación de **no firmar sin él**; el
  `analista-requerimientos` mantiene el suyo **siempre que quede una decisión**; y el disparador del
  `auditor-seguridad` se enuncia **sin depender de quién lo despache**.
  **Qué NO cambia:** el **write-back sigue siendo obligatorio** —cambia quién lo escribe, no si se
  escribe—; **el rigor no se rebaja**, elegir vía **no** reclasifica un REQ y subirlo o bajarlo sigue
  su procedimiento de siempre (lo fija el analista, el auditor puede subirlo, nadie lo baja sin su
  firma, y `Sensible a seguridad: sí` impone `critico` como suelo); **no se omiten pruebas
  necesarias**; **los contadores no se reinician**; y **seguridad sigue sin firmar lo que QA no ha
  validado**. **Ningún hook cambia**, y tampoco `.arnes/config.json` — y por eso una errata que viva
  dentro de `codigo_app.globs` **la sigue denegando `guard-codigo`** por mucho que sea documental:
  elegir vía decide quién revisa, no quién puede escribir.

  **Cómo llega esto a tu proyecto, por el estado que devuelva el merge —los cinco, sin declarar
  ninguno imposible—:**

  **Primero, la separación sin la cual esta migración se detiene entera: los agentes NO se migran.**
  Los **cuatro agentes los provee el plugin** (`.claude/agents/`): tu proyecto **no tiene copia
  propia** que clasificar, y `arnes-init` **no** deja base suya en `.arnes/plantillas-origen/`,
  porque ahí sólo van los `.tpl` y los agentes no lo son. **No los clasifiques, no los busques y no
  los pongas en el plan:** una clasificación sin base recuperable es `UNKNOWN`, y un `UNKNOWN`
  **detiene la corrida completa** — incluidas `§6` y `§9`, que sí son migrables. Los agentes llegan
  corregidos **al actualizar el plugin**, no por esta migración; **dilo en el informe** y sigue.
  **Y si guardaste una copia modificada de alguna definición de agente en tu proyecto, no se pierde
  ni se pisa:** esta migración **no la toca, no la sobrescribe y no la actualiza** — se queda
  exactamente como la dejaste. Lo que **no** va a pasar es que el merge te avise de ella, así que
  compararla con la definición nueva del plugin queda **a tu cargo**.

  **Lo que SÍ se migra son las secciones `§6` y `§9` de tu `AGENTS.md`**, que se copiaron de la
  plantilla a tu proyecto y por eso tienen base con la que comparar. Y **`templates/AGENTS.md.tpl`
  y `templates/requirements-README.md.tpl`** también tienen base y entran en el merge: si los
  personalizaste saldrán `MODIFICADO`, y eso es **conflicto** — tu texto **no se toca** y la
  decisión es tuya.

  **Y antes de clasificar ninguna, identifícala por CONTENIDO Y TÍTULO, nunca sólo por el número.**
  Es la misma regla terminal que ya rige en «Tres resultados, nunca dos» —*si una sección no se
  localiza con seguridad, el estado es `UNKNOWN` y paras*—, aplicada aquí a una forma concreta de no
  localizarla: **un mismo `## N.` ha significado cosas distintas en distintas versiones del arnés**,
  así que el número **no identifica** una sección, sólo la numera. Comprueba que el título y el
  contenido del `## N.` de tu proyecto y el del `## N.` de la base **son la misma sección**; **si no
  lo son, o si no puedes afirmarlo sin adivinar, es `UNKNOWN`**: la migración **se detiene, no se
  aplica nada** —tampoco lo que salió `SAFE`, como manda la Fase 2— **y el documento se conserva
  intacto**. Esto **manda sobre la tabla de abajo**: sin identificación firme no se entra a
  clasificar.

  > **Por qué, enunciado por propiedad y no como lista de versiones** (una lista de tags envejece; la
  > propiedad no): **el arnés ha renumerado y retitulado secciones de `AGENTS.md` a lo largo de su
  > historia**, y un proyecto instalado hace tiempo conserva la numeración de **su** versión de
  > origen. Por eso el `## N.` de una base antigua puede llevar **otro título y otro contenido** que
  > el `## N.` de hoy. **Caso real, como ejemplo y no como definición:** `## 9.` fue «Convenciones de
  > trabajo» antes de ser «Cambios de requerimientos (versionado y deriva)». Comparar por número dos
  > secciones que sólo comparten el número las declara `INTACTO` **—la única fila que actúa sin
  > preguntar—** y escribe la doctrina del write-back dentro de una sección que trata de otra cosa,
  > **en silencio**, en el archivo de gobernanza de tu proyecto. Identificar por título y contenido
  > da `NUEVO` —«Añadir»—, que es lo correcto.

  Hecha esa identificación, y **sólo** entonces:

  | Estado de `§6` / `§9` | Qué haces |
  |---|---|
  | **`INTACTO`** | Aplicar el contenido nuevo **sin preguntar** |
  | **`MODIFICADO`** | **Conflicto: preguntar, y NO tocar la sección.** Tu texto **se queda como está** y el conflicto **se lista para el humano**; no escribas nada en ella. Cuando preguntes, **propón** conservar tu texto añadiendo encima lo nuevo — pero **aplicarlo es decisión tuya, no de la migración**. Si tu personalización fijaba quién hace el write-back, **es justo lo que este cambio toca** |
  | **`ELIMINADO`** —la sección existía en la base y tu proyecto **la borró**— | **Conflicto: preguntar, y NO reponer por tu cuenta.** Pudo borrarse a propósito. Si se repone, se repone **con tu decisión**, y si no, **dilo en el informe**: ese proyecto se queda sin la vía y sigue con el flujo anterior, que es válido |
  | **`NUEVO`** —tu base **no tenía** esa sección, porque instalaste el arnés antes de que existiera— | **Añadir.** No hay texto tuyo que conservar |
  | **`UNKNOWN`** —no se puede decidir sin adivinar— | **Terminal, como `CONFLICTO`, y no es negociable: te DETIENES y NO se aplica NADA de toda la corrida**, ni siquiera lo que salió `SAFE`. Déjalo constar y pregunta |

  **Y si alguna queda en conflicto, la migración es PARCIAL: `arnes_version` conserva el valor de
  origen y no se sube hasta resolverlo (Fase 5).**

  **No supongas que §6 y §9 están en tu base sólo porque están en la nuestra**, y ojo con la forma
  en que esto falla: **no basta con mirar si la sección FALTA.** Un proyecto instalado con una
  versión anterior puede **no tener** la sección —y entonces es **`NUEVO`**, no `INTACTO`—, pero
  puede también **tener ese mismo número ocupado por otra sección distinta**, y ése es el caso que
  engaña, porque la sección **está presente** y la comprobación de ausencia **no dispara**. Las dos
  situaciones se resuelven con la identificación de arriba: si el `## N.` de la base no es la misma
  sección que el `## N.` de hoy, **no es `INTACTO`** — es `NUEVO` si la sección de hoy no existe en
  tu proyecto bajo ningún número, y **`UNKNOWN`** si no puedes decidirlo sin adivinar. Clasifica
  **cada una por separado**: pueden salir en estados distintos.

  **Y un aviso entero:** esta vía **reduce despachos, no controles**. Si prefieres seguir con las
  cuatro fases siempre, **no migres estas secciones**: conservar tu texto es una respuesta válida.

### Hacia 1.35.0

- **`AGENTS.md` §6: la COORDINACIÓN ORIENTADA A ENTREGAS, en una sola sede; y la cabecera de
  `PENDING_APPROVAL.md`, que nombra qué impide la cola.** §6 gana un bloque con **seis reglas** de
  la sesión coordinadora —objetivo concreto en el encargo · todo bloqueo declara su alcance · un
  hallazgo no es, por sí solo, un encargo nuevo · decisiones humanas temprano y con su forma ·
  presupuesto del ciclo completo · avance observable—, y **dos párrafos vigentes de esa misma
  sección quedan reescritos en su promesa completa**: «Loop de error» deja de prometer que un
  hallazgo **devuelve** el REQ al desarrollador por sí solo, y «Mecanismo de gate» deja de
  prometer que una decisión pendiente **detiene todo** — ahora nombra la **transición exacta** que
  queda impedida, **marcar un REQ como `completado`**, y dice qué sigue permitido. La **cabecera
  de `PENDING_APPROVAL.md`** cambia por lo mismo: es el texto que se lee **al encolar**.

  **LO PRIMERO, porque decide cómo se lee el resto: esta entrada se prepara CON la versión y NO
  declara que el cambio haya llegado a tu proyecto.** Tu `AGENTS.md` sigue **congelado** hasta que
  corras esta migración y resuelvas sus conflictos; que el texto exista en el plugin no cambia una
  coma del tuyo, y migrar es **un acto tuyo**.

  **Qué NO cambia, y va antes que las seis reglas porque es lo que se perdería leyendo de prisa:**
  el `qa-tester` y el `auditor-seguridad` **conservan íntegra** su capacidad de **detectar,
  registrar, clasificar y bloquear**, y el **veto** de seguridad sigue disponible en cualquier
  momento; **ninguna clasificación de la coordinadora retira, degrada ni pospone un veredicto**;
  el **tope de vueltas dev↔QA por REQ** y su no-reinicio **se conservan** —se les añade que
  tampoco se reinician por **cambio de rol, de fase o de nombre** de la comisión **ni abriendo un
  REQ nuevo**—; las **tres clases** del campo `Hallazgos abiertos:` (`usuario/dinero`, `contrato`,
  `instrumento`) **no se renombran** ni se mezclan con la clasificación nueva; y **ningún hook
  cambia**, tampoco `.arnes/config.json`: `guard-completado` sigue denegando el cierre de
  **cualquier** REQ mientras la cola tenga entradas. Lo que la reescritura corrige es que el
  **texto** prometía más de lo que ningún mecanismo sostiene. **Ninguna fila del merge —tampoco
  `INTACTO` ni `NUEVO`— escribe una autorización ni concede una facultad:** lo que se instala es
  **texto normativo** sobre cómo despacha tu sesión coordinadora, y **ningún agente gana ni pierde
  facultades** por migrarlo.

  **Primero, la separación sin la cual esta migración se detiene entera: los agentes NO se
  migran.** Los **cuatro agentes los provee el plugin** (`.claude/agents/`): tu proyecto **no
  tiene copia propia** que clasificar, y `arnes-init` **no** deja base suya en
  `.arnes/plantillas-origen/`, porque ahí sólo van los `.tpl` y los agentes no lo son. **No los
  clasifiques, no los busques y no los pongas en el plan:** una clasificación sin base recuperable
  es `UNKNOWN`, y un `UNKNOWN` **detiene la corrida completa** — incluida `§6`, que sí es
  migrable. Sus definiciones llegan con las referencias a esta sede **al actualizar el plugin**,
  no por esta migración; **dilo en el informe** y sigue.

  **Lo que SÍ se migra** son **dos** artefactos, y se clasifican **por separado**: la sección
  `§6` de tu `AGENTS.md` y la **cabecera de tu `PENDING_APPROVAL.md`** —el bloque de cita que abre
  el archivo, **antes** de `## Pendientes`; **las entradas de la cola no se tocan nunca**—. Los
  dos se copiaron de plantilla y por eso tienen base con la que comparar. Y
  **`templates/AGENTS.md.tpl`** y **`templates/PENDING_APPROVAL.md.tpl`**, si tu proyecto los
  conserva, también tienen base y entran en el merge: si los personalizaste saldrán `MODIFICADO`,
  y eso es **conflicto** — tu texto **no se toca** y la decisión es tuya.

  **Y antes de clasificar `§6`, identifícala por CONTENIDO Y TÍTULO, nunca sólo por el número.**
  Es la misma regla terminal de «Tres resultados, nunca dos», por la misma propiedad que ya se
  explica en «Hacia 1.34.0»: **el arnés ha renumerado y retitulado secciones de `AGENTS.md` a lo
  largo de su historia**, así que el número **no identifica** una sección. Comprueba que el título
  y el contenido del `## N.` de tu proyecto y el del `## N.` de la base **son la misma sección**;
  **si no lo son, o si no puedes afirmarlo sin adivinar, es `UNKNOWN`**: la migración **se
  detiene, no se aplica nada** —tampoco lo que salió `SAFE`— **y el documento se conserva
  intacto**. La cabecera de `PENDING_APPROVAL.md` se identifica por la misma propiedad y no por
  su número de línea: es el bloque de cita anterior al primer `## `. Esto **manda sobre la tabla
  de abajo**.

  Hecha esa identificación, y **sólo** entonces:

  | Estado de cada artefacto | Qué haces |
  |---|---|
  | **`INTACTO`** | Aplicar el contenido nuevo **sin preguntar** |
  | **`MODIFICADO`** | **Conflicto: preguntar, y NO tocar la sección.** Tu texto **se queda como está** y el conflicto **se lista para el humano**; no escribas nada en ella. Cuando preguntes, **propón** conservar tu texto añadiendo encima lo nuevo — pero **aplicarlo es decisión tuya, no de la migración**. Si tu personalización reescribió «Loop de error», «Mecanismo de gate» o la cabecera de la cola, **es justo lo que este cambio toca** |
  | **`ELIMINADO`** —existía en la base y tu proyecto **lo borró**— | **Conflicto: preguntar, y NO reponer por tu cuenta.** Pudo borrarse a propósito. Si no se repone, **dilo en el informe**: ese proyecto se queda sin las seis reglas y sigue con su texto anterior, que es válido |
  | **`NUEVO`** —tu base **no tenía** ese artefacto— | **Añadir.** No hay texto tuyo que conservar |
  | **`UNKNOWN`** —no se puede decidir sin adivinar— | **Terminal, como `CONFLICTO`: te DETIENES y NO se aplica NADA de toda la corrida**, ni siquiera lo que salió `SAFE`. Déjalo constar y pregunta |

  **Y si queda en conflicto, la migración es PARCIAL: `arnes_version` conserva el valor de origen
  y no se sube hasta resolverlo (Fase 5).**

  **Y un aviso entero:** estas seis reglas **no reducen controles**, reordenan **quién decide qué
  trabajo se abre**. Si prefieres seguir con tu texto actual, **no migres estas secciones**:
  conservarlo es una respuesta válida.

- **Fidelidad al encargo: el pedido del propietario llega al REQ con su fuente, y cada obligación
  queda emparejada con el criterio que la cubre.** Esta entrada **se prepara con la versión y NO
  declara que el cambio haya llegado a tu proyecto**: tu `AGENTS.md` y tu `requirements/README.md`
  siguen **congelados** hasta que corras esta migración, y migrar es **un acto tuyo**. **Ningún hook
  cambia**, tampoco `.arnes/config.json`: ninguna puerta lee la sección nueva, que vive debajo del
  primer `## ` del REQ, fuera de la cabecera. Toca **cuatro** archivos heredables:
  - **`templates/AGENTS.md.tpl`** — la regla 1 del bloque «La coordinación se orienta a entregas»
    (§6) gana **un** párrafo: el encargo al `analista-requerimientos` lleva el pedido con fuente
    identificable (o `fuente no disponible`), y antes de despachar la implementación de lo que
    dependa de una diferencia que requiera al propietario, ésta tiene que estar resuelta por él.
  - **`templates/requirements-README.md.tpl`** — la plantilla del REQ: `Origen:` pide fuente
    identificable, y «Trazabilidad» gana la subsección `### Correspondencia con el encargo`, sitio
    único de su forma, su vocabulario y cuándo se actualiza.
  - **`agents/analista-requerimientos.md`** — conservar el pedido y rellenar la correspondencia
    remitiendo a la plantilla; que partir un REQ no concede autoridad sobre el alcance; la regla
    de que un REQ existente ya aprobado no vuelve a `borrador` porque su pedido no se conservó; y
    un punto más en su Definition of Ready.
  - **`agents/qa-tester.md`** — contrasta la correspondencia antes de probar, sin rehacer el
    análisis, y lo declara en el paréntesis de evidencia de su **único** veredicto `QA:`.

  **Qué se migra:** la regla 1 de `§6` de tu `AGENTS.md` y la sección `## Plantilla` de tu
  `requirements/README.md`, cada una **por separado**, con la misma identificación por contenido y
  título y la misma tabla de estados de la entrada anterior. **Los dos agentes no se migran:** llegan
  **al actualizar el plugin**, por la misma separación que explica la entrada anterior. **Y no se
  retroajusta nada:** los REQ que ya tienes no se reabren para añadirles la correspondencia; qué
  pasa con uno ya aprobado cuyo pedido no se conservó lo dice la definición del
  `analista-requerimientos`. Si prefieres seguir con tu texto actual, conservarlo es una respuesta
  válida.

- **`Hallazgos abiertos:` con gramática CERRADA (REQ-031, ADR-013): una lista que la puerta no puede
  interpretar, el campo declarado dos veces o un valor por encima de su techo de tamaño ya no dejan
  cerrar. ES UN CAMBIO DE CONDUCTA Y DE COMPATIBILIDAD.** La conducta nueva **llega con el plugin**,
  sin migrar nada: está en `hooks/guard-completado.sh` y `hooks/lib.sh`, y no hay llave nueva en
  `.arnes/config.json`. Esta entrada **se prepara con la versión y NO declara que el cambio haya
  llegado a tu proyecto**: la puerta deniega con la regla nueva **desde que actualizas el plugin**,
  pero tu `requirements/README.md` y tu `AGENTS.md` siguen **congelados**, y **no explicarán esa
  regla** hasta que corras esta migración; migrar es **un acto tuyo**.
  - **Lo que deja de cerrar, dicho entero.** La lista se separa **sólo** con comas fuera de todo
    paréntesis, y cada hallazgo es `ID (clase)` o `ID (clase, evidencia)`; **tras el `)` que cierra un
    hallazgo sólo cabe la coma o el fin del campo**. Ejemplos **no exhaustivos** de lo que ahora
    deniega —la regla es la de la frase anterior—: un separador que no es la coma (`;`, `·`, `/`,
    `y`); **texto o una nota detrás del paréntesis**, como `QA-006 (instrumento) — REQ-007`, que se
    aceptaba **hasta `v1.34.0`**; dos paréntesis en un hallazgo, uno sin cerrar o uno sobrante; un
    elemento vacío; un ID con blancos, con tilde o con marcado; y una ausencia mezclada con
    hallazgos. La puerta **nombra el fragmento que no entendió** y no reescribe el campo. La forma
    equivalente conserva la nota **dentro** del paréntesis: `QA-006 (instrumento, REQ-007)`. El campo
    **declarado más de una vez** con su forma exacta **deniega**: no elige la primera ni la última y
    no las fusiona. Un valor de **más de 16 384 bytes** —contados en bytes y **antes** de normalizar—
    deniega sin interpretarse. **Aparte de esas reglas, sus limitaciones conocidas y sin reparar:**
    - **SEC-115:** un hook que el cliente mata por tiempo no deniega. La denegación por tamaño está
      medida hasta 255 371 bytes, que deniega a tiempo; por encima **no hay promesa**.
    - **SEC-118:** el motivo del campo repetido cita cada línea en un argumento cuyo límite es de
      **bytes**, y por encima el hook sale **sin decisión** y no deniega. Medido a nivel de hook en
      Linux/WSL2, una corrida por punto: con líneas **ASCII** de 60 caracteres o más, 1 601 deniegan y
      1 801 salen sin decisión; con líneas **ASCII** cortas, 2 501 deniegan y 3 000 no; con caracteres
      **multibyte** en la parte citada salen sin decisión 1 601 líneas con `ñ`, 1 001 con caracteres de
      4 bytes y 2 501 cortas con `ñ`. No hay cifra para otros caracteres, hosts ni tamaños; en Windows
      no está medido, y que el cliente trate como permitir un hook sin decisión es inferido.

    Las dos son **límites declarados de 1.35.0, no aceptados como definitivos**, con su reparación
    fail-closed decidida para 1.36.0: entrada «Lo que 1.35.0 publica sin reparar», al final de este apartado.

    Y, como toda regla de la puerta de cierre, ésta juzga el documento que la puerta reconstruye. Lo
    que no puede reconstruir se deniega antes de llegar a ella: es la entrada «Edición no
    reconstruible», más abajo.
  - **Sin eufemismo: las versiones anteriores pudieron cerrar un REQ con un hallazgo bloqueante
    abierto.** Hasta `v1.34.0`, `SEC-A (instrumento) · SEC-B (usuario/dinero)` y
    `SEC-A (instrumento); SEC-B (contrato)` dejaban cerrar: la puerta sólo partía por comas y no leía
    lo que seguía al primer paréntesis (ADR-013).
  - **Qué hay que auditar: la pregunta es de ESTADO** —**cuáles de tus REQ en estado terminal tenían
    en `Hallazgos abiertos:` un hallazgo `usuario/dinero` o `contrato` que la puerta anterior no
    leyó**—. Ése no estaba autorizado a cerrar y se reabre (`AGENTS.md` §9). **Ningún comando responde
    esa pregunta:** `tools/arnes-lectura.sh` de esta versión **no juzga la gramática del campo ni su
    techo**; sólo nombra el campo **repetido**, por la vía de la entrada siguiente («Cabecera
    ambigua»). Se hace a mano, REQ a REQ. Un REQ cerrado cuyo campo sólo usa una forma ya no admitida
    **sin** esconder un bloqueante no se reabre por eso: la puerta juzga **la transición** a
    `completado`, y la forma se corrige la próxima vez que ese REQ vaya a cerrarse.
  - **Qué se migra de texto:** la **fila de `AGENTS.md` §13** que empieza «No completar con un
    hallazgo `usuario/dinero` o `contrato` abierto» y la sección **«Clases de hallazgo»** de tu
    `requirements/README.md` —la sintaxis cerrada, qué lee la puerta y qué no, y el techo—, cada una
    **por separado** y con la misma identificación por contenido y título y la misma tabla de estados
    de la primera entrada de este apartado. Se migra **el texto de esta versión**, que ya incluye el
    ajuste de REQ-023 al párrafo «Qué lee la puerta, y qué no». Si prefieres seguir con tu texto
    actual, conservarlo es una respuesta válida; la puerta decide igual. **Lo que no se migra:** la
    casilla del campo `Archivos:` que gana la Definition of Ready del `analista-requerimientos` llega
    **al actualizar el plugin**, por la misma separación de la primera entrada de este apartado.

- **Cabecera ambigua (REQ-023, ADR-014): una clave de control escrita de otra forma, o declarada más
  de una vez, ya no se lee como AUSENCIA — deja la cabecera ambigua, y una cabecera ambigua no deja
  cerrar. ES UN CAMBIO DE CONDUCTA Y DE COMPATIBILIDAD.** Las claves de control son `Estado`, `QA`,
  `Seguridad`, `Sensible a seguridad`, `Hallazgos abiertos` y `Rigor`. La conducta nueva **llega con
  el plugin**, sin migrar nada: está en `hooks/lib.sh` y `hooks/guard-completado.sh`, y no hay llave
  nueva en `.arnes/config.json`.
  - **Lo que deja de cerrar, dicho entero.** Una cabecera con una **variante** de una clave de control
    —`HALLAZGOS ABIERTOS:`, `qa:`, un blanco de más, un BOM, un espacio de anchura cero o un espacio
    duro delante o dentro de la clave, `- Rigor:`, `1. QA:`— **deniega el cierre**. Y una clave de
    control **declarada dos veces deniega el cierre también con el MISMO valor**: `QA: aprobado` dos
    veces cerraba hasta `v1.34.0` y ahora no cierra (cambio de compatibilidad aceptado expresamente
    por el propietario, ADR-014); `Hallazgos abiertos` repetida con su forma exacta, cuando es la única
    ambigüedad, la decide la regla de la entrada anterior, con su limitación SEC-118. La puerta cita las líneas,
    con los caracteres invisibles escritos de forma legible. **Esta regla alcanza sólo a las ediciones
    cuyo documento resultante la puerta reconstruye:** un `Write`, o un `Edit`/`MultiEdit`
    reconstruible. La edición que la puerta no puede reconstruir la deniega otra regla: la entrada
    «Edición no reconstruible», abajo. Dentro de ese alcance, **sólo
    deniega** cuando la cabecera resultante es ambigua, **alguna** línea `Estado` —la exacta, una
    repetida o una variante— dice el estado terminal y el `Estado` que gobierna en disco (la primera
    declaración exacta; si no hay ninguna, nada lo decía) **no** lo decía. Por eso **reabrir** un REQ
    cerrado no se bloquea, ni una edición tras la cual ninguna línea `Estado` dice el terminal; pero si
    en disco el terminal está en una línea `Estado` que **no** es la que gobierna —una variante, o una
    exacta que no es la primera— y la que gobierna no lo dice o no existe, se deniega toda edición **de
    ese alcance** que conserve esa línea mientras la cabecera siga siendo ambigua, y no la que la
    retira o la corrige (detalle en `requirements/REQ-023.md` CA-01 del arnés). La salida es de una
    línea: **cada clave de control una sola vez, escrita como la plantilla** de
    `requirements/README.md` (§ «Veredictos de validación»).
  - **Sin eufemismo: las versiones anteriores pudieron cerrar un REQ `critico` sin validación ni
    auditoría.** Un BOM —el que añade PowerShell al redirigir— delante de `Sensible a seguridad: sí`,
    con `Rigor: ligero`, cerraba un REQ con `QA: pendiente` y `Seguridad: pendiente`; y un carácter
    invisible, o unas mayúsculas, delante de `Hallazgos abiertos:` hacían desaparecer un hallazgo
    `contrato` que bloqueaba (SEC-047, R-012; QA-031-01).
  - **Qué hay que auditar, y va antes que cualquier comando: la pregunta es de ESTADO** —**cuáles de
    tus REQ en estado terminal NO cerrarían hoy**, leídos con el lector de esta versión—. **Ningún
    comando la responde todavía**: se hace a mano, REQ a REQ, comprobando que su cabecera vigente
    autorizaba el cierre; el que no lo autorizaba se reabre (`AGENTS.md` §9).
  - **El barrido POR VÍA que sí puedes correr, y lo que NO encuentra** —ayuda a empezar por los
    sospechosos y **no** sustituye a la pregunta de arriba—. Con el informe de **esta** versión (el de
    tu versión instalada no las ve), antes o después de actualizar:
    `bash <plugin 1.35.0>/tools/arnes-lectura.sh <tu proyecto>` nombra cada línea ambigua —el REQ, la
    línea escapada, la clave y la consecuencia— por la vía de las anomalías y **sale ≠ 0** mientras
    quede alguna, también en un archivo que el informe cuenta como nota. **Ese comando interroga UNA
    vía, no la propiedad** —las variantes y repeticiones de las claves de control dentro de la
    frontera declarada—, y **no hallar nada NO acredita ausencia de exposición**. Vías conocidas que
    **no** encuentra (ejemplos **no exhaustivos**; el sitio único donde viven es
    `docs/seguridad/registro-seguridad.md`, SEC-047, SEC-050 y, para los cierres del pasado, SEC-117): una letra sustituida por un
    **homoglifo**; una letra ASCII **de más, de menos o cambiada**; unos **dos puntos que no son
    ASCII**; una línea con un **signo de estructura** visible —también un espacio duro en lugar del
    blanco que sigue al guion del marcador—; una clave de **más de 256 bytes**, que es una
    **limitación**: se sigue leyendo como ausencia y ese límite **no** la protege; **comentar o
    borrar** la línea de un campo (SEC-050, la semántica de la ausencia, que esta versión no cambia);
    un REQ que **ya se cerró con una versión anterior** por un `Edit` cuyo `old_string` el hook no
    encontraba literal y la herramienta sí —comillas tipográficas o `\uXXXX`—, que pudo no pasar por
    ninguna puerta (SEC-117; desde esta versión esa vía se deniega, entrada «Edición no reconstruible»);
    y lo que un lector de bash no ve (un byte NUL, un archivo en UTF-16). Si el informe no saca nada,
    **no has terminado**: vuelve a la pregunta de estado.
  - **Qué se migra de texto:** la **fila nueva de `AGENTS.md` §13** («una cabecera ambigua no deja
    cerrar») y el párrafo de **`requirements/README.md` § «Veredictos de validación»** que define la
    variante y su frontera, cada uno **por separado** y con la misma identificación por contenido y
    título y la misma tabla de estados de la primera entrada de este apartado. **Las notas de las
    versiones pasadas no cambian**: la regla de «última aparición» sigue siendo con la que **se leen**
    los valores; lo nuevo es que, **al cerrar**, una clave de control repetida deniega, dentro del
    alcance que esta entrada declara y con la limitación que la anterior nombra aparte.

- **Edición no reconstruible (REQ-023 CA-13, ADR-015): un `Edit` o `MultiEdit` de `requirements/` que
  la puerta no puede reconstruir se DENIEGA. ES UN CAMBIO DE CONDUCTA Y DE COMPATIBILIDAD.** La conducta
  nueva **llega con el plugin**, sin migrar nada: está en `hooks/guard-completado.sh`, y no hay llave nueva
  en `.arnes/config.json`. Esta entrada **se prepara con la versión y NO declara que el cambio haya
  llegado a tu proyecto**: tu `AGENTS.md` y tu `requirements/README.md` siguen **congelados** hasta que
  migres, y migrar es **un acto tuyo**.
  - **Lo que deja de pasar.** Un `Edit`/`MultiEdit` dentro de `requirements/` cuyo `old_string` no está
    **literal** en el archivo —por ejemplo, con comillas rectas donde el archivo tiene tipográficas, o con
    un escape `\uXXXX`— se deniega **aunque no toque el estado**. Vale también al reabrir un REQ y en
    archivos que no son REQ, como `requirements/README.md`. Hasta `v1.34.0` esa edición se juzgaba por su
    fragmento y, si no escribía el estado terminal, pasaba.
    - Lo que la puerta **sí** puede reconstruir se juzga como siempre: la edición literal, la creación de
      un archivo con una sola edición de `old_string` vacío —que se juzga entera, como un `Write`— y la
      reapertura literal.
    - Qué cuenta exactamente como reconstruible está en `requirements/REQ-023.md` CA-13 del arnés; esta
      guía no lo transcribe.
  - **La salida:** el motivo dice qué edición falló y enseña el comienzo de su `old_string` con los
    caracteres invisibles escritos de forma legible. Lee el archivo y repite la edición copiando el
    `old_string` **literal** —comillas, guiones, espacios y acentos tal como están—.
  - **Sin eufemismo: las versiones anteriores pudieron cerrar un REQ sin pasar por ninguna puerta.** Con
    un `Edit` cuyo `old_string` el hook no encontraba literal y la herramienta sí, que sustituía sólo el
    valor del estado, un REQ `critico` quedaba `completado` con QA y seguridad pendientes, un `contrato`
    abierto y la cola ocupada (SEC-117). Está reproducido en el CLI 2.1.285, con comillas tipográficas.
  - **Qué hay que auditar: la pregunta es de ESTADO,** y es la misma de la entrada anterior: **cuáles de
    tus REQ en estado terminal no cerrarían hoy**. Un REQ que se cerró por esa vía no deja rastro que un
    comando pueda encontrar: `tools/arnes-lectura.sh` **no** lo detecta. Se hace a mano, REQ a REQ,
    comprobando que su cabecera vigente autorizaba el cierre; el que no lo autorizaba se reabre
    (`AGENTS.md` §9).
  - **Qué se migra de texto:** la **fila nueva de `AGENTS.md` §13** («un `Edit`/`MultiEdit` de
    `requirements/` que la puerta no puede reconstruir se deniega»), la **cláusula que sigue a la tabla de
    §13** —que separa la propiedad de cada fila de sus limitaciones y dice qué pasa con la edición no
    reconstruible— y los párrafos de **`requirements/README.md` § «Veredictos de validación»** que remiten
    a esta regla. Cada uno va **por separado**, con la misma identificación por contenido y título y la
    misma tabla de estados de la primera entrada de este apartado. Si prefieres seguir con tu texto
    actual, conservarlo es una respuesta válida; la puerta decide igual.

- **Identidad del destino y archivo ilegible (REQ-007 CA-47 y CA-45, ADR-016): las puertas juzgan el
  ARCHIVO que la escritura alcanzaría, no la forma de su ruta, y un REQ que la puerta no puede leer entero
  no se edita. ES UN CAMBIO DE CONDUCTA Y DE COMPATIBILIDAD.** La conducta nueva **llega con el plugin**, sin
  migrar nada: está en `hooks/lib.sh`, `hooks/guard-codigo.sh` y `hooks/guard-completado.sh`, y no hay llave
  nueva en `.arnes/config.json`. Esta entrada **se prepara con la versión y NO declara que el cambio haya
  llegado a tu proyecto**: tu `AGENTS.md` y tu `requirements/README.md` siguen **congelados** hasta que
  migres, y migrar es **un acto tuyo**.
  - **Lo que deja de pasar** (ejemplos **no exhaustivos**; la regla está en `requirements/REQ-007.md` CA-47 y
    CA-45 del arnés, y esta guía no la transcribe):
    - una escritura a código protegido o a `requirements/` por una **ruta equivalente** —con `..`, `./` o
      `//`, relativa a otro directorio de trabajo, o a través de un directorio enlazado—, que hasta
      `v1.34.0` se juzgaba por su texto;
    - una escritura a través de un enlace situado **fuera** del proyecto que apunta a una zona protegida, y
      una escritura por `Bash` a través de un enlace hacia una zona protegida;
    - un `Edit`/`MultiEdit` sobre un REQ que la puerta **no puede leer entero** —un byte NUL, un archivo en
      UTF-16 como el que produce PowerShell 5.1 al redirigir, un archivo sin permiso de lectura—, **aunque no
      toque el estado**;
    - una escritura cuyo destino la puerta **no puede determinar**: un directorio que no se puede recorrer,
      un bucle de enlaces, `..` sobre un directorio que todavía no existe, una ruta relativa cuando el
      directorio de trabajo lleva un retorno de carro —también fuera de las zonas protegidas—, o un
      `Edit`/`Write`/`MultiEdit` cuyo `file_path` lleva un salto de línea o un retorno de carro —sea cual sea
      la ruta y el agente: no está medido qué archivo escribiría la herramienta con ese argumento—.
    - una escritura a una zona protegida a través de un enlace o un alias bajo `/dev/` o `/proc/` —un enlace en
      `/dev/shm`, `/proc/self/root`, `/proc/self/cwd`—: **ningún directorio queda fuera** de la identificación, y
      un proyecto situado bajo `/dev/` recibe las mismas reglas que en cualquier otro sitio;
    - una ruta que **depende del proceso que la abre** y que la puerta no puede situar: por `Edit`, `Write` o
      `MultiEdit`, toda ruta que pasa por el directorio de trabajo o por un descriptor del proceso del host
      —`Write /dev/stderr` incluido—, **a todo agente**; por `Bash`, una ruta detrás de un descriptor, un
      pseudoarchivo del proceso o `/proc/self/cwd/…` sin directorio de trabajo, a quien no es el agente de código.
      `> /dev/null` y `> /dev/stderr` por `Bash` **siguen pasando**, sin excepción por su nombre;
    - un comando de `Bash` con un heredoc cuyo delimitador lleva un retorno de carro —por ejemplo, el de un
      script con fines de línea CRLF—, **a todo agente**: la puerta no puede saber dónde acaba el cuerpo.
    - **(en el arnés: construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía manual
      (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por
      impedimento del proveedor)** un heredoc cuyo cuerpo tiene, antes de su última línea, una línea que es su
      delimitador seguido de un retorno de carro, **a todo agente**, aunque el shell la lea como cuerpo: es una restricción concreta que decidió el propietario del arnés (SEC-124), y la
      salida es la misma, líneas acabadas sólo en salto de línea;
    - **(en el arnés: construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía manual
      (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por
      impedimento del proveedor)** una escritura cuyo destino va tras una continuación de línea se juzga por el destino que escribe el shell (SEC-125); una continuación, por sí sola,
      no deniega nada, **salvo** al final de la línea que abre un heredoc: ese comando se deniega **a todo agente**,
      sea cual sea lo que siga, porque el shell y la puerta no coinciden en dónde empieza el cuerpo (LC10, decisión
      del propietario del arnés). La salida: escribir esa línea entera, sin la continuación al final.
    - Y la entrada del hook se lee **campo a campo**: un salto de línea dentro del directorio de trabajo, del
      agente o de la ruta ya no desplaza los demás campos ni hace juzgar otra cosa. El retorno de carro del
      directorio de trabajo, de la ruta y del nombre de la herramienta se cuenta antes de que la lectura lo
      pueda recortar, así que tampoco hace juzgar otro directorio, otra ruta u otra herramienta: lo que no se
      puede determinar se deniega. **Y el texto de un comando de `Bash` llega con sus retornos de carro:** un
      destino cuyo nombre acaba en uno se juzga con él, que es el nombre que escribe el shell.
  - **Lo que pasa a permitirse: ocho clases de casos, y sólo ésas** (REQ-007 CA-66, punto 5, del arnés,
    que lo enuncia como regla): una ruta relativa que casaba con una zona protegida sólo porque se leía desde la
    raíz cuando el directorio de trabajo era otro; un `Write` que cierra un REQ ilegible con todo en verde,
    porque se juzga entero; una ruta equivalente al manifiesto mientras está ilegible; tres rutas con `..` que
    casaban con una zona protegida sólo por su texto y designan un archivo de fuera —por ejemplo,
    `src/../README.md` por `Write` o por `Bash`—; y un destino de `Bash` cuyo nombre acaba en un retorno de
    carro y que con él ya no casa con el patrón que casaba sin él —`app/a.ts␍` con `app/*.ts`—. Ninguno debilita
    una protección: todos designan lo que de verdad escribe el shell. **(En el arnés, construido en `10ac6c4` y
    `36a0d27`; validado por el propietario por vía manual (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma
    del qa-tester ni del auditor-seguridad por impedimento del proveedor:** la forma de SEC-124, que sobre el
    código anterior del candidato pasaba sin declarar, vuelve a denegarse; y con la reparación de SEC-125 se suma
    una octava clase —un destino que se juzgaba por su fragmento anterior a una continuación de línea y que, unido como lo une el
    shell, está fuera de las zonas protegidas—, que tampoco debilita ninguna protección.)
  - **Una orden de git con un retorno de carro se juzga también sin él:** `git stash␍`, `git reset --hard␍`,
    `git checkout .␍` o `git clean␍ -f` se deniegan como sin el retorno de carro, porque lo que git haga con
    ellos depende de una configuración que la puerta no lee —con `help.autocorrect`, `git stash␍` y
    `git clean␍ -f` se corrigen y se ejecutan—. Si tus agentes escriben comandos con fines de línea CRLF,
    conviértelos.
  - **Lo que se conserva:** por `Edit`/`Write`/`MultiEdit` no se escribe a través de un enlace situado dentro
    del proyecto, sea cual sea su destino (entrada «Hacia 1.31.0»). Lo que esa entrada decía —«el arnés juzga
    la ruta escrita, no su destino»— **queda superado**: los directorios enlazados y los enlaces de fuera se
    resuelven.
  - **La salida:** cada motivo dice la causa y cómo corregirla —escribir por una ruta cuyos directorios
    existan y se puedan recorrer, sin saltos de línea ni retornos de carro, y absoluta si es el directorio de
    trabajo el que lleva el retorno de carro; escribir la ruta del archivo por su nombre, sin pasar por la
    entrada en `/proc` de un proceso ni por sus descriptores; escribir el comando con líneas acabadas sólo en
    salto de línea; o dejar el REQ legible entero: quitar el NUL, guardarlo en UTF-8, devolverle el permiso de
    lectura—.
  - **Sin eufemismo: las versiones anteriores pudieron dejar pasar escrituras protegidas por una ruta
    equivalente.** Reproducido en el CLI 2.1.285: por un directorio enlazado a `requirements/`, un REQ
    `critico` con todo en rojo quedó `completado`; por `Bash`, `..` creó código protegido desde la
    coordinadora y cerró un REQ (SEC-119). Y con un REQ en UTF-16LE, un `Edit` se aplicó sin que la puerta
    pudiera leer el archivo (O-11).
  - **Qué hay que auditar: la pregunta es de ESTADO,** la misma de las entradas anteriores: **cuáles de tus
    REQ en estado terminal no cerrarían hoy**, y qué archivos protegidos cambiaron sin pasar por el agente
    de código. Una escritura por esas vías no deja rastro que un comando pueda encontrar. Antes de
    actualizar, además: `find . -type l -not -path './.git/*'` para ver los enlaces del proyecto —en
    particular los directorios enlazados hacia zonas protegidas o desde ellas— y comprueba que ningún REQ
    tenga un byte NUL ni esté en UTF-16: con esta versión no podrás editarlo hasta dejarlo legible. Si tus
    agentes generan comandos con fines de línea CRLF y heredocs, con esta versión se denegarán: conviértelos a
    líneas acabadas sólo en salto de línea.
  - **Lo que NO cubre** (ejemplos **no exhaustivos**; la sede es REQ-007 CA-47 del arnés): un cambio del
    sistema de archivos entre la decisión del hook y la escritura; un `cd` dentro del propio comando de
    `Bash`; enlaces duros y montajes; los límites de la detección de lo que depende del proceso —una cadena que
    sale con `..` de la entrada de `/proc` del propio hook, que se juzga por el archivo al que llega el hook y
    **puede salir permitida sobre un archivo protegido** (medido a nivel de hook; desde el host, inferido y no
    ejercido; SEC-123, abierto y sin aceptar; detalle en las notas de 1.35.0), o un sistema sin `/proc`—;
    que el delimitador de un heredoc sea el único sitio donde la puerta no sigue un retorno de carro, que es una
    declaración del arnés, no una medición exhaustiva; sistemas de archivos que no distinguen mayúsculas; y
    Windows/MSYS, `MultiEdit` en el host y el editor interactivo, que no se han ejercido para esta regla
    (plataformas en las notas de 1.35.0). El retorno de carro del texto de `Bash` ya **no** está en esta lista:
    en esta versión llega a la puerta.
  - **Qué se migra de texto:** la **fila nueva de `AGENTS.md` §13** («las puertas juzgan el archivo que la
    escritura alcanzaría…»), los **puntos 2 y 3 de la cláusula que sigue a la tabla de §13** y el párrafo de
    **`requirements/README.md` § «Veredictos de validación»** que remite a REQ-007 CA-45. Cada uno va **por
    separado**, con la misma identificación por contenido y título y la misma tabla de estados de la primera
    entrada de este apartado. Si prefieres seguir con tu texto actual, conservarlo es una respuesta válida;
    la puerta decide igual.

- **Lo que 1.35.0 publica sin reparar: límites declarados por el propietario del arnés el 2026-10-03, y lo que
  sus corridas no acreditan.** Esta entrada **no migra nada**: dice lo que la versión que instalas **no**
  protege, para que no lo des por cubierto. **«Límite declarado» no es «riesgo aceptado», y ninguna de estas
  decisiones repara lo que decide.** Las condiciones medidas y sus fuentes están en las notas de 1.35.0, «Límites
  declarados, con alcance y consecuencia», y lo que no se ha medido en el host ni en Windows/MSYS, en «Lo no
  medido»; aquí va lo que necesita saber un proyecto que actualiza.
  - **Un hook que no emite su decisión no deniega (SEC-115 y SEC-118).** La puerta de cierre decide sólo si el
    hook alcanza a medir **y a emitir su decisión**. Lo impiden, medido, un veredicto de ≈ 255 KB o un `Write` de
    ≈ 2 MB, que agotan los 60 s del cliente (SEC-115), y un motivo de más de ~128 KiB **en bytes** (SEC-118; sus
    cifras, en la entrada de `Hallazgos abiertos:`, arriba). **Depende de la disciplina de tus agentes:** no
    escribir evidencia de cientos de KB en `QA:`, `Seguridad:`, `Rigor:`, `Sensible a seguridad:` ni `Estado:`,
    ni un REQ de MB por `Write`; sólo `Hallazgos abiertos:` tiene techo. No aceptados como definitivos;
    reparación fail-closed decidida para 1.36.0.
  - **El análisis de un comando de `Bash` grande es lento (REQ-007 CA-54 del arnés, QA-023-10): aceptado con
    alcance para 1.35.0.** En el máximo declarado (131 072 bytes) tarda 9,0–9,2 s en Linux/WSL2, frente al
    criterio de < 5 s, y 20,4–28,9 s medidos en una máquina con Windows/MSYS; en el valor por defecto
    (65 536 bytes) también supera el criterio en Linux/WSL2. Un comando de ese tamaño **se juzga, pero tarda**: no
    es un fallo abierto. Un margen no es una garantía: en un equipo más lento o más cargado el hook podría agotar
    el tiempo, y eso ya es SEC-115. No se sube el umbral ni se reduce la entrada; reparación en 1.36.0.
  - **Un fallo de `jq` al leer o trocear la entrada del hook deja pasar (SEC-120).** Medido a nivel de hook con
    entradas malformadas; desde el host, no alcanzable en lo observado y sin verificar. Reparación decidida para
    1.36.0, antes del 2026-10-29: ese fallo → deny.
  - **Las escrituras por intérprete o script no se detectan (hueco C).** `guard-codigo` no ve lo que escriben
    `python`, `node`, `bash script.sh`, un formateador que reescribe archivos, `patch` ni `git apply`, y no hay
    detección posterior. La versión promete que las herramientas de edición y las escrituras evidentes por shell
    se deniegan, **no** que sólo el agente de código modifique código protegido: eso depende de que ningún agente
    use esas vías. Su detección se evalúa en una versión posterior, **sin fecha**.
  - **Fronteras de la identidad del destino (P-119-A: F2, F5 y F7; y SEC-123, con F3 corregida).** No se
    promete: un `cd` dentro del propio comando de `Bash` y las expansiones del shell (F2); un enlace situado dentro
    de una zona protegida que sale de la raíz del proyecto, escrito por la ruta directa a su destino (F5); que el
    directorio de trabajo que recibe el hook sea el del comando (F7); ni el límite de la detección de lo que
    depende del proceso, que puede salir permitido sobre un archivo protegido (SEC-123; «Lo que NO cubre», en la
    entrada anterior). Abiertos y no aceptados como riesgo; la decisión no fija versión de reparación. Con ella, el
    propietario del arnés resolvió la pregunta que los planteaba (P-119-A) **como límites declarados**, no como
    riesgo aceptado. Si escribes una prueba o un informe sobre el límite de SEC-123, la sede es REQ-007 CA-47, F3,
    del arnés, no un comentario del código. *(El comentario de `hooks/lib.sh` que lo daba como un número de niveles
    —SEC-126— está corregido en esta versión: lo corrigió el propietario, es sólo un comentario y no cambia ninguna
    conducta.)*
  - **Ningún SKIP ni INCONCLUSO del banco acredita lo que mide**; se publican con su motivo. Los motivos no se
    copian a las notas de 1.35.0: están en el log de cada corrida de CI y en `docs/qa/REQ-023.md` del arnés. Un
    check verde de CI no acredita lo que en esa corrida salió SKIP o INCONCLUSO.
  - **Firmas ausentes en el arnés.** Lo construido en la fase 2 de la novena autorización —la forma de heredoc de
    SEC-124 y la continuación de línea de SEC-125, con su excepción LC10, en la entrada anterior— lo validó el
    propietario del arnés por vía manual, **sin veredicto del `qa-tester` ni firma del `auditor-seguridad`**, por un
    impedimento del proveedor que fue sobre el contenido del despacho de SEC-124/125 y la lectura de su diff, **no
    sobre los roles**. Así se publica. La corrección del comentario de SEC-126 tampoco lleva firma: así lo decidió
    el propietario del arnés. Detalle en las notas de 1.35.0, «Firmas ausentes, y por qué».

### Hacia 1.36.0

- **Plantilla nueva: `templates/autorizacion.md`.** Es la forma de una autorización del propietario que
  encarga un trabajo en varias fases para que se ejecute entero, sin parar entre fases: cuatro bloques
  —«Plan autorizado» (las fases, cada una con su commit local, y la siguiente empieza sin pedir permiso),
  «Lo que decide la coordinadora sola», «Cuándo paras y me preguntas (solo esto)» y «Si la sesión se
  corta»—, la línea que `docs/ESTADO.md` lleva mientras haya un plan vigente («Plan autorizado vigente:
  <id>, fase N de M, siguiente acción: …») y un ejemplo rotulado como tal.
  **No migra nada por sí sola:** no es un archivo que `arnes-init` copie al proyecto ni que este
  procedimiento clasifique —no tiene base en `.arnes/plantillas-origen/`—, y su presencia en el plugin
  no cambia una coma de tu `AGENTS.md`, de tu `PENDING_APPROVAL.md` ni de tu `docs/ESTADO.md`. Usarla
  es decisión del propietario de tu proyecto. Tampoco autoriza nada ni retira ninguna revisión, firma
  ni aprobación humana que tus reglas exijan: decide cuándo se para y se pregunta, no qué se valida.

- **Límite declarado: el análisis de un comando de `Bash` en el máximo puede tardar 5 s o más con cuatro formas
  (REQ-007 CA-54 del arnés, QA-007-01; decisión P-136-F del propietario del arnés, 2026-10-05).** Esta entrada **no
  migra nada**: dice lo que la versión que instalas **no** promete, para que no lo des por cubierto. **«Límite
  declarado» no es «riesgo aceptado», y la decisión no repara nada.** CA-54 se cumple en su medición: en el máximo
  declarado (131 072 bytes), en Linux/WSL2 y a nivel de hook, las 35 corridas de sus dos sondas terminan en menos de
  5 s, con la misma decisión que 1.35.0. Quedan **fuera** del criterio cuatro formas: un comando que menciona el
  estado terminal con todos sus destinos fuera de `requirements/`; uno que lleva un carácter no ASCII; un proyecto
  sin globs de código; y el agente de código cuyo primer destino es código protegido. **Consecuencia:** un comando
  con esas formas, en el máximo, **se juzga igual pero puede tardar 5 s o más**. Medido en las dos primeras: 10 de
  30 corridas entre 5,0 y 5,8 s; las otras dos, sin cifra sobre el código del candidato. No es un fallo abierto: la
  corrida más lenta medida queda a más de 54 s del límite de 60 s del cliente. Un margen no es una garantía: en un
  equipo más lento o más cargado, el hook podría agotar el tiempo, y eso ya es SEC-115. En Windows/MSYS, sin medir.
  La reparación es una segunda pasada de CA-54, prevista después de SEC-120; si no llega antes de publicar, la
  versión sale con este límite. Sede: REQ-007, nota de CA-54, «Límite declarado del candidato `82ceb63`», del arnés.

- **No medido: la corrección de SEC-127 en bash 5.0 o anterior en modo POSIX (REQ-007 CA-47, punto 20, del arnés;
  decisión P-136-K del propietario del arnés, 2026-10-06).** Esta entrada **no migra nada**: dice lo que la versión
  que instalas **no** ha medido, para que no lo des por cubierto. El atajo de `guard-completado` cambiaba el locale
  del proceso que juzga con una asignación delante de una llamada de función; en bash 5.0 o anterior, en modo POSIX,
  esa asignación persiste al volver de la función, y el cierre por `Bash` de un REQ con un estado terminal no ASCII
  escrito con otras mayúsculas podría pasar (consecuencia simulada, no reproducida). La reparación restaura el locale
  sin esa forma. **SEC-127 se acredita con los casos de la sección 47 del banco (LO1 a LO4 y LK) y con la lectura del
  código.** Esos casos se miden en bash 5.3 y allí no son fail-before. **La prueba en bash 5.0 o anterior en modo
  POSIX queda declarada como no medida:** en ese intérprete la corrección se sostiene por lectura, no por medida.
  Sede: REQ-007, CA-47, punto 20, «SEC-127 — cómo se acredita (P-136-K)», del arnés.

- **Cambio de compatibilidad: un REQ muy grande no se escribe entero de una vez, y un `Edit` con un `old_string`
  grande sobre él se deniega (REQ-007 CA-68 del arnés; decisión P-136-O del propietario del arnés, 2026-10-06).**
  Esta entrada **no migra nada**: dice qué llamadas legítimas que la versión anterior dejaba pasar **deniega** la
  que instalas, para que no te sorprenda. Para que un hook que no termina de juzgar a tiempo no deje pasar,
  `guard-completado` mide el tamaño antes de las operaciones que crecen más que linealmente, y deniega a todo
  agente por encima de dos techos. **(1)** El `Write` de un REQ cuyo `content` pasa de unos **393 216 bytes** (el
  techo cuenta el texto troceado: el `content` más 4 bytes, sin el salto final; medido, 393 213 bytes pasan y
  393 214 deniegan) **se deniega**: un REQ de ese tamaño no se escribe entero de una vez. **(2)** Un `Edit` cuyo
  producto (bytes del documento más los de los `new_string`) × (bytes de los `old_string`) pasa de **2³²** **se
  deniega**; en un `MultiEdit` cuentan todas sus ediciones. La frontera depende del tamaño del REQ: sobre uno de
  660 431 bytes, un `old_string` de 3 000 a 6 400 bytes pasa y uno de 7 000 o más deniega. **Consecuencia y
  salida:** con 1.35.0 esas llamadas salían sin decisión; ahora el motivo del `deny` lo dice y dice cómo salir:
  edita el REQ por fragmentos con `Edit`, usa un `old_string` más corto —basta con el trozo que identifica el
  sitio— o parte la edición en varias llamadas. Los REQ por debajo de esos tamaños no cambian (medido: un `Write`
  de 296 973 bytes sigue igual). Medido en Linux/WSL2, una corrida por punto; Windows/MSYS y el host, sin medir. Si
  tus REQ crecen hasta ahí, puedes archivar su historia con la rotación por sección que el arnés ya trae
  (`rotacion.artefactos`, apagada por defecto). Sede: REQ-007, CA-68, «Techos de tamaño», «Cambio de compatibilidad declarado…», y
  CA-69, punto 3, del arnés.

- **Cambio de compatibilidad: una entrada del hook que no se puede leer se deniega (SEC-120; REQ-007 CA-47, punto
  20, del arnés).** Esta entrada **no migra nada**: dice qué deja de pasar con la versión que instalas. **Decisión
  del propietario del arnés** (2026-10-03, alcance de 1.36.0, punto 2, literal): «SEC-120 (vence 2026-10-29): fallo
  de jq al leer o trocear la entrada → deny en las herramientas que las puertas juzgan.» Y qué es ilegible (2026-10-05,
  literal): «todo lo que no sea exactamente un objeto JSON (null, número, vacío, dos objetos seguidos). Fail-closed;
  es el principio del arnés.» **Qué cambia:** con 1.35.0 esas entradas salían sin decisión; ahora reciben `deny`, a
  todo agente, con un motivo que dice que la entrada no se pudo leer. También una entrada que no llega porque falla
  su lectura —por ejemplo, la entrada estándar cerrada—. Una entrada bien formada decide como antes. **Frontera:**
  sin `CLAUDE_PROJECT_DIR`, el hook es inerte si no puede obtener el proyecto, y deniega si del `cwd` de la entrada
  obtiene uno con manifiesto (decisión P-136-H del propietario del arnés). Medido a nivel de hook en Linux/WSL2; el
  host y Windows/MSYS, sin medir. Sede: REQ-007, CA-47, punto 20, del arnés.

- **Cambio de compatibilidad: un valor que la puerta necesita y no puede leer como texto se deniega, también
  `false`; y en `guard-codigo`, un `file_path` que no es texto se deniega también al agente de código (SEC-120 y
  SEC-128; REQ-007 CA-47, punto 20, del arnés).** Esta entrada **no migra nada**. **Decisiones:** la del párrafo
  anterior («leer **o trocear**»), y para SEC-128 la del propietario del arnés P-136-J (2026-10-06, literal): «la
  reparación es únicamente que un file_path que no es texto no deje pasar a nadie (fail-closed), con su caso de
  banco.» **No hay una decisión del propietario que nombre `false`:** lo midió QA (`file_path` o `command` en
  `false` salían sin decisión) y la pasada correctiva de SEC-120 lo reparó dentro de su plan autorizado, porque el
  criterio ya decidía esos casos. **Qué cambia:** unas ediciones de `MultiEdit` que no son una lista, un número o
  `false` donde va texto, reciben `deny` de la puerta que necesita ese valor; una puerta que no lo necesita decide
  como siempre. Y para el agente de código, un `Edit`, `Write` o `MultiEdit` con un `file_path` que no es texto pasa
  de `allow` a `deny` en `guard-codigo`; por `guard.sh` no cambia ninguna decisión, porque `guard-completado` ya lo
  denegaba. Sede: REQ-007, CA-47, punto 20, y su subviñeta SEC-128, del arnés.

*Las tres entradas siguientes son del paso 6 de 1.36.0. **Al escribirlas, su validación no está cerrada:** QA validó
lo construido con hallazgos, la pasada correctiva está en curso y la revisión de seguridad, pendiente. Se confirman o
se corrigen antes de copiarlas a las notas `[1.36.0]` (REQ-007 CA-69, punto 5, del arnés: ninguna sede dice
«reparado» antes de validar).*

- **Cambio de compatibilidad: el motivo de una denegación y el texto de un aviso salen acotados a 16 384 bytes
  (SEC-118; REQ-007 CA-67 del arnés; decisión P-136-B del propietario del arnés, 2026-10-03).** Esta entrada **no
  migra nada**. **Decisión, literal:** «criterio por propiedad: toda denegación decidida llega al cliente, entera o
  acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran.» **Qué cambia para quien lee la
  salida:** un motivo o un aviso de más de 16 384 bytes llega cortado, con su comienzo —que nombra la causa—, la
  nota «[...] (ARNES: motivo acortado: medía N bytes y el tope es 16384; se conserva su comienzo)» y sin un carácter
  UTF-8 partido. Con 1.35.0, por encima del límite de un argumento no llegaba **nada** y el hook salía sin
  decisión. **La decisión no cambia** por acotar: cambia el texto. Con contenido que no es UTF-8 válido, que el tope
  se cumpla es parte de la pasada correctiva en curso (QA-007-12). Medido a nivel de hook en Linux/WSL2; el host y
  Windows/MSYS, sin medir. Sede: REQ-007, CA-67, del arnés.

- **Cambio de compatibilidad: un juicio que agota el plazo propio del hook se deniega, también el legítimo (SEC-115;
  REQ-007 CA-68 del arnés; decisión P-136-C del propietario del arnés, 2026-10-03).** Esta entrada **no migra nada**.
  **Decisión, literal:** «techos de tamaño más plazo propio de 40 s, sin procesos.» **Qué cambia:** el hook comprueba
  su plazo entre unidades de trabajo, sin lanzar procesos, y al vencer deja de juzgar y emite `deny`, a todo agente,
  con un motivo que lo dice; la respuesta llega en no más de 40 s. **Lo legítimo que agote el plazo se deniega
  igual**: con 1.35.0, un juicio así podía pasar de los 60 s del cliente y salir sin decisión. Medido en una llamada
  real: el cierre por `Edit` de un REQ de 3 MB con CRLF en disco recibe `deny` por el plazo a los 36,3 s. El plazo
  no corta una quality gate en curso —se comprueba antes de lanzarla— ni una sola operación que no termina (abajo,
  el límite de QA-007-09). Sede: REQ-007, CA-68, «Un plazo propio del hook de 40 s», y CA-69, punto 3, del arnés.

- **Cambio de compatibilidad: con el modo POSIX heredado del entorno, las puertas de `Bash` vuelven a decidir, y un
  final que no es un juicio deniega (SEC-129; REQ-007 CA-68, partes (i) y (ii), del arnés; decisiones P-136-L y
  P-136-N del propietario del arnés, 2026-10-06).** Esta entrada **no migra nada**. **Decisiones, literales:**
  P-136-L, «la reparación va dentro de SEC-115/118, que ya trata «el hook siempre emite decisión».»; y P-136-N,
  texto adoptado: «ninguna decisión del hook depende de nada que herede del entorno (modo del intérprete, variables
  `ARNES_*`; `BASH_ENV` queda como ficha F-136-9).» **Qué cambia:** con `POSIXLY_CORRECT` exportada —también
  vacía—, `SHELLOPTS` con `posix`, un `BASH_ENV` que hace `set -o posix` o `bash --posix`, la vía `Bash` de
  `guard-codigo`, `guard-completado` y `guard-git` salía **sin decisión** para toda llamada desde 1.30.3, también el
  git destructivo. Ahora recibe la misma decisión que sin ese estado: `deny` donde se deniega, y `ls -la` sigue sin
  decisión. Lo mismo con `ARNES_INPUT_LISTO` o `ARNES_MANIFEST_LISTO` heredadas. Y un error del intérprete, una
  puerta abandonada a mitad o un código del analizador fuera de su vocabulario **deniegan** en vez de dejar pasar.
  **Para tu proyecto:** si tu entorno exporta `POSIXLY_CORRECT`, dejarás de ver pasar sin decisión escrituras por
  shell a código protegido, cierres por shell y git destructivo; sobre lo legítimo no se espera movimiento. Medido a
  nivel de hook en Linux/WSL2, bash 5.3.9; el host, Windows/MSYS y otros bash, sin medir. Sede: REQ-007, CA-68, «Un
  final que no es un juicio no deja pasar…», y CA-69, punto 3, del arnés.

- **Límite declarado: un REQ grande con CRLF en disco puede dejar sin decisión el `Edit` que lo cierra (QA-007-09;
  REQ-007 CA-68, «Límites declarados de 1.36.0», del arnés; decisión P-136-P del propietario del arnés,
  2026-10-06).** Esta entrada **no migra nada**: dice lo que la versión que instalas **no** cumple, para que no lo des
  por cubierto. **«Límite declarado» no es «riesgo aceptado», y la decisión no repara nada.** **Decisión, literal:**
  «QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37.» **Alcance:** un `Edit` que cierra
  un REQ cuyo documento en disco tiene finales de línea CRLF. La normalización de esos finales en
  `guard-completado` crece más que linealmente y no tiene techo, porque el techo de tamaño mide la entrada de la
  herramienta y no el disco; y el plazo no interrumpe una sola operación. Medido a nivel de hook en Linux/WSL2, una
  corrida por punto: con 3 MB, `deny` por el plazo a los 36,3 s; con 3,3 MB, `deny` a los 50,9 s, por encima de los
  40 s del plazo; con **3,6 MB o más, sin decisión** a los 60 s. **Consecuencia:** por encima de unos 3,6 MB en CRLF,
  ese cierre puede no recibir decisión, y que el cliente lo tome por permitir es inferido; lo alcanza cualquiera que
  agrande el REQ y después lo cierre por `Edit`. Es preexistente y peor en 1.35.0, que ya salía sin decisión desde
  3 MB. En Windows/MSYS la normalización es más lenta y el umbral sería más bajo: sin medir; por `Write` o
  `MultiEdit`, sin medir. **Si tus REQ crecen hasta ahí,** guárdalos con finales LF o archiva su historia con la
  rotación por sección (`rotacion.artefactos`). Ficha para 1.37: un techo sobre el documento en disco o una
  normalización lineal. Sede: REQ-007, CA-68, «Límites declarados de 1.36.0», del arnés.

- **Límite declarado: tres estados del intérprete heredados del entorno no se pueden neutralizar desde dentro del
  hook (QA-007-11 (b); REQ-007 CA-68, «Límites declarados de 1.36.0», del arnés; decisión P-136-P del propietario
  del arnés, 2026-10-06).** Esta entrada **no migra nada**: dice lo que la versión que instalas **no** cumple.
  **«Límite declarado» no es «riesgo aceptado», y la decisión no repara nada.** **Decisión, literal:** la del párrafo
  anterior. **Alcance:** `SHELLOPTS` exportada con `noexec` o con `onecmd`, y con `xtrace` junto con
  `BASH_XTRACEFD=1`, en el entorno en que corre el hook. Con `noexec` el intérprete no ejecuta ninguna línea; con
  `onecmd` sale tras la primera orden; y `xtrace` escribe la traza en la salida estándar antes de que el hook pueda
  apagarlo. Medido a nivel de hook en Linux/WSL2: con los dos primeros, **sin decisión** en las llamadas que se
  deniegan; con el tercero, una salida que no es un JSON válido, y por tanto sin decisión para el cliente
  (inferido). Igual en 1.35.0. **Consecuencia:** quien controla el entorno del hook puede dejar sin decisión las
  llamadas que las puertas deberían denegar. **Para tu proyecto:** no exportes esas opciones en el entorno de la
  sesión. Es la misma frontera que `BASH_ENV`: sólo se podría actuar en la orden de `hooks/hooks.json` que lanza el
  hook, o declarar la frontera del entorno del host; ficha para 1.37. Sede: REQ-007, CA-68, «Límites declarados de
  1.36.0», del arnés.

- **Límite declarado: estado heredado del entorno que corre antes de cualquier limpieza del hook (QA-007-13; REQ-007
  CA-68, «Límites declarados de 1.36.0», «Ampliación por P-136-Q: F-136-20», del arnés; decisión P-136-Q del
  propietario del arnés, 2026-10-07).** Esta entrada **no migra nada**: dice lo que la versión que instalas **no**
  cumple. **«Límite declarado» no es «riesgo aceptado», y la decisión no repara nada.** **Decisión, literal:**
  «Límites declarados (F-136-20, 1.37): `.`/`[` antes de entrada.sh, errexit, y BASH_ENV si no está ya cubierto;
  resolución desde hooks.json.» **Alcance:** (i) una función exportada en el entorno del hook con el nombre `.` o
  `[` (`BASH_FUNC_.%%`, `BASH_FUNC_[%%`): el hook ejecuta esas dos órdenes para cargar su preludio, antes de que
  ninguna limpieza corra, así que la función las sustituye y las llamadas que deberían denegarse salen **sin
  decisión** —y si la función de `[` imprime un `allow`, reciben un **`allow` explícito**, que además salta el
  diálogo de permisos del cliente (medido a nivel de hook en el candidato de 1.36.0; revisión de seguridad R-056 del
  arnés)—; (ii) `SHELLOPTS` exportada con `errexit`: el hook **deniega todo**, también lo legítimo —falla hacia el
  lado cerrado, y la sesión no puede trabajar—; (iii) un `BASH_ENV` con cualquier contenido, que bash ejecuta
  **antes** que el hook, con sus permisos. Medido a nivel de hook en Linux/WSL2, bash 5.3.9, los dos primeros; el
  tercero se sostiene por cómo arranca bash. Los tres son preexistentes: también ocurren en 1.35.0. **Consecuencia:** quien
  controla el entorno del hook puede dejar sin decisión las llamadas que las puertas deberían denegar (que el cliente
  lo tome por permitir es inferido), **permitirlas de forma explícita** con una función `[` que imprime un `allow`,
  o bloquear la sesión entera. **Para tu proyecto:** no exportes funciones con
  esos nombres, ni `SHELLOPTS` con `errexit`, ni `BASH_ENV`, en el entorno de la sesión. El host, Windows/MSYS y otros
  bash, sin medir. Es la misma frontera que la del párrafo anterior: sólo se resuelve en la orden de
  `hooks/hooks.json` que lanza el hook; ficha para 1.37. Sede: REQ-007, CA-68, «Límites declarados de 1.36.0», del
  arnés.

- **Cambio de compatibilidad: un cierre cuyas quality gates en serie agotan el plazo del hook se deniega, también el
  legítimo, y una gate que no termina dentro del plazo se interrumpe (SEC-132 (a); REQ-007 CA-68 y CA-69, punto 3,
  del arnés; decisiones P-136-S y P-136-T del propietario del arnés, 2026-10-07). Su validación no está cerrada:** al
  escribir esta entrada la reparación está en una pasada acotada, sin validar por QA ni por seguridad; se confirma o
  se corrige antes de copiarla a las notas `[1.36.0]`. Esta entrada **no migra nada**. **Decisiones, literales:** «se
  repara SEC-132 (a) en una pasada acotada con tope de una hora (plazo comprobado entre gates, caso de banco con gates
  lentas, cambio de compatibilidad declarado, …)» y «El plazo se comprueba entre gates y la gate en curso se acota al
  tiempo que queda del plazo […] Cambio de compatibilidad declarado: una gate que no termine dentro del plazo se
  interrumpe y el cierre se deniega.» **Qué cambia:** el plazo propio del hook se comprobaba antes de la primera
  quality gate y no entre una y la siguiente, así que unas gates lentas en serie —medido: cuatro de 20 s— dejaban el
  cierre **sin decisión** a los 60 s. Con la reparación, el hook no lanza la siguiente gate si el plazo se ha agotado,
  **acota la gate en curso al tiempo que queda del plazo** —si no termina dentro de él, la interrumpe— y **deniega**
  con un motivo que lo dice, antes de los 40 s, también con una gate colgada. **Para tu proyecto:** si tus quality
  gates suman más que el plazo del hook, o **una sola** de ellas tarda más que lo que queda de él —por ejemplo, una
  gate de más de unos 30 s—, verás `deny` por plazo al cerrar un REQ donde antes el cierre pasaba —si terminaba dentro
  de los 60 s del cliente— o quedaba sin decisión; **también con todas las gates en verde**. Una gate que no terminaba
  dentro de los 60 s del cliente, en 1.35.0, dejaba que el cliente matara el hook sin decisión; ahora se interrumpe y
  el cierre se deniega. Lo que la gate interrumpida haya lanzado por su cuenta puede seguir corriendo. Acelera o
  reparte tus gates. El defecto está medido a nivel de hook en Linux/WSL2; el host y Windows/MSYS, sin medir. Sede:
  REQ-007, CA-68, «SEC-132 (a)…», del arnés.

- **Límite declarado: una función heredada con el nombre de la orden de una quality gate, un límite de descriptores
  heredado y `PATH` (SEC-131; REQ-007 CA-68, «Límites declarados de 1.36.0», «Ampliación por P-136-S», del arnés;
  decisión P-136-S del propietario del arnés, 2026-10-07; ficha F-136-21).** Esta entrada **no migra nada**: dice lo
  que la versión que instalas **no** cumple. **«Límite declarado» no es «riesgo aceptado», y la decisión no repara
  nada.** **Decisión, literal:** «SEC-131 límite declarado, ficha F-136-21 con F-136-20 (frontera de confianza del
  entorno; lista blanca en `hooks.json` en 1.37)». **Alcance:** (i) una función exportada en el entorno del hook con
  el nombre de la orden de una de tus quality gates hace que una gate **roja pase**, y el cierre sale sin decisión;
  (ii) un `ulimit -n` de 4 o 5 heredado hace fallar el preludio del hook, que se lee como «inerte», y un cierre por
  shell sale sin decisión; (iii) `PATH` decide qué intérprete y qué herramientas corre el hook, antes de su primera
  línea. Medido a nivel de hook en Linux/WSL2, bash 5.3.9, (i) y (ii); (iii) es la raíz de confianza, no un vector
  medido. Preexistentes: también en 1.35.0. **Consecuencia:** quien controla el entorno del hook puede hacer pasar un
  cierre con una gate en rojo o dejarlo sin decisión (que el cliente lo tome por permitir es inferido). **Para tu
  proyecto:** no exportes funciones con los nombres de tus gates ni límites de descriptores tan bajos en el entorno
  de la sesión, y fija tu `PATH`. El host, Windows/MSYS y otros bash, sin medir. Ficha para 1.37, con F-136-20:
  declarar la frontera de confianza del entorno del host y resolverla con una lista blanca del entorno en la orden de
  `hooks/hooks.json`. Sede: REQ-007, CA-68, «Límites declarados de 1.36.0», del arnés.

- **Límite declarado: miles de líneas `Hallazgos abiertos:` repetidas en la cabecera en disco pueden dejar sin
  decisión el `Edit` que cierra el REQ (SEC-132 (b); REQ-007 CA-68, «Límites declarados de 1.36.0», «Ampliación por
  P-136-S», del arnés; decisión P-136-S del propietario del arnés, 2026-10-07; ficha F-136-22).** Esta entrada **no
  migra nada**: dice lo que la versión que instalas **no** cumple. **«Límite declarado» no es «riesgo aceptado», y la
  decisión no repara nada.** **Decisión, literal:** «SEC-132 (b) límite declarado, ficha 1.37». **Alcance:** un
  `Edit` que cierra un REQ cuya cabecera en disco lleva la línea `Hallazgos abiertos:` repetida miles de veces. El
  juicio de esas líneas crece más que linealmente y no tiene techo delante. Medido a nivel de hook en Linux/WSL2, una
  corrida por punto: con líneas de 66 caracteres, 12 000 líneas, `deny` en 32,8 s; 20 000, **sin decisión** a los
  60 s; con líneas cortas, 20 000, `deny` a los 48,5 s, por encima de los 40 s del plazo. **Consecuencia:** lo alcanza
  quien agranda la cabecera —por ejemplo, con un `Bash` que no menciona el estado— y después la cierra por `Edit`;
  que el cliente tome por permitir un hook sin decisión es inferido. Preexistente: en 1.35.0 esos casos salen sin
  decisión. En Windows/MSYS el umbral sería más bajo, sin medir; por `Write` o `MultiEdit`, sin medir. **Para tu
  proyecto:** una sola línea `Hallazgos abiertos:` por REQ, que es además lo que la regla exige. Ficha para 1.37: una
  normalización lineal o un techo propio del campo. Sede: REQ-007, CA-68, «Límites declarados de 1.36.0», del arnés.

*(1.17.0 y 1.18.0 no requieren migración: sólo tocaron el plugin.)*

## Reglas
- No inventes contenido de proyecto. Ante una decisión —un umbral, un nombre, una política—
  **pregunta**.
- No toques el `CHANGELOG.md` ni `docs/ESTADO.md` del proyecto salvo para dejar constancia de
  la migración: son su bitácora, no andamiaje.
- Si el proyecto personalizó una plantilla, se respeta. Se informa, no se corrige.
