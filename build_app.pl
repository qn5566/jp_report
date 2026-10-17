#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
use File::Copy qw(copy);
use File::Basename qw(dirname);
use FindBin qw($Bin);

my $output_file = "$Bin/app/index.html";
my $copy1 = "$Bin/../japan-go-app/app/index.html";
my $copy2 = "$Bin/japan_sakura_app_design_preview.html";

open my $fh, '>:utf8', $output_file or die "Cannot write to $output_file: $!\n";

print $fh <<'HTML_PART1';
<!DOCTYPE html>
<html lang="zh-TW">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
  <title>日旅報報 | 全日本四季花季・滑雪避雷・櫻花咖啡與即時地圖 (中英雙語版)</title>

  <!-- Tailwind CSS -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>

  <!-- Google Fonts: Zen Maru Gothic & Noto Sans TC / Plus Jakarta Sans -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;700;900&family=Plus+Jakarta+Sans:wght@400;600;800&family=Zen+Maru+Gothic:wght@400;500;700;900&display=swap" rel="stylesheet">

  <style>
    /* CSS Season Theme Variables */
    :root {
      --theme-bg: #F0F9FF;
      --theme-card-bg: #FFFFFF;
      --theme-primary: #0284C7;
      --theme-primary-hover: #0369A1;
      --theme-soft: #E0F2FE;
      --theme-deep: #0C4A6E;
      --theme-border: #BAE6FD;
      --theme-text: #0F172A;
      --theme-muted: #64748B;
      --theme-badge-bg: #E0F2FE;
    }

    body.theme-snow {
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

    body.theme-sakura {
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
      --theme-bg: #0F172A;
      --theme-primary: #EC4899;
      --theme-primary-hover: #DB2777;
      --theme-soft: #1E293B;
      --theme-deep: #F43F5E;
      --theme-border: #334155;
      --theme-text: #F8FAFC;
      --theme-muted: #94A3B8;
      --theme-badge-bg: #1E293B;
    }

    body.theme-momiji {
      --theme-bg: #FFF7ED;
      --theme-primary: #EA580C;
      --theme-primary-hover: #C2410C;
      --theme-soft: #FFEDD5;
      --theme-deep: #7C2D12;
      --theme-border: #FED7AA;
      --theme-text: #2A150D;
      --theme-muted: #8C6250;
      --theme-badge-bg: #FFF2E8;
    }

    body.theme-ginkgo {
      --theme-bg: #FEFCE8;
      --theme-primary: #CA8A04;
      --theme-primary-hover: #A16207;
      --theme-soft: #FEF9C3;
      --theme-deep: #713F12;
      --theme-border: #FEF08A;
      --theme-text: #291E0A;
      --theme-muted: #85724B;
      --theme-badge-bg: #FFFBEB;
    }

    body.theme-wisteria {
      --theme-bg: #FAF5FF;
      --theme-primary: #8B5CF6;
      --theme-primary-hover: #7C3AED;
      --theme-soft: #F3E8FF;
      --theme-deep: #581C87;
      --theme-border: #E9D5FF;
      --theme-text: #2E1065;
      --theme-muted: #7E639B;
      --theme-badge-bg: #F5EEFD;
    }

    body.theme-nemophila {
      --theme-bg: #F0FDFA;
      --theme-primary: #0D9488;
      --theme-primary-hover: #0F766E;
      --theme-soft: #CCFBF1;
      --theme-deep: #134E4A;
      --theme-border: #99F6E4;
      --theme-text: #042F2E;
      --theme-muted: #4F7875;
      --theme-badge-bg: #E6FFFA;
    }

    body.theme-shibazakura {
      --theme-bg: #FFF1F2;
      --theme-primary: #E11D48;
      --theme-primary-hover: #BE123C;
      --theme-soft: #FFE4E6;
      --theme-deep: #881337;
      --theme-border: #FECDD3;
      --theme-text: #290812;
      --theme-muted: #8A5565;
      --theme-badge-bg: #FFF0F2;
    }

    * {
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
      font-family: 'Zen Maru Gothic', 'Plus Jakarta Sans', 'Noto Sans TC', sans-serif;
    }

    body {
      background-color: var(--theme-bg);
      color: var(--theme-text);
      transition: background-color 0.4s ease, color 0.4s ease;
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

    @keyframes pin-pulse {
      0% { transform: scale(0.95); opacity: 0.8; }
      50% { transform: scale(1.15); opacity: 1; }
      100% { transform: scale(0.95); opacity: 0.8; }
    }
    .map-pin-pulse {
      animation: pin-pulse 2s infinite ease-in-out;
    }
  </style>
</head>
<body class="theme-snow min-h-screen flex flex-col relative pb-28 md:pb-16">

  <!-- Seasonal particle background -->
  <canvas id="particle-canvas"></canvas>

  <!-- ================= 頂部 Header ================= -->
  <header class="sticky top-0 z-40 bg-white/92 backdrop-blur-md border-b border-theme transition-colors">
    <div class="max-w-6xl mx-auto px-4 py-2.5 flex items-center justify-between gap-3">
      
      <!-- Brand Logo with Mt. Fuji & Seasonal Badge -->
      <div class="flex items-center gap-2.5 cursor-pointer" onclick="resetAllFilters()">
        <div class="relative w-11 h-11 rounded-2xl bg-gradient-to-br from-white to-gray-50 border border-theme shadow-sm flex items-center justify-center overflow-hidden flex-shrink-0">
          <svg viewBox="0 0 40 40" class="w-8 h-8">
            <path d="M7 32 L20 10 L33 32 Z" fill="#94A3B8" />
            <path d="M15 18 L20 10 L25 18 L22 16 L20 18 L18 16 Z" fill="#FFFFFF" />
            <circle cx="28" cy="11" r="5" fill="#EF4444" opacity="0.85" />
          </svg>
          <span id="brand-badge-icon" class="absolute bottom-0.5 right-0.5 text-xs">❄️</span>
        </div>
        <div>
          <div class="flex items-center gap-1.5">
            <h1 id="i18n-brand-title" class="text-base font-black tracking-tight text-theme-text leading-tight">日旅報報</h1>
            <span id="i18n-badge-live" class="text-[10px] font-black px-2 py-0.5 rounded-full bg-theme-soft text-theme-primary border border-theme">
              速報版
            </span>
          </div>
          <p id="i18n-brand-sub" class="text-[10px] text-theme-muted font-medium">全日本花季・滑雪・櫻花咖啡與地圖</p>
        </div>
      </div>

      <!-- 中間快速視圖切換器 (📋 卡片速報 ⇄ 🗺️ 原生地圖) -->
      <div class="flex items-center bg-gray-100 p-1 rounded-2xl border border-theme">
        <button id="view-cards-btn" onclick="setViewMode('cards')" class="px-2.5 sm:px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex items-center gap-1">
          <span>📋</span> <span id="i18n-view-cards">卡片</span>
        </button>
        <button id="view-map-btn" onclick="setViewMode('map')" class="px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex items-center gap-1">
          <span>🗺️</span> <span id="i18n-view-map">地圖</span>
        </button>
      </div>

      <!-- 右側按鈕組：Scope (桌機) + 語系切換 (🌐 中/EN) + 收藏愛心 -->
      <div class="flex items-center gap-2">
        <!-- 語系切換器 (一鍵切換 繁體中文 ⇄ 100% ENGLISH) -->
        <button onclick="toggleLanguage()" id="lang-toggle-btn" class="px-2.5 py-1.5 rounded-2xl bg-white border border-theme shadow-sm hover:scale-105 active:scale-95 transition flex items-center gap-1 text-xs font-black text-theme-deep flex-shrink-0" title="切換語言 / Switch Language">
          <span>🌐</span>
          <span id="lang-label">EN</span>
        </button>

        <div class="bg-gray-100/90 p-1 rounded-2xl flex items-center border border-theme overflow-x-auto no-scrollbar hidden md:flex">
          <button id="scope-all-btn" onclick="setScope('all')" class="px-2.5 sm:px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex-shrink-0">
            🗾 <span id="i18n-scope-all">全日本</span>
          </button>
          <button id="scope-tokyo-btn" onclick="setScope('tokyo')" class="px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex-shrink-0">
            🗼 <span id="i18n-scope-tokyo">東京圈</span>
          </button>
          <button id="scope-osaka-btn" onclick="setScope('osaka')" class="px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex-shrink-0">
            🐙 <span id="i18n-scope-osaka">關西圈</span>
          </button>
          <button id="scope-hokkaido-btn" onclick="setScope('hokkaido')" class="px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex-shrink-0">
            ❄️ <span id="i18n-scope-hokkaido">北海道</span>
          </button>
        </div>

        <!-- Saved Bookmarks Button -->
        <button onclick="toggleBookmarkDrawer()" class="relative p-2 rounded-2xl bg-white border border-theme shadow-sm hover:scale-105 active:scale-95 transition flex-shrink-0" title="我的收藏清單 / Saved">
          <span class="text-base">❤️</span>
          <span id="bookmark-badge" class="absolute -top-1 -right-1 bg-rose-500 text-white text-[10px] font-black w-4 h-4 rounded-full flex items-center justify-center hidden">
            0
          </span>
        </button>
      </div>

    </div>

    <!-- 手機版大區切換 (Mobile Scope Pill Bar) -->
    <div class="md:hidden px-4 py-1.5 border-t border-theme/60 bg-gray-50/70 flex items-center justify-between gap-1 overflow-x-auto no-scrollbar">
      <button onclick="setScope('all')" data-mscope="all" class="mscope-btn px-2.5 py-1 text-xs font-black rounded-xl bg-white text-theme-primary shadow-sm flex-shrink-0">
        🗾 <span class="i18n-mscope-all">全日本</span>
      </button>
      <button onclick="setScope('tokyo')" data-mscope="tokyo" class="mscope-btn px-2.5 py-1 text-xs font-bold rounded-xl text-gray-600 flex-shrink-0">
        🗼 <span class="i18n-mscope-tokyo">東京圈</span>
      </button>
      <button onclick="setScope('osaka')" data-mscope="osaka" class="mscope-btn px-2.5 py-1 text-xs font-bold rounded-xl text-gray-600 flex-shrink-0">
        🐙 <span class="i18n-mscope-osaka">關西圈</span>
      </button>
      <button onclick="setScope('hokkaido')" data-mscope="hokkaido" class="mscope-btn px-2.5 py-1 text-xs font-bold rounded-xl text-gray-600 flex-shrink-0">
        ❄️ <span class="i18n-mscope-hokkaido">北海道</span>
      </button>
    </div>

    <!-- ================= 四季與擴充花季時令切換條 ================= -->
    <div class="bg-white/70 border-t border-theme/60 px-4 py-2">
      <div class="max-w-6xl mx-auto flex items-center gap-2 overflow-x-auto no-scrollbar" id="season-buttons-wrap">
        <!-- Rendered dynamically for bilingual support -->
      </div>
    </div>
  </header>

  <!-- ================= 篩選樞紐 ================= -->
  <section class="max-w-6xl mx-auto w-full px-4 pt-3.5 z-10 relative space-y-2.5">

    <!-- 🌸 1. 下週怕凋謝？品種救援接力專題 Banner (櫻花季專屬) -->
    <div id="sakura-rescue-banner" class="p-3 sm:p-3.5 rounded-2xl bg-gradient-to-r from-rose-50 via-pink-50 to-amber-50 border border-rose-200 washi-shadow flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2.5 hidden">
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

    <!-- 🌸 2. 櫻花多系與花色深度快篩列 (Variety & Color Filters) -->
    <div id="sakura-variety-panel" class="p-2.5 sm:p-3 bg-white/95 border border-theme rounded-2xl washi-shadow hidden">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-black text-theme-deep flex items-center gap-1.5">
          <span>🌸</span> <span id="lbl-variety-title">櫻花品種花色與接力時令快篩：</span>
        </span>
        <button onclick="openUploadModal()" class="text-[11px] font-black px-2.5 py-1 bg-theme-primary text-white rounded-lg flex items-center gap-1 shadow-sm hover:scale-105 active:scale-95 transition">
          <span>📷</span> <span id="lbl-upload-btn">上傳最新實況照</span>
        </button>
      </div>

      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="sakura-variety-buttons-wrap">
        <!-- Rendered dynamically -->
      </div>
    </div>

    <!-- 0. 主題分類快選列 (花季 / 煙火 / 滑雪 / 溫泉 / 景點 / 活動) -->
    <div>
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar py-0.5" id="category-buttons-wrap">
        <!-- Injected via JavaScript for i18n -->
      </div>
    </div>

    <!-- 1. 動態區域大按鈕 (滑雪顯示滑雪地區；非滑雪則顯示花季/景點地區) -->
    <div>
      <div id="dynamic-region-bar" class="flex items-center gap-1.5 overflow-x-auto no-scrollbar py-0.5">
        <!-- Injected via JavaScript based on season & lang -->
      </div>
    </div>

    <!-- 2. 東京 23 區深度細分按鈕 (僅在選擇「東京圈」時動態展開) -->
    <div id="tokyo-district-bar" class="hidden">
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar py-1 bg-white/80 p-2 rounded-2xl border border-theme washi-shadow" id="tokyo-district-wrap">
        <!-- Injected via JavaScript for i18n -->
      </div>
    </div>

    <!-- 3. 滑雪玩家客群分級快篩 (僅在「❄️ 滑雪・雪季」時出現) -->
    <div id="ski-skill-panel" class="p-3 bg-white/90 border border-theme rounded-2xl washi-shadow">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-black text-theme-deep flex items-center gap-1.5" id="i18n-ski-filter-title">
          <span>🏂</span> 滑雪分級避雷與出行情境：
        </span>
        <span class="text-[10px] text-theme-muted font-bold" id="i18n-surf-sync-badge">即時對接日本滑雪場數據 (SURF&SNOW)</span>
      </div>
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="ski-skill-buttons-wrap">
        <!-- Injected via JavaScript for i18n -->
      </div>
    </div>

    <!-- 4. WNI 花況即時開花階段快篩 (僅在花季時出現) -->
    <div id="flower-bloom-panel" class="p-3 bg-white/90 border border-theme rounded-2xl washi-shadow hidden">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-black text-rose-600 flex items-center gap-1.5" id="i18n-bloom-filter-title">
          <span>🌸</span> Weathernews (WNI) 開花進度實時前線：
        </span>
        <span class="text-[10px] text-theme-muted font-bold" id="i18n-jma-sync-badge">氣象廳標本木觀測同步</span>
      </div>
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="flower-bloom-buttons-wrap">
        <!-- Injected via JavaScript for i18n -->
      </div>
    </div>

    <!-- 5. 煙火大會快篩 (僅在煙火時出現) -->
    <div id="fireworks-panel" class="p-3 bg-white/90 border border-theme rounded-2xl washi-shadow hidden">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs font-black text-pink-600 flex items-center gap-1.5" id="i18n-fw-filter-title">
          <span>🎆</span> Walkerplus 花火大會規格與觀賞席：
        </span>
        <span class="text-[10px] text-theme-muted font-bold" id="i18n-fw-sync-badge">主辦單位 2026 最新日程</span>
      </div>
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar" id="fireworks-buttons-wrap">
        <!-- Injected via JavaScript for i18n -->
      </div>
    </div>

    <!-- 6. 即時速報統計摘要 ＋ 子視圖切換器 (名所/咖啡/討論) ＋ API 連線列 -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between text-xs text-theme-muted px-1 border-b border-theme/60 pb-2.5 gap-2">
      <div id="filter-summary-text" class="flex items-center gap-1.5 font-medium flex-wrap">
        <!-- Injected via JavaScript -->
      </div>

      <div class="flex items-center gap-2 flex-wrap">
        <!-- 子視圖切換 (名所情報 ⇄ 櫻花咖啡館 ⇄ 實況討論區) -->
        <div class="flex items-center bg-gray-100 p-0.5 rounded-xl border border-gray-200">
          <button onclick="setSubView('spots')" id="subview-spots-btn" class="px-2 py-0.5 rounded-lg text-[11px] font-black bg-white text-theme-primary shadow-xs">
            🌸 <span id="i18n-subview-spots">名所情報</span>
          </button>
          <button onclick="setSubView('cafes')" id="subview-cafes-btn" class="px-2 py-0.5 rounded-lg text-[11px] font-bold text-gray-500 hover:text-gray-900">
            ☕ <span id="i18n-subview-cafes">櫻花咖啡館</span>
          </button>
          <button onclick="setSubView('intel')" id="subview-intel-btn" class="px-2 py-0.5 rounded-lg text-[11px] font-bold text-gray-500 hover:text-gray-900 flex items-center gap-1">
            <span>💬</span> <span id="i18n-subview-intel">實況討論區</span>
          </button>
        </div>

        <!-- API 數據來源即時狀態標籤 -->
        <div class="flex items-center gap-1.5 text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-xl border border-emerald-200 shadow-xs hidden sm:flex">
          <span class="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
          <span id="api-status-indicator">SURF&SNOW / WNI / Wiki 連線中</span>
        </div>

        <!-- 立即同步最新數據按鈕 (Trigger Live Sync) -->
        <button onclick="triggerLiveApiSync()" id="btn-sync-api" class="px-2.5 py-1 bg-white hover:bg-gray-50 border border-theme text-theme-primary font-bold rounded-xl shadow-sm text-xs flex items-center gap-1 hover:scale-105 active:scale-95 transition" title="立即串聯更新最新數據">
          <span id="sync-icon">🔄</span>
          <span id="i18n-btn-sync">即時串聯刷新</span>
        </button>
      </div>
    </div>
  </section>

  <!-- ================= 主內容區 (卡片列表 VS 原生地圖雙模切換) ================= -->
  <main class="max-w-6xl mx-auto w-full px-4 py-4 flex-1 z-10 relative">

    <!-- 1. 卡片檢視容器 (含 3 大子視圖：名所 / 咖啡 / 實況牆) -->
    <div id="cards-view-wrap">
      
      <!-- 視圖 1: 名所景點與雪場列表 -->
      <div id="spots-view">
        <div id="resorts-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          <!-- Injected via JavaScript -->
        </div>

        <!-- 空狀態提示 -->
        <div id="empty-state" class="hidden text-center py-20 bg-white/70 rounded-3xl border border-theme washi-shadow p-8">
          <div class="text-5xl mb-2">🌸</div>
          <h3 id="i18n-empty-title" class="text-sm font-bold text-theme-text">目前篩選條件下尚無符合的名所或情報</h3>
          <p id="i18n-empty-sub" class="text-xs text-theme-muted mt-1">試著切換至「全部地區」或更換時令花季看看！</p>
          <button onclick="resetAllFilters()" id="i18n-empty-btn" class="mt-4 px-4 py-1.5 bg-theme-primary text-white text-xs font-bold rounded-xl shadow-sm">
            重設所有篩選
          </button>
        </div>
      </div>

      <!-- 視圖 2: 櫻花特色景觀咖啡廳指南 (Cafe Guide) -->
      <div id="cafes-view" class="hidden space-y-4">
        <div class="p-4 bg-gradient-to-br from-amber-50/90 via-white to-pink-50/60 rounded-3xl border border-amber-200/80 washi-shadow">
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
            <div>
              <h2 class="text-base font-black text-amber-950 flex items-center gap-1.5" id="lbl-cafe-h-title">
                <span>☕</span> 2026 日本河畔・櫻花景觀咖啡廳指南
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
              <span>💬</span> 讀者即時目擊花況情報牆
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

    <!-- 2. 原生互動地圖檢視 (In-App Map Mode - 完全不跳出外部網頁) -->
    <div id="map-view-wrap" class="hidden">
      <div class="bg-white rounded-3xl overflow-hidden border border-theme washi-shadow-lg flex flex-col h-[75vh]">
        <!-- 地圖頂部控制條 -->
        <div class="p-3 bg-gray-50 border-b border-theme flex items-center justify-between gap-2 flex-wrap">
          <div class="flex items-center gap-2">
            <span class="text-base">🗾</span>
            <span id="i18n-map-title" class="text-xs font-black text-theme-deep">全日本即時實況定位圖</span>
            <span id="i18n-map-hint" class="text-[10px] px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold">點擊 Pin 查看即時情報</span>
          </div>
          <div class="flex items-center gap-1 text-[11px]">
            <button onclick="focusMapRegion('all')" id="i18n-map-f-all" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">日本全島</button>
            <button onclick="focusMapRegion('tokyo')" id="i18n-map-f-tokyo" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">東京近郊</button>
            <button onclick="focusMapRegion('kansai')" id="i18n-map-f-kansai" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">關西京阪</button>
            <button onclick="focusMapRegion('hokkaido')" id="i18n-map-f-hokkaido" class="px-2 py-0.5 rounded-lg bg-white border border-gray-200 hover:bg-gray-100 font-bold">北海道</button>
          </div>
        </div>

        <!-- 互動向量地圖畫布區 (可拖曳、點擊地標) -->
        <div class="relative flex-1 bg-[#EEF6F8] overflow-hidden select-none" id="interactive-map-container">
          <svg id="japan-map-svg" viewBox="0 0 1000 800" class="w-full h-full object-contain">
            <defs>
              <linearGradient id="seaGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#E0F2FE" />
                <stop offset="100%" stop-color="#BAE6FD" />
              </linearGradient>
              <filter id="mapShadow" x="-10%" y="-10%" width="130%" height="130%">
                <feDropShadow dx="2" dy="4" stdDeviation="4" flood-opacity="0.1" />
              </filter>
            </defs>
            <rect width="1000" height="800" fill="url(#seaGrad)" opacity="0.4" />

            <!-- 日本群島色塊 -->
            <g id="islands-group" filter="url(#mapShadow)">
              <!-- 北海道 -->
              <path d="M720 80 Q760 60 820 90 Q870 110 880 150 Q850 190 790 190 Q740 210 710 180 Q690 140 720 80 Z" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="2" />
              <!-- 本州東北至關東 -->
              <path d="M680 220 Q730 260 740 330 Q720 380 690 420 Q640 460 590 460 Q560 430 580 370 Q620 310 650 250 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2" />
              <!-- 本州中部與關西 -->
              <path d="M590 460 Q560 480 500 490 Q430 510 400 520 Q370 500 390 460 Q440 430 500 430 Q550 430 590 460 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2" />
              <!-- 四國 -->
              <path d="M410 530 Q460 520 490 540 Q460 570 410 570 Q380 550 410 530 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2" />
              <!-- 九州 -->
              <path d="M340 520 Q370 520 360 580 Q330 630 300 600 Q280 550 340 520 Z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2" />
            </g>

            <!-- 地圖區域文字標示 -->
            <text x="790" y="140" font-size="14" font-weight="900" fill="#94A3B8" id="svg-text-hokkaido">Hokkaido</text>
            <text x="690" y="300" font-size="14" font-weight="900" fill="#94A3B8" id="svg-text-tohoku">Tohoku</text>
            <text x="640" y="440" font-size="14" font-weight="900" fill="#0284C7" id="svg-text-tokyo">🗼 Tokyo Kanto</text>
            <text x="560" y="410" font-size="13" font-weight="900" fill="#0369A1" id="svg-text-nagano">⛷️ Niigata / Nagano</text>
            <text x="440" y="480" font-size="14" font-weight="900" fill="#EA580C" id="svg-text-kansai">🐙 Kansai (Kyoto/Osaka)</text>

            <!-- 動態 Pin 點標記容器 -->
            <g id="map-pins-layer"></g>
          </svg>

          <!-- 浮動地圖詳情預覽卡片 -->
          <div id="map-pin-preview-card" class="absolute bottom-4 inset-x-4 max-w-lg mx-auto bg-white/95 backdrop-blur-md rounded-2xl p-3.5 border border-theme shadow-xl transform translate-y-36 opacity-0 transition-all duration-300 flex items-center justify-between gap-3 hidden">
            <!-- Injected via JavaScript -->
          </div>
        </div>
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
            <span id="sheet-progress-title">進度與難易度分佈</span>
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

        <!-- 景點關聯咖啡廳專屬區塊 (若是目黑川等有咖啡廳者顯示) -->
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
            全中文雙板/單板教練，含專業教學攝影紀錄，提供小班制與私人 1 對 1。初學者第一天強烈建議預約教練掌握上下纜車與煞車核心姿勢！
          </p>
        </div>

        <!-- 交通路線 (整合 ODPT 公共交通指南) -->
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
            <div class="flex items-center justify-between text-[9px] text-slate-400 mt-1.5 px-0.5">
              <span>協議: REST JSON / JMA Open Data</span>
              <span id="sheet-api-timestamp">更新時間: 2026-10-16 08:00 JST</span>
            </div>
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
          <label class="font-bold text-gray-700 block mb-1" id="lbl-upload-spot-select">選擇名所或咖啡廳：</label>
          <select id="upload-spot-select" class="w-full p-2 border border-gray-200 rounded-xl bg-gray-50 font-bold">
            <option value="目黑川櫻並木">目黑川櫻並木 (目黑區)</option>
            <option value="新宿御苑 (晚開品種接力)">新宿御苑 (晚開八重櫻/稀有綠櫻)</option>
            <option value="星巴克臻選® 東京烘焙工坊">星巴克臻選® 東京烘焙工坊 (中目黑)</option>
            <option value="ONIBUS COFFEE 中目黑">ONIBUS COFFEE 中目黑</option>
            <option value="CANAL CAFE 神樂坂水岸露台">CANAL CAFE 神樂坂水岸露台</option>
            <option value="上野恩賜公園">上野恩賜公園</option>
            <option value="大阪造幣局 櫻之通道">大阪造幣局 櫻之通道</option>
            <option value="伊豆河津櫻並木">伊豆河津櫻並木</option>
          </select>
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1" id="lbl-upload-time">拍攝時間 (自動讀取 EXIF 模擬)：</label>
          <input type="datetime-local" id="upload-time" class="w-full p-2 border border-gray-200 rounded-xl bg-gray-50 font-bold text-gray-700" />
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1" id="lbl-upload-status">現況狀態標記：</label>
          <select id="upload-status" class="w-full p-2 border border-gray-200 rounded-xl bg-gray-50 font-bold">
            <option value="🌸 滿開無死角">🌸 滿開無死角 (100% 盛開)</option>
            <option value="🌺 八重櫻接力盛開中">🌺 八重櫻接力盛開中 (90%)</option>
            <option value="🍃 開始落櫻吹雪">🍃 開始落櫻吹雪 (花筏出現)</option>
            <option value="☕ 咖啡廳人潮適中 (排隊15分)">☕ 咖啡廳人潮適中 (排隊15分)</option>
            <option value="☕ 咖啡廳戶外席已滿">☕ 咖啡廳戶外席已滿</option>
          </select>
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1" id="lbl-upload-sample">照片預覽 (提供精選現場實拍照)：</label>
          <div class="grid grid-cols-3 gap-2">
            <img src="https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=400&q=80" class="h-16 w-full object-cover rounded-xl border-2 border-theme-primary cursor-pointer" onclick="selectSampleImg(this)" />
            <img src="https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=400&q=80" class="h-16 w-full object-cover rounded-xl border border-gray-200 cursor-pointer opacity-70 hover:opacity-100" onclick="selectSampleImg(this)" />
            <img src="https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=400&q=80" class="h-16 w-full object-cover rounded-xl border border-gray-200 cursor-pointer opacity-70 hover:opacity-100" onclick="selectSampleImg(this)" />
          </div>
        </div>

        <div>
          <label class="font-bold text-gray-700 block mb-1" id="lbl-upload-comment">實況心得備註：</label>
          <input type="text" id="upload-comment" placeholder="例：目黑川今日河面有薄薄花筏，星巴克露台需抽整理券～" class="w-full p-2 border border-gray-200 rounded-xl font-bold" />
        </div>
      </div>

      <div class="pt-2">
        <button onclick="submitUGCReport()" id="lbl-upload-submit-btn" class="w-full py-2.5 bg-theme-primary hover:bg-theme-primary/90 text-white font-black rounded-xl text-xs shadow-md transition">
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
      <button onclick="toggleBookmarkDrawer()" class="text-gray-400 hover:text-gray-700 font-bold text-sm">
        ✕
      </button>
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

  <!-- ================= 底部 App 快速導航欄 (TabBar: 即時花雪 / 櫻花咖啡 / 實況討論 / 我的收藏) ================= -->
  <nav class="fixed bottom-0 inset-x-0 z-40 bg-white/95 backdrop-blur-md border-t border-theme flex items-center justify-around py-2">
    <button onclick="setSubView('spots')" id="tab-btn-spots" class="flex flex-col items-center text-theme-primary">
      <span class="text-lg">🌸</span>
      <span class="text-[10px] font-bold mt-0.5" id="i18n-tab-spots">即時花雪</span>
    </button>
    <button onclick="setSubView('cafes')" id="tab-btn-cafes" class="flex flex-col items-center text-gray-400 hover:text-theme-primary">
      <span class="text-lg">☕</span>
      <span class="text-[10px] font-bold mt-0.5" id="i18n-tab-cafes">櫻花咖啡</span>
    </button>
    <button onclick="setSubView('intel')" id="tab-btn-intel" class="flex flex-col items-center text-gray-400 hover:text-theme-primary">
      <span class="text-lg">💬</span>
      <span class="text-[10px] font-bold mt-0.5" id="i18n-tab-intel">實況討論</span>
    </button>
    <button onclick="toggleBookmarkDrawer()" class="flex flex-col items-center text-gray-400 hover:text-theme-primary relative">
      <span class="text-lg">❤️</span>
      <span class="text-[10px] font-bold mt-0.5" id="i18n-tab-fav">我的收藏</span>
    </button>
  </nav>

  <!-- ================= 訊息提示 Modal ================= -->
  <div id="app-modal" class="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm hidden flex items-center justify-center p-4">
    <div class="bg-white p-5 rounded-2xl max-w-xs w-full text-center shadow-xl border border-theme">
      <p id="app-modal-text" class="text-xs font-bold text-gray-800 mb-4">提示訊息</p>
      <button onclick="closeModal()" id="i18n-modal-ok" class="w-full py-2 bg-theme-primary text-white text-xs font-black rounded-xl">
        好的
      </button>
    </div>
  </div>

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

HTML_PART1

print "HTML Part 1 written\n";
close $fh;
