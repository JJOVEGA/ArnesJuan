---
name: arnes-upgrade
description: Pone al día el andamiaje de un proyecto ya inicializado con la versión instalada del arnés. Aditivo y quirúrgico, nunca sobrescribe contenido del proyecto. Trabaja en español.
---

# arnes-upgrade — poner al día un proyecto existente

## Por qué existe

Los hooks, los agentes y las skills viven **en el plugin**, así que se actualizan solos.
Los ~10 archivos que `arnes-init` copió al proyecto —`AGENTS.md`, `.arnes/config.json`,
`requirements/README.md`…— **se quedan congelados para siempre**.

La consecuencia es una deriva garantizada en cada versión: **la máquina empieza a exigir
cosas que el `AGENTS.md` del proyecto no describe**, y los agentes, que leen esos archivos,
no se enteran de las capacidades nuevas. La capacidad existe en el arnés y no en los
documentos que la gobiernan.

## Regla de oro

**Aditivo y quirúrgico. Nunca sobrescribas contenido del proyecto.**

Un `AGENTS.md` está lleno de decisiones de ese proyecto: su stack, sus módulos, sus gates,
sus quality gates. Copiar la plantilla encima lo destruiría. Esta skill **añade lo que
falta** y, ante cualquier duda, **pregunta en vez de decidir**.

## Procedimiento

1. **Punto de partida.** Lee `arnes_version` de `.arnes/config.json`. Si no está (proyectos
   anteriores a ese campo), mira `.arnes-initialized`. Si tampoco, **pregunta** desde qué
   versión se migra — no lo adivines.

2. **Destino.** Lee `version` de `.claude-plugin/plugin.json` del plugin instalado.

3. **Si coinciden, para.** Informa que está al día y no toques nada. Idempotente, como
   `arnes-init`.

4. **Qué cambió.** El `CHANGELOG.md` del plugin entre esas dos versiones es la fuente. Lee
   sólo las entradas de ese rango.

5. **Aplica, archivo por archivo:**
   - **Secciones nuevas** en `AGENTS.md` o `requirements/README.md`: insértalas en su sitio,
     conservando intacto lo que ya había.
   - **Campos nuevos** en `.arnes/config.json`: añádelos con su valor por defecto.
   - **Si una sección ya existe pero con contenido distinto:** NO la fusiones. Muestra la
     diferencia y pregunta.
   - **Los REQ existentes no se tocan.** Los campos nuevos son compatibles hacia atrás por
     diseño; un REQ antiguo sin ellos debe seguir cerrando igual.

6. **Enseña el resumen ANTES de escribir** y pide confirmación.

7. **Sólo al final**, actualiza `arnes_version` en `.arnes/config.json`. Ese campo es el
   registro de dónde quedó la migración: si se sube antes de aplicar los cambios, la
   próxima ejecución creerá que ya está hecho.

## Migraciones conocidas

### Hacia 1.16.0
- `AGENTS.md` §6: el tope de vueltas se cuenta **por REQ y no se reinicia**; y la tabla de
  **clases de hallazgo** (`usuario/dinero`, `contrato`, `instrumento`).
- `AGENTS.md` §13: filas nuevas de enforcement (cierre por Bash, clase del hallazgo) y la
  nota de que la cobertura de `Bash` es parcial.
- `requirements/README.md`: campo `Hallazgos abiertos:` en la plantilla y sección
  **Clases de hallazgo**.
- `PENDING_APPROVAL.md`: si la copia del proyecto conserva el ejemplo comentado **bajo**
  `## Pendientes`, muévelo fuera de la sección. Con el `awk` corregido ya no bloquea, pero
  el archivo queda más claro.
- `.arnes/config.json`: `arnes_version` a la versión instalada.

## Reglas

- No inventes contenido de proyecto. Si algo requiere una decisión —un umbral, un nombre,
  una política— **pregunta**.
- No toques `CHANGELOG.md` ni `docs/ESTADO.md` del proyecto: son su bitácora, no andamiaje.
- Si el proyecto personalizó una plantilla, respétalo. Se informa, no se corrige.
- Deja constancia de la migración en el `CHANGELOG.md` del proyecto, con la versión de
  origen y la de destino.
