#!/usr/bin/env bash
# Verificación acotada del destino 1.34.0: fixture limpio desde v1.33.2; registros fuera del proyecto. Uso: lanzar-upg3.sh <SHA del candidato>
set -euo pipefail
SHA=$1; BASE_TAG=v1.33.2; source /tmp/arnes-diag-ultimo.env; T=$TMP; H=/home/juan/.claude
REPO=/home/juan/dev/ArnesJuan-porte-via; C=$T/plugin-$SHA; rm -rf "$C"; mkdir -p "$C"; git -C $REPO archive --format=tar "$SHA" | tar -x -C "$C"
echo "candidato $SHA: $(find $C -type f | wc -l) archivos · plugin.json version=$(jq -r .version $C/.claude-plugin/plugin.json)"
TPL=$T/tpl-$BASE_TAG; rm -rf "$TPL"; mkdir -p "$TPL"; git -C $REPO archive --format=tar "$BASE_TAG" templates | tar -x -C "$TPL"; TPL=$TPL/templates
build(){ local B=$T/proy-$1.base; rm -rf "$B"; mkdir -p "$B"/{.arnes/plantillas-origen,docs/decisions,docs/seguridad,docs/usuario,docs/qa,memory,requirements,.githooks}
  cp -r $T/proy-CON4.base/src "$B/src"; cp $T/proy-CON4.base/requirements/REQ-00*.md "$B/requirements/"
  cp -r "$TPL"/. "$B/.arnes/plantillas-origen/"; cp "$TPL/githooks/pre-commit" "$B/.githooks/pre-commit"; chmod +x "$B/.githooks/pre-commit"
  python3 - "$B" "$TPL" "$2" <<'PY'
import io,sys,re,json,os
B,TPL,MODO=sys.argv[1:4]
VAL={'NOMBRE_PROYECTO':'Facturador','DESCRIPCION_PROYECTO':'Facturación mensual de clientes','FRAMEWORK':'ninguno','LENGUAJE':'JavaScript','AUTENTICACION':'n/a','HOSTING':'local','REPO_URL':'n/a','TABLA_MODULOS':'| `src/` | lógica de facturación | desarrollador |','MODELO_PERMISOS':'sin usuarios externos','QUALITY_GATES':'- `true`','MAX_REINTENTOS':'3','GATES_HUMANOS':'publicar','PRESUPUESTO':'sin tope','PRINCIPIO_RECTOR':'cobrar lo decidido, ni más ni menos','CRITERIO_RIGOR_CRITICO':'todo lo que toque dinero o datos de clientes','ARNES_VERSION':'1.33.2','CODIGO_APP_GLOBS':'["src/*"]','QUALITY_GATES_JSON':'["true"]'}
def fill(name):
    s=io.open(os.path.join(TPL,name),encoding='utf-8').read()
    for k,v in VAL.items(): s=s.replace('{{'+k+'}}',v)
    assert '{{' not in s, (name, re.findall(r'\{\{[A-Z_]+\}\}',s)); return s
for tpl,dst in [('CLAUDE.md.tpl','CLAUDE.md'),('CHANGELOG.md.tpl','CHANGELOG.md'),('PENDING_APPROVAL.md.tpl','PENDING_APPROVAL.md'),('ESTADO.md.tpl','docs/ESTADO.md'),('ARCHITECTURE.md.tpl','ARCHITECTURE.md'),('requirements-README.md.tpl','requirements/README.md'),('arnes-config.json.tpl','.arnes/config.json')]:
    io.open(os.path.join(B,dst),'w',encoding='utf-8').write(fill(tpl))
json.load(io.open(os.path.join(B,'.arnes/config.json'),encoding='utf-8'))
s=fill('AGENTS.md.tpl')
if MODO=='intacto':
    s=s.replace('## 3. Módulos / alcance','**Nota propia de Facturador (personalización, no viene de la plantilla):** el cálculo de IVA vive en `src/iva.js` y lo revisa contabilidad cada trimestre.\n\n## 3. Módulos / alcance',1)
elif MODO=='unknown':
    for n in range(13,5,-1): s=re.sub(r'(?m)^## %d\. '%n,'## %d. '%(n+1),s)
    s=s.replace('## 7. Orquestación','## 6. Glosario del dominio de Facturador\n\n- **Factura:** documento de cobro emitido a un cliente.\n- **Anulación:** factura dejada sin efecto; nunca se borra.\n\n## 7. Orquestación',1)
io.open(os.path.join(B,'AGENTS.md'),'w',encoding='utf-8').write(s)
io.open(os.path.join(B,'.arnes-initialized'),'w',encoding='utf-8').write('fecha: 2026-09-12\narnes_version: 1.33.2\n')
print(f"  base {os.path.basename(B)} ({MODO}): secciones {re.findall(r'(?m)^## (\d+)\.',s)}; afirmativa {s.count('autoriza la vía proporcional')}")
PY
  git -C "$B" init -q && git -C "$B" add -A && git -C "$B" -c user.name=ensayo -c user.email=ensayo@local commit -q -m "proyecto de ensayo instalado con arnés v1.33.2" && echo "  git limpio: $(git -C "$B" rev-parse --short HEAD)"; }
