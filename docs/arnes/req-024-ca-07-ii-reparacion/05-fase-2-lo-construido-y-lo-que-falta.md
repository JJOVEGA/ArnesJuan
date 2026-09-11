# REQ-024 `CA-07 (ii)` — **vuelta 4, fase 2**: lo construido, lo demostrado y lo que NO está demostrado

> **Versión base:** worktree `/home/juan/dev/ArnesJuan-1.34-reparaciones`, rama
> `feat/1.34-reparaciones-astra`, sobre `69fc96a` + la vuelta 3 sin comitear + la evidencia de
> QA + la fase 1 (`03-…md`). Host de las mediciones locales: **WSL2, 12 núcleos**, bajo la
> contención del propio banco. Runner de referencia: **4 vCPU, `ARNES_JOBS=6`**.
>
> Vuelta **4** de `REQ-024`, autorizada expresamente por el propietario el 2026-09-11. El
> contador no se reinicia: **vuelta 4**.

---

## 0. El titular, por delante y sin adorno

La fase 2 entrega **el mecanismo completo y demostrado**, y **no** entrega la mitad de
detección. Las dos cosas van juntas porque la segunda la refutó **una medición mía**, no una
revisión posterior:

| condición del propietario | estado |
|---|---|
| 1 · Mantener el techo `1,250×` | **cumplida** — `TECHO07=1250`, sede única, intacta |
| 2 · Detectar la regresión de **1,28×** con el método que acreditará al candidato | **NO demostrada** — ver §3. En este host no se detecta a `r=15`, `r=30` ni de forma fiable a `r=60` |
| 3 · Control sin regresión (no cazar cambios correctos) | **cumplida** — árbol limpio → `PASS`, `máx(r) 1,201× ≤ 1,250×` |
| 4 · Inconcluyente = acreditación pendiente; un `SKIP` no habilita la fusión | **cumplida y demostrada** — §2 |
| 5 · Documentar causas de abstención, su cota y el procedimiento | **cumplida** en el código; el write-back del REQ es del analista (`04-…md`) |
| deuda · `plataforma` y `carga` en los mensajes de abstención | **cumplida** |
| retirada de la sonda temporal `40/8` y cuadre | **cumplida** — 1094 → **1095** |

**No presento como cumplimiento un resultado que no permite decidir**, que es literal del
propietario. La condición 2 no está cumplida y aquí está por qué, con los números.

---

## 1. Lo que cambia en el mecanismo

| qué | antes (vuelta 3) | ahora (vuelta 4) |
|---|---|---|
| mandos de la puerta | `k=4 r=6` | **`k=8 r=30`** |
| palanca de acreditación | `k=8 r=30` | **`r=60`** (`ARNES_COSTE_RUTA_CRITICA=1`) |
| una medición inconclusa | `SKIP` → el corredor lo cuenta aparte → **puerta VERDE** | se **vuelve a medir** hasta `INTENTOS07=3`; agotado, **`FAIL`** nombrado «no se pudo acreditar» |
| suelo de detección | `FACTOR07` = 1,733× en un **comentario** (`QA-024-21`) | **derivado de la propia medición** (`techo × recorrido`) y **publicado en cada veredicto** |
| par discriminante sintético | regresión de **2×** | regresión de **1,28×**, la magnitud de los rojos reales de CI |
| máquina de la medición | no se publicaba | `plataforma`, `carga` y `jobs` en **todos** los mensajes |
| vía de acreditación en el `SKIP` | ofrecía la palanca **aunque ya se estuviera usando** (`QA-024-22`) | condicional: si ya se usa, dice que la salida **no** es repetirla |
| casos de `40/7` | 5 | **6** |

### `k=8` está MEDIDO, y es la parte sólida

En el runner, con carga **5,04** idéntica, la primera repetición a `k=4` dio **805‰** y la
primera a `k=8` dio **1018‰** sobre una razón verdadera de 1,000×. `k` alarga la serie de ~54 ms
a ~110 ms y la saca del régimen en que manda el planificador. Esto no es extrapolación: son dos
filas del mismo registro (`corridas/vuelta4-fase1/RUNNER-1b3760e-salida-literal.txt`).

### `r=30` es PROVISIONAL, y lo digo yo

La fase 1 lo eligió sobre la **nula**. La fase 2 fue a confirmarlo con una regresión **real** y
lo refutó en parte (§3). Se deja en 30 porque es donde la nula del runner plateaua (1,009 a
r=30 frente a 1,021 a r=15) y porque cuesta **+24,6 s**, dentro de los **60 s** que la fase 1
fijó antes de medir. **No** porque esté demostrado que detecta 1,28×.

