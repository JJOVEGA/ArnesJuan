source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/h.sh
prep() { mkproj; ln -s ../src/a.ts $P/docs/enlace-src; ln -s notas.md $P/docs/enlace-notas; ln -s ../docs/notas.md $P/src/enlace-fuera
  ln -s ../src $P/docs/dsrc; ln $P/src/a.ts $P/docs/hl; ln $P/docs/otra.md $P/docs/hl-otra; mkdir -p $P/docs/d2; printf 'z\n' > $P/docs/d2/z
  (cd $P && git add -A && git -c user.email=a@b -c user.name=a commit -qm f); }
huella() { (cd $P && find src hooks .arnes -print0 2>/dev/null | sort -z | xargs -0 stat -c '%n %s %i %Y %F' 2>/dev/null; cat src/a.ts hooks/lib.sh .arnes/config.json 2>/dev/null) | md5sum; }
paths=(S docs/notas.md docs/otra.md docs/enlace-notas docs/enlace-src src/enlace-fuera docs/dsrc/a.ts docs/hl docs/hl-otra src/a.ts hooks/lib.sh .arnes/config.json docs/sub docs/d2 src hooks docs/nuevo.md src/nuevo.ts ./docs/notas.md docs/../docs/notas.md docs//notas.md $P/docs/notas.md $P/src/a.ts docs/sub/../notas.md)
opts=('' -f -i -n -p -v -r -R -a -u -fv -rf --force --update --archive --no-clobber --verbose)
RANDOM=4859; n=0; mov=0; prot=0
prep; base_h="$(huella)"
for ((it=0; it<700; it++)); do
  o=(cp mv install); o=${o[RANDOM%3]}; op=${opts[RANDOM%${#opts[@]}]}; k=$((2 + (RANDOM%5==0)))
  args=(); for ((q=0;q<k;q++)); do args+=("${paths[RANDOM%${#paths[@]}]}"); done
  cmd="$o${op:+ $op} ${args[*]}"
  a="$(dec "$V" "$P" - "$cmd")"; b="$(dec "$C" "$P" - "$cmd")"; n=$((n+1))
  if [ "$a" != "$b" ]; then
    mov=$((mov+1))
    h0="$(huella)"; (cd $P && env -i PATH=/usr/bin:/bin bash -c "$cmd" </dev/null >/dev/null 2>&1); h1="$(huella)"
    ch="$(cd $P && git status --porcelain -- src hooks .arnes | tr '\n' ' ')"
    if [ "$h0" != "$h1" ] || [ -n "$ch" ]; then prot=$((prot+1)); echo "PROTEGIDO v136=$a cand=$b [$ch] | $cmd"; fi
    [ "$a:$b" = deny:allow ] || echo "OTRO-SENTIDO v136=$a cand=$b | $cmd"
    prep
  fi
done
echo "casos=$n movimientos=$mov con_efecto_protegido=$prot"
