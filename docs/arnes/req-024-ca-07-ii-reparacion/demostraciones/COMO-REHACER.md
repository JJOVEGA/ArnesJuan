# Cómo se rehace cada demostración, comando por comando

Todo desde `/home/juan/dev/ArnesJuan-1.34-reparaciones` (rama `feat/1.34-reparaciones-astra`,
commit `69fc96a`). `SEC=40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh`.

## D1 · control sin regresión → PASS  (`d1-control-acreditacion.txt`)

```bash
ARNES_COSTE_RUTA_CRITICA=1 bash tests/escenarios/hooks/run.sh "$SEC"
```

## El envoltorio de contención (reproduce la FORMA del runner: 4 CPU, 6 vecinos)

No iguala al runner —está medido que no predicen lo mismo, `docs/arnes/ci-1.34.0-no-discrimina/`—;
reproduce la propiedad que ensancha la dispersión: más procesos listos que CPU disponibles.

```bash
cat > /tmp/con.sh <<'SH'
#!/usr/bin/env bash
set -uo pipefail
P=()
for ((i=0;i<6;i++)); do taskset -c 0-3 bash -c 'while :; do :; done' >/dev/null 2>&1 & P+=($!); done
trap 'for p in "${P[@]}"; do kill -9 "$p" 2>/dev/null || :; done' EXIT
sleep 1
taskset -c 0-3 "$@"
rc=$?
for p in "${P[@]}"; do kill -9 "$p" 2>/dev/null || :; done
exit $rc
SH
chmod +x /tmp/con.sh
```

## D2 · regresión deliberada EN UNA COPIA → FAIL  (`d2*.txt`)

El árbol **no se toca**. Se copia `hooks/` y se inyecta un coste que sólo quema reloj:

```bash
cp -r hooks /tmp/hooks-enfermos
# tras el shebang de /tmp/hooks-enfermos/guard-completado.sh:
#   for ((_arnes_reg_sintetica = 0; _arnes_reg_sintetica < N; _arnes_reg_sintetica++)); do :; done
# N = 5000  -> ~1,7×  (regresión modesta, la que importa)
# N = 40000 -> ~5,4×  (regresión grande)
```

- Modesta, a los parámetros **de la puerta** y bajo contención → `d2b-regresion-modesta-puerta.txt`:

```bash
ARNES_HOOKS_DIR=/tmp/hooks-enfermos /tmp/con.sh bash tests/escenarios/hooks/run.sh "$SEC"
```

- Grande, en modo acreditación → `d2-regresion-real-en-copia.txt`:

```bash
ARNES_COSTE_RUTA_CRITICA=1 ARNES_HOOKS_DIR=/tmp/hooks-enfermos bash tests/escenarios/hooks/run.sh "$SEC"
```

## D3 · condiciones insuficientes → SKIP  (`d3-dispersion-puerta.txt`)

Sin regresión ninguna, a los parámetros de la puerta y bajo contención. **Es estocástica por
definición**: puede salir `PASS` si el host coopera. Lo que **nunca** debe salir es `FAIL` sin
regresión, y lo que el `SKIP` tiene que traer es el recorrido y la vía de acreditación.

```bash
/tmp/con.sh bash tests/escenarios/hooks/run.sh "$SEC"
```

## D4 · el entorno del CI

No se puede rehacer aquí. La evidencia llega por la corrida de `hooks-en-linux`; qué esperar
exactamente está en `../02-reparacion-y-demostraciones.md` § «4 · Evidencia en el entorno del CI».

## Coste que añade la guarda

Sección sola, mínimo de 3 vueltas, comparando el archivo tal cual contra una copia con
`KRAZ07=1` (lo que el caso hacía antes de la reparación):

```bash
for m in copia-KRAZ1 seccion-real; do time ARNES_SECCIONES_DIR=<dir> bash tests/escenarios/hooks/run.sh; done
```

Medido: 3,95 s (KRAZ07=1) → 5,82 s (KRAZ07=4) = **+1,87 s = 0,473×**.
