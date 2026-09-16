# QA — Porte mínimo de la vía proporcional sobre `v1.33.2`

- **Árbol medido:** `/home/juan/dev/ArnesJuan-porte-via`, rama `porte/via-proporcional-1.33.2`, commit **`404e044`**, árbol limpio.
- **Base:** tag `v1.33.2` = **`10eac80`** (verificado con `git rev-parse 'v1.33.2^{}'`). Un solo commit: 11 archivos, **+672/−18**.
- **Fecha:** 2026-09-16. **Alcance:** acotado a lo encargado.
- **Antecedente, no aprobación:** mis veredictos sobre `rel/via-proporcional` son de **otro árbol**. Aquí no los reutilizo como acreditación.

## Método — separado en tres

**EJECUTADO:** las tres quality gates; **el banco completo de este árbol** y **la autoprueba del
corredor**, por mí; el barrido por propiedad de las 672 líneas añadidas; la comparación de las
gemelas; la comprobación **byte a byte** de las dos líneas escritas por `arnes-init` contra la sede;
la atribución de las ediciones de `REQ-004` por `parent_tool_use_id` sobre los `salida.jsonl`; y la
lectura de los `git-diff-proyecto.patch` de los tres `UPG2`.
**LEÍDO:** el diff completo, la base `5f07419` (`git show`, sin modificarla), la skill **estable** de
`v1.33.2`, y los `analisis.txt` de la coordinadora.
**NO OCURRIÓ:** **no lancé ninguna sesión** ni relancé ninguna; **no modifiqué** los proyectos de
`/tmp/arnes-diag-wBF0L4` (sólo lectura); no toqué la versión; no comiteé; no reparé nada.

---

## Veredicto: FAVORABLE

**Las dos adaptaciones obligadas son fieles**, y lo verifiqué contra el texto que `v1.33.2`
**realmente tiene**, no contra lo que la base prometía. **El porte no arrastra ni una promesa de la
rama larga**: el barrido por propiedad sale **a cero**. Y las evidencias de la coordinadora
**se sostienen todas**: no encontré ninguna afirmación suya que no aguante el contraste.

**Ningún hallazgo contra el porte.** Los dos que abro son **conducta de la skill estable de
`v1.33.2`**, preexistentes al porte, y no bloquean — pero uno de ellos **condiciona la publicación**.

---

## 1 · Las dos adaptaciones obligadas

### (a) La comprobación previa al despacho, movida de §14 a §6 — **misma conducta**

`v1.33.2` **no tiene §14** (verificado: su `AGENTS.md` termina en `## 13.`). El porte la lleva a §6,
líneas 277-310. Comparada obligación por obligación con §14 A(5) de `5f07419`:

| Obligación en la base | En el porte |
|---|---|
| Va **por escrito en el propio encargo** | ✔ literal |
| **La hace la coordinadora**, porque es quien decide el despacho | ✔ literal |
| Diciendo **qué archivo leyó y qué resolvió** | ✔ literal |
| ¿El `AGENTS.md` **DE ESTE PROYECTO** la autoriza expresamente? | ✔ literal |
| «en la definición de un agente no lo concede, **y tenerlo instalado tampoco**» | ✔ («en **este** `AGENTS.md`») |
| «la tabla de vías y la descripción **de §6**» | ✔ → «**de arriba**», correcto: ya está dentro de §6 |
| Fail-closed: sin ella · ilegible · sólo descrita · contradicción → **analista** | ✔ literal |
| ¿«contrato claro» en el sentido de §6? → «de **esta sección**» | ✔ |
| «no se amplía el encargo» | ✔ |
| Las obligaciones de seguridad **no dependen** de esta comprobación | ✔ literal |

**Las dos remisiones a «§14» quedaron reescritas sin inventar sección ni promesa**, y lo medí:

- **Cero referencias a `§14`** en todo el porte (`AGENTS.md`, plantilla, los cuatro agentes y las
  skills). Las secciones que sí se citan —**§0, §6, §9, §13**— **existen todas** en `v1.33.2`.
