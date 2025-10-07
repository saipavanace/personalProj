#!/usr/bin/env node
/* json2sv.js — Streaming JSON → SystemVerilog codegen
 *
 * Outputs (to --out):
 *   dv_cfg_pkg.sv       : hierarchical classes + singleton get_dv_cfg()
 *   if_cfg_pkg.sv       : protocol/feature arrays for per-instance decisions
 *   port_binds_auto.sv  : optional DV↔RTL assigns from ariaObj.PortList
 *   tb_report_auto.sv   : optional time-0 report of interface table
 *   dut_select_auto.sv  : **NEW** protocol/feature aware DUT wrapper (generated)
 *
 * Usage (generic):
 *   setenv NODE_OPTIONS "--max-old-space-size=16384" ; node json2sv.js \
 *     <path/to/top.level.dv.json> \
 *     --pkg dv_cfg_pkg \
 *     --root TopLevelDvCfg \
 *     --if-pkg if_cfg_pkg \
 *     --top TOP \
 *     --out <path/to/output> \
 *     --emit-binds \
 *     --emit-report
 */

const fs = require("fs");
const nodePath = require("path");

// deps
let chain, parser;
try {
  ({ chain } = require("stream-chain"));
  ({ parser } = require("stream-json"));
} catch (e) {
  console.error("Missing dependency 'stream-json'. Install with: npm i stream-json");
  process.exit(2);
}

/* ---------------- CLI ---------------- */
const args = process.argv.slice(2);
if (!args.length) {
  console.error(`Usage:
  node json2sv.js <jsonPath>
    --pkg dv_cfg_pkg --root TopLevelDvCfg --if-pkg if_cfg_pkg --top TOP --out <path>
    [--emit-binds] [--emit-report] [--no-wrapper]
    [--no-fast] [--max-enum 16] [--max-array-merge 64] [--drop-keys ...]
    [--skip-dv] [--skip-if]
  (aliases: --axi-pkg == --if-pkg, --out-dir == --out)
`);
  process.exit(1);
}

const opts = {
  jsonPath: args[0],
  pkg: "dv_cfg_pkg",
  root: "TopLevelDvCfg",
  ifPkg: "if_cfg_pkg",
  top: "TOP",
  outDir: "./out",
  emitBinds: false,
  emitReport: false,
  emitWrapper: true,   // NEW: wrapper ON by default
  fast: true,
  maxEnum: 16,
  maxArrayMerge: 64,
  dropKeys: [],
  skipDv: false,
  skipIf: false,
};

for (let i=1;i<args.length;i++){
  const a=args[i];
  if (a==="--pkg") opts.pkg = args[++i];
  else if (a==="--root") opts.root = args[++i];
  else if (a==="--if-pkg") opts.ifPkg = args[++i];
  else if (a==="--axi-pkg") opts.ifPkg = args[++i]; // alias
  else if (a==="--top") opts.top = args[++i];
  else if (a==="--out" || a==="--out-dir") opts.outDir = args[++i]; // alias
  else if (a==="--emit-binds") opts.emitBinds = true;
  else if (a==="--emit-report") opts.emitReport = true;
  else if (a==="--no-wrapper") opts.emitWrapper = false;
  else if (a==="--no-fast") opts.fast = false;
  else if (a==="--max-enum") opts.maxEnum = parseInt(args[++i],10)||16;
  else if (a==="--max-array-merge") opts.maxArrayMerge = parseInt(args[++i],10)||64;
  else if (a==="--drop-keys") opts.dropKeys = String(args[++i]).split(",").map(s=>s.trim()).filter(Boolean);
  else if (a==="--skip-dv") opts.skipDv = true;
  else if (a==="--skip-if") opts.skipIf = true;
}

// fs checks
if (!fs.existsSync(opts.jsonPath)) { console.error("JSON not found:", opts.jsonPath); process.exit(1); }
if (!fs.existsSync(opts.outDir)) fs.mkdirSync(opts.outDir, {recursive:true});
const t0 = process.hrtime.bigint();

/* ---------------- Utils ---------------- */
const SV_KW = new Set([
  "rand","constraint","class","virtual","function","task","endclass","endfunction","endtask",
  "package","endpackage","module","endmodule","interface","endinterface","typedef","union",
  "struct","enum","int","longint","shortint","byte","bit","logic","string","const","static",
  "localparam","parameter","return","if","else","for","foreach","begin","end","case","endcase",
  "import","export","extern","new","real"
]);
function camelToSnake(s){ return String(s).replace(/([a-z0-9])([A-Z])/g, "$1_$2").replace(/[^\w$]/g, "_").toLowerCase(); }
function sanitizeIdent(s, fallback="id"){ let x=String(s).replace(/[^\w$]/g,"_"); if (/^\d/.test(x)) x="_"+x; if (!x.length) x=fallback; if (SV_KW.has(x)) x=x+"_"; return x; }
function snakeLower(s){ return sanitizeIdent(camelToSnake(s)); }
function ucfirst(s){ return s ? s[0].toUpperCase()+s.slice(1) : s; }
function litStr(s){ return JSON.stringify(String(s)); }

