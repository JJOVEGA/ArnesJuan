# Las decisiones que siguen pendientes — 2026-09-11

**Cola medida por la máquina: 14** (`arnes_cola_pendientes`, `rc 0`), tras mover `D6` y `D10` a
«Resueltas» con autorización expresa. **Ninguna entrada se borró**: van íntegras, con su evidencia
enlazada, en `PENDING_APPROVAL.md` § «Resueltas».

**Qué bloquea la cola, acotado:** el gate **A2** de `guard-completado` impide **marcar un REQ como
`completado`**, y nada más. No impide commitear, empujar, abrir o fusionar un PR, ni ninguna otra
transición de estado. **Todo el trabajo de 1.34.0 puede avanzar; lo único imposible es cerrar un REQ.**

---

## Las tres re-medidas sobre la cabeza actual

### `D16` — vigente, con su medición sustituida y su pregunta intacta

**Qué decides:** qué hacer con **`QA-016-04`**, un hallazgo de clase `contrato` que **no está escrito en
el campo `Hallazgos abiertos:` de ningún REQ**. Verificado hoy: `REQ-016` sólo declara `H-07` y
`QA-016-01`, los dos `instrumento`.

**Qué cambia:** hoy **ninguna puerta lo mide**. Un hallazgo bloqueante que no está en ningún campo **no
bloquea nada**, así que el arnés deja cerrar REQ como si no existiera. Decidir es elegir entre **darle
sede** —y entonces empieza a bloquear de verdad— o **declararlo de otra clase** con su motivo.

**Qué bloquea:** nada hoy, y ése es exactamente el problema.

**Recomendación:** darle sede en el REQ que corresponda. **Consecuencia:** el recuento de bloqueantes
sube, y algún REQ que hoy parece cerrable deja de serlo. Es la dirección correcta: prefiero un tablero
que diga la verdad a uno que deje pasar.

**Lo que ya NO puedes decidir con ella:** su tabla mide el plugin **1.33.0**, y **`v1.33.1` corrigió esa
mitad**. Re-medir antes de firmar.

### `D17` — vigente, y su descripción quedó obsoleta hoy mismo

**Qué decides:** qué se hace con `SEC-084` **en lo que ya está publicado**.

**Qué cambia:** la entrada describe un fail-open que **ya no se reproduce** —lo cerró `v1.33.1`—, pero
hoy se midió que **la clase sobrevivía en otro disparador**, el del **aviso**, y que **seguía viva en la
`v1.33.2` publicada**. Lo que se decide no es lo que la entrada dice.

**Qué bloquea:** nada del código —ya está reparado en esta rama—. Bloquea saber si hay que hacer algo
con las versiones **ya distribuidas**.

**Recomendación:** reescribir la entrada con lo medido hoy antes de decidirla. **Consecuencia:** si
decides que lo publicado necesita parche, eso es una versión nueva; si decides que no, queda escrito por
qué, y es una aceptación consciente y no un olvido.

### `D18` — vigente sólo en su primera mitad

**Qué decides:** qué se hace con **`REQ-017`**, `bloqueado` tras agotar sus tres vueltas con un hallazgo
`contrato` abierto.

**Qué cambia:** un REQ bloqueado no avanza solo. Las salidas son **autorizar otra vuelta**, **aceptar un
residual declarado** —que exige dueño, forzador medido y vencimiento— o **dejarlo bloqueado** y sacarlo
de la ventana.

**Qué bloquea:** el trabajo **1** del alcance de 1.34.0.

**Su segunda mitad ya está resuelta**, y no por esta entrada: la prueba de reloj que oscilaba se
caracterizó el 2026-09-11 y **tú decidiste el techo** —se mantiene en `1,250×` y lo exigido es bloquear,
no detectar—. **Recomendación:** acotar `D18` a su primera mitad. **Consecuencia:** decides sobre
`REQ-017` sin arrastrar una discusión ya cerrada.

---

## Las once restantes

