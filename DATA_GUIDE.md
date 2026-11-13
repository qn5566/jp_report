# 網站資料維護指南

網站內容放在 JSON，頁面透過 `fetch()` 載入。部署目錄是 `app/`，所以網站實際讀取 `app/data/`。根目錄的 `data/` 供根目錄 HTML 預覽；修改資料時，兩個目錄中同名檔案要同步更新。

## 檔案對照

| 頁面 | JSON 檔案 | 資料結構與主要欄位 |
| --- | --- | --- |
| `index.html` | `spots.json` | 景點陣列；`id`、`theme`、`category`、`region`、`title`、`desc`、`img`、`klookUrl`、`bookingUrl` |
| `index.html` | `trains_database.json` | 首頁列車陣列；`id`、`name`、`route_category`、`section`、`image`、`ticket_url` |
| `index.html` | `community_feeds.json` | 旅人現場情報陣列；`id`、`season`、`user`、`spot`、`comment`、`img` |
| `index.html` | `hubs.json` | 首頁主分類物件；分類鍵對應 `title`、`themeMode`、`feedSeason`、`subItems` |
| `index.html` | `season_upload_config.json` | 各季節投稿表單設定；`modalTitle`、`spots`、`statuses`、`defaultComment` |
| `index.html` | `season_filters_config.json` | 各季節篩選選項；`regionLbl`、`regions`、`catLbl`、`categories` |
| `index.html` | `spot_geo_coords.json` | 景點座標陣列；`title`、`lat`、`lng` |
| `index.html` | `i18n.json` | 首頁語系物件；語言代碼如 `zh-TW`、`en`，每種語言含 `brandTitle`、`tab_spots`、`feedTitle` 等文字鍵 |
| `japan_train_tour.html` | `trains.json` | 列車頁陣列；`id`、`name`、`route_category`、`highlights`、`stations`、`itinerary`、`ticket_url` |
| `japan_charter_rental.html` | `charter.json` | 包車分類物件；分類鍵下有 `name` 與 `trips`，每筆行程含 `title`、`city`、`route`、`url` |
| `japan_inbound_rankings.html` | `rankings.json` | 排行分類物件；分類鍵下有 `title`、`icon`、`desc`、`items` |
| `japan_okinawa_drive.html` | `okinawa_spots.json`、`okinawa_itinerary.json` | 沖繩景點陣列（`id`、`tier1`、`subCat`、`name`、`mapUrl` 等）；行程物件（`family`、`senior`、`dive`、`shopping`） |
| `japan_ski_resorts.html` | `ski_resorts_list.json`、`resorts.json`、`snow_today.json` | 雪場清單陣列（`id`、`region`、`name`、`snow` 等）；以雪場 `id` 為鍵的票券與飯店詳情；每日雪況摘要 |
| `japan_theme_parks.html` | `theme_parks.json`、`theme_park_tickets.json` | 樂園陣列（`id`、`rank`、`name`、`region`、`img` 等）；以樂園 `id` 為鍵的門票網址 |
| `japan_flight_deals.html` | `airport_magazine_data.json`、`airport_details.json`、`airport_lounges.json`、`airport_transit_guides.json`、`airport_editorial_gallery.json`、`all_airports_gallery_db.json`、`routes_data.json` | 機場地區與機場列表、以機場代碼（如 `NRT`）為鍵的詳細資料，以及出發地航線清單 |
| `japan_special_edition.html` | `special_edition_articles.json`、`fuji_translations.json` | 以語言代碼（如 `zh-tw`、`en`）為鍵的專欄與富士主題文字 |
| `japan_special_edition_fuji.html` | `fuji_page_translations.json` | 富士專頁多語文字；`title`、`quote`、`histPre`、`histTitle`、`histP1`、`histP2` |

`trains.json` 與 `trains_database.json` 分別供列車頁與首頁使用，兩份目前各有 51 筆，但內容不完全相同；修改列車時請檢查兩頁是否都需要更新。`locations.json` 與 `seed_data.js` 屬於原有資料來源，不是上述頁面目前使用的 JSON。

## 編輯與預覽

1. 編輯 `data/` 內對應的 JSON，保持原有欄位名稱、`id` 與結構；新增資料時可複製同檔現有的一筆再修改。`theme_park_tickets.json` 的鍵要對應 `theme_parks.json` 的 `id`；`resorts.json` 的鍵要對應 `ski_resorts_list.json` 的 `id`。
2. 把修改過的 JSON 複製到 `app/data/` 的同名檔案。正式部署時上傳完整 `app/` 目錄，包含 `app/data/`。
3. 在專案根目錄執行 `python3 -m http.server 8000 --directory app`，開啟 `http://localhost:8000/` 預覽。直接用 `file://` 開啟時，瀏覽器通常會阻擋 JSON 載入。
4. 提交 GitHub 前可執行 `node -e 'JSON.parse(require("fs").readFileSync("app/data/spots.json", "utf8"))'` 檢查單一檔案格式，並確認兩份檔案一致。

若未來將資料改放其他 GitHub 儲存庫，頁面的 `fetch('data/檔名.json')` 路徑也需要一起調整，並確認遠端站點允許跨網域讀取。
