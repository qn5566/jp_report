/**
 * 日旅報報 JAPAN TABI - 核心腳本庫 (Tabi Core JS)
 * 功能包含：
 * 1. 行程收藏本 (Favorites Drawer) 離線資料庫管理 (TABI_FAVORITES_V1)
 * 2. 景點卡片詳細情報折疊手風琴 (Accordion Expansion)
 * 3. 精緻小巧愛心按鈕 (Subtle 12px Retina Heart Icon)
 * 4. 全站統一步調浮動工具箱 (Floating Square Hub)
 * 5. 官方防盜版、著作權防護與轉載追蹤宣告
 */

(function () {
  'use strict';

  const STORAGE_KEY = 'TABI_FAVORITES_V1';
  const TRIP_SHORT_URL = 'https://www.trip.com/t/fgyJcXow1X2';
  const TRIP_AFFILIATE_QUERY = 'Allianceid=9507030&SID=325761227&trip_sub1=%E6%97%A5%E6%9C%AC%E5%A0%B1%E5%A0%B1&trip_sub3=D20905663&linkhub_token=sl_fgyJcXow1X2';
  const AFFILIATE_FLIGHT_HOTEL = `https://tw.trip.com/?Allianceid=9507030&SID=325761227&trip_sub1=%E6%97%A5%E6%9C%AC%E5%A0%B1%E5%A0%B1_%E4%BD%8F%E5%AE%BF&trip_sub3=D20905663&redirect_url=https%3A%2F%2Ftw.trip.com%2Fhotels%2Ftokyo-hotels-list-294%2F`;

  const TRIP_HOTEL_CITY_MAP = {
    'tokyo': 'tokyo-hotels-list-294',
    '東京': 'tokyo-hotels-list-294',
    'osaka': 'osaka-hotels-list-219',
    '大阪': 'osaka-hotels-list-219',
    'kyoto': 'kyoto-hotels-list-734',
    '京都': 'kyoto-hotels-list-734',
    'okinawa': 'okinawa-hotels-list-614',
    '沖繩': 'okinawa-hotels-list-614',
    '那霸': 'okinawa-hotels-list-614',
    'sapporo': 'sapporo-hotels-list-704',
    '札幌': 'sapporo-hotels-list-704',
    '北海道': 'sapporo-hotels-list-704',
    'fukuoka': 'fukuoka-hotels-list-267',
    '福岡': 'fukuoka-hotels-list-267',
    '九州': 'fukuoka-hotels-list-267',
    '博多': 'fukuoka-hotels-list-267'
  };

  function getTripHotelUrl(cityName) {
    const l = localStorage.getItem('tabi_selected_lang') || 'zh-TW';
    let c = (cityName || 'tokyo').toLowerCase();
    let cityPath = 'tokyo-hotels-list-294';
    for (const k in TRIP_HOTEL_CITY_MAP) {
      if (c.includes(k.toLowerCase())) {
        cityPath = TRIP_HOTEL_CITY_MAP[k];
        break;
      }
    }

    let domain = 'https://tw.trip.com';
    let sub1 = '%E6%97%A5%E6%9C%AC%E5%A0%B1%E5%A0%B1_%E4%BD%8F%E5%AE%BF';

    if (l === 'en') {
      domain = 'https://www.trip.com';
      sub1 = '%E6%97%A5%E6%9C%AC%E5%A0%B1%E5%A0%B1_EN_Hotel';
    } else if (l === 'ja') {
      domain = 'https://jp.trip.com';
      sub1 = '%E6%97%A5%E6%9C%AC%E5%A0%B1%E5%A0%B1_JP_Hotel';
    }

    const targetUrl = `${domain}/hotels/${cityPath}/`;
    return `${domain}/?Allianceid=9507030&SID=325761227&trip_sub1=${sub1}&trip_sub3=D20905663&redirect_url=${encodeURIComponent(targetUrl)}`;
  }

  // 1. 小巧精緻 SVG 愛心圖示產生器 (12px / 14px)
  function getHeartSvg(isActive, size = 12) {
    if (isActive) {
      return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="#E11D48" stroke="#E11D48" stroke-width="1.5"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path></svg>`;
    }
    return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="#64748B" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path></svg>`;
  }

  // 2. 本地儲存庫存取
  function getFavorites() {
    try {
      const data = localStorage.getItem(STORAGE_KEY);
      return data ? JSON.parse(data) : [];
    } catch (e) {
      console.warn('[TABI] Failed to read localStorage', e);
      return [];
    }
  }

  function saveFavorites(favs) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(favs));
    } catch (e) {
      console.warn('[TABI] Failed to save localStorage', e);
    }
    updateFavoriteBadge();
    updateAllHeartButtons();
    window.dispatchEvent(new CustomEvent('tabi:favorites-updated', { detail: favs }));
  }

  function isFavorite(id) {
    if (!id) return false;
    const favs = getFavorites();
    return favs.some(item => String(item.id) === String(id));
  }

  // 3. 加入 / 移除收藏核心方法
  window.toggleFavorite = function (id, type, title, img, region, tag, extra = {}) {
    if (!id || !title) return;
    id = String(id);
    let favs = getFavorites();
    const idx = favs.findIndex(item => String(item.id) === id);

    if (idx > -1) {
      favs.splice(idx, 1);
      showTabiToast(`已從行程收藏本移除：${title}`, '💔');
    } else {
      // 嘗試從全域資料庫比對補全情報
      let spot = null;
      if (typeof window.SPOTS_DATABASE !== 'undefined' && Array.isArray(window.SPOTS_DATABASE)) {
        spot = window.SPOTS_DATABASE.find(s => String(s.id) === id);
      }
      const allTrains = typeof window.TRAINS_DATA !== 'undefined' ? window.TRAINS_DATA : (typeof window.TRAINS_DATABASE !== 'undefined' ? window.TRAINS_DATABASE : null);
      if (!spot && allTrains && Array.isArray(allTrains)) {
        spot = allTrains.find(t => String(t.id) === id);
      }

      const desc = extra.desc || (spot ? (spot.desc || spot.subtitle || '') : '');
      const mapcode = extra.mapcode || (spot ? (spot.mapCode || spot.mapcode || '') : '');
      const location = extra.location || (spot ? (spot.locationDetail || spot.section || '') : '');
      const tips = extra.tips || (spot ? (spot.bloomStatus || spot.snowStatus || spot.badge || (spot.highlights ? spot.highlights.join('、') : '')) : '');
      const link = extra.link || (spot ? (spot.klookUrl || spot.ticket_url || spot.bookingUrl || '') : '');
      const navUrl = extra.navUrl || `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(title)}`;

      favs.unshift({
        id,
        type: type || 'spot',
        title,
        img: img || './images/japan_tabi_logo.png',
        region: region || (spot ? (spot.region || spot.route_category || '') : ''),
        tag: tag || (spot ? (spot.tag || spot.badge || '日本名所') : '日本名所'),
        desc,
        mapcode,
        location,
        tips,
        link,
        navUrl,
        addedAt: new Date().toISOString()
      });
      showTabiToast(`已加入行程收藏本：${title}`, '❤️');
    }

    saveFavorites(favs);
    if (typeof window.renderCards === 'function') {
      try { window.renderCards(); } catch (e) {}
    }
    renderFavoritesList();
  };

  // 3b. 由卡片 data-* 屬性讀取資料的安全收藏入口 (避免 inline 字串跳脫錯誤)
  window.tabiFavFromBtn = function (btn, ev) {
    if (ev) ev.stopPropagation();
    const d = (k) => { try { return decodeURIComponent(btn.getAttribute('data-' + k) || ''); } catch (e) { return ''; } };
    window.toggleFavorite(d('id'), btn.getAttribute('data-type'), d('title'), d('img'), d('region'), d('tag'), {
      desc: d('desc'), location: d('loc'), tips: d('tips'), link: d('link'), navUrl: d('nav') || undefined
    });
  };

  // 4. 更新收藏徽章計數
  window.updateFavoriteBadge = function () {
    const favs = getFavorites();
    const count = favs.length;
    document.querySelectorAll('.square-hub-badge, #favCountBadge').forEach(el => {
      el.textContent = count;
      el.style.display = count > 0 ? 'flex' : 'none';
    });
  };

  // 5. 更新所有畫面中的卡片愛心圖示狀態
  window.updateAllHeartButtons = function () {
    const favs = getFavorites();
    const favMap = new Set(favs.map(f => String(f.id)));

    // 支援通用屬性 data-fav-id
    document.querySelectorAll('.btn-card-fav[data-fav-id]').forEach(btn => {
      const id = btn.getAttribute('data-fav-id');
      const active = favMap.has(String(id));
      if (active) {
        btn.classList.add('active');
        btn.innerHTML = getHeartSvg(true, 12);
        btn.setAttribute('title', '已在行程收藏本');
      } else {
        btn.classList.remove('active');
        btn.innerHTML = getHeartSvg(false, 12);
        btn.setAttribute('title', '加入我的行程收藏');
      }
    });

    // 針對非 data-fav-id 的靜態按鈕
    document.querySelectorAll('[id^="trainFavBtn_"]').forEach(btn => {
      const id = btn.id.replace('trainFavBtn_', '');
      const active = favMap.has(String(id));
      if (active) {
        btn.classList.add('active');
        btn.innerHTML = getHeartSvg(true, 12) + ' 已在收藏本';
      } else {
        btn.classList.remove('active');
        btn.innerHTML = getHeartSvg(false, 12) + ' 加入行程收藏';
      }
    });
  };

  // 6. 展開/折疊手風琴卡片內容 (Accordion Detail)
  window.toggleFavExpand = function (id) {
    const panel = document.getElementById(`fav-detail-${id}`);
    const btn = document.getElementById(`fav-expand-btn-${id}`);
    if (!panel) return;
    const isHidden = panel.style.display === 'none' || panel.style.display === '';
    if (isHidden) {
      panel.style.display = 'block';
      if (btn) btn.innerHTML = '收起 ▲';
    } else {
      panel.style.display = 'none';
      if (btn) btn.innerHTML = '展開 ▼';
    }
  };

  // 7. 渲染收藏匣列表 (包含完整折疊卡片內容)
  window.renderFavoritesList = function () {
    const container = document.getElementById('favListContainer');
    if (!container) return;
    const favs = getFavorites();

    if (favs.length === 0) {
      container.innerHTML = `
        <div style="text-align:center; padding:60px 20px; color:#94A3B8;">
          <div style="font-size:36px; margin-bottom:12px;">🤍</div>
          <div style="font-size:0.95rem; font-weight:800; color:#334155;">您的行程收藏匣是空的</div>
          <div style="font-size:0.76rem; color:#94A3B8; margin-top:6px; line-height:1.65; max-width:280px; margin-left:auto; margin-right:auto;">
            瀏覽全站景點、沖繩自駕美食或特急列車時，點擊卡片右上角愛心即可隨時保存排程！
          </div>
        </div>
      `;
      return;
    }

    container.innerHTML = favs.map(item => {
      const safeTitle = (item.title || '').replace(/'/g, "\\'");
      const hotelSearchUrl = getTripHotelUrl(item.region || item.title);
      const navUrl = item.navUrl || `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(item.title)}`;

      return `
        <div class="fav-item-card" id="fav-card-${item.id}">
          <div class="fav-item-main" onclick="toggleFavExpand('${item.id}')">
            <img src="${item.img}" alt="${item.title}" class="fav-thumb" onerror="this.src='./images/japan_tabi_logo.png'">
            <div class="fav-item-info">
              <div class="fav-item-tag">${item.tag || '日旅情報'}</div>
              <div class="fav-item-title" title="${item.title}">${item.title}</div>
              <div class="fav-item-region">${item.region ? '📍 ' + item.region : '🗾 日本精選'}</div>
            </div>
            <div class="fav-item-actions">
              <button class="btn-fav-expand-toggle" id="fav-expand-btn-${item.id}" onclick="toggleFavExpand('${item.id}'); event.stopPropagation();" title="點擊展開/收起詳細攻略">
                展開 ▼
              </button>
              <button class="btn-fav-remove" onclick="toggleFavorite('${item.id}', '${item.type}', '${safeTitle}', '${item.img}'); event.stopPropagation();" title="從收藏匣移除">
                ✕
              </button>
            </div>
          </div>

          <!-- 折疊手風琴卡片內容 (可點擊展開查看完整資訊) -->
          <div class="fav-detail-panel" id="fav-detail-${item.id}" style="display:none;">
            ${item.desc ? `
              <div class="fav-detail-desc">
                <strong style="color:#0F172A; display:block; margin-bottom:3px;">📝 名所特色簡介：</strong>
                ${item.desc}
              </div>` : ''}

            ${(item.location || item.mapcode) ? `
              <div class="fav-detail-meta">
                ${item.location ? `<div>📍 <strong>交通指南：</strong>${item.location}</div>` : ''}
                ${item.mapcode ? `<div>🚗 <strong>MapCode 導航：</strong><code>${item.mapcode}</code></div>` : ''}
              </div>` : ''}

            ${item.tips ? `
              <div class="fav-detail-tip">
                💡 觀測秘笈：${item.tips}
              </div>` : ''}

            <div class="fav-detail-links">
              <a href="${navUrl}" target="_blank" rel="noopener noreferrer" class="fav-detail-btn fav-btn-nav">
                🗺️ Google 導航 ↗
              </a>
              <a href="${hotelSearchUrl}" target="_blank" rel="noopener noreferrer" class="fav-detail-btn fav-btn-hotel">
                🏨 周邊飯店比價 ↗
              </a>
              ${item.link ? `
              <a href="${item.link}" target="_blank" rel="noopener noreferrer" class="fav-detail-btn fav-btn-booking">
                🎟️ 預約 / 票券 ↗
              </a>` : ''}
            </div>
          </div>
        </div>
      `;
    }).join('');
  };

  // 8. 抽屜開關
  window.openFavoritesDrawer = function () {
    renderFavoritesList();
    const drawer = document.getElementById('favoritesDrawer');
    const backdrop = document.getElementById('favBackdrop');
    if (drawer) drawer.classList.add('show');
    if (backdrop) backdrop.classList.add('show');
    document.body.style.overflow = 'hidden';
  };

  window.closeFavoritesDrawer = function () {
    const drawer = document.getElementById('favoritesDrawer');
    const backdrop = document.getElementById('favBackdrop');
    if (drawer) drawer.classList.remove('show');
    if (backdrop) backdrop.classList.remove('show');
    document.body.style.overflow = '';
  };

  // 9. 一鍵複製所有行程清單
  window.copyAllFavorites = function () {
    const favs = getFavorites();
    if (favs.length === 0) {
      showTabiToast('收藏匣目前沒有景點可複製', 'ℹ️');
      return;
    }
    const lines = [
      `🇯🇵【日旅報報 JAPAN TABI】我的日旅行程口袋名單 (共 ${favs.length} 處)：\n`
    ];
    favs.forEach((item, i) => {
      lines.push(`${i + 1}. ${item.title} (${item.region || '日本'})`);
      if (item.mapcode) lines.push(`   🚗 MapCode: ${item.mapcode}`);
      if (item.location) lines.push(`   📍 交通: ${item.location}`);
      if (item.tips) lines.push(`   💡 備註: ${item.tips}`);
      lines.push('');
    });
    lines.push(`來源：《日旅報報 JAPAN TABI》官方特約觀測現地取材認證`);

    navigator.clipboard.writeText(lines.join('\n')).then(() => {
      showTabiToast(`成功複製 ${favs.length} 個景點攻略到剪貼簿！`, '📋');
    }).catch(() => {
      showTabiToast('複製失敗，請手動選取文字', '⚠️');
    });
  };

  // 10. 清空收藏匣
  window.clearAllFavorites = function () {
    const favs = getFavorites();
    if (favs.length === 0) return;
    if (confirm(`確定要清空所有收藏的 ${favs.length} 個日本行程景點嗎？`)) {
      saveFavorites([]);
      renderFavoritesList();
      showTabiToast('已清空所有行程收藏', '🗑️');
    }
  };

  // 11. 浮動 Toast 提示
  window.showTabiToast = function (msg, icon = '✦') {
    let container = document.getElementById('tabiToastContainer');
    if (!container) {
      container = document.createElement('div');
      container.id = 'tabiToastContainer';
      container.className = 'tabi-toast-container';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = 'tabi-toast';
    toast.innerHTML = `<span style="font-size:15px;">${icon}</span><span>${msg}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
      toast.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      setTimeout(() => toast.remove(), 300);
    }, 2800);
  };

  // 12. 全站通用：免稅日幣匯率試算計算機 (Global FX & Tax-Free Calculator)
  window.calculateFx = function () {
    const rateInput = document.getElementById('fxRateInput');
    const jpyInput = document.getElementById('fxJpyInput');
    if (!rateInput || !jpyInput) return;

    const rate = parseFloat(rateInput.value) || 0.215;
    const jpy = parseFloat(jpyInput.value) || 0;

    // 1. 一般含稅原價
    const normTwd = Math.round(jpy * rate);
    const normTwdEl = document.getElementById('fxNormTwd');
    const normJpyEl = document.getElementById('fxNormJpy');
    if (normTwdEl) normTwdEl.textContent = `NT$ ${normTwd.toLocaleString()}`;
    if (normJpyEl) normJpyEl.textContent = `含稅 ¥${Math.round(jpy).toLocaleString()}`;

    // 2. 10% 退稅價 (未稅金額 = 含稅 / 1.1)
    const taxFreeJpy = Math.round(jpy / 1.1);
    const taxFreeTwd = Math.round(taxFreeJpy * rate);
    const savedTwd = normTwd - taxFreeTwd;
    const tfTwdEl = document.getElementById('fxTaxFreeTwd');
    const tfJpyEl = document.getElementById('fxTaxFreeJpy');
    if (tfTwdEl) tfTwdEl.textContent = `NT$ ${taxFreeTwd.toLocaleString()}`;
    if (tfJpyEl) tfJpyEl.textContent = `未稅 ¥${taxFreeJpy.toLocaleString()} (現省 NT$ ${savedTwd.toLocaleString()})`;

    // 3. 免稅 + 百貨/唐吉 5% 優惠券折抵 (未稅 * 0.95)
    const couponJpy = Math.round(taxFreeJpy * 0.95);
    const couponTwd = Math.round(couponJpy * rate);
    const cpTwdEl = document.getElementById('fxCouponTwd');
    const cpJpyEl = document.getElementById('fxCouponJpy');
    if (cpTwdEl) cpTwdEl.textContent = `NT$ ${couponTwd.toLocaleString()}`;
    if (cpJpyEl) cpJpyEl.textContent = `實付 ¥${couponJpy.toLocaleString()} (現省 NT$ ${(normTwd - couponTwd).toLocaleString()})`;
  };

  window.setQuickJpy = function (val) {
    const input = document.getElementById('fxJpyInput');
    if (input) {
      input.value = val;
      window.calculateFx();
    }
  };

  window.openFxCalculator = function () {
    const modal = document.getElementById('fxCalculatorModal');
    const backdrop = document.getElementById('fxBackdrop');
    if (modal && backdrop) {
      modal.classList.add('show');
      backdrop.classList.add('show');
      document.body.style.overflow = 'hidden';
      window.calculateFx();
    }
  };

  window.closeFxCalculator = function () {
    const modal = document.getElementById('fxCalculatorModal');
    const backdrop = document.getElementById('fxBackdrop');
    if (modal) modal.classList.remove('show');
    if (backdrop) backdrop.classList.remove('show');
    document.body.style.overflow = '';
  };

  // 13. 自動掛載 DOM 元件 (Floating Hub, Favorites Drawer & FX Modal)
  function mountUI() {
    // (A) 檢查或注入浮動工具箱
    if (!document.getElementById('floatingQuickBar')) {
      const hub = document.createElement('div');
      hub.className = 'floating-square-hub';
      hub.id = 'floatingQuickBar';
      hub.innerHTML = `
        <span class="square-hub-badge" id="favCountBadge" style="display:none;">0</span>
        <button class="square-hub-item hub-item-fav" onclick="openFavoritesDrawer()" aria-label="查看我的日旅行程收藏本" title="查看行程收藏本">
          <span class="hub-icon-wrap">${getHeartSvg(true, 14)}</span>
          <span class="hub-label">收藏</span>
        </button>
        <div class="square-hub-divider"></div>
        <button class="square-hub-item hub-item-fx" onclick="openFxCalculator()" aria-label="日幣即時匯率與10%免稅試算" title="日幣即時匯率與10%免稅試算">
          <span class="hub-icon-wrap" style="font-size:14px; line-height:1;">💴</span>
          <span class="hub-label">免稅</span>
        </button>
      `;
      document.body.appendChild(hub);
    } else {
      // 若已存在但使用了舊結構，校正按鈕與 icon
      const favBtn = document.querySelector('.floating-square-hub .hub-item-fav, .floating-square-hub button:first-of-type');
      if (favBtn) {
        const icon = favBtn.querySelector('.hub-icon, .hub-icon-wrap');
        if (icon) {
          icon.innerHTML = getHeartSvg(true, 14);
        }
      }
      const fxBtn = document.querySelector('.floating-square-hub .hub-item-fx, .floating-square-hub button:last-of-type');
      if (fxBtn && !fxBtn.hasAttribute('onclick')) {
        fxBtn.setAttribute('onclick', 'openFxCalculator()');
      }
    }

    // (B) 檢查或注入收藏抽屜
    if (!document.getElementById('favoritesDrawer')) {
      const backdrop = document.createElement('div');
      backdrop.className = 'fav-backdrop';
      backdrop.id = 'favBackdrop';
      backdrop.onclick = window.closeFavoritesDrawer;
      document.body.appendChild(backdrop);

      const drawer = document.createElement('div');
      drawer.className = 'fav-drawer';
      drawer.id = 'favoritesDrawer';
      drawer.innerHTML = `
        <div class="fav-drawer-header">
          <div>
            <div style="display:flex; align-items:center; gap:8px;">
              ${getHeartSvg(true, 16)}
              <h3 style="font-size:1.1rem; font-weight:900; color:#1E293B; margin:0;">我的日旅行程收藏本</h3>
            </div>
            <div style="font-size:0.74rem; color:#64748B; margin-top:3px;">
              免登入離線自動保存 ｜ 關閉視窗不遺失 ｜ 點擊卡片可展開完整攻略
            </div>
          </div>
          <button class="btn-fav-remove" onclick="closeFavoritesDrawer()" style="font-size:18px; padding:6px 10px;">✕</button>
        </div>
        
        <div class="fav-drawer-body" id="favListContainer"></div>

        <div class="fav-drawer-footer">
          <button class="btn-fav-copy-all" onclick="copyAllFavorites()">
            📋 一鍵複製所有行程清單
          </button>
          <button class="btn-fav-clear" onclick="clearAllFavorites()">
            全部清空
          </button>
        </div>
      `;
      document.body.appendChild(drawer);
    }

    // (C) 檢查或注入日幣匯率＆免稅試算小工具 Modal
    if (!document.getElementById('fxCalculatorModal')) {
      const fxBackdrop = document.createElement('div');
      fxBackdrop.className = 'fav-backdrop';
      fxBackdrop.id = 'fxBackdrop';
      fxBackdrop.onclick = window.closeFxCalculator;
      document.body.appendChild(fxBackdrop);

      const fxModal = document.createElement('div');
      fxModal.className = 'fx-calc-modal';
      fxModal.id = 'fxCalculatorModal';
      fxModal.innerHTML = `
        <div class="fx-calc-header">
          <div style="display:flex; align-items:center; gap:8px;">
            <span style="font-size:20px;">💴</span>
            <h3>日幣即時匯率 ＆ 免稅試算</h3>
          </div>
          <button class="btn-close-circle" onclick="closeFxCalculator()" aria-label="關閉試算小工具">✕</button>
        </div>

        <div class="fx-calc-body">
          <!-- 匯率基準 -->
          <div class="fx-rate-row">
            <span style="font-size:0.82rem; font-weight:700; color:#475569;">參考匯率 (1 JPY = ? TWD)：</span>
            <input type="number" id="fxRateInput" step="0.001" value="0.215" oninput="calculateFx()" class="fx-rate-field">
          </div>

          <!-- 輸入金額 -->
          <div style="margin:14px 0 8px;">
            <label style="font-size:0.8rem; font-weight:800; color:#334155;">輸入商品含稅日圓金額 (JPY ¥)：</label>
            <div class="fx-input-wrap">
              <span class="fx-curr-symbol">¥</span>
              <input type="number" id="fxJpyInput" value="10000" placeholder="例如 10000" oninput="calculateFx()" class="fx-amount-input">
            </div>
          </div>

          <!-- 快捷金額標籤 -->
          <div class="fx-quick-tags">
            <button onclick="setQuickJpy(1000)">¥1,000</button>
            <button onclick="setQuickJpy(5500)">¥5,500 (免稅門檻)</button>
            <button onclick="setQuickJpy(10000)">¥10,000</button>
            <button onclick="setQuickJpy(30000)">¥30,000</button>
            <button onclick="setQuickJpy(50000)">¥50,000</button>
            <button onclick="setQuickJpy(100000)">¥100,000</button>
          </div>

          <!-- 試算結果卡片 -->
          <div class="fx-result-grid">
            <!-- 1. 一般含稅原價 -->
            <div class="fx-card fx-card-normal">
              <div class="fx-card-lbl">一般含稅原價</div>
              <div>
                <div class="fx-card-twd" id="fxNormTwd">NT$ 2,150</div>
                <div class="fx-card-jpy" id="fxNormJpy">約 ¥10,000</div>
              </div>
            </div>

            <!-- 2. 日本 10% 退稅價 -->
            <div class="fx-card fx-card-taxfree">
              <div class="fx-card-lbl">✨ 10% 免稅後 (Tax Free)</div>
              <div>
                <div class="fx-card-twd text-emerald" id="fxTaxFreeTwd">NT$ 1,955</div>
                <div class="fx-card-jpy" id="fxTaxFreeJpy">未稅 ¥9,091 (現省 NT$ 195)</div>
              </div>
            </div>

            <!-- 3. 免稅 + 5% 優惠券 -->
            <div class="fx-card fx-card-coupon">
              <div class="fx-card-lbl">🎉 免稅 + 百貨/唐吉 5% 券</div>
              <div>
                <div class="fx-card-twd text-rose" id="fxCouponTwd">NT$ 1,857</div>
                <div class="fx-card-jpy" id="fxCouponJpy">實付 ¥8,636 (現折 8.6 折！)</div>
              </div>
            </div>
          </div>

          <div class="fx-tax-tip">
            💡 <b>日本免稅購物秘笈：</b>同一店家當日購買一般品或消耗品，含稅累積滿 <b>¥5,500（未稅 ¥5,000）</b>即可出示護照正本享有免稅。消耗品（藥妝、食品）出境前請勿拆封！
          </div>
        </div>
      `;
      document.body.appendChild(fxModal);
    }

    updateFavoriteBadge();
    updateAllHeartButtons();
  }


  // 15. 全球化智慧多國語系外跳分潤攔截與路由對齊引擎 (Affiliate & Geo-Routing Engine)
  function initAffiliateRouter() {
    // 取得當前用戶語系：先讀 localStorage，次讀 navigator.language
    function detectUserLocale() {
      var saved = localStorage.getItem('tabi_selected_lang');
      if (saved) return saved.toLowerCase();
      var nav = (navigator.language || navigator.userLanguage || '').toLowerCase();
      if (nav.startsWith('zh-tw') || nav.startsWith('zh-hk')) return 'zh-tw';
      if (nav.startsWith('zh')) return 'zh-cn';
      if (nav.startsWith('ja')) return 'ja';
      if (nav.startsWith('th')) return 'th';
      if (nav.startsWith('ko')) return 'ko';
      if (nav.startsWith('en')) return 'en';
      return 'zh-tw'; // default
    }

    // 監聽全站所有點擊連結事件
    document.addEventListener('click', function (e) {
      var a = e.target.closest('a');
      if (!a || !a.href) return;
      var href = a.href;
      if (href.startsWith('javascript:') || href.startsWith('#')) return;

      var locale = detectUserLocale();
      var isWesternOrGlobal = (locale === 'en' || locale === 'th' || locale === 'ko' || locale === 'ja');

      // (A) Trip.com 智慧路由與分潤掛碼
      if (href.indexOf('trip.com') > -1) {
        a.target = '_blank';
        a.rel = 'noopener noreferrer';
        // 若為官方短網址則保留快速跳轉
        if (href.indexOf('/t/fgyJcXow1X2') > -1) return;

        var tripDomains = {
          'zh-tw': 'https://tw.trip.com',
          'zh-cn': 'https://hk.trip.com',
          'en': 'https://www.trip.com',
          'ja': 'https://jp.trip.com',
          'th': 'https://th.trip.com',
          'ko': 'https://kr.trip.com'
        };
        var targetDomain = tripDomains[locale] || (isWesternOrGlobal ? 'https://www.trip.com' : 'https://tw.trip.com');

        // 置換主網域為對應語系站
        var newHref = href.replace(/https:\/\/(tw|jp|th|kr|hk|www)\.trip\.com/, targetDomain);
        if (!newHref.startsWith('http')) newHref = targetDomain + newHref;

        // 注入四大主力 ID
        if (newHref.indexOf('Allianceid=') === -1) {
          var sep = newHref.indexOf('?') > -1 ? '&' : '?';
          newHref += sep + 'Allianceid=9507030&SID=325761227&trip_sub1=%E6%97%A5%E6%9C%AC%E5%A0%B1%E5%A0%B1&trip_sub3=D20272275';
        } else {
          // 若有舊的 D20905663 或其他 trip_sub3，統一校正為規格書之 D20272275
          newHref = newHref.replace(/trip_sub3=[A-Za-z0-9_]+/, 'trip_sub3=D20272275');
        }
        a.href = newHref;
      }

      // (B) Klook 景點/體驗/包車/Pass 自動掛碼 aid=123436
      else if (href.indexOf('klook.com') > -1) {
        a.target = '_blank';
        a.rel = 'noopener noreferrer';

        var klookLocales = {
          'zh-tw': 'zh-TW',
          'zh-cn': 'zh-CN',
          'en': 'en-US',
          'ja': 'ja',
          'th': 'th',
          'ko': 'ko'
        };
        var targetKlookLoc = klookLocales[locale] || (isWesternOrGlobal ? 'en-US' : 'zh-TW');

        var newHref = href.replace(/klook\.com\/[a-zA-Z_\-]+(\/|$)/, 'klook.com/' + targetKlookLoc + '/');
        if (newHref.indexOf('aid=') === -1) {
          var sep = newHref.indexOf('?') > -1 ? '&' : '?';
          newHref += sep + 'aid=123436&utm_medium=affiliate-alwayson';
        }
        a.href = newHref;
      }

      // (C) Rakuten Travel / 日本樂天 自動掛碼 592df26a.c525acf4.592df26b.012fa32d
      else if (href.indexOf('rakuten.co.jp') > -1) {
        a.target = '_blank';
        a.rel = 'noopener noreferrer';
        if (href.indexOf('hb.afl.rakuten.co.jp') === -1 && href.indexOf('592df26a.c525acf4.592df26b.012fa32d') === -1) {
          var encodedTarget = encodeURIComponent(href);
          a.href = 'https://hb.afl.rakuten.co.jp/ichiba/592df26a.c525acf4.592df26b.012fa32d/?pc=' + encodedTarget;
        }
      }

      // (D) Booking.com 歐美外國用戶 Travelpayouts / 多幣別智慧分流
      else if (href.indexOf('booking.com') > -1) {
        a.target = '_blank';
        a.rel = 'noopener noreferrer';

        // 若為歐美旅客 (en) 且有指定 Travelpayouts 專屬短鏈 KhRuaSJR，亦可支援導流
        var bookingLocs = {
          'zh-tw': 'zh-tw',
          'zh-cn': 'zh-cn',
          'en': 'en-gb',
          'ja': 'ja',
          'th': 'th',
          'ko': 'ko'
        };
        var bookingCurs = {
          'zh-tw': 'TWD',
          'zh-cn': 'CNY',
          'en': 'USD',
          'ja': 'JPY',
          'th': 'THB',
          'ko': 'KRW'
        };
        var bLoc = bookingLocs[locale] || 'zh-tw';
        var bCur = bookingCurs[locale] || 'TWD';

        var newHref = href.replace(/searchresults\.[a-z\-]+\.html/, 'searchresults.' + bLoc + '.html');
        if (newHref.indexOf('selected_currency=') === -1) {
          var sep = newHref.indexOf('?') > -1 ? '&' : '?';
          newHref += sep + 'selected_currency=' + bCur;
        }
        a.href = newHref;
      }
    }, true);
  }

  // 14. 官方防盜版、著作權防護與轉載追蹤
  function initCopyrightProtection() {
    // 禁止在圖片與文章卡片上按右鍵盜圖
    document.addEventListener('contextmenu', function (e) {
      const target = e.target;
      if (target.tagName === 'IMG' || target.closest('.spot-card, .rank-4col-card, .rank-top3-card, .train-wanderly-card, .bloom-card, .cafe-story-card')) {
        e.preventDefault();
        showTabiToast('【日旅報報 JAPAN TABI】現地取材原創內容受著作權保護，未經授權禁止盜用', '🛡️');
      }
    });

    // 複製文字時自動附加官方著作權來源與出處網址
    document.addEventListener('copy', function (e) {
      const selection = window.getSelection();
      if (!selection || selection.toString().length < 35) return;
      const text = selection.toString();
      const attribution = `\n\n--------------------\n來源：《日旅報報 JAPAN TABI》公式觀測現地取材認證\n原文網址：${window.location.href}\n全站圖文著作權所有，未經許可請勿轉載或進行商業二次利用。`;
      
      if (e.clipboardData) {
        e.clipboardData.setData('text/plain', text + attribution);
        e.preventDefault();
      }
    });

    // 防止惡意 iframe 內嵌 (Clickjacking Protection)
    try {
      if (window.top !== window.self) {
        window.top.location = window.self.location;
      }
    } catch (e) {
      console.warn('[TABI] Frame check caught');
    }

    // 控制台官方防偽浮水印
    console.log(
      "%c JAPAN TABI 公式觀測 %c 本站所有現地取材照片與特派員報導受法律嚴密保護，未經書面許可禁止轉載、抓取與抄襲盜用。",
      "background:#BE123C; color:#FFFFFF; font-weight:bold; font-size:12px; padding:4px 8px; border-radius:4px;",
      "color:#0F172A; font-weight:bold; font-size:12px; margin-left:6px;"
    );
  }

  // DOM 載入後自動掛載
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      mountUI();
      initCopyrightProtection();
      initAffiliateRouter();
    });
  } else {
    mountUI();
    initCopyrightProtection();
    initAffiliateRouter();
  }

  // 全域暴露
  window.getHeartSvg = getHeartSvg;
  window.getFavorites = getFavorites;
  window.isFavorite = isFavorite;
})();

/* ==========================================================================
   全站統一 Header 多國語系下拉選單 (toggleLangDropdown / selectLanguage)
   ========================================================================== */
(function () {
  function closeMenu() {
    var menu = document.getElementById('langDropdownMenu');
    var wrap = document.getElementById('langSelectorWrap');
    if (menu) menu.classList.remove('show');
    if (wrap) wrap.classList.remove('open');
  }

  if (typeof window.toggleLangDropdown !== 'function') window.toggleLangDropdown = function (event) {
    if (event) event.stopPropagation();
    var menu = document.getElementById('langDropdownMenu');
    var wrap = document.getElementById('langSelectorWrap');
    if (!menu) return;
    var show = menu.classList.toggle('show');
    if (wrap) wrap.classList.toggle('open', show);
  };

  if (typeof window.selectLanguage !== 'function') window.selectLanguage = function (langCode, langName) {
    var lbl = document.getElementById('currentLangLabel');
    if (lbl) lbl.textContent = langName;
    closeMenu();

    document.querySelectorAll('.lang-menu-opt').forEach(function (opt) {
      opt.classList.toggle('active', opt.getAttribute('data-lang') === langCode);
    });

    try { localStorage.setItem('tabi_selected_lang', langCode); } catch (e) {}

    // 深度文章多語系橋接 (special_edition 等頁面)
    if (typeof window.setArticleLang === 'function') {
      var key = String(langCode).toLowerCase();
      var pill = document.querySelector('.btn-trans-choice[data-lang="' + key + '"]');
      window.setArticleLang(key, pill);
    }

    // 頁面專屬後續行為 (例如查機票重新渲染)
    if (typeof window.TabiOnLanguageChange === 'function') {
      window.TabiOnLanguageChange(langCode, langName);
    }
  };

  window.addEventListener('click', function (e) {
    var wrap = document.getElementById('langSelectorWrap');
    var menu = document.getElementById('langDropdownMenu');
    if (wrap && menu && !wrap.contains(e.target)) {
      menu.classList.remove('show');
      wrap.classList.remove('open');
    }
  });
})();
