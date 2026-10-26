# Medida de 1.37 · 4a — lo que lee cada agente (REQ-036 CA-01, sumando (i))

**Qué mide.** Los bytes (`wc -c`, 1 KB = 1 000 B) de lo que la definición de un agente le **manda leer al
empezar**, con la lectura por destinatario de CA-14 y, desde P-137-Z, en un solo `Read` (CA-18): el archivo
por rol `.arnes/lectura/<rol>.md` que `tools/arnes-lectura-rol.sh` genera de `AGENTS.md` y
`requirements/README.md` (los bloques cuya marca `[[<id> · obliga: <roles>]]` lo nombra o dice `todos`; un
bloque `explicativo`, nadie; una marca que no se entiende, todos: ante la duda, se lee; más su cabecera); la
definición entera; y del manifiesto, el bloque `rigor_politica` (sólo para el analista, que es lo que su
definición le manda leer; el manifiesto entero se imprime aparte, como dato). La lectura por marcas de respaldo
no se suma aquí: sólo ocurre si el archivo falta o está viejo, y entonces se ve en el sumando (ii).

**Qué NO mide.** El sumando (ii) de CA-01 —los bytes que de verdad leyeron las corridas de conducta, vistos en
sus transcripciones— es de la coordinadora (CA-02). Y no mide lo que el cliente inyecta solo: si `CLAUDE.md`
importa `AGENTS.md` con `@AGENTS.md`, el archivo entero entra en el contexto **aunque la definición mande leer
por bloques** (defecto D-036-1 del informe de la fase 1; la plantilla de `CLAUDE.md` está fuera de REQ-036).

**Cómo se corre.** Desde la raíz del repositorio del arnés: el guion de abajo, con `TPL` apuntando a un
directorio de plantillas, `DEF` a la definición, `ROL` a uno de los cuatro roles y `GEN` al generador (por
defecto, el `tools/` hermano de `TPL`). Monta en un temporal el proyecto «tienda-demo» de PC-034-1 (los cinco
ámbitos de `config-ambitos-declarados.json`) con esas plantillas y genera su archivo por rol; y además lo
genera de las plantillas **sin rellenar**, que es como se midió la línea base de P-137-W (138 574 B). Sin
generador, o si no genera, sale 2 sin medir. La sección 51 del banco extrae este bloque y lo ejecuta.

