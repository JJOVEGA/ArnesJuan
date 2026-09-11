#!/usr/bin/env bash
# R-029 · SEC-087 y SEC-088, reproducidos ejerciendo la PUERTA REAL.
# Metodo y version base: ./LEEME.md . Escribe SOLO en un directorio temporal propio,
# que borra al salir; no toca el repositorio.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(cd "$AQUI/../../.." && pwd)"
H330=${H330:-/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.0/hooks}
H331=${H331:-/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.1/hooks}
H332=${H332:-$RAIZ/hooks}
command -v jq >/dev/null || { echo 'hace falta jq' >&2; exit 2; }

P="$(mktemp -d)"; trap 'rm -rf "$P"' EXIT
mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
cat > "$P/.arnes/config.json" <<'CFG'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
CFG
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$P"

# El REQ: no sensible, QA ya aprobado, seguridad PENDIENTE. Lo unico que cambia
# entre casos es el valor de `Rigor:`. Si la puerta permite, ha cerrado un REQ
# declarado `critico` SIN veredicto de seguridad.
caso() { # <hooks> <valor de Rigor:>
  printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: pendiente\nRigor: %s\n' "$2" \
    > "$P/requirements/REQ-900.md"
  local out dec av
  out="$(jq -n --arg fp "$P/requirements/REQ-900.md" \
          '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
            tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' \
        | "$1/guard-completado.sh" 2>/dev/null)"
  # OJO: cuando la puerta PERMITE no emite nada, asi que `jq` sobre entrada vacia
  # no imprime nada. Si no se trata ese caso, la fila mas importante de esta tabla
  # sale EN BLANCO y se lee como «no medido» en vez de «permitio».
  if [ -z "${out//[[:space:]]/}" ]; then
    dec='ALLOW (silencio)'; av='-'
  else
    dec="$(jq -r '.hookSpecificOutput.permissionDecision // "ALLOW"' <<< "$out" 2>/dev/null || echo 'ALLOW (sin json)')"
    av="$(jq -r 'if (.systemMessage // "") == "" then "-" else "SI" end' <<< "$out" 2>/dev/null || echo -)"
  fi
  printf '  %-26s -> %-16s aviso=%s\n' "[$2]" "$dec" "$av"
}

for pareja in "1.33.0|$H330" "1.33.1 (publicada)|$H331" "1.33.2 (el parche)|$H332"; do
  etiq="${pareja%%|*}"; hooks="${pareja#*|}"
  [ -x "$hooks/guard-completado.sh" ] || { echo "== $etiq: NO INSTALADA, se omite"; continue; }
  echo "== $etiq  ($hooks)"
  caso "$hooks" 'critico (por suelo)'
  caso "$hooks" 'critico (por suelo'
  caso "$hooks" 'critico ('
  caso "$hooks" 'critico (x) y'
  caso "$hooks" 'criitco'
  echo
done
cat <<'NOTA'
Lectura de la tabla:
  `critico (por suelo)` DEBE denegar: es la correccion de D16 que trajo 1.33.1.
  Los cuatro siguientes PERMITEN hoy, en las tres versiones, y sin aviso: un REQ
  declarado `critico` cierra sin veredicto de seguridad por un parentesis sin
  cerrar o por una errata. Eso es SEC-088 (la via, diferida) y SEC-087 (la
  promesa del contrato que hoy afirma lo contrario, y que BLOQUEA la firma).
  SEC-087 se cierra con TEXTO en sus cuatro sedes; no cambiando esta conducta.
NOTA
