#!/usr/bin/env bash
# Solo registra la entrada de PostToolUse (tool_input y tool_response). Sin salida: no decide nada.
LOG="${CLAUDE_PROJECT_DIR:?}/../logs"; mkdir -p "$LOG"; cat > "$LOG/post-$(date +%s%N).json"; exit 0