<!-- guion: medida-4a (REQ-036 CA-01; lo ejecuta la sección 51 del banco del arnés) -->
```bash
TPL="${TPL:-templates}"; DEF="${DEF:-agents/analista-requerimientos.md}"; ROL="${ROL:-analista}"
GEN="${GEN:-$TPL/../tools/arnes-lectura-rol.sh}"
[ -r "$GEN" ] || { echo "no hay generador: $GEN" >&2; exit 2; }
politica() {  # <manifiesto> -> bytes del bloque rigor_politica (desde su clave hasta su cierre)
  LC_ALL=C awk '/^  "rigor_politica": \{/ { d = 1 } d { b += length($0) + 1 } d && /^  \},?[ \t]*$/ { d = 0 } END { print b + 0 }' "$1"
}
P="$(mktemp -d)"; trap 'rm -rf "$P"' EXIT
rellena() {   # <plantilla> <destino>: los marcadores de arnes-init con los valores de «tienda-demo»
  local t; t="$(<"$1")"
  t="${t//'{{NOMBRE_PROYECTO}}'/tienda-demo}"; t="${t//'{{DESCRIPCION_PROYECTO}}'/Tienda en línea de demostración.}"
  t="${t//'{{PRINCIPIO_RECTOR}}'/lo que se cobra se prueba.}"; t="${t//'{{FRAMEWORK}}'/Next.js}"
  t="${t//'{{LENGUAJE}}'/TypeScript}"; t="${t//'{{AUTENTICACION}}'/sesión propia}"; t="${t//'{{HOSTING}}'/n/a}"
  t="${t//'{{REPO_URL}}'/n/a}"; t="${t//'{{TABLA_MODULOS}}'/| src/ | la app | desarrollador |}"
  t="${t//'{{MODELO_PERMISOS}}'/- n/a}"
  t="${t//'{{DECLARACION_VIA_PROPORCIONAL}}'/**Este proyecto todavía no ha declarado esa autorización.** Rige el procedimiento anterior: analista → desarrollador → QA → seguridad.}"
  t="${t//'{{MAX_REINTENTOS}}'/3}"; t="${t//'{{CRITERIO_RIGOR_CRITICO}}'/- **Crítico:** pagos (src/pagos/).}"
  t="${t//'{{GATES_HUMANOS}}'/- publicar.}"; t="${t//'{{PRESUPUESTO}}'/sin tope fijo}"; t="${t//'{{QUALITY_GATES}}'/- \`npm test\`}"
  t="${t//'{{ARNES_VERSION}}'/1.37.0}"; t="${t//'{{CODIGO_APP_GLOBS}}'/\"src/**\"}"; t="${t//'{{QUALITY_GATES_JSON}}'/\"npm test\"}"
  t="${t//'{{RIGOR_DINERO_JSON}}'/[\"src/pagos/**\"]}"; t="${t//'{{RIGOR_SESION_JSON}}'/[\"src/auth/**\"]}"
  t="${t//'{{RIGOR_SEGURIDAD_JSON}}'/[\"src/auth/permisos.ts\"]}"; t="${t//'{{RIGOR_DATOS_JSON}}'/[\"db/**\"]}"
  printf '%s\n' "$t" > "$2"
}
mkdir -p "$P/requirements" "$P/.arnes"
rellena "$TPL/AGENTS.md.tpl" "$P/AGENTS.md"; rellena "$TPL/requirements-README.md.tpl" "$P/requirements/README.md"
rellena "$TPL/arnes-config.json.tpl" "$P/.arnes/config.json"
jq -e . "$P/.arnes/config.json" >/dev/null || { echo "el manifiesto de tienda-demo no es JSON" >&2; exit 2; }
grep -q '{{' "$P/AGENTS.md" "$P/requirements/README.md" "$P/.arnes/config.json" && { echo "quedan marcadores sin rellenar" >&2; exit 2; }
Q="$P/plantilla"; mkdir -p "$Q/requirements" "$Q/.arnes"
cp "$TPL/AGENTS.md.tpl" "$Q/AGENTS.md"; cp "$TPL/requirements-README.md.tpl" "$Q/requirements/README.md"
for modo in proyecto plantilla; do
  if [ "$modo" = proyecto ]; then D="$P"; M="$P/.arnes/config.json"; else D="$Q"; M="$TPL/arnes-config.json.tpl"; fi
  bash "$GEN" "$D" || { echo "el generador no generó ($modo)" >&2; exit 2; }
  l="$(LC_ALL=C wc -c < "$D/.arnes/lectura/$ROL.md")"; d="$(LC_ALL=C wc -c < "$DEF")"
  if [ "$ROL" = analista ]; then m="$(politica "$M")"; else m=0; fi
  printf 'modo=%s rol=%s lectura=%s definicion=%s manifiesto=%s total=%s\n' \
    "$modo" "$ROL" "$((l))" "$((d))" "$m" "$((l + d + m))"
  printf '  manifiesto entero (dato, no se suma): %s B\n  bloques:%s\n' "$(($(LC_ALL=C wc -c < "$M")))" \
    "$(grep -o '^\[\[[^ ]*' "$D/.arnes/lectura/$ROL.md" | tr -d '[' | tr '\n' ' ')"
done
```

**Lo que imprime.** Una línea `modo=… rol=… lectura=… definicion=… manifiesto=… total=…` por modo
(`proyecto`, el «tienda-demo» rellenado; `plantilla`, las plantillas sin rellenar), el tamaño del manifiesto
entero como dato y los identificadores de los bloques del archivo por rol. Los valores con que se rellenan los
marcadores son de demostración: el total del modo `proyecto` depende de ellos en unas decenas de bytes.

**Resultado de la fase 1** (2026-10-21, candidato sobre `e1f23d2`): en el informe de la fase 1 y en el
Historial de REQ-036.
