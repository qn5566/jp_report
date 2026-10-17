#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
use FindBin qw($Bin);

my $target = "$Bin/app/index.html";

open my $fh, '>:utf8', $target or die "Cannot open $target: $!\n";

print $fh <<'HTML_HEAD_CODE';
<!DOCTYPE html>
<html lang="zh-TW">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>日旅報報 | 全日本景點導覽・花火大會等級庫・動態時令咖啡與和風地圖</title>

  <!-- Tailwind CSS -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>

  <!-- Leaflet.js (100% Free Open-Source Interactive Map) -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

  <!-- Google Fonts: Zen Maru Gothic, Noto Sans TC, Plus Jakarta Sans -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;700;900&family=Plus+Jakarta+Sans:wght@400;600;800&family=Zen+Maru+Gothic:wght@400;500;700;900&display=swap" rel="stylesheet">

  <style>
    :root {
      --theme-bg: #FAF9F6;
      --theme-card-bg: #FFFFFF;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #E8E3D9;
      --theme-text: #262220;
      --theme-muted: #78716C;
      --theme-badge-bg: #E0F2FE;
      --washi-accent: #C4B9A7;
    }

    body.theme-spot {
      --theme-bg: #FAF9F6;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #E8E3D9;
      --theme-text: #262220;
      --theme-muted: #78716C;
      --theme-badge-bg: #E0F2FE;
      --washi-accent: #C4B9A7;
    }

    body.theme-flower {
      --theme-bg: #FCF8F9;
      --theme-primary: #EE6A7C;
      --theme-primary-hover: #D94D61;
      --theme-soft: #FFE4E8;
      --theme-deep: #9F1239;
      --theme-border: #F7D6DE;
      --theme-text: #271217;
      --theme-muted: #88626A;
      --theme-badge-bg: #FFF0F3;
      --washi-accent: #F4B8C5;
    }

    body.theme-fireworks {
      --theme-bg: #090C16;
      --theme-primary: #EC4899;
      --theme-primary-hover: #DB2777;
      --theme-soft: #1E293B;
      --theme-deep: #F43F5E;
      --theme-border: #334155;
      --theme-text: #F8FAFC;
      --theme-muted: #94A3B8;
      --theme-badge-bg: #1E293B;
      --washi-accent: #F59E0B;
    }

    body.theme-ski {
      --theme-bg: #F4F9FD;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #CBE4F9;
      --theme-text: #0F172A;
      --theme-muted: #64748B;
      --theme-badge-bg: #E0F2FE;
      --washi-accent: #93C5FD;
    }

    body.theme-onsen {
      --theme-bg: #FAF6ED;
      --theme-primary: #D97706;
      --theme-primary-hover: #B45309;
      --theme-soft: #FEF3C7;
      --theme-deep: #78350F;
      --theme-border: #EFE4CC;
      --theme-text: #271808;
      --theme-muted: #785A3C;
      --theme-badge-bg: #FEF3C7;
      --washi-accent: #D4AF37;
    }

    body.theme-event {
      --theme-bg: #FAF5FF;
      --theme-primary: #9333EA;
      --theme-primary-hover: #7E22CE;
      --theme-soft: #F3E8FF;
      --theme-deep: #581C87;
      --theme-border: #E9D5FF;
      --theme-text: #23083B;
      --theme-muted: #755B8F;
      --theme-badge-bg: #F3E8FF;
      --washi-accent: #C084FC;
    }

    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
      font-family: 'Zen Maru Gothic', 'Plus Jakarta Sans', 'Noto Sans TC', sans-serif;
    }

    /* 和風質感背景：精緻青海波(Seigaiha)和紙紋理 ＋ 微細纖維點 */
    body {
      background-color: var(--theme-bg);
      background-image: 
        /* 和風青海波微浮水印 */
        url("data:image/svg+xml,%3Csvg width='60' height='30' viewBox='0 0 60 30' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M0 15 A15 15 0 0 1 30 15 A15 15 0 0 1 60 15 M-15 30 A15 15 0 0 1 15 30 A15 15 0 0 1 45 30 A15 15 0 0 1 75 30 M-15 0 A15 15 0 0 1 15 0 A15 15 0 0 1 45 0 A15 15 0 0 1 75 0' fill='none' stroke='%23C0B7A6' stroke-width='0.7' stroke-opacity='0.15'/%3E%3C/svg%3E"),
        /* 鳥の子和紙微細纖維感 */
        radial-gradient(circle at 50% 50%, rgba(180, 160, 130, 0.08) 1px, transparent 1px);
      background-size: 60px 30px, 28px 28px;
      color: var(--theme-text);
      transition: background-color 0.4s ease, color 0.4s ease;
      overflow-x: hidden;
      min-height: 100vh;
    }

    body.theme-fireworks {
      background-image: 
        url("data:image/svg+xml,%3Csvg width='60' height='30' viewBox='0 0 60 30' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M0 15 A15 15 0 0 1 30 15 A15 15 0 0 1 60 15 M-15 30 A15 15 0 0 1 15 30 A15 15 0 0 1 45 30 A15 15 0 0 1 75 30 M-15 0 A15 15 0 0 1 15 0 A15 15 0 0 1 45 0 A15 15 0 0 1 75 0' fill='none' stroke='%23EC4899' stroke-width='0.6' stroke-opacity='0.12'/%3E%3C/svg%3E"),
        /* 蒔繪金箔星屑感 */
        radial-gradient(circle at 50% 50%, rgba(245, 158, 11, 0.22) 1px, transparent 1px);
      background-size: 60px 30px, 32px 32px;
    }

    .border-theme { border-color: var(--theme-border); }
    .bg-theme-soft { background-color: var(--theme-soft); }
    .text-theme-primary { color: var(--theme-primary); }
    .bg-theme-primary { background-color: var(--theme-primary); }
    .text-theme-deep { color: var(--theme-deep); }
    .text-theme-muted { color: var(--theme-muted); }
    .text-theme-text { color: var(--theme-text); }

    /* 和風陰影與柔邊 */
    .washi-shadow {
      box-shadow: 0 4px 20px -2px rgba(60, 45, 30, 0.04), 0 2px 6px -1px rgba(60, 45, 30, 0.02);
    }
    .washi-shadow-lg {
      box-shadow: 0 10px 30px -4px rgba(60, 45, 30, 0.07), 0 4px 12px -2px rgba(60, 45, 30, 0.03);
    }

    .no-scrollbar::-webkit-scrollbar { display: none; }
    .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

    #particle-canvas {
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      pointer-events: none;
      z-index: 1;
    }

    .leaflet-container {
      font-family: 'Zen Maru Gothic', sans-serif !important;
      background-color: #FAF9F6 !important;
    }

    .custom-map-icon {
      background: none;
      border: none;
    }

    @keyframes live-pulse {
      0% { transform: scale(0.95); opacity: 0.85; }
      50% { transform: scale(1.1); opacity: 1; filter: drop-shadow(0 0 8px rgba(238, 106, 124, 0.7)); }
      100% { transform: scale(0.95); opacity: 0.85; }
    }
    .map-badge-pulse {
      animation: live-pulse 2s infinite ease-in-out;
    }
  </style>
