# El CI como puerta de `main`

**Estado (2026-09-05, tarde): ACTIVO.** `proteger-main` exige que `hooks-en-linux` esté verde y que la
rama esté al día antes de fusionar. Verificado releyendo el ruleset tras aplicarlo:

```
  exige: hooks-en-linux  · estricto=true
```

Se aplicó con la cuenta `JJOVEGA` (admin) vía `gh auth switch`, con el JSON de al lado, y la cuenta
activa volvió a `jvega-habitat`. Hasta ese momento el CI informaba pero no impedía; lo señaló una
revisión externa y se comprobó con la API (cero reglas `required_status_checks`).

Lo que sigue es el procedimiento, por si hay que rehacerlo o añadir otro check.

**Por qué hacía falta la cuenta admin:** editar un ruleset exige permiso de administrador del repositorio, y la
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

Debe imprimir `hooks-en-linux`. Desde el 2026-09-05 lo imprime: **un PR rojo ya no se puede fusionar.**
