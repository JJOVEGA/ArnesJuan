# CI `hooks-en-linux` sobre `main` desde v1.34.0 (leído con `gh run view --log`, 2026-09-29; sin relanzar nada)

| Merge | PR | Run | Conclusión | Resultado |
|---|---|---|---|---|
| `cc8972c` (tag v1.34.0) | #51 | 35160309648 | success | (publicación 1.34.0) |
| `cfb1106` REQ-025 entrega 1 | #52 | 35742539672 | **failure** | 903 PASS · **2 FAIL** · 7 SKIP — REQ-017 CA-03 (cociente 2.747× > techo 2.600×) y REQ-017 CA-08 (ii) (1.255× > 1.250×, la sonda sí convergió). Integración autorizada por el propietario el 2026-09-22 con la limitación de REQ-017 CA-08 (ii) declarada en el PR |
| `c4d92c0` REQ-030 | #55 | 36343388823 | success | 904 PASS · 0 FAIL · 16 SKIP (1 INCONCLUSO rendimiento: REQ-017 CA-03) |
| `11c5df2` REQ-029 | #53 | 36358331427 | success | 905 PASS · 0 FAIL · 15 SKIP (1 INCONCLUSO rendimiento: REQ-017 CA-03) |
| `a7a60c2` cierre REQ-029/030 | #56 | 36359910761 | success | 903 PASS · 0 FAIL · 17 SKIP (2 INCONCLUSO rendimiento: REQ-017 CA-03 y CA-08 (ii)) |
| `713ac68` REQ-031 | #58 | 36573224349 | success | 963 PASS · 0 FAIL · 17 SKIP (2 INCONCLUSO rendimiento: REQ-017 CA-03 y CA-08 (ii)); autoprueba 117 · 0 |

Un INCONCLUSO no pone el banco en rojo y un check verde no lo acredita (REQ-030). Ninguna corrida acredita rendimiento, conducta ni ahorro.
