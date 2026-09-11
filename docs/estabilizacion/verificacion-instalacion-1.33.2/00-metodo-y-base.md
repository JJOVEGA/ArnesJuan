# v1.33.2 — verificación de instalación nueva y actualización desde v1.33.1

**Quién:** coordinadora. **Cuándo:** 2026-09-10, ventana autónoma de 8 h.
**Versión base:** `hotfix/1.33.2-rigor` en `a8e332a`, contra el tag **`v1.33.1`**.
**Qué NO es:** no es el veredicto de QA ni la revisión de seguridad. Es la comprobación **mecánica**
que el propietario puso como condición de publicación, hecha por adelantado para que QA y seguridad la
**verifiquen y no la reconstruyan** (§14.B.7).

**Método.** El `arnes-upgrade` del arnés es un **merge a tres vías** —*base* = plantilla de la versión
de origen, *nuestro* = el archivo del proyecto hoy, *suyo* = plantilla de la versión destino—. Así que
lo que hay que verificar es el **sustrato**: que ese merge se comporte bien en los casos reales. Se
simula con `git merge-file`, que es la misma operación, sobre las plantillas reales extraídas con
`git show v1.33.1:…` y del worktree del parche. **No se instaló nada en esta máquina ni se tocó
ninguna configuración**, por el límite expreso del propietario.

## 1. Radio de impacto: UNA sola superficie heredable

*Comando:* `git diff --name-only v1.33.1..HEAD -- <ruta>` en el worktree del parche.

| Superficie que los proyectos heredan | Archivos que cambian |
|---|---|
| `templates/` | **1** — `templates/requirements-README.md.tpl` |
| `agents/` | 0 |
| `skills/` | 0 |
| `playbooks/` | 0 |
| `hooks/hooks.json` | 0 |
| `templates/arnes-config.json.tpl` y `.arnes/config.json` | **0 — intactos** |

**Consecuencia:** la actualización de un proyecto consumidor a v1.33.2 sólo puede afectar a **un**
archivo de su andamiaje. Ni su manifiesto, ni sus agentes, ni sus skills, ni sus REQ.

*Corrección de una comprobación mía mal hecha, que se registra en vez de borrarse:* el primer intento
comparó `v1.33.1` contra el **árbol de trabajo de la línea 1.34.0** en vez de contra el parche, y dio
que `templates/arnes-config.json.tpl` cambiaba. **Es falso para este parche.** La cifra buena es la de
arriba, medida con `v1.33.1..HEAD` **dentro del worktree del parche**.

## 2. Los cuatro casos del merge, medidos

| Caso | Qué simula | `rc` | Resultado |
|---|---|---|---|
| **1** | Proyecto que **no tocó** `requirements/README.md` — y equivale a una **instalación nueva** | **0** | **Recibe la regla nueva**, 0 conflictos |
| **2** | Proyecto que editó **otra** sección (texto humano propio) | **0** | **Conserva su texto** ✅ **y recibe la regla** ✅, 0 conflictos |
| **3** | Proyecto que editó **la misma región** del rigor | **1** | **CONFLICTÚA y no sobrescribe** ✅ — conserva la regla local del equipo **y** ofrece la nueva, con marcadores |
| **4** | ¿Toca el upgrade el manifiesto o los REQ del proyecto? | — | **No.** Cero archivos, por la tabla de arriba |

**El caso 3 es el que decide si esto es seguro**, y sale como debe: el modelo del arnés promete que
*«sin saber si lo escribió una persona, no se toca nada»*, y aquí lo cumple **fail-closed** — se
detiene con conflicto en vez de imponer la plantilla. Un proyecto que hubiera reescrito la regla del
rigor **no** la pierde en silencio.

## 3. Qué queda sin verificar, y se dice

- **No se ejecutó `arnes-upgrade` como skill.** Es un procedimiento que sigue un agente, no un script;
  lo comprobado es su **sustrato mecánico**. Que el agente aplique el procedimiento correctamente es
  otra cosa, y no la acredita este documento.
- **No se instaló en esta máquina.** El límite del propietario prohíbe tocar configuraciones, así que
  la «instalación nueva» se verificó como el caso 1 del merge —plantilla sobre proyecto virgen—, no
  ejecutando `arnes-init` contra un directorio real.
- **Un proyecto cuyo `requirements/README.md` no descienda de v1.33.1** cae en la regla que la skill
  ya declara: sin base, el estado es `UNKNOWN` y la migración **se detiene**. No se probó aquí porque
  no es una conducta que este parche cambie.

## 4. Reproducción

```
git show v1.33.1:templates/requirements-README.md.tpl > base.tpl
cp <worktree-parche>/templates/requirements-README.md.tpl suyo.tpl
# caso 2
cp base.tpl c2.nuestro && printf '\n## Notas de nuestro equipo\n\ntexto humano\n' >> c2.nuestro
git merge-file -p c2.nuestro base.tpl suyo.tpl > c2.out ; echo $?
# caso 3: editar en c3.nuestro la MISMA linea de la regla del rigor y repetir
```

Archivos de esta carpeta: `base.tpl`, `suyo.tpl`, `c2.out`, `c3.out` (con sus marcadores de conflicto).
