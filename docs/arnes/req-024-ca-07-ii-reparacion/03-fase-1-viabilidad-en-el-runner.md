# REQ-024 `CA-07 (ii)` — **vuelta 4**, fase 1: ¿es viable en el runner la precisión que hace falta?

> **ESTE ARCHIVO SE ESCRIBIÓ ANTES DE EJECUTAR NADA.** Los ajustes, las repeticiones, el
> orden, el tope de reloj y —sobre todo— **el criterio de viabilidad con su cifra** quedan
> fijados aquí para que la interpretación no se elija después de ver los números
> (`AGENTS.md` §14.B.1 y §14.B.7; instrucción del propietario: *«Fija antes de ejecutar las
> condiciones y repeticiones del experimento; conserva todos los resultados. No relances
> hasta obtener la respuesta favorable.»*).
>
> **Vuelta 4 de `REQ-024`**, autorizada expresamente por el propietario el 2026-09-11 por
> encima del tope de tres de `AGENTS.md` §6. El contador **no se reinicia**: esto es la
> vuelta 4 y así se numera. No es un tramo, un ajuste ni una revisión acotada.

---

## 0. Versión base y qué se reutiliza

| qué | valor |
|---|---|
| worktree | `/home/juan/dev/ArnesJuan-1.34-reparaciones` |
| rama | `feat/1.34-reparaciones-astra` |
| commit base | **`69fc96a`** + los cambios **sin comitear** de la vuelta 3 + la evidencia de QA en `docs/qa/` |
| evidencia propia reutilizada | `00-metodo-y-plan.md`, `01-diagnostico.md`, `02-reparacion-y-demostraciones.md`, `corridas/`, `demostraciones/` (fases 1–4) |
| evidencia de QA reutilizada | `docs/qa/evidencia-req-024-ca07ii-69fc96a/` (300 razones re-derivadas, la regresión inyectada de 1,28×/1,35×, la nula propia de QA) |
| runner | `ubuntu-latest`, **4 vCPU**, `ARNES_JOBS=6` (sobresuscrito), `timeout-minutes: 20`, banco hoy ≈ 2 min |

**No se re-mide nada de lo ya medido.** La fase 1 añade exactamente **una** magnitud que no
existe en ninguno de los dos artefactos: **la dispersión del instrumento EN EL RUNNER**, a
varios ajustes `(k, r)`, con su coste.

**Por qué no vale medirla aquí.** Está medido en este mismo repositorio
(`docs/arnes/ci-1.34.0-no-discrimina/`) que esta máquina y el runner **no predicen lo
mismo**: aquí hay WSL2 (8 núcleos en mi host, 12 en el de QA) y allí 4 vCPU con seis
trabajos en paralelo. Cualquier cifra de dispersión local es un **contraste**, nunca la
respuesta.

---

## 1. La pregunta de la fase 1, escrita como una desigualdad

El criterio decide por **unanimidad** sobre `KRAZ07 = 4` razones (`40/7:213-233`):

```
PASS  ⟺  máx(r_i) ≤ T          FAIL  ⟺  mín(r_i) > T          SKIP  en cualquier otro caso
```

con `T = 1,250×` (`TECHO07=1250`, **intacto**, no se sube: condición 1 del propietario).

Sea `ρ` la razón **verdadera** del sujeto y `ε_i` el ruido **multiplicativo** del
instrumento, de modo que `r_i = ρ · ε_i`. Entonces:

> **Detectar una regresión de `ρ = 1,28×` exige `mín(ε_i) > T/ρ = 1250/1280 = 0,976 5…`**

En milésimas, y redondeando **hacia arriba** porque es una cota:

> ### **`ε_mín ≥ 977‰` en toda ventana de 4 repeticiones consecutivas.**
>
> Comprobación aritmética: `1280 × 977 / 1000 = 1250,56 > 1250` ✓ · `1280 × 976 / 1000 =
> 1249,28 ≤ 1250` ✗. El umbral entero es **977**, no 976.

Y la condición **simétrica**, que es la que impide «cazar todo» (condición 3 del
propietario: un instrumento que rechaza cambios correctos no vale). Con la razón verdadera
del árbol limpio ya acreditada en **1,118×** (fase 4, re-derivada por QA en 1,112×–1,153×),
para que un candidato **correcto** pueda salir `PASS`:

> ### **`ε_máx ≤ 1118‰`** (`T/ρ₀ = 1250/1118 = 1,118 0…`).

**Cuál de las dos manda, y se dice por delante:** la primera. Si el ruido es aproximadamente
simétrico en escala logarítmica, `ε_mín ≥ 977‰` implica un recorrido ≲ 1,047× y por tanto
`ε_máx ≲ 1,023 ≤ 1,118`. La segunda se comprueba igualmente —no se da por deducida—, pero el
cuello de botella es la **cola baja** sobre un árbol regresado.

