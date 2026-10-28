# REQ-037 — evidencia de QA (qa-tester, modelo efectivo Opus `claude-opus-5-5`), 2026-10-27, cabeza d47cfba
Informe: `docs/qa/REQ-037.md` del worktree `ArnesJuan-1.36.3`. Scripts en `bin/` (rq.sh: un cierre a nivel de hook;
bucle.sh / traza.sh / dobles.sh / cuelgue.sh: bucles; carga.sh: carga sintética en su propio grupo; ca02f.sh; ca08.sh).
| Archivo | Qué |
|---|---|
| 40-banco-completo.txt | banco completo, una vez: 2985/7/30, 311 s |
| 41- a 44- | diagnóstico de causa de los FAIL de reloj: con y sin la sección 53, y la 37-5 con los hooks de v1.36.2 |
| 02f-corrida-N420.txt | CA-02 (f): N = 420 s, gate `sleep 1000`, deny de gates a 420 241 ms |
| 08-v1.35.0.*, 08-v1.36.0.* | CA-08 con `claude -p`: meta, vigía, stream-json, registro de depuración |
| 09-* | el cliente y dos documentos JSON en la salida de un hook (doble: no aplica el deny; control: sí) |
| 10-* | QA-037-01: cierres bajo carga, candidata frente a v1.36.2 |
| 11-, 12- | vectores de integridad y señales; terminal de control |
| 21-, 22- | la carrera en reposo; bash < 5.1 simulado |
| 30-, 31- | gates de §7, CA-10/CA-11; autoprueba |
| tr1/, cu1/ | la traza del deny espurio (EXITRC de un hijo) y las salidas de la caza del cuelgue |
