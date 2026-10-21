#!/usr/bin/env bash
# Coste por orden: ms (mediana de N) y procesos (mínimo de N del salto del último PID del sistema).
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
SPIKE=/home/juan/dev/ArnesJuan-spike-1.37-3; PP="$SPIKE/hooks/puerta-posterior.sh"; V136="$S/v1362/hooks"
N=${N:-15}
export TMPDIR="$S/estado3"; rm -rf "$TMPDIR"; mkdir -p "$TMPDIR"
P="$S/p/coste"; rm -rf "$P"; mkdir -p "$P/.arnes"; cp -a "$SPIKE/hooks" "$P/hooks"; cp "$SPIKE/.arnes/config.json" "$P/.arnes/"
export CLAUDE_PROJECT_DIR="$P"
J="$S/in.json"
jq -cn --arg p "$P" '{session_id:"s1", tool_use_id:"toolu_c", tool_name:"Bash", cwd:$p, agent_type:"qa-tester", agent_id:"a", tool_input:{command:"ls"}}' > "$J"
lastpid() { local a b c d e; read -r a b c d e < /proc/loadavg; LP=$e; }
mide() {   # <etiqueta> <orden...>  (la orden lee $J por su entrada estándar)
  local et="$1"; shift; local i t0 t1 p0 ms=() pr=() m
  for ((i=0;i<N;i++)); do
    lastpid; p0=$LP; t0=$EPOCHREALTIME
    "$@" < "$J" >/dev/null 2>&1
    t1=$EPOCHREALTIME; lastpid
    ms+=("$(( (${t1/./}-${t0/./})/1000 ))"); pr+=("$((LP-p0))")
  done
  m=$(printf '%s\n' "${ms[@]}" | sort -n | sed -n "$(( (N+1)/2 ))p")
  printf '| %s | %s | %s | %s |\n' "$et" "$m" "$(printf '%s\n' "${pr[@]}" | sort -n | head -1)" "$(printf '%s\n' "${ms[@]}" | sort -n | tr '\n' ' ')"
}
pp_pre_post() { bash "$PP" pre < "$J"; bash "$PP" post < "$J"; }
v_y_pp() { bash "$V136/guard.sh" < "$J"; bash "$PP" pre < "$J"; bash "$PP" post < "$J"; }
refresco() { rm -f "$TMPDIR"/arnes-pp-*/s1/copia.foto; bash "$PP" pre; }
printf '| Medida (orden `ls`, hooks/ real 408 KB) | ms mediana | procesos (mín.) | ms de las %s corridas |\n|---|---|---|---|\n' "$N"
mide 'calibración: `bash -c :`' bash -c :
mide 'v1.36.2: guard.sh (Pre)' bash "$V136/guard.sh"
bash "$PP" pre < "$J" >/dev/null 2>&1   # toma la copia inicial
mide 'spike: puerta-posterior pre (camino común)' bash "$PP" pre
mide 'spike: puerta-posterior post (sin cambio)' bash "$PP" post
mide 'spike: pre + post' pp_pre_post
mide 'v1.36.2 + spike (todo lo que corre por orden)' v_y_pp
mide 'spike: pre que refresca la copia' refresco
