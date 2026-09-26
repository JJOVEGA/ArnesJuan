#!/usr/bin/env bash
# Limpia los logs de CI (quita el prefijo job/paso/marca de tiempo) a corrida-N.txt y reutiliza el analizador del ensayo local.
O=$(dirname "$0")/corridas; L=$(dirname "$0")/limpias; mkdir -p "$L"
for f in "$O"/run-*.txt; do n=$(basename "$f" .txt | cut -d- -f2); sed -E 's/^[^\t]*\t[^\t]*\t[0-9T:.-]+Z //' "$f" > "$L/corrida-0$n.txt"; grep -E "^(status|conclusion|job)" "$O/run-$n.meta" | tr '\n' ' ' > /dev/null; grep 'status=completed' "$O/run-$n.meta" | tail -1 | sed -E 's/.*job_start=([^ ]+) job_end=([^ ]+).*/\1 \2/' | python3 -c "import sys,datetime as d; a,b=sys.stdin.read().split(); f=lambda s:d.datetime.fromisoformat(s.replace('Z','+00:00')); print(f'segundos={(f(b)-f(a)).total_seconds():.0f}')" > "$L/corrida-0$n.meta" 2>/dev/null || echo "segundos=0" > "$L/corrida-0$n.meta"; done
python3 "$(dirname "$0")/../ensayo-local/analizar-ensayo.py" "$L"
