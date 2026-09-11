# `QA-024-35` — el aviso de `QA:` lleva su condición · medición y arreglo

**Salida (b)** elegida por el propietario el 2026-09-11: *arreglar el mensaje, no el criterio*.
**Vuelta 6** del bucle `dev↔QA` de `REQ-024`, autorizada expresamente (las posteriores a la 3 lo
están una a una; el bucle `analista↔QA` es otra cuenta y no se toca).

## Versión base y método

| qué | valor |
|---|---|
| worktree | `/home/juan/dev/ArnesJuan-1.34-reparaciones` |
| rama | `feat/1.34-cierre-alcance` |
| commit base (el «antes») | **`929043d`** |
| archivos tocados | `hooks/guard-completado.sh`, `tests/escenarios/hooks/secciones/43-condicion-del-aviso.sh` (nuevo), `tests/escenarios/hooks/run.sh` (sólo el cuadre), `tests/escenarios/hooks/README.md` (sólo el total) |
| plataforma | Linux 6.18 (WSL2), `bash` 5, `jq` |

**Cómo se re-deriva cada cifra de este artefacto, sin preguntar a nadie.** Todo sale de un único
programa, `medir-matriz.sh`, que está aquí al lado y no depende del banco: arma un proyecto
efímero con su `.arnes/config.json`, alimenta JSON de `PreToolUse` al hook **real** y publica una
línea por celda. Se le pasa un directorio de hooks, así que el «antes» y el «después» se miden con
el mismo instrumento:

```sh
# el ANTES: los hooks de 929043d, materializados aparte
mkdir /tmp/antes-hooks
cd /home/juan/dev/ArnesJuan-1.34-reparaciones
for f in $(git ls-tree --name-only 929043d hooks/); do
  git show "929043d:$f" > "/tmp/antes-hooks/$(basename "$f")"
done
chmod +x /tmp/antes-hooks/*.sh          # se invocan directamente; sin el bit, el canario aborta

bash docs/arnes/qa-024-35-condicion-del-aviso/medir-matriz.sh /tmp/antes-hooks          > antes.txt
bash docs/arnes/qa-024-35-condicion-del-aviso/medir-matriz.sh .../ArnesJuan-1.34-reparaciones/hooks > despues.txt

diff <(grep '^DECIS' antes.txt) <(grep '^DECIS' despues.txt)   # tiene que salir VACÍO
diff <(grep '^TEXTO' antes.txt) <(grep '^TEXTO' despues.txt)   # sólo las 12 celdas de `QA:`
```

Las salidas crudas de esas dos vueltas son `matriz-antes-929043d.txt` y `matriz-despues.txt`.

## 1. El defecto, verificado (no repetido de la ficha de QA)

El aviso anunciaba una consecuencia sobre el **cierre**, y esa consecuencia está **condicionada**
por un eje que **no es el mismo para las dos claves**. Medido con el hook real, celda por celda:

| forma escrita | llave | `ligero` | `estandar` | `critico` | eje real |
|---|---|---|---|---|---|
| `QA:` **ausente** para el lector (`qa:` en minúscula, o sin línea) | `false` (por defecto) | **ALLOW** | **ALLOW** | **ALLOW** | **la llave** `campos.ausencia_exige` |
| ídem | `true` | DENY | DENY | DENY | ídem |
| `Seguridad:` **ausente** para el lector | `false` | ALLOW | ALLOW | DENY | **el rigor** |
| ídem | `true` | ALLOW | ALLOW | DENY | **el rigor** (la llave **no** lo mueve) |
| `QA:` con valor **fuera de vocabulario** | `false` y `true` | **ALLOW** | DENY | DENY | **el rigor** (`ligero` no juzga el valor) |
| `Seguridad:` con valor **fuera de vocabulario** | `false` y `true` | ALLOW | ALLOW | DENY | **el rigor** |

**Dos** mensajes prometían de más, no uno, y son la **misma forma de defecto** en ejes distintos:

1. **El de `QA:` ausente** (`guard-completado.sh:287` en `929043d`; **`:309`** tras el arreglo) — el de la ficha `QA-024-35`. Prometía
   «*el REQ no podra cerrarse por ausencia de veredicto de QA*» **sin condición**, y con la llave
   apagada —que es como nace y como está este repositorio, `.arnes/config.json:37`— el REQ
   **cierra** en los tres rigores.
2. **El de `QA:` fuera de vocabulario** (`guard-completado.sh:270`, misma línea antes y después) — hallado al barrer la promesa
   entera antes de escribir, como pide la instrucción de mirar los dos lados. Prometía «*asi este
   REQ no podra cerrarse*» **sin condición**, y en `Rigor: ligero` el REQ **cierra**: `ligero` no
   pide veredicto de QA y su valor no se juzga. No es un hallazgo nuevo de otro mecanismo: es la
   misma frase, en la misma función, cuatro líneas más arriba, y arreglar sólo la señalada habría
   devuelto el trabajo al mismo sitio en la vuelta siguiente.

