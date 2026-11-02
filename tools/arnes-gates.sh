#!/usr/bin/env bash
# arnes-gates.sh — corre las quality gates del manifiesto FUERA del hook y deja su veredicto ligado al hash del
# árbol (REQ-037, ADR-019; issue #63, F-137-24). La puerta de cierre (`guard-completado`) ya no ejecuta gates:
# comprueba el registro que deja esta herramienta.
#
# Uso:  bash tools/arnes-gates.sh --quien <quien las corre> [--proyecto <dir>]
#   --quien     obligatorio: quién la corre (qa-tester, coordinadora, propietario...). Texto declarado, NO
#               verificado (REQ-037 CA-05, riesgo declarado).
#   --proyecto  la raíz del proyecto; por defecto CLAUDE_PROJECT_DIR, y si no, el directorio actual.
# Sale 0 si TODAS las gates salieron 0 y el árbol no cambió durante la corrida; 1 si una gate no salió 0 (se
# detiene en ella); 2 si no pudo medir (sin git, manifiesto ilegible, sin gates, el árbol cambió mientras
# corrían, o no pudo escribir el registro).
#
# LO QUE HACE (REQ-037 CA-02):
#   * retira el registro anterior AL EMPEZAR: una corrida cortada (kill, el límite del cliente) no deja un
#     veredicto, ni el viejo ni uno a medias;
#   * lee las gates del manifiesto con la misma expresión que la puerta, y las corre EN SERIE, en su orden, desde
#     la raíz, con la entrada estándar desde /dev/null y su salida a un archivo (no a una tubería: un proceso que
#     sobreviva a una gate no retiene la herramienta). Se detiene en la primera roja;
#   * el veredicto de una gate es SÓLO su código de salida, observado aquí (L4, L5): lo que la gate imprime, hereda
#     o escribe no entra. La lista no viaja por la entrada estándar de nadie (SEC-133, cerrado por construcción);
#   * calcula el hash del árbol ANTES y DESPUÉS con la misma función que la puerta (`arnes_hash_arbol`,
#     hooks/lib.sh): si difieren, no escribe nada y sale 2;
#   * escribe el registro AL FINAL y de forma atómica (temporal en el mismo directorio y renombrado).
# LO QUE NO HACE: no corre en el hook ni pasa por él; una suite de más de 10 min se lanza en segundo plano o la
# corre el propietario desde su terminal (REQ-037 CA-07). SEC-131 (a) sigue: corre en el entorno del shell que la
# lanza, y una función importada con el nombre de la orden de una gate la suplanta.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"; [ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/../hooks/lib.sh"

uso() { printf 'Uso: bash %s --quien <quien las corre> [--proyecto <dir>]\n' "$0" >&2; }
falla() { printf 'arnes-gates: %s\n' "$1" >&2; exit 2; }

quien=''; proj="${CLAUDE_PROJECT_DIR:-$PWD}"
while [ $# -gt 0 ]; do
  case "$1" in
    --quien) [ $# -ge 2 ] || { uso; exit 2; }; quien="$2"; shift 2 ;;
    --proyecto) [ $# -ge 2 ] || { uso; exit 2; }; proj="$2"; shift 2 ;;
    -h|--help) uso; exit 0 ;;
    *) uso; falla "argumento desconocido: $1" ;;
  esac
done
[[ $quien == *[![:space:]]* ]] || { uso; falla "--quien es obligatorio y no puede ir vacio"; }
proj="${proj%/}"; [ -n "$proj" ] || proj=/
[ -d "$proj" ] || falla "no existe el directorio del proyecto: $proj"
manif="$proj/.arnes/config.json"
reg="$proj/$ARNES_VEREDICTO_REL"
tmp_reg="$reg.$BASHPID.tmp"
sal=''
limpia() { rm -f -- "$tmp_reg" ${sal:+"$sal"} 2>/dev/null; return 0; }
trap limpia EXIT

# (iii) El registro anterior se retira AL EMPEZAR.
if [ -e "$reg" ] || [ -L "$reg" ]; then
  rm -f -- "$reg" 2>/dev/null
  { [ -e "$reg" ] || [ -L "$reg" ]; } && falla "no pude retirar el registro anterior ($reg)"
