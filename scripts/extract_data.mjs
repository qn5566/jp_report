// 將 HTML 內嵌的資料常數抽離成 JSON 檔。
// 用法: node scripts/extract_data.mjs <page.html> <VAR_NAME> [output.json]
// 自動偵測同檔內簡單常數 (字串/數字/布林/純 JSON 物件) 當作求值上下文，
// 以解決資料結構引用其他常數 (例如分潤網址) 的情況。
import fs from 'node:fs';
import vm from 'node:vm';

const [, , page, varName, outFile] = process.argv;
if (!page || !varName) {
  console.error('usage: node scripts/extract_data.mjs <page.html> <VAR_NAME> [output.json]');
  process.exit(1);
}

const src = fs.readFileSync(page, 'utf8');

// 平衡掃描 literal（從 open 開始到配對 close）
function scanLiteral(src, startIdx) {
  const open = src[startIdx];
  if (open !== '[' && open !== '{') return null;
  const close = open === '[' ? ']' : '}';
  let depth = 0, inStr = null, i = startIdx;
  while (i < src.length) {
    const c = src[i];
    if (inStr) {
      if (c === '\\') { i += 2; continue; }
      if (c === inStr) inStr = null;
      i++; continue;
    }
    if (c === '"' || c === "'" || c === '`') { inStr = c; i++; continue; }
    if (c === open) depth++;
    else if (c === close) { depth--; if (depth === 0) break; }
    i++;
  }
  return src.slice(startIdx, i + 1);
}

// 收集同檔內所有簡單常數作為上下文
const declRe = /\b(?:const|let|var)\s+([A-Za-z_$][A-Za-z0-9_$]*)\s*=\s*/g;
const context = {};
let dm;
while ((dm = declRe.exec(src))) {
  const name = dm[1];
  const s = dm.index + dm[0].length;
  const ch = src[s];
  if (ch !== '[' && ch !== '{' && ch !== '"' && ch !== "'" && ch !== '`') {
    // 數字/布林/null 等原始型別
    const m2 = /^[-+]?\d+(\.\d+)?|^true\b|^false\b|^null\b/.exec(src.slice(s));
    if (!m2) continue;
    const tok = m2[0];
    try { context[name] = vm.runInNewContext(tok, {}); } catch { continue; }
    continue;
  }
  if (ch === '"' || ch === "'" || ch === '`') {
    // 簡單字串
    let inStr = ch, i = s + 1;
    while (i < src.length) {
      const c = src[i];
      if (c === '\\') { i += 2; continue; }
      if (c === inStr) break;
      i++;
    }
    const strLit = src.slice(s, i + 1);
    try { context[name] = vm.runInNewContext('(' + strLit + ')', {}); } catch { continue; }
    continue;
  }
  // 陣列/物件
  const lit = scanLiteral(src, s);
  if (!lit) continue;
  try { context[name] = JSON.parse(lit); } catch { /* 非純 JSON，跳過 */ }
}

// 補充掃描：任意位置的 NAME = "字串"（含逗號分隔的 var 宣告、純指派）
const strAssignRe = /\b([A-Za-z_$][A-Za-z0-9_$]*)\s*=\s*(["'][^"'\\n]*["'])/g;
let sm;
while ((sm = strAssignRe.exec(src))) {
  const name = sm[1];
  if (name in context) continue;
  try { context[name] = vm.runInNewContext('(' + sm[2] + ')', {}); } catch { continue; }
}

// 找目標變數
const re = new RegExp(`\\b(?:const|let|var)\\s+${varName}\\s*=\\s*`, 'g');
const m = re.exec(src);
if (!m) { console.error(`not found: ${varName} in ${page}`); process.exit(2); }

const startIdx = m.index + m[0].length;
const literal = scanLiteral(src, startIdx);
if (!literal) { console.error(`literal starts with '${src[startIdx]}', not array/object`); process.exit(3); }

let value;
try {
  value = JSON.parse(literal);
} catch (e) {
  try {
    value = vm.runInNewContext('(' + literal + ')', context, { timeout: 5000 });
  } catch (e2) {
    console.error(`cannot evaluate ${varName}: ${e2.message}`);
    process.exit(4);
  }
}

const json = JSON.stringify(value, null, 2);
const out = outFile || `data/${varName.toLowerCase()}.json`;
fs.mkdirSync(new URL('.', 'file://' + process.cwd() + '/').pathname, { recursive: true });
fs.writeFileSync(out, json + '\n');

const items = Array.isArray(value) ? value.length : Object.keys(value).length;
console.log(`OK: ${varName} -> ${out} (${(json.length/1024).toFixed(1)} KB, ${Array.isArray(value)?'items':'keys'}=${items})`);
