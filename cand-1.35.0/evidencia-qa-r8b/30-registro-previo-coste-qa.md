# Registro previo — coste del mecanismo nuevo de la pasada correctiva (QA r8b). Escrito 2026-10-02T14:15:42-06:00, ANTES de medir.

- **Qué se mide:** el coste añadido por `guard-git` al juzgar también la copia del comando sin CR (`befc17a`), que corre
  PRIMERO en `guard.sh` y antes de cualquier techo de análisis. QA-023-14 (lectura de la entrada) no se re-mide:
  `arnes_parse_input` es byte a byte igual en `befc17a` y `9220c71` (el diff de `lib.sh` sólo toca `arnes_id_pertenece`),
  así que su medición de r8 (`evidencia-qa-r8/31-`) sigue valiendo.
- **Árboles:** candidato (worktree, `HEAD:hooks` f7d6ae7) y `9220c71` (a636553, verificado por oid en `00-arboles.txt`).
- **Entrada:** `Bash` de la coordinadora, `cwd` = proyecto de prueba, JSON construido por archivo.
- **Formas y tamaños** (bytes del comando ≈ N): N ∈ {65 536, 131 072, 262 144}.
  - A: líneas `echo aaaaaaaaaa␍␊` (comando CRLF sin escrituras);
  - B: las mismas con ␊ sólo (control: no hay copia);
  - C: una línea `echo ` + `a␍` repetido (muchos CR en una sola línea);
  - D: líneas `git status␍␊` (órdenes de git con CR).
- **Una corrida por celda**, por `guard.sh`, `timeout 120`, orden candidato y luego 9220c71. Se registra decisión y ms.
- **Lo que se afirma:** si la copia añade un coste que crezca más que linealmente frente a 9220c71. No acredita CA-54
  (QA-023-10 sigue abierto), ni SEC-115, ni Windows. **No se repite** para buscar una cifra.

## Adenda, escrita 2026-10-02T14:16:28-06:00, ANTES de medir — por qué y qué
La corrida registrada (`31-`) mostró que por encima del techo de análisis (65 536 por defecto) `guard-git` no recorre el
comando (el análisis se niega por presupuesto y todo sale deny en ~105 ms en los dos árboles): las celdas de 131 072 y
262 144 **no miden la copia**. Para responder la pregunta registrada se mide **dentro del dominio** en que la copia corre:
- formas D (`git status␍␊`) y A (`echo aaaaaaaaaa␍␊`), N ∈ {16 384, 32 768, 65 536} con el techo por defecto, y
  N = 131 072 con `limites.bash_max_analisis` = 131 072 (el máximo que admite el manifiesto, el caso de CA-54);
- candidato y 9220c71, una corrida por celda, por `guard.sh`, `timeout 120`. No se repite la corrida `31-`.
