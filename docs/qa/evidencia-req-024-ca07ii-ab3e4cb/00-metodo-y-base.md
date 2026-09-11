# Evidencia de la QA acotada, VUELTA 2, de `REQ-024 CA-07 (ii)`

**Versión base:** worktree `/home/juan/dev/ArnesJuan-1.34-reparaciones`, rama
`feat/1.34-reparaciones-astra`, cabeza **`ab3e4cb`** (más una edición sin comitear de la
coordinadora en `requirements/README.md`, que no toca nada medido aquí).
`hooks/` y `tools/` están **sin cambios desde `69fc96a`** (comprobado:
`git diff --stat 69fc96a..ab3e4cb -- hooks/ tools/` devuelve vacío), así que el sujeto medido en
la vuelta 1 y el de hoy son el **mismo código**.

**Máquina:** WSL2, `linux-gnu-x86_64-bash5.3`, **12 núcleos**, carga 0,03–2,34 durante la campaña.
**No es el runner** (4 vCPU, `ARNES_JOBS=6`, carga ~5), y está medido en este repositorio que los
dos **no predicen lo mismo**.

## Los cuatro sujetos, y cómo se construyó cada uno

Todos son copias de `hooks/` en el scratchpad; **no se editó `hooks/` del repositorio**. La
inyección es la receta de `QA-024-21`: una línea insertada **tras el shebang** de
`guard-completado.sh`.

| sujeto | inyección | dónde |
|---|---|---|
| `candidato` | ninguna | `hooks/` del worktree |
| `+1500` | `for ((_qa=0;_qa<1500;_qa++)); do :; done` | copia |
| `+3400` | ídem con `3400` | copia (sólo calibración) |
| `+3700` | ídem con `3700` | copia |
| `+5000` | ídem con `5000` | copia (sólo calibración) |

Se ejecutan apuntando el banco a la copia: `ARNES_HOOKS_DIR=<copia> bash
tests/escenarios/hooks/run.sh secciones/40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh`.
El brazo heredado (`v1.33.0`) lo materializa la propia sección desde el tag y **no** lo toca
`ARNES_HOOKS_DIR`.

## El instrumento INDEPENDIENTE (`cal.sh`, `cal2.sh`), y por qué hace falta

La razón que la puerta publica es su **propia** medición: usarla para juzgar si la puerta acierta
sería circular. Así que la razón verdadera se estima **fuera** de la puerta, con la doctrina del
propio arnés (`requirements/README.md`: el estadístico es el **mínimo**): mínimo de una serie de
**k=8** invocaciones, sobre **50 series entrelazadas** por árbol, con el **mismo** fixture que usa
la sección (proyecto efímero con `.arnes/config.json`, `PENDING_APPROVAL.md` vacío, `requirements/`
copiado y un `REQ-951` en estado terminal con todos los veredictos en verde).

Se llama **suelo** y no «valor verdadero»: es un mínimo sobre 50 series, no una garantía.

### Lo medido (`calibracion-01.txt`, 50 series por árbol, host en reposo)

| árbol | mínimo (µs) | razón contra `v1.33.0` |
|---|---|---|
| `v1.33.0` (línea base) | 200 680 | 1,0000× |
| candidato limpio | 222 046 | **1,1065×** |
| candidato +1500 | 236 170 | **1,1768×** |
| candidato +3400 | 251 809 | **1,2548×** |
| candidato +5000 | 269 245 | **1,3417×** |

### La calibración del caso de **1,28×** (`calibracion-3700.txt`, dos tomas, una antes y otra después de la campaña)

```
inyectado-3700 min=224972 us · v1.33.0 min=176631 us · RAZON VERDADERA (suelo) = 1.2737
inyectado-3700 min=223332 us · v1.33.0 min=174104 us · RAZON VERDADERA (suelo) = 1.2828
```

**`+3700` es el caso de 1,28×.** `+1500` **no lo es**: vale **1,177×**, y por tanto está **bajo el
techo de 1,250×**. Ver el hallazgo `QA-024-28`.

