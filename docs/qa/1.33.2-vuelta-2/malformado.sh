#!/usr/bin/env bash
# SEC-087: el parentesis MAL FORMADO. Dos preguntas, las dos por conducta de puerta:
#  (1) ¿se juzgan `estandar` en un REQ no sensible las tres formas que el contrato NOMBRA?
#  (2) ¿es cierto que esa es la UNICA proteccion que la forma puede perder? Para eso hay
#      que barrer los TRES niveles x sensibilidad, y comparar con lo que el matiz CERRADO
#      del mismo nivel habria dado. Se pierde proteccion solo si mal-formado < cerrado.
# La terna de firmas identifica el nivel (ver puerta.sh).
set -u
HOOKS="${1:-/home/juan/dev/ArnesJuan-1.33.2/hooks}"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
PROJ="$RAIZ/p"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'CFG'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
CFG
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"
n=0
intenta() { n=$((n+1)); local f="$PROJ/requirements/R$n.md"
  { printf '# R%s\nEstado: en-revisión\nSensible a seguridad: %s\nQA: %s\nSeguridad: %s\n' "$n" "$2" "$3" "$4"
    [ -n "$1" ] && printf 'Rigor: %s\n' "$1"; } > "$f"
  local j o; j="$(jq -n --arg fp "$f" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
  o="$(printf '%s' "$j" | "$HOOKS/guard-completado.sh" 2>/dev/null)"
  printf '%s' "$o" | grep -Eq '"permissionDecision": *"deny"' && echo deny || echo allow; }
nivel() { local t; t="$(intenta "$1" "$2" pendiente pendiente) $(intenta "$1" "$2" aprobado pendiente) $(intenta "$1" "$2" aprobado aprobado)"
  case "$t" in "allow allow allow") echo ligero ;; "deny allow allow") echo estandar ;;
               "deny deny allow") echo critico ;; *) echo "ANOMALO($t)" ;; esac; }
rank(){ case "$1" in ligero) echo 1;; estandar) echo 2;; critico) echo 3;; *) echo -1;; esac; }

echo "(1) LAS TRES FORMAS QUE EL CONTRATO NOMBRA, en un REQ no sensible"
for f in "critico (por suelo" "critico (" "critico (x) y"; do
  r="$(nivel "$f" no)"; printf '  %-24s -> %-9s %s\n' "$f" "$r" \
    "$([ "$r" = estandar ] && echo 'OK: el contrato dice estandar' || echo '<<< EL CONTRATO DICE estandar')"
done

echo
echo "(2) ¿ES LA UNICA PROTECCION QUE SE PIERDE? — tres niveles x dos sensibilidades,"
echo "    cada forma mal formada CONTRA el matiz cerrado del mismo nivel."
printf '    %-26s %-5s %-9s %-9s %s\n' FORMA_MAL_FORMADA SENS MALFORM CERRADO VEREDICTO
perdidas=0
for niv in ligero estandar critico; do
  for s in no sí; do
    for suf in " (x" " (" " (x) y" "(" " ((x)"; do
      mal="$niv$suf"; cer="$niv (x)"
      rm="$(nivel "$mal" "$s")"; rc="$(nivel "$cer" "$s")"
      v=OK; if [ "$(rank "$rm")" -lt "$(rank "$rc")" ]; then v="<<< PIERDE PROTECCION"; perdidas=$((perdidas+1)); fi
      printf '    %-26s %-5s %-9s %-9s %s\n' "$mal" "$s" "$rm" "$rc" "$v"
    done
  done
done
echo "    --- formas que PIERDEN proteccion: $perdidas ---"

echo
echo "(3) LA PROMESA ABSOLUTA: ¿alguna forma con '(' alcanza 'ligero' (el nivel exento)?"
alcanza=0
for f in "ligero (x" "ligero (" "ligero (x) y" "ligero(" "ligero ((x)" "ligero (x)" "ligero()" \
         "(ligero)" "(ligero" "ligero )" "**ligero (x**" "ligero (ligero)" "ligero ( ligero )" \
         "ligero (x) (y" "ligero (()" "ligero )(" "ligero ()()" "ligero (ligero" ; do
  r="$(nivel "$f" no)"
  [ "$r" = ligero ] && { alcanza=$((alcanza+1)); printf '    %-22s -> %-9s <<< ALCANZA ligero\n' "$f" "$r"; } \
                    || printf '    %-22s -> %s\n' "$f" "$r"
done
echo "    --- formas con '(' que alcanzan 'ligero': $alcanza (esperado 0) ---"
echo
echo "invocaciones de puerta: $n"