**La medida de `ε` es la NULA:** el mismo árbol en los dos brazos, razón verdadera `1,000×`
**por construcción**. Es el mismo discriminante que la vuelta 3 ya usó y que QA re-hizo por
su cuenta; lo único nuevo es **dónde** se toma.

### Supuesto del método, declarado y no escondido

Que el ruido sea **multiplicativo e independiente del coste verdadero del sujeto** —o sea,
que la `ε` medida sobre la nula sea la misma que actúa sobre un árbol regresado— es un
**supuesto**, no un dato. Es el supuesto estándar para un cociente de dos mínimos medidos
en el mismo intercalado, y es el que sostiene toda la vuelta 3. **Consecuencia declarada:**
si la fase 1 sale viable, la fase 2 **tiene que confirmarlo con una regresión REAL
inyectada** (la de QA, `N=1500` ≈ 1,28×), no dar el supuesto por bueno. La fase 1 no lo
confirma y no dice que lo haga.

---

## 2. Los ajustes, FIJADOS — y por qué esos

`k` y `r` no son la misma palanca, y eso está medido:

- **`k` (repeticiones del sujeto dentro de cada serie) es la palanca del SUELO.** `QA-024-23`
  midió que en un host **en reposo** la serie del brazo heredado cae **por debajo del suelo
  de 50 ms** (`min_b` 46,2 / 47,3 / 47,7 ms con `k=4`) y la sonda devuelve `estado=suelo`:
  el caso se abstiene **sin haber medido nada**. Duplicar `k` duplica la serie y la saca del
  suelo. En el runner esto **no está medido en ninguna dirección**, y por eso `V0` conserva
  `k=4`: para **observar** si el suelo dispara allí.
- **`r` (series por brazo, intercaladas) es la palanca de la DISPERSIÓN.** El estadístico es
  el mínimo sobre `r` series; su sesgo y su cola bajan con `r`.

| id | `k` | `r` | invocaciones del hook por razón (`2·k·r`) | repeticiones `M` | invocaciones totales | qué responde |
|----|-----|-----|------|----|-------|---|
| **V0** | 4 | 6 | 48 | **12** | 576 | el ajuste **de la puerta hoy**: su dispersión real en el runner y si el suelo dispara |
| **V1** | 8 | 15 | 240 | **10** | 2 400 | primer punto de la ley de escala, ya fuera del suelo |
| **V2** | 8 | 30 | 480 | **8** | 3 840 | el ajuste **de acreditación** que ya existe (`ARNES_COSTE_RUTA_CRITICA=1`) |
| **V3** | 8 | 60 | 960 | **4** | 3 840 | el punto **lejano** (20× el coste de V0): comprueba si la ley sigue valiendo o se aplana |
| | | | | | **10 656** | |

**Por qué esas `M`, y no otras.** El estadístico que decide es el **peor recorrido de una
ventana de 4**, porque el criterio mira 4 razones. Con `M = 12` hay 9 ventanas; con `M = 8`,
5; con `M = 4`, **una sola**. Las `M` bajan al subir el coste porque el presupuesto de CI es
finito, y se reparten de modo que los dos ajustes que pueden ganar —`V1` y `V2`, los únicos
que caben en el presupuesto de coste del §4— se llevan las muestras grandes. **`V3` con
`M = 4` da una sola ventana y eso se dice aquí, antes de verla:** `V3` sirve para la **ley de
escala y el coste**, no para decidir por sí solo.

**Orden: INTERCALADO, no por bloques.** Se recorren 12 rondas y en cada ronda se ejecuta una
repetición de cada ajuste que «toque» según un reparto uniforme
(`⌊n·M/12⌋ > ⌊(n−1)·M/12⌋`). Motivo: en el banco la contención **baja con el tiempo** —las
otras 64 secciones van terminando—, así que ejecutar todo `V0` primero y todo `V3` después
mediría ajustes distintos bajo **cargas distintas** y confundiría las dos cosas. Intercalar
reparte esa deriva por igual entre los cuatro.

**La nula, cómo se construye.** Dos copias `cp -a` **independientes** del mismo origen
(`hooks/` y `tools/` del árbol candidato) en **dos directorios distintos** del temporal de
la sección. Dos directorios y no uno: si el efecto fuera de ruta, de inodo o de caché de
página, un brazo contra sí mismo no lo vería. Es la misma construcción de las nulas `AA`/`BB`
de la vuelta 3 (`00-metodo-y-plan.md`), y por eso las cifras son comparables con ellas.

**El sujeto es el FIEL.** El mismo que mide el caso real: `CLAUDE_PROJECT_DIR` apuntando al
proyecto **vacío** que `seccion_nueva` exporta, con el `file_path` en un proyecto con el
corpus de REQ — exactamente la construcción de `40/7:97-110`, incluida la adenda de la
vuelta 3 que descubrió que el sujeto de las fases 1 y 2 **no** era el del banco.

