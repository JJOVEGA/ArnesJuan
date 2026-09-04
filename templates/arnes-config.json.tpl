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

  "rotacion": {
    "_doc": "APAGADA salvo que se encienda: reestructurar un documento que escribió una persona no puede ser el comportamiento por defecto. Cuando un artefacto de bitácora supera `umbral_bytes`, el hook Stop MUEVE sus secciones sobrantes a `<nombre>-archivo.md` y deja un puntero. No resume ni reescribe: un resumen convertiría la bitácora en la versión que el modelo recuerda de la bitácora. Corta sólo en encabezados `## `; si no hay límites seguros, no hace nada. Y nunca borra: primero añade al destino, relee para comprobar que llegó, y sólo entonces recorta el origen.",
    "activo": false,
    "umbral_bytes": 262144,
    "conservar_secciones": 12,
    "_doc_orden": "Qué mitad es «lo viejo» NO se adivina. `nuevo-primero` (por defecto) es la convención del CHANGELOG: lo reciente arriba. Un registro cronológico que añade al final necesita `nuevo-al-final`. Equivocarse aquí archiva lo más RECIENTE, que es justo lo que hay que tener a mano.",
    "orden": "nuevo-primero",
    "artefactos": []
  },

  "plantillas_origen": ".arnes/plantillas-origen",
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
