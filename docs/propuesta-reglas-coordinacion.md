# Propuesta: una mejora mínima y persistente de las reglas de coordinación

> **Versión base:** `67b06fe`, rama `rel/registro-1.33.0`, 2026-09-10.
> **Método:** todo byte de este documento sale de `awk`/`wc -c` sobre los archivos citados; los
> comandos van en §5 para re-derivarlos sin preguntar.
> **Naturaleza:** propuesta. **No modifica ninguna regla heredada.** Requiere tu decisión porque
> toca un REQ `completado` (§3).
> **Alcance que NO se toma:** no se crea otro agente revisor, ni una puerta permanente, ni un REQ
> extenso. Ninguna garantía, control, alcance de versión ni publicación cambia por esto.

---

## 1. El primer hallazgo: **el REQ aplicable ya existe, y no hay que crear ninguno**

Pediste comprobarlo primero. **`REQ-027`** es exactamente ese REQ:

> *«Las reglas de trabajo de la coordinadora, en la sede canónica que leen todas las herramientas»*
> · `Estado: completado` · `Versión destino: 1.34.0` · `Rigor: critico` ·
> `Archivos: AGENTS.md, templates/AGENTS.md.tpl, skills/arnes-upgrade/SKILL.md, requirements/REQ-027.md, docs/qa/REQ-027.md`

Y ya cubre por contrato las dos cosas que pediste que la propuesta contemplara:

- **Fuente canónica:** `AGENTS.md` §14, que `CLAUDE.md` importa con `@AGENTS.md` (vía **verificada**).
- **Instalación y actualización:** `templates/AGENTS.md.tpl` (proyectos nuevos) y
  `skills/arnes-upgrade/SKILL.md` (proyectos ya instalados). Las tres vías están contratadas en su
  §«Distribución».

**No hace falta un REQ nuevo.** Y su §«Reglas contratadas» se declara **«sitio único de la lista»**,
así que la lista no se duplica en ningún otro sitio: cualquier cambio entra por ahí o es deriva.

---

## 2. Qué falta, qué existe sin aplicarse, y qué está duplicado o ambiguo

Pediste las tres categorías separadas. Éste es el mapa de tus ocho prácticas contra las reglas que ya
existen.

| Tu práctica | Veredicto | Regla vigente | Detalle |
|---|---|---|---|
| **1.** Comprobar antes de encargar | **Existe, incompleta** | `§14.A` (4 preguntas) | `A` pregunta resultado, simultaneidad, supuesto y frontera. **No** pregunta por la **autorización vigente**, los **archivos afectados** ni si la **evidencia citada corresponde al cambio**. Esas tres son las que fallaron. |
| **2.** Factibilidad del contrato | **Duplicada y AMBIGUA** | `§14.B.1` + `§14.B.2` | Hay **dos taxonomías para la misma distinción**: `B.1` dice «dato medido / cálculo / estimación / hipótesis» y tu práctica dice «deseado / implementado / acreditado». Dos vocabularios compitiendo es lo que permite llamar «acreditado» a lo implementado. **Se consolidan en uno.** |
| **3.** Corregir la promesa completa | **FALTA — y es la causa del retrabajo** | ninguna | Nada obliga a barrer titulares, condiciones, excepciones y **transcripciones** antes de devolver a QA. Es la única de las ocho que no tiene sede. |
| **4.** Reutilizar evidencia válida | **Existe a medias** | `§14.B.7` | `B.7` obliga a **guardar** evidencia con versión base y método. No dice nada de **reutilizarla**, que es la mitad que ahorra la vuelta. Es el complemento natural, en la misma regla. |
| **5.** Separar descubrimiento de ampliación | **EXISTE Y NO SE APLICÓ** | `§14.B.4` «Corregir sin ampliar» | Literalmente ya dice *«los hallazgos adicionales van a la cola salvo que impidan el trabajo en curso»*. No falta regla: faltó cumplirla. **Añadir otra sería el error que pediste evitar.** |
| **6.** Documentación ≠ remediación | **FALTA, pero su sede es `§9`, no `§14`** | `§9` (media) | `§9` ya dice *«un hallazgo resuelto solo en el código o en un log es deriva»*. **Falta la inversa**: resuelto sólo en el requerimiento tampoco es remediación. Es **una cláusula en una frase que ya existe**, no una regla nueva. |
| **7.** Mantener el contador real | **FALTA, pero su sede es `§6`, no `§14`** | `§6` (el tope) | `§6` ya dice que el contador **no se reinicia con cada hallazgo nuevo**. Falta cerrar el hueco del **nombre**: «tramo», «ajuste», «revisión acotada». **Una cláusula en la frase que ya existe.** |
| **8.** Continuar lo independiente | **FALTA, y es la más pequeña** | ninguna | «Antes de declarar todo bloqueado, revisar el trabajo autorizado pendiente.» Cabe en `B.6`, que ya obliga a entregar «siguiente paso». |

