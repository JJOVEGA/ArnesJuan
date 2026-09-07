# Sección 21 del banco — 21-rotacion-de-artefactos
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=24

  seccion_nueva "Rotacion de artefactos (mover, nunca resumir):"

# rot_proj <conservar> <umbral> <activo> <orden> -> deja la ruta en ROT_P
rot_proj() {
  ROT_P="$(mktemp -d)"; mkdir -p "$ROT_P/.arnes"
  jq -n --argjson c "$1" --argjson u "$2" --argjson a "$3" --arg o "$4" \
    '{agentes:{agente_codigo:"desarrollador"},
      rotacion:{activo:$a, umbral_bytes:$u, conservar_secciones:$c, orden:$o,
                artefactos:["CHANGELOG.md"]}}' > "$ROT_P/.arnes/config.json"
  { printf '# CHANGELOG\n\n> PREAMBULO DE UNA PERSONA.\n\n'
    for v in 10 9 8 7 6 5 4 3 2 1; do
      printf '## [1.%s.0]\n' "$v"
      for i in 1 2 3 4 5 6; do printf 'relleno %s de 1.%s.0 para que el archivo pese lo suyo\n' "$i" "$v"; done
      printf '\n'
    done
  } > "$ROT_P/CHANGELOG.md"
}
rot_corre() {
  local d="$1" json
  json="$(CLAUDE_PROJECT_DIR="$d" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$d" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
}
rot_sec() { grep -c '^## ' "$1" 2>/dev/null || echo 0; }
# rot_check <nombre> <esperado> <obtenido>
rot_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}

# Apagada: instalar el plugin no puede reestructurar el documento de nadie.
rot_proj 3 2000 false nuevo-primero
rot_corre "$ROT_P"
rot_check "apagada por defecto no toca nada" "10-no" "$(rot_sec "$ROT_P/CHANGELOG.md")-$([ -e "$ROT_P/CHANGELOG-archivo.md" ] && echo si || echo no)"
rm -rf "$ROT_P"

# Bajo el umbral tampoco: no se rota por rotar.
rot_proj 3 999999 true nuevo-primero
rot_corre "$ROT_P"
rot_check "bajo el umbral no toca nada" "10" "$(rot_sec "$ROT_P/CHANGELOG.md")"
rm -rf "$ROT_P"

# Conserva EXACTAMENTE lo declarado. Es el conteo que estaba invertido.
rot_proj 3 2000 true nuevo-primero
rot_corre "$ROT_P"; ROT_RC=$?
rot_check "conserva exactamente conservar_secciones" "3" "$(rot_sec "$ROT_P/CHANGELOG.md")"
rot_check "nada se pierde: origen + archivo = total" "10" \
  "$(( $(rot_sec "$ROT_P/CHANGELOG.md") + $(rot_sec "$ROT_P/CHANGELOG-archivo.md") ))"
rot_check "conserva LAS NUEVAS, no las viejas" "1" "$(grep -c '^## \[1\.10\.0\]' "$ROT_P/CHANGELOG.md")"
rot_check "no pisa el preambulo de una persona" "1" "$(grep -c 'PREAMBULO DE UNA PERSONA' "$ROT_P/CHANGELOG.md")"
rot_check "deja el puntero al archivo" "1" "$(grep -c 'CHANGELOG-archivo.md' "$ROT_P/CHANGELOG.md")"
rot_check "el hook sale 0 (no bloquea la parada)" "0" "$ROT_RC"
# Idempotencia: la primera version volvia a rotar en cada pasada.
rot_corre "$ROT_P"; rot_corre "$ROT_P"
rot_check "idempotente: tres pasadas, mismo reparto" "3-7" \
  "$(rot_sec "$ROT_P/CHANGELOG.md")-$(rot_sec "$ROT_P/CHANGELOG-archivo.md")"
rm -rf "$ROT_P"

# El orden se DECLARA. Con `nuevo-al-final` se conserva la otra mitad.
rot_proj 3 2000 true nuevo-al-final
rot_corre "$ROT_P"
rot_check "orden nuevo-al-final conserva el final" "1" "$(grep -c '^## \[1\.1\.0\]' "$ROT_P/CHANGELOG.md")"
rot_check "...y archiva el principio" "1" "$(grep -c '^## \[1\.10\.0\]' "$ROT_P/CHANGELOG-archivo.md")"
rm -rf "$ROT_P"

# Sin encabezados no hay limite seguro: no se corta a media entrada.
rot_proj 3 2000 true nuevo-primero
{ printf '# CHANGELOG sin secciones\n'; for i in $(seq 1 200); do printf 'linea larga de relleno numero %s en un archivo sin ningun encabezado de nivel dos\n' "$i"; done; } > "$ROT_P/CHANGELOG.md"
ROT_ANTES="$(wc -c < "$ROT_P/CHANGELOG.md")"
rot_corre "$ROT_P"
rot_check "sin encabezados no corta nada" "$ROT_ANTES" "$(wc -c < "$ROT_P/CHANGELOG.md")"
rm -rf "$ROT_P"