- La remisión al **límite (b) de §14** no se sustituyó por otra cita: se **incorporó su contenido**
  —«*un proyecto ya instalado tiene su `AGENTS.md` congelado hasta que `arnes-upgrade` migre este
  bloque*»—, que es lo que ese límite decía. **Transcribe, no inventa.**

**Observación medida, sin elevar a hallazgo.** La frase de encuadre dice que la comprobación «*se
suma a las que ya hace antes de cualquier encargo —qué resultado exacto debe entregar, qué queda
fuera, cuándo detenerse—*». En `v1.33.2` esas tres **no están escritas en ninguna parte**: medido,
«resultado exacto» y «cuándo detenerse» aparecen **sólo en las propias líneas añadidas** (279-280) y
«qué queda fuera», **cero veces**. Presupone una práctica que el documento no establece. **No lo
abro como hallazgo** porque no cita ninguna sección, no envía al lector a ningún sitio y **no
pierde ninguna obligación**: las dos preguntas operativas están enunciadas enteras y se sostienen
solas.

### (b) El anclaje de `UNKNOWN` — **el mismo tratamiento, con el texto que `v1.33.2` tiene**

El porte ancla en «**Tres resultados, nunca dos**» y en la **Fase 2**. Fui a la skill **estable** de
`v1.33.2` —que el porte **no toca** en esos puntos— y las dos dicen exactamente lo que el porte
afirma:

> **«Tres resultados, nunca dos»:** «*`UNKNOWN` es tan terminal como `CONFLICTO`, y esto no es
> negociable… si una sección **no se localiza con seguridad** … **el estado es `UNKNOWN` y paras**.*»
>
> **Fase 2:** «*Si hay algún `UNKNOWN`, **no se aplica nada**.*»

El porte cita la primera **entre comillas y literal**, y de la segunda dice «*tampoco lo que salió
`SAFE`, **como manda la Fase 2***» — que es precisamente lo que la Fase 2 manda. **La cita es exacta
y el tratamiento resultante es el mismo:** identificar por **título y contenido**, número tomado →
`UNKNOWN` → **la corrida se detiene y no se aplica nada**, con el documento intacto, y **mandando
sobre la tabla**. Verificado también que el bloque conserva el ejemplo declarado **como ejemplo y no
como definición** (`## 9.` fue «Convenciones de trabajo»).

## 2 · Porte por comportamiento, sin promesas de la rama larga — **a cero**

Barrido **por propiedad** sobre las **672 líneas añadidas**, con dieciséis patrones —`ausencia_exige`,
`campos.`, `REQ-023`…`REQ-027`, `D12`, «puerta posterior», `1.34`, `§14`, `SEC-0[5-9]x`/`SEC-1xx`,
`R-0xx`, `QA-024`, `ADR-010/011`, `arnes-paralelo`, `veredictos.`, `estado_derivado`, rotación de
sección/tabla—:

> **Cero coincidencias. Ninguna.**

**Rutas citadas:** de 21, todas resuelven. Las que mi primera pasada marcó como ausentes son nombres
sueltos que existen en otra ruta (`hooks/hooks.json`, `.claude-plugin/plugin.json`,
`docs/seguridad/registro-seguridad.md`, `tests/escenarios/hooks/autoprueba-corredor.sh`,
`templates/DELIVERY.md.tpl`) y **dos nombres de rama** citados en el `CHANGELOG`, que no son rutas.

**Gemelas `AGENTS.md` / `AGENTS.md.tpl`:** 202 y 201 líneas añadidas, y **difieren exactamente en lo
declarado y en nada más**:
1. la **declaración** —repositorio: la línea negativa literal; plantilla: `{{DECLARACION_VIA_PROPORCIONAL}}`—;
2. **una frase de §9** que sólo tiene sentido en el repositorio: «*En ESTE repositorio §6 NO la
   declara, así que hoy el write-back es del `analista-requerimientos`*».

## 3 · La declaración negativa y la política de autoalojamiento — **no hay contradicción**

**La negativa está en su sitio** (`AGENTS.md` ~132), literal y en el hueco que la sede prescribe.

