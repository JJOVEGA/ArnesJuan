# Coste de reloj por comisión — medido en la sesión del 2026-09-10

**Versión base:** rama `rel/registro-1.33.0`, commits `b369094`…`b99cfbb`, 2026-09-10.
**Método:** duración de reloj que el propio orquestador reporta al terminar cada subagente
(`duration_ms`), sobre esta máquina (WSL2, 8 núcleos). **No es una estimación: es lo que tardaron.**
Estadístico: **mediana y MAD**, no rango — el rango es monotónicamente no decreciente y crece con la
muestra, así que no compara.

## Lo medido, comisión por comisión

| # | Rol | Encargo | Duración |
|---|---|---|---|
| 1 | `qa-tester` | modo intercalado de `REQ-017` (`86a44c8`) | **27,5 min** |
| 2 | `analista` | write-back `QA-017-24` | **8,6 min** |
| 3 | `analista` | cota de `CA-08 (ii)` | **5,3 min** |
| 4 | `qa-tester` | vuelta 3 de 3 de `REQ-017` | **22,2 min** |
| 5 | `analista` | `SEC-067` → `NFR-026-01` | **7,5 min** |
| 6 | `auditor-seguridad` | reconciliación `R-028` | **18,3 min** |
| 7 | `analista` | corrección de `QA-017-31` | **7,1 min** |
| 8 | `qa-tester` | revalidación de `CA-03` fuera del contador | **16,7 min** |
| 9 | `analista` | tercera sede, `CA-03:62` | **3,2 min** |
| 10 | `analista` | dos campos desfasados (`SEC-014`, `SEC-083`) | **6,3 min** |
| 11 | `analista` | dos estados desfasados (`SEC-055`, `REQ-023`) | **9,6 min** |

## Estadísticos por rol

| Rol | n | Mediana | MAD | Nota |
|---|---|---|---|---|
| `analista-requerimientos` | **7** | **7,1 min** | **1,5 min** | la muestra más sólida |
| `qa-tester` | **3** | **22,2 min** | **5,4 min** | n pequeño |
| `auditor-seguridad` | **1** | 18,3 min | — | **n = 1: no hay dispersión, y no se presenta como típico** |
| `desarrollador` | **0** | — | — | **NO SE MIDIÓ NINGUNA en esta sesión: no hay base** |

## Las cuatro limitaciones, y ninguna es menor

1. **`desarrollador` no tiene ni una medición.** Es el rol de las correcciones de código que quedan
   (`SEC-073`, `SEC-084`, `QA-024-19`, `SEC-075`), así que la parte más incierta del trabajo restante
   es justo la que no se puede acotar con esto.
2. **Esta máquina no es el runner** (WSL2 de 8 núcleos contra 4 vCPU con `ARNES_JOBS=6`), así que
   estas cifras **no** predicen el CI. Y el CI de esta rama **no discrimina** en los criterios de
   reloj (`docs/arnes/ci-1.34.0-no-discrimina/`).
3. **Es tiempo de EJECUCIÓN de agente, no de calendario.** No incluye la espera por firmas humanas,
   que **no tiene base ninguna** aquí.
4. **`AGENTS.md` §6 fuerza la serie, y está medido:** `tools/arnes-paralelo.sh` declaró que
   `REQ-017`, `REQ-013` y `REQ-024` **colisionan** por `tests/escenarios/hooks/run.sh` y
   `hooks/lib.sh`. Así que estas duraciones **se suman**, no se solapan.

## Cómo se re-deriva

Las once cifras salen de los informes de terminación de subagente de la sesión
`23a8ee5a-8587-4923-8f15-1fc9bf03aaf2`. Para una sesión nueva se re-mide igual: anotar `duration_ms`
al cerrar cada comisión y recalcular mediana y MAD por rol. **Con `n < 5` en un rol, decirlo.**

---

# Registro de comisiones — sesión del 2026-09-11 (integración de `#48`)

**Instituido por instrucción del propietario (2026-09-11):** se registra al terminar cada comisión
el REQ o tarea y el rol, inicio y fin **con zona horaria**, resultado y commit o árbol revisado,
tokens **sólo si la herramienta los da**, y la **fuente** de cada dato. Si falta un dato se escribe
**«no registrado»** — no se reconstruye ni se toma de otra sesión.

**Zona horaria:** `America/Costa_Rica` (CST). **Fuente de los tiempos:** el informe de terminación
de subagente del orquestador (`duration_ms`) y la marca de creación del archivo de tarea
(`stat -c %w`). **Fuente de los tokens:** el campo `subagent_tokens` del mismo informe.

