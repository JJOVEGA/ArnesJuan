#!/usr/bin/env python3
# QA-007-06: dos causas más de `read` fallido: (a) datos y DESPUÉS error (pty cuyo maestro se cierra: EIO tras los datos);
# (b) una tubería NO BLOQUEANTE sin datos todavía (EAGAIN). Cada una contra los guardianes de tres árboles.
import os, pty, subprocess, sys, json, fcntl, time
S="/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa5"
PQ=S+"/proy"
H={"cand":"/home/juan/dev/ArnesJuan-v1.36/hooks","413c":S+"/413c6bd/hooks","v135":"/home/juan/dev/ArnesJuan-v1.35.0-base/hooks"}
env=dict(os.environ); env.pop("LC_ALL",None); env["LANG"]="C.UTF-8"; env["CLAUDE_PROJECT_DIR"]=PQ; env.pop("ARNES_INPUT",None)
src=json.dumps({"hook_event_name":"PreToolUse","tool_name":"Write","cwd":PQ,"tool_input":{"file_path":"src/a.ts","content":"x"}})
def dec(o):
    if '"permissionDecision":"deny"' in o:
        r=json.loads(o)["hookSpecificOutput"]["permissionDecisionReason"]; return "deny<"+r[:45]+">"
    return "nada" if o=="" else "otra<"+o[:60]+">"
for nombre in [n for n in ["pty: JSON (Write a src/ de la coordinadora) y luego EIO", "pty: JSON truncado y luego EIO", "pipe no bloqueante sin datos (EAGAIN)", "pipe no bloqueante: JSON a los 0,3 s", "pipe no bloqueante: JSON ya escrito, escritor abierto 0,3 s"] if n.startswith("pipe no bloqueante:")]:
  for a in ["cand","413c","v135"]:
    for s in ["guard.sh","guard-codigo.sh"]:
        if nombre.startswith("pty"):
            m, sl = pty.openpty()
            import termios; at=termios.tcgetattr(sl); at[3] &= ~(termios.ICANON|termios.ECHO); termios.tcsetattr(sl, termios.TCSANOW, at)
            data = src if "truncado" not in nombre else src[:40]
            os.write(m, data.encode())
            p=subprocess.Popen(["bash",H[a]+"/"+s],stdin=sl,stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=PQ,env=env)
            os.close(sl); time.sleep(0.3); os.close(m)
            o,e=p.communicate(timeout=30)
        else:
            r,w=os.pipe(); fl=fcntl.fcntl(r,fcntl.F_GETFL); fcntl.fcntl(r,fcntl.F_SETFL,fl|os.O_NONBLOCK)
            p=subprocess.Popen(["bash",H[a]+"/"+s],stdin=r,stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=PQ,env=env)
            os.close(r)
            if "ya escrito" in nombre: os.write(w,src.encode())
            try:
                if "a los 0,3" in nombre: time.sleep(0.3); os.write(w,src.encode())
            except BrokenPipeError: print("   (tuberia rota: el hook ya habia salido)", flush=True)
            time.sleep(0.3); os.close(w)
            o,e=p.communicate(timeout=30)
        print(f"{nombre:58} {a:5} {s:16} {dec(o.decode())} rc={p.returncode} err=<{e.decode()[:110].strip()}>", flush=True)
