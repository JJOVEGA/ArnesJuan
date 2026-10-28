# REQ-037 (hotfix 1.36.3), fase 2: lo que midió el desarrollador

**Fecha:** 2026-10-27. **Quién:** `desarrollador` (Opus). **Árbol:** worktree `ArnesJuan-1.36.3`, rama `hotfix/1.36.3`,
cabeza `22a60d4` más los cambios sin comitear de esta fase (los comitea la coordinadora). **Máquina:** Linux/WSL2,
bash 5.3.9, 12 núcleos, 31 GB. **Línea base:** `v1.36.2` = `46ee7ca`; la sección 53 la materializa ella misma por SHA
(`mat53`) y, para las pruebas sueltas, con `git archive v1.36.2 hooks`.

| Archivo | Qué es | Resultado |
|---|---|---|
| `rp.sh` | arnés a nivel de hook (el de `repro.sh`, con la lista de gates en JSON y `env` opcional) | — |
| `10-seccion53-candidata.txt` | la sección 53 sola, sobre la candidata | 60 PASS, 0 FAIL, 2 SKIP (reloj del camino común bajo el suelo de 50 ms); 46,9 s |
| `11-seccion53-failbefore-v1.36.2.txt` | la sección 53 con los hooks de v1.36.2 como candidata (`ARNES_HOOKS_DIR`) | 11 FAIL: G1, A2, G2, M y las siete filas cuya copia exige el presupuesto (G3, G4, P1, P2, P3, P4, P6); los controles PASS |
| `20-sec133-sec131a.txt` | SEC-133 y SEC-131 (a) en sus formas medidas | mismo veredicto en v1.36.2 y en la candidata |
| `21-carrera-wait-n.txt` | dos defectos de la primera versión, hallados y cerrados antes de entregar, y un incidente propio | — |
| `30-gates.txt`, `31-autoprueba.txt` | quality gates de `AGENTS.md` §7 y autoprueba | rc 0; 117/0; `hooks.json` idéntico a v1.36.2 |
| `40-banco-completo.txt` | el banco completo, una vez, sobre el árbol final | 2985 PASS, 4 FAIL, 33 SKIP, cuadre 3022; 222,8 s. Los 4 FAIL son sondas de **reloj** de otras secciones (REQ-017 CA-08 (ii) y REQ-033 CA-06 ×3); no se repitió |
| `50-barrido-60s.txt`, `clasifica.awk` | el barrido de CA-07, clasificado línea a línea | 367 resultados, 0 sin clasificar |

Una primera corrida del banco completo, sobre una versión que todavía tenía el defecto de `setsid` (`21-`, §2), se
detuvo a mano y se descartó: no es evidencia.