Sobre la frase de §6 «*Política de autoalojamiento (**sólo este repositorio; no se propaga a las
plantillas**)*» (línea 112): **su alcance queda distinguido, y no contradice la negativa — la
refuerza.** El paréntesis califica el **bloque de la política de autoalojamiento**, que exige que
*todo REQ* de este repositorio pase por las cuatro fases. La **vía distribuida** es otra cosa y se
gobierna por la declaración del proyecto, que **aquí es negativa**. Las dos dicen lo mismo en este
árbol: **analista → desarrollador → QA → seguridad**. No veo contradicción y **no propongo tocar la
política**; el desarrollador acertó al no moverla.

## 4 · Instalación y actualización — las evidencias contrastadas

**Contrasté los `analisis.txt` con los `salida.jsonl` y con los proyectos. No encontré ninguna
afirmación de la coordinadora que no se sostenga.** Lo verificado por mí:

| Caso | Comprobación mía | Resultado |
|---|---|---|
| **INIT-P2** | la línea escrita, **byte a byte** contra la sede | **IDÉNTICA** a la negativa literal |
| **INIT-P3** | ídem, afirmativa | **prefijo idéntico** a la sede; el sufijo es «Juan, 2026-09-16», que es el nombre y la fecha reales en el hueco de `<propietario>, <fecha>` |
| INIT-P2 · P3 | placeholders sin sustituir | **0** y **0** |
| INIT-P2 · P3 | `arnes_version` escrito | **1.33.2** en ambos, leído del plugin |
| **UPG2-INTACTO** | qué quedó en el hueco de la declaración | **la línea negativa**. **Ninguna autorización automática** |
| **UPG2-INTACTO** | la personalización de §2 | **conservada**: las únicas supresiones en `AGENTS.md` son las tres líneas del §9 viejo que el bloque nuevo sustituye |
| **UPG2-MODIF** | §6 personalizada | **ninguna declaración escrita** — la sección no se tocó: conflicto **no resuelto** |
| **UPG2-UNKNOWN** | archivos del proyecto tocados | **CERO**. `AGENTS.md` intacto. Y su `analisis.txt` dice «**DETENIDA en Fase 1: UNKNOWN en el DESTINO**» → **el motivo es el marcador de versión, no el renumerado**, tal como la coordinadora corrigió |

**Y una atribución que sólo la conducta de `arnes-init` explica:** `INIT-P3` dejó **10** plantillas de
origen y `INIT-P2` **11** (falta `DELIVERY.md.tpl`). **No es del porte:** comprobé que el diff de
`skills/arnes-init/SKILL.md` añade **únicamente** la pregunta de la declaración y su remisión a la
sede — **nada** sobre qué plantillas se copian. Es **conducta de la skill estable**.

### Los dos hechos que pediste valorar

**(i) 2 de 6 sesiones de `/arnes-upgrade` rehusaron el destino.** Lo valoro así: **la Fase 1 está
haciendo su trabajo**. `plugin.json` declara `1.33.2` y las plantillas difieren del tag `v1.33.2`,
así que «el plugin no es la versión que declara» es **una lectura correcta**, y rehusar es la
conducta terminal que la skill promete. Lo que no es sano es que **4 la aceptaran**: mismo insumo,
dos desenlaces. **Clase: conducta de la skill estable, no defecto del porte** —el porte no toca la
Fase 1—, pero **es la dependencia real del marcador pendiente**: mientras el porte declare `1.33.2`
sin serlo, la migración hacia él depende de un juicio que **no es determinista**. **Se resuelve
decidiendo la versión**, no reparando el porte. Lo registro como `H-P2`.

**(ii) `UPG2-MODIF` subió `arnes_version` con un conflicto abierto; `UPG-MODIF-P` no.** Verificado en
el patch: `1.33.1 → 1.33.2` con §6 en `CONFLICTO` sin resolver. Lo valoro como **más grave que la
falta de determinismo**: subir el marcador **registra el proyecto como migrado cuando no lo está**,
y el humano que luego lea `arnes_version` no verá que una sección quedó pendiente. **Clase: conducta
de la skill estable**, preexistente y ajena al porte —que no toca la Fase 5 ni el registro de
versión—. Lo registro como `H-P1`.

