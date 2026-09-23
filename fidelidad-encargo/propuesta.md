# Fidelidad al encargo — propuesta mínima, diff SIN aplicar (revisión 2, 2026-09-23)

**Cabeza revisada:** `main` = `cfb1106`. Archivos leídos: `AGENTS.md` §6, `agents/analista-requerimientos.md`, `agents/qa-tester.md`, `requirements/README.md` (Definition of Ready, Plantilla) y sus gemelas en `templates/`.
**Evidencia de partida, y cómo se atribuye.** `docs/evidencia/informe-prueba-arnes.md` de `JJOVEGA/demo-conciliador` **sigue inaccesible desde esta sesión** (HTTP 404 para la cuenta `jvega-habitat`, reintentado el 2026-09-23 con red operativa). Lo que se usa es el **informe aportado por el propietario**: cuatro diferencias sin autorización localizada —criterio de emparejamiento, resolución automática de ambiguos, exclusión de asociaciones manuales, tolerancia de fechas— que **no aparecen en el encargo que recibió aquella sesión**. **No se sabe** si se perdieron al trasladarlo o si nunca llegaron, y **no se atribuye** al analista haber ignorado instrucciones que no consta que recibiera.

## 1. Diagnóstico, limitado a la evidencia
| Rol | Obligación que YA existe (sede) | Hueco |
|---|---|---|
| Coordinadora | Regla 1 de §6: el encargo declara resultado, criterios, **qué queda fuera** y cuándo detenerse; regla 4: decisiones humanas temprano y con su forma | Nada exige que el encargo al analista lleve el pedido del propietario **con fuente identificable y separado del resumen**; nada exige comprobar, antes de implementar, que lo que requería decisión del propietario **quedó resuelto** |
| Analista | «Interrogas, no transcribes»; «No inventes alcance… `borrador` y pregunta abierta»; Definition of Ready; plantilla con `Trazabilidad / Origen: (...)` | `Origen:` sin contenido exigido; sin correspondencia pedido → criterio; una omisión, sustitución, exclusión o decisión de negocio añadida no tiene forma prescrita de marcarse |
| QA | Valida contra los criterios del REQ; deriva = código ≠ REQ; criterio mal formado = hallazgo `contrato` antes de probar | No contrasta **REQ ≠ pedido**, y su `aprobado` se lee como si también acreditara la fidelidad al pedido |

**Dos huecos distintos, y la evidencia no permite elegir entre ellos:** (a) **trazabilidad** — si los cuatro requisitos nunca llegaron a la sesión, nadie pudo cotejarlos, y la falta es que el pedido no se conservó con su fuente; (b) **posible omisión del gate de alcance** — si llegaron al pedido y no al encargo, la regla 1 («qué queda fuera») ya obligaba a la coordinadora y **no se aplicó**. Con el informe no leído y el encargo no conservado, **no se concluye ni que «cada rol cumplió» ni que una regla se incumplió**: se conserva la incertidumbre y la propuesta cubre los dos casos —conservar la fuente hace visible (a), y la comprobación de resolución antes de implementar hace medible (b)—.

## 2. Comprobación propuesta (sedes existentes; sin agente, formulario ni revisión nuevos)
1. **Plantilla del REQ** (`requirements/README.md` §Plantilla, gemela `templates/requirements-README.md.tpl`): `Origen:` exige fuente identificable o `fuente no disponible`; subsección **«Correspondencia con el encargo»** dentro de `## Trazabilidad`, **una fila por obligación verificable** —no por frase—, con cita, criterio, relación (`cubierta / omitida / sustituida / excluida / añadida`) y autorización citada o `→ Preguntas abiertas`. **Se establece al crear el REQ, se actualiza sólo cuando cambia el alcance (misma fila del Historial) y una reparación que conserva el contrato la reutiliza.** Ningún hook ni herramienta lee `Trazabilidad` (`git grep` en `hooks/`, `tools/`): cero efecto en mecanismo y banco.
2. **Analista**: una viñeta en «Entrevista» y un punto en la Definition of Ready. Lo no autorizado va a `Preguntas abiertas` y **el REQ entero queda en `borrador`** por la regla que ya rige; no se inventa estado parcial.
3. **Coordinadora** (`AGENTS.md` §6 regla 1, gemela idéntica): el encargo al analista lleva el pedido con su fuente, separado del resumen; **antes de despachar la implementación de lo que dependa de una fila marcada, comprueba que el propietario la resolvió — presentarla no la resuelve**. Las elecciones técnicas ordinarias no pasan por esta comprobación.
4. **QA**: contrasta la tabla antes de probar, contra la fuente citada si está disponible y contra los criterios, sin rehacer la entrevista, y sin repetirla entera en una reparación que conserva el contrato. **Conformidad con el REQ y fidelidad al pedido son dos veredictos**: con fuente ausente o filas pendientes acredita la conformidad y deja escrito que la fidelidad **no se pudo contrastar**; aprobar la conformidad no acredita la fidelidad ni autoriza decisiones pendientes.

**Diff:** `propuesta-fidelidad-encargo.patch` (128 líneas, seis archivos). Sede y gemela idénticas tras el cambio en las dos parejas, verificado con `diff`.

