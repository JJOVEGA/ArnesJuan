{ delete v; for(i=1;i<=NF;i++){n=index($i,"="); if(n){v[substr($i,1,n-1)]=substr($i,n+1)}}
  if(v["min_a"]+0<=0||v["min_b"]+0<=0){ printf "  rep=%-3s SIN-MINIMOS estado=%s\n",v["rep"],v["estado"]; next }
  r=v["min_a"]*1000/v["min_b"]; ca=v["min2_a"]*1000/v["min_a"]; cb=v["min2_b"]*1000/v["min_b"]
  c=(ca>cb?ca:cb); rr[++n_]=r; if(n_==1){mn=r;mx=r}; if(r<mn)mn=r; if(r>mx)mx=r; s+=r
  if(c>cmx)cmx=c; if(r>1250)sobre++
  if(v["estado"]=="suelo")suelo++
}
END{ if(n_==0){print "  (sin datos)"; exit}
  asort(rr)
  printf "  n=%d  min=%.3f  p50=%.3f  max=%.3f  media=%.3f  peor_conv=%.3f  r>1.250: %d  bajo_suelo: %d\n", n_, mn/1000, rr[int((n_+1)/2)]/1000, mx/1000, (s/n_)/1000, cmx/1000, sobre+0, suelo+0 }
