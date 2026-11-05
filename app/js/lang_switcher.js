/* 三語系切換核心 (zh-tw / en / ja)
 * 用法：載入後，頁面可使用 TabiLang.get() / TabiLang.set(lang) / TabiLang.t(key) / TabiLang.onChange(fn)
 * 語言來源優先序：網址 ?lang= > localStorage.current_lang > 瀏覽器語言 > zh-tw
 */
(function () {
  var SUPPORTED = ["zh-tw", "en", "ja"];
  var listeners = [];

  var DICT = {
    "zh-tw": {
      siteName: "日本報報", articlesTitle: "深度文章庫", articlesSub: "專為台灣旅客整理的日本深度特刊",
      filterAll: "全部文章", empty: "此語言目前尚無文章，敬請期待。", read: "閱讀全文", min: "分鐘閱讀", book: "預訂優惠",
      allLevels: "全部難度", footer: "© 2026 日本報報 ｜ 本站含 Trip.com 聯盟連結，訂購可能為本站帶來分潤，不影響您的價格。",
      langLabel: "語言", home: "返回首頁",
      cat: { ski: "⛷️ 滑雪", flower: "🌸 賞花", themepark: "🎡 遊樂園", food: "🍜 美食", transit: "🚆 交通" }
    },
    "en": {
      siteName: "Japan Tabi Report", articlesTitle: "Deep-Dive Articles", articlesSub: "In-depth Japan travel features written for international travelers",
      filterAll: "All Articles", empty: "No articles in this language yet. Coming soon.", read: "Read more", min: "min read", book: "Book now",
      allLevels: "All Levels", footer: "© 2026 Japan Tabi Report | This site contains Trip.com affiliate links. We may earn a commission at no extra cost to you.",
      langLabel: "Language", home: "Back to Home",
      cat: { ski: "⛷️ Ski", flower: "🌸 Blossoms", themepark: "🎡 Theme Parks", food: "🍜 Food", transit: "🚆 Transit" }
    },
    "ja": {
      siteName: "日本報報", articlesTitle: "ディープ記事ライブラリ", articlesSub: "日本の旅をもっと深く楽しむための特集記事",
      filterAll: "すべての記事", empty: "この言語の記事はまだありません。近日公開予定です。", read: "続きを読む", min: "分で読める", book: "予約はこちら",
      allLevels: "すべての難易度", footer: "© 2026 日本報報 ｜ 当サイトには Trip.com のアフィリエイトリンクが含まれます。ご予約により当サイトに報酬が発生する場合がありますが、価格には影響しません。",
      langLabel: "言語", home: "ホームへ戻る",
      cat: { ski: "⛷️ スキー", flower: "🌸 花見", themepark: "🎡 テーマパーク", food: "🍜 グルメ", transit: "🚆 交通" }
    }
  };

  function normalize(l) {
    l = String(l || "").toLowerCase();
    if (l === "zh" || l === "zh-tw" || l === "zh-hant" || l.indexOf("zh-") === 0) return "zh-tw";
    if (l === "en" || l.indexOf("en-") === 0) return "en";
    if (l === "ja" || l.indexOf("ja-") === 0) return "ja";
    return null;
  }
  function detect() {
    var q = normalize(new URLSearchParams(location.search).get("lang"));
    if (q) return q;
    try { var s = normalize(localStorage.getItem("current_lang")); if (s) return s; } catch (e) {}
    var b = normalize(navigator.language);
    return b || "zh-tw";
  }

  var current = detect();

  function apply(lang, push) {
    current = lang;
    try { localStorage.setItem("current_lang", lang); } catch (e) {}
    var u = new URL(location.href);
    u.searchParams.set("lang", lang);
    history.replaceState(null, "", u.toString());
    document.documentElement.lang = lang === "zh-tw" ? "zh-Hant" : lang;
    listeners.forEach(function (fn) { fn(lang); });
  }

  window.TabiLang = {
    SUPPORTED: SUPPORTED,
    get: function () { return current; },
    set: function (l) { l = normalize(l); if (l) apply(l); },
    t: function (key) { return (DICT[current] && DICT[current][key]) || key; },
    cat: function (c) { return (DICT[current].cat && DICT[current].cat[c]) || c; },
    onChange: function (fn) { listeners.push(fn); },
    init: function () { apply(current); }
  };
})();