const ITEM="__item__";
const schema = new Map(); // pathKey -> { kind:'object'|'array'|'scalar', keys:Set, elem:'object'|'scalar'|null }
const arrLimit = opts.maxArrayMerge;
function pkey(arr){ return arr.map(sanitizeIdent).join("."); }
function ensure(map, k, init){ if (!map.has(k)) map.set(k, init()); return map.get(k); }

/* ---------------- PASS1: schema ---------------- */
function pass1(){
  return new Promise((resolve, reject)=>{
    let container = [];     // 'object'|'array'
    let keyPath = [];       // keys from root to current container
    let pendingKey = null;  // last key awaiting value

    function markObject(path){
      const k = pkey(path);
      const s = ensure(schema,k,()=>({kind:'object', keys:new Set()}));
      s.kind='object'; return s;
    }
    function markArray(path){
      const k = pkey(path);
      const s = ensure(schema,k,()=>({kind:'array', keys:new Set(), elem:null}));
      s.kind='array'; return s;
    }
    function markScalar(path){
      const k = pkey(path);
      const s = ensure(schema,k,()=>({kind:'scalar'}));
      s.kind='scalar'; return s;
    }
    function addKey(path, key){
      const s = markObject(path);
      s.keys.add(sanitizeIdent(key));
    }

    const pipeline = chain([ fs.createReadStream(opts.jsonPath), parser() ]);

    pipeline.on('data', ({name, value})=>{
      switch(name){
        case 'startObject': {
          if (container.length===0) { markObject([]); container.push('object'); break; }
          if (pendingKey !== null) { addKey(keyPath, pendingKey); keyPath.push(sanitizeIdent(pendingKey)); markObject(keyPath); container.push('object'); pendingKey = null; }
          else { const arrSch = markArray(keyPath); arrSch.elem='object'; keyPath.push(ITEM); markObject(keyPath); container.push('object|arrayItem'); }
          break;
        }
        case 'endObject': {
          const top = container.pop();
          if (top==='object') keyPath.pop();
          else if (top==='object|arrayItem') keyPath.pop();
          break;
        }
        case 'startArray': {
          if (pendingKey !== null) { addKey(keyPath, pendingKey); keyPath.push(sanitizeIdent(pendingKey)); markArray(keyPath); container.push('array'); pendingKey=null; }
          else { const arrSch=markArray(keyPath); arrSch.elem='array'; keyPath.push(ITEM); markArray(keyPath); container.push('array|arrayItem'); }
          break;
        }
        case 'endArray': {
          const top = container.pop();
          if (top==='array') keyPath.pop();
          else if (top==='array|arrayItem') keyPath.pop();
          break;
        }
        case 'keyValue': pendingKey = String(value); break;
        case 'nullValue':
        case 'trueValue':
        case 'falseValue':
        case 'numberValue':
        case 'stringValue': {
          if (pendingKey !== null) {
            addKey(keyPath, pendingKey);
            const leafPath = keyPath.concat(sanitizeIdent(pendingKey));
            markScalar(leafPath);
            pendingKey = null;
          } else {
            const arrSch = markArray(keyPath);
            arrSch.elem = arrSch.elem || 'scalar';
          }
          break;
        }
      }
    });

    pipeline.on('end', resolve);
    pipeline.on('error', reject);
  });
}

/* ---------------- Class registry ---------------- */
class Registry {
  constructor(pkg, root){ this.pkg=sanitizeIdent(pkg); this.root=sanitizeIdent(root); this.order=[]; this.classes=new Map(); }
  addClass(name, fields){ if (!this.classes.has(name)) { this.classes.set(name, fields); this.order.push(name); } }
}
const reg = new Registry(opts.pkg, opts.root);

