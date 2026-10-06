#!/usr/bin/env bash
# 32-modo-barrido.sh <hooksdir> <salida> — CA-68 (ii): estado del INTÉRPRETE heredado del entorno, más allá de las
# formas de R-054 §3. Cada entrada de la lista se exporta en el entorno del hook (por `env`, como el cliente) y se
# comparan los 10 vectores de 30-entorno-barrido.sh por guard.sh con la base sin ella. Imprime la base y una línea
# por (entrada, vector) que difiere en decisión, rc o comienzo del motivo.
set -u
QD="$(cd "$(dirname "$0")" && pwd)"; HD="$1"; OUT="$2"
W="${TMPDIR:-/tmp}/qa6-modo-$$"; mkdir -p "$W"; . "$QD/h.sh"; P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"; in_edit src/a.ts 'orig' 'nuevo' > "$W/v2"; in_bash 'echo x > src/a.ts' > "$W/v3"
in_bash 'git reset --hard' > "$W/v4"
in_write requirements/REQ-900.md "$(printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n')" > "$W/v5"
in_bash "sed -i 's/en-revisión/completado/' requirements/REQ-900.md" > "$W/v6"; in_write src/a.ts 'x' desarrollador > "$W/v7"
in_bash 'ls -la' > "$W/v8"; in_edit requirements/REQ-900.md 'QA: pendiente' 'QA: quizas' > "$W/v9"
jq -cn --arg c "$P/no-existe" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > src/a.ts"}}' > "$W/v10"
VECS="v1 v2 v3 v4 v5 v6 v7 v8 v9 v10"
fp() { local r; r="$(corre "$HD" guard.sh "$W/$1" "${@:2}")"; IFS='|' read -r d rc ms b m <<< "$r"; printf '%s|%s|%s' "$d" "$rc" "${m:0:50}"; }
ENTRADAS=()
for o in allexport braceexpand emacs errexit errtrace functrace hashall histexpand history ignoreeof interactive-comments keyword monitor noclobber noexec noglob nolog notify nounset onecmd physical pipefail privileged verbose vi xtrace; do ENTRADAS+=("SHELLOPTS=$o"); done
for o in array_expand_once assoc_expand_once autocd bash_source_fullpath cdable_vars cdspell checkhash checkjobs checkwinsize cmdhist compat31 compat32 compat40 compat41 compat42 compat43 compat44 complete_fullquote direxpand dirspell dotglob execfail expand_aliases extdebug extglob extquote failglob force_fignore globasciiranges globskipdots globstar gnu_errfmt histappend histreedit histverify hostcomplete huponexit inherit_errexit interactive_comments lastpipe lithist localvar_inherit localvar_unset mailwarn no_empty_cmd_completion nocaseglob nocasematch noexpand_translation nullglob patsub_replacement progcomp progcomp_alias promptvars shift_verbose sourcepath varredir_close xpg_echo; do ENTRADAS+=("BASHOPTS=$o"); done
for c in 31 32 40 41 42 43 44 50 51 52; do ENTRADAS+=("BASH_COMPAT=$c"); done
for n in 1 2 3 5 8 13 21; do ENTRADAS+=("FUNCNEST=$n"); done
ENTRADAS+=("GLOBIGNORE=*" "GLOBSORT=-name" "GLOBSORT=nosort" "CDPATH=/" "CDPATH=/tmp" "TMPDIR=/no/existe" "HOME=/no/existe" "EXECIGNORE=*" "TIMEFORMAT=x" "BASH_XTRACEFD=1" "PS4=x")
ENTRADAS+=("SHELLOPTS=xtrace BASH_XTRACEFD=1" "SHELLOPTS=verbose BASH_XTRACEFD=1")
for f in jq grep mktemp cksum git sed cat rm printf read cd source command type mv cp tr head wc date env timeout; do ENTRADAS+=("BASH_FUNC_${f}%%=() { :; }"); done
declare -A BASE
{ echo "# base, hooks=$HD, $(date -Is), bash $BASH_VERSION"; for v in $VECS; do BASE[$v]="$(fp $v)"; echo "BASE $v ${BASE[$v]}"; done; } > "$OUT"
n=0; nd=0
for e in "${ENTRADAS[@]}"; do
  read -r -a kv <<< "$e"; case "$e" in BASH_FUNC_*) kv=("$e") ;; esac
  for v in $VECS; do
    n=$((n+1)); r="$(fp $v "${kv[@]}")"
    [ "$r" = "${BASE[$v]}" ] || { nd=$((nd+1)); echo "DIFIERE [$e] $v: base=[${BASE[$v]}] con=[$r]" >> "$OUT"; }
  done
done
echo "# fin $(date -Is): ${#ENTRADAS[@]} entradas, $n combinaciones, $nd diferencias" >> "$OUT"; rm -rf "$W"
