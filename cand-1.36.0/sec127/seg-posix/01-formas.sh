# cada forma de las que usa el codigo, en un subshell aparte para que un error de analisis no tumbe el resto
x='a $(b) (c) "d" e;f'
eval 'r1="${x//'"'"'$('"'"'/ }"' 2>&1 && printf 'F1 dollar-paren  [%s]\n' "$r1" || echo "F1 ERROR"
eval 'r2="${x//'"'"'('"'"'/A}"' 2>&1 && printf 'F2 paren-abre    [%s]\n' "$r2" || echo "F2 ERROR"
eval 'r3="${x//'"'"')'"'"'/C}"' 2>&1 && printf 'F3 paren-cierra  [%s]\n' "$r3" || echo "F3 ERROR"
eval 'r4="${x//'"'"'"'"'"'/Q}"' 2>&1 && printf 'F4 comilla-doble [%s]\n' "$r4" || echo "F4 ERROR"
eval 'r5="${x//;/$'"'"'\n'"'"'}"' 2>&1 && printf 'F5 ansi-c-repl   [%q]\n' "$r5" || echo "F5 ERROR"