function pathToClass(pArr){
  if (!pArr || pArr.length===0) return sanitizeIdent(opts.root);
  const parts = pArr.filter(Boolean).map(sanitizeIdent).map(ucfirst);
  return sanitizeIdent(parts.join(""));
}
function buildClassesFromSchema(){
  const objEntries = [...schema.entries()].filter(([k,v]) => v.kind === 'object');
  objEntries.sort((a,b)=> a[0].split('.').length - b[0].split('.').length);

  for (const [k,info] of objEntries){
    const pArr = k ? k.split('.').filter(Boolean) : [];
    const clsName = pathToClass(pArr.length ? pArr : []);
    const fields = [];
    const keys = [...(info.keys||[])].sort();
    for (const key of keys){
      const childPath = pArr.concat(key);
      const childKey = childPath.join('.');
      const ch = schema.get(childKey);
      if (!ch) { fields.push({decl:`string ${key};`}); continue; }
      if (ch.kind === 'scalar') {
        fields.push({decl:`string ${key};`});
      } else if (ch.kind === 'object') {
        const subName = pathToClass(childPath);
        fields.push({decl:`${subName} ${key};`});
      } else if (ch.kind === 'array') {
        if (ch.elem === 'object') {
          const itemName = pathToClass(childPath.concat(ITEM));
          fields.push({decl:`${itemName} ${key}[$];`});
        } else {
          fields.push({decl:`string ${key}[$];`});
        }
      } else {
        fields.push({decl:`string ${key};`});
      }
    }
    reg.addClass(clsName, fields);
  }
  if (!reg.classes.has(opts.root)) reg.addClass(opts.root, []);
}

/* ---------------- Emit dv_cfg_pkg.sv ---------------- */
function emitDvHeader(ws){
  const W = s => ws.write(s+"\n");
  W(`// Auto-generated: ${reg.pkg}.${reg.root}`);
  W(`package ${reg.pkg};\n`);
  for (const cls of reg.order) W(`class ${cls}; endclass`);
  W("");
  for (const cls of reg.order){
    W(`class ${cls};`);
    const fields = reg.classes.get(cls) || [];
    for (const f of fields) W(`  ${f.decl}`);
    W(`  function new(); endfunction`);
    W(`endclass\n`);
  }
  W(`${reg.root} p_dv_cfg;`);
  W(`function ${reg.root} get_dv_cfg(); if (p_dv_cfg==null) p_dv_cfg=__construct_dv_cfg(); return p_dv_cfg; endfunction`);
  W(`function void dv_cfg_reset(); p_dv_cfg=null; endfunction`);
}

function emitDvAssignments(ws){
  const W = s => ws.write(s+"\n");
  W(`\nfunction automatic ${reg.root} __construct_dv_cfg();`);
  W(`  ${reg.root} cfg; cfg = new();`);

  const arrayPaths = [...schema.entries()].filter(([k,v])=>v.kind==='array').map(([k])=>k).sort();
  const idxVar = (p)=>`__idx_${p.split('.').map(sanitizeIdent).join('_')}`;
  for (const p of arrayPaths) W(`  int ${idxVar(p)} = -1;`);

  const initedObjs = new Set();
  const activeArray = new Set();

  function svPathFor(pArr){
    let parts = ["cfg"];
    let prefix = [];
    for (const seg of pArr){
      prefix.push(seg);
      const k = prefix.join('.');
      parts.push(seg);
      const sch = schema.get(k);
      if (sch && sch.kind==='array' && activeArray.has(k)) {
        parts[parts.length-1] += `[${idxVar(k)}]`;
      }
    }
    return parts.join(".");
  }
  function ensureNew(pArr){
    const k = pArr.join('.');
    const sch = schema.get(k);
    if (!sch || sch.kind!=='object') return;
    const sv = svPathFor(pArr);
    if (initedObjs.has(sv)) return;
    if (pArr.length>0) ensureNew(pArr.slice(0,-1));
    W(`  ${sv} = new();`);
    initedObjs.add(sv);
  }

  return new Promise((resolve, reject)=>{
    let container = [];
    let keyPath = [];
    let pendingKey = null;

    const pipeline = chain([ fs.createReadStream(opts.jsonPath), parser() ]);
    pipeline.on('data', ({name,value})=>{
      switch(name){
        case 'startObject': {
          if (container.length===0) { ensureNew([]); container.push({t:'object', how:'root'}); break; }
          if (pendingKey !== null) {
            const fld = sanitizeIdent(pendingKey);
            ensureNew(keyPath);
            const cur = keyPath.concat(fld);
            ensureNew(cur);
            keyPath.push(fld);
            container.push({t:'object', how:'field'});
            pendingKey = null;
          } else {
            const arrPath = keyPath.join('.');
            W(`  ${idxVar(arrPath)}++;`);
            const svArr = svPathFor(keyPath);
            W(`  ${svArr}.push_back(new());`);
            activeArray.add(arrPath);
            initedObjs.add(`${svArr}[${idxVar(arrPath)}]`);
            keyPath.push(ITEM);
            container.push({t:'object', how:'arrayItem', arr: arrPath});
          }
          break;
        }
        case 'endObject': {
          const top = container.pop();
          if (top.how === 'field') keyPath.pop();
          else if (top.how === 'arrayItem') { activeArray.delete(top.arr); keyPath.pop(); }
          break;
        }
        case 'startArray': {
          if (pendingKey !== null) { const fld = sanitizeIdent(pendingKey); ensureNew(keyPath); keyPath.push(fld); container.push({t:'array', how:'field'}); pendingKey = null; }
          else { const arrPath = keyPath.join('.'); W(`  ${idxVar(arrPath)}++;`); const svArr=svPathFor(keyPath); W(`  // nested array element under ${svArr}[${idxVar(arrPath)}]`); activeArray.add(arrPath); keyPath.push(ITEM); container.push({t:'array', how:'arrayItem', arr:arrPath}); }
          break;
        }
        case 'endArray': {
          const top = container.pop();
          if (top.how === 'field') keyPath.pop();
          else if (top.how === 'arrayItem') { activeArray.delete(top.arr); keyPath.pop(); }
          break;
        }
        case 'keyValue': pendingKey = String(value); break;
        case 'nullValue':
        case 'trueValue':
        case 'falseValue':
        case 'numberValue':
        case 'stringValue': {
          let vStr;
          if (name==='stringValue') vStr = litStr(value);
          else if (name==='numberValue') vStr = litStr(String(value));
          else if (name==='trueValue') vStr = litStr("true");
          else if (name==='falseValue') vStr = litStr("false");
          else vStr = litStr("");

          if (pendingKey !== null) {
            const fld = sanitizeIdent(pendingKey);
            ensureNew(keyPath);
            const sv = svPathFor(keyPath).concat(`.${fld}`);
            W(`  ${sv} = ${vStr};`);
            pendingKey = null;
          } else {
            const svArr = svPathFor(keyPath);
            W(`  ${svArr}.push_back(${vStr});`);
          }
          break;
        }
      }
    });
    pipeline.on('end', ()=>{ W(`  return cfg;`); W(`endfunction\n`); resolve(); });
    pipeline.on('error', reject);
  });
}

