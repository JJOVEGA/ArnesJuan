# t8 — Registro previo de la comprobación puntual de coste (R-047), escrito ANTES de ejecutar

- Qué: confirmación independiente de QA-023-14 (no sustituye la medición de QA, `evidencia-qa-r8/31-`).
- Cómo: `Write` con `file_path` = `<raíz>/docs/` + N bytes de `a` + un CR final, por `hooks/guard.sh`, coordinadora,
  `timeout 120`, una sola corrida por celda, sin repetir. Y `Bash` (`ls`) con `tool_input.file_path` igual.
- Tamaños: 200 000 bytes (el que usé en R-046, `s5-coste-cr.txt`: 10,3 s y 11,6 s en `3bc7d3c`).
- Árboles: candidato (`57129fb`, hooks `f7d6ae7`) y `3bc7d3c`.
- Criterio: no hay umbral. Se anota la cifra tal como salga; un resultado desfavorable se registra igual.
