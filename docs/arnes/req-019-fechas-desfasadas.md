# Enumerado de fechas candidatas a deriva UTC↔local en `requirements/REQ-019.md`

> **Para qué existe este archivo.** La corrección de fechas de `REQ-019` **no se hace en una comisión
> propia** (instrucción del propietario, 2026-09-09): se agrupa con la próxima edición autorizada del
> archivo. Lo caro de la tarea es la **atribución por git**, no el `Edit`, así que el enumerado se
> persiste aquí para que esa comisión lo aplique en **una sola pasada** sin repetir la investigación.
> Regla de persistencia: `REQ-027 B.7` — nace de que las enumeraciones de F1 de `REQ-019` se
> entregaron **por informe** y hoy no se pueden usar.

## Versión base y método

- **Árbol enumerado:** `requirements/REQ-019.md` tal como está en el disco el **2026-09-09**, rama
  `rel/registro-1.33.0`, sobre el commit de trabajo que el propio REQ cita como base del reparto
  (`496068c`) **más cambios sin comprometer** de las dos comisiones del `analista-requerimientos` y de
  la del `desarrollador` que añadió §«El suelo forzado MEDIDO EN BYTES».
- **Advertencia sobre la versión base:** no está verificada con consola (ver abajo). Quien aplique
  esto **re-enumera primero** con el comando del paso 1 y compara el conteo: si no salen **15**, el
  árbol se movió y los números de línea de esta tabla no valen.
- **La `sede` es el identificador estable, no el número de línea.** Los números son del árbol de hoy y
  se desplazan con cualquier edición.

### Método prescrito (los comandos exactos, en orden)

```sh
# 1. Enumerar las apariciones (esperado hoy: 15)
grep -n '2026-09-09' requirements/REQ-019.md

# 2. Por cada línea <n>: qué commit la introdujo
git blame -L<n>,<n> -- requirements/REQ-019.md
#    (o, para ver la historia de esa línea)
git log -L<n>,<n>:requirements/REQ-019.md

# 3. Fecha LOCAL del commit que la introdujo
git show -s --format=%cd --date=format:%Y-%m-%d <sha>
```

**Regla de decisión.** Si el texto dice `2026-09-09` y el commit que introdujo la línea es del
**2026-09-08 local**, está **desfasada** → se corrige a `2026-09-08`. Si el commit es del 2026-09-09,
es **correcta** → no se toca. Si el atributo **no se puede establecer**, se deja como está y se dice.

### Por qué la columna de commit va vacía, y qué hay que hacer antes de rellenarla

1. **La comisión que enumeró corrió sin herramienta de consola.** No pudo ejecutar ninguno de los tres
   comandos: el veredicto de las 15 es `indeterminada` por ausencia de evidencia, no por conflicto.
2. **Y el método, tal como está escrito, tampoco resuelve 14 de las 15.** Esas 14 líneas son
   **posteriores al último commit** y `git blame` sobre una línea no comprometida devuelve
   `Not Committed Yet`. Antes de atribuir hay que **comprometer** los cambios vivos (y entonces la
   fecha del commit será la del día en que se comprometan, no la del día en que se escribieron) **o**
   atribuir por el **registro de comisión**, que es evidencia más débil y va en su propia columna.

## El enumerado

`sede` = dónde vive · `texto` = qué dice la fecha · `commit` / `fecha local` = método prescrito ·
`atribución por comisión` = evidencia débil, del registro de la sesión · `veredicto` = por el método.