---

## 2. Condición 4, demostrada: un `SKIP` ya no deja la puerta en verde

**El defecto, medido en la corrida del propio runner (`1b3760e`):** el caso se abstuvo con
recorrido `[0,836× , 1,598×]` y **`hooks-en-linux` salió `success`**. El `SKIP` habilitaba la
fusión sin ninguna medición válida.

**Lo construido:** `cierre07` es la sede única de la escalada — `pass|fail` → `emitir`;
inconcluso con presupuesto → `reintentar`; inconcluso agotado → `sin-acreditar` → **`FAIL`**.

**Ejecutado sobre una regresión REAL inyectada en una copia** (`for ((_qa=0;_qa<2000;_qa++))`
tras el shebang de `guard-completado.sh`, `ARNES_HOOKS_DIR` apuntando a la copia; **el árbol no
se tocó**):

```
(reintento) … el intento 1 de 3 no resolvió (el techo cae DENTRO del recorrido observado
            [1.225×, 1.354×] · máquina linux-gnu-x86_64-bash5.3 · carga 2.14 · jobs 6)
(reintento) … el intento 2 de 3 no resolvió ([1.225×, 1.404×] · carga 1.55)
FAIL        … NO SE PUDO ACREDITAR en 3 intentos ([1.207×, 1.329×]). Esto NO afirma que haya
            regresión: afirma que esta puerta no pudo MEDIRLO …
```

**Los dos `FAIL` se distinguen en el texto, y eso importa:** el de regresión dice «mín(r) > techo
en TODAS: es regresión, no ruido»; el de exhaustión dice «NO SE PUDO ACREDITAR … esto NO afirma
que haya regresión». Un rojo que no distingue las dos cosas enseña a leer mal el siguiente.

**Y lleva su mitad discordante** (caso 6 del banco, determinista): la **misma** entrada por el
camino de presentación sigue dando `SKIP`, que es exactamente lo que dejaba la puerta en verde.
Sin esa mitad, el `sin-acreditar` no demostraría que lo cambia **la escalada** y no la entrada.

### La cota, que ahora es comprobable DENTRO de la corrida

`REQ-017 CA-08 (ii)` contrata la cota como «no más de 1 corrida **consecutiva** abstenida», y
deja abierto que **dos abstenciones no se pueden sumar sin saber de qué máquina salió cada una**.
Con la escalada, la cota deja de necesitar esa agregación: **dentro de una corrida** o se
resuelve o se emite `FAIL`. Es una forma más fuerte de la misma regla. Aun así se añadieron
`plataforma`, `carga` y `jobs` a **todos** los mensajes, porque la cota entre corridas sigue
siendo la del criterio hermano.

---

## 3. Condición 2: lo que MIDÍ y lo que refuta mi propio supuesto de la fase 1

La fase 1 declaró un supuesto (`03-…md` §1): que la `ε` medida sobre la **nula** —mismo árbol en
los dos brazos— es la que actúa sobre un árbol **regresado**. Y declaró que la fase 2 tenía que
**confirmarlo con una regresión real, no darlo por bueno**. Fui a confirmarlo. **No se confirma.**

Regresión real inyectada, razón verdadera ≈ **1,29×** (medida: razones 1,353 1,262 1,289 1,286):

| mandos | recorrido de la **nula** (fase 1, runner) | recorrido de la medición **REAL** (este host) | ¿detecta 1,29×? |
|---|---|---|---|
| `k=8 r=15` | 1,021 | 1,066 · 1,085 · 1,066 | **no** — `sin-acreditar` en 3 intentos |
| `k=8 r=30` | 1,009 | 1,10 | **no** — `sin-acreditar` en 3 intentos |
| `k=8 r=60` | 1,010 | 1,125 (intento 1) · 1,072 (intento 2) | **marginal** — resolvió en el 2.º intento, `mín(r) 1,262×` contra techo 1,250× |

**Dos hechos nuevos, y ninguno es cómodo:**

1. **La nula SUBESTIMA la dispersión de lo que la puerta mide de verdad.** La comparación real
   enfrenta **dos árboles distintos**; la nula, el mismo dos veces. El criterio C1 de la fase 1
   se aplicó a la nula, y por eso dio `VIABLE` con márgenes de 17–22‰ que la medición real no
   respalda.
