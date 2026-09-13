# Entrega acotada desde `v1.33.2` — qué se puede separar, qué arrastra y qué cuesta

> **Propuesta de alcance. No construye ninguna rama candidata ni retira trabajo de
> `feat/1.34-cierre-alcance`, que se conserva completa.** La decide el propietario.

**Versión base de todas las cifras:** tag **`v1.33.2`** (la publicada).
**Árbol medido:** `feat/1.34-cierre-alcance` @ **`cc0bc24`**, árbol limpio.
**Método:** `git diff --stat v1.33.2 HEAD`, `git log --name-only v1.33.2..HEAD`, `git blame -w`
sobre `HEAD` con exclusión de los SHA ancestros de `v1.33.2`, y comparación literal línea a
línea (`grep -F`) de lo que cada commit publicado añadió contra el contenido de `HEAD`. Cada
cifra de este documento se re-deriva con esos cuatro comandos.

---

## 1. Lo que hoy viajaría, elemento por elemento

`git diff --stat v1.33.2 cc0bc24` sobre lo **ejecutable o heredable** (los proyectos no reciben
`tests/`, `docs/` ni `requirements/`):

| Archivo | Δ líneas | Qué lo trajo |
|---|---:|---|
| `hooks/lib.sh` | **+597 / −** | REQ-023 (medibilidad) **y** REQ-024 (ausencia), entrelazados |
| `hooks/rotar-artefactos.sh` | **+419** | REQ-026 (rotación de tablas) |
| `skills/arnes-upgrade/SKILL.md` | **+469** | REQ-027 + `D12` (migración) |
| `hooks/guard-completado.sh` | **+282** | REQ-023, REQ-024, SEC-083 |
| `AGENTS.md` | **+88** | superficie heredada: SEC-079, `CA-12 (ii)`, SEC-084, QA-024-38, política |
| `tools/arnes-lectura.sh` | **+88** | REQ-023, REQ-024 |
| `templates/AGENTS.md.tpl` | **+81** | gemela byte a byte de las filas de `AGENTS.md` |
| `hooks/estado-derivado.sh` | **+58** | REQ-026 (45 líneas vivas) + REQ-024 (10) |
| `.arnes/config.json` | **+7** | **una** llave nueva: `campos.ausencia_exige: false` |
| `templates/arnes-config.json.tpl` | **+7** | la misma llave y su `_doc` |
| `.claude-plugin/plugin.json` + `marketplace.json` | **−6** | **la versión BAJA: 1.33.2 → 1.33.0** |

**Total: 1 984 inserciones / 118 supresiones en 12 archivos.**

### 1.1 El manifiesto: exactamente una llave nueva

Comparadas las claves de `.arnes/config.json` (excluidas las `_doc`) entre `v1.33.2` y `HEAD`, la
**única** diferencia es `campos.ausencia_exige`, y nace **`false`**. El resto del `+7` es prosa
(`_doc`), y el cambio de `_doc_artefactos` documenta el reconocedor de tablas de REQ-026.
`veredictos.exigir_fecha`, `veredictos.caducan_con_codigo` y `rotacion.activo` siguen en `false`
en las dos versiones.

### 1.2 Bloqueo mecánico: la rama declara una versión **anterior** a la publicada

`plugin.json`, `marketplace.json` (dos campos) y `.arnes/config.json:arnes_version` dicen
**`1.33.0`**. La rama salió de `rel/registro-1.33.0`, anterior a los parches `1.33.1` y `1.33.2`,
y **el número no se subió**. Publicar desde aquí sin tocarlo instalaría una versión que se
declara más vieja que la que ya corre en los consumidores. Se arregla con el commit de versión
que toda publicación lleva, pero **hoy la rama no es publicable tal cual**, y conviene saberlo
antes de discutir alcance.

### 1.3 Los arreglos ya publicados **sí** están dentro — verificado, no supuesto