---

## 3. El tope de reloj, fijado antes

- **Presupuesto duro de la sonda: 420 s (7 min).** Al agotarse, la sonda **para** y publica
  lo que llevara, con una línea que lo dice. Motivo: `timeout-minutes: 20` y el banco tarda
  hoy ≈ 2 min; 2 + 7 = 9 min deja **11 min de margen** ante un runner más lento de lo
  estimado. Un experimento que tumba la puerta por agotar el `timeout` no devuelve ningún
  dato.
- **Coste estimado de las 10 656 invocaciones:** entre **266 s** (a 25 ms/invocación, que es
  lo medido en mi host: 4,8 s / 192 invocaciones en `40/7`) y **426 s** (a 40 ms, cota alta
  para 4 vCPU contendidas). El presupuesto de 420 s cubre el caso central y recorta el
  extremo pesimista **publicando lo que dio tiempo a medir**, que sigue siendo respuesta.

---

## 4. EL CRITERIO DE VIABILIDAD — escrito antes de ver un solo número

Un ajuste `S` se declara **viable** si y sólo si cumple **las tres** condiciones:

| # | condición | cifra | por qué esa cifra |
|---|---|---|---|
| **C1** | **detección** | `ε_mín ≥ 977‰` en **toda** ventana de 4 consecutivas de la nula | es la desigualdad del §1: por debajo, una regresión verdadera de 1,28× produce al menos una razón bajo el techo y la unanimidad la convierte en `SKIP` |
| **C2** | **no cazar todo** | `ε_máx ≤ 1118‰` en **toda** la muestra | por encima, un candidato **correcto** (ρ₀ = 1,118×) deja de poder salir `PASS` y la puerta abstiene siempre |
| **C3** | **coste** | el ajuste añade **≤ 60 s** al tiempo de sección en el runner respecto de `k=4 r=6` | ver abajo |

Y una **condición de admisibilidad** previa, que no es de precisión sino de que el
instrumento **pueda medir**:

| **C0** | **mide** | **0** repeticiones con `estado ≠ ok` de las `M` | el caso convierte **una sola** repetición no medida en `SKIP` del conjunto (`40/7:150-153`): la unanimidad no perdona ninguna |

> **C0 es necesaria y su potencia estadística es baja, y se dice aquí y no después.** Observar
> 0 fallos en `M = 12` es compatible con una tasa verdadera de hasta ~22 % al 95 %. O sea:
> **C0 cumplida no demuestra que el suelo no dispare nunca**; C0 **incumplida** sí demuestra
> que dispara. Es una prueba de un solo lado y así se usará.

### Por qué 60 s, y no otro número

El banco es la puerta **requerida de cada PR** y tarda hoy ≈ 2 min. `+60 s` es **+50 %** de
esa puerta: la deja por debajo de 3 min y muy dentro del `timeout` de 20. Traducido a
invocaciones, con `c` = coste de una invocación del hook en el runner (que **la sonda mide**,
no se supone) y `KRAZ = 4`:

| ajuste | invocaciones por veredicto (`4·2·k·r`) | Δ sobre `k=4 r=6` | cabe en +60 s si… |
|---|---|---|---|
| `k=4 r=6` | 192 | — | — |
| `k=8 r=15` | 960 | +768 | `c ≤ 78 ms` |
| `k=8 r=30` | 1 920 | +1 728 | `c ≤ 34,7 ms` |
| `k=8 r=60` | 3 840 | +3 648 | `c ≤ 16,4 ms` |

**El presupuesto cae justo entre `V2` y `V3`,** y no por casualidad: el barrido está elegido
para **horquillar la línea de decisión**, no para quedar todo del lado cómodo. `c` sale del
campo `us` del registro de la sonda, así que el lado del coste es **medido**.

### El veredicto de la fase 1, con sus tres salidas — decididas antes

1. **VIABLE** — existe un ajuste medido que cumple C0+C1+C2 y cuyo Δ de coste cumple C3.
   → se pide autorización para la fase 2 **con ese ajuste**, el más barato de los que cumplan.
2. **NO VIABLE** — ninguno de los ajustes medidos cumple C0+C1+C2 dentro de C3, y la ley de
   escala ajustada sobre los cuatro puntos sitúa el ajuste necesario **fuera** del
   presupuesto. → **me detengo** y presento **evidencia y alternativas con sus
   consecuencias**, sin recomendación suelta y sin otra vuelta de tanteo de parámetros
   (instrucción literal del propietario).
