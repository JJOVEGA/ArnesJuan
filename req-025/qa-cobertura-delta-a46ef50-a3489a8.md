# QA — comprobación acotada: ¿cubre `QA: aprobado (R-4)` el delta `a46ef50..a3489a8`?

**Comisión acotada** por instrucción del propietario (2026-09-22). **Sólo lectura** sobre
`/home/juan/dev/ArnesJuan-req025`; este informe vive **fuera de la cabeza del PR**, en la rama de
evidencia. **No se ha editado ningún archivo del worktree del PR** — ni `requirements/REQ-025.md`,
ni `docs/qa/`, ni `CHANGELOG.md`. Sin ensayos, sin comisiones, sin repetir la revisión completa.

| | |
|---|---|
| Firma en cuestión | `QA: aprobado (R-4, 2026-09-21, sobre `a46ef50`)` |
| Delta juzgado | `a46ef50..a3489a8` — 6 commits, 6 archivos, 803 inserciones |
| Fecha de esta comprobación | 2026-09-22 |
| Autor | `qa-tester` |

---

## 1. Respuesta, y la distinción que el propietario pidió que no se difumine

**«Cubrir» y «no alterar» no son lo mismo, y aquí sólo puedo emitir lo segundo.**

- **R-4 NO cubre el delta, y no podría:** se emitió el 2026-09-21 sobre `a46ef50`, y **cinco de los
  seis commits del delta no existían** cuando firmé. Atribuir cobertura a una firma sobre
  artefactos posteriores es exactamente lo que el propietario prohibió («no atribuyas cobertura
  que QA no haya emitido»). **Que quede escrito: mi R-4 no examinó nada de lo que viene después de
  `a46ef50`.**
- **Lo que sí puedo emitir hoy, y emito, es un pronunciamiento acotado:**

> ## **R-4b — el delta `a46ef50..a3489a8` NO altera nada de lo que R-4 acreditó.**
> **Ninguno de los seis commits toca el objeto de mi firma** —la entrega 1 construida— ni retira,
> debilita o resignifica ninguna de las condiciones que verifiqué. **R-4 sigue vigente sobre
> `a3489a8` sin necesidad de reemisión.** Emitido el 2026-09-22 por el `qa-tester`, acotado a este
> delta documental. **No** es una revalidación de la entrega ni una firma nueva sobre la cabeza.

**Criterio aplicado (`AGENTS.md` §9).** Un cambio de REQ **reabre** si es **de fondo** —cambia el
alcance, la decisión base o el significado—; un cambio **menor** que no toca lo validado, no.
Apliqué la prueba **criterio a criterio sobre lo que mi firma acreditaba**, no sobre el tamaño del
diff.

---

## 2. Lo que cambió, y por qué ninguna pieza altera R-4

**Evidencia común, comprobada primero:** el **mecanismo es byte a byte idéntico** entre las dos
cabezas — `git rev-parse <c>:{hooks,tools,tests}` da los mismos tres hashes en `a46ef50` y
`a3489a8` (`hooks=a6810ac6…`, `tools=87edb9b4…`, `tests=b4cbb114…`). Y
`git diff --name-only a46ef50 a3489a8 -- AGENTS.md templates/ agents/ skills/ hooks tools tests
.arnes .github .claude-plugin docs/decisions` devuelve **0 archivos**. **La sede, la gemela, los
agentes, las skills y el ADR no se han tocado desde que los validé.**

| Commit | Qué toca | ¿Altera R-4? |
|---|---|---|
| `5c30281` | Mi propio R-4 (`docs/qa/REQ-025.md`, cabecera) | **No** — es mi firma |
| `51a4430` | `Seguridad: con-hallazgos` (R-041); `Hallazgos abiertos:` +SEC-102 +SEC-103 | **No** — campo del auditor; mi R-4 dejó escrito que él venía después y levantaría lo que levantara |
| `a1e4f72` | `docs/ESTADO.md`, `CHANGELOG.md` | **No** — artefactos de continuidad |
| `1932492` | `Archivos:` 13→15; CA-11 pt 3 (dos confirmaciones); 2 filas de Historial | **No** — §3 y §4 |
| `4b1a86e` | `Seguridad: aprobado` (R-041-A); `Hallazgos abiertos:` −SEC-102 +SEC-104 | **No** — campo del auditor |
| `a3489a8` | `PENDING_APPROVAL.md` (entrada bajo `## Resueltas`), ESTADO, CHANGELOG | **No** — §5 |

