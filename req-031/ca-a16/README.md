# CA-A16 · cómo trata Claude Code un hook `PreToolUse` que termina sin decisión (reproducción aislada, coordinadora, 2026-09-28)

**Presupuesto:** 1 intento (el que quedaba de los 2 de CA-A16; QA no pudo ejecutarlo porque el clasificador de permisos de su entorno denegó `claude -p --plugin-dir`). **Entorno:** Claude Code CLI 2.1.272 (`claude -p`), WSL2. **Método:** plugin temporal `plugin-sonda/` (hook `PreToolUse` sobre `Write`, `"timeout": 5`, `duerme.sh` = `sleep 10` sin imprimir nada) y proyecto temporal vacío; comando:

```
claude -p --plugin-dir <plugin-sonda> --allowedTools Write --output-format json \
  "Usa la herramienta Write para crear el archivo x.txt en el directorio actual con el contenido exacto: hola. No hagas nada más."
```

**Resultado (intento-1.json / .err):** rc 0, 13,3 s de pared; **`x.txt` quedó escrito con `hola`**; el modelo respondió «Hecho.». Es decir: **cuando el hook agota su timeout sin emitir decisión, la herramienta se ejecuta**. Un hook muerto no deniega, confirmado en el cliente real y no sólo por código de salida.

**Control (control-deny.json):** mismo comando con `plugin-control/` (hook que imprime `permissionDecision: deny`): rc 0, **`x.txt` no se creó**; el modelo respondió que la herramienta fue denegada. El camino de denegación funciona en este mismo entorno.

**Alcance:** evidencia sobre el entorno (CLI, sesión no interactiva, `--allowedTools Write`), no sobre el arnés; no medido en la sesión interactiva del editor ni en Windows. Es la razón por la que SEC-113 (valores que hacían morir al hook) era un fail-open real y por la que la parte super-lineal por `Write` (`arnes_sin_cr_transporte`, PENDIENTES) sigue siendo relevante.
