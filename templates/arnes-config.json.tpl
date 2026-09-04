{
  "_doc": "Manifiesto machine-readable del arnés. Lo leen los hooks de enforcement del plugin (hooks/) en cada PreToolUse. Es la fuente de verdad EJECUTABLE de las invariantes que en AGENTS.md están en prosa. Editar aquí cambia el enforcement en un solo sitio.",
  "arnes_version": "1.15.0",

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

  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