**`v1.33.2` NO es ancestro de `HEAD`**: los parches `1.33.1`/`1.33.2` se **portaron** (commits
`d1b3cc3` y `a05994f`), no se fusionaron. Eso obliga a comprobar que no se perdió ninguno, y se
comprobó:

- **101 líneas** de `hooks/` y `tools/` existen en `v1.33.2` y no en `HEAD`. Inspeccionadas: son
  **código superado** —los dos `grep` de cadena literal que `SEC-084` sustituyó por el lector, y
  el reconocedor de entradas por prefijo que REQ-026 sustituyó por el de tablas— **más**
  comentarios reescritos. **Ninguna es un arreglo perdido.**
- Sólo **cuatro** commits publicados tocan `hooks/` y no están en la rama: `de3e9e6`, `b398b9d`,
  `09ccf63`, `29f9af6`. Contrastados línea a línea:
  - `29f9af6` (SEC-087, la promesa deja de ser absoluta): **20 de 20 líneas presentes**.
  - `09ccf63` (el matiz entre paréntesis sólo sube o mantiene el rigor): **el código está
    entero** —`ARNES_RIGOR_MATIZ`, el piso heredado y la comparación `nd < nh`—; sólo difieren
    **5 líneas de comentario**, reescritas.
  - `b398b9d` y `de3e9e6`: las líneas «ausentes» son **la forma anterior** de líneas que
    `09ccf63` y SEC-084 reemplazaron después. Los símbolos que importan —`ARNES_SEG_CABECERA`,
    `seg_antes`, `ARNES_RIGOR_MATIZ`— aparecen **el mismo número de veces** en los dos árboles.

**Conclusión del apartado:** el criterio «arreglos publicados incorporados» **se cumple**, y la
divergencia con `v1.33.2` no es una pérdida sino una sustitución deliberada.

---

## 2. Los cuatro grupos, y cuál se puede separar

Atribución por `git blame -w` sobre `HEAD`, contando **líneas vivas** (no líneas del diff).

### R · Rotación de tablas — REQ-026

**Commits:** `2a91c82`, `ade924e`, `931218b`, `8248e58`, `43bfd47`.
**Archivos:** `hooks/rotar-artefactos.sh` (431 → **788** líneas), `hooks/estado-derivado.sh` (45
líneas vivas), `.arnes/config.json` y su plantilla (sólo `_doc_artefactos`).

**Separable: SÍ, y es el grupo más limpio.** Ninguna línea viva de `lib.sh`, `guard-completado.sh`
ni `arnes-lectura.sh` procede de estos commits. No hay dependencia de código en ninguna dirección.
**Pero es el grupo más ANTIGUO de la rama**: los otros tres se construyeron encima, así que
separarlo **no** se hace recortando el final de la historia — se hace **revirtiendo** sus cuatro
commits sobre el candidato, o reconstruyendo la rama desde `v1.33.2`.

**Estado que arrastra:** `REQ-026` está **`en-revisión`**, con `Seguridad: con-hallazgos` y
**diecisiete** entradas en `Hallazgos abiertos:`, de las cuales **`SEC-067` es `usuario/dinero`**
(`en-mitigación`) y **`SEC-072`, `SEC-073` y sus cuatro derivados de criterio son `contrato`**.
Cuatro criterios contratados —`CA-13`, `CA-14`, `CA-16`, `CA-17`— **siguen sin implementar**.

### M · Medibilidad de la cabecera — REQ-023

**Commits:** `e406202`, `29b06eb`, `d1b3cc3`.
**Líneas vivas:** `lib.sh` **307**, `guard-completado.sh` **41**, `arnes-lectura.sh` **30**.

### A · Ausencia del campo — REQ-024

**Commits:** `119e853`, `6e3bb90`, `a05994f`, `0440cfd`, `5c71694`, `00b8cb4`.
**Líneas vivas:** `lib.sh` **322**, `guard-completado.sh` **225**, `arnes-lectura.sh` **38**,
`estado-derivado.sh` **10**.

