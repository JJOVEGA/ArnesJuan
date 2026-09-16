# Porte mínimo de la vía proporcional sobre `v1.33.2` — diff preparado, 2026-09-16

- **Rama:** `porte/via-proporcional-1.33.2` (worktree `/home/juan/dev/ArnesJuan-porte-via`), creada desde el tag `v1.33.2` = `10eac80`. **Commit del porte: `404e044`**, local, sin push.
- **Diff completo:** `404e044.diff` (`git diff v1.33.2 404e044`, 11 archivos, +672/−18). Fuente de las decisiones de diseño: `base/via-proporcional` @ `5f07419` (intacta).
- **Autorización:** el propietario autorizó preparar el porte por comportamiento, conservando hooks/tools/configuración de `v1.33.2`, sin referencias a mecanismos exclusivos de la rama de desarrollo, sin cambiar versión, sin QA hasta entregar el diff.

## Revisión de la coordinadora sobre `404e044` (ejecutada, no leída del informe del desarrollador)
- `git diff --name-only v1.33.2 404e044 -- hooks tools .arnes .claude-plugin tests .github` → **0**.
- Barrido propio de términos prohibidos en las líneas añadidas heredables (`ausencia_exige`, `campos.`, `REQ-02x`, `SEC-nnn`, `R-0nn`, `D1x`, rotación de tabla/sección, «puerta posterior», `1.34`, `§14`, «Hacia 1.3x», medibilidad) → **0**.
- Rutas citadas en lo añadido que no existan en el árbol del porte → **0**.
- Gemelas `AGENTS.md`/`templates/AGENTS.md.tpl`: el bloque añadido difiere en **la declaración** (negativa en el repo, `{{DECLARACION_VIA_PROPORCIONAL}}` en la plantilla) y en **una frase de §9** del repo («en ESTE repositorio §6 NO la declara»). Nada más.
- Sede normativa única (§6 «La disciplina de la declaración», 5 puntos + límite declarado) con las dos líneas literales; la afirmativa se parte en dos líneas de fuente **igual que en `5f07419`**, y el punto 4 fija la oración como unidad. Comprobación de la coordinadora en §6 (era §14 A(5) en la base), con los límites 1 y 2 reescritos sin remitir a §14.
- Entrada de `arnes-upgrade` con título **«Hacia <versión por decidir> — vía proporcional»** y párrafo que lo declara deliberado; ninguna fila de merge escribe la autorización; la sección canónica «Clasificación» sin tocar. **No publicable tal cual** hasta que el propietario fije el número.
- `arnes-init`: pregunta la autorización textualmente; sólo un «sí» escribe la afirmativa; remite a la sede única sin copiarla.
- `AGENTS.md` del repo lleva la **negativa** (decisión del propietario **sin tomar**, no tomada).

## Capacidades reales de `v1.33.2` de las que depende la política — comprobadas
| Capacidad | Cómo se comprobó | Resultado |
|---|---|---|
| Clases de hallazgo: `usuario/dinero`, `contrato` y **sin clase** deniegan el cierre | sección `08-clase-del-hallazgo.sh` por ruta, hooks de `v1.33.2` | 7 PASS · 0 FAIL |
| `Rigor: ligero` no salta gates, cola ni `usuario/dinero`; sólo el veredicto de QA | `12-rigor-ligero.sh` por ruta | 4 PASS · 0 FAIL |
| Los campos valen sólo en la cabecera | `14-campos-solo-en-la-cabecera.sh` por ruta | 36 PASS · 0 FAIL |
| Suelo de rigor (`Sensible a seguridad: sí` → `critico`; un matiz no lo rebaja; `estandar` cierra con QA, `critico` exige ambas firmas) | `40-estabilizacion-firmas-y-rigor.sh` por ruta, hooks de `v1.33.2` (identificadores `QA-P48-01 … sensible con matiz conserva el suelo critico (deny)`, `D16: matiz CERRADO no rebaja critico (deny)`) | 28 PASS · 0 FAIL |
| Regla `UNKNOWN` terminal de `arnes-upgrade`; relleno de `{{…}}` por entrevista en `arnes-init`; `tools/arnes-paralelo.sh` | lectura del código y las skills de `v1.33.2` (`SKILL.md:56-68`, `:145`; `arnes-init` `:22-54`) | existen |
| `campos.ausencia_exige` (base) | — | **no existe y no se referencia** |

