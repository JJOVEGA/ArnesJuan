#!/usr/bin/env bash
set -u
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066
. <(sed -n '/^C=/,/^W=/p' $R/sondas.sh)
echo "## E1 (SEC-133): gate que lee su entrada estandar, con una roja detras"
mk $W/e1 '["cat >/dev/null", "false"]'; herr $W/e1; echo "  registro rc: $(jq -c '[.gates[].rc]' $W/e1/.arnes/gates-veredicto.json)"
echo "  cand: $(cierra $C $W/e1)"; echo "  base: $(cierra $B $W/e1)"
echo "## S11 sin quality_gates (control, sin registro)"
mk $W/s11 '[]'; echo "  cand: $(cierra $C $W/s11)"; echo "  base: $(cierra $B $W/s11)"
