#!/usr/bin/env bash
# enlaces3.sh — tercera tanda: copiar o mover un archivo llamado gates-veredicto.json A UN DIRECTORIO (.arnes/), con y
# sin enlace; y el análogo con el manifiesto (config.json) para ver si REQ-033 lo cubre.
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/issue-63-f13724-qa-pasada
. <(sed -n '/^A=/,/^in_bash()/p' $R/bin/enlaces.sh)
nuevo2() { nuevo; mkdir -p $W/f; mv $W/v.json $W/f/gates-veredicto.json; cp $P/.arnes/config.json $W/f/config.json; rm -f $P/.arnes/gates-veredicto.json; }
echo "# QA-037-11, tercera tanda, $(date -Is)"
while IFS= read -r c; do [ -n "$c" ] || continue; nuevo2; c2="${c//F/$W/f/gates-veredicto.json}"; c2="${c2//M/$W/f/config.json}"
  dA=$(juzga $A "$(in_bash "$c2" qa-tester)"); dB=$(juzga $B "$(in_bash "$c2" qa-tester)")
  r=''; if [ "$dA" = allow ] && [[ $c != *M* ]]; then (cd $P && eval "$c2") >/dev/null 2>&1; r=" → ejecutada; cierre: $(cierre)"; fi
  echo "  [$c] candidata: $dA | v1.36.2: $dB$r"; done <<'L'
cp F .arnes/
cp F .arnes
mv F .arnes/
cp -t .arnes F
install -m 644 F .arnes/
cp --link F .arnes/ && rm F
cp -l F .arnes && rm F
cp M .arnes/
cp M .arnes
mv M .arnes/
L
