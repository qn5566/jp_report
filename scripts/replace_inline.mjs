// 將 HTML 內嵌資料常數整段替換為空佔位符。
// 用法: node scripts/replace_inline.mjs <page.html> <VAR_NAME> <EMPTY_LITERAL> [KIND]
//   EMPTY_LITERAL 例如 {} 或 []
//   KIND = const|let|var (預設 let)
import fs from 'node:fs';

const [, , page, varName, emptyLit, kind] = process.argv;
if (!page || !varName || !emptyLit) {
  console.error('usage: node scripts/replace_inline.mjs <page> <VAR> <{}|[]> [let|const|var]');
  process.exit(1);
}
const kw = kind || 'let';
const src = fs.readFileSync(page, 'utf8');

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
  return i + 1; // end index (exclusive)
}

const re = new RegExp(`\\b(?:const|let|var)\\s+${varName}\\s*=\\s*`, 'g');
const m = re.exec(src);
if (!m) { console.error(`not found: ${varName}`); process.exit(2); }

const startIdx = m.index + m[0].length;
const endIdx = scanLiteral(src, startIdx);
if (endIdx == null) { console.error('not a literal'); process.exit(3); }

// 吃掉結尾分號
let end = endIdx;
while (end < src.length && /\s/.test(src[end])) end++;
if (src[end] === ';') end++;

const replacement = `${kw} ${varName} = ${emptyLit};`;
const out = src.slice(0, m.index) + replacement + src.slice(end);
fs.writeFileSync(page, out);
console.log(`OK: ${page} ${varName} -> ${replacement} (removed ${end - m.index} chars)`);