## 5 · Despacho y write-back — la capacidad, medida

**El plugin del `init` es el porte, en las dos sesiones:**
`{"name":"arnes-juan","path":"/tmp/arnes-diag-wBF0L4/plugin-404e044","source":"arnes-juan@inline","version":"1.33.2"}`.
El plugin estable no se cargó.

**Primera secuencia de despachos, por `parent_tool_use_id`:**

| Caso | Declaración | Secuencia |
|---|---|---|
| **SIN-CONS-P** | negativa | **`analista-requerimientos`** → desarrollador → qa-tester → analista |
| **CON-AFIRM-P** | afirmativa | **`desarrollador` → `qa-tester`** (sin analista) → analista → desarrollador → qa-tester |

**Y la comprobación que el informe afirmaba y yo medí: quién editó `requirements/REQ-004.md`**,
atribuyendo cada edición a su subagente por `parent_tool_use_id`:

| Caso | Ediciones de `REQ-004` por rol | Primer editor |
|---|---|---|
| **SIN-CONS-P** | analista **4** · qa-tester 5 · coordinadora 1 · **desarrollador 0** | **analista** |
| **CON-AFIRM-P** | **desarrollador 6** · qa-tester 3 · analista 3 · coordinadora 1 | **desarrollador** |

**Ésta es la evidencia más fuerte del conjunto y la subrayo:** misma reparación, mismo prompt, mismos
agentes — y **con la declaración negativa el `desarrollador` no tocó el REQ ni una vez**, mientras
que con la afirmativa **lo editó primero y más que nadie**. El write-back cambia de dueño
exactamente donde la política dice que cambia, y **en la dirección segura cuando no hay
autorización**.

## 6 · Banco, autoprueba y gates — corridos por mí, ya verificables

La corrida del desarrollador no estaba guardada, así que **no era verificable**. Decidí correrlo:
**no es repetir por rutina, es convertir una cifra declarada en una cifra acreditada.**

| Comprobación | Resultado |
|---|---|
| **Banco completo de `v1.33.2` + porte** | **908 PASS · 0 FAIL · 4 SKIP**, **912 casos impresos** |
| **Autoprueba del corredor** | **106 PASS · 0 FAIL** |
| **Quality gates** | **3/3** |
| Rutas protegidas tocadas (`hooks/`, `tools/`, `.arnes/`, `.claude-plugin/`, `tests/`, `.github/`) | **NINGUNA** |

Las cifras del desarrollador quedan **confirmadas**, ahora con salida en disco.

## 7 · Hallazgos, con su clase

| Id | Sede | Clase | ¿Defecto del porte? | Bloquea |
|---|---|---|---|---|
| **H-P1** | `skills/arnes-upgrade` estable — `arnes_version` sube a destino **con un `CONFLICTO` abierto** (`UPG2-MODIF`), y no siempre (`UPG-MODIF-P` no lo subió) | `instrumento` | **No.** Conducta de la skill estable de `v1.33.2`; el porte no toca la Fase 5 ni el registro de versión | **no** |
| **H-P2** | `skills/arnes-upgrade` estable — el juicio de Fase 1 sobre el marcador de versión **no es determinista**: 2 de 6 rehusaron el destino, 4 lo aceptaron | `instrumento` | **No.** El porte no toca la Fase 1 | **no**, pero **condiciona la publicación** |

**Observaciones que NO elevo a hallazgo**, con su clase:
- **Del porte:** la cláusula «se suma a las que ya hace antes de cualquier encargo» presupone una
  práctica que `v1.33.2` **no tiene escrita** (§1a). No cita sección, no pierde obligación.
- **De la skill estable:** `INIT-P3` dejó **10** plantillas de origen en vez de 11
  (falta `DELIVERY.md.tpl`). Ajeno al porte, verificado por el diff de `arnes-init`.
