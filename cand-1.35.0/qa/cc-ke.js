// Funciones copiadas LITERALMENTE del binario de Claude Code 2.1.284 (cadenas extraidas con strings):
// b, w, y, _, $ke. Se ejecutan sobre el mismo documento que ve el hook.
const x="‘",h="’",A="“",T="”";
function b(e){return e.replaceAll(x,"'").replaceAll(h,"'").replaceAll(A,'"').replaceAll(T,'"')}var w=/\\u[0-9a-fA-F]{4}/,y=/[\u0080-￿]/;function _(e){return e.replace(/(\\\\)|\\u([0-9a-fA-F]{4})/g,(n,r,i)=>r!==void 0?n:String.fromCharCode(parseInt(i,16)))}
function $ke(e,n){if(e.includes(n))return n;let r=b(n),s=b(e).indexOf(r);if(s!==-1)return e.substring(s,s+n.length);if(w.test(n)){let o=_(n);if(o!==n&&e.includes(o))return o}if(y.test(n)){return "(rama N no copiada)"}return null}
const doc1="# REQ-950 — prueba\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\n";
const doc2="# REQ-950 — prueba\nEstado: en-revisión\nNota: “ver R-1”\nQA: pendiente\n";
const bs=String.fromCharCode(92);
console.log("G1 old_string =", JSON.stringify("en-revisi"+bs+"u00f3n"), "->", JSON.stringify($ke(doc1,"en-revisi"+bs+"u00f3n")));
console.log("G2 old_string =", JSON.stringify('en-revisión\nNota: "ver R-1"'), "->", JSON.stringify($ke(doc2,'en-revisión\nNota: "ver R-1"')));
console.log("control inexistente ->", JSON.stringify($ke(doc1,"NOEXISTE")));