---

## 3. `Archivos:` corregido — coincide con SEC-102 y no añade ni quita otra ruta

**Comprobado por conjuntos, no leyendo el diff.** `requirements/REQ-025.md`, **línea 4**:

```
a46ef50    n=13 rutas
a3489a8    n=15 rutas
diff de los dos conjuntos ordenados:
  > requirements/README.md
  > requirements/REQ-028.md
```

- **Se añaden exactamente dos**, las dos que SEC-102 nombra. ✓
- **No se quita ninguna** y **no se añade ninguna otra**: el `diff` de conjuntos no tiene una sola
  línea `<`. ✓
- **Sin decoración de Markdown**, como exige SEC-020: los únicos `*` y `_` de la línea pertenecen a
  nombres reales (`PENDING_APPROVAL.md`, `templates/PENDING_APPROVAL.md.tpl`) y a globs legítimos
  (`docs/decisions/*.md`, `docs/arnes/*.md`). **Ningún par de marcadores.** ✓

**Por qué no altera R-4.** `Archivos:` es el **mapa de colisión** del despacho, no un criterio de
aceptación de la entrega. Mi firma acreditó CA-09, CA-10, CA-13, CA-14, CA-15 y CA-11 puntos 3 y 5;
**`Archivos:` no está entre ellos**. Y la corrección va en la dirección que **hace más verdadero**
el campo: declaraba **de menos**, que es el error caro —produce un `disjunto` falso—. Corregir una
declaración incompleta no puede invalidar una firma que no dependía de ella. **Cambio menor
(§9).**

---

## 4. El residual de CA-11 punto 3 — lo que importaba de verdad, porque ahí sí soy la dueña

Es la única pieza del delta que toca algo que R-4 acreditó. La revisé línea a línea contra el
`git diff a46ef50..a3489a8 -- requirements/REQ-025.md`.

| Elemento del residual | Estado tras el delta |
|---|---|
| «**S4 ante un hallazgo de QA: no observado**» | **Conservado, sin tocar.** El diff no modifica esa frase, y la decisión añadida la repite: «**S4 sigue "no observado"**» |
| **Dueño: `qa-tester`** | **Sin cambio** |
| **Forzador** (primer hallazgo de QA que llegue a la regla 3; anotar sí/no con cita en `docs/qa/REQ-025.md`) | **Sin cambio** — el párrafo del forzador no aparece modificado en el diff |
| **Fecha 2026-10-21** | **Misma fecha.** Pasa de «propuesta de la coordinadora, y el propietario puede cambiarla» a «**confirmada** el 2026-09-21… cambiarla vuelve a exigir una decisión suya» |
| Consecuencia («si el caso no aparece antes, se revisa la aceptación y no se da por acreditado») | **Intacta**, textual |

**Nada se retira, nada se debilita.** Las dos confirmaciones **refuerzan**: una fecha confirmada
obliga más que una propuesta, y una obligación aceptada por el propietario obliga más que una que
un write-back añadió por su cuenta.

### ¿Acepto la aceptación tal como está escrita, siendo yo la dueña? **Sí.**

OBS-I fue **mía**: en R-4 señalé que el write-back imponía a un tercero una obligación que **el
propietario no había escrito**, y la dejé **«a confirmar por él junto con la fecha»**. Ha ocurrido
exactamente eso, en la forma que pedí. Y la confirmación literal —«**Acepto que la coordinadora
señale el primer caso aplicable; QA conserva la responsabilidad de verificarlo**»— **preserva mi
titularidad en su segunda mitad**, que es lo único que me importaba: señalar no mueve al dueño ni
la verificación.

**Y sigue siendo observable por mí, que es lo que comprobé en R-4 y no ha cambiado:** la
observación se **deriva de artefactos en disco** —`Hallazgos abiertos:`, `Estado:`, `QA:` y
`docs/qa/<REQ>.md`—, así que la señal de la coordinadora aporta **puntualidad, no posibilidad**.
Si algún día falla en señalar, **el forzador sigue siendo mío y sigue siendo verificable**.

**OBS-I queda resuelta.** No por el write-back, sino por la decisión del propietario que el
write-back transcribe.

---

## 5. `Hallazgos abiertos:` — **corrijo el resumen que recibí**

Trazado en las **siete** cabezas, línea 11 de `requirements/REQ-025.md`:

