# Candidato de estabilización sobre v1.33.0

Estado: candidato validado localmente; no es una versión publicada ni un cierre de hallazgos.

Base de código: `810128abd5d5b1ca9a240bde98192a9a0c51447c` (tag v1.33.0).
Traspaso consultado: `1dfe31bcb71dcf914f2124f40536bcde2d4019a3`.
Autorización: el propietario pidió tomar el relevo el 2026-09-10, tras detener
Claude, para preparar cambios y pruebas en una copia aislada. No incluye publicar.

## Alcance verificable

1. **D16 / QA-016-04 — ENUNCIADO CORREGIDO EN v1.33.2; ver §«El parche v1.33.2».**
   ~~Un nivel de rigor válido con evidencia parentética final conserva el mismo
   nivel que sin esa evidencia.~~ Esa promesa, tal cual, es la que abrió el
   fail-open de `QA-P48-01`: enunciada sin dirección, autoriza tanto subir
   `critico (por suelo)` —que era el arreglo— como **bajar** `ligero (local)`
   hasta la exención de QA, que no era. El enunciado vigente lleva dirección:
   **el matiz parentético puede SUBIR o MANTENER el rigor efectivo; nunca
   bajarlo.** Se sigue usando la normalización común, y `critico (por suelo)`
   en un REQ no sensible sigue sin caer a `estandar`.
   Ausencia y valores realmente desconocidos conservan la derivación de v1.33.0;
   endurecer esa política queda fuera de este candidato.
2. **SEC-084:** al cambiar el valor efectivo de Seguridad a aprobado, la guarda
   aplica el control de orden existente también si la clave tiene decoración
   aceptada por el lector o si Edit sustituye sólo el valor. QA pendiente o
   con-hallazgos deniega; QA aprobado permite. No se añade una lista alternativa
   de claves al disparador.
3. **Ediciones legítimas:** mencionar campos en el cuerpo o editar texto ajeno
   a la firma no se trata como una nueva firma sólo porque exista una aprobación
   antigua en la cabecera. Seguridad preventiva conserva su conducta.
4. **Vías:** ejercer Write, Edit y MultiEdit contra el hook real, con archivos y
   sustituciones válidas. Los controles comprueban decisión y diagnóstico.
5. **Discriminación:** las regresiones del parche fallan en la base y pasan en
   la candidata. El banco existente y su autoprueba se conservan; no se cambian
   techos de rendimiento ni se repite hasta conseguir verde.

## Límite de seguridad y compatibilidad

Este candidato no garantiza frescura de la firma respecto del commit, no resuelve
homóglifos ni la ausencia de QA (SEC-083), y no modifica rotación, manifiesto,
workflow, estados de los REQ existentes ni sus aprobaciones. Una firma ya presente
no se revalida por una edición de prosa. La comprobación de ausencia heredada no
se presenta como protección nueva.