El desarrollador reportó además: gates 3/3; banco completo de `v1.33.2` dos veces (912 casos, 0 FAIL, 6 y 5 SKIP —sonda de reloj—); autoprueba 106 · 0; los 3 casos `REQ-016 CA-10` de la sección 36 pasan sobre el texto nuevo. **No re-ejecutado por la coordinadora**; se cita como reportado.

## Qué NO acredita
Sin QA ni seguridad. Nada mecánico distingue la declaración afirmativa de la negativa (límite declarado en la propia sede). La migración de `arnes-upgrade` no se ejecutó contra ningún proyecto. No se ha hecho ningún despacho real con agentes sobre el porte (`--plugin-dir`): la evidencia funcional existente (CON-AFIRM, SIN-CONS) es de `6212e87`, otro árbol.

---

## Resultado consolidado de la validación acotada de `404e044` (2026-09-16)

| Pieza | Resultado | Sede |
|---|---|---|
| Ensayos con agentes reales (CON-AFIRM-P, SIN-CONS-P) | ambos coinciden con lo esperado: con la negativa el analista va primero y el desarrollador no edita el REQ (0 ediciones); con la afirmativa desarrollador → QA sin analista y write-back del desarrollador en la misma entrega (6 ediciones, primer editor) | `ensayos/README.md` §A |
| Instalación (`/arnes-init`) | sin respuestas: la skill estable se detiene en la entrevista (no crea nada); con respuestas y sin «sí»: **negativa** literal; con «sí» explícito: **afirmativa** literal con nombre y fecha; 0 placeholders | `ensayos/README.md` §B |
| Actualización (`/arnes-upgrade`, origen 1.33.1) | personalizaciones conservadas (§2 nota; §6 propia → CONFLICTO no resuelto); ninguna de 6 sesiones escribió la afirmativa; §6 INTACTA recibe el bloque con la negativa. **2 de 6 sesiones rehusaron el destino** por el marcador de versión (plugin declara 1.33.2 con plantillas distintas del tag) | `ensayos/README.md` §C |
| QA (porte `743a5ff`) | **FAVORABLE**; adaptaciones §14→§6 y ancla `UNKNOWN` **conformes**; barrido a cero; gemelas exactas; autoalojamiento sin contradicción; banco de `v1.33.2` corrido por QA: **908 · 0 · 4 = 912**, autoprueba **106 · 0**, gates 3/3. Hallazgos `H-P1`, `H-P2` (skill estable) | `docs/qa/porte-1.33.2-via-proporcional-veredicto.md` del porte |
| Seguridad (porte `346b882`) | **`Seguridad: aprobado` acotada al porte** (R-031 del registro de `v1.33.2`); identidad por `sha` de los agentes y de §13; cinco diferencias sin pérdida de protección; **`SEC-089`** `instrumento` (límite 1 incorpora sólo una de dos causas); H-P1/H-P2 no bloquean | `docs/seguridad/registro-seguridad.md` § R-031 del porte |

**Estado del porte:** `porte/via-proporcional-1.33.2` @ `346b882` (= `404e044` + informes), **local, nunca empujada**. `main`, `5f07419`, `v1.33.2` e instalación estable sin cambios.

**Pendiente antes de entregar (decisiones del propietario):** (1) **el número de versión** — el porte declara `1.33.2` y la skill estable lo detecta como destino inconsistente en 2 de 6 sesiones; con el número decidido, el título «Hacia <versión por decidir>» se fija y `H-P2` desaparece; (2) la declaración de este repositorio (hoy **negativa**); (3) qué hacer con `SEC-089`, `H-P1` y la discrepancia preexistente `arnes_version 1.33.0` / `plugin.json 1.33.2` (limitaciones no bloqueantes, declaradas); (4) CI sobre el porte (nunca corrido en `hooks-en-linux`; el banco local de QA es la evidencia disponible).

**Qué no acredita el conjunto:** n=1 por caso; la Fase 2 de `/arnes-upgrade` con `UNKNOWN` no quedó ejercida; fila 3 por vía afirmativa, copia propia de agente y `arnes-init` interactivo sin ejercer; ninguna corrida de CI; ninguna publicación.
