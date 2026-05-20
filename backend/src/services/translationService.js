// MyMemory free translation API — API key shart emas, 1000 req/kun
// Node.js 18+ built-in fetch ishlatiladi (bizda Node 22)

const SUPPORTED   = new Set(['en', 'uz', 'tr', 'ru']);
const MAX_CHUNK   = 450; // MyMemory free limit (chars)
const CACHE_LIMIT = 2000;
const TIMEOUT_MS  = 5000;

// In-memory cache: key = "srcLang:targetLang\x00text"
const _cache = new Map();

// ─── Manba tilni harflar asosida taxminiy aniqlash ─────────────────────────
// Ushbu ilova o'zbek ijodkorlariga bag'ishlangan, shuning uchun
// lotin matnning aksariyati o'zbek tilidadir (default: 'uz').
function _detectSourceLang(text) {
  // Kirill alifbosi → rus yoki o'zbek-kirill
  if (/[Ѐ-ӿ]/.test(text)) return 'ru';
  // Turk tiliga xos harflar: ğ ş ı İ Ğ Ş
  if (/[ğşıİĞŞ]/.test(text)) return 'tr';
  // Qolgan lotin matnlar — o'zbek deb farazlanadi
  return 'uz';
}

// ─── Asosiy tarjima funksiyasi ──────────────────────────────────────────────
async function _translateChunk(text, targetLang) {
  const srcLang = _detectSourceLang(text);

  // Bir xil til — tarjima shart emas
  if (srcLang === targetLang) return text;

  const key = `${srcLang}:${targetLang}\x00${text}`;
  if (_cache.has(key)) return _cache.get(key);

  const url =
    `https://api.mymemory.translated.net/get` +
    `?q=${encodeURIComponent(text)}&langpair=${srcLang}|${targetLang}`;

  const res = await fetch(url, {
    signal: AbortSignal.timeout(TIMEOUT_MS),
    headers: { 'User-Agent': 'anthology-app/1.0' },
  });

  if (!res.ok) return text;

  const data   = await res.json();
  const result = data.responseData?.translatedText || text;

  // INVALID SOURCE xabarini original bilan almashtir
  if (result.includes('INVALID SOURCE') || result.includes('INVALID LANGUAGE')) {
    return text;
  }

  // Cache to'lib ketsa eski 10 %ini tozala
  if (_cache.size >= CACHE_LIMIT) {
    [..._cache.keys()].slice(0, CACHE_LIMIT / 10).forEach(k => _cache.delete(k));
  }
  _cache.set(key, result);
  return result;
}

/**
 * Bitta matn satrini tarjima qiladi.
 * Uzun matnlarni paragraflar bo'yicha bo'ladi.
 */
async function translateText(text, targetLang) {
  if (!text || !targetLang || !SUPPORTED.has(targetLang)) return text ?? '';

  const str = String(text).trim();
  if (!str) return text;

  try {
    if (str.length <= MAX_CHUNK) {
      return await _translateChunk(str, targetLang);
    }

    // Uzun matn: ikki qatr bo'shliq bilan bo'lish (paragraflar)
    const chunks     = str.split(/\n\n+/);
    const translated = await Promise.all(
      chunks.map(c =>
        c.length <= MAX_CHUNK
          ? _translateChunk(c.trim(), targetLang)
          : Promise.resolve(c),
      ),
    );
    return translated.join('\n\n');
  } catch (err) {
    console.error('[translate] error:', err.message);
    return text; // asl matn qaytariladi
  }
}

/**
 * Ob'ektning berilgan fieldlarini tarjima qiladi.
 */
async function translateFields(row, fields, targetLang) {
  if (!row || !targetLang || !SUPPORTED.has(targetLang)) return row;

  const result = { ...row };
  await Promise.all(
    fields
      .filter(f => result[f] && typeof result[f] === 'string')
      .map(async f => {
        result[f] = await translateText(result[f], targetLang);
      }),
  );
  return result;
}

/**
 * Accept-Language headeridan asosiy til kodini ajratib oladi.
 * Masalan: "uz-UZ,uz;q=0.9,en;q=0.8" → "uz"
 */
function parseLang(acceptLanguageHeader) {
  if (!acceptLanguageHeader) return null;
  const primary = acceptLanguageHeader
    .split(',')[0]
    .trim()
    .split(';')[0]
    .trim()
    .split('-')[0]
    .toLowerCase();
  return SUPPORTED.has(primary) ? primary : null;
}

module.exports = { translateText, translateFields, parseLang };