Las referencias D16/SEC-084 proceden del traspaso y del registro de seguridad de
[1dfe31b](https://github.com/JJOVEGA/ArnesJuan/tree/1dfe31bcb71dcf914f2124f40536bcde2d4019a3).
No se copian datos ni informes de proyectos consumidores.

## Entrega

Diff aplicable sobre la base, pruebas reproducibles y revisión independiente.
Las revisiones realizadas aquí no se presentan como firmas de QA Opus del
pipeline de Claude. No se cambia el número de versión ni se marca ningún REQ
completado. La aprobación de publicación y el portado a 1.34.0 quedan pendientes.

## Resultado local — 2026-09-10

La nueva sección de regresión da 17 PASS en la candidata; sobre la base del tag
da 6 PASS y 11 FAIL. Las secciones relacionadas dan 39 PASS. `bash -n`, los JSON
del plugin y `git diff --check` pasan.

El banco completo de la candidata terminó en 889 PASS, 3 FAIL y 9 SKIP. Los tres
FAIL tienen el mismo identificador que los observados contra la base en esta
máquina: CA-04 de recorte y los dos casos de descendencia de REQ-021 CA-04.1.
El banco no está verde, por lo que este resultado no autoriza una publicación.

---

# El parche v1.33.2 — `QA-P48-01`

Base de código: `a630dc6` (tag `v1.33.1`, punta de `main`).
Rama: `hotfix/1.33.2-rigor`. Autorización expresa del propietario, 2026-09-10.

## El defecto

`v1.33.1` cerró un fail-open y **abrió otro más ancho**. El candidato enrutó la
forma con paréntesis por el lector común **para todos los valores**. En `critico`
eso corrigió D16. En `ligero` regaló una exención: `ligero` es el **único** nivel
exento de `QA: aprobado` (`AGENTS.md` §6), así que un REQ **no sensible** con
`Rigor: ligero (<cualquier matiz>)` pasó a **cerrarse sin QA y sin veredicto de
seguridad**, donde `v1.33.0` lo denegaba.

La conducta anterior —«valor no reconocido: se ignora y se cae al defecto de la
sensibilidad»— no era un descuido que el candidato corrigiera: en `ligero` era
**protectora**. Ese es el punto que el enunciado sin dirección no distinguía.

| `Rigor:` con `Sensible a seguridad:` ≠ sí | v1.33.0 | v1.33.1 | **v1.33.2** |
|---|---|---|---|
| `ligero`                   | `ligero`   | `ligero`     | **`ligero`** |
| `ligero (local)`           | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero (D8, 2026-09-08)`  | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero(sin espacio)`      | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero ()`                | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero (critico)`         | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `estandar (x)`             | `estandar` | `estandar`   | **`estandar`** |
| `critico (por suelo)`      | `estandar` | `critico` ✅ | **`critico`** |

## La propiedad

> **El matiz parentético puede SUBIR o MANTENER el rigor efectivo; nunca bajarlo.**

Operativamente, en `arnes_rigor_efectivo` (`hooks/lib.sh`): se desenvuelve el
paréntesis, se calcula el nivel candidato y se toma **el más restrictivo** entre
ese candidato y el **nivel heredado** —el que la sensibilidad da por defecto, que
es exactamente lo que ese mismo valor daba antes de que el desenvoltorio
existiera—. El suelo de seguridad se aplica después y sigue mandando.

No es un caso especial: es la doctrina que el proyecto ya tiene escrita en
`AGENTS.md` §6 («el rigor se puede subir, nunca bajar») y la regla de que una
guarda sólo puede **estrechar**. Un paréntesis es evidencia que alguien añadió a
mano: puede pedir más ceremonia, no regalar una exención.

`arnes_campos_normaliza` anota en `ARNES_RIGOR_MATIZ` que el nivel salió de
desenvolver un paréntesis. Sin ese dato, `arnes_rigor_efectivo` no puede
distinguir `ligero` escrito a secas de `ligero` obtenido desenvolviendo, que es
justo la distinción que el candidato perdió. La función sigue siendo idempotente.

**Consecuencia que hay que saber, y es deliberada:** no existe forma de declarar
`ligero` **con** matiz. Quien quiera la exención escribe `Rigor: ligero` a secas
y pone la evidencia en el cuerpo del REQ. La exención de QA es justo lo que no
debe poder concederse de pasada.

## Que ningún caso antes denegado pase a permitido

La condición del propietario se cumple **por construcción**, no por muestreo:

1. Para toda entrada, el rigor efectivo de v1.33.2 es **mayor o igual** que el de
   v1.33.0 (barrido de 144 combinaciones `(Rigor:, Sensible a seguridad:)`
   comparando ambos lectores: **0 regresiones**; los únicos cuatro cambios son
   hacia arriba, y son la corrección D16 conservada).
2. Las exigencias de la puerta crecen de forma **monótona** con el nivel:
   `ligero` ⊂ `estandar` (QA) ⊂ `critico` (QA + seguridad), en
   `hooks/guard-completado.sh`.

De (1) y (2): un caso sólo puede pasar de permitido a denegado, nunca al revés.

## Evidencia

- Sonda del propietario reproducida contra los **tres** árboles antes de tocar
  nada: tag `v1.33.0`, `v1.33.1` publicada en la caché del plugin y este
  worktree. Las tres columnas de la tabla salen de ahí.
- **Fail-before / pass-after**, midiendo la **conducta de la puerta** y no el
  lector: contra
  `~/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.1/hooks` los casos nuevos
  dan **6 FAIL** (los seis discriminantes); contra este árbol, **28 PASS · 0
  FAIL** en la sección 40 completa.
- Los cinco casos que pasan en ambos lados **no sobran**: fijan las filas que no
  se pueden mover (`ligero` limpio conserva su exención, `estandar (x)` sigue
  pidiendo QA, `critico (por suelo)` conserva la corrección de v1.33.1, el suelo
  de seguridad sigue mandando sobre el piso del matiz). Sin ellos, «apretar de
  más» y «arreglar» serían indistinguibles.
- Contabilidad cuadrada: sección 40 `17 → 28` casos, `CASOS_ESPERADOS`
  `901 → 912`, `PISO_AUTONOMO_SECCION` `20 → 53`. El caso 12.º no suma porque
  `D16: ligero con matiz sigue ligero` **declaraba `allow` sobre el propio
  fail-open** y se corrigió en su sitio en vez de añadirse: una prueba que fija
  la conducta defectuosa como esperada es lo que impide que el banco la vea.

## Resultado local — 2026-09-10

Banco completo, **tres corridas**, todas con `rc 0` y cuadre **912** exacto:
**908 PASS · 0 FAIL · 4 SKIP** (la 1.ª) y **907 PASS · 0 FAIL · 5 SKIP** (la 2.ª
y la 3.ª).
**La variabilidad se registra, no se promedia ni se elige la cifra mejor:** el
total y el `rc` son idénticos y **FAIL es 0 en las tres**; lo que se mueve es un
SKIP de calibración que depende del reloj de la máquina. 25,2 s de reloj
(`loadavg` 0,92 al arrancar la primera; **esta máquina no es el runner**, la
cifra de reloj no es un umbral y el veredicto lo da el CI en Linux).
Autoprueba del corredor: **106 PASS · 0 FAIL**, CA-18 incluido. `bash -n` sobre
`hooks/*.sh` y `tools/*.sh`, los tres JSON del plugin y `git diff --check`: en
verde.

Los SKIP van explicados por el propio corredor (uno sólo de Windows, dos de
acreditación de coste que no son puerta de PR y uno o dos de calibración cuya
mitad no es medible en este instrumento). Ninguno tapa un caso de este parche:
los 28 de la sección 40 se ejecutan y pasan en las tres corridas.

Nota de reconciliación: el resultado de v1.33.1 registrado arriba (889 PASS, 3
FAIL, 9 SKIP) se midió en **otra máquina**; los recuentos no son comparables
entre plataformas y aquí no se presentan como tales.

## Límites de este parche

- **No** toca la corrección de la firma (`arnes_seguridad_cabecera` y su uso en
  `guard-completado.sh`): está validada y no es el defecto.
- **No** sube la versión en `.claude-plugin/`: el commit de versión va aparte.
- **No** toca `requirements/`, ni veredictos, ni estados de REQ.
- Un `Rigor:` **genuinamente basura** (sin paréntesis, o cuyo desenvoltorio no da
  un nivel válido) sigue cayendo al defecto de la sensibilidad. Eso es
  `QA-016-04`, ya abierto, y **no** se toca aquí.
- **Pendiente de decisión del propietario, y por eso no está escrito:**
  `requirements/README.md:107-110` y su plantilla heredada
  `templates/requirements-README.md.tpl:107-110` afirman que «un matiz
  parentético final **no cambia** un nivel válido». Con este parche esa frase es
  **falsa** para `ligero (…)`. Es contrato heredado por los proyectos
  instalados, así que la corrección se propone y no se aplica por iniciativa del
  desarrollador. Mientras no se corrija, esas dos sedes **prometen de más**.
- `docs/estabilizacion/actualizacion-candidata.md:12` repite el enunciado sin
  dirección. Describe el candidato de v1.33.1 como fue, así que se deja como
  registro histórico; queda **superado** por esta sección.