3. **NO MIDE** — la sonda no pudo tomar la muestra (todo `estado ≠ ok`, presupuesto agotado
   antes del primer punto útil, la sección no llegó a correr). → **no es «viable»**; es la
   tercera respuesta y se informa como tal. Si la causa es un **defecto mecánico de la sonda**
   (no compila, no emite, revienta el cuadre), eso se arregla y se vuelve a correr: **arreglar
   un instrumento roto no es relanzar buscando un número mejor**, y la distinción se declara
   aquí para que no la invente yo después.

### Lo que NO se relanza

**Una sola corrida de CI.** Si los números no gustan, **son la respuesta**. No se repite el
experimento con otras `M`, otros `(k, r)` ni otro momento del día buscando una lectura
favorable (`memoria variabilidad-no-desmiente-un-fail`: un resultado no queda desmentido por
repetir hasta obtener verde).

### Alternativas que se presentarán si sale NO VIABLE — enumeradas ANTES

Se escriben aquí para que no parezcan inventadas a conveniencia después del resultado. Se
presentarán **con sus consecuencias** y **sin recomendación suelta**, y **ninguna** de ellas
es «subir el techo» ni «`continue-on-error`», que el propietario excluyó:

- **(A)** Sacar la decisión de reloj de la puerta **de cada PR** y acreditarla en una puerta
  **de fusión** o **de versión**, donde `k` y `r` grandes sí caben. *Consecuencia:* deja de
  vigilarse en cada PR; hay que decir **quién** la corre y **cuándo bloquea**.
- **(B)** Cambiar el **sujeto** para que su coste absoluto suba (medir un lote de N entradas
  en vez de una), de modo que el mismo ruido relativo cueste menos reloj. *Consecuencia:*
  cambia lo que el criterio mide y obliga a re-derivar el techo.
- **(C)** Cambiar el **estadístico** (p. ej. una cota sobre un cuantil del intercalado en vez
  del mínimo de cada brazo). *Consecuencia:* es instrumento nuevo, y entra por su propio REQ
  con sus demostraciones; no es una reparación.
- **(D)** Declarar `CA-07 (ii)` **no acreditante en la puerta requerida** con dueño,
  vencimiento y la cota de abstención de `QA-024-20`. *Consecuencia:* es **documentar un
  residuo**, y documentar no remedia — el propietario ya rechazó esa salida; entra en la
  lista sólo para que la comparación sea completa y **con esa etiqueta puesta**.

---

## 5. La sonda: qué es, dónde vive y por qué no toca el cuadre

**Archivo:** `tests/escenarios/hooks/secciones/40-ausencia-que-abre-8-sonda-de-viabilidad.sh`
(sección nueva, **temporal**).

**Por qué viaja dentro del banco y no por un `workflow_dispatch`:**
`.github/workflows/banco.yml` sólo se dispara por `push` a `main` y por `pull_request`, **no
tiene `workflow_dispatch`**, y `.github/` es gate humano (`AGENTS.md` §4): no se toca. Luego
la única vía de ejecutar algo en el runner es que **viaje dentro de una corrida normal del
PR**.

**Por qué una sección nueva y no un añadido a `40/7`:** `40/7` es el artefacto que QA acaba
de validar; tocarlo obligaría a re-verificar sus 5 casos y su cuadre. Una sección aparte se
**borra con un `rm`** cuando la fase 1 termine, sin tocar nada más.

### No altera el cuadre — comprobado contra `run.sh`, no supuesto

| mecanismo | dónde | por qué no le afecta |
|---|---|---|
| recuento de casos | `run.sh:1216-1220`, `awk` con `/^  PASS /`, `/^  FAIL /`, `/^  SKIP /` | la sonda emite **`  VIAB  …`** y **`  VIAB-RESUMEN  …`**: no casan ninguno de los tres patrones (dos espacios + palabra + espacio) |
| cuadre por archivo | `run.sh:1287-1295` | declara **`CASOS_ESPERADOS_SECCION=0`** y ejecuta 0 casos: `0 = 0` |
| cuadre total | `run.sh` `CASOS_ESPERADOS` | **sigue en 1094**: la sección no añade ni quita casos |
| «la sección no dejó ni una línea» | `run.sh:1241-1243` | `seccion_nueva "<título>"` imprime el título, así que `out-i` nunca sale vacío |
| invariante 1 (quien juzga un hook, se guarda) | `run.sh:996-1051` | la sonda **no dicta veredicto**: ninguna función suya contiene `  PASS  ` ni `  FAIL  ` |
| «no hay segunda sede de un instrumento» | `run.sh:1069-1086` | **invoca** `tests/util/sonda-reloj.sh`; no cronometra ni cuenta procesos por su cuenta |
| CA-18 (piso y techo) | `autoprueba-corredor.sh:540-548` | declara `PISO_AUTONOMO_SECCION` con sus tres términos sumando, y el archivo cabe holgado bajo `máx(400, piso × 1,25)` |
| bit de ejecución | `banco.yml:57-60` | el archivo va **100644**, como toda sección |