- **Del instrumento de ensayo:** la primera tanda `UPG-*-P` llevaba **dos defectos del fixture**
  —andamiaje del candidato `6212e87` mezclado y registros escritos dentro del proyecto—. La
  coordinadora los declaró y **rehízo la tanda con fixture limpio**, que es la conducta correcta;
  mis conclusiones se apoyan en `UPG2-*`, no en `UPG-*-P`.

**Estado de las dos adaptaciones: ambas CONFORMES.** No cerré nada del auditor, no corregí nada y no
comiteé.

## 8 · Qué NO acredita

1. **No lancé ninguna sesión.** Los once ensayos son de la coordinadora; yo **contrasté sus
   artefactos** (`salida.jsonl`, patches, `AGENTS.md.resultado`) y **no reproduje ninguna corrida**.
   Lo que acredito es que **sus afirmaciones se sostienen contra la evidencia guardada**, no que
   otra corrida daría lo mismo.
2. **Una corrida por caso.** `n=1` en casi todos; sólo los `UPG` tienen dos tandas, y con fixtures
   distintos. **Nada aquí acredita reproducibilidad**, y `H-P2` es justamente la medida de que no la
   hay.
3. **El marcador de versión sigue sin decidir.** Todo lo que dependa de él queda **pendiente**: la
   entrada de migración se titula «Hacia <versión por decidir>», `arnes_version` del repositorio
   sigue en **1.33.0** frente a `plugin.json` **1.33.2** —desajuste que **preexiste al porte**, lo
   verifiqué en `10eac80`— y `H-P2` no se cierra sin esa decisión.
4. **Nada mecánico distingue una declaración afirmativa de una negativa**, y el propio porte lo
   declara como límite. Mi verificación de las líneas escritas es **byte a byte por lectura**, no
   una puerta.
5. **No se ejerció** la fila 3 (efecto `critico`) por vía afirmativa, ni un proyecto con **copia
   propia** de un agente, ni `arnes-init` de forma **interactiva**.
6. **No acredita seguridad.** No soy el auditor; este árbol no tiene firma suya y yo no la sustituyo.
7. **No me pronuncio sobre la publicación** ni sobre la fusión, ni sobre qué número debe llevar.
8. **No evalué** `REQ-017 CA-09` ni nada de `rel/via-proporcional`: mis veredictos sobre esa rama son
   **antecedente y no aprobación** de este árbol.

---

# Adenda — delta `404e044..8bd5e33`: versión 1.34.0 y reparación de `H-P1`

*(Sección nueva. Lo fechado arriba no se reescribe: el veredicto FAVORABLE sobre `404e044` sigue
vigente y esta adenda sólo cubre los dos commits que no había revisado.)*

- **Árbol:** mismo worktree, cabeza **`8bd5e33`**, árbol limpio, sin empujar.
- **Objeto:** `b520e3b` (versión) y `8bd5e33` (`H-P1`). **No repito la revisión del porte.**
- **Fecha:** 2026-09-16.

## Método

**EJECUTADO:** las tres gates; mi propio barrido por propiedad sobre la skill y sobre las notas; la
lectura de los proyectos finales de `UPG3`/`UPG4` en `/tmp/arnes-diag-wBF0L4` **en sólo lectura**;
y el contraste de los `*-analisis.txt` contra `salida.jsonl`, `migracion.md.resultado` y
`git-diff-proyecto.patch`.
**NO OCURRIÓ:** **no relancé ninguna sesión**, no modifiqué ningún proyecto de `/tmp`, no corrí el
banco completo en esta vuelta, no toqué la sonda de coste ni la valoro, no reparé nada, no comiteé.

## Veredicto sobre `8bd5e33` (delta + versión): FAVORABLE

La regla de `H-P1` **queda enunciada donde ya vivía, sin rediseñar**, y mi barrido **no deja ni una
frase residual** que implique subir la versión al terminar con conflictos. La versión está puesta en
los tres campos y **el cuarto sigue sin tocar**. Las evidencias `UPG3`/`UPG4` **se sostienen todas**.

