# Playbooks de plataforma

Los **playbooks** son documentos de convenciones de plataforma **opcionales** que
viajan con el arnés. Capturan conocimiento reutilizable y caro de aprender
(típicamente errores de runtime que costaron horas) para un stack o servicio
concreto — sin acoplar el flujo base del arnés a ningún cliente.

## Principios

- **Genéricos y reutilizables.** Un playbook describe convenciones de una
  *plataforma* (p. ej. Dataverse), no de un cliente. Lo específico de cada
  cliente (nombres reales de tablas/columnas) vive en `docs/` del proyecto.
- **Opt-in.** El arnés es agnóstico del stack. Un playbook **sólo aplica si el
  proyecto lo declara** en su `AGENTS.md`. Los proyectos que no lo declaran no se
  ven afectados.
- **Vinculantes cuando aplican.** Si el proyecto declara un playbook, sus
  convenciones son obligatorias: incumplirlas es **hallazgo**, no detalle.

## Cómo lo declara un proyecto

En el `AGENTS.md` del proyecto, sección **§2 Stack →
*Playbooks de plataforma aplicables***, se listan las rutas:

```markdown
### Playbooks de plataforma aplicables
- plugins/ArnesJuan/playbooks/power-apps-dataverse.md
```

(La ruta exacta depende de cómo el proyecto consuma el arnés — submódulo,
marketplace de plugins, etc.)

## Qué deben hacer los agentes

- **desarrollador:** leer los playbooks declarados **antes de codificar** y
  respetar sus convenciones.
- **qa-tester / auditor-seguridad:** verificar que el código cumpla las
  convenciones del playbook y que existan (y pasen) los tests guardián que
  prescriba. El incumplimiento es hallazgo.

## Límite conocido

Algunos playbooks prescriben **tests guardián** que dependen de artefactos
generados de cada proyecto (p. ej. esquemas en `.power/schemas/`). Esos tests
**no pueden viajar genéricos**: el playbook describe la *receta* y cada proyecto
crea su test. Cuando exista, el arnés ofrece un template de arranque en
`templates/` que el proyecto copia y adapta.

## Playbooks disponibles

| Playbook | Plataforma |
|----------|-----------|
| [power-apps-dataverse.md](power-apps-dataverse.md) | Power Apps Code App + Dataverse |
