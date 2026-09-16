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
