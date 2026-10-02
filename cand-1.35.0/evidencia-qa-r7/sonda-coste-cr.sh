#!/usr/bin/env bash
# Sonda de coste: un campo grande con UN retorno de carro (file_path, tool_name, cwd), de punta a punta por
# guard.sh, candidato frente a cd6afa6 (y 9596e39 / 1.33.2 como referencia). Mide el reloj con timeout 120 s
# para ver el tiempo real aunque pase de 60 s (el cliente mata el hook a los 60 s: un hook muerto no deniega).
# Una corrida por celda, alternando árboles; se registran todas.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r7/qa-lib-r7.sh
PRJ=$Q/proj-coste; rm -rf "$PRJ"; mkproj "$PRJ"
mide() {   # <hooksdir> <json> -> T (ms), D
  local out t0 t1
  t0=$(date +%s%N)
  out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$PRJ" timeout 120 bash "$1/guard.sh" 2>/dev/null)"; RC=$?
  t1=$(date +%s%N); T=$(( (t1 - t0) / 1000000 ))
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  [ "$RC" -ne 124 ] || D=TIMEOUT120
}
echo "== Sonda de coste del CR en campos grandes ($(date -Iseconds)); $(uname -r); bash ${BASH_VERSION}; $(jq --version) =="
echo "   campo | N bytes de relleno | árbol | ms | decisión"
for N in ${TAMANOS:-20000 50000 100000 150000}; do
  rel="$(head -c "$N" /dev/zero | tr '\0' a)"
  for campo in fp fp-sin-cr tool cwd; do
    case "$campo" in
      fp)        J="$(j Write "$PRJ" - "file_path=$PRJ/src/$rel$CR" content=x)" ;;
      fp-sin-cr) J="$(j Write "$PRJ" - "file_path=$PRJ/src/$rel" content=x)" ;;
      tool)      J="$(j "Write$rel$CR" "$PRJ" - "file_path=$PRJ/src/a.ts" content=x)" ;;
      cwd)       J="$(j Bash "/tmp/$rel$CR" - 'command=echo x > src/a.ts')" ;;
    esac
    for k in CAND CD6; do mide "${!k}" "$J"; printf '   %-9s | %7d | %-4s | %6d | %s\n' "$campo" "$N" "$k" "$T" "$D"; done
  done
done
