. "$(dirname "$0")/qa-lib.sh"
E0='Estado: en-revisión'; EC='Estado: completado'
P=$'!"#$%&\'()*+,-./0123456789;<=>?@[\\]^_`{|}~'
res=''
for ((i=0;i<${#P};i++)); do ch="${P:i:1}"
  doc "$E0" "Sensible a${ch}seguridad: sí" 'QA: pendiente' 'Seguridad: pendiente' 'Rigor: ligero'
  printf '%s' "$DOC" > "$F"; j="$(jwrite "${DOC/"$E0"/"$EC"}")"; juzga "$CAND" "$j"; c=$DEC; m=${MOT:0:60}; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$j"
  res+="$(printf '%q' "$ch"):cand=$c/base=$DEC "
  case "$c" in deny) echo "  $(printf '%q' "$ch") -> cand=deny base=$DEC | $m";; esac
done
echo "$res" | fold -w 200
