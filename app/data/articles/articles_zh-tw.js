/* 繁體中文深度文章庫 (zh-tw)
 * 之後「更新中文文章」只需要在下方陣列新增物件即可，不會影響英文／日文文章庫。
 * 欄位：id, lang, title, category(ski|flower|themepark|food|transit), excerpt, cover, readTime(分鐘), date, link
 */
window.articlesDatabase = (window.articlesDatabase || []).concat([
  {
    id: "tw-ski-01",
    lang: "zh-tw",
    title: "二世谷初學者避坑指南：中文教練預約與雪具租借全攻略",
    category: "ski",
    excerpt: "手把手教你如何避開排隊人潮，搞定雪道新手村與接駁巴士...",
    cover: "https://images.unsplash.com/photo-1551524559-8af4e6624178?auto=format&fit=crop&w=800&q=75",
    readTime: 8,
    date: "2026-11-05",
    link: "articles/zh-tw/niseko-beginner-guide.html"
  },
  {
    id: "tw-park-01",
    lang: "zh-tw",
    title: "東京迪士尼樂園極致避坑特刊：帶娃推車、如廁與快速通關",
    category: "themepark",
    excerpt: "從合流利用券到 APP 零課金排程，一次整理親子遊園的所有潛規則...",
    cover: "https://images.unsplash.com/photo-1542640244-7e672d6cef4e?auto=format&fit=crop&w=800&q=75",
    readTime: 12,
    date: "2026-11-05",
    link: "japan_theme_parks.html"
  }
]);
