#!/usr/bin/env bash
# La salida COMPLETA del hook (stdout, codigo de salida y stderr) de v1.35.0 y del candidato sobre las 10
# entradas de S1 y S2, comparada byte a byte. Completa lo que S2 no publica: el motivo de v1.35.0.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54; WT=/home/juan/dev/ArnesJuan-v1.36; T="${TMPDIR:-/tmp}/ca54-salidas.$$"; mkdir -p "$T"
for par in s1/trabajo/ca54-65536:ca54-65536-A s1/trabajo/ca54-65536:ca54-65536-B s1/trabajo/ca54-65536:ca54-65536-C \
           s1/trabajo/ca54-131072:ca54-131072-A s1/trabajo/ca54-131072:ca54-131072-B s1/trabajo/ca54-131072:ca54-131072-C \
           s2/trabajo/ca54x-131072:ca54x-original s2/trabajo/ca54x-131072:ca54x-control-A s2/trabajo/ca54x-131072:ca54x-control-B s2/trabajo/ca54x-131072:ca54x-control-C; do
  P="$E/${par%%:*}"; J="$E/${par%%/trabajo*}/trabajo/${par#*:}.json"
  for arbol in v1.35.0 candidato; do
    case $arbol in v1.35.0) H=$E/arboles/v1.35.0/hooks ;; *) H=$WT/hooks ;; esac
    CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" > "$T/$arbol.out" 2> "$T/$arbol.err"; echo "rc=$?" >> "$T/$arbol.out"
  done
  if cmp -s "$T/v1.35.0.out" "$T/candidato.out" && cmp -s "$T/v1.35.0.err" "$T/candidato.err"; then r=IDENTICAS; else r=DISTINTAS; fi
  printf '%s | %s | stdout+rc sha256 %s | stderr %s bytes | %s\n' "${par#*:}" "$r" "$(sha256sum < "$T/candidato.out" | cut -c1-16)" "$(wc -c < "$T/candidato.err")" "$(head -c 120 "$T/candidato.out" | tr '\n' ' ')"
done
rm -rf "$T"
