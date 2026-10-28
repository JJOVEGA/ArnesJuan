#!/usr/bin/env bash
cat >/dev/null; date +%s > "$PWD/hook-corrio"
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"DENEGADO 1 (fijo)"}}'
exit 0
