#!/usr/bin/env bash
# destinos.sh <proy> <fuera> -> lista separada por NUL
P="$1"; F="$2"
base=( f a.ts src src/ src/a.ts src/nuevo.ts src//a.ts src/./a.ts ./src/a.ts docs/../src/a.ts docs/enl/a.ts docs/enl/../x.md
  docs/enl/../../src/a.ts docs/../../proy/src/a.ts lnreq/REQ-001.md lnreq/../src/a.ts requirements/REQ-001.md requirements/ requirements
  requirements/nuevo/REQ-9.md requirements/../requirements/REQ-001.md docs/req-enl.md docs/x.md docs/y.md docs/xx.md docs/sub/a1 docs/sub/c1
  app/a.ts app/../src/a.ts app2/q app2/../app2/q zz/q ñandú/x 'dir con espacio/x' src/log roto bucle1 bucle1/x sinpermiso/x sinpermiso
  archivo/x archivo/ n1/n2/n3/f n1/../f n1/./f n1//f . .. ../ ../x ../../x / // /// '' x/ x// 'src\a.ts' 'C:\x\y' 'C:/x' 'c:x' cwdenl cwdenl/src/a.ts
  cwdenl/../x /proc/self/fd/1 /proc/self/fd/9 /proc/self/cwd/src/a.ts /proc/self /proc/thread-self/fd/2 /dev/stdout /dev/stderr /dev/fd/1 /dev/fd/7 /dev/null
  /dev/shm/x /tmp /tmp/ /etc/passwd 'src/a.ts\' 'src/*' 'src/?' '[ab]' .arnes/config.json .arnes//config.json ./.arnes/config.json
  docs/../.arnes/config.json "$P/src/a.ts" "$P//src/a.ts" "$P/./src/a.ts" "$P/docs/../src/a.ts" "$P/docs/enl/a.ts" "$P" "$P/" "$P/.." "$F/f" "$F/haciasrc/a.ts" "$F/haciasrc/../f"
  "$F/../proy/src/a.ts" $'src/a\nb.ts' $'src/a.ts\r' $'docs/\r/x' 'src/é.ts' 'src/a b' )
long="$(printf 'a%.0s' {1..4100})"
base+=( "$long" "src/$long" )
printf '%s\0' "${base[@]}"