/* ---------------- if_cfg_pkg.sv (interfaces) ---------------- */
function normalizeProto(s){
  const x = String(s||"").trim().toUpperCase();
  if (x==="ACE5") return "ACE5";
  if (x==="ACE4"||x==="ACE") return "ACE4";
  if (x==="ACE-LITE-E"||x==="ACELITE-E"||x==="ACE-LITE") return "ACE_LITE_E";
  if (x==="AXI5") return "AXI5";
  if (x==="AXI4"||x==="AXI") return "AXI4";
  if (x==="CHI-B"||x==="CHIB") return "CHI_B";
  if (x==="CHI-E"||x==="CHIE") return "CHI_E";
  return "UNKNOWN";
}
function isBoolLike(v){ if (typeof v==="boolean") return true; if (typeof v==="number") return v===0||v===1; if (typeof v==="string") return /^0|1|true|false$/i.test(v.trim()); return false; }
function asBool(v){ if (typeof v==="boolean") return v; if (typeof v==="number") return !!v; if (typeof v==="string") return !/^(0|false)$/i.test(v.trim()); return false; }

async function buildIfPkg(){
  const proto = [];
  const wdata = [];
  const flags = new Map();  // key -> [bits]
  const nums  = new Map();  // key -> [ints]
  const enums = new Map();  // key -> Set<string>

  function setArr(map, key, val){
    key = snakeLower(key);
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(val);
  }
  function addEnum(key, val){
    key = snakeLower(key);
    if (!enums.has(key)) enums.set(key, new Set());
    if (enums.get(key).size < opts.maxEnum*2) enums.get(key).add(String(val).trim());
  }

  let container = [];
  let kstack = [];
  let pendingKey = null;

  let inIface = false;
  let ifacePath = "";
  let capturingParams = false;
  let curValues = new Map();
  let curParams = new Map();

  // derived flags we want to always expose
  let seenCheckTypeAny = false;
  const checkTypeVals = [];

  await new Promise((resolve, reject)=>{
    const pipeline = chain([ fs.createReadStream(opts.jsonPath), parser() ]);
    pipeline.on('data', ({name,value})=>{
      switch(name){
        case 'startObject': container.push('object'); if (pendingKey !== null) { kstack.push(sanitizeIdent(pendingKey)); pendingKey = null; } break;
        case 'endObject': {
          if (inIface && kstack.join('.') === ifacePath) {
            const pNorm = normalizeProto(curValues.get('fnNativeInterface'));
            proto.push(`PROTO_${pNorm}`);
            const wd = Number(curValues.get('wData') ?? curParams.get('wData'));
            wdata.push(Number.isFinite(wd) ? String(wd) : "128");

            for (const [k,v] of curValues){
              if (k==='fnNativeInterface'||k==='wData') continue;
              if (/^(has|enable)/i.test(k) && isBoolLike(v)) setArr(flags, k, asBool(v) ? "1":"0");
              else if (typeof v === 'number') setArr(nums, k, String(v));
              else if (typeof v === 'string') { addEnum(k, v); if (k==='check_type') { checkTypeVals.push(v); seenCheckTypeAny=true; } }
            }
            for (const [k,v] of curParams){
              if (k==='wData') { /* consumed */ }
              if (/^(has|enable)/i.test(k) && isBoolLike(v)) setArr(flags, k, asBool(v) ? "1":"0");
              else if (typeof v === 'number') setArr(nums, k, String(v));
              else if (typeof v === 'string') { addEnum(k, v); if (k==='check_type') { checkTypeVals.push(v); seenCheckTypeAny=true; } }
            }

            inIface=false; ifacePath=""; capturingParams=false; curValues=new Map(); curParams=new Map();
          }
          container.pop(); kstack.pop(); break;
        }
        case 'startArray': container.push('array'); if (pendingKey !== null) { kstack.push(sanitizeIdent(pendingKey)); pendingKey = null; } break;
        case 'endArray'  : container.pop(); kstack.pop(); break;
        case 'keyValue'  : pendingKey = String(value);
                           if (pendingKey === 'fnNativeInterface') { inIface = true; ifacePath = kstack.join('.'); }
                           else if (inIface && pendingKey === 'params') { capturingParams = true; }
                           break;
        case 'stringValue':
        case 'numberValue':
        case 'trueValue':
        case 'falseValue':
        case 'nullValue': {
          const v = (name==='stringValue') ? value
                : (name==='numberValue') ? Number(value)
                : (name==='trueValue') ? true
                : (name==='falseValue') ? false
                : null;
          if (pendingKey !== null) {
            const k = pendingKey;
            if (inIface) {
              if (capturingParams && k!=='params') curParams.set(k, v);
              else curValues.set(k, v);
            }
            if (k==='params') capturingParams = false;
            pendingKey = null;
          }
          break;
        }
      }
    });
    pipeline.on('end', resolve);
    pipeline.on('error', reject);
  });

  // derive has_parity from check_type if present
  if (seenCheckTypeAny) {
    const arr = [];
    for (let i=0;i<proto.length;i++){
      const v = (checkTypeVals[i]||"").toString().toUpperCase();
      const has = /PARITY/.test(v) || v === "ODD_PARITY_BYTE_ALL";
      arr.push(has ? "1":"0");
    }
    flags.set("has_parity", arr);
  }

  // Ensure well-known flags exist (default 0) so wrapper compiles in all configs
  const wantFlags = ["has_sysco_interface","has_parity"];
  for (const k of wantFlags){
    if (!flags.has(k)) flags.set(k, Array(proto.length).fill("0"));
  }

  // emit package
  const out = nodePath.join(opts.outDir, "if_cfg_pkg.sv");
  const ws = fs.createWriteStream(out, {encoding:"utf8"});
  const W = s => ws.write(s+"\n");

  W(`// Auto-generated: protocol/feature arrays (lowercase identifiers, enum values in caps)`);
  W(`package ${sanitizeIdent(opts.ifPkg)};`);
  W(`  typedef enum int { PROTO_UNKNOWN=0, PROTO_AXI4, PROTO_AXI5, PROTO_ACE4, PROTO_ACE5, PROTO_ACE_LITE_E, PROTO_CHI_B, PROTO_CHI_E } proto_e;`);
  W(`  function string proto_e_to_string(proto_e p);`);
  W(`    case (p)`);
  W(`      PROTO_AXI4: return "AXI4";`);
  W(`      PROTO_AXI5: return "AXI5";`);
  W(`      PROTO_ACE4: return "ACE4";`);
  W(`      PROTO_ACE5: return "ACE5";`);
  W(`      PROTO_ACE_LITE_E: return "ACE-LITE-E";`);
  W(`      PROTO_CHI_B: return "CHI-B";`);
  W(`      PROTO_CHI_E: return "CHI-E";`);
  W(`      default: return "UNKNOWN";`);
  W(`    endcase`);
  W(`  endfunction`);
  const enumInfos = [];
  for (const [k,S] of [...enums.entries()]){
    if (S.size===0 || S.size>opts.maxEnum) continue;
    const en = `${k}_e`;
    W(`  typedef enum int { __NONE__, ${[...S].map(v=>sanitizeIdent(String(v).toUpperCase(),"VAL")).join(", ")} } ${en};`);
    W(`  function string ${en}_to_string(${en} x);`);
    W(`    case (x)`);
    W(`      __NONE__: return "NONE";`);
    for (const v of S) W(`      ${sanitizeIdent(String(v).toUpperCase(),"VAL")}: return "${String(v)}";`);
    W(`      default: return "NONE";`);
    W(`    endcase`);
    W(`  endfunction`);
    enumInfos.push(en);
  }
  W(`  parameter int n_if = ${proto.length};`);
  W(`  localparam proto_e axi_proto [n_if] = '{ ${proto.join(", ")} };`);
  W(`  localparam int wdata [n_if] = '{ ${wdata.join(", ")} };`);
  for (const [k,arr] of [...flags.entries()].sort((a,b)=>a[0].localeCompare(b[0]))) W(`  localparam bit ${k} [n_if] = '{ ${arr.join(", ")} };`);
  for (const [k,arr] of [...nums.entries()].sort((a,b)=>a[0].localeCompare(b[0]))) { if (k!=='w_data') W(`  localparam int ${k} [n_if] = '{ ${arr.join(", ")} };`); }
  for (const [k,S] of [...enums.entries()]) {
    if (S.size===0 || S.size>opts.maxEnum) continue;
    const en = `${k}_e`;
    const arr = Array(proto.length).fill("__NONE__");
    W(`  localparam ${en} ${k} [n_if] = '{ ${arr.join(", ")} };`);
  }
  W(`endpackage : ${sanitizeIdent(opts.ifPkg)}`);
  await new Promise(res=>ws.end(res));

  return { count: proto.length, enums: enumInfos, out, flags: [...flags.keys()] };
}

