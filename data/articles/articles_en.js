/* English deep-dive article library (en)
 * To publish new English articles, just add objects to the array below.
 * Fields: id, lang, title, category(ski|flower|themepark|food|transit), excerpt, cover, readTime(min), date, link
 */
window.articlesDatabase = (window.articlesDatabase || []).concat([
  {
    id: "en-ski-01",
    lang: "en",
    title: "Niseko Powder & Backcountry: Avalanche Safety & Best Après-Ski Bars",
    category: "ski",
    excerpt: "A complete deep-dive into JAPOW tree runs, gate access rules, and vibrant nightlife...",
    cover: "https://images.unsplash.com/photo-1551524559-8af4e6624178?auto=format&fit=crop&w=800&q=75",
    readTime: 10,
    date: "2026-11-05",
    link: "articles/en/niseko-backcountry-apres-ski.html"
  },
  {
    id: "en-park-01",
    lang: "en",
    title: "Tokyo Disneyland Survival Guide: Strollers, Restrooms & Fast Passes",
    category: "themepark",
    excerpt: "Rider switch, single-rider tricks and the free-app route that saves hours in line...",
    cover: "https://images.unsplash.com/photo-1542640244-7e672d6cef4e?auto=format&fit=crop&w=800&q=75",
    readTime: 11,
    date: "2026-11-05",
    link: "articles/en/tokyo-disneyland-survival-guide.html"
  }
]);

