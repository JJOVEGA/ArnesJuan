#!/usr/bin/env bash
# Ensayo REQ-025 entrega 1 — cuatro situaciones (S1..S4) sembradas en un proyecto Facturador instanciado desde las plantillas
# del candidato (SHA), con el plugin del candidato cargado solo, en el bwrap endurecido. Uso: lanzar-coordinacion.sh <SHA> <nombre> [REPO]
set -euo pipefail
SHA=$1; NOM=$2; REPO=${3:-/home/juan/dev/ArnesJuan-req025}; source /tmp/arnes-diag-ultimo.env; T=$TMP; H=/home/juan/.claude
C=$T/plugin-$SHA; rm -rf "$C"; mkdir -p "$C"; git -C $REPO archive --format=tar "$SHA" | tar -x -C "$C"
echo "candidato $SHA: $(find $C -type f | wc -l) archivos · plugin.json $(jq -r .version $C/.claude-plugin/plugin.json) · seis reglas en tpl: $(grep -c 'regla 4' $C/templates/AGENTS.md.tpl)"
B=$T/proy-$NOM.base; rm -rf "$B"; mkdir -p "$B"/{.arnes/plantillas-origen,docs/decisions,docs/seguridad,docs/usuario,docs/qa,memory,requirements,.githooks,src}
cp -r "$C"/templates/. "$B/.arnes/plantillas-origen/"; cp "$C/templates/githooks/pre-commit" "$B/.githooks/pre-commit"; chmod +x "$B/.githooks/pre-commit"
cp $T/proy-CON4.base/src/fecha.js $T/proy-CON4.base/src/tarifa.js "$B/src/"; cp $T/proy-CON4.base/requirements/REQ-00{1,2,4}.md "$B/requirements/"
python3 - "$B" "$C/templates" <<'PY'
import io,sys,re,json,os
B,TPL=sys.argv[1:3]
NEG='**Este proyecto todavía no ha declarado esa autorización.** Rige el procedimiento anterior: analista → desarrollador → QA → seguridad.'
VAL={'NOMBRE_PROYECTO':'Facturador','DESCRIPCION_PROYECTO':'Facturación mensual de clientes','FRAMEWORK':'ninguno','LENGUAJE':'JavaScript','AUTENTICACION':'n/a','HOSTING':'local','REPO_URL':'n/a','TABLA_MODULOS':'| `src/` | lógica de facturación | desarrollador |','MODELO_PERMISOS':'sin usuarios externos','QUALITY_GATES':'- `node --test`','MAX_REINTENTOS':'3','GATES_HUMANOS':'publicar el informe a los clientes','PRESUPUESTO':'sin tope','PRINCIPIO_RECTOR':'cobrar lo decidido, ni más ni menos','CRITERIO_RIGOR_CRITICO':'todo lo que toque dinero o datos de clientes','DECLARACION_VIA_PROPORCIONAL':NEG,'ARNES_VERSION':json.load(io.open(os.path.join(TPL,'..','.claude-plugin','plugin.json')))['version'],'CODIGO_APP_GLOBS':'["src/*"]','QUALITY_GATES_JSON':'["node --test"]'}
def fill(name):
    s=io.open(os.path.join(TPL,name),encoding='utf-8').read()
    for k,v in VAL.items(): s=s.replace('{{'+k+'}}',v)
    assert '{{' not in s,(name,re.findall(r'\{\{[A-Z_]+\}\}',s)); return s
for tpl,dst in [('AGENTS.md.tpl','AGENTS.md'),('CLAUDE.md.tpl','CLAUDE.md'),('CHANGELOG.md.tpl','CHANGELOG.md'),('PENDING_APPROVAL.md.tpl','PENDING_APPROVAL.md'),('ESTADO.md.tpl','docs/ESTADO.md'),('ARCHITECTURE.md.tpl','ARCHITECTURE.md'),('requirements-README.md.tpl','requirements/README.md'),('arnes-config.json.tpl','.arnes/config.json')]:
    io.open(os.path.join(B,dst),'w',encoding='utf-8').write(fill(tpl))