/* ---------------- Binds from ariaObj.PortList ---------------- */
async function buildBinds(){
  const pairs = [];
  let container = [];
  let kstack = [];
  let pendingKey = null;
  let capture = null;
  let inPortList = false;

  await new Promise((resolve, reject)=>{
    const pipeline = chain([ fs.createReadStream(opts.jsonPath), parser() ]);
    pipeline.on('data', ({name,value})=>{
      switch(name){
        case 'startObject': container.push('object'); if (pendingKey !== null) { kstack.push(sanitizeIdent(pendingKey)); pendingKey = null; } if (inPortList) capture = {}; break;
        case 'endObject':  if (capture && capture.rtlSignal && capture.dvSignal) pairs.push({rtl:String(capture.rtlSignal), dv:String(capture.dvSignal)}); capture=null; container.pop(); kstack.pop(); break;
        case 'startArray': container.push('array'); if (pendingKey !== null) { if (pendingKey === 'PortList' && kstack.slice(-1)[0] === 'ariaObj') inPortList = true; kstack.push(sanitizeIdent(pendingKey)); pendingKey=null; } break;
        case 'endArray':   if (inPortList && kstack.slice(-1)[0] === 'PortList' && kstack.slice(-2)[0] === 'ariaObj') inPortList = false; container.pop(); kstack.pop(); break;
        case 'keyValue':   pendingKey = String(value); break;
        case 'stringValue':
        case 'numberValue':
        case 'trueValue':
        case 'falseValue':
        case 'nullValue': {
          const v = (name==='stringValue') ? value
                : (name==='numberValue') ? Number(value)
                : (name==='trueValue') ? true
                : (name==='falseValue') ? false
                : null;
          if (pendingKey !== null) {
            if (capture) {
              if (pendingKey === 'rtlSignal') capture.rtlSignal = v;
              else if (pendingKey === 'dvSignal') capture.dvSignal = v;
            }
            pendingKey = null;
          }
          break;
        }
      }
    });
    pipeline.on('end', resolve);
    pipeline.on('error', reject);
  });

  const out = nodePath.join(opts.outDir, "port_binds_auto.sv");
  const ws = fs.createWriteStream(out, {encoding:"utf8"});
  const W = s => ws.write(s+"\n");
  W(`// Auto-generated: RTL←DV binds from ariaObj.PortList (time-0 log)`);
  W(`module dv_port_binds;`);
  W(`  initial begin`);
  W(`    $display("[port_binds] %0t: applying %0d bindings", $time, ${pairs.length});`);
  for (const {rtl,dv} of pairs) W(`    $display("[port_binds]   %s <- %s", "${rtl}", "${dv}");`);
  W(`  end`);
  for (const {rtl,dv} of pairs) {
    const esc = s => (/^[A-Za-z_][A-Za-z0-9_$]*$/.test(s) ? s : ("\\"+String(s).replace(/\s/g,"_")+" "));
    W(`  assign ${esc(rtl)} = ${esc(dv)};`);
  }
  W(`endmodule`);
  W(`bind ${sanitizeIdent(opts.top)} dv_port_binds dv_port_binds_i();`);
  await new Promise(res=>ws.end(res));

  return {count:pairs.length, out};
}

