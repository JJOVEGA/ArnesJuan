# ADR-012 — Las sondas de coste CA-03 y CA-08 (ii) deciden sobre un presupuesto fijo y pueden decir INCONCLUSO: se cambia el procedimiento, no los techos
Fecha: 2026-09-26
Estado: aceptada (decisión del propietario, `PENDING_APPROVAL.md` § Resueltas, entrada «REQ-030: se AUTORIZA implementar de forma acotada…»)
Supersede parcialmente: `requirements/REQ-017.md` CA-03 (procedimiento de medida y calibración) y CA-08 (ii) (procedimiento y cláusula de convergencia), en su redacción del 2026-09-07, que **se conserva**.

## Contexto

REQ-017 contrata dos sondas de coste que corren en la puerta requerida de `main` (`hooks-en-linux`):
**CA-03**, el cociente de duplicación del escáner (lineal ≈ 2, cuadrático ≈ 4, techo **2,6**), con un
caso aparte que calibra el instrumento contra v1.32.1 con `k = 1`; y **CA-08 (ii)**, la razón de reloj
contra v1.32.1 en una cabecera de 6 y otra de 200 líneas (esperado ≈ 1, techo **1,25×**), con la
comprobación de convergencia por brazo que se añadió el 2026-09-07. Las dos deciden con **una lectura
por corrida**.

**Lo medido sobre mecanismo idéntico por hash** (`hooks=a6810ac6`, `tools=87edb9b4`, `tests=b4cbb114`),
11 corridas de CI del 2026-09-16 al 09-24 (`sondas-coste/contabilidad.md` en la rama de evidencia):
CA-03 directa recorre 1,49–**2,75** (1 FAIL); su calibración 2,44–5,35 (1 FAIL con `k = 1`); CA-08 (ii)
0,94–1,27 en 6 líneas (2 FAIL) y 0,97–1,36 en 200 (3 FAIL). A eso se suman las cuatro de `cand/1.33.0`
(0,973 · 1,131 · 1,337 · 1,364). **El techo cae dentro de la dispersión entre corridas del mismo
estimando**, y la guarda de convergencia mide cuánto se asentó **cada serie**, no cuánto varía **el
cociente**. En el ensayo en CI (5 corridas, `ensayo-ci/resultados.md`) CA-03 directa leyó **2,693×** en
la corrida 5 sobre un árbol que pasó en las otras cuatro: el procedimiento vigente habría puesto el
check en rojo.

**El modo de fallo que esto produce ya estaba nombrado.** La fila del Historial de REQ-017 del
2026-09-07 sobre la convergencia lo escribió: una sonda flaky en la puerta requerida es «el camino más
corto a que alguien lo apague», o a que **alguien suba el techo** para que deje de molestar. Y el propio
CA-08 dejó escrita la condición de disparo de la lectura alternativa —si con el procedimiento
implementado siguiera saliendo rojo sin regresión, subir el techo es decisión del propietario con ADR—.
Este ADR **no** es ese: el propietario decidió que **los umbrales permanecen intactos**.

**Lo ensayado.** Un procedimiento de presupuesto fijo (`sondas-coste/propuesta.md`, rev 2, y su parche
sobre `cfb1106`), probado en 10 corridas locales (0 falsos avisos en 60 casos de control, demora añadida
detectada 20 de 20, calibración resuelta 10 de 10, juez sintético 9 de 9) y en 5 corridas de CI (0 FAIL
en 35 juicios no-WD, WD 10 de 10, calibración 5 de 5, **4 inconclusos**, entre ellos el de la corrida 5
de CA-03 donde el vigente habría fallado).

## Decisión

1. **Procedimiento, no umbrales.** Cada uno de los tres casos (CA-03 directa, CA-08 (ii) con 6 y con 200
   líneas) toma **R = 5** repeticiones con las series y el `k` de hoy; una repetición es **resuelta**
   según una regla fijada antes de medir; con menos de **3** resueltas el caso no decide; con 3 o más,
   **PASS** si todas quedan en el techo o por debajo (la igualdad cumple), **FAIL** si todas lo exceden,
   y si el techo cae dentro del recorrido no decide. En CA-03 la calibración contra v1.32.1 se mide **en
   la misma corrida y con el mismo `k = 20`** y es **precondición**: si no resuelve, el caso no decide,
   nunca es FAIL del candidato. Los techos 2,6 y 1,25 **no se mueven**.
2. **Vocabulario nuevo: INCONCLUSO**, que significa **rendimiento no acreditado**. Se imprime como
   `SKIP <nombre> [INCONCLUSO] …` —el banco sigue teniendo tres clases y su cuadre no cambia— y el
   resumen final lo cuenta **aparte** y nombra cada caso.