### Qué emite, literalmente

Una línea por repetición con **el registro íntegro de la sonda** —que ya trae `estado`,
`motivo`, `carga` (loadavg), `jobs`, `plataforma`, `k`, `r`, `us`, y los `min`/`min2` de los
dos brazos—, más la razón calculada en milésimas. Y una línea de resumen por ajuste con las
razones, el recorrido, el **peor recorrido de ventana 4** y el reloj consumido.

**Se publica el registro crudo a propósito:** así cualquiera re-deriva todas las cifras del
informe sin volver a correr nada, que es la condición de entrega de `AGENTS.md` §14.B.7.

---

## 6. Qué espero ver (hipótesis, NO compromiso — `AGENTS.md` §14.B.1 y §14.B.2)

Se escribe **antes** para que el resultado pueda desmentirme, no para acertar:

1. **`V0` (`k=4 r=6`) no cumplirá C1.** En mi host la nula recorre 1,115×–1,386× a esos
   mandos; el runner es más pequeño y está sobresuscrito. **Hipótesis**, no dato.
2. **`V0` puede además incumplir C0** por el suelo de 50 ms (`QA-024-23`), o no: depende de
   si el runner es más rápido o más lento que mi host por invocación. **No lo sé y no lo voy
   a suponer.**
3. **`V2` (`k=8 r=30`) es el candidato con más opciones** —en mi host, en reposo, la nula
   colapsó a 0,984×–1,005×, recorrido **1,021×**, que está **justo en el filo** del 1,024×
   que C1 exige—. En un runner de 4 vCPU contendido espero que **no llegue**.
4. En conjunto, **mi expectativa es NO VIABLE**. Y por eso mismo el criterio está escrito
   antes: si los números me desmienten, mandan ellos.

---

## 7. Resultados

### 7.0 Lo que se ejecutó aquí, y por qué no es la respuesta

Tres corridas, **todas conservadas**, en `corridas/vuelta4-fase1/`:

| corrida | qué es | archivo | resultado |
|---|---|---|---|
| **humo** | barrido **REDUCIDO** (`r=2`, 2 ajustes) sobre un directorio de secciones sintético | — (en el borrador; **no es dato experimental**: `r=2` no es ninguno de los ajustes fijados) | destapó un defecto **mecánico** y se corrigió: `VIAB_REPO` derivaba de `$SEC_DIR` y apuntaba fuera del repositorio con `ARNES_SECCIONES_DIR`; pasa a derivar de `$HOOKS_DIR`, que es el árbol que el brazo «este» del caso real mide |
| **banco entero con la sonda** | el barrido **completo y fijado**, dentro del banco | `local-barrido-completo.txt` (40 líneas: 1 contexto + 34 repeticiones + 5 resúmenes), `local-cuadre-con-sonda.txt` | `1087 PASS · 0 FAIL · 7 SKIP = 1094`, **0 ABORT**, rc 0, 3 min 34 s |
| **banco entero de control** | lo mismo con `ARNES_SONDA_VIABILIDAD=0` | `local-cuadre-control-sonda-apagada.txt` | `1086 PASS · 0 FAIL · 8 SKIP = 1094`, **0 ABORT**, rc 0, 1 min 08 s |

Y la autoprueba del corredor: **106 PASS · 0 FAIL**, con la fila de CA-18 de la sección nueva
(`local-ca18-fila.txt`): `lineas= 183 piso= 183 techo= 400 (gobierna N)`.

**El cuadre no se movió, medido en las dos direcciones:** 1094 con la sonda encendida y 1094
con ella apagada.

**Lo que la comparación con el control dice sobre el coste ajeno, sin adornarlo:** el `SKIP`
número 8 del control es un `REQ-023 CA-09 (iii)` que **con** la sonda salió `PASS`. O sea que
la diferencia va **en contra** de la hipótesis «la sonda contamina el reloj de las demás
secciones»; **no la descarta** —dos corridas no establecen nada sobre un criterio del que ya
está medido que no discrimina—, pero no hay ningún indicio de que la sonda enrojezca ni
abstenga nada ajeno. **Ningún `FAIL` en ninguna de las dos.**

### 7.1 Contraste local (NO es la respuesta, y se dice antes de la tabla)

Host: **WSL2, 12 núcleos**, bajo la contención del propio banco. El runner tiene **4 vCPU con
`ARNES_JOBS=6`**. Está medido en este repositorio que **no predicen lo mismo**, así que esto
es un **contraste** y el criterio del §4 **no se aplica aquí para decidir nada**.