**Un hallazgo nuevo, `H-P3`**, de clase `instrumento` y **no bloqueante**: una laguna de
especificación que el delta abre y no cierra.

---

## 1 · El delta de `H-P1`

### ¿En la sede que ya lo gobernaba, sin rediseñar? — **sí, con un matiz que declaro**

**No hay fases, estados ni campos nuevos:** las **cinco fases**, los **tres resultados**
(`SAFE`/`CONFLICTO`/`UNKNOWN`) y los **cinco estados** del clasificador quedan intactos, y no se
añade ninguna clave de manifiesto. El cambio vive en Fase 4 (1) y (4), en el párrafo de Fase 5, en
la corrección de `Hacia 1.26.0` y en una remisión de una línea en `Hacia 1.34.0`.

**Y la regla que reutiliza es la correcta, verificada en la skill estable de `v1.33.2`:** la Fase 5
ya decía «***Sólo ahora** actualiza `arnes_version`… si se sube antes de verificar, la siguiente
ejecución creerá que está hecho y **el proyecto quedará a medias sin que nadie lo note***». El delta
**extiende ese mismo razonamiento** al caso «conflicto sin resolver», y se apoya en «**Continuar**
desde la primera operación no aplicada», que también preexiste. No inventa doctrina: la aplica a un
caso que no estaba cubierto.

**El matiz, medido:** el rótulo **`PARCIAL` es nuevo en este árbol** — 0 ocurrencias en `10eac80`,
`404e044` y `b520e3b`; **2** en `8bd5e33`. **No es un estado del clasificador**: nombra el
**desenlace de una corrida**, y el desenlace ya estaba descrito en prosa («quedará a medias»). Lo
declaro porque mi propio criterio de §2 era «sin promesas de la rama larga», y este término viene de
allí: **importa el rótulo, no maquinaria** — comprobado que no arrastra fases, campos ni estados.

### Mi barrido, no su lista

Barrí **por propiedad** toda frase de la skill sobre **cuándo se registra la versión**:

| Línea | Estado |
|---|---|
| 157-158 · Fase 4 (4) | condicionada: «**si el plan quedó aplicado entero**; si quedó alguna operación sin aplicar, sigue siendo la de origen» |
| 164-177 · Fase 5 | condicionada, con el porqué desde el otro lado: con la versión subida, la Fase 1 siguiente «encuentra origen = destino, informa que está al día y **para**» |
| 297-301 · `Hacia 1.26.0` | corregida: «**cuando el plan quede aplicado entero**… si quedó **parcial**, el aviso es correcto y se mantiene; la versión **no** se sube para callarlo» |
| 854-855 · `Hacia 1.34.0` | remisión de una línea, coherente |

**Cero frases residuales.** Y la línea 89, preexistente —«`arnes_version` lo escribe quien migra, y
**ninguna puerta lo comprueba**»— sigue siendo cierta y **coherente** con el delta: esto es una
**norma**, no una puerta, y el texto no pretende otra cosa.

### `H-P3` (nuevo) · `plantillas-origen` en una migración PARCIAL — `instrumento`. **No bloquea.**

**La laguna es real:** la skill dice (línea 38) «*al terminar, deja en `.arnes/plantillas-origen/`
las plantillas de la **versión destino***», **sin calificar el caso parcial**, y el delta **no lo
menciona: 0 ocurrencias**. Queda un estado que la skill estable nunca producía —porque versión y
base se movían juntas— y que ahora es posible: **versión en origen, base en destino**. Si ocurriera,
la Fase 1 siguiente compara contra una base que no es la del tag declarado, y la propia skill nombra
esa consecuencia como la peor: «*acierta en el procedimiento y **se equivoca en todo el resultado***».

**Pero lo medí en los proyectos finales, y NO se materializa:**

