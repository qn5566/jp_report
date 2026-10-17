/**
 * 日本旅遊報報 - 四季變色龍 × 滑雪分級避雷 × WNI花季 × 高分潤導購主控制器
 */
(function () {
  const FAV_KEY = "japan_baobao_favs_v2";

  function loadFavs() {
    try {
      const r = localStorage.getItem(FAV_KEY);
      if (r) return JSON.parse(r);
    } catch (e) {}
    return ["ski-gala-yuzawa", "sakura-tokyo-meguro"];
  }

  function saveFavs(list) {
    try {
      localStorage.setItem(FAV_KEY, JSON.stringify(list));
    } catch (e) {}
  }

  const state = {
    season: "ski",       // 'ski' | 'sakura' | 'ginkgo' | 'maple' | 'fireworks' | 'all'
    region: "all",       // 'all' | 'tokyo' | 'osaka' | 'hokkaido' | 'nagano'
    skiFilter: "all",    // 'all' | 'beginner' | 'expert' | 'shopping'
    bloomFilter: "all",  // 'all' | 'full' | 'blooming' | 'bud'
    viewMode: "web",
    focusedId: "ski-gala-yuzawa",
    favorites: loadFavs(),
    locations: window.JAPAN_GO_LOCATIONS || []
  };

  let mapInstance = null;
  let mapMarkers = {};

  const REGION_COORDS = {
    all: { lat: 37.2, lng: 138.2, zoom: 5 },
    tokyo: { lat: 36.2, lng: 139.2, zoom: 8 },
    osaka: { lat: 34.9, lng: 135.6, zoom: 9 },
    hokkaido: { lat: 42.6, lng: 140.8, zoom: 7 },
    nagano: { lat: 36.7, lng: 137.9, zoom: 9 }
  };

  function init() {
    bindTopControls();
    initMap();
    applySeasonTheme();
    renderDynamicSubFilter();
    updateFavCount();
    renderAll();
  }

  function updateFavCount() {
    const el = document.getElementById("jp-fav-count");
    if (el) el.textContent = String(state.favorites.length);
  }

  function toggleFavorite(id) {
    const idx = state.favorites.indexOf(id);
    if (idx >= 0) state.favorites.splice(idx, 1);
    else state.favorites.push(id);
    saveFavs(state.favorites);
    updateFavCount();
    renderAll();
  }

  // 切換四季視覺配色與飄落特效 (春櫻粉 / 銀杏土黃 / 秋楓紅 / 冬雪冰晶藍)
  function applySeasonTheme() {
    document.body.classList.remove("theme-sakura", "theme-ginkgo", "theme-maple", "theme-ski");
    let cls = "theme-ski";
    let symbol = "❄️";
    if (state.season === "sakura" || state.season === "fireworks") {
      cls = "theme-sakura";
      symbol = state.season === "sakura" ? "🌸" : "🎆";
    } else if (state.season === "ginkgo") {
      cls = "theme-ginkgo";
      symbol = "🌼";
    } else if (state.season === "maple") {
      cls = "theme-maple";
      symbol = "🍁";
    }
    document.body.classList.add(cls);

    const rain = document.getElementById("jp-particles-rain");
    if (rain) {
      const lefts = [6, 22, 42, 64, 86];
      rain.innerHTML = lefts
        .map(
          (l, i) =>
            `<div class="jp-falling-particle" style="left:${l}%; animation-duration:${9 + i * 1.5}s; animation-delay:${i * 0.8}s;">${symbol}</div>`
        )
        .join("");
    }
  }

  // 渲染第 4 層動態痛點篩選器 (滑雪玩家分級避雷 vs WNI 花開時間點)
  function renderDynamicSubFilter() {
    const box = document.getElementById("jp-dynamic-subfilter");
    if (!box) return;

    if (state.season === "ski" || state.season === "all") {
      const items = [
        { id: "all", label: "⛷️ 全部雪場" },
        { id: "beginner", label: "🌱 新手入門 (綠線≥50%・平緩寬雪道・有自動魔毯)" },
        { id: "expert", label: "🌲 老手狂歡 (二世谷/白馬・頂級JAPOW粉雪與野雪道)" },
        { id: "shopping", label: "🛍️ 出街逛街方便 (兼顧Outlet購物・溫泉街夜生活)" }
      ];
      box.innerHTML = `
        <div style="display:flex; align-items:center; gap:6px; overflow-x:auto;">
          <span style="font-size:12px; font-weight:900; color:#0369a1; white-space:nowrap;">🛡️ 滑雪分級避雷：</span>
          ${items
            .map(
              (b) => `
            <button data-ski-filter="${b.id}" class="jp-pill-btn ${state.skiFilter === b.id ? "active" : ""}" style="padding:4px 10px;">
              ${b.label}
            </button>
          `
            )
            .join("")}
        </div>
        <span style="font-size:11px; font-weight:800; color:#059669;">✓ 數據與日本 SURF&SNOW 官網即時同步</span>
      `;
      box.querySelectorAll("[data-ski-filter]").forEach((btn) => {
        btn.addEventListener("click", () => {
          state.skiFilter = btn.getAttribute("data-ski-filter");
          renderDynamicSubFilter();
          renderAll();
        });
      });
    } else {
      const blooms = [
        { id: "all", label: "全部花開時間點" },
        { id: "full", label: "🌸 滿開見頃 (90~100% 最佳觀賞)" },
        { id: "blooming", label: "🌷 正在開 (5~7分開)" },
        { id: "bud", label: "🌱 準備要開 (含苞預報地區)" }
      ];
      box.innerHTML = `
        <div style="display:flex; align-items:center; gap:6px; overflow-x:auto;">
          <span style="font-size:12px; font-weight:900; color:var(--theme-badge-text); white-space:nowrap;">📅 WNI 花開時間點：</span>
          ${blooms
            .map(
              (b) => `
            <button data-bloom-filter="${b.id}" class="jp-pill-btn ${state.bloomFilter === b.id ? "active" : ""}" style="padding:4px 10px;">
              ${b.label}
            </button>
          `
            )
            .join("")}
        </div>
        <span style="font-size:11px; font-weight:800; color:var(--theme-badge-text);">✓ 串聯 Weathernews (WNI) & tenki.jp</span>
      `;
      box.querySelectorAll("[data-bloom-filter]").forEach((btn) => {
        btn.addEventListener("click", () => {
          state.bloomFilter = btn.getAttribute("data-bloom-filter");
          renderDynamicSubFilter();
          renderAll();
        });
      });
    }
  }

  function bindTopControls() {
    document.querySelectorAll("[data-view-mode]").forEach((btn) => {
      btn.addEventListener("click", () => {
        state.viewMode = btn.getAttribute("data-view-mode");
        document.querySelectorAll("[data-view-mode]").forEach((b) =>
          b.classList.toggle("active", b.getAttribute("data-view-mode") === state.viewMode)
        );
        const stage = document.getElementById("jp-app-stage");
        if (stage) stage.classList.toggle("webview-frame", state.viewMode === "app");
        if (mapInstance) setTimeout(() => mapInstance.invalidateSize(), 260);
      });
    });

    document.querySelectorAll("[data-season]").forEach((btn) => {
      btn.addEventListener("click", () => {
        state.season = btn.getAttribute("data-season");
        state.skiFilter = "all";
        state.bloomFilter = "all";
        document.querySelectorAll("[data-season]").forEach((b) =>
          b.classList.toggle("active", b.getAttribute("data-season") === state.season)
        );
        applySeasonTheme();
        renderDynamicSubFilter();
        renderAll();
      });
    });

    document.querySelectorAll("[data-region]").forEach((btn) => {
      btn.addEventListener("click", () => {
        state.region = btn.getAttribute("data-region");
        document.querySelectorAll("[data-region]").forEach((b) =>
          b.classList.toggle("active", b.getAttribute("data-region") === state.region)
        );
        if (mapInstance) {
          const cfg = REGION_COORDS[state.region] || REGION_COORDS.all;
          mapInstance.flyTo([cfg.lat, cfg.lng], cfg.zoom, { duration: 0.7 });
        }
        renderAll();
      });
    });

    const favBtn = document.getElementById("jp-open-favorites");
    if (favBtn) favBtn.addEventListener("click", openFavoritesDrawer);

    const backdrop = document.getElementById("jp-drawer-backdrop");
    if (backdrop) {
      backdrop.addEventListener("click", (e) => {
        if (e.target === backdrop) backdrop.classList.remove("open");
      });
    }
  }

  function getFilteredItems() {
    return state.locations.filter((item) => {
      if (state.season !== "all" && item.season !== state.season) return false;
      if (state.region !== "all" && item.city !== state.region) return false;
      if (item.season === "ski" && state.skiFilter !== "all") {
        if (!item.ski_tags || !item.ski_tags.includes(state.skiFilter)) return false;
      }
      if (
        (item.season === "sakura" || item.season === "ginkgo" || item.season === "maple") &&
        state.bloomFilter !== "all"
      ) {
        if (item.bloom_state !== state.bloomFilter) return false;
      }
      return true;
    });
  }

  function initMap() {
    const el = document.getElementById("jp-leaflet-map");
    if (!el || typeof L === "undefined") return;
    mapInstance = L.map("jp-leaflet-map").setView([37.2, 138.2], 5);
    L.tileLayer("https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png", {
      attribution: "&copy; OpenStreetMap &copy; CARTO",
      maxZoom: 18
    }).addTo(mapInstance);
  }

  function focusOnMap(id) {
    const item = state.locations.find((x) => x.id === id);
    if (!item) return;
    state.focusedId = item.id;
    if (mapInstance) {
      mapInstance.flyTo([item.lat, item.lng], 12, { duration: 0.65 });
      if (mapMarkers[item.id]) mapMarkers[item.id].openPopup();
    }
    renderMapFocusedBox(item);
  }

  function renderMapFocusedBox(item) {
    const box = document.getElementById("jp-map-focused-info");
    if (!box || !item) return;
    const hotelUrl = window.AffiliateBuilder.buildHotelAffiliateUrl({
      query: item.hotel_area_keyword || item.name_zh,
      platform: "klook"
    });
    box.innerHTML = `
      <div style="font-size:11px; font-weight:800; color:var(--theme-badge-text);">📍 App內建地圖目前定位：${item.region_label}</div>
      <div style="font-size:14px; font-weight:900; margin:2px 0;">${item.name_zh}</div>
      <div style="font-size:11.5px; color:#475569;">🗓️ ${item.season_period}</div>
      <div style="font-size:11.5px; color:#475569;">🚇 ${item.station_zh}</div>
      <div style="margin-top:8px; padding-top:8px; border-top:1px dashed var(--theme-border); display:flex; justify-content:space-between; align-items:center; font-size:11.5px; font-weight:800;">
        <span>🏨 ${item.hotel_name || "周邊高評價飯店"}</span>
        <a href="${hotelUrl}" target="_blank" rel="noopener" style="color:var(--theme-primary);">查房價 ➔</a>
      </div>
    `;
  }

  function renderMapMarkers(items) {
    if (!mapInstance || typeof L === "undefined") return;
    Object.values(mapMarkers).forEach((m) => mapInstance.removeLayer(m));
    mapMarkers = {};

    const icons = { ski: "⛷️", sakura: "🌸", ginkgo: "🌼", maple: "🍁", fireworks: "🎆" };
    items.forEach((item) => {
      const emoji = icons[item.season] || "🗾";
      const icon = L.divIcon({
        className: "jp-custom-div-icon",
        html: `<div class="jp-map-pin">${emoji}</div>`,
        iconSize: [36, 36],
        iconAnchor: [18, 18]
      });
      const marker = L.marker([item.lat, item.lng], { icon })
        .bindPopup(`<strong>${emoji} ${item.name_zh}</strong><br/><span style="font-size:11px;">${item.status_badge}</span>`)
        .addTo(mapInstance);
      marker.on("click", () => focusOnMap(item.id));
      mapMarkers[item.id] = marker;
    });

    const focused = items.find((x) => x.id === state.focusedId) || items[0];
    if (focused) renderMapFocusedBox(focused);
  }

  function renderCards(items) {
    const grid = document.getElementById("jp-cards-grid");
    if (!grid) return;

    if (items.length === 0) {
      grid.innerHTML = `<div style="grid-column:1/-1; text-align:center; padding:36px; background:#fff; border-radius:20px;">此地區目前無符合條件項目，請點選「全國日本」查看全部名所。</div>`;
      return;
    }

    grid.innerHTML = items
      .map((item) => {
        const isFav = state.favorites.includes(item.id);
        const hotelLink = window.AffiliateBuilder.buildHotelAffiliateUrl({
          query: item.hotel_area_keyword || item.name_zh,
          platform: "klook"
        });

        // A. 滑雪場卡片 (置頂高對比綠色漸層「預約中文教練」＋ SURF&SNOW 同步欄位 ＋ 找教練/雪場房間/雪場溫泉三按鈕)
        if (item.season === "ski") {
          const coachLink = window.AffiliateBuilder.buildKlookUrl(item.coach_url, item.id + "-coach");
          const onsenLink = window.AffiliateBuilder.buildKlookUrl(item.onsen_url, item.id + "-onsen");
          const lv = item.levels || { green: 50, red: 30, black: 20 };

          return `
            <article class="jp-card" data-card-id="${item.id}">
              <div>
                <a class="jp-coach-banner-btn" href="${coachLink}" target="_blank" rel="noopener" onclick="event.stopPropagation();">
                  <span>${item.coach_btn_text || "⛷️ 預約中文教練・享專屬折扣"}</span>
                  <span style="background:rgba(255,255,255,0.22); padding:2px 8px; border-radius:99px; font-size:11px;">${item.coach_price || "高分潤"} ➔</span>
                </a>

                <div style="display:flex; justify-content:space-between; align-items:center; gap:6px; margin-bottom:6px; flex-wrap:wrap;">
                  <span style="font-size:11px; font-weight:800; padding:2px 8px; border-radius:8px; background:#e0f2fe; color:#0369a1;">${item.region_label}</span>
                  <div style="display:flex; align-items:center; gap:4px;">
                    ${(item.ski_tag_labels || []).slice(0, 2).map((t) => `<span style="font-size:11px; font-weight:800; padding:2px 7px; border-radius:8px; background:#ecfdf5; color:#047857; border:1px solid #a7f3d0;">${t}</span>`).join("")}
                    <button data-fav-id="${item.id}" style="border:1px solid #cbd5e1; background:#f8fafc; width:26px; height:26px; border-radius:50%; cursor:pointer;">${isFav ? "❤️" : "🤍"}</button>
                  </div>
                </div>

                <h3 style="font-size:15.5px; font-weight:900;">${item.name_zh}</h3>
                <div style="font-size:11.5px; color:#64748b; margin-bottom:6px;">${item.name_ja}</div>

                <div class="jp-ski-sync-grid">
                  <div class="jp-ski-sync-cell">
                    <div style="font-size:10.5px; color:#64748b; font-weight:700;">積雪深度</div>
                    <div style="font-size:12px; font-weight:900; color:#0369a1;">${item.snowDepth}</div>
                  </div>
                  <div class="jp-ski-sync-cell">
                    <div style="font-size:10.5px; color:#64748b; font-weight:700;">目前雪質</div>
                    <div style="font-size:12px; font-weight:900; color:#4338ca;">${item.snowQuality}</div>
                  </div>
                  <div class="jp-ski-sync-cell">
                    <div style="font-size:10.5px; color:#64748b; font-weight:700;">開放纜車</div>
                    <div style="font-size:12px; font-weight:900; color:#047857;">${(item.lifts || "").split(" ")[0]}</div>
                  </div>
                </div>

                <div style="margin-bottom:8px;">
                  <div style="display:flex; justify-content:space-between; font-size:11px; font-weight:800; margin-bottom:3px;">
                    <span style="color:#059669;">🟢 綠線新手 ${lv.green}%</span>
                    <span style="color:#e11d48;">🔴 紅線中級 ${lv.red}%</span>
                    <span style="color:#1e293b;">⚫ 黑線老手 ${lv.black}%</span>
                  </div>
                  <div style="height:7px; border-radius:99px; overflow:hidden; display:flex; background:#e2e8f0;">
                    <div style="width:${lv.green}%; background:#10b981;"></div>
                    <div style="width:${lv.red}%; background:#f43f5e;"></div>
                    <div style="width:${lv.black}%; background:#1e293b;"></div>
                  </div>
                </div>

                <p style="font-size:12.5px; color:#334155; margin-bottom:10px;">${item.summary_zh}</p>
              </div>

              <div>
                <div style="font-size:11.5px; color:#475569; background:#f8fafc; padding:8px; border-radius:11px; border:1px solid #e2e8f0; margin-bottom:8px;">
                  <div>🗓️ <strong>開放時間：</strong>${item.season_period}</div>
                  <div>🚄 <strong>交通：</strong>${item.station_zh}</div>
                  <div style="color:#0369a1; font-weight:800;">🏨 雪場住宿：${item.hotel_name}</div>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:6px;" onclick="event.stopPropagation();">
                  <a class="jp-btn" href="${coachLink}" target="_blank" rel="noopener" style="background:#059669; color:#fff;">⛷️ 找教練</a>
                  <a class="jp-btn" href="${hotelLink}" target="_blank" rel="noopener" style="background:#0284c7; color:#fff;">🏨 雪場房間</a>
                  <a class="jp-btn" href="${onsenLink}" target="_blank" rel="noopener" style="background:#d97706; color:#fff;">♨️ 雪場溫泉</a>
                </div>
              </div>
            </article>
          `;
        }

        // B. 花季 (春櫻/銀杏/秋楓) 與煙火卡片：配備「賞花訂房」＋「包車/一日遊行程」＋「App內看地圖」
        const charterLink = window.AffiliateBuilder.buildKlookUrl(item.charter_url, item.id + "-charter");
        const pct = item.progress_pct || 95;

        return `
          <article class="jp-card" data-card-id="${item.id}">
            <div>
              <a class="jp-charter-banner-btn" href="${charterLink}" target="_blank" rel="noopener" onclick="event.stopPropagation();">
                <span>${item.charter_btn_text || "🚐 預訂賞花私人包車 / 一日遊行程"}</span>
                <span style="background:rgba(255,255,255,0.22); padding:2px 8px; border-radius:99px; font-size:11px;">高分潤 ➔</span>
              </a>

              <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                <span style="font-size:11px; font-weight:800; padding:2px 8px; border-radius:8px; background:var(--theme-card-soft); color:var(--theme-badge-text);">${item.region_label}</span>
                <div style="display:flex; align-items:center; gap:6px;">
                  <span style="font-size:11px; font-weight:800; padding:2px 8px; border-radius:8px; background:var(--theme-card-soft); color:var(--theme-badge-text);">${item.status_badge}</span>
                  <button data-fav-id="${item.id}" style="border:1px solid #cbd5e1; background:#f8fafc; width:26px; height:26px; border-radius:50%; cursor:pointer;">${isFav ? "❤️" : "🤍"}</button>
                </div>
              </div>

              <h3 style="font-size:15.5px; font-weight:900;">${item.name_zh}</h3>
              <div style="font-size:11.5px; color:#64748b; margin-bottom:6px;">${item.name_ja}</div>

              <div style="background:var(--theme-bg); border:1px solid var(--theme-border); border-radius:11px; padding:7px 10px; margin-bottom:8px;">
                <div style="display:flex; justify-content:space-between; font-size:11px; font-weight:800; color:var(--theme-badge-text); margin-bottom:4px;">
                  <span>🌸 WNI 花況觀測進度</span>
                  <span>${pct}%</span>
                </div>
                <div style="height:7px; border-radius:99px; background:#e2e8f0; overflow:hidden;">
                  <div style="width:${pct}%; height:100%; background:var(--theme-primary);"></div>
                </div>
              </div>

              <p style="font-size:12.5px; color:#334155; margin-bottom:10px;">${item.summary_zh}</p>
            </div>

            <div>
              <div style="font-size:11.5px; color:#475569; background:#f8fafc; padding:8px; border-radius:11px; border:1px solid #e2e8f0; margin-bottom:8px;">
                <div>🗓️ <strong>花開時間點：</strong>${item.season_period}</div>
                <div>🚇 <strong>交通：</strong>${item.station_zh}</div>
                <div style="color:var(--theme-badge-text); font-weight:800;">🏨 推薦住宿：${item.hotel_name}</div>
              </div>

              <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:6px;" onclick="event.stopPropagation();">
                <a class="jp-btn" href="${hotelLink}" target="_blank" rel="noopener" style="background:#e11d48; color:#fff;">🏨 賞花訂房</a>
                <a class="jp-btn" href="${charterLink}" target="_blank" rel="noopener" style="background:#ff5b00; color:#fff;">🚐 行程/包車</a>
                <button class="jp-btn" data-map-id="${item.id}" style="background:#f1f5f9; color:#1e293b; border:1px solid #cbd5e1;">🗺️ 地圖看</button>
              </div>
            </div>
          </article>
        `;
      })
      .join("");

    grid.querySelectorAll("[data-card-id]").forEach((card) => {
      card.addEventListener("click", () => focusOnMap(card.getAttribute("data-card-id")));
    });

    grid.querySelectorAll("[data-map-id]").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        focusOnMap(btn.getAttribute("data-map-id"));
      });
    });

    grid.querySelectorAll("[data-fav-id]").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        toggleFavorite(btn.getAttribute("data-fav-id"));
      });
    });
  }

  function openFavoritesDrawer() {
    const backdrop = document.getElementById("jp-drawer-backdrop");
    const body = document.getElementById("jp-drawer-body");
    if (!backdrop || !body) return;
    const favItems = state.locations.filter((x) => state.favorites.includes(x.id));

    body.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; padding-bottom:12px; border-bottom:1px solid #e2e8f0; margin-bottom:12px;">
        <div>
          <h3 style="font-size:17px; font-weight:900;">❤️ 我的日本旅遊報報・愛心筆記 (${favItems.length})</h3>
          <div style="font-size:12px; color:#64748b;">收藏的滑雪場中文教練、花季名所、煙火與周邊飯店</div>
        </div>
        <button id="jp-close-drawer" style="border:none; background:#f1f5f9; width:32px; height:32px; border-radius:50%; cursor:pointer;">✕</button>
      </div>
      ${
        favItems.length === 0
          ? `<div style="padding:24px; text-align:center; color:#64748b;">尚未收藏任何項目，點擊卡片右上角的 🤍 即可加入！</div>`
          : favItems
              .map((item) => {
                const hotelUrl = window.AffiliateBuilder.buildHotelAffiliateUrl({
                  query: item.hotel_area_keyword || item.name_zh,
                  platform: "klook"
                });
                return `
                  <div style="padding:12px; border-radius:14px; border:1px solid #e2e8f0; margin-bottom:8px; display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap;">
                    <div>
                      <div style="font-size:11px; font-weight:800; color:var(--theme-badge-text);">${item.region_label}</div>
                      <div style="font-size:14px; font-weight:900;">${item.name_zh}</div>
                      <div style="font-size:11.5px; color:#64748b;">🗓️ ${item.season_period}</div>
                    </div>
                    <div style="display:flex; gap:6px;">
                      <a class="jp-btn" href="${hotelUrl}" target="_blank" rel="noopener" style="background:#e11d48; color:#fff;">🏨 訂飯店</a>
                      <button data-rm-fav="${item.id}" class="jp-btn" style="background:#f1f5f9;">移除</button>
                    </div>
                  </div>
                `;
              })
              .join("")
      }
    `;

    document.getElementById("jp-close-drawer")?.addEventListener("click", () => backdrop.classList.remove("open"));
    body.querySelectorAll("[data-rm-fav]").forEach((btn) => {
      btn.addEventListener("click", () => {
        toggleFavorite(btn.getAttribute("data-rm-fav"));
        openFavoritesDrawer();
      });
    });
    backdrop.classList.add("open");
  }

  function renderAll() {
    const items = getFilteredItems();
    renderCards(items);
    renderMapMarkers(items);
  }

  document.addEventListener("DOMContentLoaded", init);
})();