/* ---------------- tb report ---------------- */
async function buildReport(enumNames){
  const out = nodePath.join(opts.outDir, "tb_report_auto.sv");
  const ws = fs.createWriteStream(out, {encoding:"utf8"});
  const W = s => ws.write(s+"\n");
  const P = sanitizeIdent(opts.ifPkg);
  W(`// Auto-generated: tb report of interface table`);
  W(`module dv_cfg_report; import ${P}::*; initial begin`);
  W(`  $display("--------------------------------------------------------------------------------");`);
  W(`  $display("  idx | protocol   | wdata");`);
  W(`  $display("--------------------------------------------------------------------------------");`);
  W(`  for (int i=0;i<n_if;i++) $display("  %0d  | %s | %0d", i, proto_e_to_string(axi_proto[i]), wdata[i]);`);
  if (enumNames && enumNames.length){
    W(`  $display("---- string knobs ----");`);
    for (const en of enumNames) W(`  for (int i=0;i<n_if;i++) $display("  ${en}[%0d]=%s", i, ${en}_to_string(${en}[i]));`);
  }
  W(`  $display("--------------------------------------------------------------------------------");`);
  W(`end endmodule`);
  await new Promise(res=>ws.end(res));
}

/* ---------------- dut_select_auto.sv (wrapper) ----------------
 * Strategy:
 *  - Expose a *small superset* of TB-side signals.
 *  - Instantiate DUT via explicit named connections that are valid per protocol/flag.
 *  - Branch by protocol (ACE/AXI/CHI) and common feature flags (has_sysco_interface, has_parity).
 *  - Ports you don’t need simply don’t appear in the chosen branch → no compile error.
 *  - DUT/port names are macro-overridable to match your RTL.
 */
