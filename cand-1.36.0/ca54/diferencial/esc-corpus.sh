#!/usr/bin/env bash
# corpus dirigido + aleatorio (semilla fija), separado por NUL
dir=( 'echo x > src/a.ts' 'echo x>src/a.ts' 'echo x >> src/a.ts' 'echo x >| src/a.ts' 'a | tee -a src/a.ts b' 'cp a b src' 'cp -r a src/' 'mv a src/b'
 'install -m 644 a src/b' 'sed -i s/a/b/ src/a.ts' 'sed --in-place=.bak s/x/y/ f' 'sed --expression=x f' 'perl -pi -e s/a/b/ src/a.ts' 'dd if=a of=src/a.ts'
 'git commit -m "toca src/a.ts"' "echo 'x > src/a.ts'" 'echo "a" > "src/b c"' 'x; y && z || w & v' 'echo $(echo x > src/a.ts)' 'echo `echo x > src/a.ts`'
 $'cat <<EOF\n$(echo x > src/a.ts)\nEOF' $'cat <<\'EOF\'\n$(echo x > src/a.ts)\nEOF\necho y > src/b.ts' $'cat <<-EOF\n\t$(cp a src/)\n\tEOF' $'cat <<"EOF"\ncp a src/\nEOF'
 $'cat <<EOF\ndon\'t $(cp README.md src/a.ts)\nEOF' $'cat <<EOF\n\\$(cp a src/)\nEOF' $'cat <<EOF\n$(echo "a)b" > src/a.ts)\nEOF' $'cat <<EOF\n$(echo \\) > src/x.ts)\nEOF'
 $'echo x > \\\nsrc/a.ts' $'echo x \\\n > src/a.ts' $'cat <<EOF \\\n> src/a.ts\nb\nEOF' $'cat <<EOF\r\nx\nEOF\r\necho > src/a.ts' $'printf x > k\r' $'cat <<EOF\nEOF\r\necho x > src/a.ts'
 'echo ñ > src/ñ.ts' 'echo x > src/é' $'echo x > "src/a\xc3"' 'echo $((1<<3)) > f' 'cat <<< "x" > src/a.ts' 'echo x 2>/dev/null > src/a' 'echo x &> src/a' 'echo x>&2'
 'for f in *; do echo $f > src/$f; done' '(echo x > src/a.ts)' '{ echo x; } > src/a.ts' 'echo x > src/a.ts;echo y > src/b.ts' "echo x > 'src/a.ts'" 'tee' 'cp' 'sed -i' 'of=' '>' '' ' ' )
printf '%s\0' "${dir[@]}"
RANDOM=4242
alf=( 'echo' 'x' '>' '>>' '|' ';' '&&' '||' '&' 'tee' '-a' 'cp' 'mv' 'install' 'sed' '-i' 'perl' '-pi' 'of=src/a' 'dd' 'src/a.ts' 'src/' 'docs/../src/x' '"' "'" '$(' ')' '`' '\' $'\n' '<<EOF' "<<'EOF'" '<<-EOF' 'EOF' '#' 'ñ' 'é' $'\r' '(' '{' '}' '$((' '1<<2' '<<<' '2>' '>&2' '/dev/null' '*' '?' '[' ']' )
for ((n = 0; n < 4000; n++)); do
  k=''; m=$(( RANDOM % 14 + 1 ))
  for ((i = 0; i < m; i++)); do k+="${alf[RANDOM % ${#alf[@]}]}"; (( RANDOM % 3 )) && k+=' '; done
  printf '%s\0' "$k"
done