## Inventario de corridas conservadas — 25, elemento por elemento, ninguna descartada

Todas están en `corridas/`. `rc` es el código de salida de `run.sh`.

| archivo | sujeto | intentos | veredicto del caso | rc |
|---|---|---|---|---|
| `base-01.txt` | candidato limpio | 1 | PASS `máx(r) 1.140×` | 0 |
| `inj1500-01.txt` | +1500 | 3 | **FAIL por REGRESIÓN** `mín(r) 1.262×` | 1 |
| `inj1500-02.txt` | +1500 | 3 | FAIL «no se pudo acreditar» | 1 |
| `inj1500-03.txt` | +1500 | 3 | PASS `máx(r) 1.237×` | 0 |
| `inj1500-04.txt` | +1500 | 3 | FAIL «no se pudo acreditar» | 1 |
| `inj1500-05.txt` | +1500 | 3 | PASS `máx(r) 1.224×` | 0 |
| `inj1500-06.txt` | +1500 | 2 | PASS `máx(r) 1.246×` | 0 |
| `inj1500-07.txt` | +1500 | 1 | PASS `máx(r) 1.249×` | 0 |
| `inj1500-08.txt` | +1500 | 3 | FAIL «no se pudo acreditar» | 1 |
| `inj1500-09.txt` | +1500 | 3 | FAIL «no se pudo acreditar» | 1 |
| `inj1500-10.txt` | +1500 | 1 | PASS `máx(r) 1.223×` | 0 |
| `inj1500-palanca-1.txt` | +1500, `ARNES_COSTE_RUTA_CRITICA=1` | 3 | PASS `máx(r) 1.241×` | 0 |
| `inj1500-palanca-2.txt` | +1500, `ARNES_COSTE_RUTA_CRITICA=1` | 3 | PASS `máx(r) 1.228×` | 0 |
| `inj3700-01.txt` | **+3700 (1,28×)** | 1 | **FAIL por REGRESIÓN** `mín(r) 1.361×` | 1 |
| `inj3700-02.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.354×` | 1 |
| `inj3700-03.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.340×` | 1 |
| `inj3700-04.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.375×` | 1 |
| `inj3700-05.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.343×` | 1 |
| `inj3700-06.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.329×` | 1 |
| `inj3700-07.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.351×` | 1 |
| `inj3700-08.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.363×` | 1 |
| `inj3700-09.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.361×` | 1 |
| `inj3700-10.txt` | +3700 | 1 | **FAIL por REGRESIÓN** `mín(r) 1.361×` | 1 |
| `sinbase-sinpalanca.txt` | candidato, **sin línea base** | 3 | FAIL «no se pudo acreditar» | 1 |
| `sinbase-conpalanca.txt` | candidato, sin línea base, con palanca | 3 | FAIL «no se pudo acreditar» | 1 |

**Cuadre:** las 25 corridas ejecutaron **6 de 6** casos declarados en la sección
(`CASOS_ESPERADOS_SECCION=6`) y **ninguna** produjo `ABORT`.
**rc:** `FAIL` → `rc 1` en **17 de 17**; `PASS` → `rc 0` en **8 de 8**.
**Y el caso real NO emitió `SKIP` ni una sola vez en las 25**: la rama `SKIP` de `veredicto07` es
inalcanzable desde el caso real (ver `QA-024-22`).

## Cómo forzar la no acreditación sin tocar el banco (para re-derivar `sinbase-*.txt`)

Se copia **sólo** el archivo de la sección a un árbol cuyo `secciones/../../../..` no tenga `.git`,
y se apunta `ARNES_SECCIONES_DIR` ahí. La sección no encuentra `v1.33.0`, `mide07` no devuelve
ninguna repetición, y el caso recorre los 3 intentos y emite el `FAIL` «no se pudo acreditar» en
**2 segundos**, de forma determinista.
