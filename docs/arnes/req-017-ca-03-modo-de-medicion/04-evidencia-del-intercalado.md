# Evidencia — el MODO INTERCALADO de REQ-017 CA-03, implementado y medido
Criterio de decisión declarado ANTES de medir: `03-criterio-del-intercalado-declarado-antes-de-medir.md`.
**Versión base:** rama `rel/registro-1.33.0`, HEAD **`3e49b98`**, más el cambio de esta
comisión (un solo archivo de banco: `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-las-razones.sh`,
y el total del corredor). **Sujeto medido:** `hooks/lib.sh` de este árbol (idéntico a
`3e49b98`: no lo toca esta comisión) y el tag **v1.32.1** materializado con
`git show v1.32.1:hooks/lib.sh` (110 767 B, la misma cifra que `01-evidencia.md`).
**Máquina:** WSL2, 12 núcleos, bash 5.3, `plataforma=linux-gnu-x86_64-bash5.3`.
**Método:** `rr-modo.sh` (en esta carpeta) round-robin con **rotación de orden por ronda**,
reutilizando **sin modificarlas** las sondas `probe.sh` (bloque, réplica literal de la
invocación de `mide37`) y `probe-int.sh` (intercalado, `--sujeto-a`/`--sujeto-b`) que dejó
la comisión anterior. `r = 3` y `k` (20 directa / 1 fail-before) **fijos**: el único
parámetro que se mueve es el MODO. `carga` es el `loadavg` que publica la propia sonda en
cada invocación. Crudos: `medidas-modo.tsv`, `medidas-modo-carga.tsv`, `05-corridas-crudas.txt`.

## 1. Qué se implementó (un archivo de banco; ningún umbral se movió)
- Las **dos** mediciones de CA-03 —la directa sobre este árbol y el **fail-before** sobre
  v1.32.1— pasan a medir sus dos términos **INTERCALADOS en una sola invocación**
  (`mide37i`, que invoca `sr_intercala` de `tests/util/sonda-reloj.sh`: **sede única**, no
  se reescribió nada de la sonda).
- Las dos comparten **una** puerta con la **regla de la banda** y la **dirección como
  dato** (`banda37` + `razon37`): PASS sólo si toda la banda `[mín(2S)/máx(S),
  máx(2S)/mín(S)]` cae del lado conforme, FAIL sólo si toda cae del no conforme, y en
  cuanto el techo cae **dentro**, **SKIP** citando banda, cociente y techo.
- `razon37` publica ahora, **en todas sus ramas**, el **mínimo y el máximo de cada
  término**, el **modo**, `k`, las series, el techo, la **plataforma** y la **carga**. El
  mensaje compartido alcanza a los **5** casos de la sección; ninguno publica menos.
- **Intactos:** techo 2 600 ‰, suelo 50 000 µs, estadístico = mínimo, par S/2S, `k`
  constreñida sólo por el suelo, y el **veredicto y el modo de CA-04** (sus cuatro razones
  siguen en bloque, con la misma `k` y el mismo techo; sólo publican más evidencia).
- Tres casos **nuevos** acreditan la banda (5 → **8** en la sección; total del banco
  1012 → **1015**): la tabla de veredictos en las dos direcciones, el **par discriminante**
  y el **contenido del SKIP**.

## 2. ¿El intercalado ESTRECHA? Round-robin controlado, N=5, `loadavg` fila a fila
Dos magnitudes, porque no dicen lo mismo: la **anchura de banda** `hi/lo` de una
invocación —que es la que **decide** PASS o abstención— y la dispersión **entre rondas**
del cociente. Mediana y **MAD** (nunca el rango: es monótono no decreciente).

### 2.1 Máquina en reposo (`carga` 0,10–0,43) — `medidas-modo.tsv`
| medición | modo | anchura mediana | MAD | cociente mediano | MAD | rango del cociente | coste mediano |
|---|---|---|---|---|---|---|---|
| directa (k=20) | bloque | 1,090 | 0,014 | 1,955× | 0,019 | 4,3 % | 0,833 s |
| directa (k=20) | **intercalado** | **1,086** | 0,008 | **2,104×** | 0,018 | **3,0 %** | **0,807 s** |
| fail-before (k=1) | bloque | **1,075** | 0,032 | 3,867× | 0,065 | 5,1 % | **1,089 s** |
| fail-before (k=1) | **intercalado** | 1,101 | 0,009 | 3,935× | **0,023** | **3,9 %** | 1,102 s |

