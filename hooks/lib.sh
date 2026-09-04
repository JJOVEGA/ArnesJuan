#!/usr/bin/env bash
# lib.sh — helpers compartidos por los hooks de enforcement del arnés.
#
# Filosofía (coherente con AGENTS.md y los agentes):
#   - INERTE fuera de un proyecto del arnés: si no hay `.arnes/config.json`, el hook
#     no hace nada (exit 0). Así el plugin puede estar activo globalmente sin estorbar
#     en repos que no usan el arnés.
#   - FAIL-CLOSED pero NO silencioso para la regla de identidad: ante un editor no
#     autorizado se deniega Y se explica el motivo (nunca un bloqueo mudo).
#   - Si falta una herramienta de base (jq), el enforcement queda inactivo con un
#     aviso por stderr; NO se bloquean ediciones por falta de tooling (no brickear).

# Lee TODO el stdin de forma bloqueante. El harness a veces tarda en enviarlo.
arnes_read_stdin() { cat; }

# Raíz del proyecto: prioriza $CLAUDE_PROJECT_DIR; si no, el campo `cwd` del input.
arnes_project_dir() {
  local input="$1"
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    printf '%s' "$CLAUDE_PROJECT_DIR"
  else
    printf '%s' "$input" | jq -r '.cwd // empty'
  fi
}

# Ruta del manifiesto del arnés para este proyecto.
arnes_manifest_path() { printf '%s/.arnes/config.json' "$1"; }

# ¿Está jq disponible? Si no, avisa y pide al llamador que se desactive.
arnes_require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'ARNES (hook): jq no encontrado; enforcement inactivo en esta sesión.\n' >&2
    return 1
  fi
  return 0
}

# Emite una decisión DENY de PreToolUse y termina (exit 0 = decisión aplicada).
# Salida compacta (-c): una sola línea, el formato que esperan los hooks.
arnes_deny() {
  jq -cn --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# Aviso por stderr (no silencioso), sin bloquear.
arnes_warn() { printf 'ARNES (hook): %s\n' "$1" >&2; }

# --- Compatibilidad Windows ---------------------------------------------------
# En Windows `jq` suele ser un binario NATIVO, no MSYS. Eso rompe dos cosas a la vez:
#   1. Traducción de rutas: bash ve `/tmp/x`, pero jq devuelve `C:/Users/.../Temp/x`.
#      Al restar el prefijo del proyecto, `rel` conserva la ruta absoluta y NINGÚN
#      glob casa jamás -> el hook permite todo.
#   2. stdout en modo texto: cada línea llega con CRLF, así que un glob leído del
#      manifiesto es `src/*\r` y tampoco casa nunca.
# Ambos fallan ABIERTO y en silencio: el enforcement parece activo y no lo está.

# jq con el CR de Windows retirado de la salida, SIN arrancar un segundo proceso.
#
# La forma obvia —`jq "$@" | tr -d '\r'`— cuesta DOS arranques de proceso por
# lectura. Medido en Windows con emulación MSYS y antivirus de por medio, un
# arranque ronda el segundo, y los guardianes hacen varias lecturas por
# invocación: el `tr` llegaba a ser la mitad del coste del hook.
#
# Bash quita los CR con expansión de variable, que no arranca nada. El
# `printf` final repone el salto que la sustitución de comandos se come, para
# que esto siga sirviendo igual en `$(...)` que en `< <(...)`.
arnes_jq() {
  local out
  out="$(jq "$@")" || return $?
  printf '%s\n' "${out//$'\r'/}"
}

# Ruta canónica para COMPARAR (no para abrir): separadores `/` y, en Windows, forma
# mixta `c:/...` con la unidad en minúscula. Fuera de Windows es la identidad.
arnes_norm_path() {
  local p="$1" bs='\' fs='/'
  if command -v cygpath >/dev/null 2>&1; then
    p="$(cygpath -m -- "$p" 2>/dev/null || printf '%s' "$p")"
  fi
  p="${p//"$bs"/"$fs"}"
  case "$p" in
    [A-Za-z]:*) p="$(printf '%s' "${p%%:*}" | tr '[:upper:]' '[:lower:]'):${p#*:}" ;;
  esac
  printf '%s' "$p"
}

