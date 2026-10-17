#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
use File::Copy qw(copy);
use File::Basename qw(dirname);
use FindBin qw($Bin);

my $target = "$Bin/app/index.html";
my $copy1 = "$Bin/../japan-go-app/app/index.html";
my $copy2 = "$Bin/japan_sakura_app_design_preview.html";

open my $fh, '>:utf8', $target or die "Cannot open $target: $!\n";

print $fh <<'HTML_HEAD_PART';
<!DOCTYPE html>
<html lang="zh-TW">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
  <title>日旅報報 | 全日本景點導覽・花季雪況・花火與高質感地圖</title>

  <!-- Tailwind CSS -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>

  <!-- Leaflet.js (100% Free Open-Source Interactive Map) -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;700;900&family=Plus+Jakarta+Sans:wght@400;600;800&family=Zen+Maru+Gothic:wght@400;500;700;900&display=swap" rel="stylesheet">

  <style>
    /* 核心主題變數 */
    :root {
      --theme-bg: #F8FAFC;
      --theme-card-bg: #FFFFFF;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #E2E8F0;
      --theme-text: #0F172A;
      --theme-muted: #64748B;
      --theme-badge-bg: #E0F2FE;
    }

    body.theme-spot {
      --theme-bg: #F8FAFC;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #CBD5E1;
      --theme-text: #0F172A;
      --theme-muted: #64748B;
      --theme-badge-bg: #E0F2FE;
    }

    body.theme-flower {
      --theme-bg: #FFF5F7;
      --theme-primary: #EE6A7C;
      --theme-primary-hover: #D94D61;
      --theme-soft: #FFE4E8;
      --theme-deep: #9F1239;
      --theme-border: #FBCFE8;
      --theme-text: #271217;
      --theme-muted: #88626A;
      --theme-badge-bg: #FFF0F3;
    }

    body.theme-fireworks {
      --theme-bg: #0B0F19;
      --theme-primary: #EC4899;
      --theme-primary-hover: #DB2777;
      --theme-soft: #1E293B;
      --theme-deep: #F43F5E;
      --theme-border: #334155;
      --theme-text: #F8FAFC;
      --theme-muted: #94A3B8;
      --theme-badge-bg: #1E293B;
    }

    body.theme-ski {
      --theme-bg: #F0F9FF;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #BAE6FD;
      --theme-text: #0F172A;
      --theme-muted: #64748B;
      --theme-badge-bg: #E0F2FE;
    }

    body.theme-onsen {
      --theme-bg: #FFFBEB;
      --theme-primary: #D97706;
      --theme-primary-hover: #B45309;
      --theme-soft: #FEF3C7;
      --theme-deep: #78350F;
      --theme-border: #FDE68A;
      --theme-text: #271808;
      --theme-muted: #785A3C;
      --theme-badge-bg: #FEF3C7;
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
    }

    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
      font-family: 'Zen Maru Gothic', 'Plus Jakarta Sans', 'Noto Sans TC', sans-serif;
    }

    body {
      background-color: var(--theme-bg);
      color: var(--theme-text);
      transition: background-color 0.35s ease, color 0.35s ease;
      overflow-x: hidden;
    }

    .border-theme { border-color: var(--theme-border); }
    .bg-theme-soft { background-color: var(--theme-soft); }
    .text-theme-primary { color: var(--theme-primary); }
    .bg-theme-primary { background-color: var(--theme-primary); }
    .text-theme-deep { color: var(--theme-deep); }
    .text-theme-muted { color: var(--theme-muted); }
    .text-theme-text { color: var(--theme-text); }

    .washi-shadow {
      box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.05), 0 2px 6px -1px rgba(0, 0, 0, 0.03);
    }
    .washi-shadow-lg {
      box-shadow: 0 10px 30px -4px rgba(0, 0, 0, 0.08), 0 4px 12px -2px rgba(0, 0, 0, 0.05);
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

    /* Leaflet 地圖美化 */
    .leaflet-container {
      font-family: 'Zen Maru Gothic', sans-serif !important;
      background-color: #F8FAFC !important;
    }

    .custom-map-icon {
      background: none;
      border: none;
    }

    @keyframes live-pulse {
      0% { transform: scale(0.95); opacity: 0.85; }
      50% { transform: scale(1.1); opacity: 1; filter: drop-shadow(0 0 6px rgba(238, 106, 124, 0.6)); }
      100% { transform: scale(0.95); opacity: 0.85; }
    }
    .map-badge-pulse {
      animation: live-pulse 2s infinite ease-in-out;
    }
  </style>
</head>
<body class="theme-spot min-h-screen flex flex-col relative pb-28 md:pb-16">

  <!-- Seasonal background particle canvas -->
  <canvas id="particle-canvas"></canvas>

  <!-- ================= 頂部 Header ================= -->
  <header class="sticky top-0 z-40 bg-white/94 backdrop-blur-md border-b border-theme transition-colors">
    <div class="max-w-6xl mx-auto px-4 py-2.5 flex items-center justify-between gap-3">
      
      <!-- Brand Logo with Mt. Fuji & Badge -->
      <div class="flex items-center gap-2.5 cursor-pointer" onclick="resetAllFilters()">
        <div class="relative w-11 h-11 rounded-2xl bg-gradient-to-br from-white to-sky-50 border border-theme shadow-sm flex items-center justify-center overflow-hidden flex-shrink-0">
          <svg viewBox="0 0 40 40" class="w-8 h-8">
            <path d="M7 32 L20 10 L33 32 Z" fill="#94A3B8" />
            <path d="M15 18 L20 10 L25 18 L22 16 L20 18 L18 16 Z" fill="#FFFFFF" />
            <circle cx="28" cy="11" r="5" fill="#EF4444" opacity="0.85" />
          </svg>
          <span id="brand-badge-icon" class="absolute bottom-0.5 right-0.5 text-xs">🏛️</span>
        </div>
        <div>
          <div class="flex items-center gap-1.5">
            <h1 id="i18n-brand-title" class="text-base font-black tracking-tight text-theme-text leading-tight">日旅報報</h1>
            <span id="i18n-badge-live" class="text-[10px] font-black px-2 py-0.5 rounded-full bg-theme-soft text-theme-primary border border-theme">
              2026 旬況版
            </span>
          </div>
          <p id="i18n-brand-sub" class="text-[10px] text-theme-muted font-medium">全日本景點導覽・花季雪況・花火與高質感地圖</p>
        </div>
      </div>

      <!-- 視圖切換 (📋 卡片速報 ⇄ 🗺️ 和風實況地圖) -->
      <div class="flex items-center bg-gray-100 p-1 rounded-2xl border border-theme">
        <button id="view-cards-btn" onclick="setViewMode('cards')" class="px-2.5 sm:px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex items-center gap-1">
          <span>📋</span> <span id="i18n-view-cards">卡片</span>
        </button>
        <button id="view-map-btn" onclick="setViewMode('map')" class="px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex items-center gap-1">
          <span>🗺️</span> <span id="i18n-view-map">和風地圖</span>
        </button>
      </div>

      <!-- 右側按鈕：語言切換 + 我的收藏愛心 -->
      <div class="flex items-center gap-2">
        <button onclick="toggleLanguage()" id="lang-toggle-btn" class="px-2.5 py-1.5 rounded-2xl bg-white border border-theme shadow-sm hover:scale-105 active:scale-95 transition flex items-center gap-1 text-xs font-black text-theme-deep flex-shrink-0" title="切換語言 / Switch Language">
          <span>🌐</span>
          <span id="lang-label">EN</span>
        </button>

        <button onclick="toggleBookmarkDrawer()" class="relative p-2 rounded-2xl bg-white border border-theme shadow-sm hover:scale-105 active:scale-95 transition flex-shrink-0" title="我的收藏清單 / Saved">
          <span class="text-base">❤️</span>
          <span id="bookmark-badge" class="absolute -top-1 -right-1 bg-rose-500 text-white text-[10px] font-black w-4 h-4 rounded-full flex items-center justify-center hidden">
            0
          </span>
        </button>
      </div>

    </div>

    <!-- ================= 一、頂部大地區（最直覺・預設選中 🗼 東京全部景點） ================= -->
    <div class="bg-gray-50/90 border-t border-theme/60 px-4 py-1.5">
      <div class="max-w-6xl mx-auto flex items-center justify-between gap-1 overflow-x-auto no-scrollbar" id="scope-selector-wrap">
        <button onclick="setScope('tokyo')" id="scope-tokyo-btn" class="scope-btn px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex-shrink-0 flex items-center gap-1">
          <span>🗼</span> <span id="i18n-scope-tokyo">東京全部景點</span>
        </button>
        <button onclick="setScope('all')" id="scope-all-btn" class="scope-btn px-3 py-1 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1">
          <span>🗾</span> <span id="i18n-scope-all">全日本</span>
        </button>
        <button onclick="setScope('kansai')" id="scope-kansai-btn" class="scope-btn px-3 py-1 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1">
          <span>🐙</span> <span id="i18n-scope-kansai">關西圈 (京阪神)</span>
        </button>
        <button onclick="setScope('hokkaido')" id="scope-hokkaido-btn" class="scope-btn px-3 py-1 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1">
          <span>❄️</span> <span id="i18n-scope-hokkaido">北海道</span>
        </button>
        <button onclick="setScope('tohoku')" id="scope-tohoku-btn" class="scope-btn px-3 py-1 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1">
          <span>🌲</span> <span id="i18n-scope-tohoku">東北</span>
        </button>
      </div>
    </div>

    <!-- ================= 二、大分類主按鈕（景點為主體・預設 🏛️ 全部景點） ================= -->
    <div class="bg-white/80 border-t border-theme/60 px-4 py-2">
      <div class="max-w-6xl mx-auto flex items-center gap-2 overflow-x-auto no-scrollbar" id="main-category-wrap">
        <!-- Rendered dynamically -->
      </div>
    </div>
  </header>

  <!-- ================= 三、情境動態展開樞紐（點什麼才出什麼，絕不打架） ================= -->
  <section class="max-w-6xl mx-auto w-full px-4 pt-3.5 z-10 relative space-y-2.5">

    <!-- 1. 【點全部景點時】動態展開：東京各區深度細分（澀谷、新宿、淺草、銀座、港區、秋葉原...） -->
    <div id="panel-district-filter" class="p-2.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-black text-theme-deep flex items-center gap-1.5" id="lbl-district-title">
          <span>📍</span> 東京各區地標深度篩選：
        </span>
        <span class="text-[10px] text-theme-muted font-bold" id="lbl-district-hint">精選代表性熱門打卡景點</span>
      </div>
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="district-buttons-wrap">
        <!-- Injected via JS -->
      </div>
    </div>

    <!-- 2. 【點花季名所時】動態展開：櫻花救援專題 ＋ 品種花色快篩 ＋ WNI 開花進度前線 -->
    <div id="panel-flower-filter" class="space-y-2.5 hidden">
      <!-- 櫻花救援專題 Banner -->
      <div id="sakura-rescue-banner" class="p-3 sm:p-3.5 rounded-2xl bg-gradient-to-r from-rose-50 via-pink-50 to-amber-50 border border-rose-200 washi-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2.5">
        <div class="flex items-center gap-2.5">
          <div class="w-9 h-9 rounded-xl bg-rose-500/10 flex items-center justify-center text-xl flex-shrink-0">
            🌺
          </div>
          <div>
            <div class="flex items-center gap-1.5">
              <span class="text-xs font-black text-rose-800" id="lbl-rescue-title">下週去怕染井吉野凋謝？「晚開八重櫻＆稀有綠櫻」接力盛開中！</span>
              <span class="text-[9px] bg-rose-600 text-white px-1.5 py-0.5 rounded font-black" id="lbl-rescue-badge">救援攻略</span>
            </div>
            <p class="text-[11px] text-rose-700/90 leading-tight mt-0.5" id="lbl-rescue-desc">
              染井吉野櫻落櫻後，新宿御苑、大阪造幣局等「關山櫻、御衣黃、普賢象」花期可一路延續至 4 月中下旬！
            </p>
          </div>
        </div>
        <button onclick="selectVariety('late')" class="px-3 py-1.5 bg-rose-600 hover:bg-rose-700 text-white text-xs font-black rounded-xl shadow-sm transition flex-shrink-0 flex items-center gap-1">
          <span>👀</span> <span id="lbl-rescue-btn">一鍵查看晚開接力名所</span>
        </button>
      </div>

      <!-- 櫻花品種多系與花色快篩 -->
      <div class="p-2.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs font-black text-theme-deep flex items-center gap-1.5">
            <span>🌸</span> <span id="lbl-variety-title">櫻花品種花色與接力時令快篩：</span>
          </span>
          <button onclick="openUploadModal()" class="text-[11px] font-black px-2.5 py-1 bg-theme-primary text-white rounded-lg flex items-center gap-1 shadow-sm hover:scale-105 active:scale-95 transition">
            <span>📷</span> <span id="lbl-upload-btn">上傳最新實況照</span>
          </button>
        </div>
        <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="sakura-variety-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>

      <!-- WNI 實時開花進度前線快篩 -->
      <div class="p-2.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs font-black text-rose-600 flex items-center gap-1.5" id="lbl-bloom-title">
            <span>🌸</span> Weathernews (WNI) 開花進度實時前線：
          </span>
          <span class="text-[10px] text-theme-muted font-bold">氣象廳標本木觀測同步</span>
        </div>
        <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="flower-bloom-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>
    </div>

    <!-- 3. 【點花火大會時】動態展開：發數規模（萬發/尺玉/水上/屋形船VIP）快篩 -->
    <div id="panel-fireworks-filter" class="p-2.5 bg-slate-900/90 text-white border border-slate-700 rounded-2xl washi-shadow hidden">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-black text-pink-400 flex items-center gap-1.5" id="lbl-fw-filter-title">
          <span>🎆</span> Walkerplus 花火大會規格與觀賞席：
        </span>
        <span class="text-[10px] text-slate-400 font-bold">主辦單位 2026 最新日程</span>
      </div>
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="fireworks-buttons-wrap">
        <!-- Injected via JS -->
      </div>
    </div>

    <!-- 4. 【點滑雪雪場時】動態展開：雪區篩選 ＋ 新手寬坡/進階長紅線/老手粉雪分級避雷 -->
    <div id="panel-ski-filter" class="space-y-2.5 hidden">
      <!-- 雪區大按鈕 -->
      <div class="p-2.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs font-black text-theme-deep flex items-center gap-1.5">
            <span>📍</span> 全日本滑雪勝地分區：
          </span>
          <span class="text-[10px] text-theme-muted font-bold">即時同步日本 SURF&SNOW</span>
        </div>
        <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="ski-region-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>

      <!-- 避雷分級面板 -->
      <div class="p-2.5 bg-white/95 border border-theme rounded-2xl washi-shadow">
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs font-black text-theme-deep flex items-center gap-1.5" id="lbl-ski-filter-title">
            <span>🏂</span> 滑雪分級避雷與出行情境（解決新手誤闖黑線）：
          </span>
        </div>
        <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="ski-skill-buttons-wrap">
          <!-- Injected via JS -->
        </div>
      </div>
    </div>

    <!-- 即時速報摘要列 ＋ 景點/咖啡/討論 次切換 ＋ API 同步按鈕 -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between text-xs text-theme-muted px-1 border-b border-theme/60 pb-2.5 gap-2">
      <div id="filter-summary-text" class="flex items-center gap-1.5 font-medium flex-wrap">
        <!-- Injected via JavaScript -->
      </div>

      <div class="flex items-center gap-2 flex-wrap">
        <!-- 子視圖切換 (景點名所 ⇄ 櫻花咖啡館 ⇄ 實況討論區) -->
        <div class="flex items-center bg-gray-100 p-0.5 rounded-xl border border-gray-200" id="subview-toggle-bar">
          <button onclick="setSubView('spots')" id="subview-spots-btn" class="px-2 py-0.5 rounded-lg text-[11px] font-black bg-white text-theme-primary shadow-xs">
            🏛️ <span id="i18n-subview-spots">全部列表</span>
          </button>
          <button onclick="setSubView('cafes')" id="subview-cafes-btn" class="px-2 py-0.5 rounded-lg text-[11px] font-bold text-gray-500 hover:text-gray-900">
            ☕ <span id="i18n-subview-cafes">景觀咖啡</span>
          </button>
          <button onclick="setSubView('intel')" id="subview-intel-btn" class="px-2 py-0.5 rounded-lg text-[11px] font-bold text-gray-500 hover:text-gray-900 flex items-center gap-1">
            <span>💬</span> <span id="i18n-subview-intel">實況討論</span>
          </button>
        </div>

        <button onclick="triggerLiveApiSync()" id="btn-sync-api" class="px-2.5 py-1 bg-white hover:bg-gray-50 border border-theme text-theme-primary font-bold rounded-xl shadow-sm text-xs flex items-center gap-1 hover:scale-105 active:scale-95 transition" title="立即串聯更新最新數據">
          <span id="sync-icon">🔄</span>
          <span id="i18n-btn-sync">即時串聯刷新</span>
        </button>
      </div>
    </div>
  </section>

  <!-- ================= 主內容區 (卡片列表 VS 和風實況地圖) ================= -->
  <main class="max-w-6xl mx-auto w-full px-4 py-4 flex-1 z-10 relative">

    <!-- 1. 卡片檢視容器 (含名所列表 / 景觀咖啡 / 實況牆) -->
    <div id="cards-view-wrap">
      
      <!-- 視圖 1: 景點與雪場卡片列表 -->
      <div id="spots-view">
        <div id="resorts-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          <!-- Injected via JavaScript -->
        </div>

        <!-- 空狀態提示 -->
        <div id="empty-state" class="hidden text-center py-20 bg-white/70 rounded-3xl border border-theme washi-shadow p-8">
          <div class="text-5xl mb-2">⛩️</div>
          <h3 id="i18n-empty-title" class="text-sm font-bold text-theme-text">目前篩選條件下尚無符合的名所或情報</h3>
          <p id="i18n-empty-sub" class="text-xs text-theme-muted mt-1">試著切換至「全部」或更換區域看看！</p>
          <button onclick="resetAllFilters()" id="i18n-empty-btn" class="mt-4 px-4 py-1.5 bg-theme-primary text-white text-xs font-bold rounded-xl shadow-sm">
            重設所有篩選
          </button>
        </div>
      </div>

      <!-- 視圖 2: 景觀咖啡廳指南 (Cafe Guide) -->
      <div id="cafes-view" class="hidden space-y-4">
        <div class="p-4 bg-gradient-to-br from-amber-50/90 via-white to-pink-50/60 rounded-3xl border border-amber-200/80 washi-shadow">
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
            <div>
              <h2 class="text-base font-black text-amber-950 flex items-center gap-1.5" id="lbl-cafe-h-title">
                <span>☕</span> 日本水岸・櫻花景觀咖啡廳指南
              </h2>
              <p class="text-xs text-amber-800/80 mt-0.5" id="lbl-cafe-h-desc">
                川畔第一排露台席、窗景與鐵道櫻花同框，附旅人真實拍攝時間戳與排隊攻略
              </p>
            </div>
            <button onclick="openUploadModal('cafe')" class="px-3 py-1.5 bg-amber-800 text-white text-xs font-black rounded-xl shadow hover:bg-amber-900 transition flex items-center gap-1 flex-shrink-0">
              <span>📷</span> <span id="lbl-cafe-report-btn">回報咖啡廳花況</span>
            </button>
          </div>
        </div>

        <div id="cafes-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          <!-- Injected via JavaScript -->
        </div>
      </div>

      <!-- 視圖 3: 讀者即時情報與花況實況牆 (Live Intel & Community) -->
      <div id="intel-view" class="hidden space-y-4">
        <div class="p-4 bg-white rounded-3xl border border-theme washi-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
          <div>
            <h2 class="text-base font-black text-theme-text flex items-center gap-1.5" id="lbl-intel-h-title">
              <span>💬</span> 讀者即時目擊情報牆
            </h2>
            <p class="text-xs text-theme-muted mt-0.5" id="lbl-intel-h-desc">
              旅人第一手 EXIF 拍攝時間認證，拒絕過期舊照！
            </p>
          </div>
          <button onclick="openUploadModal()" class="px-3 py-1.5 bg-theme-primary text-white text-xs font-black rounded-xl shadow-sm hover:scale-105 transition flex items-center gap-1 flex-shrink-0">
            <span>✍️</span> <span id="lbl-intel-submit-btn">我也要提供情報</span>
          </button>
        </div>

        <div id="intel-stream" class="space-y-3">
          <!-- Injected via JavaScript -->
        </div>
      </div>

    </div>

    <!-- 2. 【全新 Leaflet ＋ CARTO Voyager 和風高質感地圖】（100% 免費・可縮放・帶活體圖標與花季前線範圍） -->
    <div id="map-view-wrap" class="hidden">
      <div class="bg-white rounded-3xl overflow-hidden border border-theme washi-shadow-lg flex flex-col h-[78vh]">
        <!-- 地圖頂部控制條 -->
        <div class="p-3 bg-gray-50/95 border-b border-theme flex items-center justify-between gap-2 flex-wrap z-10">
          <div class="flex items-center gap-2">
            <span class="text-base">🗾</span>
            <span id="i18n-map-title" class="text-xs font-black text-theme-deep">全日本實時地圖 (CARTO 和風底圖)</span>
            <!-- 櫻花開花前線範圍切換開關 -->
            <button onclick="toggleSakuraFrontlineLayer()" id="btn-toggle-frontline" class="px-2 py-0.5 rounded-full bg-rose-100 text-rose-700 hover:bg-rose-200 text-[10px] font-black border border-rose-300 transition flex items-center gap-1">
              <span>🌸</span> <span>櫻花前線範圍：開</span>
            </button>
          </div>

          <!-- 一鍵定位大分區 -->
          <div class="flex items-center gap-1 text-[11px]">
            <button onclick="jumpMapTo('tokyo')" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">🗼 東京</button>
            <button onclick="jumpMapTo('kansai')" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">🐙 關西</button>
            <button onclick="jumpMapTo('yuzawa')" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">⛷️ 湯澤雪區</button>
            <button onclick="jumpMapTo('hokkaido')" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">❄️ 北海道</button>
            <button onclick="jumpMapTo('all')" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">🗾 全日本</button>
          </div>
        </div>

        <!-- Leaflet Map Canvas Container -->
        <div id="leaflet-map-container" class="relative flex-1 w-full h-full"></div>
      </div>
    </div>
  </main>

  <!-- ================= 景點 / 雪場詳細抽屜 (Bottom Sheet Modal) ================= -->
  <div id="detail-sheet" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden opacity-0 transition-opacity duration-300 flex items-end sm:items-center justify-center p-0 sm:p-4" onclick="closeDetailSheet(event)">
    <div class="bg-white w-full sm:max-w-xl max-h-[90vh] rounded-t-3xl sm:rounded-3xl overflow-hidden shadow-2xl flex flex-col transform translate-y-8 transition-transform duration-300" onclick="event.stopPropagation()">
      
      <!-- Drawer Top Header Image -->
      <div class="relative h-56 w-full bg-gray-100 flex-shrink-0">
        <img id="sheet-img" src="" alt="" class="w-full h-full object-cover" />
        <button onclick="closeDetailSheet()" class="absolute top-4 right-4 w-8 h-8 rounded-full bg-black/60 text-white font-bold flex items-center justify-center hover:bg-black/80 transition">
          ✕
        </button>
        <div class="absolute bottom-3 left-4 right-4 flex items-center justify-between">
          <span id="sheet-region-badge" class="px-2.5 py-1 rounded-lg bg-black/60 backdrop-blur-md text-white text-[11px] font-bold">
            地區標籤
          </span>
          <span id="sheet-status-badge" class="px-3 py-1 rounded-full bg-white/95 text-theme-primary text-xs font-black shadow-md">
            狀態標籤
          </span>
        </div>
      </div>

      <!-- 📸 多圖切換縮圖輪播列 (Wikimedia Commons / Unsplash API 高清實拍圖庫) -->
      <div class="px-5 py-2 bg-gray-50 border-b border-gray-100 flex items-center justify-between gap-2 overflow-x-auto no-scrollbar">
        <div class="flex items-center gap-1.5 flex-1 overflow-x-auto no-scrollbar" id="sheet-gallery-bar">
          <!-- Injected via JavaScript -->
        </div>
        <span class="text-[9px] font-bold text-gray-400 flex items-center gap-1 flex-shrink-0">
          <span>📷</span> <span id="sheet-photo-license">Wikimedia / Unsplash</span>
        </span>
      </div>

      <!-- Drawer Body Content -->
      <div class="p-5 overflow-y-auto space-y-4 flex-1">
        <div>
          <div class="flex items-center gap-2 mb-1 flex-wrap">
            <span id="sheet-category-badge" class="px-2 py-0.5 rounded-md bg-theme-soft text-theme-primary text-[10px] font-bold">景點類別</span>
            <span id="sheet-variety-badge" class="px-2 py-0.5 rounded-md bg-pink-100 text-pink-800 text-[10px] font-bold hidden">品種標記</span>
            <span id="sheet-opendata-badge" class="px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-700 text-[10px] font-bold">Japan Open Data Verified</span>
          </div>
          <h2 id="sheet-title" class="text-xl font-black text-theme-text">名所/景點名稱</h2>
          <p id="sheet-subtitle" class="text-xs font-bold text-theme-primary mt-0.5">副標特色</p>
          <p id="sheet-desc" class="text-xs text-gray-600 mt-2 leading-relaxed">介紹說明</p>
        </div>

        <!-- 旬況 / 雪況實況儀表盤 -->
        <div class="grid grid-cols-3 gap-2 p-3 bg-theme-soft/50 border border-theme rounded-2xl text-center">
          <div>
            <span id="sheet-metric-label-1" class="text-[10px] text-theme-muted font-bold block">目前指標</span>
            <span id="sheet-depth" class="text-sm font-black text-theme-deep">狀態值</span>
          </div>
          <div>
            <span id="sheet-metric-label-2" class="text-[10px] text-theme-muted font-bold block">觀賞/雪質</span>
            <span id="sheet-quality" class="text-sm font-black text-theme-deep">品質</span>
          </div>
          <div>
            <span id="sheet-metric-label-3" class="text-[10px] text-theme-muted font-bold block">運作/點燈</span>
            <span id="sheet-lifts" class="text-sm font-black text-theme-deep">正常營業</span>
          </div>
        </div>

        <!-- 開花進度條 或 雪道難易度條 -->
        <div id="sheet-progress-wrap" class="p-3 bg-gray-50 border border-gray-100 rounded-2xl">
          <div class="flex justify-between text-xs font-bold text-gray-700 mb-1.5">
            <span id="sheet-progress-title">進度與指標等級</span>
            <span id="sheet-slopes-text" class="text-theme-muted text-[11px]">80% 滿開倒數</span>
          </div>
          <div class="flex h-2.5 rounded-full overflow-hidden bg-gray-200">
            <div id="sheet-slope-green" class="bg-emerald-500" style="width: 50%;"></div>
            <div id="sheet-slope-red" class="bg-rose-500" style="width: 35%;"></div>
            <div id="sheet-slope-black" class="bg-slate-800" style="width: 15%;"></div>
          </div>
          <div id="sheet-slopes-legend" class="flex justify-between text-[10px] text-gray-400 mt-1">
            <span class="text-emerald-700 font-bold">🟢 初級 (緩坡/魔毯)</span>
            <span class="text-rose-700 font-bold">🔴 中級 (巡航)</span>
            <span class="text-slate-700 font-bold">⚫ 高級 (黑線/野雪)</span>
          </div>
        </div>

        <!-- 景點關聯咖啡廳專屬區塊 -->
        <div id="sheet-cafe-preview" class="p-3.5 rounded-2xl bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 text-xs hidden">
          <div class="flex items-center justify-between mb-1.5">
            <span class="font-black text-amber-900 flex items-center gap-1.5">
              <span>☕</span> <span id="sheet-cafe-preview-title">沿岸櫻花景觀咖啡廳特推：</span>
            </span>
            <button onclick="setSubView('cafes'); closeDetailSheet();" class="text-[10px] text-amber-700 font-bold underline">
              查看全部 3 間 ➔
            </button>
          </div>
          <p id="sheet-cafe-preview-text" class="text-amber-800 text-[11px] leading-relaxed">
            推薦「星巴克臻選® 東京烘焙工坊」4 樓川畔露台席或「ONIBUS COFFEE」窗景電車同框！
          </p>
        </div>

        <!-- 高客單價專屬預約卡 (滑雪中文教練 / 花季包車一日遊 / 煙火屋形船) -->
        <div id="sheet-highvalue-card" class="p-3.5 rounded-2xl bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200 text-xs">
          <div class="flex items-center gap-1.5 font-black text-emerald-900 mb-1">
            <span id="sheet-highvalue-icon">⛷️</span>
            <span id="sheet-highvalue-title">專屬中文滑雪教練特約預約：</span>
          </div>
          <p id="sheet-highvalue-desc" class="text-emerald-800 leading-relaxed text-[11px]">
            全中文雙板/單板教練，含專業教學攝影紀錄，提供小班制與私人 1 對 1。
          </p>
        </div>

        <!-- 交通路線 -->
        <div class="p-3 bg-gray-50 rounded-2xl border border-gray-100 text-xs">
          <div class="flex items-center justify-between mb-1">
            <span id="i18n-transit-title" class="text-theme-muted text-[11px] font-bold block">🚇 公共交通指南 (ODPT 連線)</span>
            <button onclick="openExternalRoute()" class="text-[10px] text-blue-600 hover:underline font-bold flex items-center gap-0.5">
              <span>📍</span> <span id="i18n-transit-nav">導航路線</span>
            </button>
          </div>
          <p id="sheet-transit" class="font-bold text-gray-800">地鐵與接駁路線</p>
        </div>

        <!-- 📊 即時底層 API 數據溯源與技術檢視 (Raw API Inspector) -->
        <div class="p-3 bg-slate-900 text-slate-100 rounded-2xl border border-slate-700 text-xs">
          <div class="flex items-center justify-between cursor-pointer" onclick="toggleApiRawInspector()">
            <div class="flex items-center gap-1.5 font-mono font-bold text-[11px] text-emerald-400">
              <span class="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
              <span>API 數據溯源 (SURF&SNOW / WNI / Wiki)</span>
            </div>
            <span id="api-raw-toggle-arrow" class="text-[10px] text-slate-400 hover:text-white font-mono">▼ 檢視 JSON</span>
          </div>
          <div id="api-raw-content" class="mt-2.5 hidden">
            <pre class="bg-black/70 p-2.5 rounded-xl font-mono text-[10px] text-emerald-300 overflow-x-auto leading-relaxed border border-slate-800" id="sheet-api-json"></pre>
          </div>
        </div>
      </div>

      <!-- Drawer 底部動態導購按鈕組 (滑雪三大按鈕 VS 花季三大按鈕) -->
      <div id="sheet-action-footer" class="p-4 bg-gray-50 border-t border-theme/80 space-y-2">
        <!-- Injected via JavaScript -->
      </div>

    </div>
  </div>

  <!-- ================= 互動 Modal 2: 旅人即時實況照上傳 (UGC Modal) ================= -->
  <div id="upload-modal" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-3xl max-w-md w-full p-5 shadow-2xl border border-theme space-y-3.5">
      <div class="flex items-center justify-between border-b border-gray-100 pb-2">
        <div class="flex items-center gap-1.5">
          <span class="text-lg">📷</span>
          <h3 class="text-sm font-black text-gray-900" id="lbl-upload-modal-title">回報最新實況照 (附拍攝時間)</h3>
        </div>
        <button onclick="closeUploadModal()" class="text-gray-400 hover:text-gray-700 font-bold text-sm">✕</button>
      </div>

      <!-- Upload Form -->
      <div class="space-y-2.5 text-xs">
        <div>
          <label class="font-bold text-gray-700 block mb-1">選擇名所或景點：</label>
          <select id="upload-spot-select" class="w-full p-2 border border-gray-200 rounded-xl bg-gray-50 font-bold">
            <option value="目黑川櫻並木">目黑川櫻並木 (目黑區)</option>
            <option value="新宿御苑 (晚開品種接力)">新宿御苑 (晚開八重櫻/綠櫻)</option>
            <option value="星巴克臻選® 東京烘焙工坊">星巴克臻選® 東京烘焙工坊</option>
            <option value="SHIBUYA SKY 展望台">SHIBUYA SKY 展望台</option>
            <option value="東京鐵塔 TOKYO TOWER">東京鐵塔 TOKYO TOWER</option>
            <option value="淺草寺 ＆ 仲見世通">淺草寺 ＆ 仲見世通</option>
          </select>
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1">拍攝時間 (自動讀取 EXIF 模擬)：</label>
          <input type="datetime-local" id="upload-time" class="w-full p-2 border border-gray-200 rounded-xl bg-gray-50 font-bold text-gray-700" />
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1">現況狀態標記：</label>
          <select id="upload-status" class="w-full p-2 border border-gray-200 rounded-xl bg-gray-50 font-bold">
            <option value="🌸 滿開無死角">🌸 滿開無死角 (100% 盛開)</option>
            <option value="🌺 八重櫻接力盛開中">🌺 八重櫻接力盛開中 (90%)</option>
            <option value="🍃 開始落櫻吹雪">🍃 開始落櫻吹雪 (花筏出現)</option>
            <option value="✨ 人潮適中，體驗極佳">✨ 人潮適中，體驗極佳</option>
            <option value="☕ 咖啡廳露台席開放中">☕ 咖啡廳露台席開放中</option>
          </select>
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1">精選實拍照預覽：</label>
          <div class="grid grid-cols-3 gap-2">
            <img src="https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=400&q=80" class="h-16 w-full object-cover rounded-xl border-2 border-theme-primary cursor-pointer" onclick="selectSampleImg(this)" />
            <img src="https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=400&q=80" class="h-16 w-full object-cover rounded-xl border border-gray-200 cursor-pointer opacity-70 hover:opacity-100" onclick="selectSampleImg(this)" />
            <img src="https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=400&q=80" class="h-16 w-full object-cover rounded-xl border border-gray-200 cursor-pointer opacity-70 hover:opacity-100" onclick="selectSampleImg(this)" />
          </div>
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1">實況心得備註：</label>
          <input type="text" id="upload-comment" placeholder="例：目黑川今日天氣極佳，河面已有薄薄花筏～" class="w-full p-2 border border-gray-200 rounded-xl font-bold" />
        </div>
      </div>

      <div class="pt-2">
        <button onclick="submitUGCReport()" class="w-full py-2.5 bg-theme-primary hover:bg-theme-primary/90 text-white font-black rounded-xl text-xs shadow-md transition">
          確認送出情報
        </button>
      </div>
    </div>
  </div>

  <!-- ================= 收藏清單口袋抽屜 (Bookmarks Drawer) ================= -->
  <div id="bookmark-drawer" class="fixed inset-y-0 right-0 z-50 w-full max-w-sm bg-white shadow-2xl border-l border-theme transform translate-x-full transition-transform duration-300 flex flex-col">
    <div class="p-4 bg-theme-soft border-b border-theme flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-xl">❤️</span>
        <h3 class="text-sm font-black text-theme-text"><span id="i18n-fav-title">我的清單・收藏</span> (<span id="drawer-count">0</span>)</h3>
      </div>
      <button onclick="toggleBookmarkDrawer()" class="text-gray-400 hover:text-gray-700 font-bold text-sm">✕</button>
    </div>
    
    <div id="bookmark-items-container" class="flex-1 overflow-y-auto p-4 space-y-3">
      <!-- Rendered dynamically -->
    </div>
    
    <div class="p-4 bg-gray-50 border-t border-theme">
      <button onclick="clearAllBookmarks()" id="i18n-clear-fav-btn" class="w-full py-2 bg-white border border-gray-200 text-gray-500 text-xs font-bold rounded-xl hover:text-red-500 transition">
        清空所有收藏
      </button>
    </div>
  </div>

  <!-- ================= 底部 App 快速導航欄 (TabBar) ================= -->
  <nav class="fixed bottom-0 inset-x-0 z-40 bg-white/95 backdrop-blur-md border-t border-theme flex items-center justify-around py-2">
    <button onclick="selectCategory('spot')" id="tab-btn-spots" class="flex flex-col items-center text-theme-primary">
      <span class="text-lg">🏛️</span>
      <span class="text-[10px] font-bold mt-0.5">全部景點</span>
    </button>
    <button onclick="selectCategory('flower')" id="tab-btn-flower" class="flex flex-col items-center text-gray-400 hover:text-theme-primary">
      <span class="text-lg">🌸</span>
      <span class="text-[10px] font-bold mt-0.5">花季名所</span>
    </button>
    <button onclick="selectCategory('fireworks')" id="tab-btn-fw" class="flex flex-col items-center text-gray-400 hover:text-theme-primary">
      <span class="text-lg">🎆</span>
      <span class="text-[10px] font-bold mt-0.5">花火大會</span>
    </button>
    <button onclick="selectCategory('ski')" id="tab-btn-ski" class="flex flex-col items-center text-gray-400 hover:text-theme-primary">
      <span class="text-lg">⛷️</span>
      <span class="text-[10px] font-bold mt-0.5">滑雪雪場</span>
    </button>
    <button onclick="toggleBookmarkDrawer()" class="flex flex-col items-center text-gray-400 hover:text-theme-primary relative">
      <span class="text-lg">❤️</span>
      <span class="text-[10px] font-bold mt-0.5">我的收藏</span>
    </button>
  </nav>

  <!-- ================= 即時 API 串聯終端監控 Modal ================= -->
  <div id="api-sync-modal" class="fixed inset-0 z-50 bg-black/75 backdrop-blur-md hidden flex items-center justify-center p-4">
    <div class="bg-slate-950 text-white p-5 rounded-3xl max-w-md w-full shadow-2xl border border-slate-700 font-mono flex flex-col gap-3">
      <div class="flex items-center justify-between border-b border-slate-800 pb-2.5">
        <div class="flex items-center gap-2">
          <span class="w-3 h-3 rounded-full bg-rose-500 inline-block"></span>
          <span class="w-3 h-3 rounded-full bg-amber-500 inline-block"></span>
          <span class="w-3 h-3 rounded-full bg-emerald-500 inline-block"></span>
          <span class="text-xs font-bold text-slate-300 pl-1.5">Live API Gateway Terminal</span>
        </div>
        <button onclick="closeApiSyncModal()" class="text-slate-400 hover:text-white text-xs">✕</button>
      </div>

      <div class="text-[11px] text-slate-300 space-y-1.5 py-1 min-h-[160px]" id="api-sync-logs">
        <!-- Dynamic terminal logs injected via JS -->
      </div>

      <div class="pt-2 border-t border-slate-800 flex items-center justify-between">
        <span class="text-[10px] text-emerald-400 font-bold" id="api-sync-status-text">連線進度: 0%</span>
        <button onclick="closeApiSyncModal()" id="btn-api-sync-done" class="px-3 py-1 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold rounded-xl transition hidden">
          完成返回
        </button>
      </div>
    </div>
  </div>

HTML_HEAD_PART

print "HTML Head written\n";
close $fh;

