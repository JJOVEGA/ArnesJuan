#!/usr/bin/env bash
cat >/dev/null; date +%s > "$PWD/hook-inicio"; sleep 620; date +%s > "$PWD/hook-fin"
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"DENEGADO tras 620 s"}}\n'