| Cabeza | `Hallazgos abiertos:` |
|---|---|
| `a46ef50` | QA-025-08 |
| `5c30281` | QA-025-08 |
| `51a4430` | QA-025-08, **SEC-102 (contrato)**, **SEC-103 (instrumento)** |
| `a1e4f72` | (igual) |
| `1932492` | (igual) — **el write-back del analista no tocó el campo**, como declara |
| `4b1a86e` | QA-025-08, SEC-103, **SEC-104** — sale SEC-102 |
| `a3489a8` | (igual) |

**El encargo dice que el campo «sólo cambió por SEC-102 → mitigado y SEC-104 nuevo». No es
exacto: falta SEC-103.** El cambio **neto** frente a `a46ef50` es **+SEC-103 y +SEC-104**;
SEC-102 entró en `51a4430` y salió en `4b1a86e`, dentro de la ventana.

**No es un defecto del árbol** —SEC-103 es OBS-H registrada por el auditor como `instrumento`,
abierta y sin aceptación, que es **literalmente lo que el propietario ordenó**— sino una
**imprecisión del resumen** que se me pidió verificar. La corrijo porque verificarla era el
encargo.

**Los tres abiertos son `instrumento`**, ninguno bloquea por su clase, y **ninguno es mío salvo
QA-025-08**. Mi firma no los acredita ni los niega: son del auditor.

---

## 6. Observación nueva, fuera del delta documental pero sobre mi propia acreditación: **OBS-J**

La marco como **fuera de alcance del delta** y la reporto igual, porque toca directamente lo que
R-4 afirmó sobre CA-13 y porque el registro visible hoy induce a error.

**Medido con `gh api`, no con `gh run list`:**

```
run 35668137505 · head a3489a8 · run_attempt: 2 · conclusion: success
                                  (updated 2026-09-22T14:23:31Z)
run 35668137505 · attempts/1     · conclusion: FAILURE
```

**Es decir: el CI sobre `a3489a8` FALLÓ en el primer intento y pasó en la repetición**, y la
conclusión a nivel de run muestra hoy **sólo `success`**. Quien consulte `gh run list` concluirá
que pasó a la primera, y eso es **falso**. *(El mensaje de `64848bb` —«CI ROJO de `a3489a8`»—
**es correcto**; lo engañoso es la vista actual.)*

**Lo que esto NO cambia, comprobado:** mi R-4 apoyó CA-13 en dos corridas que **sí** fueron
`run_attempt: 1` y `success` — `35646997951` sobre `9f908d9` y `35655684298` sobre `6640e5a`—, y
`35665158708` sobre `a1e4f72` también es attempt 1 en verde. **Tres verdes a la primera sobre
árboles de mecanismo byte a byte idénticos** al de `a3489a8`. Así que el fallo del intento 1 **no
es una regresión del mecanismo**: no hay mecanismo distinto que pudiera regresar.

**Lo que sí hay que decir, y no lo suavizo:** CA-13 exige «**no hay ningún FAIL**», y en el intento
1 lo hubo. **Un verde obtenido repitiendo no desmiente el rojo**; conserva la variabilidad como
evidencia y deja la decisión aparte — que es la regla que este repositorio ya se aplicó al publicar
`v1.33.0` («no se fusionó porque el semáforo se pusiera verde»). El caso que falló, según
`64848bb`, es **`REQ-017 CA-08 (ii)`, la sonda de coste**, cuya dispersión este repositorio ya tiene
documentada como cubriendo su propio techo —«su verde y su rojo son igual de poco informativos»—,
que es presumiblemente por qué la repetición se autorizó.

**Clase `instrumento`. Dueño: coordinadora.** **No la abro contra REQ-025** —no toca `hooks/` y no
es de esta entrega— y **no altera R-4b**. Lo que pido es sólo que **el rojo del intento 1 quede
escrito donde se lea**, porque dentro de un mes nadie va a mirar `attempts/1`.

---

## 7. Qué NO acredita este pronunciamiento

1. **No es una revalidación de la entrega 1.** R-4b dice **una sola cosa**: que este delta no
   altera lo acreditado. No he repetido ningún criterio, ni corrido el banco, ni vuelto a leer la
   sede.
2. **No acredita nada del auditor.** `Seguridad: aprobado` (R-041-A), SEC-102 `mitigado`, SEC-103 y
   SEC-104 son **suyos**; los he leído para verificar que no alteran mi firma, **no** para
   respaldarlos. En particular **no acredito que SEC-102 esté bien mitigado**: comprobé que el
   campo declara las dos rutas, no la suficiencia de esa mitigación, que es juicio del auditor.
