import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read().split('\n')
QA_ADD = ("; 2026-10-02, vuelta excepcional de la octava autorización, árbol c877246 (código 9220c71): "
 "reparación central VERIFICADA a nivel de hook en cuatro árboles —SEC-122 caras a y b (ningún prefijo /dev/ ni /proc/ "
 "queda fuera de la identidad; lo dependiente del proceso se detecta y no recibe permiso; /dev/null y descriptores estándar "
 "legítimos siguen pasando), QA-023-14 (la lectura ya no recorre el valor: coste plano en Linux, 106-506 ms de 20000 a 600000 "
 "bytes frente a 0,2-97 s de 3bc7d3c), P-023-13-A/CR del texto de Bash (el command llega con su CR y se juzga lo que el shell "
 "escribe; heredoc con CR en el delimitador denegado con motivo)—; 87 filas de las baterías del desarrollador reproducidas por QA "
 "0 diferencias, sección 45 160 PASS, fail-before de 41-45 contra 3bc7d3c 59 FAIL (52 de la 45); banco completo 1729 PASS, 0 FAIL, "
 "12 SKIP (1 INCONCLUSO de rendimiento), cuadre 1741; autoprueba 117/0; gates rc 0; guard.sh y guard-git.sh sin cambios (sha256 =); "
 "coste bajo procedimiento registrado antes de medir; plataformas conformes (sólo nivel de hook Linux/WSL2 para 9220c71). "
 "CONFIRMADOS los dos de P-122-A: (1) git stash<CR> allow, con help.autocorrect=immediate git ejecuta el stash; (2) src/log->/dev/stderr "
 "allow por Bash, el shell escribe al descriptor. NUEVO QA-023-16 (contrato): la enumeración «sólo esos ocho» movimientos deny->allow "
 "de CA-66 (octava) es incompleta —hay además una familia del CR al final en comandos git prohibidos (git checkout .<CR>, checkout -- .<CR>, "
 "restore .<CR>, checkout HEAD .<CR>) fuera de los ocho y fuera de P-122-A—; NUEVO QA-023-17 (instrumento): P-122-A (2). VEREDICTO: "
 "CON-HALLAZGOS para el delta; los tres defectos (P-122-A 1 y 2, QA-023-16/17) van a la pasada correctiva autorizada; QA pendiente se "
 "mantiene (bloques B y C sin rendir; QA-114, QA-116, QA-117 y QA-023-10 contrato abiertos); docs/qa/REQ-023.md")
HALL_ADD = (", QA-023-16 (contrato, dueño analista-requerimientos y desarrollador; introducido por 9220c71: la enumeración de CA-66 "
 "versionado de la octava autorización afirma «y sólo esos ocho» movimientos deny->allow y «cualquier otro es un hallazgo», pero el "
 "código construido produce más: la familia del retorno de carro AL FINAL en comandos git prohibidos cuyo último token es un pathspec "
 "—git checkout .<CR>, git checkout -- .<CR>, git restore .<CR>, git checkout HEAD .<CR>— sale allow en el candidato y deny en 9596e39, "
 "1.33.2 y 3bc7d3c, fuera de los ocho declarados (sólo G1, git reset --hard<CR>, está declarado) y fuera de P-122-A; seguros por efecto "
 "—git rechaza el pathspec con CR y help.autocorrect no corrige pathspec, medido con git 2.53.0: a.txt sin revertir— pero el contrato "
 "dice algo falso sobre lo construido; se resuelve en la pasada correctiva declarando la clase git-CR por propiedad o reparándola; "
 "medido a nivel de hook en cuatro árboles, docs/qa/REQ-023.md), QA-023-17 (instrumento, dueño desarrollador; introducido por 9220c71 "
 "y es P-122-A (2): por Bash, un enlace del último componente SITUADO DENTRO de un ámbito protegido que apunta a un descriptor "
 "—src/log -> /dev/stderr— sale allow en el candidato y deny en 9596e39, 1.33.2 y 3bc7d3c; arnes_id_pertenece responde «fuera» para un "
 "descriptor antes de mirar las tres vías de CA-47 punto 6, entre ellas la lectura léxica src/log que sí está en el ámbito; seguro por "
 "efecto —el shell escribe al descriptor, no a src/a.ts, comprobado—; por Write/Edit el mismo enlace se deniega; se decide o repara en "
 "la pasada correctiva; docs/qa/REQ-023.md)")
out=[]
for ln in s:
    if ln.startswith('QA: ') and ln.endswith(')'):
        ln = ln[:-1] + QA_ADD + ')'
    elif ln.startswith('Hallazgos abiertos: '):
        ln = ln + HALL_ADD
    out.append(ln)
io.open(p,'w',encoding='utf-8').write('\n'.join(out))
print("editado")