**M y A: separables con coste alto, no imposibles de separar.** Sus líneas vivas están
**entrelazadas dentro de `hooks/lib.sh`**, y el entrelazado es de diseño, no de casualidad: el
commit `6e3bb90` se titula *«La pieza que faltaba: la guarda se AÑADE sobre la lógica de ausencia
de esta rama»* — la guarda de medibilidad de REQ-023 está **construida encima** de la resolución
por ausencia de REQ-024.

**Qué demuestra exactamente el entrelazamiento, y qué no.** Demuestra que la separación **no se
hace recortando commits**: habría que reescribir `hooks/lib.sh` para que la guarda de REQ-023 se
sostenga sin la lógica de REQ-024, y eso es trabajo nuevo con su ciclo completo de dev → QA →
seguridad y su propio riesgo de regresión sobre la puerta. **No demuestra que sea imposible**, y
esta medición no lo intentó: nadie ha construido la variante ni ha medido qué parte de la guarda
depende realmente de la otra. Lo medido es el **coste esperado** de separarlas, y es alto.

**Estado que arrastra:** `REQ-023` está **`bloqueado`** esperando `D13`. `REQ-024` está
**`bloqueado`** con **28** hallazgos abiertos, **5 de clase `contrato`** (`SEC-084`, `QA-024-38`,
`QA-024-39`, `QA-024-40`, `QA-024-42`), y `SEC-084` no puede cerrarse porque le falta su cuarta
parte, que es la decisión **`D15`**, sin tomar.

### U · Migración y tabla heredada — REQ-027 + `D12`

**Commits:** `cd5dc0c`, `6dd3f8a`, `808f9ca`, `d54761e`, `b5a29d9`, `8b06cd6`, `98f0ecd`,
`0990d34`, `2fcd239`, `1154417`, `2f7c821`.
**Archivos:** `skills/arnes-upgrade/SKILL.md`, `AGENTS.md`, `templates/AGENTS.md.tpl`, y
**9 líneas** de `lib.sh` (`8b06cd6`).

**Separable en archivos: casi.** Salvo esas 9 líneas, no toca los hooks.
**Separable en sentido: sólo reescribiéndola.** La migración de `D12` existe **para que la
denegación por ausencia de A llegue a los proyectos ya instalados**, y las filas corregidas de
`AGENTS.md` describen lo que A y M hacen. Publicar U **tal cual** sin A distribuiría una migración
que prepara un mecanismo ausente y una tabla que describe una conducta que el consumidor no
tendría. Separarla exige **reescribir** las partes que referencian el mecanismo, no sólo extraer
los archivos. **U arrastra A mientras conserve esas referencias; A no arrastra U.**

---

## 3. El riesgo que el propietario nombró: el consumidor que YA tiene la rotación encendida

**Que la llave nazca apagada protege a quien instala de cero. No protege a quien actualiza.**
`rotacion.activo` vive en el `.arnes/config.json` **del proyecto consumidor**, no en el plugin:
quien la puso en `true` la conserva, y `arnes-upgrade` no la apaga. Al actualizar, ese proyecto
pasa a ejecutar **788 líneas donde había 431**, en cada `Stop` y `SubagentStop`, sobre sus
bitácoras y —si declaró `glob` + `seccion`— sobre sus requerimientos.

**Tres consecuencias medidas, no supuestas:**

1. **Una sección que antes no se tocaba, ahora se recorta.** Hasta `v1.33.2` una **entrada** era
   sólo una línea a columna cero (`- `, `* `, `### `, `N. `); las filas de tabla eran
   *continuaciones*. Una sección declarada que fuese una tabla tenía **cero entradas
   reconocibles** y el rotador **avisaba y no hacía nada** (mensaje literal en
   `v1.33.2:hooks/rotar-artefactos.sh:297`). Con esta versión, esa misma sección y esa misma
   configuración **mueven filas fuera del documento**. Es un cambio de comportamiento **silencioso
   sobre configuración existente**: el consumidor no cambia nada y su documento empieza a
   recortarse.