build UPG3-INTACTO intacto; build UPG3-UNKNOWN unknown
RW="projects file-history shell-snapshots todos debug backups statsig"
lanzar(){ local R=$T/casos/$1; local O=$T/salidas/$1; rm -rf "$R" "$O"; mkdir -p "$O"; cp -r $T/proy-$2.base "$R"; rm -rf "$R/.git"; git -C "$R" init -q; git -C "$R" add -A; git -C "$R" -c user.name=ensayo -c user.email=ensayo@local commit -q -m "proyecto de ensayo instalado con arnés v1.33.2"; printf '%s' '/arnes-upgrade' > "$O/prompt.txt"
  local BW=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --bind "$R" "$R" --bind "$O" "$O" --ro-bind "$C" "$C" --ro-bind "$NODE_DIR" "$NODE_DIR" --bind /tmp/claude-1000 /tmp/claude-1000 --bind /home/juan/.claude.json /home/juan/.claude.json --tmpfs "$H")
  for e in "$H"/* "$H"/.[!.]*; do [ -e "$e" ] || continue; n=$(basename "$e"); case " $RW " in *" $n "*) BW+=(--bind "$e" "$e");; *) BW+=(--ro-bind "$e" "$e");; esac; done
  BW+=(--die-with-parent --chdir "$R")
  local FLAGS="--plugin-dir $C --setting-sources project,local --strict-mcp-config --tools Read,Edit,Write,Glob,Grep,Agent,Bash,Skill --allowedTools Bash --permission-mode acceptEdits --max-budget-usd 10 --output-format stream-json --verbose --debug-file $O/debug.log"
  { printf '%q ' "${BW[@]}"; printf 'env PATH=%q HOME=/home/juan claude -p "$(cat %q)" %s\n' "$NODE_DIR/bin:$PATH" "$O/prompt.txt" "$FLAGS"; } > "$O/comando.txt"
  ( setsid nohup bash -c "$(cat $O/comando.txt) > '$O/salida.jsonl' 2> '$O/err.log' < /dev/null; echo \$? > '$O/rc.txt'; date -u +%FT%TZ > '$O/fin.txt'" > /dev/null 2>&1 & )
  date -u +%FT%TZ > "$O/inicio.txt"; echo "  lanzado $1 $(cat $O/inicio.txt)"; }
lanzar UPG3-INTACTO-1 UPG3-INTACTO; lanzar UPG3-INTACTO-2 UPG3-INTACTO; lanzar UPG3-INTACTO-3 UPG3-INTACTO; lanzar UPG3-UNKNOWN UPG3-UNKNOWN
