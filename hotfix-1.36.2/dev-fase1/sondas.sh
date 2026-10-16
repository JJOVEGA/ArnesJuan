# Sondas ad hoc: cada línea de sondas.txt se entrega como COMANDO al hook (no se ejecuta nunca).
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
P=$S/pm; R=/home/juan/dev/ArnesJuan-v1.36
juzga() {   # <dir hooks> <agente|-> <comando>
  local j o
  j=$(jq -cn --arg c "$P" --arg a "$2" --arg k "$3" '{tool_name:"Bash",cwd:$c,tool_input:{command:$k}} + (if $a != "-" then {agent_id:"x",agent_type:$a} else {} end)')
  o=$(printf '%s' "$j" | CLAUDE_PROJECT_DIR=$P bash "$1/guard.sh" 2>/dev/null)
  case "$o" in *'"deny"'*) echo deny ;; *) echo allow ;; esac
}
while IFS= read -r c; do
  printf '%-34s cand=%-5s v1.36.1=%s\n' "$c" "$(juzga "$R/hooks" desarrollador "$c")" "$(juzga "$S/t136/hooks" desarrollador "$c")"
done < "$S/sondas.txt"
cp "$P/.arnes/config.json" "$S/cfg.ok"; printf 'roto' > "$P/.arnes/config.json"
echo "manifiesto roto, coordinadora: printf '{}' > .arnes/config.json -> $(juzga "$R/hooks" - "printf '{}' > .arnes/config.json") (v1.36.1 $(juzga "$S/t136/hooks" - "printf '{}' > .arnes/config.json"))"
echo "manifiesto roto, coordinadora: mv .arnes/config.json x -> $(juzga "$R/hooks" - 'mv .arnes/config.json x') (v1.36.1 $(juzga "$S/t136/hooks" - 'mv .arnes/config.json x'))"
cp "$S/cfg.ok" "$P/.arnes/config.json"