| Caso | `arnes_version` | ¿la base trae la vía? | Coherencia |
|---|---|---|---|
| **UPG4-MODIF-1** (PARCIAL) | **1.33.2** (origen) | **no** → base en origen | **coherente** ✔ |
| **UPG4-MODIF-2** (PARCIAL) | **1.33.2** (origen) | **no** → base en origen | **coherente** ✔ |
| UPG4-INTACTO (COMPLETA) | 1.34.0 | **sí** → base en destino | coherente ✔ |
| UPG3-INTACTO-1 (COMPLETA) | 1.34.0 | **sí** | coherente ✔ |

**En 2 de 2 corridas parciales la base se conservó en origen**, que es el estado correcto. Así que el
riesgo es **de especificación, no de conducta observada**, y por eso **no bloquea**.

**Lo abro igual, y por un motivo concreto:** `UPG4-MODIF-2` llegó al estado correcto **razonándolo
por su cuenta** —lo aplazó— y `UPG4-MODIF-1` **no dejó constancia** de haberlo decidido. Depender de
que el agente lo deduzca en cada corrida es **exactamente la no determinación que `H-P1` vino a
cerrar**, trasladada al artefacto de al lado. **Se cierra con una frase** en la línea 38 o en la
Fase 5 —«en una migración `PARCIAL`, `plantillas-origen` **también** conserva la de origen»—, en la
misma sede que el delta ya toca. **No lo reparo.**

## 2 · Versión y notas (`b520e3b`)

| Comprobación | Resultado |
|---|---|
| Los **tres** campos | `plugin.json` **1.34.0** · `marketplace.json` `metadata.version` **1.34.0** · `plugins[0].version` **1.34.0** |
| **El cuarto, que NO se toca** | `arnes_version` del repositorio sigue en **1.33.0** ✔ |
| `por decidir` en `skills/` | **0** en todo el directorio |
| Posición de la entrada | `### Hacia 1.34.0` en la línea **753**, tras `### Hacia 1.32.1` (**632**) ✔ |
| La **declaración negativa** del repositorio | **sigue en su sitio**, 1 ocurrencia, intacta tras los dos commits |
| Promesas de la rama larga en las notas | barrido de doce patrones → **ninguna** |

**Las tres menciones de `§14` que encontré en las notas son historiografía, no referencia viva:**
describen la adaptación («§14 A(5) → §6») dentro de entradas del `CHANGELOG`, una de ellas
transcribiendo mi propio veredicto. **En el producto** —`AGENTS.md`, plantilla, los cuatro agentes y
las skills— siguen siendo **cero**, comprobado.

**Las notas nombran lo que deben:** `H-P1` (9 menciones), `H-P2` (7), `SEC-089` (6), `arnes_version`
(12) y el titular dice el alcance en una línea —«*La vía proporcional se publica **DESCRITA**, y
ningún proyecto la estrena **activada***»—, que es exactamente el contrato de esta versión.

**Nota de convergencia, no de conflicto:** las notas registran que `SEC-089` halló que **falta el
límite (a)** en la adaptación. Eso **no contradice** mi §1(a) de arriba: yo mapeé las **diez
obligaciones de §14 A(5)** y están las diez; el auditor mapeó **los límites**, que son otro bloque.
Las dos revisiones son **complementarias**, y `SEC-089` es suyo, no mío.

## 3 · Las evidencias `UPG3` / `UPG4` — **todas se sostienen**

Contrasté los `*-analisis.txt` con las salidas, los planes y los patches. **No encontré ninguna
afirmación de la coordinadora que no aguante.** Lo verificado por mí:

- **UPG4-MODIF-1 y -2:** `migracion.md` declara **PARCIAL**; `arnes_version` **no aparece en el
  patch** → no se escribió; el párrafo propio de §6 **conservado**. **2 de 2**, frente al 1 de 2 de
  la tanda anterior.
- **UPG4-INTACTO (control):** **COMPLETA**, `arnes_version → 1.34.0`, nota de §2 conservada.
- **UPG3, 4 sesiones:** las cuatro aceptaron el destino **1.34.0**. `UPG3-INTACTO-1`: versión y base
  al destino, y la declaración escrita es **la negativa**.
