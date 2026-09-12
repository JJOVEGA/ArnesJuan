# Tres propuestas de lectura — `SEC-072`, `REQ-003` y `QA-024-41`

**Versión base:** `feat/1.34-cierre-alcance` @ `38d173d`, 2026-09-12. **Autorizadas como lectura y
diagnóstico**: ninguna implementa nada, ninguna abre comisión, y las estimaciones van **marcadas como
estimación** frente a lo medido.

**Lo medido en este documento** sale de leer el árbol y las sedes que se citan por ruta y línea.
**Lo estimado** son las duraciones, y su base es el registro de comisiones de esta sesión
(`docs/arnes/coste-de-comision/`), con la limitación de que **`n` es pequeño por rol**.

---

## 1. `SEC-072` — la ventana de concurrencia de `CA-18 (i)`

### Qué está roto, medido

`CA-18 (i)` promete **en absoluto** que si el documento cambió bajo los pies, «*entonces **no publica**:
el documento conserva **byte a byte** el contenido de esa escritura ajena*». En el **residuo de la
ventana de publicar** —entre que se decide publicar y se publica— **una escritura ajena sí se pierde**.

**Duración de la ventana: SIN MEDIR.** Eso es parte del problema: no sabemos si es de microsegundos o
de milisegundos, y la magnitud cambia qué reparación merece.

### Las opciones

| | Cambio necesario | Limitaciones | Estimación |
|---|---|---|---|
| **(A) Medir primero** | Instrumentar la ventana y publicar su magnitud, sin tocar el mecanismo | **No repara nada.** Pero hoy se estaría eligiendo reparación **sin saber el tamaño del agujero** | **estimación:** 1 comisión de `desarrollador`, ~30–60 min |
| **(B) Publicación atómica** | Escribir a un temporal **propio del proceso** y `mv` encima — el patrón que `1.32.1` ya usó para cerrar la pérdida de texto humano en el hook de parada (`REQ-015`) | `mv` es atómico **dentro del mismo sistema de archivos**; entre sistemas distintos, no. Y no cierra la ventana **lectura→decisión**, sólo **decisión→escritura** | **estimación:** 1 comisión, ~45–90 min + QA + seguridad |
| **(C) Re-verificar antes de publicar** | Releer el documento justo antes de escribir y abortar si cambió | **Estrecha la ventana, no la cierra**: entre la re-lectura y el `write` queda un residuo más pequeño. Es una mejora cuantitativa, no un cierre | **estimación:** 1 comisión, ~30–60 min |
| **(D) Reparación completa** | (B) **más** (C), con la ventana medida antes y después | El coste es la suma; y aun así **queda un residuo teórico** que habría que declarar honestamente | **estimación:** 2 comisiones + QA + seguridad |

### Recomendación: **(A) y después decidir**, con (B) como candidata

**Por qué no recomiendo ir directo a (B):** el propietario ya rechazó aceptar la pérdida como residual,
y con razón — pero **elegir la reparación sin la magnitud es elegir a ciegas**. Si la ventana resulta
ser de microsegundos, (C) puede bastar; si es de milisegundos bajo carga, hace falta (B).

**Y (B) tiene un precedente medido en este mismo repositorio**: `REQ-015` cerró exactamente esta forma
de pérdida en el hook de parada con temporal propio del proceso y `mv` encima, tras medir que **1 de 25
vueltas del banco perdía texto humano**. Ese antecedente es lo que hace a (B) la candidata, no una
intuición.

**Lo que ninguna opción hace:** cerrar `SEC-072` por escribir texto. **Documentar una limitación no
equivale a repararla.**

---

## 2. `QA-024-39` y el efecto exacto de reabrir `REQ-003`

### El criterio que cambiaría: **`CA-13`, y sólo ése**

`REQ-003` está **`completado`** con `QA: aprobado` (2026-09-06) y **`Hallazgos abiertos: (ninguno)`**.

Su **Bloque B** tiene **siete** criterios: `CA-09`, `CA-10`, `CA-11`, `CA-12`, **`CA-13`**, `CA-14`,
`CA-15`. **Seis de los siete no se tocan**: contratan el **aviso** —que se emita, que viaje en
`systemMessage`, que no se dispare fuera de `requirements/`, los controles— y todo eso **sigue siendo
cierto**.

**`CA-13`** dice: «*Dado un `Edit` que a la vez escribe un valor fuera del vocabulario **y deja la
cabecera en el estado terminal**, Entonces el hook responde **DENY** por la puerta de cierre*». **Sin
condición de rigor.** Y QA midió que **su escenario exacto da `ALLOW` en `ligero`**, porque `ligero` no
pide veredicto de QA.

### Qué evidencia previa sigue siendo válida

**Casi toda, y esto es lo que hace la reapertura acotada.**

- El `QA: aprobado` del 2026-09-06 **incluye una prueba por mutación del vocabulario** — esa evidencia
  acredita el **aviso**, que no cambia.
- Los seis criterios restantes del Bloque B **no cambian de enunciado**, así que su evidencia **no
  caduca**.
- El **código no se toca**: `CA-13` describe mal una conducta que es **correcta**. `ligero` no pide
  veredicto de QA **por diseño**, y eso está contratado en `requirements/README.md`.

**Lo que sí caduca:** el `QA: aprobado` **como firma sobre el conjunto**, porque §9 dice que un REQ que
cambia vuelve a `en-revisión` y re-recorre el ciclo. Ésa es la parte que hay que acotar explícitamente
al autorizarla, o la reapertura se come el REQ entero.