# --- El orden es del ARTEFACTO, no del proyecto -------------------------------
# Medido en un proyecto real: el CHANGELOG crece por arriba y el registro de
# seguridad por abajo. Con un `orden` global la rotacion era inservible para uno de
# los dos, y equivocarse archiva lo MAS RECIENTE. `artefactos` acepta cadena u
# objeto, la misma convencion que las quality_gates: la cadena hereda lo global.
ROT_M="$(mktemp -d)"; mkdir -p "$ROT_M/.arnes" "$ROT_M/seg"
cat > "$ROT_M/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador" },
  "rotacion": { "activo": true, "umbral_bytes": 400, "conservar_secciones": 2,
                "artefactos": [ "CHANGELOG.md",
                                { "ruta": "seg/registro.md", "orden": "nuevo-al-final", "conservar_secciones": 1 } ] } }
JSON
for n in CHANGELOG.md seg/registro.md; do
  { printf '# %s\n\n' "$n"; for v in 5 4 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in 1 2 3; do printf 'relleno %s de 1.%s.0 con texto suficiente\n' "$i" "$v"; done; printf '\n'; done; } > "$ROT_M/$n"
done
rot_corre "$ROT_M"
rot_check "artefacto como CADENA sigue funcionando (compatibilidad)" "## [1.5.0] ## [1.4.0]" \
  "$(grep -o '^## \[1\.[0-9]*\.0\]' "$ROT_M/CHANGELOG.md" | tr '\n' ' ' | sed 's/ $//')"
rot_check "...y el OBJETO usa SU orden, opuesto, en la misma pasada" "## [1.1.0]" \
  "$(grep -o '^## \[1\.[0-9]*\.0\]' "$ROT_M/seg/registro.md" | tr '\n' ' ' | sed 's/ $//')"
rot_check "...y SU conservar_secciones, distinto del global" "1" \
  "$(grep -c '^## ' "$ROT_M/seg/registro.md")"
rm -rf "$ROT_M"

# --- Un artefacto CRLF rota igual que uno LF -----------------------------------
# En Windows la mayoria de los archivos son CRLF, y este banco los escribia todos
# con LF: por eso no lo vio. Medido en un proyecto real: el registro de seguridad
# (12 857 CRLF) creaba su archivo y NO recortaba el origen, en silencio y con exit 0.
# Peor que inoperante: el contenido quedaba en los dos sitios y cada parada lo volvia
# a anadir -- 3, 6, 9 secciones en tres pasadas. Una fuga sin tope, justo en la
# funcion cuyo proposito es frenar el crecimiento sin tope.
ROT_CR="$(mktemp -d)"; mkdir -p "$ROT_CR/.arnes"
cat > "$ROT_CR/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador" },
  "rotacion": { "activo": true, "umbral_bytes": 400, "conservar_secciones": 2,
                "artefactos": ["LF.md","CRLF.md"] } }
JSON
rot_gen() { printf '# %s\n\n' "$1"; for v in 5 4 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in 1 2 3; do printf 'relleno %s de 1.%s.0 con texto suficiente\n' "$i" "$v"; done; printf '\n'; done; }
rot_gen LF > "$ROT_CR/LF.md"
rot_gen CRLF | sed 's/$/\r/' > "$ROT_CR/CRLF.md"
# Tres pasadas: la fuga solo se ve repitiendo.
rot_corre "$ROT_CR"; rot_corre "$ROT_CR"; rot_corre "$ROT_CR"
rot_check "un artefacto CRLF rota igual que uno LF" "2-3" \
  "$(rot_sec "$ROT_CR/CRLF.md")-$(rot_sec "$ROT_CR/CRLF-archivo.md")"
rot_check "...y no duplica: tres pasadas, mismo reparto" "2-3" \
  "$(rot_sec "$ROT_CR/LF.md")-$(rot_sec "$ROT_CR/LF-archivo.md")"
rot_check "nada se pierde con CRLF: origen + archivo = total" "5" \
  "$(( $(rot_sec "$ROT_CR/CRLF.md") + $(rot_sec "$ROT_CR/CRLF-archivo.md") ))"
# Se MUEVE tal cual: el final de linea del contenido no se toca.
rot_check "el contenido movido conserva su CRLF" "si" \
  "$([ "$(tr -cd '\r' < "$ROT_CR/CRLF-archivo.md" | wc -c)" -gt 0 ] && echo si || echo no)"