**Resumen: una sola regla falta de verdad (la 3).** Dos son cláusulas de secciones que ya existen
(6 → `§9`, 7 → `§6`). Una ya existe y no se aplicó (5). Cuatro son precisiones de reglas vigentes
(1, 2, 4, 8). **Ocho prácticas ⇒ una regla nueva.**

---

## 3. La decisión que necesito, y por qué no la tomo yo

**`REQ-027` está `completado`, y `§9 REGLA DE ESTADO` dice que un cambio en un REQ `completado` lo
devuelve a `en-progreso` o `en-revisión` y le hace re-recorrer el ciclo** (dev → QA → seguridad).

Y hay un detalle que decide cuánto cuesta: su lista contratada dice **«B. Las siete reglas, una línea
cada una (títulos que CA-02 comprueba)»**. Es decir, **`CA-02` comprueba los TÍTULOS**.

De ahí dos vías con costes muy distintos, y **cuál aplica no lo decido yo** —lo decide el analista
con el auditor, porque es la interpretación de su propio criterio—:

| | **Vía 1 — conservadora** | **Vía 2 — con reapertura** |
|---|---|---|
| Qué se hace | **Los siete títulos quedan idénticos byte a byte.** Sólo cambian los **cuerpos**, más una cláusula en `§6` y otra en `§9` | Se añade un título nuevo (una octava regla) o se renombra alguno |
| `CA-02` | **sigue pasando** — comprueba títulos | **cambia el criterio** |
| `§9` | Cambio **MENOR**: editar + `Historial de cambios` + `CHANGELOG` | **REABRE `REQ-027`** y re-recorre dev → QA → seguridad |
| Coste | Write-back del analista + revalidación documental | El único REQ `completado` de la ventana 1.34.0 **deja de estarlo** |
| Riesgo | Que un cuerpo cambiado se considere igualmente cambio de la lista contratada | Ninguno de interpretación; el coste es real y grande |

**Recomiendo la vía 1**, y no por barata: es la que cumple tu propia instrucción de **«consolidar o
sustituir texto antes que aumentarlo»**. La regla que falta (tu práctica 3) es **exactamente el
complemento** de `B.4`, cuyo título ya dice las dos mitades del asunto —**corregir** y **sin
ampliar**—: hoy el cuerpo sólo desarrolla la segunda mitad.

**Redacción propuesta para el cuerpo de `B.4`** (el título no se toca):

> **Corregir sin ampliar** — ante un defecto, **corregir la promesa entera y no la frase señalada**:
> sus titulares, condiciones, excepciones y **transcripciones** en otras sedes, comprobado antes de
> devolverlo a validar. Los hallazgos **nuevos** se registran con dueño y siguiente paso, y van a la
> cola salvo que impidan el trabajo en curso o exista autorización expresa.

Eso resuelve **3** y **5** en la misma regla, **sin un título nuevo**.

---

## 4. Los casos representativos, con su resultado esperado

Pediste pocos y de estas vueltas. Son **tres**, todos de esta ventana y todos con evidencia en disco.

| # | El caso real | Hoy | Con la regla propuesta |
|---|---|---|---|
| **1** | `QA-017-24`: se corrigió la contradicción señalada en `CA-03`. La validación siguiente encontró **la misma forma con el objeto cambiado** (`QA-017-31`): *«toda abstención declara su cota»* → *«toda abstención publica de qué máquina es»* | **Dos vueltas** del tope, y el tope se agotó | El write-back barre **las tres** promesas de `CA-03` contra los tres casos de abstención antes de devolver. **Una vuelta** |
| **2** | `SEC-084` y `QA-016-04`: el arreglo es de código en **una** sede, pero el vocabulario que ambos leen está transcrito en **7–9 archivos**, incluidos `templates/` y `skills/arnes-upgrade/` — que es lo que los proyectos **heredan** | El arreglo pasa QA y la transcripción heredada queda desfasada; el defecto vuelve por la plantilla | La corrección incluye las transcripciones **en la misma comisión**; se enumeran antes de empezar |
| **3** | `SEC-067`: se escribió `NFR-026-01` con el residuo declarado y sus tres campos. **No cierra el hallazgo**: su condición exacta de cierre es el write-back de `SEC-072`, que no está autorizado | Parece avance y no lo es; el cierre se aleja | `§9` dice que documentar no remedia, y **la decisión de alcance se presenta con sus alternativas juntas** en vez de entregar texto |

**Falsable:** si con la regla puesta el caso 1 vuelve a producir dos vueltas, la regla no sirve. Eso
es lo que hay que observar, y es §6.

