source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/h.sh; mkproj
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
echo "comando | 1.33.2 | 1.35.0 | 1.36.0 (f22b905 = instalado) | candidata (6f2b811)"
while IFS= read -r k; do printf '%s' "$k"; for h in $S/v1.33.2/hooks $S/v1.35.0/hooks $V $C; do printf ' | %s' "$(dec $h "$P" - "$k")"; done; echo; done <<'L'
cp S src/a.ts 2>/dev/null
cp S src/a.ts 2> /dev/null
cp S src/a.ts 2>&1
cp S src/a.ts 1>&2
cp S src/a.ts 2>/tmp/e48
cp S src/a.ts # nada
cp S src/a.ts < docs/sub
cp -rt src docs/sub
\cp S src/a.ts
find src -name a.ts -exec cp S {} \;
(cp S src/a.ts)
cp S src/b.ts 2>/dev/null
mv S src/a.ts 2>/dev/null
cp S hooks/lib.sh 2>/dev/null
cp S src/a.ts
cat S > src/a.ts
cp S docs/notas.md
mv src/a.ts docs/notas.md
mv .arnes/config.json docs/notas.md
mv src/a.ts docs/nuevo.md
rm src/a.ts
unlink src/a.ts
truncate -s 0 src/a.ts
rm .arnes/config.json
L