### Qué trabajo adicional exige

| | |
|---|---|
| **Analista** | corregir `CA-13` para que declare su condición de rigor; **1 sede**, más el barrido por propiedad dentro del archivo |
| **QA** | verificar **`CA-13`** y **no** re-validar los otros seis; y **re-firmar** el REQ |
| **Seguridad** | sólo si el auditor lo considera — el código no cambia |
| **Estado** | `completado` → `en-revisión` → `completado`, **con la cola vacía como precondición** (hoy son 14) |

**Y aquí está el impedimento que no depende del trabajo:** **`REQ-003` no puede volver a `completado`
mientras la cola tenga entradas.** Reabrirlo hoy lo deja `en-revisión` **indefinidamente**.

### Recomendación: **no reabrir `REQ-003` ahora**

Contratar `QA-024-39` en `REQ-003` es lo **correcto en el sitio correcto** — es su dueño natural—, pero
**hacerlo hoy convierte un REQ cerrado en uno abierto que no puede volver a cerrarse**, por una razón
ajena a su contenido.

**La alternativa que propongo:** dejar `QA-024-39` **abierto con dueño `analista-requerimientos` y
forzador declarado** —«al vaciarse la cola de aprobaciones, o al abrirse 1.35.0, lo que ocurra
primero»—, y **corregir `CA-13` en ese momento**. El hallazgo **no se cierra ni se reclasifica**: se le
pone fecha.

**Consecuencia de aceptarla:** `REQ-024` no puede cerrar mientras `QA-024-39` siga abierto, porque es
`contrato`. **Consecuencia de rechazarla:** se reabre `REQ-003` y queda `en-revisión` hasta que la cola
baje a cero.

---

## 3. `QA-024-41` — la base anterior al bloque, y el caso de `v1.30.3`

### El defecto, medido

La migración clasifica un bloque comparándolo contra la **base de origen**. Si la base **es anterior al
bloque** —el bloque no existía cuando ese proyecto se instaló—, la comparación da **`MODIFICADO`**, que
es **conflicto**, y el conflicto **impide subir `arnes_version`**.

**No es hipotético: es nuestro caso.** `.arnes/plantillas-origen/` de **este** repositorio congela
**`v1.30.3`**, y con esa base **el párrafo del aviso da `MODIFICADO → CONFLICTO`**. Con base `v1.33.0`
los tres bloques dan `INTACTO`.

**El banco no lo ve** porque sus 27 casos usan una base que **sí** contiene los tres bloques.

### La corrección mínima: **el estado que falta ya existe**

`skills/arnes-upgrade/SKILL.md:47` ya define **`NUEVO`** — «*no existía en la base y sí en el destino →
**Añadir***» — y `:54` lo dice explícito: «*si no existía en la base, entonces sí es `NUEVO` y se
añade*». Y el bloque de §14 **ya se clasifica contando anclas** (`:880`) en vez de comparar contra la
base, precisamente por esto.

**La corrección mínima es aplicar a los tres bloques nuevos la misma clasificación por anclas que ya
usa §14**, con la regla de tres valores que esa sede ya tiene:

| anclas en el destino | estado | acción |
|---|---|---|
| **0** | **`NUEVO`** | añadir |
| **1** | ya está | no tocar |
| **> 1** | **`UNKNOWN`** | **parar y preguntar** |

### Cómo preserva las personalizaciones, y por qué no permite una actualización incompleta

- **`NUEVO` añade, no sustituye:** el resto del `AGENTS.md` del proyecto **no se toca**.
- **Si el destino ya tiene algo en esa ancla, no es `NUEVO`** y vuelve al camino de conflicto — la
  personalización **se conserva** y se cita sin aplicar.
- **`> 1` es `UNKNOWN`, y `UNKNOWN` es tan terminal como `CONFLICTO`**: la skill ya lo dice y **no es
  negociable**. Una actualización con un `UNKNOWN` **no sube `arnes_version`** y **no se declara
  migrada**.

### La verificación necesaria

1. **Con base `v1.30.3`** —el origen real de este repositorio— los tres bloques clasifican **`NUEVO`** y
   se añaden, y `arnes_version` **sí** sube.
2. **Con base `v1.33.0`** siguen dando **`INTACTO`** — la corrección **no** cambia el caso que hoy pasa.
3. **Con el bloque ya presente** (segunda corrida) da «ya está» y es **idempotente byte a byte**.
4. **Con el bloque duplicado** da **`UNKNOWN`**, y la migración **se detiene**.
5. **Con personalización en esa zona** sigue dando **conflicto**, y el contenido del proyecto **no se
   pierde**.

**Y una que el banco debe ganar por este hallazgo:** que **al menos un caso use una base anterior al
bloque**. Hoy los 27 usan una base que lo contiene, y **por eso el banco no vio el defecto**.

**Estimación:** 1 comisión de `desarrollador`, **~30–50 min** (estimación, no medición), más QA acotada.

---

## Lo que estas tres propuestas NO hacen

No implementan nada, no abren comisión, no cierran ni reclasifican ningún hallazgo, y **no amplían el
alcance a una revisión general del arnés**. `SEC-072` sigue abierto y **no aceptado como residual**;
`SEC-084` sigue abierto **mientras falte su cuarta parte**.
