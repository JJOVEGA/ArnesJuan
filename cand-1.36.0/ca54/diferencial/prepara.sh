#!/usr/bin/env bash
# Proyecto de prueba para la comparacion diferencial de identidad/pertenencia.
R="$1"; rm -rf "$R"; mkdir -p "$R"
P="$R/proy"; mkdir -p "$P"/{src,requirements,docs/sub,app2,.arnes,sinpermiso,"dir con espacio",ñandú}
printf '{}' > "$P/.arnes/config.json"
: > "$P/src/a.ts"; : > "$P/requirements/REQ-001.md"; : > "$P/docs/x.md"; : > "$P/archivo"
ln -s ../src "$P/docs/enl"            # directorio enlazado hacia src
ln -s requirements "$P/lnreq"         # enlace a requirements en la raiz
ln -s /dev/stderr "$P/src/log"        # enlace a un descriptor
ln -s noexiste "$P/roto"              # enlace roto
ln -s bucle1 "$P/bucle2"; ln -s bucle2 "$P/bucle1"
ln -s src "$P/app"                    # tramo enlazado (via c)
ln -s ../requirements/REQ-001.md "$P/docs/req-enl.md"
ln -s /proc/self/cwd "$P/cwdenl"
mkdir -p "$R/fuera"; ln -s "$P/src" "$R/fuera/haciasrc"; : > "$R/fuera/f"
chmod 000 "$P/sinpermiso"
