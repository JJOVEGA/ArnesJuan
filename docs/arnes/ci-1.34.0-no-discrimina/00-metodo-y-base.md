# El CI pasó, falló y volvió a pasar sobre código idéntico — y el verde de `af01436` no acredita

**Versión base:** tres corridas consecutivas de `hooks-en-linux` sobre `b55347e`, `67b06fe` y
`af01436`, rama `rel/registro-1.33.0`, 2026-09-10 entre 13:27 y 13:54 UTC.
**Método:** `gh run list` para los veredictos; `gh run view --log-failed` para la línea del fallo;
`git diff --name-only <a>..<b> -- hooks/ tools/ tests/ .github/ .arnes/ templates/ .claude-plugin/`
para el delta de mecanismo. **No se re-corrió nada.**

## Lo medido

| Commit | `hooks-en-linux` | Archivos de mecanismo cambiados respecto del anterior |
|---|---|---|
| `b55347e` | **success** | — |
| `67b06fe` | **failure** | **0** |
| `af01436` | **success** | **0** |

*Comprobado:* `git diff --name-only b55347e..67b06fe` y `67b06fe..af01436` sobre `hooks/ tools/
tests/ .github/ .arnes/ templates/ .claude-plugin/` devuelven **cero archivos** las dos veces. Lo
único que cambió entre los tres son documentos (`docs/`, `requirements/`, `CHANGELOG.md`,
`PENDING_APPROVAL.md`).

## Qué falló, y NO es lo que yo esperaba

```
FAIL  REQ-024 CA-07 (ii) el reloj de la ruta crítica = 1.320× > techo 1.250×
      (76072µs sobre 57589µs): el techo es OPERATIVO y no se sube
```

**No es `REQ-023 CA-09 (iii)`.** Es un **segundo** criterio de techo de reloj, en otro REQ. Los dos
comparten patología —un techo de reloj juzgado en una máquina cuya carga nadie fija— pero son
hallazgos distintos y no se cuentan como uno.

## Lo que esto acredita y lo que NO

**Acredita:** que la comprobación `hooks-en-linux` **no discrimina** sobre `REQ-024 CA-07 (ii)`.
Un mismo mecanismo, byte a byte, obtiene `success`, `failure` y `success` en 27 minutos.

**NO acredita — y aquí es donde yo me equivoqué antes:** que el rojo fuera falso. Una prueba que no
discrimina **no acredita nada en ninguna de sus dos direcciones**. Por lo tanto:

> **El `success` de `af01436` NO acredita `REQ-024 CA-07 (ii)`.**

Tomar el verde como acreditación es el mismo error que tomar el rojo como ruido, con el signo
cambiado. Las dos lecturas se apoyan en la mitad conveniente de la misma evidencia.

## Consecuencia para la puerta requerida

`hooks-en-linux` es la puerta **requerida y estricta** de `main`. Una puerta que devuelve veredictos
distintos sobre el mismo código no protege lo que dice proteger, **y tampoco puede usarse como prueba
de que algo está bien**. Cualquier afirmación de la forma «el CI está en verde, luego X» queda sin
fundamento para los criterios de reloj mientras esto siga así.

## Siguiente paso — registrado, no ejecutado

- **Dueño:** `qa-tester` (caracterizar) y `desarrollador` (el techo), sobre `REQ-024`.
- **Qué falta:** decidir si `CA-07 (ii)` se repara, se declara no acreditante con dueño y
  vencimiento, o se saca de la puerta requerida. Es la **misma decisión** que la de
  `REQ-023 CA-09 (iii)` en §10 de `docs/propuesta-cierre-1.34.0.md`, aplicada a otro criterio.
- **No se abrió hallazgo:** abrirlos es de QA o del auditor, y el propietario pidió no abrir
  investigaciones nuevas en el cierre. Queda escrito aquí para que no se redescubra.
