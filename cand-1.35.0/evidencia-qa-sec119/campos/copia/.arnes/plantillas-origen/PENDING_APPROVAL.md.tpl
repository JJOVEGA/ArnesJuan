# PENDING_APPROVAL — {{NOMBRE_PROYECTO}}

> Cola de decisiones que esperan visto bueno humano antes de que el pipeline continúe.
> Un agente AÑADE una entrada y se detiene; el humano la resuelve y la mueve a "Resueltas".
> Mientras haya algo en "Pendientes", el pipeline NO avanza en ese hilo.
>
> **Formato de una entrada** (va bajo `## Pendientes`, con `###`):
> `### [AAAA-MM-DD] (agente) — Título de la decisión`, y debajo: **Contexto** (por qué se
> detuvo aquí) · **Opciones** (A / B / …) · **Recomendación del agente** · **Espera**
> (aprobación / elección del humano).
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: `guard-completado` cuenta las
> entradas `###` bajo "Pendientes" para decidir si un REQ puede cerrar. Un ejemplo dentro
> de la sección se cuenta como una pendiente real y bloquea todos los cierres.

## Pendientes

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