| # | Tarea y rol | Inicio (CST) | Fin (CST) | Duración | Resultado | Árbol / commit | Tokens | Fuente |
|---|---|---|---|---|---|---|---|---|
| 1 | `SEC-090` — reconciliación del registro · `auditor-seguridad` | 2026-09-11 06:39:05 | 2026-09-11 06:53:35 | **14 min 30 s** | `SEC-090` `abierto` → `mitigado` (`R-032`); 0 identificadores perdidos | `feat/1.34-reparaciones-astra` @ `3c52d6d` → commiteado en `0caeac5` | **132 158** | `duration_ms` y `subagent_tokens` del informe de terminación |
| 2 | `REQ-024 CA-07 (ii)` — reparar el instrumento · `desarrollador` | 2026-09-11 07:05:08 | 2026-09-11 08:00:52 | **55 min 45 s** | causa = dispersión del instrumento, no regresión; guarda de convergencia portada; criterio acreditado a 1,118× | `feat/1.34-reparaciones-astra` @ `69fc96a` | **285 206** | ídem |
| 3 | `REQ-024 CA-07 (ii)` — QA acotada de la reparación · `qa-tester` | 2026-09-11 08:02:31 | 2026-09-11 08:33:42 | **31 min 11 s** | **`con-hallazgos`** (vuelta 1 de esta acotada; el contador §6 de `REQ-024` sigue agotado 3/3 y NO se reinició). 5 hallazgos: `QA-024-20` (`contrato`, bloquea) y 4 `instrumento` | árbol de trabajo sobre `69fc96a` | **185 933** | ídem |

| 4 | `REQ-024 CA-07 (ii)` — **vuelta 4**, fase 1: viabilidad de la precisión en el CI real · `desarrollador` | 2026-09-11 08:43:33 | 2026-09-11 09:11:30 | **27 min 57 s** | sonda de viabilidad entregada, condiciones y criterio fijados **antes** de ejecutar; expectativa propia registrada («espero NO VIABLE») | árbol sobre `69fc96a` → commiteado en `1b3760e` | **218 994** | ídem |

| 5 | `REQ-024 CA-07 (ii)` — **vuelta 4**, fase 2: implementación · `desarrollador` | 2026-09-11 09:19:15 | 2026-09-11 09:52:57 | **~32 min** | **4 de 5 condiciones cumplidas**; la detección de 1,28× con los mandos de la puerta **NO** demostrada. Se detuvo en vez de tantear parámetros | árbol sobre `1b3760e` | **350 088** | ídem |

| 6 | `QA-024-20` — write-back del criterio · `analista-requerimientos` | 2026-09-11 10:05:10 | 2026-09-11 10:05:23 | **7 min 19 s** | cinco sedes corregidas (una más de las cuatro encargadas); abstención enunciada **por propiedad**; no afirma detectar 1,28× | árbol sobre `f2b74d9` | **125 018** | ídem |

| 7 | `REQ-024 CA-07 (ii)` — QA acotada **vuelta 2** · `qa-tester` | 2026-09-11 10:22:58 | 2026-09-11 11:13:25 | **48 min 29 s** | **`con-hallazgos`**. Comprobaciones 1·2·3 **acreditadas**, la 4 **no**. Cierra `QA-024-20/21/24`; abre `QA-024-25/26` (`contrato`), `27`, `28` | `ab3e4cb` | **214 463** | ídem |

| 8 | `QA-024-25/26` — transcripción del contrato · `analista-requerimientos` | 2026-09-11 11:30:50 | 2026-09-11 11:40:13 | **9 min 22 s** | **seis** sedes corregidas (dos más de las cuatro listadas); bloqueo sin atribución; suelo como dato diagnóstico; `REQ-017.md:118` **nombrada y no tocada** | `f612b84` | **126 548** | ídem |

| 9 | `QA-024-25/26` — mensajes del programa · `desarrollador` | 2026-09-11 11:30:50 | 2026-09-11 11:56:21 | **25 min 31 s** | **ocho** sedes (cinco fuera de la lista); decisión y `rc` idénticos por **cinco** pruebas; `37/5` tocada sin tocar `REQ-017.md` | `f612b84` | **174 744** | ídem |

| 10 | `QA-024-25/26` — revisión del delta · `qa-tester` (3.er pase de la vuelta 4) | 2026-09-11 11:58:08 | 2026-09-11 12:21:48 | **23 min 40 s** | **el delta CUMPLE**; cierra `QA-024-25` y `QA-024-26`; abre `29/30/31` (`instrumento`, ninguno bloquea) | `d82c127` | **203 205** | ídem |