2. **En este host, `r` NO estrecha el recorrido de la medición real.** 1,066 → 1,10 → 1,07–1,13
   al pasar de `r=15` a `r=30` a `r=60`, o sea **plano con 4× el coste**. La dispersión residual
   no es ruido de muestreo que un mínimo sobre más series pueda promediar: parece contención
   autocorrelada durante toda la invocación, y alargar la ventana no la decorrela.

**Y aquí me paro.** Probé `r=15`, `r=30` y `r=60`: eso ya es el bucle de tanteo de parámetros que
el propietario prohibió expresamente («*No consumas otra vuelta automática intentando ajustar
parámetros indefinidamente*»). No hay una cuarta prueba.

### Lo que sigue sin saberse, dicho como incógnita y no como matiz

**El recorrido de la medición REAL en el runner a `k=8 r=30` no está medido.** El único dato del
runner sobre la medición real es a `k=4 r=6`: **1,911**, frente a una nula de 1,395 en la misma
corrida — o sea que allí la real también es más ancha que la nula, en la misma dirección que
aquí. **Lo decidirá la próxima corrida de CI**, porque el caso ahora publica su recorrido, su
suelo derivado y su máquina en cada veredicto. No hace falta instrumento nuevo ni otra sonda
temporal: la evidencia la produce el propio caso.

---

## 4. Las alternativas, con sus consecuencias — no una recomendación suelta

Ninguna es «subir el techo» ni `continue-on-error`, que el propietario excluyó.

- **(A) Dejarlo como queda y leer la próxima corrida de CI.** El caso ya publica recorrido real,
  suelo derivado y máquina. *Consecuencia:* coste cero ahora; la decisión se toma con el dato que
  falta. *Riesgo:* si el runner se parece a este host, el caso emitirá `FAIL` por exhaustión en
  PR sanos y la puerta requerida se pondrá roja sin regresión — que es la clase de rojo que
  termina con alguien apagando el guard (H-11).
- **(B) Subir `INTENTOS07`.** Los reintentos sí ayudan (el único éxito a `r=60` fue un segundo
  intento), porque **separan en el tiempo** y el tiempo es lo que descontenciona. *Consecuencia:*
  el peor caso crece linealmente: con 5 intentos a `r=30` son ~135 s, **por encima** de los 60 s
  que la fase 1 fijó. Exigiría re-declarar el presupuesto, y eso es decisión de alcance.
- **(C) Cambiar el sujeto para que su coste absoluto suba** (medir un lote de N entradas en vez
  de una), de modo que el mismo ruido relativo pese menos. *Consecuencia:* cambia **qué** mide el
  criterio y obliga a re-derivar el techo; es otro REQ, no una reparación.
- **(D) Sacar la decisión de reloj de la puerta **de cada PR** y acreditarla como acto fechado y
  re-ejecutable**, la vía que `REQ-017 CA-05` ya usa. *Consecuencia:* deja de vigilarse en cada
  PR y hay que decir quién la corre y cuándo bloquea. **`REQ-017 CA-08 (ii)` dice explícitamente
  que esta salida es decisión del PROPIETARIO con entrada en `PENDING_APPROVAL.md`**, no del
  desarrollador — por eso la enumero y no la tomo.

---

## 5. Coste, medido — incluido el que le cobro a los vecinos

El caso pasa de **3,6 s** a **~27 s** por veredicto (`4 × 2 × 8 × 30` invocaciones). Eso es
**+24,6 s**, dentro de los 60 s del presupuesto… **medido como tiempo de la sección**. Pero el
banco corre 6 secciones a la vez, así que también es **+24 s de trabajo ligado a CPU compitiendo
con los vecinos**, y eso el presupuesto de la fase 1 **no lo cubría**. Se midió:

| vuelta del banco entero | resultado | cuadre |
|---|---|---|
| **v1** | **1079 PASS · 4 FAIL · 12 SKIP**, rc 1 | 1095 ✓ |
| **v2** | 1086 PASS · 0 FAIL · 9 SKIP, rc 0 | 1095 ✓ |
| **v3** | 1087 PASS · 0 FAIL · 8 SKIP, rc 0 | 1095 ✓ |

**Los cuatro `FAIL` de v1 se conservan y NO quedan desmentidos por v2 y v3** (memoria
`variabilidad-no-desmiente-un-fail`). Ninguno es de `CA-07 (ii)`; tres salen de **una** causa —la
calibración de `sonda-reloj.sh` se salió de banda, `b=773` contra un suelo de 800— y el cuarto es
un caso de presupuesto de pared (`heredoc de ~300 KB`, 4455 ms contra 1000 ms). Los cuatro son
sensibles a la carga. **Lo honesto es decirlo así: 1 de 3 vueltas salió roja por criterios de
reloj vecinos después de que este caso multiplicara por 7,5 su consumo de CPU, y no tengo
evidencia que separe «mi carga lo causó» de «esos criterios ya eran así».** Separarlo exigiría
vueltas con y sin el cambio, y eso es medición nueva, no una frase.