2. **Un acoplamiento nuevo en la dirección contraria.** Con `estado_derivado.activo: false`, la
   rotación **de sección** deja de rotar —*«un fail-closed invisible es indistinguible de una
   sección que lleva meses sin archivarse»*—. Un consumidor con rotación encendida y bloque
   derivado apagado pasa de rotar a **no rotar**, también en silencio.
3. **Ninguna firma de seguridad cubre ese escenario.** Las dos revisiones de `REQ-026` lo dicen
   con todas las letras en su campo «Qué NO acredita»: **«el comportamiento con la rotación
   encendida»** (`registro-seguridad.md:6356`), y en la vuelta 2, además, «el banco, la carrera,
   la intermitencia, el coste» (`:6607`). Y el hallazgo que la clase arrastra es
   **`SEC-067`, `usuario/dinero`**: *«la rotación reescribe el documento ENTERO desde una lectura
   previa, sin comprobar si cambió: una firma que caiga en esa ventana se pierde en silencio»*.
   Está **`en-mitigación`** —el testigo de vigencia de `CA-18` cierra la clase *en todo lo que el
   shell puede observar*— y **no `mitigado`**: su cierre está condicionado a `SEC-072`, abierto.

**Lectura honesta:** el riesgo no es que la rotación nazca encendida. Es que **para quien ya la
encendió, esta publicación es un cambio de conducta sobre sus propios documentos, sin firma de
seguridad que cubra ese modo de operación y con un hallazgo `usuario/dinero` todavía en
mitigación.** Ése es el argumento más fuerte a favor de separar el grupo **R**.

---

## 4. Las opciones, con lo que cada una arrastra

| | Alcance | Qué entra | Qué arrastra | Publicable hoy |
|---|---|---|---|---|
| **1** | **Todo** (la rama tal cual) | R + M + A + U | 28 hallazgos de REQ-024 (5 `contrato`), 17 de REQ-026 (1 `usuario/dinero`, 6 `contrato`), REQ-023 esperando `D13`, `D15` sin decidir | **No** |
| **2** | **Sin rotación** (revertir R) | M + A + U | lo de REQ-023/024/027; **quita** el `usuario/dinero` de `SEC-067` y el cambio de conducta del apartado 3 | **No** — siguen los 5 `contrato` de REQ-024 |
| **3** | **Sólo U** (migración y tabla) | U | la migración prepara un mecanismo que no viajaría (§2.U) | **No** — distribuye una promesa sin su máquina |
| **4** | **Nada todavía** | — | la rama se conserva; se resuelven `D13`, `D15` y los `contrato` primero | — |

**Ninguna de las cuatro es publicable hoy por la vía delegada.** `AGENTS.md` §4 delega en la
coordinadora fusionar, etiquetar y publicar **«cuando todo está en verde; cualquier rojo o
hallazgo abierto las devuelve al humano»**. Con hallazgos `contrato` y `usuario/dinero` abiertos
en los REQ que aportan el código, la decisión es **del propietario** en las cuatro.

**La opción 3 no la recomiendo** y conviene decirlo aparte: publicar la migración sin el
mecanismo que migra deja a los consumidores con un `arnes-upgrade` que prepara una denegación que
su plugin no hará. Es la forma exacta del defecto que este ciclo lleva persiguiendo — **un texto
que promete lo que la máquina no tiene**.

---

## 5. Cuánto costaría — estimación, con sus anclas

**Método, y su límite.** No se sintetiza ningún total multiplicando medianas ni rangos. Lo que
sigue enumera **qué comisiones** exige el arnés para cada opción y cita, al lado, el **coste
medido de comisiones del mismo tipo** en el registro de las 34 de este repositorio
(`docs/arnes/coste-de-comision/00-metodo-y-base.md`, base `v1.33.2..cc0bc24`). Las sumas son
**estimación por suma de anclas medidas**, no por mediana, y su error crece con cada supuesto.

