#!/usr/bin/env bash
# Ensayos de instalación (arnes-init) y actualización (arnes-upgrade) con el porte 404e044, en el bwrap endurecido.
set -euo pipefail
SHA=404e044; BASE_TAG=v1.33.1; source /tmp/arnes-diag-ultimo.env; T=$TMP; H=/home/juan/.claude
REPO=/home/juan/dev/ArnesJuan-via-proporcional; C=$T/plugin-$SHA; [ -d "$C" ] || { echo "falta $C"; exit 2; }
TPL=$T/tpl-$BASE_TAG; rm -rf "$TPL"; mkdir -p "$TPL"; git -C $REPO archive --format=tar "$BASE_TAG" templates | tar -x -C "$TPL"
build(){ # $1=nombre $2=modo (init|intacto|modif|unknown)
  local B=$T/proy-$1.base; rm -rf "$B"; cp -r $T/proy-CON4.base "$B"; rm -rf "$B/.git"
  if [ "$2" = init ]; then rm -rf "$B"/{AGENTS.md,CLAUDE.md,CHANGELOG.md,PENDING_APPROVAL.md,docs,requirements,.arnes,.arnes-initialized}; printf '# Facturador\n' > "$B/README.md"
  else
    mkdir -p "$B/.arnes/plantillas-origen"; cp -r "$TPL"/templates/. "$B/.arnes/plantillas-origen/"
    python3 - "$B" "$TPL/templates/AGENTS.md.tpl" "$2" <<'PY'
import io,sys,re,json
B,TPLF,MODO=sys.argv[1:4]
VAL={'NOMBRE_PROYECTO':'Facturador','DESCRIPCION_PROYECTO':'Facturación mensual de clientes','FRAMEWORK':'ninguno','LENGUAJE':'JavaScript','AUTENTICACION':'n/a','HOSTING':'local','REPO_URL':'n/a','TABLA_MODULOS':'| `src/` | lógica de facturación | desarrollador |','MODELO_PERMISOS':'sin usuarios externos','QUALITY_GATES':'- `true`','MAX_REINTENTOS':'3','GATES_HUMANOS':'publicar','PRESUPUESTO':'sin tope','PRINCIPIO_RECTOR':'cobrar lo decidido, ni más ni menos','CRITERIO_RIGOR_CRITICO':'todo lo que toque dinero o datos de clientes'}
s=io.open(TPLF,encoding='utf-8').read()
for k,v in VAL.items(): s=s.replace('{{'+k+'}}',v)
assert '{{' not in s, re.findall(r'\{\{[A-Z_]+\}\}',s)
if MODO=='intacto':
    s=s.replace('## 3. Módulos / alcance','**Nota propia de Facturador (personalización, no viene de la plantilla):** el cálculo de IVA vive en `src/iva.js` y lo revisa contabilidad cada trimestre.\n\n## 3. Módulos / alcance',1)
elif MODO=='modif':
    i=s.index('**Flujo:**'); j=s.index('\n',i)
    s=s[:j+1]+'\n**Regla propia de Facturador (personalización de §6, no viene de la plantilla):** toda factura anulada exige revisión del `auditor-seguridad` antes de cerrar su REQ.\n'+s[j+1:]
elif MODO=='unknown':
    for n in range(13,5,-1): s=re.sub(r'(?m)^## %d\. '%n,'## %d. '%(n+1),s)
    s=s.replace('## 7. Orquestación','## 6. Glosario del dominio de Facturador\n\n- **Factura:** documento de cobro emitido a un cliente.\n- **Anulación:** factura dejada sin efecto; nunca se borra.\n\n## 7. Orquestación',1)
io.open(B+'/AGENTS.md','w',encoding='utf-8').write(s)
c=json.load(io.open(B+'/.arnes/config.json',encoding='utf-8')); c['arnes_version']='1.33.1'
io.open(B+'/.arnes/config.json','w',encoding='utf-8').write(json.dumps(c,ensure_ascii=False,indent=2)+'\n')
print(f"  base {B.split('/')[-1]} ({MODO}): AGENTS.md {len(s)} B; secciones: {re.findall(r'(?m)^## (\d+)\.',s)}; afirmativa: {s.count('autoriza la vía proporcional')}")
PY
  fi
  git -C "$B" init -q && git -C "$B" add -A && git -C "$B" -c user.name=ensayo -c user.email=ensayo@local commit -q -m "estado inicial del proyecto de ensayo" && echo "  git limpio en $1: $(git -C "$B" rev-parse --short HEAD)"
}
build INIT-P init; build UPG-INTACTO-P intacto; build UPG-MODIF-P modif; build UPG-UNKNOWN-P unknown
RW="projects file-history shell-snapshots todos debug backups statsig"
lanzar(){ # $1=nombre $2=prompt
  local R=$T/casos/$1; rm -rf "$R"; cp -r $T/proy-$1.base "$R"; printf '%s' "$2" > "$R/.prompt.txt"
  local BW=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --bind "$R" "$R" --ro-bind "$C" "$C" --ro-bind "$NODE_DIR" "$NODE_DIR" --bind /tmp/claude-1000 /tmp/claude-1000 --bind /home/juan/.claude.json /home/juan/.claude.json --tmpfs "$H")
  for e in "$H"/* "$H"/.[!.]*; do [ -e "$e" ] || continue; n=$(basename "$e"); case " $RW " in *" $n "*) BW+=(--bind "$e" "$e");; *) BW+=(--ro-bind "$e" "$e");; esac; done
  BW+=(--die-with-parent --chdir "$R")
  local FLAGS="--plugin-dir $C --setting-sources project,local --strict-mcp-config --tools Read,Edit,Write,Glob,Grep,Agent,Bash,Skill --allowedTools Bash --permission-mode acceptEdits --max-budget-usd 10 --output-format stream-json --verbose --debug-file $R/debug.log"
  { printf '%q ' "${BW[@]}"; printf 'env PATH=%q HOME=/home/juan claude -p "$(cat %q)" %s\n' "$NODE_DIR/bin:$PATH" "$R/.prompt.txt" "$FLAGS"; } > "$R/comando.txt"
  ( setsid nohup bash -c "$(cat $R/comando.txt) > '$R/salida.jsonl' 2> '$R/err.log' < /dev/null; echo \$? > '$R/rc.txt'; date -u +%FT%TZ > '$R/fin.txt'" > /dev/null 2>&1 & )
  date -u +%FT%TZ > "$R/inicio.txt"; echo "  lanzado $1 $(cat $R/inicio.txt)"; }
lanzar INIT-P '/arnes-init'
lanzar UPG-INTACTO-P '/arnes-upgrade'
lanzar UPG-MODIF-P '/arnes-upgrade'
lanzar UPG-UNKNOWN-P '/arnes-upgrade'