| ajuste | razones (‰) | `mín` = **estadístico de C1** | `máx` | peor ventana 4 | µs/invocación | Δ coste por veredicto vs `k=4 r=6` |
|---|---|---|---|---|---|---|
| **V0** `k=4 r=6` | 968 1022 1009 1021 1059 990 1019 1023 1029 1054 1011 **935** | **935** | 1059 | 1127 | 17 017 | — |
| **V1** `k=8 r=15` | 1010 1024 **981** 995 981 984 985 989 1011 1012 | **981** | 1024 | 1043 | 17 169 | 768 inv ≈ **13,2 s** |
| **V2** `k=8 r=30` | 997 1007 **993** 1037 1019 1040 1000 1001 | **993** | 1040 | 1047 | 16 484 | 1 728 inv ≈ **28,5 s** |
| **V3** `k=8 r=60` | 1014 **1001** 1018 1010 | **1001** | 1018 | 1016 | 15 083 | 3 648 inv ≈ **55,1 s** |

`sin_razon = 0` en los cuatro (**C0 cumplida localmente**): en este host el suelo de 50 ms
**no** disparó ni con `k=4`. Barrido completo en **172,5 s**, sin agotar el presupuesto.

**Leído con el criterio del §4 —insisto: como contraste—:** `V0` **incumple C1** (935 < 977),
y `V1`, `V2` y `V3` la cumplen, con márgenes de **4‰**, **16‰** y **24‰**. Las tres cumplen
C2 y C3.

**Esto debilita mi propia hipótesis del §6 y lo digo yo, no lo descubre el que lee.** Yo
esperaba `NO VIABLE` incluso en `V2`; aquí `V1` ya cumple. Dos observaciones que impiden
convertir esto en un adelanto del resultado:

1. **El margen de `V1` es de 4 milésimas sobre 981.** Es **0,4 %**: lo consume cualquier cosa.
   Una muestra de 10 no resuelve una cola de 0,4 %.
2. **Este host tiene 12 núcleos y el runner 4, sobresuscritos a 6.** La dirección del cambio
   es conocida y desfavorable; la magnitud, no.

### 7.2 Nota sobre el truncamiento — **escrita antes de ver el runner**

El barrido tardó 172,5 s en 12 núcleos. En 4 vCPU sobresuscritas puede acercarse o superar el
tope de **420 s**, y entonces el barrido **para y publica lo medido** (por diseño, §3). El
intercalado hace que el recorte se reparta entre los cuatro ajustes en vez de borrar el
último, pero hay una consecuencia que **agranda el resultado en la dirección cómoda** y por
eso se declara ahora:

> **Una muestra truncada hace C1 MÁS FÁCIL de cumplir**, porque C1 mira el **mínimo** y menos
> repeticiones es menos oportunidad de ver la cola baja. Luego un «cumple C1» sobre una
> muestra recortada **vale menos** que el mismo número sobre la muestra completa, y así se
> informará: con las repeticiones **hechas** al lado de las **pedidas** (la línea
> `VIAB-RESUMEN` publica las dos). Esto **no afloja** el criterio: lo endurece.

### 7.3 El runner — **la respuesta**

**Corrida:** `hooks-en-linux` sobre **`1b3760e`**, `success`, 15:13:42→15:17:18Z (3 min 36 s).
Cuadre **1080 PASS · 0 FAIL · 14 SKIP = 1094**: la sonda no lo alteró, como estaba comprobado.
Contexto: **`nucleos=4`**, `jobs=6`, **`carga_al_empezar=5.04`** — 4 vCPU con carga 5, o sea el
runner llegó sobresuscrito, que es exactamente la condición que se quería medir. Salida
literal, 40 líneas: `corridas/vuelta4-fase1/RUNNER-1b3760e-salida-literal.txt`.

**`hechas = pedidas` en los cuatro y `presupuesto_agotado=no`**: la muestra **no** se recortó,
así que la advertencia del §7.2 **no aplica** y el resultado se lee a cara descubierta.

| ajuste | razones (‰) | `mín` (**C1** ≥ 977) | `máx` (**C2** ≤ 1118) | `sin_razón` (**C0** = 0) | peor ventana 4 | coste por veredicto (`×4`) | Δ vs `k=4 r=6` (**C3** ≤ 60 s) |
|---|---|---|---|---|---|---|---|
| **V0** `k=4 r=6` | 805 1123 988 994 991 1003 1000 997 1000 1000 1003 1003 | **805** ✗ | **1123** ✗ | 0 ✓ | 1395 | 3,58 s | — |
| **V1** `k=8 r=15` | 1018 1002 997 1000 999 998 999 1001 999 1002 | **997** ✓ (+20‰) | **1018** ✓ | 0 ✓ | 1021 | 14,77 s | **+11,2 s** ✓ |
| **V2** `k=8 r=30` | 1000 1000 1005 999 1002 1003 994 998 | **994** ✓ (+17‰) | **1005** ✓ | 0 ✓ | 1009 | 28,13 s | **+24,6 s** ✓ |
| **V3** `k=8 r=60` | 1001 999 1009 1004 | **999** ✓ (+22‰) | **1009** ✓ | 0 ✓ | 1010 | 52,93 s | **+49,4 s** ✓ |