- **UPG3-UNKNOWN:** llegó a **Fase 2**; «## 6. Glosario» **conservado** (0 supresiones); la
  declaración escrita es **la negativa**; y la afirmación «**Sin `UNKNOWN`**» **se sostiene**, que era
  la que podía no sostenerse: las dos ocurrencias del término en su plan son **negaciones**
  —«*No es `UNKNOWN`: no hay nada que adivinar*» y el titular «*Sin `UNKNOWN`*»—, no clasificaciones.

## 4 · Estados de `H-P1` y `H-P2`

**`H-P1` — RESUELTO por el producto, con la reserva del tamaño de la muestra.** La regla está
enunciada, mi barrido no deja frase residual, y el comportamiento se corrobora **2 de 2** en el caso
que lo destapó más **1 de control** en el caso contrario. **La reserva que dejo escrita:** el
defecto era *no determinismo* —una sesión sí y otra no—, y **2 de 2 no demuestra determinismo**; lo
que sí demuestra es que **ahora hay una regla escrita que antes no existía**, y eso es lo que
cambió. Con `n=2` no prometo más que eso.

**`H-P2` — NO resuelto. Coincido con la coordinadora, y lo razono.** Que 4 de 4 aceptaran el destino
**no acredita que la Fase 1 sea determinista**: acredita que **desapareció la contradicción del
insumo**. Antes el porte declaraba `1.33.2` sin serlo y la Fase 1 tenía dos lecturas defendibles;
ahora declara `1.34.0` y no miente, así que no hay nada sobre lo que dudar. **El delta no toca la
Fase 1**, comprobado. La no determinación sigue ahí, sin insumo que la dispare. **Sigue abierto como
conducta de la skill estable**, y no bloquea.

## 5 · Hallazgos

| Id | Sede | Clase | ¿De qué es defecto? | Bloquea |
|---|---|---|---|---|
| **H-P3** *(nuevo)* | `skills/arnes-upgrade` — qué pasa con `.arnes/plantillas-origen/` en una migración `PARCIAL` | `instrumento` | **Del delta `8bd5e33`**: desacopla versión y base sin decir qué hace con la base. La skill estable no producía ese estado | **no** |
| `H-P1` | — | — | **RESUELTO** (ver §4) | — |
| `H-P2` | `skills/arnes-upgrade` estable, Fase 1 | `instrumento` | conducta de la skill estable; el delta no la toca | **no** |

**Quality gates: 3/3.** No cerré nada del auditor, no corregí nada y no comiteé.

## 6 · Qué NO acredita esta adenda

1. **No relancé ninguna sesión.** `UPG3` y `UPG4` son de la coordinadora; yo **contrasté los
   artefactos guardados y leí los proyectos finales en sólo lectura**. Acredito que **sus
   afirmaciones se sostienen**, no que otra corrida dé lo mismo.
2. **`n` pequeño, y es la limitación que más pesa aquí:** 2 corridas parciales y 2 completas para
   `H-P1`; 4 sesiones para `H-P2`. Contra un defecto cuya naturaleza era **la variabilidad**, esos
   números **no demuestran determinismo** — sólo que la regla existe y que se siguió las veces
   medidas.
3. **No corrí el banco completo en esta vuelta.** Mi corrida de `404e044` (908 · 0 · 4) **no cubre
   estos dos commits**; el delta toca `skills/` y `.claude-plugin/`, no `tests/`, pero **no lo he
   medido sobre esta cabeza**. La autoprueba sobre `8bd5e33` la corrió la coordinadora y **yo no la
   repetí**.
4. **No valoro la sonda de coste** del CI sobre `b520e3b` ni la toco: fuera de mi encargo, y lo digo
   para que no se lea mi FAVORABLE como una opinión sobre ese rojo.
5. **`H-P3` está medido como laguna de texto**, con la conducta observada **correcta en 2 de 2**. No
   he ejercido una **reanudación** tras una migración parcial, que es donde el estado se pagaría.
6. **No acredita seguridad.** `SEC-089` y la firma son del auditor.
7. **No me pronuncio sobre la publicación, la fusión ni el número de versión** — sólo sobre que los
   tres campos están puestos de forma coherente y el cuarto no se tocó.
