# Medida de 1.37 · 4a — lo que lee cada agente (REQ-036 CA-01, sumando (i))

**Qué mide.** Los bytes (`wc -c`, 1 KB = 1 000 B) de lo que la definición de un agente le **manda leer al
empezar**, con la lectura por destinatario de CA-14: de `AGENTS.md` y `requirements/README.md`, sólo los
bloques cuya marca `[[<id> · obliga: <roles>]]` lo nombra o dice `todos` (la coordinadora, todos; un bloque
`explicativo`, nadie; una marca que no se entiende, todos: ante la duda, se lee); la definición entera; y del
manifiesto, el bloque `rigor_politica` (sólo para el analista, que es lo que su definición le manda leer).

**Qué NO mide.** El sumando (ii) de CA-01 —los bytes que de verdad leyeron las corridas de conducta, vistos en
sus transcripciones— es de la coordinadora (CA-02). Y no mide lo que el cliente inyecta solo: si `CLAUDE.md`
importa `AGENTS.md` con `@AGENTS.md`, el archivo entero entra en el contexto **aunque la definición mande leer
por bloques** (defecto D-036-1 del informe de la fase 1; la plantilla de `CLAUDE.md` está fuera de REQ-036).

**Cómo se corre.** Desde la raíz del repositorio del arnés: el guion de abajo, con `TPL` apuntando a un
directorio de plantillas y `DEF` a la definición. Monta en un temporal el proyecto «tienda-demo» de PC-034-1
(los cinco ámbitos de `config-ambitos-declarados.json`) con esas plantillas, y además mide las plantillas
**sin rellenar**, que es como se midió la línea base de P-137-W (138 574 B). La sección 51 del banco
extrae este bloque y lo ejecuta.

<!-- guion: medida-4a (REQ-036 CA-01; lo ejecuta la sección 51 del banco del arnés) -->
```bash
TPL="${TPL:-templates}"; DEF="${DEF:-agents/analista-requerimientos.md}"; ROL="${ROL:-analista}"
bloques() {   # <archivo> <rol> -> bytes de los bloques que ese rol lee; en stderr, sus id
  LC_ALL=C awk -v rol="$2" '
    function decide(m,   o) {
      if (rol == "coordinadora") return 1
      if (m ~ /explicativo\]\]$/) return 0
      if (m !~ /obliga: /) return 1
      o = m; sub(/^.*obliga: /, "", o); sub(/\]\][ \t]*$/, "", o); gsub(/ /, "", o); o = "," o ","
      return (index(o, "," rol ",") || index(o, ",todos,")) ? 1 : 0
    }
    BEGIN { lee = 1; id = "(antes-de-la-primera-marca)" }
    /^\[\[/ { lee = decide($0); id = $1; sub(/^\[\[/, "", id) }
    lee { b += length($0) + 1; if (!(id in v)) { v[id] = 1; ids = ids " " id } }
    END { print b + 0; print ids > "/dev/stderr" }
  ' "$1"
}
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
for modo in proyecto plantilla; do
  if [ "$modo" = proyecto ]; then A="$P/AGENTS.md"; R="$P/requirements/README.md"; M="$P/.arnes/config.json"
  else A="$TPL/AGENTS.md.tpl"; R="$TPL/requirements-README.md.tpl"; M="$TPL/arnes-config.json.tpl"; fi
  a="$(bloques "$A" "$ROL" 2>"$P/ia")"; r="$(bloques "$R" "$ROL" 2>"$P/ir")"; d="$(LC_ALL=C wc -c < "$DEF")"
  if [ "$ROL" = analista ]; then m="$(politica "$M")"; else m=0; fi
  printf 'modo=%s rol=%s agents=%s readme=%s definicion=%s manifiesto=%s total=%s\n' \
    "$modo" "$ROL" "$a" "$r" "$((d))" "$m" "$((a + r + d + m))"
  printf '  bloques de AGENTS.md:%s\n  bloques del README:%s\n' "$(<"$P/ia")" "$(<"$P/ir")"
done
```

**Lo que imprime.** Una línea `modo=… rol=… agents=… readme=… definicion=… manifiesto=… total=…` por modo
(`proyecto`, el «tienda-demo» rellenado; `plantilla`, las plantillas sin rellenar) y los identificadores de los
bloques que ese rol lee. Los valores con que se rellenan los marcadores son de demostración: el total del modo
`proyecto` depende de ellos en unas decenas de bytes.

**Resultado de la fase 1** (2026-10-21, candidato sobre `e1f23d2`): en el informe de la fase 1 y en el
Historial de REQ-036.
