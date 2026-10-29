#!/usr/bin/env bash
# lectura.sh — pasada de sólo texto P-137-AN (A): formas que CA-05 (ii) promete denegar, y las tres declaradas fuera.
# Columnas: d89316c qa-tester | d89316c coordinadora | v1.36.2 qa-tester
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/issue-63-f13724-qa-pasada
. <(sed -n '/^A=/,/^in_bash()/p' $R/bin/enlaces.sh)
nuevo2() { nuevo; mkdir -p $W/f; mv $W/v.json $W/f/gates-veredicto.json; }
echo "# lectura P-137-AN, $(date -Is)"
while IFS= read -r c; do [ -n "$c" ] || continue; nuevo2; c2="${c//F/$W/f/gates-veredicto.json}"
  dA=$(juzga $A "$(in_bash "$c2" qa-tester)"); dC=$(juzga $A "$(in_bash "$c2" '')"); dB=$(juzga $B "$(in_bash "$c2" qa-tester)")
  echo "  [$c] $dA | $dC | $dB"; done <<'L'
install F .arnes/gates-veredicto.json
install -m 644 F .arnes/gates-veredicto.json
install -D F .arnes/gates-veredicto.json
install -t .arnes F
install -m 644 F .arnes/
cp F .arnes/gates-veredicto.json
mv F .arnes/gates-veredicto.json
mv .arnes/gates-veredicto.json /tmp/x
echo {} > .arnes/gates-veredicto.json
echo {} >> .arnes/gates-veredicto.json
echo {} | tee .arnes/gates-veredicto.json
sed -i s/a/b/ .arnes/gates-veredicto.json
ln -s F .arnes/gates-veredicto.json
ln F .arnes/gates-veredicto.json
cp F .arnes/
mv F .arnes
link F .arnes/gates-veredicto.json
cp -l F .arnes
cp --link F .arnes/
L