# --- Rutas relativas al proyecto ----------------------------------------------
# Devuelve la ruta con la que se comparan los globs del manifiesto: relativa a la
# raíz del proyecto. Una ruta ya relativa (típica en comandos de Bash) se deja tal
# cual, asumiendo que el comando corre en la raíz; si el agente hizo `cd` a otro
# sitio, el resultado no casará con ningún glob (falso negativo, nunca positivo).
arnes_ruta_relativa() {  # <ruta> <raíz del proyecto>
  local p pp
  p="$(arnes_norm_path "$1")"
  pp="$(arnes_norm_path "$2")"
  p="${p#"$pp"/}"
  p="${p#./}"
  printf '%s' "$p"
}

# ¿La ruta relativa cae dentro de `codigo_app.globs`?
arnes_es_codigo_app() {  # <ruta relativa> <manifiesto>
  local rel="$1" manifest="$2" g
  [ -n "$rel" ] || return 1
  while IFS= read -r g; do
    [ -n "$g" ] || continue
    # shellcheck disable=SC2053  -- glob a la derecha a propósito
    if [[ "$rel" == $g ]]; then return 0; fi
  done < <(arnes_jq -r '.codigo_app.globs[]? // empty' "$manifest")
  return 1
}

# --- Identidad del agente -----------------------------------------------------
# Claude Code entrega el agente en `agent_type` CON el prefijo del plugin que lo
# provee (`arnes-juan:desarrollador`), mientras que el manifiesto lo declara por su
# nombre corto (`desarrollador`). Comparar en crudo no casaba nunca y el guard
# terminaba denegando justo al único agente autorizado (bug hallado en SENDA).
#
# Regla de coincidencia — tolerante al prefijo, sin volverse permisiva:
#   1. Se compara el NOMBRE CORTO (lo que va tras el último ':'), normalizado
#      (minúsculas, sin espacios ni CR): el manifiesto lo escribe una persona.
#   2. Si AMBOS lados traen prefijo, además deben coincidir los prefijos. Un
#      proyecto que necesite desambiguar declara `arnes-juan:desarrollador` y con
#      eso rechaza a `otro-plugin:desarrollador`.
#   3. Si el manifiesto NO trae prefijo, cualquier proveedor con ese nombre corto
#      casa. El manifiesto no dijo de qué plugin viene, y exigirlo obligaría a cada
#      proyecto a conocer el nombre del plugin — que es el fallo que se corrige.
arnes_norm_ident() {
  printf '%s' "$1" | tr -d '\r' | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

arnes_ident_nombre() {  # nombre corto, sin prefijo de plugin
  local s; s="$(arnes_norm_ident "$1")"; printf '%s' "${s##*:}"
}

arnes_ident_prefijo() {  # prefijo del proveedor, o vacío si no lo trae
  local s; s="$(arnes_norm_ident "$1")"
  case "$s" in *:*) printf '%s' "${s%:*}" ;; *) printf '' ;; esac
}

arnes_agente_coincide() {  # <agent_type recibido> <nombre declarado>
  local rn dn rp dp
  rn="$(arnes_ident_nombre "$1")"; dn="$(arnes_ident_nombre "$2")"
  [ -n "$rn" ] && [ "$rn" = "$dn" ] || return 1
  rp="$(arnes_ident_prefijo "$1")"; dp="$(arnes_ident_prefijo "$2")"
  if [ -n "$dp" ] && [ -n "$rp" ] && [ "$rp" != "$dp" ]; then return 1; fi
  return 0
}

