#!/usr/bin/env bash
# corridas-qa5.sh — re-verificación acotada de SEC-132 (a): sección 47 y regresión corta, EN SERIE, una vez cada una
# (00-procedimiento.txt). Las sondas propias (10-, 13-) se corrieron antes, también en serie, y su salida está en 11*- y 13-.
set -u; E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118; Q=$E/qa5; S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; WT=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base; T=$S/q5t; export TMPDIR=$S
cd "$WT"
{ echo "# $(date -Is) cabeza $(git rev-parse --short HEAD)"; git status --short; sha256sum hooks/*.sh; echo "# frente a cd63066 (hooks tools tests):"; git diff --stat cd63066 HEAD -- hooks tools tests; echo "# frente a c5bf6d4:"; git diff --stat c5bf6d4 HEAD -- hooks tools tests; } > "$Q/19-arbol.txt"
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || echo "SINTAXIS $f"; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; jq -r .version .claude-plugin/plugin.json; jq -r '.plugins[]?.version // .version // empty' .claude-plugin/marketplace.json; } > "$Q/20-gates.txt" 2>&1
{ echo "# seccion 47 (selector), hooks=candidato, $(date -Is), carga $(cat /proc/loadavg)"; bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/47-decision-emitida.sh 2>&1; echo "rc=$?"; } > "$Q/01-seccion47-candidato.txt"
{ echo "# seccion 47 (selector), hooks=c5bf6d4 ($T/c5bf6d4/hooks), $(date -Is), carga $(cat /proc/loadavg)"; ARNES_HOOKS_DIR="$T/c5bf6d4/hooks" bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/47-decision-emitida.sh 2>&1; echo "rc=$?"; } > "$Q/02-seccion47-c5bf6d4.txt"
bash "$E/qa2/40-limpieza-ataque.sh" "$Q/03-limpieza-567.txt" candidato="$WT/hooks"
bash "$E/qa3/10-ataque-ampliado.sh" "$Q/04-ataque-ampliado-900.txt" candidato="$WT/hooks"
bash "$E/qa4/15-cuerpos-extra.sh" "$Q/05-cuerpos-extra.txt" candidato="$WT/hooks"
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$Q/21-autoprueba.txt" 2>&1
{ echo "# banco completo del worktree, ARNES_SEMILLA_41=23062, $(date -Is), carga $(cat /proc/loadavg)"; ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$Q/22-banco-candidato.txt"
bash tests/escenarios/hooks/inventario.sh "$Q/22-banco-candidato.txt" > "$Q/23-inventario-candidato.txt"
{ echo "# frente a sec132a/23- (desarrollador)"; diff "$E/sec132a/23-inventario-candidato.txt" "$Q/23-inventario-candidato.txt"; echo "# frente a qa4/23-"; diff "$E/qa4/23-inventario-candidato.txt" "$Q/23-inventario-candidato.txt"; } > "$Q/24-diff-inventario.txt"
(cd "$B" && { echo "# CA-69 2 (a): banco de v1.35.0 tal cual, ARNES_HOOKS_DIR=candidato, ARNES_SEMILLA_41=23062, $(date -Is), carga $(cat /proc/loadavg)"; ARNES_SEMILLA_41=23062 ARNES_HOOKS_DIR="$WT/hooks" bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$Q/25-banco-v1.35.0-con-candidato.txt"; bash tests/escenarios/hooks/inventario.sh "$Q/25-banco-v1.35.0-con-candidato.txt" > "$Q/26-inventario-v1.35.0-con-candidato.txt")
diff "$E/../ca54/22-inventario-v1.35.0.txt" "$Q/26-inventario-v1.35.0-con-candidato.txt" > "$Q/27-diff-2a.txt"
bash "$E/30-procesos.sh" "$WT" v1.35.0="$B/hooks" c5bf6d4="$T/c5bf6d4/hooks" candidato="$WT/hooks" > "$Q/28-procesos.txt" 2>&1
bash "$E/06-e1.sh" "$S" "$WT/tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh" 3 "$WT/hooks" "$B/hooks" > "$Q/29-e1.txt" 2>&1
bash "$E/20-tope.sh" "$S" "$WT/hooks" > "$Q/30-tope.txt" 2>&1
echo "# fin $(date -Is)" >> "$Q/19-arbol.txt"
echo fin