async function buildWrapper(){
  const out = nodePath.join(opts.outDir, "dut_select_auto.sv");
  const ws = fs.createWriteStream(out, {encoding:"utf8"});
  const W = s => ws.write(s+"\n");
  const P = sanitizeIdent(opts.ifPkg);

  W(`// Auto-generated: Protocol/feature-aware DUT wrapper.`);
  W(`// Customize DUT/module port names via the macros below if needed.`);
  W(`\`ifndef DUT_MODULE`);
  W(`  \`define DUT_MODULE Gen_wrapper`);
  W(`\`endif`);
  W(`\`ifndef DUT_PORT_CLK`);
  W(`  \`define DUT_PORT_CLK clk`);
  W(`\`endif`);
  W(`\`ifndef DUT_PORT_RST_N`);
  W(`  \`define DUT_PORT_RST_N rst_n`);
  W(`\`endif`);
  W(`\`ifndef DUT_PORT_AR_VALID`);
  W(`  \`define DUT_PORT_AR_VALID ar_valid`);
  W(`\`endif`);
  W(`\`ifndef DUT_PORT_AC_VALID`);
  W(`  \`define DUT_PORT_AC_VALID ac_valid`);
  W(`\`endif`);
  W(`\`ifndef DUT_PORT_SYSCO_P`);
  W(`  \`define DUT_PORT_SYSCO_P sysco_p`);
  W(`\`endif`);
  W(`\`ifndef DUT_PORT_PARITY`);
  W(`  \`define DUT_PORT_PARITY parity_bit`);
  W(`\`endif\n`);

  W(`module dut_select_auto #(int unsigned IDX = 0) (`);
  W(`  // TB-side superset of signals; add more as you standardize`);
  W(`  input  logic clk,`);
  W(`  input  logic rst_n,`);
  W(`  input  logic ar_valid,      // AXI/ACE`);
  W(`  input  logic ac_valid,      // ACE-only`);
  W(`  input  logic sysco_p,       // optional feature`);
  W(`  input  logic parity_bit     // optional feature`);
  W(`);`);
  W(`  import ${P}::*;`);
  W(`  initial $display("[%m] IDX=%0d proto=%s wdata=%0d", IDX, proto_e_to_string(axi_proto[IDX]), wdata[IDX]);`);

  W(`  generate`);
  W(`    if (axi_proto[IDX] inside {PROTO_ACE4, PROTO_ACE5}) begin : G_ACE`);
  W(`      if (has_sysco_interface[IDX] && has_parity[IDX]) begin : G_SYSCO_PAR`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_AC_VALID(ac_valid),`);
  W(`          .\`DUT_PORT_SYSCO_P(sysco_p),`);
  W(`          .\`DUT_PORT_PARITY (parity_bit)`);
  W(`        );`);
  W(`      end else if (has_sysco_interface[IDX]) begin : G_SYSCO`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_AC_VALID(ac_valid),`);
  W(`          .\`DUT_PORT_SYSCO_P(sysco_p)`);
  W(`        );`);
  W(`      end else if (has_parity[IDX]) begin : G_PAR`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_AC_VALID(ac_valid),`);
  W(`          .\`DUT_PORT_PARITY (parity_bit)`);
  W(`        );`);
  W(`      end else begin : G_BASE`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_AC_VALID(ac_valid)`);
  W(`        );`);
  W(`      end`);
  W(`    end else if (axi_proto[IDX] inside {PROTO_AXI4, PROTO_AXI5}) begin : G_AXI`);
  W(`      if (has_sysco_interface[IDX] && has_parity[IDX]) begin : G_SYSCO_PAR`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_SYSCO_P(sysco_p),`);
  W(`          .\`DUT_PORT_PARITY (parity_bit)`);
  W(`        );`);
  W(`      end else if (has_sysco_interface[IDX]) begin : G_SYSCO`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_SYSCO_P(sysco_p)`);
  W(`        );`);
  W(`      end else if (has_parity[IDX]) begin : G_PAR`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid),`);
  W(`          .\`DUT_PORT_PARITY (parity_bit)`);
  W(`        );`);
  W(`      end else begin : G_BASE`);
  W(`        \`DUT_MODULE dut (`);
  W(`          .\`DUT_PORT_CLK    (clk),`);
  W(`          .\`DUT_PORT_RST_N  (rst_n),`);
  W(`          .\`DUT_PORT_AR_VALID(ar_valid)`);
  W(`        );`);
  W(`      end`);
  W(`    end else if (axi_proto[IDX] inside {PROTO_CHI_B, PROTO_CHI_E}) begin : G_CHI`);
  W(`      \`DUT_MODULE dut (`);
  W(`        .\`DUT_PORT_CLK    (clk),`);
  W(`        .\`DUT_PORT_RST_N  (rst_n)`);
  W(`      );`);
  W(`    end else begin : G_UNKNOWN`);
  W(`      initial $warning("[%m] Unknown protocol at IDX=%0d (%0d) — minimal DUT", IDX, axi_proto[IDX]);`);
  W(`      \`DUT_MODULE dut (`);
  W(`        .\`DUT_PORT_CLK   (clk),`);
  W(`        .\`DUT_PORT_RST_N (rst_n)`);
  W(`      );`);
  W(`    end`);
  W(`  endgenerate`);
  W(`endmodule`);
  await new Promise(res=>ws.end(res));

  return { out };
}