*Método de las dos últimas columnas:* coste por veredicto `= (us_total / hechas) × KRAZ(4)`; Δ
contra el mismo cálculo sobre `V0`. **Y va la horquilla, no el número cómodo:** los 3,58 s de
`V0` están inflados por sus dos primeras repeticiones (1,80 s y 1,92 s bajo carga 5,04); con el
coste de sus repeticiones tardías (≈ 0,67 s ⇒ 2,68 s por veredicto) los Δ salen **+12,1 s**,
**+25,5 s** y **+50,3 s**. **Los tres siguen bajo 60 s con cualquiera de las dos bases**, así
que C3 no depende de cuál se elija.

## ▶ VEREDICTO DE LA FASE 1: **VIABLE**

- **`V0` (`k=4 r=6`, el ajuste de la puerta HOY) incumple C1 y C2** — `mín 805` contra 977, y
  `máx 1123` contra 1118. **Eso es `QA-024-21` medido en el runner:** con el instrumento
  recorriendo `[0,805× , 1,123×]` sobre una razón verdadera de **1,000× por construcción**, una
  regresión de 1,28× cae dentro del ruido y sale `SKIP`. No es conjetura: es la misma corrida.
- **`V1`, `V2` y `V3` cumplen C0, C1, C2 y C3.**
- Por la regla escrita en el §4 —«el **más barato** de los que cumplan»— el ajuste es **`V1`:
  `k=8`, `r=15`**, con **Δ ≈ +11,2 s** por veredicto.

**Y el resultado refuta mi hipótesis registrada.** En el §6 escribí «mi expectativa es **NO
VIABLE**», y esperaba que ni `V2` llegara en 4 vCPU sobresuscritas. El runner dice que `V2`
llega con holgura y que **`V1` ya llega**. Lo digo yo y no lo descubre quien lea: una hipótesis
registrada y **refutada** vale más que una acertada, porque es la que demuestra que el criterio
no se escribió para confirmarla.

### Por qué me equivoqué — y es un hecho NUEVO sobre el instrumento

Miré la máquina (4 vCPU contra 12) y no miré **dónde** cae la medición dentro de la corrida. El
registro crudo lo dice sin que haya que inferir nada:

| repetición de `V0` | carga | `disp` | `acompanada` | razón | `min_a` |
|---|---|---|---|---|---|
| n=1 | 5,04 | **1838** | **sí** | **805** | 98 763 µs |
| n=2 | 5,04 | **1389** | **sí** | **1123** | 126 163 µs |
| n=3 | 5,05 | 1044 | no | 988 | 75 987 µs |
| n=4 … n=12 | 4,14 → 1,76 | ≤ 1144 | no | **991 … 1003** | ≈ 54 000 µs |

**`V0` sólo descarrila en sus dos primeras repeticiones, y las dos son justo las que la sonda
marcó `acompanada=si`.** De la tercera en adelante recorre `[0,988× , 1,003×]` — **más
estrecho que `V2`**. La dispersión de `V0` **no es una propiedad de `k=4`**: es una propiedad
de **medir mientras las otras 64 secciones todavía corren**.

Dos consecuencias, las dos operativas:

1. **`k=8` ya absorbe esa contención.** La primera repetición de `V1` se tomó con la **misma**
   carga 5,04 y dio **1018**, no 805. Duplicar `k` alarga la serie de ~54 ms a ~110 ms y saca
   la medida del régimen en que manda el planificador.
2. **Hay una señal publicada que las marca… y NO sirve como discriminante. Lo comprobé y me
   desmiente, así que va escrito y no se calla.** `sonda-reloj.sh` publica `disp` y
   `acompanada` (CA-06 punto 2, umbral 1250‰), y las dos repeticiones malas de `V0` vienen
   marcadas `acompanada=si`. La conclusión fácil —«que la guarda descarte las repeticiones
   marcadas»— es **falsa**, y lo dice la misma corrida: `V1 n=1` trae `disp=2316
   acompanada=si` y su razón es **1018**, buena; `V1 n=2` trae `disp=1450 acompanada=si` y da
   **1002**; en el contraste local `V2 n=7` trae `acompanada=si` y da **994**. `acompanada`
   dice «alguna serie salió lenta», y con `k=8` **el mínimo no se contamina por eso**:
   descartar por esa marca tiraría mediciones buenas y pagaría reintentos por nada. **La
   palanca que sí está medida es `k`**, y es la que mueve la fase 2. Queda anotado como
   observación con su refutación para que nadie la redescubra y la implemente.

### El coste que la sonda le cobró a la puerta

