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
- Si coinciden: informa que está al día y **para**. Idempotente.
- Recupera las plantillas **base** y **destino**. Si alguna no se puede: `UNKNOWN`.
- **Exige el árbol de git limpio.** Si hay cambios sin comitear, para: el respaldo y la
  reversión los da git, y con el árbol sucio no se puede distinguir lo tuyo de lo mío.

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
- `requirements/README.md`: campo `Rigor:` en la plantilla y sección **Nivel de rigor**.
- `AGENTS.md` §6: bloque del nivel de rigor y el marcador `{{CRITERIO_RIGOR_CRITICO}}` —
  **pregunta al usuario qué es crítico en su dominio**, no lo inventes.
- `AGENTS.md` §13: fila «el rigor se puede subir, nunca bajar».

### Hacia 1.20.0
- `AGENTS.md` §6: bloque **el orden no es una sugerencia** —seguridad no firma lo que QA no ha
  validado— con la **excepción nombrada** de la auditoría preventiva.
- `AGENTS.md` §13: fila «Seguridad no firma lo que QA no ha validado».
- `requirements/README.md`: el valor `aprobado (preventiva)` en el campo `Seguridad:` y el
  párrafo **el orden importa**.

  Esta migración **no es cosmética**: el hook empieza a denegar una escritura que antes pasaba,
  y la salida —declarar la auditoría preventiva— sólo existe si el proyecto la tiene escrita.
  Un proyecto sin migrar verá un `deny` cuya excepción no está en su `AGENTS.md`.

*(1.17.0 y 1.18.0 no requieren migración: sólo tocaron el plugin.)*

## Reglas
- No inventes contenido de proyecto. Ante una decisión —un umbral, un nombre, una política—
  **pregunta**.
- No toques el `CHANGELOG.md` ni `docs/ESTADO.md` del proyecto salvo para dejar constancia de
  la migración: son su bitácora, no andamiaje.
- Si el proyecto personalizó una plantilla, se respeta. Se informa, no se corrige.