**Los dos de `Seguridad:` ya salían bien y NO se han tocado.** Su única condición es el rigor, su
texto la lleva («si el rigor efectivo es critico»), y está medido que la llave **no mueve su
veredicto en ningún nivel**. No hay, por tanto, eje sin declarar que presentar.

## 2. El texto, antes y después, combinación por combinación

El texto de un aviso no depende del rigor —el hook no lo conoce al avisar—, así que las tres
columnas de rigor traen el mismo texto; lo que cambia es si ese texto **es verdad** en esa celda.
Esa es justamente la columna «¿verdadero?».

### (a) `QA:` ausente para el lector — `guard-completado.sh:287` → `:309`

| llave | texto **antes** (`929043d`) | ¿verdadero en `ligero`/`estandar`/`critico`? |
|---|---|---|
| `false` | «…el campo sigue SIN declarar, asi que ninguna guarda juzga esta edicion **y el REQ no podra cerrarse por ausencia de veredicto de QA**.» | **NO / NO / NO** (cierra en los tres) |
| `true` | *el mismo texto* | sí / sí / sí |

| llave | texto **después** | ¿verdadero? |
|---|---|---|
| `false` | «…ninguna guarda juzga esta edicion. Y lo que el CIERRE hace con esa ausencia **NO lo decide el rigor** —que es el eje del campo 'Seguridad:'—, lo decide **'campos.ausencia_exige'** (.arnes/config.json): encendida, el cierre se deniega nombrando 'QA:' en los tres niveles de rigor; apagada —como nace—, la ausencia se perdona y el REQ cierra sin veredicto de QA. **Aqui esta APAGADA, asi que el REQ SI podra cerrarse sin veredicto de QA.** Salida: escribe la clave como 'QA:'.» | **sí / sí / sí** |
| `true` | *ídem, cerrando con* «**Aqui esta ENCENDIDA, asi que el REQ no podra cerrarse.**» | **sí / sí / sí** |

### (b) `QA:` con valor fuera de vocabulario — `guard-completado.sh:270`

| | texto | ¿verdadero en `ligero`/`estandar`/`critico`? |
|---|---|---|
| **antes** | «…que NO es un veredicto (…). **Asi este REQ no podra cerrarse.** Un matiz va entre parentesis…» | **NO** / sí / sí |
| **después** | «…que NO es un veredicto (…). **Si el rigor efectivo NO es 'ligero' —'ligero' no pide veredicto de QA y su valor no se juzga—, asi este REQ no podra cerrarse.** Un matiz va entre parentesis…» | **sí / sí / sí** |

Idéntico en los **dos** estados de la llave: el campo está declarado, así que la llave no interviene.

### (c) y (d) Los dos de `Seguridad:` — **sin cambio, byte a byte**

| sede | texto (antes **y** después) | ¿verdadero en las 6 celdas? |
|---|---|---|
| `:290` → `:312`, ausente | «…esta firma no la juzga la guarda del orden del ciclo y, **si el rigor efectivo es critico**, el REQ no podra cerrarse por ausencia de veredicto de seguridad.» | **sí**, en los dos estados de la llave |
| `:273`, fuera de vocabulario | «**Si el rigor efectivo es critico**, asi este REQ no podra cerrarse.» | **sí**, en los dos estados |

`diff` de las 12 celdas `TEXTO …SEG…` entre `matriz-antes-929043d.txt` y `matriz-despues.txt`:
**vacío**.

## 3. No-regresión: ninguna decisión ni ningún `rc` se movió

`diff` de las **36** celdas `DECIS` (6 sujetos × 2 estados de la llave × 3 rigores) entre las dos
vueltas del mismo instrumento: **vacío**. Los seis sujetos son: cierre con `QA:` fuera de
vocabulario, con `QA:` ausente, con `Seguridad:` fuera de vocabulario, con `Seguridad:` ausente,
con la línea `qa:` en minúscula escrita en disco, y el control positivo (todo declarado y
aprobado). **Todas** las celdas salen con `rc=0` antes y después — lo que importa porque el
arreglo mete una **sustitución de comando dentro del texto** de un aviso, y eso es justo lo que
podría mover un código de salida o ensuciar la salida sin cambiar ningún veredicto.

La matriz publicada, por si hace falta leerla sin re-correr nada:

| sujeto del cierre | llave | `ligero` | `estandar` | `critico` |
|---|---|---|---|---|
| `QA:` fuera de vocabulario | `false` / `true` | allow / allow | deny / deny | deny / deny |
| `QA:` ausente | `false` / `true` | **allow** / deny | **allow** / deny | **allow** / deny |
| `Seguridad:` fuera de vocabulario | `false` / `true` | allow / allow | allow / allow | deny / deny |
| `Seguridad:` ausente | `false` / `true` | allow / allow | allow / allow | deny / deny |
| `qa:` en minúscula en disco | `false` / `true` | allow / deny | allow / deny | allow / deny |
| control positivo (todo aprobado) | `false` / `true` | allow / allow | allow / allow | allow / allow |