/* ---------------- Main ---------------- */
(async () => {
  await pass1();
  buildClassesFromSchema();

  const dvPath     = nodePath.join(opts.outDir, "dv_cfg_pkg.sv");
  const ifPath     = nodePath.join(opts.outDir, "if_cfg_pkg.sv");
  const bindsPath  = nodePath.join(opts.outDir, "port_binds_auto.sv");
  const reportPath = nodePath.join(opts.outDir, "tb_report_auto.sv");
  const wrapPath   = nodePath.join(opts.outDir, "dut_select_auto.sv");

  // DV PKG
  let dvSize = 0;
  if (!opts.skipDv){
    const ws = fs.createWriteStream(dvPath, {encoding:"utf8"});
    emitDvHeader(ws);
    await emitDvAssignments(ws);
    await new Promise(res=>ws.end(res));
    dvSize = fs.statSync(dvPath).size;
  }

  // IF PKG
  let ifInfo = {count:0, enums:[], out: ifPath, flags:[]};
  let ifSize = 0;
  if (!opts.skipIf){
    ifInfo = await buildIfPkg();
    ifSize = fs.statSync(ifPath).size;
  }

  // BINDS
  let bindsInfo = {count:0, out: bindsPath};
  if (opts.emitBinds) bindsInfo = await buildBinds();

  // REPORT
  if (opts.emitReport && !opts.skipIf) await buildReport(ifInfo.enums);

  // WRAPPER
  let wrapInfo = {out: wrapPath};
  if (opts.emitWrapper && !opts.skipIf) wrapInfo = await buildWrapper();

  // STATS
  const t1 = process.hrtime.bigint();
  const elapsedMs = Number(t1 - t0)/1e6;
  const mem = process.memoryUsage();
  console.log("=== json2sv: STATS ===");
  console.log(`Input JSON : ${opts.jsonPath}`);
  try { const st = fs.statSync(opts.jsonPath); console.log(`  Bytes    : ${st.size} (~${(st.size/1024).toFixed(1)} KB)`); } catch {}
  console.log(`Classes    : ${reg.order.length}`);
  console.log(`Interfaces : ${ifInfo.count} (via fnNativeInterface)`);
  if (!opts.skipDv)  console.log(`  ${dvPath} (${dvSize} bytes)`);
  if (!opts.skipIf)  console.log(`  ${ifPath} (${ifSize} bytes)`);
  if (opts.emitBinds) console.log(`  ${bindsPath} (pairs=${bindsInfo.count})`);
  if (opts.emitReport && !opts.skipIf) console.log(`  ${reportPath}`);
  if (opts.emitWrapper && !opts.skipIf) console.log(`  ${wrapPath}`);
  console.log(`Build time : ${elapsedMs.toFixed(2)} ms`);
  console.log(`Node RSS   : ${(mem.rss/1024/1024).toFixed(1)} MB`);
})().catch(e => { console.error("FATAL:", e); process.exit(1); });
