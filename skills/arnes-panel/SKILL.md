---
name: arnes-panel
description: Genera un panel HTML interactivo de una sola página con el estado completo del proyecto, leyendo los archivos del arnés (AGENTS.md, requirements/, ESTADO.md, seguridad, ADRs, CHANGELOG). Resumen ejecutivo arriba (para stakeholders) + detalle al hacer clic (para el equipo): cada requerimiento, hallazgo de seguridad y decisión abre su detalle completo en un panel lateral. Úsalo cuando se pida "ver todo el proyecto en un lugar", un panel, dashboard, informe de estado o resumen para presentar. Es de SOLO LECTURA y se regenera cada vez. Trabaja en español.
---

# arnes-panel — panel interactivo de estado del proyecto

Ensambla en **un solo archivo HTML autocontenido** el estado real del proyecto. Es una
**vista**, no una fuente: lee los archivos del arnés y los presenta; nunca los edita ni
inventa contenido.

## Reglas inviolables
- **Solo lectura.** El ÚNICO archivo que escribes es `PANEL.html`. No modificas
  `requirements/`, `AGENTS.md`, los agentes, ni ningún otro archivo fuente.
- **No tocas los agentes** ni disparas el pipeline.
- **No inventas.** Si una fuente no existe o está vacía, marca esa sección/ítem como
  "sin datos" en vez de rellenarla con supuestos. Los datos del panel deben poder
  rastrearse a un archivo real del proyecto.
- **Se regenera.** Sobrescribe siempre `PANEL.html` con una foto fresca.

## Procedimiento
1. Lee `templates/panel.html` de esta skill: es el esqueleto (estilo Swiss + panel lateral
   de detalle + JS) ya armado. NO cambies su CSS ni su JS; solo rellenas las zonas marcadas
   con comentarios `<!-- FILL:... -->`.
2. Lee las fuentes del proyecto (omite las que no existan):
   - `AGENTS.md` (o `CLAUDE.md`) → nombre, visión (§1), stack (§2), módulos (§3).
   - `requirements/` → cada `REQ-*` y `NFR-*`: id, título, **Estado**, y su **contenido
     completo** (historia, criterios Gherkin, notas). El contenido completo se embebe para
     el drill-down.
   - `docs/ESTADO.md` → fase, próximo paso (incl. el "paso 0" si lo hay), bloqueos.
   - `docs/seguridad/registro-seguridad.md` → cada hallazgo: id, severidad, estado y su
     **detalle completo** (descripción, recomendación).
   - `docs/decisions/` → cada ADR: id, título, estado y su **contenido completo**
     (contexto, decisión, consecuencias).
   - `CHANGELOG.md` → últimas 3–5 entradas (actividad reciente), si lo incluyes.
3. Calcula el resumen ejecutivo: conteo de REQ por estado (para la barra de avance),
   nº de tests si está documentado, y el **semáforo de seguridad** = severidad máxima entre
   los hallazgos abiertos (rojo = altos/críticos abiertos, ámbar = medios, verde = ninguno).
4. Rellena el template:
   - Cada `REQ-*`, `NFR-*`, hallazgo y ADR va como fila/ítem **clicable** (con `data-detail`)
     y, además, un bloque oculto en `<!-- FILL: hidden-details -->` con su detalle completo
     (mismo `data-id`). El clic ya está cableado en el JS del template.
   - Próximos pasos y módulos: como lista/tarjetas (no requieren detalle clicable salvo que
     remitan a un REQ).
5. Escribe `PANEL.html` en la raíz del proyecto. Al terminar, di en una línea qué secciones
   se llenaron y cuáles quedaron "sin datos".

## Estilo (fijo: Swiss Modern)
Lo provee `templates/panel.html`: tipografía Archivo + Nunito, fondo blanco, tinta negra,
acento rojo (`#ff3300`) usado SOLO para riesgo/bloqueo y marcas de sección. Color con
significado para los estados (verde=completado, azul=en progreso, gris=pendiente,
rojo=bloqueado). No alteres la paleta ni metas degradados, emojis en encabezados, ni la
fuente Inter.

## Notas
- `PANEL.html` es un artefacto derivado (una foto). Conviene agregarlo a `.gitignore`: no es
  fuente y commitearlo lo deja desactualizado en el historial. Se genera y se comparte/abre
  bajo demanda.
- La skill es independiente del proyecto: vale para cualquier repo que use el arnés.