# Si la verificacion falla, no puede quedar medio hecho ni dejar basura.
rot_check "sin temporales huerfanos" "0" \
  "$(ls "$ROT_CR"/*.arnes.tmp 2>/dev/null | wc -l)"
rm -rf "$ROT_CR"

# La misma regla para la rotacion: una `ruta` fuera del proyecto no se toca.
ROT_RAIZ="$(mktemp -d)"; ROT_FUERA="$ROT_RAIZ/proyecto"; mkdir -p "$ROT_FUERA/.arnes"
printf '# fuera\n\n## [1.5.0]\nx\n\n## [1.4.0]\nx\n\n## [1.3.0]\nx\n' > "$ROT_RAIZ/fuera.md"; ROT_ANTES="$(wc -c < "$ROT_RAIZ/fuera.md")"
printf '{ "agentes": { "agente_codigo": "desarrollador" }, "rotacion": { "activo": true, "umbral_bytes": 10, "conservar_secciones": 1, "artefactos": ["../fuera.md"] } }' > "$ROT_FUERA/.arnes/config.json"
rot_corre "$ROT_FUERA"
rot_check "rotacion con ruta '../fuera.md' NO toca nada fuera del proyecto" "$ROT_ANTES-no" \
  "$(wc -c < "$ROT_RAIZ/fuera.md")-$([ -e "$ROT_RAIZ/fuera-archivo.md" ] && echo si || echo no)"
rm -rf "$ROT_RAIZ"

# La misma contencion fisica para la rotacion: un artefacto bajo un directorio enlazado
# hacia fuera no se toca. SKIP donde no hay symlinks reales; lo ejecuta el CI en Linux.
SYR_RAIZ="$(mktemp -d)"; SYR_P="$SYR_RAIZ/proyecto"; SYR_EXT="$SYR_RAIZ/externo"
mkdir -p "$SYR_P/.arnes" "$SYR_EXT"
ln -s "$SYR_EXT" "$SYR_P/bitacoras" 2>/dev/null
if [ -L "$SYR_P/bitacoras" ]; then
  printf '# fuera\n\n## [1.5.0]\nx\n\n## [1.4.0]\nx\n\n## [1.3.0]\nx\n' > "$SYR_EXT/LOG.md"; SYR_ANTES="$(wc -c < "$SYR_EXT/LOG.md")"
  printf '{ "agentes": { "agente_codigo": "desarrollador" }, "rotacion": { "activo": true, "umbral_bytes": 10, "conservar_secciones": 1, "artefactos": ["bitacoras/LOG.md"] } }' > "$SYR_P/.arnes/config.json"
  rot_corre "$SYR_P"
  rot_check "rotacion bajo un directorio symlink hacia fuera NO toca el externo" "$SYR_ANTES-no" \
    "$(wc -c < "$SYR_EXT/LOG.md")-$([ -e "$SYR_EXT/LOG-archivo.md" ] && echo si || echo no)"
else
  echo "  SKIP  rotacion bajo un directorio symlink hacia fuera NO toca el externo  (sin symlinks reales en esta plataforma)"
fi
rm -rf "$SYR_RAIZ"

# `umbral_bytes` mide BYTES. Un archivo UTF-8 de ~4 000 bytes y ~2 000 caracteres con umbral
# 3 000 rotaba en 1.29.2 y dejo de rotar en 1.29.3, cuando ${#texto} sustituyo a wc -c.
ROT_U="$(mktemp -d)"; mkdir -p "$ROT_U/.arnes"
printf '{ "agentes": { "agente_codigo": "desarrollador" }, "rotacion": { "activo": true, "umbral_bytes": 3000, "conservar_secciones": 1, "artefactos": ["UTF8.md"] } }' > "$ROT_U/.arnes/config.json"
{ printf '# UTF8\n\n'; for v in 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in $(seq 1 12); do printf 'áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú\n'; done; printf '\n'; done; } > "$ROT_U/UTF8.md"
ROT_UB="$(LC_ALL=C; t="$(cat "$ROT_U/UTF8.md")"; printf '%s' "${#t}")"
rot_corre "$ROT_U"
rot_check "umbral_bytes mide BYTES: UTF-8 de ${ROT_UB} bytes (< chars×2) con umbral 3000 ROTA" "1" "$(rot_sec "$ROT_U/UTF8.md")"
rm -rf "$ROT_U"

# Inerte en repo ajeno, como el resto de hooks.
ROT_AJENO="$(mktemp -d)"; printf '# CHANGELOG de OTRO\n## [9.9.9]\nx\n' > "$ROT_AJENO/CHANGELOG.md"
rot_corre "$ROT_AJENO"; ROT_RC=$?
rot_check "sin manifiesto no toca nada y sale 0" "1-0" "$(rot_sec "$ROT_AJENO/CHANGELOG.md")-$ROT_RC"
rm -rf "$ROT_AJENO"

