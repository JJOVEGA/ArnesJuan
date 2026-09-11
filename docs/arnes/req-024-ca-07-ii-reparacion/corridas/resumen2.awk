{ delete v; for(i=1;i<=NF;i++){n=index($i,"="); if(n){v[substr($i,1,n-1)]=substr($i,n+1)}}
  if(v["estado"]!="ok"){ printf "  rep=%-3s NO-OK estado=%s motivo=%s\n", v["rep"], v["estado"], v["motivo"]; nok++; next }
  r=v["min_a"]*1000/v["min_b"]; ca=v["min2_a"]*1000/v["min_a"]; cb=v["min2_b"]*1000/v["min_b"]
  rr[++n_]=r; if(n_==1){mx=r;mn=r} ; if(r>mx)mx=r; if(r<mn)mn=r; s+=r
  c=(ca>cb?ca:cb); cc[n_]=c; if(c>cmx)cmx=c
  if(r>1250)sobre++
  if(c>1250)nconv++
  printf "  rep=%-3s r=%.3f peor_conv=%.3f a=%dus b=%dus carga=%s\n", v["rep"], r/1000, c/1000, v["min_a"], v["min_b"], v["carga"]
}
END{ n=asort(rr); printf "  -> n=%d  min=%.3f  p50=%.3f  max=%.3f  media=%.3f  max/min=%.3f  peor_conv=%.3f  r>1.250: %d/%d  conv>1.250: %d/%d  no-ok=%d\n", n_, mn/1000, rr[int((n_+1)/2)]/1000, mx/1000, (s/n_)/1000, (mx/mn)/1000, cmx/1000, sobre+0, n_, nconv+0, n_, nok+0 }