---

## 5. Delta de tamaño, medido

*Re-derivación:* `awk '/^## 14\./{f=1} f&&/^## 15\./{exit} f' <archivo> | wc -c`

| Artefacto | Hoy | Propuesto | Δ |
|---|---|---|---|
| `AGENTS.md` §14 | **3 667 B** | ~3 790 B | **+123 B (+3,4 %)** |
| `templates/AGENTS.md.tpl` §14 | **3 667 B** | ~3 790 B | **+123 B (+3,4 %)** |
| `AGENTS.md` §6 (cláusula del contador) | — | ~+150 B | **+150 B** |
| `AGENTS.md` §9 (cláusula de la inversa) | — | ~+130 B | **+130 B** |
| **Total sobre `AGENTS.md` (39 709 B)** | | | **+403 B, +1,0 %** |

Y el desglose dentro de §14, que es donde se ve la consolidación:

| Regla | Hoy | Propuesto | Δ |
|---|---|---|---|
| `A` (las 4 preguntas) | 415 B | ~500 B | +85 B — entran autorización, archivos y correspondencia de la evidencia |
| `B.1` | 169 B | ~169 B | **0** — se **sustituye** una taxonomía por la otra, no se suman |
| `B.4` | 165 B | ~330 B | +165 B — absorbe las prácticas **3** y **5** |
| `B.7` | 1 037 B | ~1 100 B | +63 B — la mitad de la **reutilización** |
| `B.6` | — | +40 B | la práctica **8**, una oración |
| **Reglas nuevas** | | | **0 títulos nuevos** |

**El número de reglas no crece: 7 antes, 7 después.** El texto crece **1 %** sobre `AGENTS.md`, y la
mayor parte va a `B.4`, que es donde estaba el agujero.

---

## 6. Cómo observar si el retrabajo baja — sin prometer ahorro

Pediste explícitamente no prometer tokens ni tiempo. **No los prometo**, y hay motivo medido: las
cifras de duración de este repositorio se tomaron en máquinas distintas con dispersión no acotada, y
QA acaba de confirmar que esta máquina **no es el runner**. Cualquier número de ahorro sería una
hipótesis presentada como compromiso, que es lo que `§14.B.2` prohíbe.

Lo que **sí** se puede contar, porque ya vive en disco y no hay que instrumentar nada:

| Indicador | De dónde sale hoy | Qué esperaríamos si la regla funciona |
|---|---|---|
| **Vueltas gastadas por REQ hasta el cierre** | el campo `QA:` declara «vuelta N de 3» | que ningún REQ de la ventana siguiente agote el tope **por una promesa mal barrida** |
| **Hallazgos que son la MISMA FORMA que uno ya cerrado** | los pares ya trazados: `SEC-047` → `SEC-079` → `QA-023-18` → `SEC-083` → `CA-05` → `QA-016-04` → `SEC-084` → `QA-017-24` → `QA-017-31` | que la cadena **deje de alargarse** dentro de un mismo REQ |
| **Hallazgos abiertos en una sede y no en la otra** | el `comm -23` de `§0.b` de la otra propuesta: hoy **11** | que baje, y que no vuelva a subir sin explicación |
| **Write-backs que no cierran su hallazgo** | el caso `SEC-067`/`NFR-026-01` | que la decisión de alcance se pida **antes** de escribir el texto, no después |

**La medición base para comparar es ésta**, y queda escrita: en la ventana 1.34.0, `REQ-017`,
`REQ-021`, `REQ-023` y `REQ-024` **agotaron los tres** —cuatro de cuatro—, y la cadena de «misma
forma» lleva **nueve** eslabones.

---

## 7. Lo que esta propuesta NO hace

- No crea agente revisor, ni puerta permanente, ni REQ nuevo (`REQ-027` ya aplica).
- No cambia ninguna garantía, control, umbral ni alcance de versión, y no publica nada.
- No toca `hooks/`, `tools/`, `tests/`, `.github/` ni `.arnes/config.json`.
- **No modifica todavía ninguna regla heredada:** hasta tu decisión, `AGENTS.md` y
  `templates/AGENTS.md.tpl` quedan como están.

## 8. La decisión que pido

1. **Vía 1 o vía 2** de §3 — mi recomendación es la **vía 1** (títulos intactos, cuerpos
   consolidados, dos cláusulas en `§6` y `§9`).
2. **Si vía 1: quién juzga si es cambio MENOR o reapertura.** Es la interpretación de `CA-02`, un
   criterio de `REQ-027`, así que le corresponde al `analista-requerimientos` con el
   `auditor-seguridad` — no a mí. Autorizás que lo dictaminen, y con su dictamen se ejecuta o se
   vuelve a ti.