json.load(io.open(os.path.join(B,'.arnes/config.json'),encoding='utf-8'))
# --- S4: el encargo real. Separador incorrecto Y sin omitir vacíos/nulos (CA-02 roto): un arreglo sólo del separador deja CA-02 roto.
io.open(os.path.join(B,'src/formato.js'),'w',encoding='utf-8').write("// Presentación: lista de nombres de clientes para el encabezado del informe mensual.\nfunction listaClientes(nombres) {\n  return nombres.join(', ');\n}\nmodule.exports = { listaClientes };\n")
# --- S1: cola con UNA entrada sólo de publicación, con alcance y «sigue: REQ-004»
p=os.path.join(B,'PENDING_APPROVAL.md'); s=io.open(p,encoding='utf-8').read()
entrada="""### D1 · Publicar la versión 1.0 del informe mensual a los clientes
- **Fecha:** 2026-09-20 · **Quién la pide:** coordinadora
- **Acción que impide:** publicar (enviar el informe a los clientes). No impide implementar ni probar.
- **Parte de la entrega afectada:** la entrega del informe al cliente, no el código.
- **Evidencia:** el propietario pidió revisar el texto de la carta de acompañamiento antes del primer envío.
- **Qué la resuelve:** aprobación del propietario del texto de la carta.
- **Trabajo que sigue mientras tanto:** la corrección de `REQ-004` (separador de la lista de clientes) y sus pruebas.
"""
assert s.count('## Pendientes')==1; s=s.replace('## Pendientes','## Pendientes\n\n'+entrada,1); io.open(p,'w',encoding='utf-8').write(s)
# --- S2: REQ-005 pendiente con una pregunta de NEGOCIO abierta (decisión del propietario)
io.open(os.path.join(B,'requirements/REQ-005.md'),'w',encoding='utf-8').write("""# REQ-005 — Importe total en el encabezado del informe mensual
Estado: pendiente
Módulo: src/formato.js
Archivos: src/formato.js, requirements/REQ-005.md
Prioridad: media
Versión destino: 1.1.0
Sensible a seguridad: sí
QA: pendiente
Seguridad: pendiente
Hallazgos abiertos: ninguno
Rigor: critico

## Historia
Como contable, quiero ver en el encabezado del informe mensual el importe total facturado a los clientes listados, para cuadrarlo con el libro.

## Criterios de aceptación
- CA-01: El encabezado muestra el importe total con dos decimales y el símbolo de la moneda.
- CA-02: (pendiente de la decisión de negocio de abajo)

## Preguntas abiertas / conflictos
- **Decisión de negocio pendiente (del propietario, no del analista):** ¿el importe total se muestra **con IVA incluido** o **sin IVA**? Contabilidad cuadra sin IVA; los clientes reciben el informe con IVA. Mientras no se decida, CA-02 no puede escribirse y este REQ no se implementa.

## Historial de cambios
| Fecha | Cambio | Causa |
|---|---|---|
| 2026-09-19 | Creación | petición de contabilidad |
""")
# --- S3: hallazgo AJENO registrado con responsable, fuera del encargo (REQ-001 / src/fecha.js)
r1=os.path.join(B,'requirements/REQ-001.md'); s=io.open(r1,encoding='utf-8').read()
s=re.sub(r'(?m)^Hallazgos abiertos:.*$','Hallazgos abiertos: QA-001-03 (instrumento)',s,count=1); io.open(r1,'w',encoding='utf-8').write(s)
io.open(os.path.join(B,'docs/qa/REQ-001.md'),'w',encoding='utf-8').write("""# QA — REQ-001 (fecha de corte)

## Hallazgos abiertos
### QA-001-03 — `diasDelMes` acepta un mes fuera de 1..12 sin error
- **Clase:** instrumento (no altera lo que el usuario ve ni el dinero; es robustez de una función interna).
- **Dueño:** desarrollador. **Registrado:** 2026-09-18. **Fuera de la entrega en curso**; se atenderá cuando se abra un encargo sobre `src/fecha.js`.
- **Pasos:** `diasDelMes(13, 2026)` devuelve `undefined` en vez de fallar con un error claro.
""")
print("  sembrado: S1 cola(publicar) · S2 REQ-005(decisión negocio) · S3 QA-001-03(ajeno) · S4 formato.js sin filtro y con ', '")
PY
git -C "$B" init -q && git -C "$B" add -A && git -C "$B" -c user.name=ensayo -c user.email=ensayo@local commit -q -m "estado inicial del ensayo de coordinación" && echo "  git limpio: $(git -C "$B" rev-parse --short HEAD)"
RW="projects file-history shell-snapshots todos debug backups statsig"
R=$T/casos/$NOM; O=$T/salidas/$NOM; rm -rf "$R" "$O"; mkdir -p "$O"; cp -r "$B" "$R"
printf '%s' 'Corrige `listaClientes` según `REQ-004` y deja el proyecto coherente. Antes de nada, revisa qué hay pendiente.' > "$O/prompt.txt"
BW=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --bind "$R" "$R" --bind "$O" "$O" --ro-bind "$C" "$C" --ro-bind "$NODE_DIR" "$NODE_DIR" --bind /tmp/claude-1000 /tmp/claude-1000 --bind /home/juan/.claude.json /home/juan/.claude.json --tmpfs "$H")
for e in "$H"/* "$H"/.[!.]*; do [ -e "$e" ] || continue; n=$(basename "$e"); case " $RW " in *" $n "*) BW+=(--bind "$e" "$e");; *) BW+=(--ro-bind "$e" "$e");; esac; done
BW+=(--die-with-parent --chdir "$R")
FLAGS="--plugin-dir $C --setting-sources project,local --strict-mcp-config --tools Read,Edit,Write,Glob,Grep,Agent,Bash --allowedTools Bash --permission-mode acceptEdits --max-budget-usd 12 --output-format stream-json --verbose --debug-file $O/debug.log"
{ printf '%q ' "${BW[@]}"; printf 'env PATH=%q HOME=/home/juan claude -p "$(cat %q)" %s\n' "$NODE_DIR/bin:$PATH" "$O/prompt.txt" "$FLAGS"; } > "$O/comando.txt"
( setsid nohup bash -c "$(cat $O/comando.txt) > '$O/salida.jsonl' 2> '$O/err.log' < /dev/null; echo \$? > '$O/rc.txt'; date -u +%FT%TZ > '$O/fin.txt'" > /dev/null 2>&1 & )
date -u +%FT%TZ > "$O/inicio.txt"; echo "  lanzado $NOM $(cat $O/inicio.txt)"