*Corridas guardadas:* `corridas/vuelta4-fase2/local-banco-v{1,2,3}.txt`, `local-autoprueba.txt`.

---

## 6. Quality gates

| puerta | resultado |
|---|---|
| `bash -n` de `hooks/*.sh` y `tools/*.sh` | ok |
| `jq -e .` de `hooks.json`, `plugin.json`, `marketplace.json` | ok |
| `bash -n` de `run.sh` y de las 65 secciones | ok |
| banco entero | **1095** casos, cuadre exacto en las tres vueltas, **0 ABORT**; 0 FAIL en v2 y v3, 4 FAIL en v1 (§5) |
| `autoprueba-corredor.sh` | **106 PASS · 0 FAIL**; CA-18: `lineas=449 piso=449 techo=562` |
| los 6 casos de `40/7` sobre árbol limpio | **6 PASS** |

---

## 7. Archivos tocados en la fase 2

| archivo | qué |
|---|---|
| `tests/escenarios/hooks/secciones/40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh` | mandos, `mide07`, `resuelve07`, `cierre07`, bucle de reintento, suelo derivado, máquina en los mensajes, `QA-024-22`, demostración 5. 329 → 449 líneas, 5 → 6 casos |
| `tests/escenarios/hooks/secciones/40-ausencia-que-abre-8-sonda-de-viabilidad.sh` | **BORRADO** (sonda temporal de la fase 1) |
| `tests/escenarios/hooks/run.sh` | `CASOS_ESPERADOS` 1094 → **1095**, con su derivación escrita |
| `docs/arnes/req-024-ca-07-ii-reparacion/05-…md`, `corridas/vuelta4-fase2/` | este artefacto |

**No se tocó:** `hooks/`, `tools/`, `tests/util/`, `.github/`, `.arnes/config.json`,
`.claude-plugin/`, `requirements/`, el techo `1,250×`, ni ningún otro criterio de reloj.

## 8. Entrada de `CHANGELOG.md` lista para pegar (NO se escribió: la comisión reserva el commit)

```markdown
### [2026-09-11] — REQ-024 CA-07 (ii), vuelta 4 fase 2: un SKIP deja de habilitar la fusión, y la detección de 1,28× queda SIN demostrar
- **Origen:** GitHub · **Usuario:** juan.vega@sysvega.cr · **Modelo IA:** Claude Opus 5
- **Agente(s):** `desarrollador`
- **Detalle:** medido en el runner (`1b3760e`), `k=4 r=6` recorre [0,805× , 1,123×] sobre una
  razón verdadera de 1,000×, así que no resuelve el factor que vigila (QA-024-21). Los mandos
  pasan a `k=8 r=30` —`k=8` está medido: con la MISMA carga 5,04 la razón pasa de 805‰ a
  1018‰— y la palanca de acreditación a `r=60`. Una medición inconclusa deja de emitir `SKIP`
  y salir verde: se REMIDE hasta 3 veces y, agotado el presupuesto, el caso emite `FAIL`
  nombrado «no se pudo acreditar», distinto en el texto del FAIL por regresión; demostrado
  sobre una regresión real inyectada en una copia y con su mitad discordante en el banco. El
  suelo de detección deja de ser una constante en un comentario y se DERIVA de cada medición
  (`techo × recorrido`), publicándose con la máquina y la carga en todos los mensajes
  (QA-024-22 y la deuda de `plataforma`/`carga` incluidas). El par discriminante sintético baja
  de 2× a 1,28×. Se retira la sonda temporal `40/8`; `CASOS_ESPERADOS` 1094 → 1095.
  **Lo que NO queda demostrado y se declara:** la detección de 1,28× con los mandos de la
  puerta. La nula subestima la dispersión de la comparación real, y en este host `r` no la
  estrecha (1,066 → 1,10 → 1,07 al 4× el coste). El techo 1,250× queda INTACTO y no hay
  `continue-on-error`. Evidencia y alternativas:
  `docs/arnes/req-024-ca-07-ii-reparacion/05-fase-2-lo-construido-y-lo-que-falta.md`.
```
