{ delete v; for(i=1;i<=NF;i++){n=index($i,"="); if(n){v[substr($i,1,n-1)]=substr($i,n+1)}}
  if(v["estado"]!="ok") next
  r[++n_]=v["min_a"]*1000/v["min_b"] }
END{
  tot_mn=r[1]; tot_mx=r[1]
  for(i=1;i<=n_;i++){ if(r[i]<tot_mn)tot_mn=r[i]; if(r[i]>tot_mx)tot_mx=r[i] }
  totrec=tot_mx*1000/tot_mn
  printf "%-28s n=%d recorrido_total=%.3f (min %.3f max %.3f)\n", ARCHIVO, n_, totrec/1000, tot_mn/1000, tot_mx/1000
  for(k=2;k<=8;k++){
    peor=0
    for(i=1;i+k-1<=n_;i++){ mn=r[i];mx=r[i]
      for(j=i;j<i+k;j++){ if(r[j]<mn)mn=r[j]; if(r[j]>mx)mx=r[j] }
      w=mx*1000/mn; if(w>peor)peor=w }
    printf "    k=%d  peor_ventana=%.3f  (%.0f%% del recorrido total)\n", k, peor/1000, (peor-1000)*100/(totrec-1000)
  }
}
