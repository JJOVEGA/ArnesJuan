# hotfix-1.36.1/qa-pasada1 — re-verificación de QA de la pasada correctiva de REQ-032 (cabeza 264dfa9), 2026-10-15

- 00-entorno.txt — entorno, cabeza, árboles (v1.36.0 idéntica a f22b905; 759ff50 materializado), carga
- 60-gates.txt — gates de AGENTS.md §7 y versiones
- 20-/21-/22- — sección 48: candidata 406/0; 759ff50 como candidata 388/18 (H1–H3, fail-before del enlace duro); v1.36.0 como candidata 378/28
- 32-confirmacion.sh → 33- — las formas de QA-032-01 en proyectos limpios, ejecutadas de verdad (scripts de la fase 2, sin cambio)
- 30-ataques.sh → 31- — batería amplia de la fase 2 (82 casos)
- 34-llano.sh → 35- — comandos LLANOS cuyo último operando no es el destino (xargs): DEFECTO de la pasada
- 36-find.sh → 37- — (b) find ausente, que falla o vacío; 37a- es un intento DESCARTADO (PATH sin jq)
- 38-alcance-llano.sh → 39- — (e) alcance de la regla del comando llano
- 10-/12- banco completo (v1.36.0 como candidata 2681/29/12; candidata 2709/0/13); 11-/13- inventarios; 14- diff
- 50-autoprueba.txt — 117/0
- 41-reloj-ca08.sh → 42- — procedimiento de 9cd647b tal cual (no atribuible: P1 mediana 1,001)
- 43-reloj-ca12c.sh → 44- — CA-12 (c)