Barrido **157,1 s** de los 216 s de la corrida. `timeout` de 20 min ⇒ **holgura 16,4 min**. El
presupuesto de 420 s **no se agotó**.

### Lo que este resultado NO acredita — antes de que alguien lo dé por dicho

- **Es una corrida.** Los márgenes de C1 son de 17–22 milésimas sobre 10, 8 y 4 muestras. Que
  ninguna cayera bajo 977 **no demuestra** que la cola no exista. Lo que lo hace creíble no es
  el conteo: es el **mecanismo** identificado arriba (la cola de `V0` viene marcada
  `acompanada=si`, y `k=8` la suprime).
- **La nula no es el candidato.** Mide `ε`; que ese `ε` sea el que actúa sobre un árbol
  **regresado** es el supuesto declarado en el §1, y la fase 2 **tiene que confirmarlo con una
  regresión real inyectada**, no darlo por bueno.

### La incertidumbre del método, declarada como pidió el propietario

Con `ε ∈ [0,997 , 1,018]` medido en el runner a `V1`, la zona en que el método **puede no
decidir** alrededor del techo es

> `ρ ∈ [T/ε_máx , T/ε_mín] = [1250/1018 , 1250/997] = [1,228× , 1,254×]`.

Por debajo de **1,228×** resuelve del lado `PASS`; por encima de **1,254×** resuelve del lado
`FAIL`; dentro, puede abstenerse. **`1,28×` queda fuera de la zona de indecisión**, y `1,25×`
—la frontera exacta— queda dentro, que es justo la precisión infinita que el propietario no
exige. La zona es **declarada y acotada**, y no se presenta como cumplimiento nada que caiga
dentro de ella.

---

## 8. Archivos tocados en la fase 1

| archivo | qué |
|---|---|
| `tests/escenarios/hooks/secciones/40-ausencia-que-abre-8-sonda-de-viabilidad.sh` | **nuevo, TEMPORAL**: la sonda. 183 líneas, `CASOS_ESPERADOS_SECCION=0`, modo 100644 |
| `tests/escenarios/hooks/run.sh` | **sólo comentario**: por qué `CASOS_ESPERADOS` sigue en 1094 con una sección más, y que la sección es temporal |
| `docs/arnes/req-024-ca-07-ii-reparacion/03-…` (este archivo) y `04-…` | la pre-registración y el insumo del write-back de `QA-024-20` |
| `docs/arnes/req-024-ca-07-ii-reparacion/corridas/vuelta4-fase1/` | las corridas locales, **todas** |

**No se tocó:** `hooks/`, `tools/`, `tests/util/`, `.github/`, `.arnes/config.json`,
`.claude-plugin/`, `requirements/`, ni `40/7` (el artefacto que QA validó), ni el techo
`1,250×`, ni ningún otro criterio de reloj.

## 9. Entrada de `CHANGELOG.md` lista para pegar (NO se escribió: la comisión reserva el commit)

```markdown
### [2026-09-11] — REQ-024 CA-07 (ii), vuelta 4 fase 1: una pregunta de viabilidad que sólo el runner puede responder
- **Origen:** GitHub · **Usuario:** juan.vega@sysvega.cr · **Modelo IA:** Claude Opus 5
- **Agente(s):** `desarrollador`
- **Detalle:** `QA-024-21` midió una banda ciega: una regresión REAL de 1,28× salió
  `SKIP·SKIP·SKIP·FAIL·SKIP` con rc 0 en 4 de 5 corridas, y el propio código deriva su suelo
  de detección en 1,733× (`FACTOR07`), en un comentario y en ningún criterio. Antes de ampliar
  la reparación se comprueba de forma acotada si la precisión necesaria es viable EN EL CI
  REAL, porque está medido que este host y el runner no predicen lo mismo. Se añade una sonda
  de viabilidad TEMPORAL (`40/8`) que mide la distribución NULA a cuatro ajustes `(k, r)` y
  publica su dispersión y su coste; **no dicta veredicto**, declara 0 casos y no mueve el
  cuadre (1094 con la sonda y 1094 sin ella, medido en las dos direcciones). Viaja dentro del
  banco porque `banco.yml` no tiene `workflow_dispatch` y `.github/` es gate humano. Las
  condiciones, las repeticiones y el CRITERIO DE VIABILIDAD con su cifra (`ε_mín ≥ 977‰`,
  derivada de `1250/1280`) quedan fijados por escrito ANTES de ejecutar. El techo 1,250× queda
  INTACTO y no hay `continue-on-error`. Evidencia:
  `docs/arnes/req-024-ca-07-ii-reparacion/03-fase-1-viabilidad-en-el-runner.md`.
  Banco: 1094 casos, 0 FAIL, 0 ABORT. Autoprueba: 106 PASS, 0 FAIL.
```