**Anclas medidas** (mín.–máx. observados en las 34 comisiones registradas):

| Rol | Duración | Tokens |
|---|---|---|
| `auditor-seguridad` (acotado) | 10 min 53 s – 14 min 30 s | 116 377 – 132 158 |
| `desarrollador` (acotado) | 8 min 28 s – 55 min 45 s | 103 264 – 350 088 |
| `qa-tester` | 11 min 40 s – 48 min 29 s | 147 856 – 214 463 |
| `analista-requerimientos` | 7 min 19 s – 13 min 35 s | 116 083 – 210 375 |

**Opción 2 — revertir la rotación.** Revertir cuatro commits sobre `rotar-artefactos.sh` y
`estado-derivado.sh`, más el `_doc_artefactos` del manifiesto y su plantilla. El conflicto
esperable es **bajo**: ningún commit posterior de la rama toca `rotar-artefactos.sh`, y sobre
`estado-derivado.sh` sólo `119e853` añadió 10 líneas. Comisiones: **1 `desarrollador`** (la
reversión y el banco), **1 `qa-tester`** (que el banco cuadre sin las secciones de rotación),
**1 `auditor-seguridad`** (que revertir no reabra nada). Más el write-back del `analista` si
mover `REQ-026` fuera de la ventana cambia su `Versión destino:`. **Estimación: 4 comisiones,
≈ 1 h – 2 h de agente, ≈ 0,5 M – 0,9 M tokens.**

**Opción 1 — publicar todo.** No necesita reversión, pero sí lo que hoy falta: el commit de
versión (§1.2), la revisión de seguridad del conjunto (**1 `auditor-seguridad`**, la que se
detuvo), CI en verde sobre la cabeza final, y **la decisión del propietario sobre cada hallazgo
`contrato` abierto**. El coste de agente es el **menor** de las cuatro; el coste **real** es el
riesgo del apartado 3, que no se paga en tokens.

**Opción 3 — sólo U.** Exige separar 9 líneas de `lib.sh` (`8b06cd6`) y reescribir la parte de la
migración que referencia el mecanismo ausente: **trabajo nuevo**, no una reversión. **1
`analista`** + **1 `desarrollador`** + **1 `qa-tester`** + **1 `auditor`**, y con alta
probabilidad más de una vuelta, porque lo que se pide es que un documento **deje de describir**
algo que la rama sí tiene. **Estimación: ≥ 5 comisiones**, y la menos predecible de las cuatro.

**Separar M de A no se estima aquí** porque exigiría **reescribir** `hooks/lib.sh` (§2) y nadie ha
construido esa variante: sin ella no hay base para una cifra. Lo que sí se afirma es que su coste
es **superior** al de la opción 2, porque lleva ciclo completo y riesgo de regresión sobre la
puerta.

---

## 6. Lo que decide el propietario

1. **Qué alcance se publica** — opciones 1 a 4 del §4.
2. **Si la rotación viaja** sabiendo el §3: cambio de conducta sobre configuración existente de
   los consumidores, sin firma que cubra la rotación encendida, con `SEC-067` (`usuario/dinero`)
   en mitigación.
3. **`D13`** (desbloquea `REQ-023`), **`D15`** (cuarta parte de `SEC-084`) y **`D14`** (aplazar
   `REQ-024`), que hoy bloquean los tres REQ que aportan el código.
4. **Qué hacer con los 5 `contrato` de `REQ-024`** y los 6 de `REQ-026` antes de cualquier
   publicación.

**Hasta que 1 y 2 estén decididos no se despacha la revisión de seguridad del conjunto**: una
auditoría sobre un alcance que va a cambiar acredita un árbol que no se publicará.