## 4. Lo que el banco fija, y su fail-before

Sección nueva **`43-condicion-del-aviso.sh`**, **52 casos**; `CASOS_ESPERADOS` del corredor
**1115 → 1167**. No se toca ni un `CASOS_ESPERADOS_SECCION` ajeno: ningún caso preexistente
cambia de veredicto.

| bloque | casos | qué fija |
|---|---|---|
| A | 6 | el aviso de `QA:` **ausente** declara la **llave** y resuelve su estado real (2 estados × 3 rigores) |
| B | 6 | el aviso de `QA:` **fuera de vocabulario** declara el **rigor** (2 × 3) |
| C, D | 12 | **control de la asimetría**: los dos de `Seguridad:` siguen diciendo lo mismo y su eje sigue siendo el rigor en los dos estados de la llave |
| discriminante | 2 | una clave limpia con un valor válido **no avisa** — sin esto, un aviso que se disparara siempre pasaría los 24 de arriba |
| E | 26 | **no-regresión**: las mismas celdas, con su `ALLOW`/`DENY` **y su `rc`**, más el control positivo por estado de la llave |

**Fail-before, medido** (`fail-before-seccion-43.txt`): la sección corrida contra los hooks de
`929043d` vía `ARNES_HOOKS_DIR` da **40 PASS · 12 FAIL**. Los 12 rojos son exactamente los
bloques A y B —las dos promesas falsas—; los otros 40 pasan **también** contra el código anterior,
que es la otra mitad de la acreditación: son controles, no arreglo.

```sh
ARNES_HOOKS_DIR=/tmp/antes-hooks bash tests/escenarios/hooks/run.sh secciones/43-*.sh
```

## 5. Puertas

| puerta | resultado |
|---|---|
| banco entero (`tests/escenarios/hooks/run.sh`) | **1160 PASS · 0 FAIL · 7 SKIP**, cuadre 1167 ✓, `rc=0`, 1 min 12 s |
| autoprueba del corredor | `rc=0`; `CA-18` publica la 43 con `lineas=158 piso=92 techo=400` |
| §7 · `bash -n` de `hooks/*.sh` y `tools/*.sh` | OK |
| §7 · `jq -e . hooks/hooks.json` | OK |
| §7 · `jq -e .` de `plugin.json` y `marketplace.json` | OK |

Los **7 SKIP** son los mismos de antes del cambio, cada uno con su motivo impreso; ninguno toca
esta reparación. **No se acredita nada de rendimiento en este artefacto**: el reloj del banco se
publica como dato de contexto y no como medida —había otra sesión del propietario en la misma
máquina—, y esta reparación no tiene ninguna afirmación de coste que sostener.

## 6. Lo que NO se hizo, dicho aquí y no en otro sitio

- **No se encendió nada.** `campos.ausencia_exige` sigue `false` en `.arnes/config.json`; no se
  tocó el manifiesto, ni el valor por defecto del lector, ni se añadió ninguna rama de decisión.
  Que con la llave apagada una ausencia de `QA:` se **perdone** sigue siendo exactamente igual de
  cierto que antes: el arreglo hace que el aviso **lo diga**, no que deje de pasar.
- **`QA-024-36`** (`instrumento`) sigue abierto: el comentario de `hooks/guard-completado.sh:275-280`
  —y su gemela de `hooks/lib.sh:2206-2208`, verificada: «*el lector no lee esa linea, asi que el
  REQ sigue SIN ese campo y el cierre lo deniega por ausencia*»— afirma la denegación **sin su
  condición**, que es la misma falsedad que este arreglo corrige en el mensaje. Las dos líneas
  siguen donde estaban (el comentario nuevo se insertó **después**, en `:286-305`). No cae dentro de la línea corregida y el propietario lo dejó fuera de esta vuelta. El
  comentario **nuevo** que acompaña al arreglo (inmediatamente antes de la rama de desfase) trae la
  matriz medida y no repite la afirmación falsa, así que el archivo no gana ninguna sede; pero
  quien tome `QA-024-36` encontrará las dos versiones a siete líneas de distancia.
- **`QA-024-37`** (`instrumento`) sigue abierto: el rótulo del caso `42/B` generaliza sobre un
  fixture `critico`. No se tocó la sección 42.
- **`hooks/lib.sh` no se tocó.** La corrección vive entera en el texto de dos mensajes de
  `guard-completado.sh`.
- **Se corrigió un total desfasado en `tests/escenarios/hooks/README.md`**: decía «1015 casos» con
  el literal del corredor ya en 1115. Es el mismo defecto que ese párrafo enumera de sí mismo
  («886 con el literal en 887…»), y dejarlo habría hecho dudar del cuadre nuevo.