3. **La política de inconclusos del propietario, literal** (fuente: la entrada de `PENDING_APPROVAL.md`
   citada arriba):
   > - Los umbrales permanecen intactos.
   > - Un inconcluso significa rendimiento no acreditado; debe quedar visible en el resumen, no sólo en el log detallado.
   > - Puede permitir integrar un cambio que no altere el sujeto medido ni el procedimiento de medición, con esa identidad comprobada y la limitación declarada. Esto no elimina ningún FAIL ni sustituye los demás requisitos de integración.
   > - Si el cambio afecta al rendimiento medido, un inconcluso deja pendiente su acreditación y no permite darla por satisfecha.
   > - Un cambio al propio instrumento, como esta entrega, requiere validar el instrumento; no puede acogerse a la excepción por "hooks idénticos".
   > - No se obtiene acreditación seleccionando una corrida favorable entre otras adversas.
   >
   > La detección de la demora artificial es un control de la prueba, no su finalidad ni garantía de detectar cualquier regresión.
4. **Los controles del instrumento se separan en dos clases:** pruebas **sintéticas** del evaluador
   (vectores fijos, siempre en el banco) y pruebas **de medición** (sujetos idénticos, envoltorio de
   demora 0 y demora fija, a demanda), con el FAIL esperado de la demora **comprobado como esperado**.
5. **Sede del contrato:** desde esta fecha el procedimiento y el vocabulario de CA-03 y CA-08 (ii) los
   contrata **REQ-030**; REQ-017 conserva su texto y enlaza aquí.

## Alternativas consideradas

- **Subir los techos** — no: decisión del propietario; y un techo por encima del ruido dejaría de ver la
  clase de regresión (10× de reloj) para la que existen las sondas.
- **Que INCONCLUSO ponga el check en rojo** (P3 de la propuesta) — no: bloquearía casi todos los PR sin
  acreditar nada, que es el modo de fallo que acaba apagando la sonda.
- **Sacar las sondas a un job no requerido** (P2) — no en esta entrega: toca workflow y ruleset, que el
  propietario dejó fuera.
- **Reabrir REQ-017** (`completado` → `en-progreso`) en vez de un REQ nuevo — no: REQ-017 contrata diez
  criterios que no cambian; reabrirlo arrastraría a revalidar lo cerrado. Se elige un REQ acotado.
- **Aplicar R = 5 también a CA-09** — no: el propietario lo dejó fuera, y su dispersión es de SEC-030.

## Consecuencias

- (+) Un FAIL de estas sondas exige 3 o más lecturas unánimes (y en CA-03, un instrumento que en esa misma
  corrida demostró ver el defecto): un rojo pasa a significar «la medición excede el techo», no «una
  lectura cayó en la cola».
- (+) Lo que el instrumento no puede resolver deja de salir como verde mudo o como rojo de ruido: sale
  **marcado y contado**.
- (−) **Un CI verde puede contener una sonda de rendimiento no acreditada.** El workflow no lee
  inconclusos ni comprueba la identidad del árbol; lo que lo hace visible es la línea `Resultado:` del
  banco, y lo que decide qué significa para una integración es la política de arriba, aplicada por QA,
  seguridad y el propietario (REQ-030 CA-08, CA-09, CA-10). *Mitigación:* el recuento en el resumen; un
  delta de workflow sólo se prepara, para aprobación del propietario.
- (−) **Coste:** las invocaciones de la sonda de reloj de CA-08 (ii) se multiplican por 5 y la calibración
  de CA-03 pasa de `k = 1` a `k = 20`. El sobrecoste en CI **no está medido** (el +89–175 s del ensayo no es
  separable); REQ-030 CA-11 lo mide en la validación normal, sin techo nuevo.
- (−) **Pérdida de decisividad por corrida**, sobre todo en la entrada de 6 líneas de CA-08 (ii). Es el
  precio de no afirmar lo que el instrumento no resuelve.
- (−) **El caso `REQ-017 CA-03 fail-before` desaparece del banco** (−1 en el cuadre): su función pasa a la
  calibración, dentro del veredicto de CA-03.
- **CA-09 queda fuera**, con su sonda y sus resultados (FAIL 1 de 5 y SKIP 1 de 5 en el ensayo en CI sobre
  mecanismo idéntico); puede seguir bloqueando una integración, y esta decisión no promete desbloquear el
  PR #53.
- **Regla de estado (`AGENTS.md` §9).** El cambio es de fondo en dos criterios de un REQ `completado`. La
  regla —un cambio reabre el trabajo y lo hace re-recorrer dev → QA → seguridad— se cumple con **REQ-030**,
  que es el REQ nuevo que reabre ese trabajo y lo recorre entero con `Rigor: critico`. Por eso REQ-017
  conserva `Estado: completado` y sus veredictos: siguen acreditando lo que acreditaron, sobre los
  criterios que no cambian; lo que cambia lo acreditará REQ-030.
- **Numeración:** 012 y no 009, porque 009–011 ya existen en otras líneas del repositorio (REQ-030 § Notas).