| # | Línea | Sede | Texto | Commit | Fecha local | Atribución por comisión (débil) | Veredicto |
|---|---|---|---|---|---|---|---|
| 1 | 379 | `CA-07`, §«Línea base del peso… se re-mide, no se cita» | «dos mediciones del 2026-09-08 y el **2026-09-09** difieren en una línea» | — | — | `analista-requerimientos`, comisión 1 | **indeterminada** |
| 2 | 389 | `CA-07`, §«Por qué `0,72×`» | «**firma del propietario, 2026-09-09**» | — | — | ídem | **indeterminada** · *fecha de firma del propietario* |
| 3 | 469 | `CA-07`, §«Tipo de los números» | «el procedimiento ya se ejerció una vez, el **2026-09-09**» | — | — | ídem | **indeterminada** · *dentro de criterio* |
| 4 | 654 | `CA-14`, §«Y ya no es una precaución teórica» | «**firma del propietario (2026-09-09)** e Historial» | — | — | ídem | **indeterminada** · *firma · dentro de criterio* |
| 5 | 657 | `CA-14`, misma sección | «queda **obsoleta el 2026-09-09**» | — | — | ídem | **indeterminada** · *dentro de criterio* |
| 6 | 673 | `CA-15` (iii) | «el punto 4 dejó de ser sólo del README el **2026-09-09**» | — | — | ídem | **indeterminada** · *dentro de criterio* |
| 7 | 1051 | §«Qué se queda y qué se delega» (README) | «el denominador se corrige el **2026-09-09**» | — | — | ídem | **indeterminada** |
| 8 | 1095 | §«El núcleo del README que no se puede mover» | «no las 433 que este REQ declaraba **hasta el 2026-09-09**» | — | — | ídem | **indeterminada** |
| 9 | 1099 | ídem | «con **firma del propietario (2026-09-09)**» | — | — | ídem | **indeterminada** · *fecha de firma* |
| 10 | 1114 | Encabezado §«El suelo forzado MEDIDO EN BYTES» | «las entradas de este REQ fechadas **2026-09-09** … son de este mismo día» | — | — | `desarrollador`, comisión del suelo en bytes | **correcta por construcción** — la línea **habla sobre** la deriva y la declara; re-fecharla la contradice. **No se toca** |
| 11 | 1486 | Celda **F4** de §«Reparto por fases» | «(Historial, **2026-09-09**)» | — | — | `analista-requerimientos`, comisión 2 | **indeterminada** · *puntero: sigue a la fila 15* |
| 12 | 1816 | `## Historial`, fila del techo `0,72×` y línea base 521 | `| 2026-09-09 |` | — | — | ídem, comisión 1 | **indeterminada** |
| 13 | 1817 | `## Historial`, fila de los tres defectos de `CA-02` | `| 2026-09-09 |` | — | — | ídem, comisión 1 | **indeterminada** |
| 14 | 1818 | `## Historial`, fila del valor `parcial` de `CA-17.1` | `| 2026-09-09 |` | — | — | ídem, comisión 1 | **indeterminada** |
| 15 | 1819 | `## Historial`, fila de la colisión de número de ADR | `| 2026-09-09 |` | — | — | ídem, comisión 2 | **correcta** — la coordinadora la clasificó como escrita hoy (2026-09-09) |

## El número real

**No se puede afirmar, y el `12` declarado tampoco estaba comprobado.** Lo medido:

- **15 apariciones** del literal `2026-09-09` en el archivo (no 12).
- **0 desfasadas confirmadas** por el método prescrito.
- **2 correctas** por evidencia que no es git: la **10** (declara la deriva; contradecirla sería
  introducir el error) y la **15** (clasificada como de hoy por la coordinadora).
- **13 candidatas** a desfasadas, todas `indeterminada`.

Si el `12` de la deuda se refería sólo a las apariciones **ya comprometidas** el 2026-09-08, entonces
el conjunto de esta tabla y el de la deuda **no son el mismo**, y quien aplique la corrección tiene que
reconciliarlos antes de editar: es la misma clase que este REQ ya corrigió tres veces —un número
derivado sin comprobar—.

## Dos prohibiciones que la comisión aplicadora hereda

1. **Cuatro apariciones son la fecha de la firma del propietario** sobre el techo `0,72×` (2, 4, 9 y
   parte de 1). Re-fecharlas es re-fechar la firma: **no se hace sin decisión del propietario**.
2. **Seis viven dentro de texto de criterio** (3, 4, 5, 6 y las dos de `CA-07` de arriba). La
   corrección de una fecha no debe cambiar ningún umbral, ninguna dirección admitida ni el tipo
   (operativo / de contrato) del número que acompaña.
