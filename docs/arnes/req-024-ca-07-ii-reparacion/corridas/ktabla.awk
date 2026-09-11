{ delete v; for(i=1;i<=NF;i++){n=index($i,"="); if(n){v[substr($i,1,n-1)]=substr($i,n+1)}}
  if(v["min_a"]+0<=0||v["min_b"]+0<=0) next
  r[++n_]=v["min_a"]*1000/v["min_b"] }
END{ if(n_<8) exit
  tmn=r[1];tmx=r[1]; for(i=1;i<=n_;i++){if(r[i]<tmn)tmn=r[i]; if(r[i]>tmx)tmx=r[i]}
  tot=tmx*1000/tmn
  printf "%-12s", ARCHIVO
  for(k=2;k<=6;k++){ peor=0
    for(i=1;i+k-1<=n_;i++){mn=r[i];mx=r[i]
      for(j=i;j<i+k;j++){if(r[j]<mn)mn=r[j]; if(r[j]>mx)mx=r[j]}
      w=mx*1000/mn; if(w>peor)peor=w}
    printf " k%d=%3.0f%%", k, (peor-1000)*100/(tot-1000) }
  printf "   (recorrido total %.3f)\n", tot/1000 }
