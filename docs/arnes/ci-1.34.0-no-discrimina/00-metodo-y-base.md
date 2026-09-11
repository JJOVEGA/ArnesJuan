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

---

## Cuarta y quinta observación — `#48`, 2026-09-11 (añadido por la coordinadora)

**Versión base:** `3c52d6d` (**success**, 12:28 UTC) y `0caeac5` (**failure**, 12:55 UTC), rama
`feat/1.34-reparaciones-astra`. **Método:** idéntico al de arriba. **No se re-corrió nada.**

```
FAIL  REQ-024 CA-07 (ii) el reloj de la ruta crítica = 1.257× > techo 1.250×
      (70971µs sobre 56431µs): el techo es OPERATIVO y no se sube
```

**El mismo criterio.** El resto de la corrida: **1077 PASS, 1 FAIL, 12 SKIP**.

| Hecho | Cómo se comprobó |
|---|---|
| `git diff --stat 3c52d6d 0caeac5 -- hooks/ tools/ tests/ .github/ .arnes/ .claude-plugin/` | **vacío** — el código medido es idéntico byte a byte |
| Lo único que cambia entre ambos | `CHANGELOG.md`, `docs/seguridad/`, `docs/arnes/` |
| Margen del rebase | **0,6 %** sobre el techo (1,257× contra 1,250×) |

### La atribución, comprobada y no supuesta

El fallo previo de este mismo criterio (1,320×) fue sobre **`67b06fe`**, y se verificó que
`67b06fe` es **ancestro de `rel/registro-1.33.0`** y **anterior a `6e3bb90`**, que es donde `#48`
modifica `hooks/lib.sh`. Luego el criterio **ya fallaba en la línea destino antes de que existiera
el cambio de código de `#48`**: la guarda del matiz no es condición necesaria del fallo.

Historial de la rama: `d1b3cc3` **failure**, `406f7e9`…`3c52d6d` **success** (6), `0caeac5`
**failure**. Y el rojo de `d1b3cc3` **no** fue instrumento: era `CA-18 (b)`, un defecto real de
declaración del piso de sección, corregido en `406f7e9`. **No todo rojo de esta rama es ruido**, y
por eso ninguno se descarta sin mirarlo.

### Lo que esto NO autoriza, y es el punto

Que el código medido sea idéntico **no convierte el `FAIL` en falso**. Sigue valiendo lo escrito
arriba: una prueba que no discrimina **no acredita nada en ninguna de sus dos direcciones**. Lo que
queda acreditado es lo de no-atribución —el fallo no lo causó este cambio— y lo que queda **sin**
acreditar es `REQ-024 CA-07 (ii)`, en los dos sentidos, por quinta observación consecutiva.

**Consecuencia operativa:** `#48` **no se fusionó** sobre este rojo. La puerta no se debilita, el
rojo no se reclasifica y no se re-corrió buscando un verde. La decisión sobre el criterio sigue
siendo la que ya estaba registrada arriba, y es del propietario.