## 3. Las cuatro correcciones respecto de la revisión 1
1. **Diagnóstico**: retirado «cada rol cumplió» y «no fue una regla incumplida»; se distinguen el hueco de trazabilidad y la posible omisión del gate de alcance; el informe se atribuye como **aportado**, no leído.
2. **Estado del REQ**: retirado «retiene sólo la parte afectada». `borrador` es del REQ entero (`requirements/README.md`, plantilla, §Preguntas abiertas). El trabajo independiente continúa **como hoy** (regla 4: lo que no depende de la decisión, está autorizado y está definido — otros REQ u otras entregas). Si lo ya decidido de ese mismo REQ debe avanzar mientras se espera, la salida existente es **partir el REQ por alcance** (`AGENTS.md` §6, «partir un REQ por alcance no elude ningún contador»), decisión que se registra, **no** una partición automática. Implementar parte de un REQ en `borrador` exigiría cambiar la regla del `borrador`: **dependencia fuera de este ajuste**, no se propone.
3. **Presentación ≠ autorización**: la coordinadora comprueba que la decisión **quedó resuelta**, no que se presentó; QA separa conformidad de fidelidad.
4. **Carga proporcional**: correspondencia al crear el REQ, actualizada sólo con cambios de alcance, reutilizada en reparaciones que conservan el contrato; obligaciones verificables, no transcripción; **retirada** la afirmación de «minutos»: el coste añadido no está medido.

## 4. Qué sucede en los tres casos
- **Fuente ausente.** `Origen: fuente no disponible`. Toda decisión de negocio que el pedido conservado no fija se marca `añadida` y va a `Preguntas abiertas`; el REQ queda en `borrador` hasta que el propietario decida (o hasta que el analista, por decisión registrada, lo parta por alcance). QA, si valida, acredita sólo conformidad con el REQ y deja escrito que la fidelidad no se pudo contrastar. Nadie reconstruye las palabras del propietario.
- **Cambio de alcance sin resolver.** La fila pasa a `sustituida/omitida/excluida/añadida` en la misma edición que el Historial (§9); el REQ vuelve a `borrador`; la coordinadora presenta la diferencia con la forma de la regla 4 y **no despacha** lo que dependa de ella hasta que esté resuelta; lo independiente autorizado sigue.
- **Reparación sin cambio de contrato.** No se crea otra tabla ni se repite la comparación: la fila vigente se cita; QA verifica que la reparación no altera ninguna fila y no vuelve a contrastar la tabla entera.

**Ejemplo (formato, no palabras reales): «tolerancia de fechas».** Fuente disponible: fila «las fechas deben coincidir» (cita) → CA-03 «±2 días» → `sustituida` → `→ Preguntas abiertas`; REQ en `borrador`; la coordinadora presenta *exacta / tolerancia / configurable* con recomendación y consecuencia, y no despacha CA-03 hasta la respuesta. Fuente ausente: fila `fuente no disponible` → CA-03 → `añadida (decisión de negocio no pedida)` → `→ Preguntas abiertas`; misma presentación; QA no acredita fidelidad de esa parte.

## 5. Archivos afectados y crecimiento neto del texto
| Archivo | Neto |
|---|---:|
| `AGENTS.md` (**texto obligatorio de arranque**) | +944 B sobre 63 619 B (`CLAUDE.md` + `AGENTS.md`) = +1,5 % |
| `templates/AGENTS.md.tpl` (gemela) | +944 B |
| `requirements/README.md` (plantilla; no se carga al arrancar) | +753 B |
| `templates/requirements-README.md.tpl` (gemela) | +753 B |
| `agents/analista-requerimientos.md` (entra en el contexto del analista) | +1 110 B |
| `agents/qa-tester.md` (entra en el contexto de QA) | +960 B |
Más, por REQ, la tabla de correspondencia (3–10 filas típicas, no medido). **Ningún hook, herramienta, prueba, umbral ni permiso cambia.**

## 6. Decisiones contractuales que siguen siendo imprescindibles
- **Vehículo:** un REQ nuevo del arnés (`estandar` por §6 al tocar plantillas y agentes heredados; en autoalojamiento nace `critico` y sólo el propietario lo baja) por el ciclo completo. **No se abre aquí.**
- **REQ-025:** la regla 1 es su sede única acreditada; añadirle este párrafo es cambio de §9 que exige fila de Historial en REQ-025 y gemela byte a byte (CA-15 punto 1). **No se modifica aquí**; si se implementa, ese write-back forma parte del REQ nuevo.
- **Distribución:** entrada «Hacia 1.35.0» en `skills/arnes-upgrade/SKILL.md` (plantilla del REQ, regla 1, dos agentes). Nada llega a consumidores hasta publicar y migrar; la demo no cambia.
- **Validación mínima:** `diff` de las dos parejas de gemelas; banco sin cambio esperado; y medir en el **primer REQ real** cuánto cuesta rellenar la tabla y si detecta alguna diferencia. **Esta propuesta no garantiza fidelidad ni reduce costes: no está validada, y su coste añadido no está medido.**

## Lo que no se hizo
No se aplicó el parche; no se tocaron hooks, herramientas, pruebas, umbrales ni permisos; sin comisiones, ensayos, push, publicación ni reparaciones de la demo; REQ-019, REQ-025 y las sondas de coste, intactos.
