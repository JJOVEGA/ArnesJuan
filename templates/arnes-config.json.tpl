{
  "_doc": "Manifiesto machine-readable del arnés. Lo leen los hooks de enforcement del plugin (hooks/) en cada PreToolUse. Es la fuente de verdad EJECUTABLE de las invariantes que en AGENTS.md están en prosa. Editar aquí cambia el enforcement en un solo sitio.",
  "arnes_version": "{{ARNES_VERSION}}",

  "agentes": {
    "_doc": "El nombre llega al hook en el campo `agent_type`. Sólo `agente_codigo` puede editar `codigo_app.globs`. Basta el nombre corto: el hook tolera el prefijo del plugin que Claude Code añade en runtime (`arnes-juan:desarrollador`). Escribirlo CON prefijo es opcional y hace la comparación estricta con ese proveedor.",
    "agente_codigo": "desarrollador",
    "conocidos": ["analista-requerimientos", "desarrollador", "qa-tester", "auditor-seguridad"]
  },

  "codigo_app": {
    "_doc": "Rutas (relativas a la raíz) que SÓLO el agente de código puede editar. Apunta a código de PRODUCCIÓN; deja fuera tests y fixtures para que el qa-tester pueda editarlos. Patrones estilo shell; '*' abarca también separadores '/'. Ej.: \"src/*\", \"app/*\", \"lib/*\", \"*.py\".",
    "globs": [{{CODIGO_APP_GLOBS}}]
  },

  "quality_gates": [{{QUALITY_GATES_JSON}}],

  "estados": {
    "completado": "completado",
    "todos": ["borrador", "pendiente", "en-progreso", "en-revisión", "completado", "bloqueado"]
  },

  "estado_derivado": {
    "_doc": "Bloque de continuidad que el hook Stop/SubagentStop DERIVA leyendo el disco y escribe entre marcadores en `archivo`. No lo redacta ningún agente: un resumen escrito por el modelo miente justo cuando más falta hace, que es cuando le queda poco contexto. Fuera de los marcadores no se toca nada. Pon `activo: false` para apagarlo.",
    "activo": true,
    "archivo": "docs/ESTADO.md"
  },

  "veredictos": {
    "_doc": "APAGADO salvo que se encienda. `exigir_fecha`: un veredicto `aprobado` sin fecha (AAAA-MM-DD dentro de su paréntesis de evidencia: `QA: aprobado (R-045, 2026-09-01)`) no cierra el REQ. `caducan_con_codigo`: tampoco cierra un veredicto anterior al último commit que tocó `codigo_app.globs`, ni con cambios sin commit en ese código; y sin repositorio git que consultar, NO deja pasar. Un veredicto es una foto: sólo vale si el sujeto estaba quieto. Antes de encenderlo en un proyecto con REQ ya cerrados, mide con `tools/arnes-lectura.sh` cuántos veredictos llevan fecha: los que no la lleven no volverán a cerrar hasta re-validarse.",
    "exigir_fecha": false,
    "caducan_con_codigo": false
  },

  "git": {
    "_doc": "Órdenes de git que NINGÚN agente ejecuta: descartan o esconden trabajo que puede no ser suyo (con agentes en vuelo el árbol contiene estados intermedios de otros; medido: ~52 archivos sin comitear perdidos en un incidente). Cada regla es `subcomando [token...]`: el subcomando debe ser ése y cada token aparecer entre los argumentos. Matices fijos: `stash list|show`, `restore --staged` y `clean -n` no cuentan. Mira el comando SIN su texto: `git commit -m \"no uses git clean\"` no es un `git clean`. ENCENDIDO por defecto; se apaga con `activo: false` o se sustituye la lista.",
    "activo": true,
    "prohibidos": ["clean", "reset --hard", "checkout .", "restore .", "stash"]
  },

  "rotacion": {
    "_doc": "APAGADA salvo que se encienda: reestructurar un documento que escribió una persona no puede ser el comportamiento por defecto. Cuando un artefacto de bitácora supera `umbral_bytes`, el hook Stop MUEVE sus secciones sobrantes a `<nombre>-archivo.md` y deja un puntero. No resume ni reescribe: un resumen convertiría la bitácora en la versión que el modelo recuerda de la bitácora. Corta sólo en encabezados `## `; si no hay límites seguros, no hace nada. Y nunca borra: primero añade al destino, relee para comprobar que llegó, y sólo entonces recorta el origen.",
    "activo": false,
    "umbral_bytes": 262144,
    "conservar_secciones": 12,
    "_doc_orden": "Qué mitad es «lo viejo» NO se adivina. `nuevo-primero` (por defecto) es la convención del CHANGELOG: lo reciente arriba. Un registro cronológico que añade al final necesita `nuevo-al-final`. Equivocarse aquí archiva lo más RECIENTE, que es justo lo que hay que tener a mano. ESTOS VALORES SON EL DEFECTO: cada artefacto puede declarar el suyo, porque el orden es una propiedad DEL ARTEFACTO. Medido en un proyecto real: el CHANGELOG crece por arriba y el registro de seguridad por abajo, así que un solo orden dejaba la rotación inservible para uno de los dos.",
    "orden": "nuevo-primero",
    "_doc_artefactos": "Cadena u objeto, la misma convención que `quality_gates`. Una cadena hereda los ajustes de arriba; un objeto declara los suyos: { \"ruta\": \"docs/seguridad/registro.md\", \"orden\": \"nuevo-al-final\", \"umbral_bytes\": 100000, \"conservar_secciones\": 8 }. Un objeto con `glob` y `seccion` rota UNA SECCIÓN de cada archivo que case —{ \"glob\": \"requirements/*.md\", \"seccion\": \"## Historial\", \"conservar_entradas\": 20, \"umbral_bytes\": 65536, \"orden\": \"nuevo-al-final\" }—: cuando esa sección supera `umbral_bytes`, mueve sus entradas viejas (líneas que empiezan por `- `, `* `, `### ` o `N. `, con sus continuaciones) a `historial/<nombre>.md` junto al documento (o a `archivo_dir`) y deja un puntero. El resto del documento no se toca: los criterios de aceptación son el contrato. Qué sección es historia lo decide el proyecto.",
    "artefactos": []
  },

  "plantillas_origen": ".arnes/plantillas-origen",
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
