#!/usr/bin/env bash
H=/home/juan/dev/ArnesJuan-v1.35/hooks
MANI='{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador"]},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}'
caso() { # id esperado cabecera old new
  P=$(mktemp -d); mkdir -p $P/.arnes $P/requirements; echo "$MANI" > $P/.arnes/config.json; printf '## Pendientes\n\n## Resueltas\n' > $P/PENDING_APPROVAL.md
  f=$P/requirements/REQ-9.md; printf '# REQ-9\n%s\n\n## H\nx\n' "$3" > $f
  j=$(jq -n --arg fp "$f" --arg o "$4" --arg n "$5" '{hook_event_name:"PreToolUse",tool_name:"Edit",tool_input:{file_path:$fp,old_string:$o,new_string:$n}}')
  out=$(printf '%s' "$j" | CLAUDE_PROJECT_DIR=$P bash $H/guard-completado.sh 2>/dev/null)
  if grep -q '"deny"' <<< "$out"; then got=deny; else got=allow; fi
  m=$(jq -r '.hookSpecificOutput.permissionDecisionReason // ""' <<< "$out" 2>/dev/null | cut -c1-110)
  printf '%-4s %-5s esperado=%-5s got=%-5s %s\n' "$([ $got = $2 ] && echo PASS || echo FAIL)" "$1" "$2" "$got" "$m"; rm -rf $P
}
V=$'QA: aprobado\nSeguridad: aprobado\nSensible a seguridad: no\nHallazgos abiertos: (ninguno)'
caso D0 deny  "Estado: en-revisión"$'\n'"ESTADO: completado"$'\n'"Rigor: estandar"$'\n'"$V" 'Rigor: estandar' 'Rigor: critico'
caso D1 deny  "Estado: en-revisión"$'\n'"Estado: completado"$'\n'"Rigor: estandar"$'\n'"$V" 'Rigor: estandar' 'Rigor: critico'
caso D2 deny  "ESTADO: completado"$'\n'"Rigor: estandar"$'\n'"$V" 'Rigor: estandar' 'Rigor: critico'
caso P1 allow "Estado: completado"$'\n'"ESTADO: completado"$'\n'"Rigor: estandar"$'\n'"$V" 'Estado: completado' 'Estado: en-progreso'
caso P2 allow "Estado: en-revisión"$'\n'"Rigor: estandar"$'\n'"qa: pendiente"$'\n'"$V" 'Rigor: estandar' 'Rigor: critico'
caso P3 allow "Estado: en-revisión"$'\n'"qa: aprobado"$'\n'"Rigor: estandar"$'\n'"$V" 'Rigor: estandar' 'Rigor: critico'
caso P4a allow "Estado: en-revisión"$'\n'"ESTADO: completado"$'\n'"Rigor: estandar"$'\n'"$V" $'\nESTADO: completado' ''
caso P4b allow "Estado: en-revisión"$'\n'"Estado: completado"$'\n'"Rigor: estandar"$'\n'"$V" $'\nEstado: completado' ''
# X1 retirando la PRIMERA: la terminal pasa a gobernar -> cierre normal, lo juzgan las puertas (veredictos verdes -> allow)
caso X1r allow "Estado: en-revisión"$'\n'"Estado: completado"$'\n'"Rigor: estandar"$'\n'"$V" $'Estado: en-revisión\n' ''
# control: el mismo X1r pero con QA pendiente -> lo deniega la puerta de siempre, no esta regla
caso X1q deny  "Estado: en-revisión"$'\n'"Estado: completado"$'\n'"Rigor: estandar"$'\n'"QA: pendiente"$'\n'"Seguridad: n/a"$'\n'"Sensible a seguridad: no" $'Estado: en-revisión\n' ''
