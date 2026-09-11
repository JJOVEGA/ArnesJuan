# `QA-P48-01` **no lo introduce el porte: vive en la `v1.33.1` PUBLICADA**

**Quién y cuándo:** coordinadora, 2026-09-10, inmediatamente después del veredicto de QA.
**Por qué esta comprobación:** QA midió `QA-P48-01` **base del PR ↔ porte**, y ese par no puede
distinguir «el porte lo introdujo» de «el porte lo hereda de lo publicado». La diferencia decide si
esto es un hallazgo de un PR o un **defecto publicado**, así que se midió.

**Método:** se ejecutan los lectores **realmente instalados** —no copias, no el árbol— desde la caché
de instalación del plugin, que conserva las dos versiones:
`/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/{1.33.0,1.33.1}/hooks/lib.sh`, más el
`hooks/lib.sh` del porte extraído con `git show`. Sonda re-ejecutable:
`22-sonda-ligero-publicadas.sh` (se le pasa la ruta de un `lib.sh`).

## Lo medido — `Sensible a seguridad:` **≠ sí** (que es la condición de exposición)

| `Rigor:` declarado | **1.33.0** publicada | **1.33.1** publicada | **porte #48** |
|---|---|---|---|
| `ligero` | `ligero` | `ligero` | `ligero` |
| **`ligero (local)`** | `estandar` | **`ligero`** | **`ligero`** |
| **`ligero (D8, 2026-09-08)`** | `estandar` | **`ligero`** | **`ligero`** |
| **`ligero(sin espacio)`** | `estandar` | **`ligero`** | **`ligero`** |
| **`ligero ()`** | `estandar` | **`ligero`** | **`ligero`** |
| **`ligero (critico)`** | `estandar` | **`ligero`** | **`ligero`** |
| `estandar (x)` | `estandar` | `estandar` | `estandar` |
| `critico (por suelo)` | `estandar` ⚠️ | `critico` ✅ | `critico` ✅ |

## Conclusión, y es de tres partes

1. **El porte es FIEL.** Sus tres columnas de la derecha son idénticas a la `1.33.1` publicada. El
   porte **no introduce** `QA-P48-01`: lo **hereda**. El hallazgo de QA es correcto en el hecho y su
   par base↔porte no alcanzaba para atribuirlo.
2. **`v1.33.1` abrió un fail-open que `v1.33.0` NO tenía.** Y va en la dirección peor: `ligero` es el
   **único** nivel exento de `QA: aprobado` (`AGENTS.md` §6). Un REQ **no** sensible con
   `Rigor: ligero (<cualquier matiz>)` cierra hoy **sin QA y sin veredicto de seguridad**, donde
   1.33.0 exigía QA por caer a `estandar`.
3. **Es la misma forma que el defecto que 1.33.1 salió a corregir, con el signo cambiado.** El parche
   enrutó la forma con paréntesis por el lector común **para todos los valores**, y en `ligero` la
   conducta anterior —«valor no reconocido: se ignora y se cae al defecto de la sensibilidad»— era
   **protectora**. Se cerró la caída de `critico`→`estandar` y se abrió la de `estandar`→`ligero`.

## Exposición, separando lo medido de lo no comprobado

- **Defecto reproducido:** sí, en la 1.33.1 **publicada**, con el lector instalado. Arriba.
- **Exposición observada en este repositorio: NINGUNA, y es medible.** La política de
  autoalojamiento (`AGENTS.md` §6) declara **todo** REQ `Sensible a seguridad: sí`, y el suelo lo
  rescata. Comprobado: `grep -L 'Sensible a seguridad: *\**s[íi]' requirements/REQ-0*.md` → **0**
  archivos. Aquí es **latente**.
- **Uso histórico: NO COMPROBADO.** Que haya proyectos instalados con REQ no sensibles descansa en
  la afirmación de `AGENTS.md`, no en una comprobación. **No hay base para estimarlo.**

## Por qué NO se recomienda volver a 1.33.0 en la instalación estable

Porque en **este** repositorio los dos defectos no son simétricos: el de 1.33.1 es **latente** (todos
los REQ son sensibles), y el de 1.33.0 estaba **activo** — QA midió que con la clave **limpia**, un
`Edit` que sustituye **sólo el valor** de `Seguridad:` daba **allow** en 1.33.0 y da **deny** en
1.33.1, y ésa es la forma más natural de firmar con `Edit`. Para este árbol, 1.33.1 es
**estrictamente mejor**. Para un consumidor con REQ no sensibles, la comparación es **otra** y no la
decide este documento.
