# Registro previo de las mediciones de coste — desarrollador, octava autorización (2026-10-02)

Escrito y comprometido **antes** de ejecutar ninguna de las mediciones de abajo. Lo que se mida se
registra entero, sin repetir para obtener una cifra favorable. Una corrida inválida por el instrumento
se conserva marcada y se repite **una** vez, diciendo por qué.

- **Árbol candidato:** `hooks/` del worktree `/home/juan/dev/ArnesJuan-v1.35` con los cambios de esta
  comisión (sha256 de `hooks/lib.sh` registrado en la cabecera de cada salida).
- **Fail-before:** `3bc7d3c` (= `01b4a59:hooks`, oid `edff8ac5`), materializado con `git archive`.
- **Antes de la regresión de coste:** `cd6afa6`, materializado con `git archive`.
- **Plataforma:** Linux/WSL2, bash 5.3.9, jq 1.8.2. Sin carga ajena conocida; se anota `loadavg`.

## P1 — QA-023-14: coste de un campo grande con un retorno de carro (la sonda de QA, mismos tamaños)

Copia de `cand-1.35.0/evidencia-qa-r7/sonda-coste-cr.sh` con dos únicos cambios: los árboles
(candidato, `3bc7d3c`, `cd6afa6`) y que el JSON se construye **siempre por archivo** (`jq --rawfile`),
porque por argumentos falla con «Argument list too long» por encima de ~130 000 bytes (defecto del
instrumento que QA ya registró en r7).

- **Bloque 1:** relleno N ∈ {20 000, 50 000, 100 000}; campos `fp` (`Write`, `file_path` = `<raíz>/src/<N a>` + CR),
  `fp-sin-cr`, `tool` (`tool_name` = `Write<N a>` + CR) y `cwd` (`Bash`, `cwd` = `/tmp/<N a>` + CR, `echo x > src/a.ts`).
- **Bloque 2:** `fp` con CR final, N ∈ {200 000, 300 000, 400 000, 600 000}.
- **Bloque 3:** `Bash` `echo x > src/a.ts` de la coordinadora con `tool_input.file_path` de N + CR, N ∈ {100 000, 500 000};
  y el control sin CR de 500 000 en los tres árboles.
- **Una corrida por celda**, por `guard.sh`, con `timeout 120` para ver el reloj aunque pase de 60 s;
  orden por celda: candidato, `3bc7d3c`, `cd6afa6`. Se registran decisión y milisegundos.
- **Lo que se afirma con esto:** si el candidato crece o no más que linealmente frente a `cd6afa6` en
  esos tamaños. **No** acredita CA-54, ni SEC-115, ni Windows.

## P2 — CA-54 (informativo, no un criterio): la sonda de QA de las tres formas

Copia de `cand-1.35.0/evidencia-qa-sec119/sonda-ca54-qa.sh` con un único cambio: los árboles (base =
`3bc7d3c`, candidato = el worktree). Techos 65 536 y 131 072; formas A, B y C; una corrida de
calentamiento descartada por árbol y forma; cinco corridas alternadas. **No** se cambia ningún umbral,
techo ni procedimiento; el resultado se presenta como lo que es: el efecto de esta comisión sobre el
coste, no el cumplimiento de CA-54 (QA-023-10 sigue abierto y es decisión 9b del propietario).

## P3 — camino común (informativo)

`ls -la`, `echo x > /dev/null`, `echo x > /dev/stderr` y `Write <raíz>/src/a.ts` de la coordinadora
por `guard.sh`: mínimo de cinco corridas por caso y árbol (candidato, `3bc7d3c`).