fi

[ -f "$manif" ] && [ -r "$manif" ] || falla "no encuentro el manifiesto legible ($manif)"
# La MISMA expresión que la puerta (guard-completado, Gate A3): las mismas gates, en el mismo orden.
lista="$(jq -r '.quality_gates[]? | if type=="object" then (.comando // empty) else . end' "$manif" 2>/dev/null)" \
  || falla "no pude leer las quality gates del manifiesto ($manif)"
gates=()
while IFS= read -r g; do [ -n "$g" ] && gates+=("$g"); done <<< "$lista"
(( ${#gates[@]} > 0 )) || falla "el manifiesto no tiene quality_gates: no hay nada que correr ni veredicto que escribir"

arnes_hash_arbol "$proj" || falla "no puedo medir el arbol: $ARNES_HASH_MOTIVO"
antes="$ARNES_HASH"

sal="$(mktemp 2>/dev/null)" || falla "no pude crear el archivo de salida de las gates"
printf 'arnes-gates: %d gate(s) en %s (quien: %s)\n' "${#gates[@]}" "$proj" "$quien"
rcs=(); mss=(); roja=''
for ((i = 0; i < ${#gates[@]}; i++)); do
  if [ -n "$roja" ]; then rcs+=(null); mss+=(null); continue; fi
  t0=${EPOCHREALTIME//[!0-9]/}
  ( cd "$proj" && eval "${gates[i]}" ) </dev/null >"$sal" 2>&1
  rc=$?
  ms=$(( (${EPOCHREALTIME//[!0-9]/} - t0) / 1000 ))
  rcs+=("$rc"); mss+=("$ms")
  printf '  [rc %3d] %8d ms  %s\n' "$rc" "$ms" "${gates[i]}"
  if [ "$rc" -ne 0 ]; then
    roja="${gates[i]}"
    printf '  ultimas lineas de su salida:\n%s\n' "$(tail -c 600 "$sal" 2>/dev/null)"
  fi
done

arnes_hash_arbol "$proj" || falla "no puedo medir el arbol despues de las gates: $ARNES_HASH_MOTIVO"
[ "$ARNES_HASH" = "$antes" ] || falla "el arbol cambio mientras corrian las gates (una gate, u otra persona, escribio en el): no se escribe veredicto; vuelve a correrlas con el arbol quieto"

# El registro, al final y atómico. Sus campos son exactamente los que la puerta exige (lib.sh).
fecha="$(TZ=UTC0 printf '%(%Y-%m-%dT%H:%M:%SZ)T' -1)"
jsg="$(for ((i = 0; i < ${#gates[@]}; i++)); do printf '%s\0%s\0%s\0' "${gates[i]}" "${rcs[i]}" "${mss[i]}"; done \
  | jq -Rs 'split("\u0000") | .[:-1] | [range(0; length; 3) as $i | {comando: .[$i], rc: (.[$i+1] | fromjson), ms: (.[$i+2] | fromjson)}]')" \
  || falla "no pude formar la lista de gates del registro"
jq -n --argjson fmt "$ARNES_VEREDICTO_FORMATO" --arg arbol "$ARNES_ARBOL_DEF" --arg hash "$antes" \
  --argjson gates "$jsg" --arg fecha "$fecha" --arg quien "$quien" \
  '{formato: $fmt, arbol: $arbol, hash: $hash, gates: $gates, fecha: $fecha, quien: $quien}' > "$tmp_reg" 2>/dev/null \
  && mv -f -- "$tmp_reg" "$reg" 2>/dev/null || falla "no pude escribir el registro ($reg)"

if [ -n "$roja" ]; then
  printf 'arnes-gates: ROJO: la gate `%s` no salio 0; las siguientes no se corrieron. Registro: %s\n' "$roja" "$reg"
  exit 1
fi
printf 'arnes-gates: VERDE: todas las gates salieron 0 sobre el arbol %s. Registro: %s\n' "$antes" "$reg"
exit 0