### 2.2 CPU saturada (12 quemadores en 12 núcleos, `carga` 10,0–14,6) — `medidas-modo-carga.tsv`
| medición | modo | anchura mediana | MAD | rango del cociente | MAD del cociente | veredictos que habría dado |
|---|---|---|---|---|---|---|
| directa | bloque | **1,493** | 0,196 | **26,5 %** | 0,129 | 3 PASS · 2 SKIP |
| directa | **intercalado** | 1,616 | 0,290 | 52,9 % | 0,125 | 3 PASS · 2 SKIP |
| fail-before | bloque | **1,231** | 0,094 | 77,1 % | 0,508 | 5 PASS |
| fail-before | **intercalado** | 1,631 | 0,162 | **52,5 %** | **0,160** | 5 PASS |

### 2.3 Lo que estas dos tablas dicen, con el umbral que se declaró antes de verlas
El criterio pedía afirmar «estrecha» sólo si la **mediana de la anchura** bajaba y la
diferencia superaba la suma de los MAD. **No se alcanza:**
- en reposo, directa: 1,086 contra 1,090, diferencia 0,004 **menor** que 0,014 + 0,008 →
  **NO DISCRIMINADO**;
- en reposo, fail-before: 1,101 contra 1,075 → **NO es más estrecha**, es más ancha;
- saturada: las dos medianas de anchura son **mayores** en intercalado.

Sí estrecha, en cambio, la **dispersión entre corridas del cociente**, que es la magnitud
que la comisión anterior midió: en 3 de las 4 comparaciones el rango baja (4,3→3,0 %,
5,1→3,9 %, 77,1→52,5 %) y en la cuarta sube (26,5→52,9 %); el MAD del fail-before baja
0,065→0,023 en reposo y 0,508→0,160 saturado. **Coste:** igual dentro del ruido (−3,1 %
directa, +1,2 % fail-before), no la mitad: el ahorro de una invocación es de milisegundos
frente a series de 0,8–1,1 s.

### 2.4 La comparación histórica antes/después, sobre la sección aislada
Es la más limpia que existe para el fail-before, y **reutiliza** la tanda de la comisión
anterior en vez de re-derivarla (`01-evidencia.md`, § «Verificación del cambio» y § 6.ª
corrida: 6 corridas en **bloque**, `loadavg` 1,4–1,6) contra mis **5** corridas en
**intercalado** (`loadavg` 1,14–1,28, `05-corridas-crudas.txt`):

| medición | bloque (6 corridas, otra sesión) | intercalado (5 corridas) |
|---|---|---|
| fail-before, cociente | 3,819–4,150 → **rango 8,7 %** | 3,899–3,967 → **rango 1,7 %** |
| directa, cociente | 1,822–2,072 → **rango 13,7 %** | 2,019–2,118 → **rango 4,9 %** |

**Limitación material:** no es un round-robin —son dos sesiones distintas, con carga
parecida pero no la misma—, así que **no** vale como cifra atribuible al modo. La tanda
atribuible es la de § 2.1 y § 2.2, y ésa es la que dice «no discriminado».

### 2.5 Un efecto que NO se buscaba y hay que declarar: el modo mueve el VALOR
La medición directa vale **1,955×** en bloque y **2,104×** intercalado (+7,6 % de mediana,
en reposo y en la misma ronda). El mecanismo se lee en las columnas crudas: intercalado el
mínimo del término corto sale **más bajo** (81–84 ms contra 87–91 ms), porque a partir de
la segunda serie los dos sujetos están calientes, mientras en bloque la invocación del
término corto paga su propio arranque dentro de sus 3 series. Consecuencia práctica: el
**margen** de la directa al techo baja de ~25 % a ~19 %. Sigue siendo margen, y no cambia
ningún veredicto medido, pero es la prueba de que **el modo es un parámetro de la
medición** — que es exactamente por lo que CA-03 exige publicarlo y por lo que mover una
sola de las dos mediciones habría dejado de acreditar el mismo cociente.

## 3. ¿El fail-before DISCRIMINA con el instrumento nuevo?
**Sí, en las 16 corridas medidas, sin una sola excepción.** Once del banco entero
(`ARNES_JOBS=6`, que es el modo de la puerta requerida) y cinco de la sección aislada:

| tanda | corridas | directa | fail-before |
|---|---|---|---|
| banco entero (`carga` 0,7–6,5) | 11 | 10 PASS · **1 SKIP** | **11 PASS** |
| sección aislada (`carga` 1,1–1,3) | 5 | 5 PASS | 5 PASS |

Cotas observadas: el **máximo** de `hi` de la directa fue **2,371×** (PASS) y su banda
mínima nunca cruzó el techo por abajo; el **mínimo** de `lo` del fail-before fue **2,904×**
contra el techo 2,600× (margen 11,7 %) en el banco y **3,300×** en la sección. Cifra a
cifra en `05-corridas-crudas.txt`.

## 4. La ABSTENCIÓN se produjo de verdad, y con sus cifras
Corrida **9** del banco (`carga=2.78`, `plataforma=linux-gnu-x86_64-bash5.3`):

