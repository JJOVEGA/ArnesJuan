---
name: arnes-close
description: Genera el artefacto de cierre/entrega (DELIVERY.md) consolidando el estado del proyecto al terminar un hito o el proyecto completo. Trabaja en español.
---

# arnes-close — cierre y entrega

Genera `DELIVERY.md` en la raíz del proyecto consolidando lo que ya existe. No inventes
contenido: resume lo real.

## Procedimiento
1. Parte de `templates/DELIVERY.md.tpl`.
2. Rellena cada sección leyendo el estado real del proyecto:
   - **Resumen ejecutivo:** a partir de `AGENTS.md §1` y los módulos entregados.
   - **Módulos / requerimientos:** los REQ en estado `completado` de `requirements/`.
   - **Pruebas:** resultado de las quality gates y veredictos de QA en `CHANGELOG.md`.
   - **Seguridad:** estado de `docs/seguridad/registro-seguridad.md` (hallazgos abiertos vs. mitigados).
   - **Documentación entregada:** enlaces a `ARCHITECTURE.md`, `docs/`, `docs/usuario/`, `docs/decisions/`.
   - **Handoff:** cómo correr/desplegar/mantener (de la doc técnica). Credenciales las gestiona el cliente.
3. **Verificación de trazabilidad y no-deriva (bloqueante).** Por cada REQ `completado`, confirma:
   - Sus **criterios de aceptación reflejan el comportamiento construido** (no solo el original):
     los hallazgos de QA que añadieron conducta están como criterios.
   - Los **controles de seguridad** implementados por hallazgo están como **NFR**, no solo en
     `registro-seguridad.md`.
   - Cada hallazgo (en `docs/qa/` y `docs/seguridad/registro-seguridad.md`) **traza** a un
     REQ/NFR/ADR, o está explícitamente `aceptado` con justificación.
   - Veredictos coherentes: `QA: aprobado` y, si es sensible, `Seguridad: aprobado`.
   Si encuentras **deriva** (algo construido que el requerimiento no refleja), es **bloqueante**:
   devuélvelo para el write-back antes de entregar. **A quién depende de la vía** (`AGENTS.md` §6 y
   §9): al `analista-requerimientos` cuando queda una decisión de requisitos o de diseño, y al
   `desarrollador` —en la misma entrega que el arreglo— cuando sólo hay que reflejar en el REQ lo
   que ya estaba contratado. **Lo bloqueante no cambia:** sin el write-back no se entrega, venga de
   quien venga. Documenta el resultado en la sección *Trazabilidad y no-deriva* de `DELIVERY.md`.
4. Pregunta el **destinatario** (técnico / ejecutivo / ambos) y ajusta el nivel de detalle.
5. Marca el `DELIVERY.md` como pendiente de aprobación: regístralo en `PENDING_APPROVAL.md`
   y NO des el proyecto por cerrado hasta el visto bueno del destinatario.

## Reglas
- No incluyas secretos ni datos sensibles del cliente en el entregable.
- Si hay hallazgos de seguridad críticos abiertos, NO cierres: indícalo y escala.