| id | Qué decisión concreta necesitas tomar | Qué comportamiento, compromiso o riesgo cambia | Qué trabajo bloquea | Recomendación y su consecuencia |
|---|---|---|---|---|
| **`D2`** | Qué se hace con los hallazgos bloqueantes abiertos: resolverlos, declararlos residuales con dueño y vencimiento, o aceptarlos | **Tu regla dice que cualquiera de ellos devuelve el tag a ti.** Mientras sigan abiertos, ningún REQ que los declare puede cerrarse | El cierre de **5 REQ** | **Decidir sobre la cifra corregida: 16 en 5 REQ, no 23 en 8.** Ocho de los dieciséis son de `REQ-020`. **Consecuencia:** si mueves `REQ-020` de ventana, quedan **ocho** y la decisión se hace mucho más pequeña |
| **`D3`** | Qué son `SEC-072` y `SEC-073` y qué se hace con ellos | Los dos son `contrato` y el auditor los describió como «de redacción, no de código». **Eso hace tentador cerrarlos reescribiendo un párrafo**, y tú lo prohibiste el 2026-09-09 | `REQ-026`, el trabajo **2** del alcance | **Decidir si son defectos reales o descripciones mejorables.** **Consecuencia:** si son reales, hay trabajo de código; si no, se cierran con tu firma explícita y no por redacción |
| **`D4`** | En qué versión se arregla la superlinealidad del camino **heredado** | Es rendimiento **ya medido** y **fuera** del alcance de 1.34.0. Está descrito y **no aplicado** | Nada de esta ventana | **Fijar 1.35.0.** **Estarías autorizando** que este trabajo *no* se haga ahora y quede con ventana escrita, en vez de flotar sin fecha. **Consecuencia:** cero trabajo hoy; el arreglo espera con su evidencia |
| **`D7`** | Si `REQ-024 CA-04` se ejecuta, y quién lo aprueba | **El criterio contrata su propio gate humano**, así que una delegación general **no** lo cubre: si la cubriera, el gate no sería un gate | `CA-04` de `REQ-024` | **Decidir explícitamente.** **Estarías autorizando** que se ejecute un criterio que pidió pararse ante ti. **Consecuencia:** sin tu firma, `CA-04` no avanza aunque todo lo demás esté verde |
| **`D8`** | Si aceptas **a posteriori** un cambio del manifiesto que se hizo **antes** de su gate | `.arnes/config.json` recibió el bloque `campos` sin pasar por el gate humano que `ADR-009` declara. **Fue un fallo de procedimiento de la coordinadora, no un riesgo:** la llave nace `false` en las dos sedes, verificado | Nada en la práctica | **Estarías autorizando el cambio ya hecho y cerrando el incumplimiento de procedimiento** — no aprobando un riesgo nuevo. **Consecuencia:** si **no** lo ratificas, habría que revertir el bloque y volver a introducirlo por el gate |
| **`D9`** | Dos preguntas al analista sobre la evidencia que fundó `D6` | La tabla que decidió el modo de medición **cambiaba dos variables a la vez** (el modo **y** `k`/`r`), así que **no aísla lo que dice aislar** | El método de medición de `CA-03` | **Resolverla junto a `D6`**, que ya está en «Resueltas» pero cuya evidencia es ésta. **Consecuencia:** si la evidencia no sostiene el modo elegido, hay que re-medir antes de acreditar `CA-03` |
| **`D11`** | Si se transcribe a `AGENTS.md` la fila que `ADR-011` prescribe | ⚠️ **La fila que esta entrada autorizaba es HOY FALSA.** Anuncia que la guarda «no deniega» y, desde que el desarrollador tomó la salida (b), **sí deniega** | Superficie heredada: `AGENTS.md` y la plantilla, y de ahí **todos los proyectos** | **NO firmarla tal como está.** **Estarías autorizando escribir en el documento que cada proyecto hereda una promesa al revés de lo que hace el código.** **Consecuencia de firmarla hoy:** los proyectos leerían que una puerta no protege cuando sí lo hace. Hay que reescribir la fila y volver a traerla |
| **`D12`** | Si aceptas el **precio** de la salida (b) de `CA-12` | **Una decisión cambia para un proyecto que no ha migrado nada y con la llave apagada**: escribir `Seguridad: aprobado` sobre un REQ que no declara `QA:` **antes pasaba y ahora deniega**. Es más seguro, pero **cambia sin que nadie lo pida** | `CA-12 (ii)`, y con él el cierre de `REQ-024` **y** la transcripción de `SEC-084` | **Aceptarlo.** **Estarías autorizando** que un proyecto note un cambio de conducta al actualizar, a cambio de cerrar un fail-open. **Consecuencia:** sin esto, `REQ-024` no cierra y su remediación de texto no se escribe |
| **`D13`** | Qué se hace con `REQ-023 CA-11`, enunciado **sin acto** | El criterio dice qué decide la puerta «cuando la juzga», sin decir **en qué acto**. Hoy es **falso** para el acto de firmar, y tiene **dos firmas verdes encima** | `REQ-023`, `bloqueado` | **Decidir si se corrige el criterio o se acepta la deriva.** **Consecuencia:** es la misma familia que `CA-13` — un criterio sin acto acaba siendo verdadero en un acto y falso en otro |
| **`D14`** | Si `REQ-024` cierra con **residual declarado** o sigue `bloqueado` | Aceptar un residual **es una decisión de aceptación y es tuya**. La coordinadora aplicó `bloqueado` porque **describe la realidad**, no porque eligiera | `REQ-024` | **Mantener `bloqueado`.** **Consecuencia:** lo que queda **no es un residual** sino un criterio contratado y sin implementar; declararlo residual diría que se acepta un riesgo cuando lo que hay es trabajo sin hacer |
| **`D15`** | Si se enciende `veredictos.caducan_con_codigo` | Encendida, un veredicto anterior al último cambio del código **deja de cerrar** | Nada | **Decidir sin prisa o moverla al backlog.** **La razón que la hacía urgente resultó falsa al medirla** —la comparación es por día, y el caso que la motivó tenía veredicto y código del mismo día—. **Consecuencia:** encenderla es más rigor y más fricción; no encenderla deja las cosas como están |

---

## Lo que esta revisión NO hace

No acepta riesgos, no reclasifica hallazgos, no retira ninguna de las catorce y **no decide ninguna**.
`D6` y `D10` se movieron **con autorización expresa** y tras verificar que **no pedían decisión**; van
íntegras y enlazadas, no borradas.