```
SKIP  REQ-017 CA-03 el escáner no crece más que linealmente…  el techo 2.600× cae DENTRO de
la banda: el veredicto dependería del ruido de esta corrida · cociente = 2.133× · banda
compatible [2.000×, 2.817×] · mín/máx 334577/441914µs sobre 156822/167227µs · techo 2.600×
· modo=intercalado k=20 series=3 · plataforma=linux-gnu-x86_64-bash5.3 carga=2.78
```

El cociente (2,133×) cabía **de sobra** bajo el techo; lo que no cabía era el **máximo** del
término largo (441 914 µs contra un mínimo de 334 577: dispersión intra-invocación 1,32×).
La corrida no podía afirmar el techo sin apoyarse en su propio ruido y **se abstuvo**. Es el
resultado que CA-03 ordena, no un fallo: **nunca PASS y nunca FAIL**.

**Frecuencia medida y COTA (CA-03 / `SEC-064`):** 1 abstención en 16 corridas de este árbol
(**1 de 11** del banco entero; **0 de 5** de la sección aislada), y **2 de 5** bajo CPU
saturada. **Máximo de abstenciones CONSECUTIVAS observado: 1**, contra la cota de **no más
de 2**. La cota **no está agotada**, y queda viva como riesgo: el runner corre con
`ARNES_JOBS=6` sobre **4 vCPU** y esta máquina tiene 12 núcleos, así que su vecindad es
peor que cualquiera de las dos tandas de arriba. **De qué máquina es cada cifra va publicado
en la propia línea** del caso (`plataforma=` y `carga=`), que es la exigencia (ii) de la
remediación de `SEC-064`.

## 5. La guarda de la banda no puede fabricar un verde — PROBADO, no argumentado
Propiedad: `lo ≤ coc ≤ hi` por construcción, luego un PASS con banda implica el mismo
veredicto sin ella **en las dos direcciones**. Ejecutado por dos casos nuevos del banco,
con 7 entradas sintéticas y el veredicto sin banda calculado por un **oráculo
independiente** escrito en el propio caso:

```
PASS  REQ-017 CA-03 par discriminante: la banda sólo puede ESTRECHAR…
      (7 entradas: 0 de FAIL a PASS · 1 de FAIL a abstención · 2 de PASS a abstención)
PASS  REQ-017 CA-03 la banda decide en las dos direcciones…
      (10 entradas → PASS FAIL SKIP SKIP PASS FAIL SKIP SKIP SKIP SKIP)
PASS  REQ-017 CA-03 el SKIP de la banda cita las TRES cifras…
      (banda 2.250×-3.200×, cociente 2.700×, techo 2.600×: las cuatro citadas)
```

Las dos mitades del par son de contrato: **ninguna** entrada pasa de FAIL a PASS, y **sí**
hay entradas que la guarda lleva de veredicto a abstención (1 desde FAIL, 2 desde PASS) —
sin esta segunda mitad, «no convierte un FAIL en PASS» lo cumpliría también una guarda que
no hiciera nada. Las diez entradas cubren además el máximo ausente, el suelo de 50 ms y una
**dirección no reconocida** (fail-closed **con** diagnóstico: se abstiene citando el valor).

## 6. Banco completo, cuadre e inventario
- **11 corridas** del banco entero. Las **9 primeras**, **todas `rc 0`** y todas con el
  cuadre cerrado en **1015** casos: `1009+6`, `1009+6`, `1008+7`, `1008+7`, `1008+7`,
  `1008+7`, `1007+8`, `1007+8`, `1007+8` (PASS+SKIP, **0 FAIL en las nueve**). Reloj: 63–65 s.
- Las corridas **10 y 11 salen `rc 1`, y no por esta comisión**: entre la 9 y la 10 otra
  comisión —viva en el mismo árbol— añadió **9 casos** a `40/1` (7 → 12) y `40/3` (16 → 20)
  **sin** actualizar el literal compartido `CASOS_ESPERADOS` de `run.sh`. El ABORT dice
  «corrieron 1024 y se esperaban 1015», y 1024 = 1015 + 9 **exactamente**. En las dos,
  **0 FAIL**, ningún `ABORT: la sección …` y `37/2` con sus **8** casos. El literal es el
  punto de colisión: quien aterrice segundo lo deja en **1024**. Esta comisión **no lo
  toca**: poner 1024 sería certificar 9 casos ajenos y a medio escribir.
- **Autoprueba del corredor: 106 PASS, 0 FAIL, `rc 0`**, incluido `CA-18` con el piso
  re-derivado: `37/2` mide **552 líneas** contra un techo de **689** (gobierna `piso×k`).
