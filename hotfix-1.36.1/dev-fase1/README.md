# Hotfix 1.36.1 — fase 1 (desarrollador): REQ-032, evidencia

Árbol medido: `hotfix/1.36.1` en `e3e1e02` **con los cambios de la fase 1 sin commit** (los commits del
repositorio del arnés los hace la coordinadora); sha256 de los tres hooks tocados en `00-entorno.txt`.
Línea base: los hooks de `v1.36.0` (`f22b905`), la instalación estable, idéntica a `git archive v1.36.0 hooks`.
Plataforma: Linux/WSL2, bash 5.3.9, jq 1.8.2. Windows/MSYS y el host: **sin medir**.

## Qué se cambió
- `hooks/lib.sh`, rama `cp|mv|install` del detector: la forma `destino/` sale **marcada** (un tabulador
  delante; ningún destino del detector lleva uno). Con `-t`/`--target-directory` (también `-vt`), sin marca.
- `hooks/lib.sh`, `arnes_destino_a_juzgar`: la forma marcada **no se juzga** sólo si el destino, por la
  identidad de REQ-007 CA-47, existe y es archivo regular (un enlace ya resuelto cuenta como su archivo).
- `hooks/guard-codigo.sh` y `hooks/guard-completado.sh`: su bucle de destinos de `Bash` la llama.
- `arnes_deny_manifiesto_roto`: sólo retira la marca; juzga como en v1.36.0 (CA-10, registrado).

## Resultados
| Archivo | Qué | Resultado |
|---|---|---|
| `10` / `11` | banco ANTES: pruebas de v1.36.0 con hooks de v1.36.0 | 2303 PASS, 0 FAIL, 13 SKIP (2316) |
| `20` | sección 48 sobre la candidata | 254 PASS, 0 FAIL |
| `21` | sección 48 con los hooks de v1.36.0 como candidata (fail-before) | 226 PASS, **28 FAIL**: F1–F4, F6–F8 × cp/mv/install (21), G1 × 3 × 2 agentes (6) y el oráculo O1 |
| `12` | banco DESPUÉS, corrida 1, **con carga concurrente del desarrollador** (`32-observaciones.sh` corriendo a la vez) | 2552/**4**/14: los 4 son de reloj (REQ-017 CA-08 (ii) 6 líneas; calibración de `sonda-reloj.sh` y los dos casos de REQ-021 CA-10 que dependen de ella) |
| `13` | corrida 2, sin carga | 2556/0/14 |
| `14` | corrida 3 (final, tras normalizar la ruta del caso P1) | 2558/**1**/11: REQ-017 CA-08 (ii) «un REQ real de 6 líneas», 1,263×–1,300× contra v1.32.1, techo 1,25× |
| `17-diff-inv-antes-final.txt` | inventario antes/final | fuera de la sección 48: los dos casos de reloj de REQ-017 CA-08 (ii) (SKIP INCONCLUSO → FAIL y → PASS) y dos líneas de sorteo (semilla de la 41; longitud de una ruta temporal). Ningún caso de decisión de una puerta cambia |
| `41` | CA-12 (c), reloj candidata/v1.36.0 en la misma corrida (k=10, r=6, intercalado) | `ls -la` 0,880×; `npm run build` 0,995×; F3 0,876× (techo 1,25×) |
| `20`, caso P1 | CA-12 (a)(b), procesos (sonda de procesos) candidata/v1.36.0 | `ls -la` 1/1, `npm run build` 1/1, F3 2/3: **0 añadidos** |
| `43` | el sujeto del FAIL de `14`, cabeza a cabeza candidata/v1.36.0 (procedimiento de 37/5) | 0,970×, 0,900×, 0,954×, 0,888×, 0,960× |
| `44`, `45` | la sección 37/5 con v1.36.0 como candidata y con la candidata, dos veces cada una | v1.36.0: [1,206×, 1,274×] y [1,190×, 1,517×]; candidata: [1,233×, 1,305×] y [1,229×, 1,380×] — las dos recorren el techo |
| `50` | autoprueba del corredor | 117 PASS, 0 FAIL |
| `60` | quality gates de `AGENTS.md` §7 | las tres rc 0; versiones 1.36.1 |
| `31` | matriz a mano, cp/mv/install, los dos árboles | la de CA-02/CA-03 (a); `mv` e `install` comparten la causa |
| `33` | formas vecinas (observaciones) | ver abajo |

**El FAIL de `14` no se ha clasificado aquí ni se desmiente repitiendo.** Queda escrito con lo medido alrededor
(`43`, `44`, `45`); su clasificación es de QA y de la coordinadora.

## Observaciones (`33`), medidas y sin reparar
Movimientos de la clase M-032 **por la letra** —el destino que identifica CA-47 existe, es archivo regular y no
está protegido, y `cat S > D` decide igual— cuyo **efecto** alcanza algo protegido por límites preexistentes:
- `mv src/a.ts docs/notas.md`: candidata `allow`, v1.36.0 `deny`. Borra el origen protegido; los orígenes de `mv`
  nunca se juzgaron, y `mv src/a.ts docs/nuevo.md` ya era `allow` en v1.36.0.
- `cd src && cp S a.ts` con `<raíz>/a.ts` existente: candidata `allow`, v1.36.0 `deny`; `cd src && cat S > a.ts`
  ya era `allow`. El `cd` dentro del comando está sin promesa en CA-47.
- `cp S $X` con un archivo llamado literalmente `$X`: candidata `allow`, v1.36.0 `deny`; `cat S > $X` ya era
  `allow` (expansiones, `AGENTS.md` §13).
- `cp -t src docs/notas.md` sigue `deny`/`deny`: la forma de directorio de un `-t` no se marca (lectura de
  CA-10 y CA-08; sin ella, `allow` escribiendo en `src/`).
