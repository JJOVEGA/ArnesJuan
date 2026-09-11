{ delete v; for(i=1;i<=NF;i++){n=index($i,"="); if(n){v[substr($i,1,n-1)]=substr($i,n+1)}}
  if(v["estado"]!="ok"){ printf "  rep=%-3s NO-OK estado=%s motivo=%s\n", v["rep"], v["estado"], v["motivo"]; nok++; next }
  r=v["min_a"]*1000/v["min_b"]; ca=v["min2_a"]*1000/v["min_a"]; cb=v["min2_b"]*1000/v["min_b"]
  rr[++n_]=r; if(r>mx||n_==1)mx=r; if(r<mn||n_==1)mn=r; s+=r
  if(ca>cmx)cmx=ca; if(cb>cmx)cmx=cb
  if(r>1250)sobre++
  printf "  rep=%-3s r=%.3f conv_a=%.3f conv_b=%.3f a=%dus b=%dus carga=%s\n", v["rep"], r/1000, ca/1000, cb/1000, v["min_a"], v["min_b"], v["carga"]
}
END{ asort(rr); printf "  -> n=%d  min=%.3f  p50=%.3f  max=%.3f  media=%.3f  recorrido=%.3f  peor_conv=%.3f  sobre_1.250=%d\n", n_, mn/1000, rr[int((n_+1)/2)]/1000, mx/1000, (s/n_)/1000, (mx/mn)/1000, cmx/1000, sobre+0 }
