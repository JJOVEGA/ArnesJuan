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
3. Pregunta el **destinatario** (técnico / ejecutivo / ambos) y ajusta el nivel de detalle.
4. Marca el `DELIVERY.md` como pendiente de aprobación: regístralo en `PENDING_APPROVAL.md`
   y NO des el proyecto por cerrado hasta el visto bueno del destinatario.

## Reglas
- No incluyas secretos ni datos sensibles del cliente en el entregable.
- Si hay hallazgos de seguridad críticos abiertos, NO cierres: indícalo y escala.
