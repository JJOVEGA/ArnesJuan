#!/usr/bin/env bash
# monta.sh <arbol-de-plantillas> <destino>: proyecto «tienda-demo» con AGENTS.md, README, manifiesto y CLAUDE.md de la plantilla
set -euo pipefail
TPL="$1/templates"; P="$2"
rellena() { local t; t="$(<"$1")"
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
  printf '%s\n' "$t" > "$2"; }
mkdir -p "$P/requirements" "$P/.arnes" "$P/src/pagos" "$P/src/catalogo" "$P/src/auth" "$P/db"
rellena "$TPL/AGENTS.md.tpl" "$P/AGENTS.md"; rellena "$TPL/requirements-README.md.tpl" "$P/requirements/README.md"
rellena "$TPL/arnes-config.json.tpl" "$P/.arnes/config.json"; rellena "$TPL/CLAUDE.md.tpl" "$P/CLAUDE.md"
printf 'export function filtrar(items, {categoria}) {\n  return items.filter(i => !categoria || i.categoria === categoria);\n}\n' > "$P/src/catalogo/filtro.ts"
printf 'export function totalCarrito(lineas) {\n  return lineas.reduce((s, l) => s + l.precio * l.cantidad, 0);\n}\n' > "$P/src/pagos/total.ts"
printf 'export const puede = (u, accion) => u.roles.includes(accion);\n' > "$P/src/auth/permisos.ts"
jq -e . "$P/.arnes/config.json" >/dev/null
if grep -q '{{' "$P/AGENTS.md" "$P/requirements/README.md" "$P/.arnes/config.json" "$P/CLAUDE.md"; then echo "marcadores sin rellenar en $P" >&2; exit 2; fi
