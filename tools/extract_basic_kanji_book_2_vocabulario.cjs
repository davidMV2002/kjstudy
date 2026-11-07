/* Extrae únicamente las palabras, lecturas y glosas inglesas impresas en BKB 2. */

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const sourcePath = path.join(root, 'tmp', 'bkb2-ocr', 'raw-text.json');
const outputPath = path.join(root, 'tmp', 'bkb2-ocr', 'vocabulario-del-libro.json');
const pageRanges = [
  [7, 10], [18, 21], [27, 30], [41, 44], [52, 55], [61, 64],
  [70, 73], [79, 81], [90, 94], [99, 103], [111, 113], [119, 121],
  [129, 131], [138, 141], [150, 153], [160, 162], [170, 172],
  [178, 181], [191, 193], [200, 203], [211, 213], [221, 223], [233, 235],
];
const japaneseCharacters = '一-龯々ぁ-ゖァ-ヺー';
const selectedPages = new Set(
  pageRanges.flatMap(([first, last]) =>
    Array.from({ length: last - first + 1 }, (_, index) =>
      `page-${String(first + index).padStart(3, '0')}.jpg`),
  ),
);

function normalizeJapaneseSpacing(text) {
  let result = text;
  for (let index = 0; index < 5; index += 1) {
    result = result.replace(
      new RegExp(`(?<=[${japaneseCharacters}])\\s+(?=[${japaneseCharacters}])`, 'g'),
      '',
    );
  }
  return result.replace(new RegExp(`(?<=[${japaneseCharacters}])\\s+(?=\\()`, 'g'), '');
}

function cleanReading(value) {
  return value.replace(/[\s・()]/g, '').replace(/^まっ?$/, 'ま').trim();
}

function cleanEnglish(value) {
  return value.replace(/\s+/g, ' ').replace(/^a ?fee/i, 'a fee').trim();
}

function extractEntries(pages) {
  const pattern = new RegExp(
    `([${japaneseCharacters}]+)\\s*\\(\\s*((?:[^()]|\\([^()]*\\))*)\\s*\\)\\s*` +
      `([ぁ-ゖァ-ヺー]*)([A-Za-z0-9,.'’"“” -]+?)\\s*` +
      `(?=(?:[${japaneseCharacters}]+)\\s*\\(|[\\r\\n]|$)`,
    'g',
  );
  const entries = [];
  const seen = new Set();

  for (const [page, originalText] of Object.entries(pages)) {
    if (!selectedPages.has(page)) continue;
    const text = normalizeJapaneseSpacing(originalText);
    for (const match of text.matchAll(pattern)) {
      const palabra = `${match[1]}${match[3]}`;
      const lectura = cleanReading(`${match[2]}${match[3]}`);
      const meaningEn = cleanEnglish(match[4]);
      if (
        !/[一-龯々]/.test(palabra) ||
        !/^[ぁ-ゖァ-ヺー]+$/.test(lectura) ||
        !/[A-Za-z]/.test(meaningEn) ||
        meaningEn.length > 50
      ) continue;

      const key = `${palabra}\0${lectura}`;
      if (!seen.has(key)) {
        seen.add(key);
        entries.push({ palabra, lectura, meaning_en: meaningEn, pagina: page });
      }
    }
  }
  return entries;
}

const pages = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
const entries = extractEntries(pages);
fs.writeFileSync(outputPath, JSON.stringify(entries, null, 2), 'utf8');
console.log(`Extraídas ${entries.length} entradas del libro en ${outputPath}.`);
