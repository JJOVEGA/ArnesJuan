declare -A SONDA=()
SONDA_MOTIVO=''
sonda_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# sonda_es_util <instrumento> — QUIÉN es un instrumento de `tests/util/`, y ésta es su sede
# única. Decide qué campos son obligatorios: el materializador de línea base vive INLINE en
# las secciones 37 (REQ-021 CA-05, tras la reducción de alcance del 2026-09-08) y HEREDA el
# formato y este parser, pero NO hereda CA-04, así que no puede observar `vivos` y no lo
# declara. Exigirle un campo que no puede observar no es rigor: es un FAIL garantizado, que
# es la forma de criterio insatisfacible que este REQ ya ha pagado dos veces. Por eso el
# campo se enuncia sobre EL EMISOR y no sobre el formato (CA-10 punto 2).
sonda_es_util() { case "${1:-}" in reloj|procesos) return 0 ;; *) return 1 ;; esac; }
# …y QUIÉNES son los emisores que este juez sabe juzgar. Los de `tests/util/` más el
# materializador INLINE de CA-05. Un emisor que no esté aquí es un registro que nadie ha
# declarado, y eso es FAIL: fail-closed, porque no hay forma de saber qué gates le aplican.
sonda_emisor_conocido() { case "${1:-}" in reloj|procesos|linea-base) return 0 ;; *) return 1 ;; esac; }

sonda_lee() {
  local reg="${1:-}" resto par clave valor vistas=' '
  SONDA=(); SONDA_MOTIVO=''
  if [ -z "$reg" ]; then SONDA_MOTIVO='el registro salió VACÍO: la sonda no se ejecutó'; return 1; fi
  case "$reg" in *'='*) ;; *) SONDA_MOTIVO="el registro no tiene ningún campo clave=valor (<${reg:0:80}>)"; return 1 ;; esac
  # SIN `for par in $reg`, Y NO ES ESTILO (QA-021-04): esa forma parte por espacios —así que
  # un valor con un espacio deja de ser un valor y sus palabras con `=` se vuelven CAMPOS— y
  # además hace EXPANSIÓN DE NOMBRES DE ARCHIVO sobre lo que resulta, de modo que el
  # significado de un registro dependía del contenido del directorio de trabajo (comprobado
  # con un archivo llamado `estado=ok` en el `cwd`: el juez leía `estado=<ok>` y dejaba pasar
  # como medición una sonda que no había podido medir). Se recorre con expansión de
  # parámetros: no hay split, no hay glob y no cuesta un proceso.
  resto="$reg"
  while [ -n "$resto" ]; do
    par="${resto%% *}"
    if [ "$par" = "$resto" ]; then resto=''; else resto="${resto#* }"; fi
    [ -n "$par" ] || continue
    case "$par" in *'='*) ;; *) continue ;; esac
    clave="${par%%=*}"; valor="${par#*=}"
    [ -n "$clave" ] || continue
    # CLAVE REPETIDA = registro AMBIGUO = ILEGIBLE (QA-021-04). Dejar ganar a la ÚLTIMA
    # aparición es lo que convertía un `estado=sin-linea-base` en `estado=ok` en cuanto un
    # valor traía un espacio. Ni CA-01 punto 5 («ausente es un error, nunca un cero») ni
    # CA-10 («vacío o ilegible es FAIL») cubrían el registro AMBIGUO — y un registro
    # ambiguo no es un registro: son dos, y elegir uno es adivinar.
    case "$vistas" in *" $clave "*) SONDA_MOTIVO="el registro trae la clave '$clave' REPETIDA: es ambiguo, y un registro ambiguo no es legible"; return 1 ;; esac
    vistas="$vistas$clave "
    SONDA[$clave]="$valor"
  done
  # Los campos que TODO registro trae. Ausente no es cero: es un error con motivo.
  for clave in sonda modo estado corrida invocacion us procesos; do
    if [ -z "${SONDA[$clave]:-}" ]; then SONDA_MOTIVO="al registro le falta el campo obligatorio '$clave'"; return 1; fi
  done
  # …y los que además tienen que ser números, UNO A UNO.
  if ! sonda_num "${SONDA[us]}"; then SONDA_MOTIVO="el campo 'us' no es un número (<${SONDA[us]}>)"; return 1; fi
  # `procesos` es un número O EXACTAMENTE `no-aplica`, que NO es un cero (QA-021-07): el
  # reloj no puede contar procesos sin instrumentar, y una muestra mixta no es publicable
  # (CA-02 punto 5). Un cero publicado ahí era la mitad en procesos de CA-08 (iii)
  # calculándose como 0/0 y saliendo `0,000×` — PASA en vacío.
  case "${SONDA[procesos]}" in
    no-aplica) ;;
    *) if ! sonda_num "${SONDA[procesos]}"; then SONDA_MOTIVO="el campo 'procesos' no es un número ni 'no-aplica' (<${SONDA[procesos]}>)"; return 1; fi ;;
  esac
  # `vivos` es obligatorio SÓLO en el registro de un instrumento de `tests/util/`
  # (CA-10 punto 2): ausente ahí es ilegible → FAIL, nunca un cero.
  if sonda_es_util "${SONDA[sonda]}"; then
    if [ -z "${SONDA[vivos]:-}" ]; then SONDA_MOTIVO="al registro de '${SONDA[sonda]}' le falta 'vivos', y es un instrumento de tests/util/: un cero publicado y un campo ausente no son lo mismo"; return 1; fi
    if ! sonda_num "${SONDA[vivos]}"; then SONDA_MOTIVO="el campo 'vivos' no es un número (<${SONDA[vivos]}>)"; return 1; fi
  fi
  return 0
}