# Nombre del agente para un mensaje humano: corto y, si venía calificado, con el
# identificador completo entre paréntesis para poder diagnosticar el origen.
arnes_agente_legible() {  # <agent_type>
  local ident nombre
  ident="$(arnes_norm_ident "$1")"
  nombre="$(arnes_ident_nombre "$1")"
  if [ "$ident" != "$nombre" ]; then
    printf "'%s' (%s)" "$nombre" "$ident"
  else
    printf "'%s'" "$nombre"
  fi
}

# --- Escrituras evidentes dentro de un comando de Bash ------------------------
# COBERTURA DELIBERADAMENTE PARCIAL. Un hook no puede analizar shell arbitrario de
# forma fiable (heredocs, scripts, herramientas que escriben por su cuenta), y un
# intento de cobertura total produce falsos positivos que terminan con alguien
# desactivando el guard. Aquí sólo se detectan las formas obvias y directas:
#   redirección `>`/`>>`, `tee`, `cp`, `mv`, `install`, `sed -i`, `perl -i`, `dd of=`.
# Todo lo demás (compiladores, formateadores, `git apply`, `patch`, scripts) queda
# fuera a propósito: es una barandilla, no una jaula.
#
# Sesgo explícito al FALSO NEGATIVO: primero se descarta el texto entrecomillado,
# así una mención de una ruta dentro de un mensaje no dispara nada.
arnes_bash_escrituras() {  # <comando> -> rutas escritas, una por línea
  local cmd="$1" limpio i j n tok
  limpio="$(printf '%s' "$cmd" | sed -e 's/"[^"]*"/ /g' -e "s/'[^']*'/ /g")"
  # Separa los operadores de su operando: `>src/a.ts` -> `> src/a.ts`.
  limpio="$(printf '%s' "$limpio" \
    | sed -e 's/>|/>/g' -e 's/>>/>/g' -e 's/>/ > /g' -e 's/|/ | /g' -e 's/;/ ; /g')"

  local reponer_f=0
  case $- in *f*) reponer_f=1 ;; esac
  set -f
  # shellcheck disable=SC2206  -- se quiere el word splitting, con globbing apagado
  local -a t=($limpio)
  [ "$reponer_f" -eq 1 ] || set +f

  n=${#t[@]}
  _arnes_es_separador() { case "$1" in '>'|'|'|';'|'&&'|'||'|'&') return 0 ;; *) return 1 ;; esac; }
  _arnes_emite() { [ -n "${1:-}" ] && ! _arnes_es_separador "$1" && printf '%s\n' "$1"; }

  for ((i = 0; i < n; i++)); do
    tok="${t[i]}"
    case "$tok" in
      '>')
        _arnes_emite "${t[i + 1]:-}" ;;
      tee|*/tee)
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          case "${t[j]}" in -*) continue ;; esac
          _arnes_emite "${t[j]}"
        done ;;
      cp|mv|install|*/cp|*/mv|*/install)
        # El destino es el último operando del segmento; se prueba también su forma
        # de directorio (`cp x src` debe casar con el glob `src/*`).
        local dest=""
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          case "${t[j]}" in -*) continue ;; esac
          dest="${t[j]}"
        done
        if [ -n "$dest" ]; then
          _arnes_emite "$dest"
          case "$dest" in */) ;; *) _arnes_emite "$dest/" ;; esac
        fi ;;
      sed|perl|*/sed|*/perl)
        local en_sitio=0
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          # Sólo cuenta como in-place `--in-place[=x]` o un flag corto con `i`
          # (`-i`, `-i.bak`, `-pi`). `--expression` también lleva una `i` y NO lo es.
          case "${t[j]}" in
            --in-place|--in-place=*) en_sitio=1 ;;
            --*) : ;;
            -*i*) en_sitio=1 ;;
          esac
        done
        [ "$en_sitio" -eq 1 ] || continue
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          case "${t[j]}" in -*) continue ;; esac
          _arnes_emite "${t[j]}"
        done ;;
      of=*)
        _arnes_emite "${tok#of=}" ;;
    esac
  done
  return 0
}
