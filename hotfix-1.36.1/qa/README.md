# hotfix-1.36.1/qa — QA fase 2 de REQ-032 (código 9e97bd7; rama en c5746f0)

Rehecho el 2026-10-15 tras la interrupción del 2026-10-14. Lo de `descartadas-interrupcion/` NO es evidencia.
Conservado del día 14 (comiteado antes de medir, 9cd647b): `00-entorno.txt`, `40-procedimiento-reloj.md`.

- 01-entorno-reanudacion.txt — entorno, cabeza, identidad de los hooks de v1.36.0, carga
- 60-gates.txt — quality gates de AGENTS.md §7 y versiones (CA-13)
- 20-/21- — sección 48 con la candidata (254/0) y con v1.36.0 como candidata (226/28: el fail-before)
- 30-ataques.sh → 31-ataques.txt — 82 casos de ruptura, dos árboles, con el efecto real ejecutado en una copia
- 32-confirmacion.sh → 33-confirmacion.txt — QA-032-01 en proyectos limpios, con la línea base de cada forma y F-137-13
- 10-/12- — banco completo: v1.36.0 como candidata (2528/28/14) y candidata (2557/0/13); 11-/13- inventarios; 14- diff
- 50-autoprueba.txt — 117/0
- 41-reloj-ca08.sh → 42-reloj-ca08.txt — atribución del FAIL de reloj REQ-017 CA-08 (ii), según 40- (no atribuible)
- 43-reloj-ca12c.sh → 44-reloj-ca12c.txt — REQ-032 CA-12 (c)