</head>
<body class="theme-spot min-h-screen flex flex-col relative">

  <!-- Seasonal background particle canvas -->
  <canvas id="particle-canvas"></canvas>

  <!-- ================= 頂部 Header（寬版適配，左右留白恰到好處） ================= -->
  <header class="sticky top-0 z-40 bg-white/94 backdrop-blur-md border-b border-theme transition-colors">
    <div class="max-w-[1540px] mx-auto px-4 sm:px-6 lg:px-8 xl:px-12 py-3 flex items-center justify-between gap-4">
      
      <!-- Brand Logo with Mt. Fuji & Badge -->
      <div class="flex items-center gap-3 cursor-pointer select-none" onclick="resetAllFilters()">
        <div class="relative w-11 h-11 rounded-2xl bg-gradient-to-br from-white to-amber-50 border border-theme shadow-sm flex items-center justify-center overflow-hidden flex-shrink-0">
          <svg viewBox="0 0 40 40" class="w-8 h-8">
            <path d="M7 32 L20 10 L33 32 Z" fill="#94A3B8" />
            <path d="M15 18 L20 10 L25 18 L22 16 L20 18 L18 16 Z" fill="#FFFFFF" />
            <circle cx="28" cy="11" r="5" fill="#EF4444" opacity="0.85" />
          </svg>
          <span id="brand-badge-icon" class="absolute bottom-0.5 right-0.5 text-xs">🏛️</span>
        </div>
        <div>
          <div class="flex items-center gap-2">
            <h1 id="i18n-brand-title" class="text-base sm:text-lg font-black tracking-tight text-theme-text leading-tight">日旅報報</h1>
            <span id="i18n-badge-live" class="text-[10px] font-black px-2 py-0.5 rounded-full bg-theme-soft text-theme-primary border border-theme">
              2026 旬況版
            </span>
          </div>
          <p id="i18n-brand-sub" class="text-[11px] text-theme-muted font-medium hidden sm:block">全日本景點導覽・花火大會等級庫・動態時令咖啡與和風地圖</p>
        </div>
      </div>

      <!-- 中間快速功能：視圖切換 (📋 卡片速報 ⇄ 🗺️ 和風實況地圖) -->
      <div class="flex items-center bg-gray-100/90 p-1 rounded-2xl border border-theme">
        <button id="view-cards-btn" onclick="setViewMode('cards')" class="px-3 sm:px-4 py-1.5 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex items-center gap-1.5">
          <span>📋</span> <span id="i18n-view-cards">卡片清單</span>
        </button>
        <button id="view-map-btn" onclick="setViewMode('map')" class="px-3 sm:px-4 py-1.5 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex items-center gap-1.5">
          <span>🗺️</span> <span id="i18n-view-map">和風實況地圖</span>
        </button>
      </div>

      <!-- 右側按鈕：語言切換 + 我的收藏愛心 -->
      <div class="flex items-center gap-2 sm:gap-3">
        <button onclick="toggleLanguage()" id="lang-toggle-btn" class="px-3 py-1.5 rounded-2xl bg-white border border-theme shadow-sm hover:scale-105 active:scale-95 transition flex items-center gap-1 text-xs font-black text-theme-deep flex-shrink-0" title="切換語言 / Switch Language">
          <span>🌐</span>
          <span id="lang-label">EN</span>
        </button>

        <button onclick="toggleBookmarkDrawer()" class="relative px-3 py-1.5 rounded-2xl bg-white border border-theme shadow-sm hover:scale-105 active:scale-95 transition flex items-center gap-1.5 text-xs font-black text-theme-text flex-shrink-0" title="我的收藏清單 / Saved">
          <span class="text-rose-500">❤️</span>
          <span class="hidden md:inline">收藏</span>
          <span id="bookmark-badge" class="bg-rose-500 text-white text-[10px] font-black w-4 h-4 rounded-full flex items-center justify-center hidden">
            0
          </span>
        </button>
      </div>

    </div>

    <!-- ================= 一、頂部大地區（最直覺：預設選中 🗼 東京全部景點） ================= -->
    <div class="bg-stone-50/90 border-t border-theme/60 px-4 sm:px-6 lg:px-8 xl:px-12 py-2">
      <div class="max-w-[1540px] mx-auto flex items-center justify-start gap-2 overflow-x-auto no-scrollbar" id="scope-selector-wrap">
        <button onclick="setScope('tokyo')" id="scope-tokyo-btn" class="scope-btn px-3.5 py-1.5 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex-shrink-0 flex items-center gap-1.5 border border-theme">
          <span>🗼</span> <span id="i18n-scope-tokyo">東京全部景點</span>
        </button>
        <button onclick="setScope('all')" id="scope-all-btn" class="scope-btn px-3.5 py-1.5 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1.5">
          <span>🗾</span> <span id="i18n-scope-all">全日本</span>
        </button>
        <button onclick="setScope('kansai')" id="scope-kansai-btn" class="scope-btn px-3.5 py-1.5 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1.5">
          <span>🐙</span> <span id="i18n-scope-kansai">關西圈 (京阪神)</span>
        </button>
        <button onclick="setScope('hokkaido')" id="scope-hokkaido-btn" class="scope-btn px-3.5 py-1.5 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1.5">
          <span>❄️</span> <span id="i18n-scope-hokkaido">北海道</span>
        </button>
        <button onclick="setScope('tohoku')" id="scope-tohoku-btn" class="scope-btn px-3.5 py-1.5 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1.5">
          <span>🌲</span> <span id="i18n-scope-tohoku">東北</span>
        </button>
      </div>
    </div>

    <!-- ================= 二、大分類主按鈕（景點為主體：預設 🏛️ 全部景點） ================= -->
    <div class="bg-white/80 border-t border-theme/60 px-4 sm:px-6 lg:px-8 xl:px-12 py-2.5">
      <div class="max-w-[1540px] mx-auto flex items-center gap-2 overflow-x-auto no-scrollbar" id="main-category-wrap">
        <!-- Rendered dynamically -->
      </div>
    </div>
  </header>

  <!-- ================= 三、情境動態展開樞紐（點什麼才出什麼，絕不打架） ================= -->
  <section class="max-w-[1540px] mx-auto w-full px-4 sm:px-6 lg:px-8 xl:px-12 pt-4 z-10 relative space-y-3">

    <!-- 1. 【點全部景點時】動態展開：東京各區深度篩選（澀谷、新宿、淺草、銀座、港區、秋葉原...） -->
    <div id="panel-district-filter" class="p-3.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
      <div class="flex items-center justify-between mb-2.5">
        <span class="text-xs font-black text-theme-deep flex items-center gap-1.5" id="lbl-district-title">
          <span>📍</span> 東京各區地標深度篩選：
        </span>
        <span class="text-[11px] text-theme-muted font-bold" id="lbl-district-hint">精選代表性熱門打卡景點</span>
      </div>
      <div class="flex items-center gap-2 overflow-x-auto no-scrollbar" id="district-buttons-wrap">
        <!-- Injected via JS -->
      </div>
    </div>

    <!-- 2. 【點花季名所時】動態展開：櫻花救援專題 ＋ 品種花色快篩 ＋ WNI 開花進度前線 -->
    <div id="panel-flower-filter" class="space-y-3 hidden">
      <!-- 櫻花救援專題 Banner -->
      <div id="sakura-rescue-banner" class="p-4 rounded-2xl bg-gradient-to-r from-rose-50 via-pink-50 to-amber-50 border border-rose-200 washi-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-rose-500/10 flex items-center justify-center text-2xl flex-shrink-0">
            🌺
          </div>
          <div>
            <div class="flex items-center gap-2">
              <span class="text-xs sm:text-sm font-black text-rose-800" id="lbl-rescue-title">下週去怕染井吉野凋謝？「晚開八重櫻＆稀有綠櫻」接力盛開中！</span>
              <span class="text-[10px] bg-rose-600 text-white px-2 py-0.5 rounded font-black" id="lbl-rescue-badge">救援攻略</span>
            </div>
            <p class="text-xs text-rose-700/90 leading-relaxed mt-0.5" id="lbl-rescue-desc">
              染井吉野櫻落櫻後，新宿御苑、大阪造幣局等「關山櫻、御衣黃、普賢象」花期可一路延續至 4 月中下旬！
            </p>
          </div>
        </div>
        <button onclick="selectVariety('late')" class="px-3.5 py-2 bg-rose-600 hover:bg-rose-700 text-white text-xs font-black rounded-xl shadow-sm transition flex-shrink-0 flex items-center gap-1.5">
          <span>👀</span> <span id="lbl-rescue-btn">一鍵查看晚開接力名所</span>
        </button>
      </div>

      <!-- 櫻花品種多系與花色快篩 -->
      <div class="p-3.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2.5">
          <span class="text-xs font-black text-theme-deep flex items-center gap-1.5">
            <span>🌸</span> <span id="lbl-variety-title">櫻花品種花色與接力時令快篩：</span>
          </span>
          <button onclick="openUploadModal()" class="text-xs font-black px-3 py-1 bg-theme-primary text-white rounded-xl flex items-center gap-1 shadow-sm hover:scale-105 active:scale-95 transition">
            <span>📷</span> <span id="lbl-upload-btn">上傳最新實況照</span>
          </button>
        </div>
        <div class="flex items-center gap-2 overflow-x-auto no-scrollbar" id="sakura-variety-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>

      <!-- WNI 實時開花進度前線快篩 -->
      <div class="p-3.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2.5">
          <span class="text-xs font-black text-rose-600 flex items-center gap-1.5">
            <span>🌸</span> Weathernews (WNI) 開花進度實時前線：
          </span>
          <span class="text-[11px] text-theme-muted font-bold">氣象廳標本木觀測同步</span>
        </div>
        <div class="flex items-center gap-2 overflow-x-auto no-scrollbar" id="flower-bloom-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>
    </div>

    <!-- 3. 【點花火大會時】動態展開：Walkerplus 規格與等級標準化 (S級超大規模/A級萬發/特色級水中尺玉) -->
    <div id="panel-fireworks-filter" class="p-4 bg-slate-900/95 text-white border border-slate-700 rounded-2xl washi-shadow hidden space-y-3">
      <div class="flex items-center justify-between border-b border-slate-800 pb-2.5">
        <div class="flex items-center gap-2.5">
          <span class="text-base">🎆</span>
          <span class="text-xs sm:text-sm font-black text-pink-400">Walkerplus 花火大會等級規格庫：</span>
          <span class="text-[10px] px-2.5 py-0.5 rounded-full bg-pink-900/60 text-pink-300 font-bold border border-pink-700">官方 1,000+ 場同步</span>
        </div>
        <span class="text-xs text-slate-400 font-bold hidden sm:inline">含發數・最大玉・去年度人潮・有料席搶票</span>
      </div>
      <div class="flex items-center gap-2 overflow-x-auto no-scrollbar" id="fireworks-grade-buttons-wrap">
        <!-- Injected via JS: S級/A級/特色級/全部 -->
      </div>
    </div>

    <!-- 4. 【點滑雪雪場時】動態展開：雪區篩選 ＋ 新手寬坡/進階長紅線/老手粉雪分級避雷 -->
    <div id="panel-ski-filter" class="space-y-3 hidden">
      <!-- 雪區大按鈕 -->
      <div class="p-3.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2.5">
          <span class="text-xs font-black text-theme-deep flex items-center gap-1.5">
            <span>📍</span> 全日本滑雪勝地分區：
          </span>
          <span class="text-[11px] text-theme-muted font-bold">即時同步日本 SURF&SNOW</span>
        </div>
        <div class="flex items-center gap-2 overflow-x-auto no-scrollbar" id="ski-region-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>

      <!-- 避雷分級面板 -->
      <div class="p-3.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2.5">
          <span class="text-xs font-black text-theme-deep flex items-center gap-1.5">
            <span>🏂</span> 滑雪分級避雷與出行情境（解決新手誤闖黑線痛點）：
          </span>
        </div>
        <div class="flex items-center gap-2 overflow-x-auto no-scrollbar" id="ski-skill-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>
    </div>

    <!-- 即時速報摘要列 ＋ 動態時令咖啡廳切換鈕 ＋ API 同步按鈕 -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between text-xs text-theme-muted px-1 border-b border-theme/60 pb-3 gap-3">
      <div id="filter-summary-text" class="flex items-center gap-2 font-medium flex-wrap text-xs sm:text-sm">
        <!-- Injected via JavaScript -->
      </div>

      <div class="flex items-center gap-3 flex-wrap">
        <!-- 子視圖切換 (動態主題咖啡廳：🌸櫻花咖啡 ⇄ 🍁楓葉手沖 ⇄ 🎆花火景觀餐廳) -->
        <div class="flex items-center bg-stone-100 p-1 rounded-xl border border-stone-200" id="subview-toggle-bar">
          <button onclick="setSubView('spots')" id="subview-spots-btn" class="px-3 py-1 rounded-lg text-xs font-black bg-white text-theme-primary shadow-xs">
            🏛️ <span id="i18n-subview-spots">全部列表</span>
          </button>
          <button onclick="setSubView('cafes')" id="subview-cafes-btn" class="px-3 py-1 rounded-lg text-xs font-bold text-gray-500 hover:text-gray-900 flex items-center gap-1">
            <span id="subview-cafe-icon">☕</span> <span id="subview-cafe-label">景觀咖啡</span>
          </button>
          <button onclick="setSubView('intel')" id="subview-intel-btn" class="px-3 py-1 rounded-lg text-xs font-bold text-gray-500 hover:text-gray-900 flex items-center gap-1">
            <span>💬</span> <span id="i18n-subview-intel">實況討論</span>
          </button>
        </div>

        <button onclick="triggerLiveApiSync()" id="btn-sync-api" class="px-3 py-1.5 bg-white hover:bg-stone-50 border border-theme text-theme-primary font-bold rounded-xl shadow-xs text-xs flex items-center gap-1.5 hover:scale-105 active:scale-95 transition" title="立即串聯更新最新數據">
          <span id="sync-icon">🔄</span>
          <span id="i18n-btn-sync">即時串聯刷新</span>
        </button>
      </div>
    </div>
  </section>

  <!-- ================= 主內容區 (卡片列表 VS 和風實況地圖，寬螢幕充分展開) ================= -->
  <main class="max-w-[1540px] mx-auto w-full px-4 sm:px-6 lg:px-8 xl:px-12 py-5 flex-1 z-10 relative">

    <!-- 1. 卡片檢視容器 (4 欄大格局展開，左右不再空洞) -->
    <div id="cards-view-wrap">
      
      <!-- 視圖 1: 景點與雪場卡片列表 -->
      <div id="spots-view">
        <div id="resorts-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-4 gap-5 lg:gap-6">
          <!-- Injected via JavaScript -->
        </div>

        <!-- 空狀態提示 -->
        <div id="empty-state" class="hidden text-center py-20 bg-white/80 rounded-3xl border border-theme washi-shadow p-8">
          <div class="text-5xl mb-3">⛩️</div>
          <h3 id="i18n-empty-title" class="text-base font-bold text-theme-text">目前篩選條件下尚無符合的名所或情報</h3>
          <p id="i18n-empty-sub" class="text-xs text-theme-muted mt-1.5">試著切換至「全部」或更換區域看看！</p>
          <button onclick="resetAllFilters()" id="i18n-empty-btn" class="mt-4 px-5 py-2 bg-theme-primary text-white text-xs font-bold rounded-xl shadow-sm hover:scale-105 transition">
            重設所有篩選
          </button>
        </div>
      </div>

      <!-- 視圖 2: 動態景觀咖啡廳指南 (櫻花咖啡 / 楓葉手沖 / 花火景觀餐廳) -->
      <div id="cafes-view" class="hidden space-y-5">
        <div class="p-5 bg-gradient-to-br from-amber-50/90 via-white to-pink-50/60 rounded-3xl border border-amber-200/80 washi-shadow" id="cafe-header-banner">
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div>
              <h2 class="text-base sm:text-lg font-black text-amber-950 flex items-center gap-2" id="lbl-cafe-h-title">
                <span id="cafe-header-icon">☕</span> <span id="cafe-header-title-text">特色水岸・景觀咖啡廳指南</span>
              </h2>
              <p class="text-xs sm:text-sm text-amber-800/80 mt-1" id="lbl-cafe-h-desc">
                第一排露台席、窗景與鐵道同框，附旅人真實拍攝時間戳與排隊攻略
              </p>
            </div>
            <button onclick="openUploadModal('cafe')" class="px-4 py-2 bg-amber-800 text-white text-xs font-black rounded-xl shadow hover:bg-amber-900 transition flex items-center gap-1.5 flex-shrink-0">
              <span>📷</span> <span id="lbl-cafe-report-btn">回報現場人潮/花況</span>
            </button>
          </div>
        </div>

        <div id="cafes-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-4 gap-5 lg:gap-6">
          <!-- Injected via JavaScript -->
        </div>
      </div>

      <!-- 視圖 3: 讀者即時情報與花況實況牆 (Live Intel & Community) -->
      <div id="intel-view" class="hidden space-y-5">
        <div class="p-5 bg-white rounded-3xl border border-theme washi-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <h2 class="text-base sm:text-lg font-black text-theme-text flex items-center gap-2">
              <span>💬</span> 讀者即時目擊情報牆
            </h2>
            <p class="text-xs text-theme-muted mt-1">
              旅人第一手 EXIF 拍攝時間認證，拒絕過期舊照！
            </p>
          </div>
          <button onclick="openUploadModal()" class="px-4 py-2 bg-theme-primary text-white text-xs font-black rounded-xl shadow-sm hover:scale-105 transition flex items-center gap-1.5 flex-shrink-0">
            <span>✍️</span> <span>我也要提供情報</span>
          </button>
        </div>

        <div id="intel-stream" class="space-y-3">
          <!-- Injected via JavaScript -->
        </div>
      </div>

    </div>

    <!-- 2. 【Leaflet ＋ CARTO Voyager 和風實況地圖】（寬螢幕大氣展現・可縮放・帶活體圖標與花季前線範圍） -->
    <div id="map-view-wrap" class="hidden">
      <div class="bg-white rounded-3xl overflow-hidden border border-theme washi-shadow-lg flex flex-col h-[75vh] min-h-[550px]">
        <div class="p-3.5 bg-stone-50/95 border-b border-theme flex items-center justify-between gap-3 flex-wrap z-10">
          <div class="flex items-center gap-2.5">
            <span class="text-lg">🗾</span>
            <span class="text-xs sm:text-sm font-black text-theme-deep">全日本實時地圖 (CARTO 和風底圖)</span>
            <button onclick="toggleSakuraFrontlineLayer()" id="btn-toggle-frontline" class="px-2.5 py-1 rounded-full bg-rose-100 text-rose-700 hover:bg-rose-200 text-xs font-black border border-rose-300 transition flex items-center gap-1">
              <span>🌸</span> <span>櫻花前線範圍：開</span>
            </button>
          </div>

          <div class="flex items-center gap-1.5 text-xs">
            <button onclick="jumpMapTo('tokyo')" class="px-2.5 py-1 rounded-lg bg-white border border-stone-200 hover:bg-stone-100 font-bold">🗼 東京</button>
            <button onclick="jumpMapTo('kansai')" class="px-2.5 py-1 rounded-lg bg-white border border-stone-200 hover:bg-stone-100 font-bold">🐙 關西</button>
            <button onclick="jumpMapTo('yuzawa')" class="px-2.5 py-1 rounded-lg bg-white border border-stone-200 hover:bg-stone-100 font-bold">⛷️ 湯澤雪區</button>
            <button onclick="jumpMapTo('hokkaido')" class="px-2.5 py-1 rounded-lg bg-white border border-stone-200 hover:bg-stone-100 font-bold">❄️ 北海道</button>
            <button onclick="jumpMapTo('all')" class="px-2.5 py-1 rounded-lg bg-white border border-stone-200 hover:bg-stone-100 font-bold">🗾 全日本</button>
          </div>
        </div>

        <div id="leaflet-map-container" class="relative flex-1 w-full h-full"></div>
      </div>
    </div>
  </main>

  <!-- ================= 景點 / 雪場 / 花火 詳細抽屜 (Bottom Sheet Modal) ================= -->
  <div id="detail-sheet" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden opacity-0 transition-opacity duration-300 flex items-end sm:items-center justify-center p-0 sm:p-4" onclick="closeDetailSheet(event)">
    <div class="bg-white w-full sm:max-w-2xl max-h-[90vh] rounded-t-3xl sm:rounded-3xl overflow-hidden shadow-2xl flex flex-col transform translate-y-8 transition-transform duration-300" onclick="event.stopPropagation()">
      
      <div class="relative h-60 w-full bg-stone-100 flex-shrink-0">
        <img id="sheet-img" src="" alt="" class="w-full h-full object-cover" />
        <button onclick="closeDetailSheet()" class="absolute top-4 right-4 w-9 h-9 rounded-full bg-black/60 text-white font-bold flex items-center justify-center hover:bg-black/80 transition">
          ✕
        </button>
        <div class="absolute bottom-3 left-4 right-4 flex items-center justify-between">
          <span id="sheet-region-badge" class="px-3 py-1 rounded-xl bg-black/60 backdrop-blur-md text-white text-xs font-bold">
            地區標籤
          </span>
          <span id="sheet-status-badge" class="px-3.5 py-1 rounded-full bg-white/95 text-theme-primary text-xs font-black shadow-md">
            狀態標籤
          </span>
        </div>
      </div>

      <div class="px-5 py-2.5 bg-stone-50 border-b border-stone-100 flex items-center justify-between gap-2 overflow-x-auto no-scrollbar">
        <div class="flex items-center gap-2 flex-1 overflow-x-auto no-scrollbar" id="sheet-gallery-bar">
          <!-- Injected via JavaScript -->
        </div>
        <span class="text-[10px] font-bold text-stone-400 flex items-center gap-1 flex-shrink-0">
          <span>📷</span> <span>Wikimedia / Unsplash 官方授權</span>
        </span>
      </div>

      <div class="p-5 sm:p-6 overflow-y-auto space-y-4 flex-1">
        <div>
          <div class="flex items-center gap-2 mb-1.5 flex-wrap">
            <span id="sheet-category-badge" class="px-2.5 py-0.5 rounded-lg bg-theme-soft text-theme-primary text-xs font-bold">景點類別</span>
            <span id="sheet-opendata-badge" class="px-2.5 py-0.5 rounded-lg bg-emerald-50 text-emerald-700 text-xs font-bold">Japan Open Data 官方連線</span>
          </div>
          <h2 id="sheet-title" class="text-xl sm:text-2xl font-black text-theme-text">名所/景點名稱</h2>
          <p id="sheet-subtitle" class="text-xs sm:text-sm font-bold text-theme-primary mt-1">副標特色</p>
          <p id="sheet-desc" class="text-xs sm:text-sm text-stone-600 mt-2 leading-relaxed">介紹說明</p>
        </div>

        <!-- 旬況 / 雪況 / 花火儀表盤 -->
        <div class="grid grid-cols-3 gap-2 p-3.5 bg-theme-soft/50 border border-theme rounded-2xl text-center">
          <div>
            <span id="sheet-metric-label-1" class="text-[11px] text-theme-muted font-bold block">規模 / 發數</span>
            <span id="sheet-depth" class="text-sm sm:text-base font-black text-theme-deep">狀態值</span>
          </div>
          <div>
            <span id="sheet-metric-label-2" class="text-[11px] text-theme-muted font-bold block">最大玉 / 雪質</span>
            <span id="sheet-quality" class="text-sm sm:text-base font-black text-theme-deep">品質</span>
          </div>
          <div>
            <span id="sheet-metric-label-3" class="text-[11px] text-theme-muted font-bold block">觀覽席 / 人潮</span>
            <span id="sheet-lifts" class="text-sm sm:text-base font-black text-theme-deep">正常營業</span>
          </div>
        </div>

        <!-- 景點關聯咖啡廳/餐廳專屬區塊 -->
        <div id="sheet-cafe-preview" class="p-4 rounded-2xl bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 text-xs hidden">
          <div class="flex items-center justify-between mb-1.5">
            <span class="font-black text-amber-900 flex items-center gap-1.5 text-xs sm:text-sm">
              <span>☕</span> <span id="sheet-cafe-preview-title">周邊景觀咖啡廳 / 餐廳特推：</span>
            </span>
            <button onclick="setSubView('cafes'); closeDetailSheet();" class="text-xs text-amber-700 font-bold underline">
              查看全部 ➔
            </button>
          </div>
          <p id="sheet-cafe-preview-text" class="text-amber-800 text-xs leading-relaxed">
            推薦「星巴克臻選® 東京烘焙工坊」4 樓川畔露台席或「ONIBUS COFFEE」窗景電車同框！
          </p>
        </div>

        <!-- 高客單價專屬預約卡 (滑雪中文教練 / 花季包車一日遊 / 煙火屋形船) -->
        <div id="sheet-highvalue-card" class="p-4 rounded-2xl bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200 text-xs">
          <div class="flex items-center gap-2 font-black text-emerald-900 mb-1 text-xs sm:text-sm">
            <span id="sheet-highvalue-icon">⛷️</span>
            <span id="sheet-highvalue-title">專屬中文滑雪教練特約預約：</span>
          </div>
          <p id="sheet-highvalue-desc" class="text-emerald-800 leading-relaxed text-xs">
            全中文雙板/單板教練，含專業教學攝影紀錄，提供小班制與私人 1 對 1。
          </p>
        </div>

        <!-- 交通路線 -->
        <div class="p-3.5 bg-stone-50 rounded-2xl border border-stone-200 text-xs">
          <div class="flex items-center justify-between mb-1.5">
            <span class="text-theme-muted text-xs font-bold block">🚇 公共交通指南 (ODPT 連線)</span>
            <button onclick="openExternalRoute()" class="text-xs text-blue-600 hover:underline font-bold flex items-center gap-1">
              <span>📍</span> <span>導航路線</span>
            </button>
          </div>
          <p id="sheet-transit" class="font-bold text-stone-800">地鐵與接駁路線</p>
        </div>

        <!-- 📊 即時底層 API 數據溯源與技術檢視 (Raw API Inspector) -->
        <div class="p-3.5 bg-slate-900 text-slate-100 rounded-2xl border border-slate-700 text-xs">
          <div class="flex items-center justify-between cursor-pointer" onclick="toggleApiRawInspector()">
            <div class="flex items-center gap-2 font-mono font-bold text-xs text-emerald-400">
              <span class="inline-block w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
              <span>API 數據溯源 (Walkerplus / SURF&SNOW / WNI / 觀振協)</span>
            </div>
            <span id="api-raw-toggle-arrow" class="text-xs text-slate-400 hover:text-white font-mono">▼ 檢視 JSON</span>
          </div>
          <div id="api-raw-content" class="mt-2.5 hidden">
            <pre class="bg-black/70 p-3 rounded-xl font-mono text-[11px] text-emerald-300 overflow-x-auto leading-relaxed border border-slate-800" id="sheet-api-json"></pre>
          </div>
        </div>
      </div>

      <!-- Drawer 底部動態導購按鈕組 -->
      <div id="sheet-action-footer" class="p-4 sm:p-5 bg-stone-50 border-t border-theme/80 space-y-2">
        <!-- Injected via JavaScript -->
      </div>

    </div>
  </div>

  <!-- ================= 互動 Modal 2: 旅人即時實況照上傳 (UGC Modal) ================= -->
  <div id="upload-modal" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-theme space-y-4">
      <div class="flex items-center justify-between border-b border-stone-100 pb-2.5">
        <div class="flex items-center gap-2">
          <span class="text-xl">📷</span>
          <h3 class="text-sm font-black text-stone-900">回報現場最新情報 (附拍攝時間)</h3>
        </div>
        <button onclick="closeUploadModal()" class="text-stone-400 hover:text-stone-700 font-bold text-sm">✕</button>
      </div>

      <div class="space-y-3 text-xs">
        <div>
          <label class="font-bold text-stone-700 block mb-1">選擇名所、花火或景觀餐廳：</label>
          <select id="upload-spot-select" class="w-full p-2.5 border border-stone-200 rounded-xl bg-stone-50 font-bold">
            <option value="目黑川櫻並木">目黑川櫻並木 (目黑區)</option>
            <option value="新宿御苑 (晚開八重櫻/綠櫻)">新宿御苑 (晚開八重櫻/綠櫻)</option>
            <option value="星巴克臻選® 東京烘焙工坊">星巴克臻選® 東京烘焙工坊 (中目黑)</option>
            <option value="隅田川花火大會">隅田川花火大會 (晴空塔水岸)</option>
            <option value="長岡花火大會 (鳳凰花火)">長岡花火大會 (信濃川水岸)</option>
            <option value="SHIBUYA SKY 展望台">SHIBUYA SKY 展望台</option>
          </select>
        </div>

        <div>
          <label class="font-bold text-stone-700 block mb-1">拍攝時間 (自動讀取 EXIF 模擬)：</label>
          <input type="datetime-local" id="upload-time" class="w-full p-2.5 border border-stone-200 rounded-xl bg-stone-50 font-bold text-stone-700" />
        </div>

        <div>
          <label class="font-bold text-stone-700 block mb-1">現況狀態標記：</label>
          <select id="upload-status" class="w-full p-2.5 border border-stone-200 rounded-xl bg-stone-50 font-bold">
            <option value="🌸 滿開無死角">🌸 滿開無死角 (100% 盛開)</option>
            <option value="🌺 八重櫻接力盛開中">🌺 八重櫻接力盛開中 (90%)</option>
            <option value="🎆 有料席視野極佳">🎆 有料席視野極佳・音效震撼</option>
            <option value="☕ 景觀露台需候位 20 分鐘">☕ 景觀露台需候位 20 分鐘</option>
          </select>
        </div>

        <div>
          <label class="font-bold text-stone-700 block mb-1">實況心得備註：</label>
          <input type="text" id="upload-comment" placeholder="例：現場人潮秩序良好，星巴克 4 樓露台整理券排隊約需 15 分鐘！" class="w-full p-2.5 border border-stone-200 rounded-xl font-bold" />
        </div>
      </div>

      <div class="pt-2">
        <button onclick="submitUGCReport()" class="w-full py-3 bg-theme-primary hover:bg-theme-primary/90 text-white font-black rounded-xl text-xs shadow-md transition">
          確認送出情報
        </button>
      </div>
    </div>
  </div>

  <!-- ================= 收藏清單口袋抽屜 (Bookmarks Drawer) ================= -->
  <div id="bookmark-drawer" class="fixed inset-y-0 right-0 z-50 w-full max-w-md bg-white shadow-2xl border-l border-theme transform translate-x-full transition-transform duration-300 flex flex-col">
    <div class="p-5 bg-theme-soft border-b border-theme flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-xl">❤️</span>
        <h3 class="text-sm sm:text-base font-black text-theme-text">我的清單・收藏 (<span id="drawer-count">0</span>)</h3>
      </div>
      <button onclick="toggleBookmarkDrawer()" class="text-stone-400 hover:text-stone-700 font-bold text-base">✕</button>
    </div>
    
    <div id="bookmark-items-container" class="flex-1 overflow-y-auto p-5 space-y-3.5">
      <!-- Rendered dynamically -->
    </div>
    
    <div class="p-5 bg-stone-50 border-t border-theme">
      <button onclick="clearAllBookmarks()" class="w-full py-2.5 bg-white border border-stone-200 text-stone-500 text-xs font-bold rounded-xl hover:text-rose-600 transition">
        清空所有收藏
      </button>
    </div>
  </div>

  <!-- ================= 網頁版和風精緻頁尾 (Pure Web Japanese Footer) ================= -->
  <footer class="mt-16 bg-white/95 backdrop-blur-md border-t border-theme py-12 transition-colors z-20 relative">
    <div class="max-w-[1540px] mx-auto px-4 sm:px-6 lg:px-8 xl:px-12">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8 pb-10 border-b border-theme/60">
        <!-- Col 1: Brand & Logo -->
        <div class="space-y-3.5 md:col-span-1">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-white to-amber-50 border border-theme shadow-sm flex items-center justify-center">
              <svg viewBox="0 0 40 40" class="w-7 h-7">
                <path d="M7 32 L20 10 L33 32 Z" fill="#94A3B8" />
                <path d="M15 18 L20 10 L25 18 L22 16 L20 18 L18 16 Z" fill="#FFFFFF" />
                <circle cx="28" cy="11" r="5" fill="#EF4444" opacity="0.85" />
              </svg>
            </div>
            <div>
              <h3 class="text-base font-black text-theme-text leading-tight">日旅報報</h3>
              <p class="text-[10px] text-theme-muted font-bold">全日本景點・旬況與和風地圖導覽</p>
            </div>
          </div>
          <p class="text-xs text-theme-muted leading-relaxed">
            專為網頁版現代旅人量身打造：以「全部景點」為骨幹，依據櫻花前線、萬發花火、粉雪雪場及秘湯時令即時聯動。提供旅人透明、免踩雷的日本旅遊即時情報。
          </p>
        </div>

        <!-- Col 2: 核心功能分類導覽 -->
        <div class="space-y-2.5">
          <h4 class="text-xs font-black text-theme-deep tracking-wider uppercase">🏮 主題即時速報</h4>
          <ul class="text-xs space-y-2 text-theme-muted font-medium">
            <li><a href="javascript:void(0)" onclick="selectCategory('spot')" class="hover:text-theme-primary transition">🏛️ 東京與全日本熱門景點</a></li>
            <li><a href="javascript:void(0)" onclick="selectCategory('flower')" class="hover:text-theme-primary transition">🌸 櫻花開花前線與晚開名所</a></li>
            <li><a href="javascript:void(0)" onclick="selectCategory('fireworks')" class="hover:text-theme-primary transition">🎆 Walkerplus 花火大會等級庫</a></li>
            <li><a href="javascript:void(0)" onclick="selectCategory('ski')" class="hover:text-theme-primary transition">⛷️ 日本雪場雪況與避雷指南</a></li>
            <li><a href="javascript:void(0)" onclick="selectCategory('onsen')" class="hover:text-theme-primary transition">♨️ 秘境溫泉與紅葉手沖咖啡</a></li>
          </ul>
        </div>

        <!-- Col 3: 資料源公開透明聲明 -->
        <div class="space-y-2.5">
          <h4 class="text-xs font-black text-theme-deep tracking-wider uppercase">📡 資料源與排程同步</h4>
          <ul class="text-xs space-y-2 text-theme-muted font-medium">
            <li class="flex items-center gap-2"><span>●</span> <span>花火：Walkerplus 日本全國花火數據庫</span></li>
            <li class="flex items-center gap-2"><span>●</span> <span>雪況：日本 SURF&SNOW 官方實時連線</span></li>
            <li class="flex items-center gap-2"><span>●</span> <span>櫻花：Weathernews (WNI) 標本木觀測</span></li>
            <li class="flex items-center gap-2"><span>●</span> <span>觀光：日本觀光振興協會 Open Data</span></li>
          </ul>
        </div>

        <!-- Col 4: 旅人分潤與版權 -->
        <div class="space-y-2.5">
          <h4 class="text-xs font-black text-theme-deep tracking-wider uppercase">⚖️ 旅人服務聲明</h4>
          <p class="text-xs text-theme-muted leading-relaxed">
            本站所有票券預訂與飯店查詢皆串聯 Klook (AID: 123436) 及 Agoda 官方特約合作通道。經由本站連結預訂不影響您的付款價格，並可確保獲得特約優惠。
          </p>
          <div class="pt-2 flex items-center gap-2">
            <span class="text-[11px] px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-bold border border-emerald-200">● 伺服器運作正常</span>
            <button onclick="window.scrollTo({top: 0, behavior: 'smooth'})" class="text-[11px] text-theme-primary hover:underline font-bold">
              ⬆️ 回到頂部
            </button>
          </div>
        </div>
      </div>

      <div class="pt-6 flex flex-col sm:flex-row items-center justify-between text-xs text-theme-muted gap-3">
        <p>© 2026 日旅報報 Japan Travel Express. 專為現代旅人設計之純網頁版響應式指南.</p>
        <div class="flex items-center gap-3">
          <span class="hover:text-theme-text cursor-pointer" onclick="toggleLanguage()">🌐 繁體中文 / English</span>
          <span>・</span>
          <span class="hover:text-theme-text cursor-pointer" onclick="toggleBookmarkDrawer()">❤️ 我的收藏 (<span id="footer-fav-count">0</span>)</span>
        </div>
      </div>
    </div>
  </footer>

  <!-- ================= 懸浮快捷動作 (回到頂部 ＆ 快速開啟收藏) ================= -->
  <div class="fixed bottom-6 right-6 z-40 flex flex-col gap-2.5 items-end">
    <button onclick="toggleBookmarkDrawer()" class="px-4 py-2.5 rounded-full bg-white/95 backdrop-blur-md border border-theme washi-shadow-lg text-theme-text hover:scale-105 active:scale-95 transition flex items-center gap-2 text-xs font-black" title="查看收藏清單">
      <span class="text-rose-500">❤️</span>
      <span class="hidden sm:inline">我的收藏</span>
      <span id="floating-fav-badge" class="bg-rose-500 text-white text-[10px] px-2 py-0.5 rounded-full font-bold">0</span>
    </button>
    <button onclick="window.scrollTo({top: 0, behavior: 'smooth'})" class="w-10 h-10 rounded-full bg-white/95 backdrop-blur-md border border-theme washi-shadow-lg text-theme-text hover:scale-105 active:scale-95 transition flex items-center justify-center text-xs font-bold shadow-md" title="回到頂部">
      ▲
    </button>
  </div>

  <!-- ================= 即時 API 串聯終端監控 Modal ================= -->
  <div id="api-sync-modal" class="fixed inset-0 z-50 bg-black/75 backdrop-blur-md hidden flex items-center justify-center p-4">
    <div class="bg-slate-950 text-white p-6 rounded-3xl max-w-md w-full shadow-2xl border border-slate-700 font-mono flex flex-col gap-3.5">
      <div class="flex items-center justify-between border-b border-slate-800 pb-3">
        <div class="flex items-center gap-2">
          <span class="w-3 h-3 rounded-full bg-rose-500 inline-block"></span>
          <span class="w-3 h-3 rounded-full bg-amber-500 inline-block"></span>
          <span class="w-3 h-3 rounded-full bg-emerald-500 inline-block"></span>
          <span class="text-xs font-bold text-slate-300 pl-1.5">Walkerplus / SURF&SNOW / WNI Live Gateway</span>
        </div>
        <button onclick="closeApiSyncModal()" class="text-slate-400 hover:text-white text-xs">✕</button>
      </div>

      <div class="text-xs text-slate-300 space-y-2 py-1 min-h-[160px]" id="api-sync-logs">
        <!-- Dynamic terminal logs injected via JS -->
      </div>

      <div class="pt-2 border-t border-slate-800 flex items-center justify-between">
        <span class="text-xs text-emerald-400 font-bold" id="api-sync-status-text">連線進度: 0%</span>
        <button onclick="closeApiSyncModal()" id="btn-api-sync-done" class="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold rounded-xl transition hidden">
          完成返回
        </button>
      </div>
    </div>
  </div>

HTML_HEAD_CODE

print "HTML Part 1 written successfully.\n";
close $fh;

