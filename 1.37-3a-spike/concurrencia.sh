S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
. <(sed -n '/^SPIKE=/,/^}$/p;/^json()/,/^}$/p' "$S/casos.sh")
PP=$SPIKE/hooks/puerta-posterior.sh; export TMPDIR=$S/estado5; rm -rf $TMPDIR; mkdir -p $TMPDIR; P=$S/p/conc
[ -n "$P" ] || exit 1
nuevo_proyecto "$P"
h() { json "$P" "$1" "$2" "$3" | CLAUDE_PROJECT_DIR=$P bash $PP "$4" 2>/dev/null; }
h qa-tester 'sleep 1' tq pre; h desarrollador "printf '#dev' >> hooks/lib.sh" td pre
(cd "$P" && printf '#dev' >> hooks/lib.sh)
echo "Post(qa) primero: $(h qa-tester 'sleep 1' tq post | jq -r .decision)"
echo "Post(dev) después: $(h desarrollador x td post)"
tail -c 4 "$P/hooks/lib.sh" | grep -q '#dev' && echo "el cambio del desarrollador SIGUE" || echo "el cambio del desarrollador SE PERDIÓ"
