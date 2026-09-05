# El CI como puerta de `main` — pendiente del dueño del repo

**Estado (2026-09-05):** el workflow `banco.yml` corre en cada PR y su último run es verde, pero el
ruleset `proteger-main` **no lo exige**. Un PR con el banco rojo se puede fusionar. Lo señaló una
revisión externa y se comprobó con la API: cero reglas `required_status_checks`.

**Por qué no está hecho ya:** editar un ruleset exige permiso de administrador del repositorio, y la
cuenta desde la que se opera el arnés (`jvega-habitat`) tiene `push` pero no `admin` sobre
`JJOVEGA/ArnesJuan`. La API devuelve 404 a quien no es admin. Lo tiene que hacer `JJOVEGA`.

## Cómo hacerlo, dos caminos

**Web (30 segundos):** Settings → Rules → Rulesets → `proteger-main` → *Add rule* →
**Require status checks to pass** → añadir `hooks-en-linux` → marcar *Require branches to be up to
date before merging* → Save.

**API, autenticado como `JJOVEGA`:** la regla exacta está en `regla-ci-obligatorio.json`, al lado.

```bash
RID=$(gh api repos/JJOVEGA/ArnesJuan/rulesets --jq '.[] | select(.name=="proteger-main") | .id')
gh api "repos/JJOVEGA/ArnesJuan/rulesets/$RID" \
  | jq --slurpfile r docs/gobernanza/regla-ci-obligatorio.json \
       '{name, target, enforcement, conditions, bypass_actors: (.bypass_actors // []), rules: (.rules + $r)}' \
  | gh api -X PUT "repos/JJOVEGA/ArnesJuan/rulesets/$RID" --input -
```

## Cómo se comprueba que quedó hecho

```bash
gh api repos/JJOVEGA/ArnesJuan/rulesets/$RID \
  --jq '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[].context'
```

Debe imprimir `hooks-en-linux`. Hasta entonces, **el CI informa pero no impide.**