- **Inventario (`inventario.sh`), elemento por elemento.** Las 8 líneas de `37/2` salen
  **idénticas byte a byte** entre corridas del mismo código (6 vs 8 vs 9 salvo el veredicto
  de la abstención, que es lo que se quiere ver). El delta contra `3e49b98` es exactamente:
  **3 líneas nuevas** (los tres casos de la banda); **2 líneas con evidencia nueva** (los
  dos casos de CA-03: modo, banda, máximos, plataforma y carga); **2 líneas con evidencia
  nueva y el mismo veredicto** (los dos de CA-04); **1 renombrada** —el fail-before de
  CA-04, de tres nombres a uno, ver abajo—; **0 casos perdidos**.
- **Un defecto propio que cazó el inventario, y no un caso del banco.** El fail-before de
  CA-04 no tenía el separador de **dos espacios**, así que `inventario.sh` leía su línea
  entera como NOMBRE —donde sólo normaliza los numerales en notación de magnitud— y los µs
  recién publicados **sobrevivían crudos**: tres corridas daban tres inventarios distintos.
  Arreglado igual que hizo la comisión anterior con el fail-before de CA-03: **un solo
  nombre** para las tres ramas y la evidencia detrás de dos espacios. Segundo defecto de la
  misma familia: `carga v1.32.1=2.46` **designa** para el oráculo (numeral pegado a un
  nombre por un punto) y también sobrevivía crudo; se publica `carga heredada=…`.

## 7. Limitaciones materiales, dichas enteras
1. **Esta máquina no es el juez.** 12 núcleos contra los **4 vCPU** del runner, que corre
   el banco con `ARNES_JOBS=6`. Ninguna de estas 14 corridas reproduce esa vecindad, y el
   **2,329×** del CI del 2026-09-09 sigue sin reproducirse aquí.
2. **El árbol NO estuvo limpio durante toda la campaña, y va dicho corrida a corrida.** La
   corrida 7 solapó una edición ajena de `hooks/guard-completado.sh`; las 8 y 9 se tomaron
   con esa edición **presente** y declarada; las 10 y 11, además, con los 9 casos nuevos de
   `40/1` y `40/3` de esa misma comisión (de ahí su `rc 1`, § 6). Las 1–6 son anteriores.
   **Ninguna** de las mediciones de CA-03 toca nada de eso: sólo cargan `hooks/lib.sh`, que
   ninguna comisión modificó (`git status` limpio para ese archivo en las once corridas), y
   las cinco corridas de la sección **aislada** ni siquiera ejecutan las otras secciones.
3. **La evidencia del § 2.4 no es atribuible al modo** (dos sesiones distintas). La
   atribuible es § 2.1 y § 2.2, y dice **no discriminado** en la magnitud que se declaró.
4. **El umbral de «estrecha» se declaró antes y NO se cambió al ver que no se alcanzaba.**
   Lo que hay escrito arriba es el resultado, no una lectura acomodada de él.
5. **`CA-18` casi no muerde en `37/2`.** El piso re-derivado (551) queda a 1 línea del
   total (552), porque el bloque indivisible es hoy casi todo el archivo: la puerta es
   **única** y los tres casos que la acreditan **tienen que ejercerla y no una copia**. Es
   honesto y es el mismo patrón que `37/5` (piso 448) y `37/4` (piso 463), pero deja el
   techo casi libre. Va declarado como observación de **instrumento** para el analista, con
   el aviso escrito en el propio archivo.

## 8. Lo que NO se hizo, y por qué (para que no se lea como olvido)
1. **Ningún umbral se movió:** techo 2 600 ‰, suelo 50 ms, estadístico mínimo, par S/2S,
   `k` = 20 / 1 constreñida sólo por el suelo, y `r` = 3 igual que antes.
2. **No se retiró ni se hizo opcional ningún caso.** La sección pasa de 5 a 8 y los 8
   corren siempre; el propietario rechazó expresamente el opt-in para CA-03.
3. **No se repitió hasta obtener verde.** La abstención de la corrida 9 se publica con sus
   cifras; no se re-corrió para taparla ni se promedió con las otras.
4. **No se tocó `hooks/`, `tools/`, `.arnes/`, la sonda, `AGENTS.md`, `templates/`,
   `skills/`, `PENDING_APPROVAL.md`, `docs/ESTADO.md`, `requirements/README.md` ni
   `CHANGELOG.md`.** Tampoco `requirements/REQ-017.md`: el `Estado:` y los veredictos no los
   firma quien implementa.
5. **`CA-04` no cambió de modo, de `k`, de techo ni de veredicto.** Que el intercalado sea
   también el modo correcto para comparar dos ÁRBOLES es plausible y **no está medido en
   esta evidencia**: es otro write-back con su medición.
