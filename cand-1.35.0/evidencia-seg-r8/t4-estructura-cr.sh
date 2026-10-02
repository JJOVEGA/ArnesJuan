#!/usr/bin/env bash
# t4 — Estructura sintáctica que cambia porque el CR final de línea ya no se borra en el transporte:
# (1) movimientos de deny a allow frente a lo publicado (¿declarados?) y su efecto real en el shell;
# (2) búsqueda de lo contrario: estructuras donde el analizador ve MENOS que el shell (fallo en abierto).
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
proyecto_nuevo "$S/p4"
declare -a NOM CMD
add() { NOM+=("$1"); CMD+=("$2"); }
add "E1 heredoc: cuerpo con 'EOF<CR>', luego echo > src/a.ts, luego EOF" "cat <<EOF > docs/x.md"$'\n'"x"$'\n'"EOF$CR"$'\n'"echo E1 > src/a.ts"$'\n'"EOF"$'\n'
add "E2 heredoc <<-: cuerpo con '<TAB>EOF<CR>', luego echo > src/a.ts" "cat <<-EOF > docs/x.md"$'\n'"x"$'\n'"	EOF$CR"$'\n'"echo E2 > src/a.ts"$'\n'"EOF"$'\n'
add "E3 continuación '\\<CR><LF>' entre > y el destino" "echo E3 > \\$CR"$'\n'"src/a.ts"
add "E4 continuación '\\<CR><LF>' entre orden y argumentos" "tee \\$CR"$'\n'"src/a.ts < /dev/null"
add "E5 continuación '\\<CR><LF>' en sed -i que cierra" "sed -i 's/en-revisión/completado/' \\$CR"$'\n'"requirements/REQ-900.md"
add "E6 control: continuación limpia '\\<LF>' (deny)" "echo E6 > \\"$'\n'"src/a.ts"
add "E7 echo x 1<CR>>src/a.ts" "echo E7 1$CR>src/a.ts"
add "E8 echo x ><CR>>src/a.ts (dos redirecciones)" "echo E8 >$CR>src/a.ts"
add "E9 cuerpo citado 'EOF<CR>' y comillas que cruzan" "cat <<'EOF'"$'\n'"EOF$CR"$'\n'"echo E9 > src/a.ts"$'\n'"EOF"$'\n'
add "E10 if/then con CR al final de 'then'" "if true; then$CR"$'\n'"echo E10 > src/a.ts"$'\n'"fi"
add "E11 comentario con CR y orden siguiente" "# nota$CR"$'\n'"echo E11 > src/a.ts"
add "E12 comillas abiertas con CR antes de LF" "echo \"a$CR"$'\n'"b\" > src/a.ts"
add "E13 subshell con CR: ( echo x > src/a.ts<CR> )" "( echo E13 > src/a.ts$CR"$'\n'")"
add "E14 \$( ) con CR" "x=\$(echo E14 > src/a.ts$CR"$'\n'")"
echo "proyecto=$P"
for i in "${!NOM[@]}"; do j_bash "${CMD[i]}"; fila "${NOM[i]}" "$J"; done
echo "== Efecto real del shell (bash $(bash --version | head -1 | awk '{print $4}')), árbol aparte, cwd = su raíz =="
T="$S/efe4"
for i in "${!NOM[@]}"; do
  proyecto_nuevo "$T"
  ( cd "$T" && bash -c "${CMD[i]}" ) >/dev/null 2>&1
  r1="$(cat "$T/src/a.ts")"; r2="$(sed -n 2p "$T/requirements/REQ-900.md")"
  printf '%-58s src/a.ts=%s | REQ-900 l2=%s\n' "${NOM[i]:0:58}" "$(printf '%s' "$r1" | tr '\n\r' '|~')" "$r2"
done
rm -rf "$T"
