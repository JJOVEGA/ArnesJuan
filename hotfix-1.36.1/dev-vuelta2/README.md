# Hotfix 1.36.1 — vuelta 2 de 3 (QA-032-02, P-032-5 (C)): REQ-032 CA-15 como lista de lo que se acepta

Árbol medido: `hotfix/1.36.1` en `30568fd` más los cambios de la vuelta 2 sin commit (sha256 en `00-entorno.txt`).
Línea base: hooks de v1.36.0 (`f22b905`). Comparación de la entrega anterior: `264dfa9`. Linux/WSL2; Windows/MSYS y host sin medir.

## Qué se cambió (`70-diff-desde-30568fd.patch`; `hooks/` con `Edit`)
`_arnes_cmd_llano` (`hooks/lib.sh`) afirma sólo que el comando crudo es UNA invocación simple: primera palabra `cp`/`mv`/`install`;
caracteres `[A-Za-z0-9]` (escritos uno a uno), blanco y `. / _ + , : @ % = -`; opciones de la lista cerrada
(`-f -i -n -p -v -r -R -a -u`, solas o agrupadas; `--force --interactive --no-clobber --verbose --recursive --archive --update`);
dos operandos o más. `arnes_destino_a_juzgar` exige además que el destino del detector sea el último operando. El enlace único, igual.

## Resultados
| Archivo | Qué | Resultado |
|---|---|---|
| `20` | sección 48, candidata | 546/0 |
| `21` | hooks de v1.36.0 como candidata | 517/29: F1–F3, F6–F8 (M-032), L1, H4k y el ORÁCULO; las demás deciden igual |
| `22` | hooks de `264dfa9` como candidata | 493/**53**: X1–X4, P2–P8, E1 (salvo `> /dev/null`), O1, F4 y G1 |
| `10`/`11` | banco completo | **2850/0/12** (2862) |
| `12` | inventario frente a v1.36.0 | fuera de la 48: REQ-017 CA-08 (ii) 200 líneas SKIP → PASS (reloj) y sorteo; ningún allow → deny |
| `10`, caso PROC | procesos candidata/v1.36.0 | `ls -la` 1/1, `npm run build` 1/1 (0 añadidos); F3 3/3; H3 4/3 (≤ 1) |
| `41` | reloj CA-12 (c) | 0,995×, 1,034×, 1,023× |
| `50` / `60` | autoprueba / gates | 117/0 / rc 0, versión 1.36.1 |

X5 (`find … -exec`) y P1 (`\cp`) dan `allow` en v1.36.0 y en la candidata (igualdad; familia de F-137-14).
