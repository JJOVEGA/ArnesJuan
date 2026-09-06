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
    "_doc": "APAGADO salvo que se encienda; un proyecto que no lo active no nota ningún cambio. `exigir_fecha`: un veredicto `aprobado` sin fecha (AAAA-MM-DD dentro de su paréntesis de evidencia: `QA: aprobado (R-045, 2026-09-01)`) no cierra el REQ. `caducan_con_codigo`: tampoco cierra un veredicto anterior al último commit que tocó `codigo_app.globs`, ni con cambios sin comitear en ese código; y sin repositorio git que consultar NO deja pasar, porque una puerta que no puede medir no deja pasar. La fecha sólo se le exige a `aprobado`, que es la única firma que cierra, y el empate del mismo día no caduca (`git log --format=%cs` tiene resolución de día). Antes de encenderlo en un proyecto con REQ ya firmados, mide con `tools/arnes-lectura.sh` cuántos veredictos llevan fecha: los que no la lleven no volverán a cerrar hasta re-validarse. Una fecha FUTURA se acepta y nunca caduca: esta puerta mide contra el código, no contra el reloj; falsearla es una violación declarada de la convención, como `aprobado (con reservas)`.",
    "exigir_fecha": false,
    "caducan_con_codigo": false
  },

  "git": {
    "_doc": "Órdenes de git que NINGÚN agente ejecuta, ni siquiera la sesión coordinadora: descartan o esconden trabajo que puede no ser suyo. El trabajo de un subagente no es atómico para git —mientras escribe, el árbol contiene cambios intermedios de otros— y git no devuelve lo que nunca se comiteó (medido: ~52 archivos sin comitear perdidos en un incidente). ES LA ÚNICA PUERTA QUE NACE ENCENDIDA: las demás novedades cambian cómo se juzga algo y se activan a petición; ésta impide una operación irreversible cuyo valor legítimo dentro de una sesión de agentes es casi nulo. Se apaga con `activo: false` o se sustituye la lista. Cada regla es `subcomando [token...]`: el subcomando debe ser ése y cada token aparecer entre los argumentos, en cualquier posición; un flag corto casa dentro de un grupo (`clean -f` alcanza `-fd` y `-fdx`, no `-n`). Una regla que es SÓLO el subcomando casa la forma desnuda, sin ningún argumento posicional: por eso `stash` deniega y `stash list` no. Mira el comando sin su texto: `git commit -m \"no uses git clean\"` no es un `git clean`.",
    "activo": true,
    "prohibidos": ["clean -f", "reset --hard", "checkout .", "restore .", "stash", "stash push", "stash pop", "stash drop", "stash clear"]
  },

  "limites": {
    "_doc": "OPCIONAL, y casi nunca hace falta: el valor por defecto vive en el código. `bash_max_analisis` es el presupuesto en BYTES de material que el detector de escrituras analiza en un comando de shell (cuerpos de heredoc sin citar más el texto del comando). Por encima del techo el comando se DENIEGA sin analizar —una puerta que no puede medir no deja pasar—, así que subirlo sólo tiene sentido si un comando legítimo y grande topa con él. Sólo se acepta un entero positivo, y sólo puede SUBIR el techo del código: un valor más bajo no daría nada que la puerta no dé ya. Bórralo si no lo necesitas.",
    "bash_max_analisis": 65536
  },

  "rotacion": {
    "_doc": "APAGADA salvo que se encienda: reestructurar un documento que escribió una persona no puede ser el comportamiento por defecto. Cuando un artefacto de bitácora supera `umbral_bytes`, el hook Stop MUEVE sus secciones sobrantes a `<nombre>-archivo.md` y deja un puntero. No resume ni reescribe: un resumen convertiría la bitácora en la versión que el modelo recuerda de la bitácora. Corta sólo en encabezados `## `; si no hay límites seguros, no hace nada. Y nunca borra: primero añade al destino, relee para comprobar que llegó, y sólo entonces recorta el origen.",
    "activo": false,
    "umbral_bytes": 262144,
    "conservar_secciones": 12,
    "_doc_orden": "Qué mitad es «lo viejo» NO se adivina. `nuevo-primero` (por defecto) es la convención del CHANGELOG: lo reciente arriba. Un registro cronológico que añade al final necesita `nuevo-al-final`. Equivocarse aquí archiva lo más RECIENTE, que es justo lo que hay que tener a mano. ESTOS VALORES SON EL DEFECTO: cada artefacto puede declarar el suyo, porque el orden es una propiedad DEL ARTEFACTO. Medido en un proyecto real: el CHANGELOG crece por arriba y el registro de seguridad por abajo, así que un solo orden dejaba la rotación inservible para uno de los dos.",
    "orden": "nuevo-primero",
    "_doc_artefactos": "Cadena u objeto, la misma convención que `quality_gates`. Una cadena hereda los ajustes de arriba; un objeto declara los suyos: { \"ruta\": \"docs/seguridad/registro.md\", \"orden\": \"nuevo-al-final\", \"umbral_bytes\": 100000, \"conservar_secciones\": 8 }. Un objeto con `glob` Y `seccion` rota UNA SECCIÓN de cada archivo que case, en vez del artefacto entero: { \"glob\": \"requirements/REQ-*.md\", \"seccion\": \"## Historial de cambios\", \"conservar_entradas\": 20, \"umbral_bytes\": 65536, \"orden\": \"nuevo-al-final\", \"archivo_dir\": \"requirements/historial\" }. Cuando esa sección supera `umbral_bytes`, mueve sus entradas viejas —líneas que empiezan por `- `, `* `, `### ` o `N. `, con sus continuaciones— a `<archivo_dir>/<nombre>` (por defecto `historial/<nombre>` junto al documento) y deja un puntero. El resto del documento NO SE TOCA: los criterios de aceptación son el contrato, y la cabecera con sus veredictos tampoco se puede alterar. El nombre de la sección se compara EXACTO, nunca por prefijo. Las seis claves: `glob`, `seccion`, `conservar_entradas` (20 por defecto), `umbral_bytes`, `orden` y `archivo_dir`. Qué sección es historia lo decide el proyecto: el arnés no trae ninguna por defecto.",
    "artefactos": []
  },

  "plantillas_origen": ".arnes/plantillas-origen",
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
