source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/h.sh
ef() { mkproj; ln -s ../src/a.ts $P/docs/enlace-src; (cd $P && git add -A && git -c user.email=a@b -c user.name=a commit -qm l)
  local a b; a="$(dec "$V" "$P" "${2:--}" "$1")"; b="$(dec "$C" "$P" "${2:--}" "$1")"
  (cd "$P" && env -i PATH=/usr/bin:/bin bash -c "$1" >/dev/null 2>&1 </dev/null); local rc=$?
  printf 'v136=%-5s cand=%-5s rc=%s cambio_protegido=[%s] | %s\n' "$a" "$b" "$rc" "$(cd $P && git status --porcelain --untracked-files=all -- src hooks .arnes | tr '\n' ' ')" "$1"; }
while IFS= read -r k; do ef "$k"; done <<'L'
cp S docs/notas.md
mv S docs/notas.md
install S docs/notas.md
cp -fv S docs/notas.md
cp S src/a.ts docs/notas.md
mv S src/a.ts docs/notas.md
install S src/a.ts docs/notas.md
cp -r src docs/notas.md
cp -a hooks docs/notas.md
mv -r src docs/notas.md
install -r src docs/notas.md
install -p src/a.ts docs/notas.md
cp -a docs/enlace-src docs/notas.md
mv docs/enlace-src docs/notas.md
mv src/a.ts docs/notas.md
mv -f src/a.ts docs/notas.md
mv -n src/a.ts docs/notas.md
mv hooks/lib.sh docs/notas.md
mv .arnes/config.json docs/notas.md
mv src/a.ts docs/nuevo.md
rm src/a.ts
cp S src/a.ts 2>/dev/null
(cp S src/a.ts)
cp S src/b.ts 2>/dev/null
L
