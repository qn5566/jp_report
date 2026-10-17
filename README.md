# 日本四季玩樂地圖 App（東京・大阪 MVP）

這是一個獨立運作的日本旅遊 Web App / PWA，專為台灣自由行旅客設計，整合：
1. **🌸 最新花季進度**（櫻花、紅葉、銀杏見頃百分比進度條）
2. **🎆 煙火大會倒數**（施放發數、時間、雨天備案與周邊景觀飯店）
3. **🎪 附近祭典與活動**（聖誕市集、冬季燈飾、神社祭典）
4. **🎟️ Klook 全景點門票一鍵導購**（已自動綁定您的聯盟夥伴 ID `AID: 123436`）
5. **🏨 附近高評價飯店比價導購**（自動帶入景點座標與地標關鍵字，散場免擠電車）

---

## 一、 如何立即打開預覽 App？

不需要安裝任何伺服器，也不用先買網址！
直接在 Finder 雙擊打開以下檔案即可在瀏覽器體驗完整互動地圖與導購抽屜：

- **App 主程式入口**：`japan-go-app/app/index.html`

---

## 二、 還沒買新網址，如何免費上線給大家用？

在您決定好品牌名稱與購買專屬網域之前，可以使用以下免費服務 **3 分鐘一鍵上線**（皆會送您一個免費的 `.vercel.app` 或 `.pages.dev` 網址，且 `AID=123436` 分潤完全正常計算）：

1. **Cloudflare Pages / Vercel / Netlify（推薦）**：
   - 將 `japan-go-app` 資料夾上傳，並將發佈目錄指向 `japan-go-app/`，首頁入口為 `app/index.html`。
   - 之後買了新網域（例如 `japango.tw`），只要在後台點「Custom Domain」綁定即可，程式碼完全不用改。

---

## 三、 聯盟行銷參數設定 (`AID: 123436`)

所有導購規則統一集中在：
- `config/affiliate.json`
- `app/js/affiliate.js`

每個 Klook 按鈕與飯店訂房按鈕都會自動加上：
`?aid=123436&utm_medium=affiliate-alwayson&utm_source=non-network&utm_campaign=123436&aff_label1=<景點ID>`
方便您在聯盟後台清楚看到是哪一個花季或煙火景點帶來最多訂單！
