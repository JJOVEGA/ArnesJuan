#!/usr/bin/env bash
# REQ-007 CA-69 punto 7, E1 (línea base de la fase 1): las TRES entradas exactas de la sonda 37/3 de REQ-017
# CA-09, generadas con SU PROPIO CÓDIGO —el heredoc PARED37 de
# tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh, extraído tal cual del archivo, sin
# tocar una línea de la generación (:147-157)—, a nivel de hook, por guard-completado.sh como la sonda, con
# N = 0, 98 304 y 196 608. Por cada una: decisión, motivo completo, código de salida y duración.
# Proyecto como el de la sección: el manifiesto base del corredor y requirements/REQ-900.md «en-revisión».
# Uso: 06-e1.sh <scratch> <seccion-37-3> <repeticiones> <arbol-hooks>...   (intercala los árboles)
set -u
S="${1:?scratch}"; SEC="${2:?seccion}"; K="${3:?k}"; shift 3
W="$(mktemp -d "$S/e1-XXXX")"; trap 'rm -rf "$W"' EXIT
# El generador: del heredoc, las líneas hasta la que comprueba el JSON (la medición de la sonda se sustituye).
sed -n '/^cat > "\$PARED37" <<.PARED37FIN.$/,/^PARED37FIN$/p' "$SEC" | sed '1d;$d' | sed '/^t0=/,$d' > "$W/gen.sh"
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements"
cat > "$P/.arnes/config.json" <<'M'
{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
M
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
echo "# E1 $(date -Is); bash $BASH_VERSION; $(uname -r); LANG=C.UTF-8 sin LC_ALL; k=$K; generador: $(sha256sum < "$W/gen.sh" | cut -c1-16) ($(wc -l < "$W/gen.sh") líneas)"
echo "# columnas: rep N arbol decision rc ms entrada_bytes sha_entrada | motivo completo"
for ((r = 1; r <= K; r++)); do
  for N in 0 98304 196608; do
    bash "$W/gen.sh" x "$P" "$N" > "$W/g.out" 2>&1 || { echo "rep=$r N=$N GENERADOR-FALLA $(cat "$W/g.out")"; continue; }
    eb="$(wc -c < "$P/in37.json")"; es="$(sha256sum < "$P/in37.json" | cut -c1-16)"
    for H in "$@"; do
      printf '# REQ-900\nEstado: en-revisión\n' > "$P/requirements/REQ-900.md"
      (cd "$P"; unset LC_ALL POSIXLY_CORRECT BASH_ENV; export LANG=C.UTF-8
       t0=${EPOCHREALTIME/./}; CLAUDE_PROJECT_DIR="$P" timeout 120 bash "$H/guard-completado.sh" < "$P/in37.json" > "$W/o" 2> "$W/e"; rc=$?
       t1=${EPOCHREALTIME/./}; printf '%s %s\n' "$rc" "$(( (t1 - t0) / 1000 ))" > "$W/rc")
      read -r rc ms < "$W/rc"
      d=nada; grep -q '"permissionDecision":"deny"' "$W/o" && d=deny
      m="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' "$W/o" 2>/dev/null | tr '\n' ' ')"
      printf 'rep=%s N=%-6s arbol=%-28s dec=%-4s rc=%-3s ms=%-6s entrada=%sB sha=%s | %s\n' "$r" "$N" "${H%/hooks}" "$d" "$rc" "$ms" "$eb" "$es" "${m:-<sin motivo>}"
    done
  done
done
