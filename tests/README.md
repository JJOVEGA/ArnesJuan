# Tests del arnés

Validan los **agentes del arnés**, no la app de un proyecto. Sirven para no romper todos
los proyectos al subir una versión nueva del arnés.

## Regla
Nunca subas una versión nueva (tag semver) sin correr al menos un escenario por agente.

## Escenarios (`escenarios/`)
Cada escenario es un caso con: entrada conocida, qué agente la maneja, y salida esperada.
Empieza con uno minimo por agente y crece con cada fallo real encontrado en proyectos.

- analista — dada una necesidad vaga, produce un REQ con historia + Gherkin + estado.
- desarrollador — dado un REQ, implementa solo su alcance y deja quality gates en verde.
- qa — dado un REQ implementado, verifica criterios y reporta fallos reproducibles.
- seguridad — dado codigo con un secreto en cliente, lo detecta y veta.
- hooks — `escenarios/hooks/run.sh`: prueba en aislamiento los hooks de enforcement
  (A1 quién edita código, A2 aprobaciones pendientes, A3 quality gates). Ejecutable directo:
  `bash tests/escenarios/hooks/run.sh` (requiere `jq`). Todo caso nuevo se comprueba también
  contra los hooks anteriores (`ARNES_HOOKS_DIR=...`): si pasa antes del arreglo, no prueba nada.

## Como validar
Corre cada escenario en un proyecto de prueba y compara contra la salida esperada.
Documenta el resultado antes de versionar.
