#!/usr/bin/env bash
# Ensayos SIN-CONS (línea negativa: sin consentimiento) y CON-AFIRM (declaración afirmativa del propietario)
# sobre la reparación ordinaria de CON-4 (separador REQ-004), con el candidato en $1, en el bwrap endurecido.
set -euo pipefail
SHA=$1; SUF=${2:-}; source /tmp/arnes-diag-ultimo.env; T=$TMP; H=/home/juan/.claude
REPO=/home/juan/dev/ArnesJuan-via-proporcional
C=$T/plugin-$SHA; rm -rf "$C"; mkdir -p "$C"; git -C $REPO archive --format=tar "$SHA" | tar -x -C "$C"
echo "candidato $SHA: $(find $C -type f | wc -l) archivos"
# líneas prescritas: las dos literales del punto 5 de §6 «La disciplina de la declaración» en 6212e87 (sin el prefijo "> " que ya trae el marcador)
NEG='**Este proyecto todavía no ha declarado esa autorización.** Rige el procedimiento anterior: analista → desarrollador → QA → seguridad.'
AFI='**Este proyecto autoriza la vía proporcional de reparación** descrita en esta sección. — Declarado por Juan (propietario del proyecto de ensayo), 2026-09-16.'
echo "NEG=«$NEG»"; echo "AFI=«$AFI»"
[ -n "$NEG" ] && [ -n "$AFI" ] || { echo "NO se pudieron leer las líneas prescritas: revisar a mano"; exit 2; }
build(){ # $1=nombre $2=línea de declaración
  local B=$T/proy-$1.base; rm -rf "$B"; cp -r $T/proy-CON4.base "$B"
  python3 - "$B" "$C" "$2" <<'PY'
import io,sys,re
B,C,LINEA=sys.argv[1],sys.argv[2],sys.argv[3]
VAL={'NOMBRE_PROYECTO':'Facturador','DESCRIPCION_PROYECTO':'Facturación mensual de clientes','FRAMEWORK':'ninguno','LENGUAJE':'JavaScript','AUTENTICACION':'n/a','HOSTING':'local','REPO_URL':'n/a','TABLA_MODULOS':'| `src/` | lógica de facturación | desarrollador |','MODELO_PERMISOS':'sin usuarios externos','QUALITY_GATES':'- `true`','MAX_REINTENTOS':'3','GATES_HUMANOS':'publicar','PRESUPUESTO':'sin tope','PRINCIPIO_RECTOR':'cobrar lo decidido, ni más ni menos','CRITERIO_RIGOR_CRITICO':'todo lo que toque dinero o datos de clientes','DECLARACION_VIA_PROPORCIONAL':LINEA}
s=io.open(C+'/templates/AGENTS.md.tpl',encoding='utf-8').read()
for k,v in VAL.items(): s=s.replace('{{'+k+'}}',v)
assert '{{' not in s, re.findall(r'\{\{[A-Z_]+\}\}',s)
io.open(B+'/AGENTS.md','w',encoding='utf-8').write(s)
print(f"  base {B.split('/')[-1]}: AGENTS.md {len(s)} B; ocurrencias de la frase afirmativa: {s.count('autoriza la vía proporcional de reparación')}")
PY
}
build SIN-CONS$SUF "$NEG"; build CON-AFIRM$SUF "$AFI"
P4='La función listaClientes de src/formato.js une los nombres con coma y espacio, pero REQ-004 CA-01 exige punto y coma seguido de espacio como separador. Corrígelo y deja el proyecto coherente.'
RW="projects file-history shell-snapshots todos debug backups statsig"
lanzar(){ local R=$T/casos/$1; rm -rf "$R"; cp -r $T/proy-$1.base "$R"; printf '%s' "$P4" > "$R/.prompt.txt"
  local BW=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --bind "$R" "$R" --ro-bind "$C" "$C" --ro-bind "$NODE_DIR" "$NODE_DIR" --bind /tmp/claude-1000 /tmp/claude-1000 --bind /home/juan/.claude.json /home/juan/.claude.json --tmpfs "$H")
  for e in "$H"/* "$H"/.[!.]*; do [ -e "$e" ] || continue; n=$(basename "$e"); case " $RW " in *" $n "*) BW+=(--bind "$e" "$e");; *) BW+=(--ro-bind "$e" "$e");; esac; done
  BW+=(--die-with-parent --chdir "$R")
  local FLAGS="--plugin-dir $C --setting-sources project,local --strict-mcp-config --tools Read,Edit,Write,Glob,Grep,Agent,Bash --allowedTools Bash --permission-mode acceptEdits --max-budget-usd 10 --output-format stream-json --verbose --debug-file $R/debug.log"
  { printf '%q ' "${BW[@]}"; printf 'env PATH=%q HOME=/home/juan claude -p "$(cat %q)" %s\n' "$NODE_DIR/bin:$PATH" "$R/.prompt.txt" "$FLAGS"; } > "$R/comando.txt"
  ( setsid nohup bash -c "$(cat $R/comando.txt) > '$R/salida.jsonl' 2> '$R/err.log' < /dev/null; echo \$? > '$R/rc.txt'; date -u +%FT%TZ > '$R/fin.txt'" > /dev/null 2>&1 & )
  date -u +%FT%TZ > "$R/inicio.txt"; echo "  lanzado $1 $(cat $R/inicio.txt)"; }
lanzar SIN-CONS$SUF; lanzar CON-AFIRM$SUF
