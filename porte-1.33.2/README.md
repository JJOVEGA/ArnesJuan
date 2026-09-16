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
| Suelo de rigor (`Sensible a seguridad: sí` → `critico`) | ver el apéndice de abajo (sección localizada y corrida) | ver abajo |
| Regla `UNKNOWN` terminal de `arnes-upgrade`; relleno de `{{…}}` por entrevista en `arnes-init`; `tools/arnes-paralelo.sh` | lectura del código y las skills de `v1.33.2` (`SKILL.md:56-68`, `:145`; `arnes-init` `:22-54`) | existen |
| `campos.ausencia_exige` (base) | — | **no existe y no se referencia** |

El desarrollador reportó además: gates 3/3; banco completo de `v1.33.2` dos veces (912 casos, 0 FAIL, 6 y 5 SKIP —sonda de reloj—); autoprueba 106 · 0; los 3 casos `REQ-016 CA-10` de la sección 36 pasan sobre el texto nuevo. **No re-ejecutado por la coordinadora**; se cita como reportado.

## Qué NO acredita
Sin QA ni seguridad. Nada mecánico distingue la declaración afirmativa de la negativa (límite declarado en la propia sede). La migración de `arnes-upgrade` no se ejecutó contra ningún proyecto. No se ha hecho ningún despacho real con agentes sobre el porte (`--plugin-dir`): la evidencia funcional existente (CON-AFIRM, SIN-CONS) es de `6212e87`, otro árbol.