3. **No acredita el CI sobre `a3489a8`**, y ahora menos: el único run tiene un intento fallido.
   CA-13 lo acredité sobre `9f908d9`/`6640e5a`, y ahí sigue.
4. **No convierte S4 en observado.** Sigue **no observado**, dos corridas. **QA-025-08 sigue
   abierto** en el campo, con su clase, su dueño, su forzador y su fecha.
5. **No acredita OBS-H / SEC-103**, que siguen **pendientes y sin aceptación**.
6. **No autoriza cerrar REQ-025.** **CA-15 punto 9**: aprobar la entrega 1 **no** completa el REQ —
   quedan la **entrega 1b** y **REQ-028**—, y **ninguna puerta comprueba esa cláusula**. Con las
   dos firmas puestas, `guard-completado` **ya no lo impide**: el único freno es que alguien lo
   sepa. Lo repito aquí porque el auditor ya lo advirtió y una advertencia que sólo vive en un
   sitio se pierde.
7. **No es aprobación de fusión ni de publicación**, que son gates humanos (`AGENTS.md` §6).
8. **No he verificado la cabeza real del worktree.** `a3489a8` es la del PR; el worktree está en
   **`64848bb`**, un commit local posterior sin push. Mi pronunciamiento es sobre `a46ef50..a3489a8`
   y **no alcanza a `64848bb`**.

---

## 8. Resumen para quien decide

| Pregunta del encargo | Respuesta |
|---|---|
| ¿R-4 cubre el delta? | **No, y no podría**: es posterior a la firma. Lo que emito es **R-4b**: el delta **no altera** lo acreditado |
| ¿Es cambio de fondo o menor (§9)? | **Menor**, pieza a pieza: `Archivos:` no era objeto de mi firma; el residual **se refuerza** sin retirar nada; el resto son campos del auditor y artefactos de continuidad |
| ¿`Archivos:` coincide con SEC-102? | **Sí**: +2 exactas, −0, sin decoración. 13→15 |
| ¿El residual conserva S4, dueño, forzador y fecha? | **Sí, los cuatro**; la fecha pasa de propuesta a **confirmada** |
| ¿Acepto la aceptación, como dueña? | **Sí.** «QA conserva la responsabilidad de verificarlo» preserva mi titularidad, y el forzador sigue siendo derivable del disco. **OBS-I resuelta** |
| ¿`Hallazgos abiertos:` cambió sólo por SEC-102 y SEC-104? | **No: también +SEC-103.** Corrijo el resumen recibido. Neto vs `a46ef50`: **+SEC-103, +SEC-104** |
| Nuevo | **OBS-J** (`instrumento`, dueño coordinadora): el CI de `a3489a8` **falló en el intento 1** y la vista actual sólo muestra el verde del intento 2 |

**Dos avisos operativos que no son hallazgos:** (a) el encargo dice que la cabeza está congelada
«mientras corre una repetición autorizada del CI» — **la repetición ya terminó** (intento 2,
`success`, 2026-09-22T14:23:31Z); (b) este informe vive **sólo** en la rama de evidencia, y el
propietario decide si algo de aquí —señaladamente **R-4b** y **OBS-J**— se transcribe al REQ. **Yo
no lo he transcrito.**

---

**Rutas citadas**

- `/home/juan/dev/ArnesJuan-req025/requirements/REQ-025.md` — **línea 4** (`Archivos:`),
  **línea 9** (`QA:`), **línea 10** (`Seguridad:`), **línea 11** (`Hallazgos abiertos:`);
  **CA-11 punto 3**, párrafo «Residual aceptado por el propietario (2026-09-21) — QA-025-08»;
  «Historial de cambios», dos filas nuevas al final.
- `/home/juan/dev/ArnesJuan-req025/PENDING_APPROVAL.md` — entrada nueva bajo `## Resueltas`
  (la cabecera normativa, líneas 1-35, **sin cambios**).
- `/home/juan/dev/ArnesJuan-req025/docs/qa/REQ-025.md` — §«R-4», §«Estado final» (OBS-I).
- `/home/juan/dev/ArnesJuan-req025/docs/seguridad/registro-seguridad.md` — §«Revisión R-041»,
  §«Adenda a R-041» (SEC-102, SEC-103, SEC-104).
- `/home/juan/dev/ArnesJuan-evidencia/req-025/qa-cobertura-delta-a46ef50-a3489a8.md` — **este
  informe**.