| 11 | Delta de redacción — revisión de seguridad acotada · `auditor-seguridad` | 2026-09-11 12:23:29 | 2026-09-11 12:34:22 | **10 min 53 s** | **`R-033`, sin veto**. La puerta no se debilitó (por construcción); abre `SEC-091` y `SEC-092` (`instrumento`, no bloquean) | `0b2f227` | **116 377** | ídem |

| 12 | `REQ-017.md:118` — retirar la atribución absoluta · `analista-requerimientos` | 2026-09-11 13:30:20 | 2026-09-11 13:39:21 | **9 min 1 s** | **seis** sedes corregidas (cinco fuera de la lista) + dos transcripciones declaradas; umbrales y tres salidas intactos; deriva contra `37/5:273` cerrada | `e53de46` | **139 416** | ídem |

| 13 | `SEC-084`/`QA-024-19` — reproducción sobre `e53de46` y reparación · `desarrollador` | 2026-09-11 13:30:20 | 2026-09-11 13:57:50 | **27 min 30 s** | **(c)** el vector medido ya estaba cerrado por `v1.33.1`+`#48`; **(b)** la clase sobrevive en el disparador del **aviso**, vivo en la `v1.33.2` publicada; reparado por propiedad | `6327b8c` | **199 406** | ídem |

| 14 | Disparador del aviso — QA · `qa-tester` (**vuelta 5** dev↔QA de `REQ-024`) | 2026-09-11 14:05 | 2026-09-11 14:38:46 | **33 min 46 s** | **`con-hallazgos`**. El **código** queda acreditado entero (0 celdas `DENY→ALLOW` de 56); `QA-024-19` **no se cierra** por falta de write-back; abre `QA-024-32` (`instrumento`) | `a05994f` | **187 286** | ídem |

| 15 | `QA-024-19` — write-back del contrato · `analista-requerimientos` | 2026-09-11 14:40 | 2026-09-11 14:51:22 | **11 min 22 s** | **cuatro** sedes vivas (no una); criterio nuevo `CA-13`; las «tres reglas» de la sección heredada pasan a **cuatro** | `21c52c6` | **191 964** | ídem |

> **Vuelta 4 de `REQ-024`, autorizada expresamente por el propietario el 2026-09-11**, por encima
> del tope de tres de `AGENTS.md` §6. **El contador no se reinicia** y el historial se conserva: es
> la vuelta **4** y así se numera en todas las sedes. Alcance autorizado: resolver `QA-024-20` y la
> banda ciega de `QA-024-21`, más las correcciones **estrictamente** relacionadas. **No** autoriza
> aceptar residuales, rebajar el techo de `1,250×` ni fusionar con ese bloqueo pendiente.
> Condición previa impuesta por el propietario: **comprobar de forma acotada que la precisión
> necesaria es viable en el CI real** antes de ampliar la implementación.

## Estimación del ciclo restante — y lo que NO es

El propietario lo advirtió expresamente: **los 86 minutos de desarrollo + QA de la vuelta 3 no son
la duración del ciclo siguiente**, porque ese ciclo incluye además seguridad y CI. Lo medido, por
comisión y con su `n`, es lo único que hay:

| Rol | n | Mediana | Fuente |
|---|---|---|---|
| `desarrollador` | **1** | 55 min 45 s | esta sesión — **n = 1, no se presenta como típico** |
| `qa-tester` | 4 | ~22–31 min | 3 de la sesión anterior + 1 de ésta |
| `auditor-seguridad` | 2 | 14,5 y 18,3 min | una de cada sesión |
| `hooks-en-linux` (CI) | 7 | ~2 min | corridas de esta rama |

**No hay base para un total del ciclo**, porque la fase 1 puede terminar en «no viable» y entonces no
hay fase 2, ni QA, ni seguridad. La estimación se dará cuando la viabilidad esté medida.

## Lo retirado del informe anterior, y no se reconstruye

Por instrucción del propietario quedan **retirados** los conteos y tiempos sin respaldo que publiqué
al cerrar la ventana de 8 h: «doce comisiones», las muestras «7 + 6 + 3», y una mediana atribuida al
rol `desarrollador`, que en la tabla de arriba de este mismo archivo tiene **n = 0**. **No se
reconstruyen.** Durante la ventana autónoma del 2026-09-10/11 **no se registró ninguna duración en
disco**, así que de ese período no hay cifras y así se dice.

**No hay total de tokens de la sesión**, y no se calcula multiplicando medianas ni rangos. Sólo
existen los valores por comisión que la herramienta publicó, arriba.
