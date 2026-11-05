/* 日本語ディープ記事ライブラリ (ja)
 * 新しい日本語記事は下の配列にオブジェクトを追加するだけで、他言語には影響しません。
 * フィールド: id, lang, title, category(ski|flower|themepark|food|transit), excerpt, cover, readTime(分), date, link
 */
window.articlesDatabase = (window.articlesDatabase || []).concat([
  {
    id: "ja-ski-01",
    lang: "ja",
    title: "ニセコ＆キロロ徹底比較！極上のパウダースノーと温泉宿の歩き方",
    category: "ski",
    excerpt: "今シーズン狙うべき名湯とリフト混雑を避けるルート完全マップ...",
    cover: "https://images.unsplash.com/photo-1551524559-8af4e6624178?auto=format&fit=crop&w=800&q=75",
    readTime: 9,
    date: "2026-11-05",
    link: "articles/ja/niseko-kiroro-guide.html"
  },
  {
    id: "ja-park-01",
    lang: "ja",
    title: "東京ディズニーランド完全攻略：ベビーカー・トイレ・待ち時間対策",
    category: "themepark",
    excerpt: "合流利用券から無料アプリ活用ルートまで、家族連れの裏ワザをまとめました...",
    cover: "https://images.unsplash.com/photo-1542640244-7e672d6cef4e?auto=format&fit=crop&w=800&q=75",
    readTime: 11,
    date: "2026-11-05",
    link: "articles/ja/tokyo-disneyland-guide.html"
  }
]);
