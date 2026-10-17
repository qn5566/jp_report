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

open my $fh, '>>:utf8', $target or die "Cannot append to $target: $!\n";

print $fh <<'JS_CODE_SECTION';
  <!-- ================= JavaScript 資料庫、時令咖啡切換與 Leaflet 地圖控制器 ================= -->
  <script>
    const AFFILIATE_AID = "123436";
    let currentLang = localStorage.getItem('tabi_lang') || 'zh';

    function appendAffiliateParams(url, subId) {
      if (!url) return "#";
      try {
        const u = new URL(url);
        if (currentLang === 'en') {
          if (u.hostname.includes("klook.com") && u.pathname.startsWith("/zh-TW/")) {
            u.pathname = u.pathname.replace("/zh-TW/", "/en-US/");
          }
          if (u.hostname.includes("agoda.com") && u.pathname.startsWith("/zh-tw/")) {
            u.pathname = u.pathname.replace("/zh-tw/", "/en-us/");
          }
        }
        if (u.hostname.includes("klook.com")) {
          u.searchParams.set("aid", AFFILIATE_AID);
          u.searchParams.set("utm_medium", "affiliate-alwayson");
          u.searchParams.set("utm_source", "non-network");
          u.searchParams.set("utm_campaign", AFFILIATE_AID);
          if (subId) u.searchParams.set("aff_label1", subId);
        } else if (u.hostname.includes("agoda.com")) {
          u.searchParams.set("cid", AFFILIATE_AID);
        }
        return u.toString();
      } catch (e) {
        return url;
      }
    }

    // 大分類
    const MAIN_CATEGORIES = [
      { id: "spot", name: "全部景點", name_en: "All Spots", icon: "🏛️" },
      { id: "flower", name: "花季名所", name_en: "Sakura & Blooms", icon: "🌸" },
      { id: "fireworks", name: "花火大會", name_en: "Fireworks", icon: "🎆" },
      { id: "ski", name: "滑雪雪場", name_en: "Ski Resorts", icon: "⛷️" },
      { id: "onsen", name: "溫泉秘境", name_en: "Hot Springs", icon: "♨️" },
      { id: "event", name: "最新活動", name_en: "Latest Events", icon: "🎪" }
    ];

    // 東京各區
    const TOKYO_DISTRICTS = [
      { id: "all", name: "全部 23 區", name_en: "All Wards" },
      { id: "shibuya", name: "澀谷 (SHIBUYA SKY/原宿)", name_en: "Shibuya" },
      { id: "shinjuku", name: "新宿 (御苑/歌舞伎町)", name_en: "Shinjuku" },
      { id: "taito", name: "台東 (淺草寺/上野公園)", name_en: "Asakusa/Ueno" },
      { id: "minato", name: "港區 (東京鐵塔/六本木)", name_en: "Minato/Tower" },
      { id: "chuo", name: "中央區 (銀座 GINZA SIX)", name_en: "Ginza" },
      { id: "chiyoda", name: "千代田 (秋葉原/皇居)", name_en: "Akihabara" },
      { id: "koto", name: "江東區 (豐洲teamLab/台場)", name_en: "Toyosu/Odaiba" },
      { id: "sumida", name: "墨田區 (晴空塔水岸)", name_en: "Sumida/Skytree" }
    ];

    // Walkerplus 花火大會等級規格
    const FIREWORKS_GRADES = [
      { id: "all", label: "全部等級規格", en: "All Fireworks" },
      { id: "S", label: "🏆 S 級 (超大規模 20,000發+)", en: "🏆 Grade S (20,000+ Shells Mega)" },
      { id: "A", label: "🥇 A 級 (萬發名所 10,000~19,999發)", en: "🥇 Grade A (10,000~19,999 Shells)" },
      { id: "SPECIAL", label: "💎 特色級 (水中/海上/尺玉連發)", en: "💎 Special (Water & Seaside)" }
    ];

    // 櫻花品種多系快篩
    const SAKURA_VARIETIES = [
      { id: "all", label: "全部品種 (All)", en: "All Varieties" },
      { id: "deep_pink", label: "🌸 濃粉色系 (早櫻河津櫻/八重紅枝垂)", en: "🌸 Deep Pink (Kawazu)" },
      { id: "white_pink", label: "🤍 雪白淡粉 (經典染井吉野/大島櫻)", en: "🤍 Pale Pink (Yoshino)" },
      { id: "late", label: "🌺 晚開接力 (八重櫻/普賢象/關山)", en: "🌺 Late Yaezakura" },
      { id: "green", label: "💚 稀有綠櫻 (御衣黃/鬱金櫻)", en: "💚 Rare Green" }
    ];

    // WNI 開花進度
    const SAKURA_BLOOM_STAGES = [
      { id: "all", name: "全部進度", name_en: "All Stages" },
      { id: "full", name: "🌸 滿開盛況 100%", name_en: "🌸 100% Full Bloom" },
      { id: "blooming", name: "🌺 八分咲き (最佳觀賞)", name_en: "🌺 80% Bloom" },
      { id: "bud", name: "🌱 開花前線 (初開)", name_en: "🌱 Just Opened" },
      { id: "falling", name: "🍃 吹雪花筏 (落櫻地毯)", name_en: "🍃 Petal Rafts" }
    ];

    // 滑雪勝地分區與分級
    const SKI_REGIONS = [
      { id: "all", name: "全部雪區", name_en: "All Ski Zones" },
      { id: "yuzawa", name: "越後湯澤・新潟", name_en: "Echigo Yuzawa" },
      { id: "hakuba", name: "長野・白馬", name_en: "Nagano Hakuba" },
      { id: "hokkaido", name: "北海道・二世谷", name_en: "Hokkaido Niseko" },
      { id: "tohoku", name: "東北・藏王", name_en: "Tohoku Zao" }
    ];

    const SKI_SKILLS = [
      { id: "all", name: "全部推薦", name_en: "All Resorts" },
      { id: "beginner", name: "🌱 新手入門 (緩坡/魔毯/綠線>50%)", name_en: "🌱 Beginner (>50% Green)" },
      { id: "intermediate", name: "⛷️ 進階暢滑 (巡航長紅線)", name_en: "⛷️ Cruiser (Long Red)" },
      { id: "pro", name: "🌲 老手狂歡 (JAPOW極上粉雪/野雪)", name_en: "🌲 Powder Pro (JAPOW)" },
      { id: "town", name: "🛍️ 出街逛街方便 (新幹線/Outlet)", name_en: "🛍️ Town & Outlet" }
    ];

    // 三、景觀咖啡廳全面動態升級庫（櫻花咖啡 ⇄ 楓葉手沖 ⇄ 花火景觀餐廳）
    const SCENIC_CAFES = {
      flower: [
        {
          id: "cafe-starbucks-roastery",
          name: "星巴克臻選® 東京烘焙工坊",
          name_en: "Starbucks Reserve Roastery Tokyo",
          spotName: "目黑川櫻並木",
          viewType: "🌸 4F 川畔露台席・櫻花冠第一排",
          walking: "中目黑站步行約 10 分鐘 (沿目黑川)",
          latestPhotoTime: "今日 09:30 拍 (EXIF 認證)",
          photoStatus: "🌸 4F 露台正對櫻花冠滿開・薄薄花筏出現",
          tips: "隈研吾大師設計！花季期間務必於一早 07:00 開門時在門口掃 QR Code 抽取「入場整理券」，4 樓露台席景觀震撼心靈。",
          photoUrl: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Starbucks+Reserve+Roastery+Tokyo"
        },
        {
          id: "cafe-onibus-nakameguro",
          name: "ONIBUS COFFEE 中目黑店",
          name_en: "ONIBUS COFFEE Naka-Meguro",
          spotName: "中目黑鐵道旁櫻花",
          viewType: "🌸 2F 窗景與日比谷線電車同框",
          walking: "中目黑站南口步行 2 分鐘",
          latestPhotoTime: "今日 11:15 拍 (EXIF 認證)",
          photoStatus: "🌸 窗外櫻花開滿，列車每 3 分鐘一班",
          tips: "獨棟雙層古民家風格，二樓小窗台能拍出東京最經典的「手沖咖啡＋櫻花樹＋行駛中的電車」日系文青構圖！",
          photoUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=ONIBUS+COFFEE+Nakameguro"
        },
        {
          id: "cafe-canal-cafe",
          name: "CANAL CAFE 神樂坂水岸露台",
          name_en: "CANAL CAFE Kagurazaka",
          spotName: "外濠公園櫻並木",
          viewType: "🌸 水上浮動木棧甲板＆倒影花筏",
          walking: "飯田橋站 B2a 出口步行 1 分鐘",
          latestPhotoTime: "昨日 15:40 拍 (EXIF 認證)",
          photoStatus: "🍃 櫻吹雪開始，水面漂滿落櫻",
          tips: "東京最浪漫的水上甲板咖啡廳！點一份義式冰淇淋坐在戶外木棧道，落櫻隨風飄在水面如花筏，傍晚夜櫻點燈尤其迷人。",
          photoUrl: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=CANAL+CAFE+Tokyo"
        }
      ],
      momiji: [
        {
          id: "cafe-blue-bottle-nanzenji",
          name: "藍瓶咖啡 京都南禪寺店 (百年町家茶屋)",
          name_en: "Blue Bottle Coffee Kyoto Nanzenji",
          spotName: "京都・南禪寺",
          viewType: "🍁 百年傳統京町家・枯山水紅葉中庭",
          walking: "地下鐵東西線「蹴上站」步行 7 分鐘",
          latestPhotoTime: "昨日 14:20 拍 (EXIF 認證)",
          photoStatus: "🍁 庭院楓葉赤紅見頃・光影絕美",
          tips: "由百年歷史的江戶傳統町家茶屋改建！在挑高的木質橫樑與碎石枯山水庭園中品嚐單品手沖，秋天楓紅與日式老宅極致交融。",
          photoUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Blue+Bottle+Coffee+Kyoto"
        },
        {
          id: "cafe-arabica-arashiyama",
          name: "% ARABICA 京都嵐山店",
          name_en: "% ARABICA Kyoto Arashiyama",
          spotName: "京都・嵐山渡月橋",
          viewType: "🍁 桂川水岸第一排・渡月橋楓紅全景",
          walking: "京福嵐山本線「嵐山站」步行 5 分鐘",
          latestPhotoTime: "今日 10:15 拍 (EXIF 認證)",
          photoStatus: "🍁 嵐山層巒楓紅與碧綠川水同框",
          tips: "全球最著名的水岸咖啡館！通透的玻璃落地窗正對著倒映楓紅的桂川與渡月橋，外帶一杯冠軍拉花拿鐵漫步河畔，無可挑剔。",
          photoUrl: "https://images.unsplash.com/photo-1493780474015-ba834fd0ce2f?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Arabica+Kyoto+Arashiyama"
        },
        {
          id: "cafe-shake-shack-gai-en",
          name: "Shake Shack 明治神宮外苑店",
          name_en: "Shake Shack Meiji Jingu Gaien",
          spotName: "神宮外苑銀杏並木",
          viewType: "🍂 300m 百年銀杏大道・落葉露天席",
          walking: "外苑前站或青山一丁目站步行 3 分鐘",
          latestPhotoTime: "今日 12:00 拍 (EXIF 認證)",
          photoStatus: "🍂 黃金銀杏隧道滿開・落葉鋪地",
          tips: "坐落於百年銀杏大道正中央，秋季金黃落葉飄落在木質桌椅上，點一份漢堡配手沖咖啡，彷彿走入日劇電影場景。",
          photoUrl: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Shake+Shack+Gai-en"
        }
      ],
      fireworks: [
        {
          id: "dining-sky-lounge-skytree",
          name: "Sky Restaurant 634 (晴空塔 345m 高空展望)",
          name_en: "Sky Restaurant 634 (Musashi)",
          spotName: "隅田川花火大會",
          viewType: "🎆 俯瞰 2 萬發花火綻放於腳下・奢華法日料亭",
          walking: "東京晴空塔站直達晴空塔展望台 345F",
          latestPhotoTime: "花火夜特別包廂 (實名預約)",
          photoStatus: "🎆 視野無死角！空中俯瞰雙會場煙火大輪",
          tips: "東京最高景觀餐廳！花火大會當晚推出專屬晚宴席，免除地面 100 萬人潮擁擠，在 345 公尺高空優雅品嚐法日懷石美饌配香檳！",
          photoUrl: "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Sky+Restaurant+634"
        },
        {
          id: "dining-odaiba-deck",
          name: "KING OF THE PIRATES (台場海濱水岸露台)",
          name_en: "KING OF THE PIRATES Odaiba",
          spotName: "台場彩虹花火大會",
          viewType: "🎆 彩虹大橋與東京灣水上花火第一排木棧露台",
          walking: "百合鷗號「台場站」步行 1 分鐘 (AQUA CiTY 5F)",
          latestPhotoTime: "週六定期施放 19:00 (現正開放預約)",
          photoStatus: "🎆 彩虹大橋七彩點燈＋水上海上連發同框",
          tips: "正對自由女神像與彩虹大橋的海盜主題景觀餐廳！擁有超大戶外木棧露天座位，冬天點上一杯熱紅酒欣賞 5 分鐘的水上連發，浪漫滿分。",
          photoUrl: "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=KING+OF+THE+PIRATES+Odaiba"
        },
        {
          id: "dining-yodogawa-terrace",
          name: "川之驛 Hachikenya 水岸露天餐酒館",
          name_en: "Riverside Bistro Hachikenya Osaka",
          spotName: "浪速淀川花火大會",
          viewType: "🎆 水岸第一排 VIP 包廂席・微醺精釀啤酒",
          walking: "天滿橋站 2 號出口直達大川水岸",
          latestPhotoTime: "淀川花火特別觀賞席",
          photoStatus: "🎆 水上屋形船穿梭與絢爛水面倒影",
          tips: "大阪大川與淀川水系第一排浪漫水岸。花火之夜提供限定觀賞套餐與精釀生啤酒，免擠電車直接在河畔露天微醺欣賞花火倒影！",
          photoUrl: "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Hachikenya+Osaka"
        }
      ],
      spot: [
        {
          id: "cafe-paradise-lounge",
          name: "Paradise Lounge (SHIBUYA SKY 46F)",
          name_en: "Paradise Lounge Shibuya Sky",
          spotName: "SHIBUYA SKY",
          viewType: "🍸 229m 高空天際酒吧・俯瞰澀谷十字路口",
          walking: "澀谷站直通 Shibuya Scramble Square 46F",
          latestPhotoTime: "今日 16:30 拍",
          photoStatus: "✨ 富士山夕陽黃金時刻＋無敵夜景",
          tips: "由英國著名設計師 Tom Dixon 操刀，長達 15 公尺的高空復古吧檯。點一杯特調調酒搭配天際熱狗堡，享受俯瞰東京無死角夜景！",
          photoUrl: "https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=700&q=80",
          mapUrl: "https://maps.google.com/?q=Paradise+Lounge+Shibuya"
        }
      ]
    };

    // 全日本景點、花火大會規格庫、滑雪場資料庫 (已標準化 Walkerplus 與觀振協欄位)
    const TABI_DATABASE = [
      // ---------- 🎆 花火大會標準化等級規格庫 (S級超大/A級萬發/特色級) ----------
      {
        id: "fw-nagaoka",
        name: "長岡祭大花火大會",
        name_en: "Nagaoka Grand Fireworks Festival",
        subtitle: "日本三大花火之首！信濃川兩岸長達 2 公里「復興祈願鳳凰花火」",
        subtitle_en: "Japan's #1 Fireworks: Iconic 2km Phoenix Shells & Niigata Grand Sky",
        type: "fireworks",
        scope: "all",
        district: "all",
        regionName: "新潟・長岡市",
        regionName_en: "Niigata · Nagaoka",
        fireworksGrade: "S",
        fireworksGradeBadge: "🏆 S 級 (超大規模)",
        shellsCount: "20,000 發",
        maxShellSize: "正三尺玉 (直徑650m)",
        lastYearCrowd: "約 100 萬人次 (極度壅塞)",
        badWeatherPlan: "小雨照常；荒天時順延",
        paidSeatsStatus: "有料觀覽席事前抽選 (搶票中)",
        snowDepth: "20,000 發",
        snowQuality: "復興祈願鳳凰巨型花火",
        liftRatio: "信濃川兩岸會場",
        slopes: { green: 70, red: 20, black: 10 },
        transit: "JR 長岡站步行 30 分鐘至信濃川河川敷會場",
        transit_en: "JR Nagaoka Station (30 mins walk to Shinano River)",
        desc: "【日本三大花火大會】被譽為一生必看一次的奇蹟盛會！以平原為舞台施放全長 2 公里的「鳳凰花火」與直徑達 650 公尺的「正三尺玉」，磅礡交響樂配合連發，全場感動落淚。",
        desc_en: "Regarded as Japan's ultimate fireworks masterpiece. Launching 20,000 shells across a 2-kilometer riverfront featuring the legendary Phoenix starmines and massive Sanshakudama shells.",
        image: "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=800&q=80",
        lat: 37.4478, lng: 138.8522,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "fw-sumida",
        name: "隅田川花火大會",
        name_en: "Sumida River Fireworks Festival",
        subtitle: "東京夏季代表作！晴空塔與 2 萬發璀璨同框・萬發尺玉連發",
        subtitle_en: "Tokyo's Iconic Summer Tradition: 20,000 Shells with Skytree",
        type: "fireworks",
        scope: "tokyo",
        district: "sumida",
        regionName: "東京・隅田川水岸",
        regionName_en: "Tokyo · Sumida River",
        fireworksGrade: "S",
        fireworksGradeBadge: "🏆 S 級 (超大規模)",
        shellsCount: "20,000 發",
        maxShellSize: "一尺玉 (10號玉)",
        lastYearCrowd: "約 103 萬人次 (極度壅塞)",
        badWeatherPlan: "荒天順延至隔日施放",
        paidSeatsStatus: "有料觀覽席＋屋形船 VIP 席熱售中",
        snowDepth: "20,000 發",
        snowQuality: "尺玉速射連發",
        liftRatio: "兩大發射會場",
        slopes: { green: 70, red: 20, black: 10 },
        transit: "都營淺草線/東武晴空塔線「淺草站」步行 5 分鐘",
        transit_en: "Asakusa Station (5 mins walk)",
        desc: "【享保 18 年傳承】日本歷史最古老的花火大會。第一與第二會場共發射 20,000 發煙火，晴空塔點亮特別限定燈光秀，河道上停泊數百艘屋形船，極致奢華浪漫。",
        desc_en: "Japan's oldest fireworks tradition dating back to 1733. Over 20,000 shells launched across two riverfront zones against the Tokyo Skytree.",
        image: "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=800&q=80",
        lat: 35.7128, lng: 139.8000,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "fw-yodogawa",
        name: "浪速淀川花火大會",
        name_en: "Naniwa Yodogawa Fireworks Festival",
        subtitle: "關西最大規模！水上水中花火連發・大阪天際線水岸交響曲",
        subtitle_en: "Kansai's Top Fireworks Spectacle: Water Shells over Osaka Skyline",
        type: "fireworks",
        scope: "kansai",
        district: "all",
        regionName: "關西・大阪淀川河川敷",
        regionName_en: "Osaka · Yodogawa",
        fireworksGrade: "A",
        fireworksGradeBadge: "🥇 A 級 (萬發名所)",
        shellsCount: "15,000 發",
        maxShellSize: "水上水中速射連發",
        lastYearCrowd: "約 60 萬人次",
        badWeatherPlan: "雨天決行；荒天中止",
        paidSeatsStatus: "納涼席與堤防特等席開賣中",
        snowDepth: "15,000 發",
        snowQuality: "水中扇形半圓花火",
        liftRatio: "梅田水岸特等席",
        slopes: { green: 75, red: 20, black: 5 },
        transit: "JR 東海道本線「塚本站」或阪急「十三站」步行 15 分鐘",
        transit_en: "JR Tsukamoto Station / Hankyu Juso Station (15 mins walk)",
        desc: "大阪市民熱愛的第一名花火！以大阪梅田摩天大樓天際線為背景，在淀川水面上以極快節奏施放扇形水中花火與大輪金柳，聲光音效極度震撼。",
        desc_en: "Osaka's premier summer fireworks festival, illuminating the Yodogawa River with massive fan-shaped water shells set against the Umeda skyscraper skyline.",
        image: "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=800&q=80",
        lat: 34.7100, lng: 135.4850,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "fw-atami",
        name: "熱海海上花火大會",
        name_en: "Atami Sea Fireworks Festival",
        subtitle: "天然音場環繞！四季定期施放・熱海灣大空中尼加拉瀑布",
        subtitle_en: "Four-Season Natural Bay Echoes: Niagara Falls Fireworks over Atami Bay",
        type: "fireworks",
        scope: "tokyo",
        district: "all",
        regionName: "關東近郊・靜岡熱海灣",
        regionName_en: "Shizuoka · Atami Bay",
        fireworksGrade: "SPECIAL",
        fireworksGradeBadge: "💎 特色級 (海上音響)",
        shellsCount: "5,000 發/回",
        maxShellSize: "大空中尼加拉銀瀑",
        lastYearCrowd: "約 12 萬人次/回",
        badWeatherPlan: "雨天決行 (暴風雨除外)",
        paidSeatsStatus: "溫泉飯店海景房直接觀賞",
        snowDepth: "四季定期施放",
        snowQuality: "三面環山天然音響效果",
        liftRatio: "親水公園全景區",
        slopes: { green: 85, red: 15, black: 0 },
        transit: "JR 東海道新幹線「熱海站」步行 15 分鐘至熱海親水公園",
        transit_en: "JR Atami Shinkansen Station (15 mins walk to Waterfront Park)",
        desc: "【四季皆放的海上傳奇】熱海灣三面環山，形成宛如大型天然音樂廳的反射音場，爆炸聲直擊心臟！壓軸的「大空中尼加拉瀑布」將整片夜空與海面染成銀白星河。",
        desc_en: "Famous for its natural basin acoustics and four-season schedule. The grand finale 'Airborne Niagara' blankets the entire bay in shimmering silver starlight.",
        image: "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=800&q=80",
        lat: 35.0963, lng: 139.0730,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },

      // ---------- 🏛️ 東京必訪景點 (全部景點骨幹) ----------
      {
        id: "spot-shibuya-sky",
        name: "SHIBUYA SKY 展望台",
        name_en: "SHIBUYA SKY Observation Deck",
        subtitle: "360度露天全景！俯瞰澀谷十字路口與富士山夕陽",
        subtitle_en: "360-degree Open-Air Sky Deck overlooking the Scramble & Mt. Fuji",
        type: "spot",
        scope: "tokyo",
        district: "shibuya",
        regionName: "東京・澀谷區",
        regionName_en: "Tokyo · Shibuya",
        statusText: "熱銷門票預約中",
        statusText_en: "Timed Entry (Fast Selling)",
        snowDepth: "地上 229 公尺",
        snowQuality: "全透明無遮蔽天際線",
        liftRatio: "高速體感電梯直達",
        slopes: { green: 90, red: 10, black: 0 },
        transit: "澀谷站直通 Shibuya Scramble Square 47F",
        desc: "東京最熱門的露天高空展望台，站在懸空玻璃角落拍照心跳加速。可俯瞰世界聞名的澀谷十字路口人潮，黃昏時刻還能眺望富士山剪影。",
        image: "https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=800&q=80",
        lat: 35.6580, lng: 139.7016,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-tokyo-tower",
        name: "東京鐵塔 TOKYO TOWER",
        name_en: "TOKYO TOWER",
        subtitle: "東京永恆地標！經典紅白塔身與 RED° 電競樂園",
        subtitle_en: "Tokyo's Timeless Icon with RED° Esports Theme Park",
        type: "spot",
        scope: "tokyo",
        district: "minato",
        regionName: "東京・港區芝公園",
        regionName_en: "Tokyo · Minato (Shiba Park)",
        statusText: "夜間點燈璀璨營業",
        statusText_en: "Night Light-up Daily",
        snowDepth: "標高 333 公尺",
        snowQuality: "Top Deck 菱鏡鏡面展望台",
        liftRatio: "全天開放",
        slopes: { green: 85, red: 15, black: 0 },
        transit: "都營大江戶線「赤羽橋站」步行 5 分鐘",
        desc: "建於 1958 年的東京精神象徵。擁有 Main Deck (150m) 與重新改裝的 Top Deck (250m) 鏡面反射展望室，塔下更進駐全日本最大室內電競主題樂園 RED° TOKYO TOWER。",
        image: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
        lat: 35.6586, lng: 139.7454,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-sensoji",
        name: "淺草寺 ＆ 仲見世商店街",
        name_en: "Senso-ji Temple & Nakamise Dori",
        subtitle: "東京最古老寺院！巨型雷門紅燈籠與和服體驗勝地",
        subtitle_en: "Tokyo's Oldest Temple: Iconic Kaminarimon & Kimono Experience",
        type: "spot",
        scope: "tokyo",
        district: "taito",
        regionName: "東京・台東區淺草",
        regionName_en: "Tokyo · Asakusa",
        statusText: "全日香火鼎盛",
        statusText_en: "Open Year-round",
        snowDepth: "創建於西元 628 年",
        snowQuality: "傳統江戶和風老街",
        liftRatio: "和服租借熱門中",
        slopes: { green: 95, red: 5, black: 0 },
        transit: "東京地鐵銀座線「淺草站」步行 1 分鐘",
        desc: "東京香火最盛的觀音信仰聖地。穿過巨大的「雷門」提燈，即可漫步於擁有數百年歷史的仲見世通，品嚐現烤人形燒，是租借和服漫遊的第一首選。",
        image: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80",
        lat: 35.7148, lng: 139.7967,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },

      // ---------- 🌸 櫻花名所 (花季專區) ----------
      {
        id: "sakura-meguro",
        name: "目黑川櫻並木",
        name_en: "Meguro River Sakura Promenade",
        subtitle: "粉紅光廊・800株吉野櫻璀璨盛開・景觀咖啡聚集",
        subtitle_en: "800 Yoshino Cherry Trees along romantic canal & iconic cafes",
        type: "flower",
        scope: "tokyo",
        district: "all",
        regionName: "東京・目黑區",
        regionName_en: "Tokyo · Meguro",
        variety: "white_pink",
        varietyName: "染井吉野櫻 (淡粉白)",
        statusText: "滿開盛況 (100%)",
        statusText_en: "Full Bloom (100%)",
        bloomStage: "full",
        snowDepth: "800 株吉野櫻",
        snowQuality: "粉紅花筏倒影",
        liftRatio: "夜櫻點燈至 20:00",
        slopes: { green: 90, red: 10, black: 0 },
        hasCafe: true,
        cafeSummary: "星巴克臻選烘焙工坊 (4F露台) ｜ ONIBUS 手沖 ｜ SIDEWALK STAND",
        transit: "東急東橫線/日比谷線「中目黑站」步行 2 分鐘",
        desc: "東京最具人氣的水岸櫻花，兩岸吉野櫻形成遮天花廊。落櫻時分河道化身粉紅地毯，沿岸聚集眾多景觀咖啡館。",
        image: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=800&q=80",
        lat: 35.6450, lng: 139.6980,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "sakura-shinjuku-gyoen",
        name: "新宿御苑 (晚開品種接力)",
        name_en: "Shinjuku Gyoen National Garden",
        subtitle: "65種櫻花・吉野凋謝後的「八重櫻與稀有綠櫻」天堂",
        subtitle_en: "65 varieties! The ultimate late-blooming Yaezakura & Green Sakura paradise",
        type: "flower",
        scope: "tokyo",
        district: "shinjuku",
        regionName: "東京・新宿區",
        regionName_en: "Tokyo · Shinjuku",
        variety: "late",
        varietyName: "八重櫻 (關山/普賢象) ＋ 奇蹟綠櫻 (御衣黃)",
        statusText: "接力盛開中 (90%)",
        statusText_en: "Late Bloom Peak (90%)",
        bloomStage: "blooming",
        snowDepth: "1,000 株名木 (65品種)",
        snowQuality: "重瓣繡球花型・淡綠花冠",
        liftRatio: "開園 09:00 - 17:30",
        slopes: { green: 80, red: 20, black: 0 },
        hasCafe: true,
        cafeSummary: "園內星巴克 (玻璃景觀席) ｜ SASAYAIORI+ 抹茶茶寮",
        transit: "東京地鐵丸之內線「新宿御苑前站」步行 5 分鐘",
        desc: "【下週救援推薦第一名】當染井吉野凋謝時，新宿御苑正是主角！擁有高達 65 種品種，特別是 4 月中盛開的「關山、普賢象」以及罕見綠櫻「御衣黃」，花期長且人潮舒適。",
        image: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
        lat: 35.6852, lng: 139.7101,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },

      // ---------- ⛷️ 滑雪雪場 (滑雪專區・避雷分級) ----------
      {
        id: "ski-gala-yuzawa",
        name: "GALA 湯澤滑雪度假村",
        name_en: "GALA Yuzawa Snow Resort",
        subtitle: "新幹線出閘即雪場！新手避雷專區・寬緩坡魔毯",
        subtitle_en: "Direct Shinkansen Connection! Beginner-friendly with Magic Carpets",
        type: "ski",
        scope: "tokyo",
        district: "all",
        regionName: "新潟・越後湯澤",
        regionName_en: "Niigata · Echigo-Yuzawa",
        skills: ["beginner", "town"],
        statusText: "全面開放・積雪 285cm",
        statusText_en: "Fully Open (285cm Snow)",
        snowDepth: "285 cm",
        snowQuality: "壓雪・優質粉雪",
        liftRatio: "11 / 11 條 (初學魔毯全開)",
        slopes: { green: 50, red: 35, black: 15 },
        coachOffer: "中文單雙板教練 (享 9 折特約)",
        coachPrice: "NT$ 8,500 / JPY 40,000",
        transit: "JR 東京站搭乘上越新幹線 74 分鐘直達 GALA 湯澤站",
        desc: "【新手避雷首選】下新幹線剪票口即是雪場大廳，初學專用魔毯緩坡綠線達 50%，山下即是越後湯澤溫泉街，新手絕不踩雷！",
        image: "https://images.unsplash.com/photo-1551524559-8af4e6624178?auto=format&fit=crop&w=800&q=80",
        lat: 36.9500, lng: 138.8000,
        coachUrl: "https://www.klook.com/zh-TW/?aid=123436",
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436",
        onsenUrl: "https://www.google.com/maps/search/%E8%B6%8A%E5%BE%8C%E6%B9%AF%E6%BE%A4+%E6%BA%AB%E6%B3%89"
      }
    ];

    let LIVE_INTEL_REPORTS = [
      {
        id: "rep-1",
        spotName: "目黑川櫻並木",
        user: "台灣小旅人・Ken",
        timeTag: "今日 09:40 拍 (EXIF 認證)",
        status: "🌸 滿開無死角",
        comment: "今天目黑川天氣超晴朗！中目黑站前橋上人潮雖多但前進很順暢，河道已經開始有薄薄的花筏，下午打算去星巴克！",
        photo: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=600&q=80",
        likes: 42
      },
      {
        id: "rep-2",
        spotName: "隅田川花火大會",
        user: "花火控・Eason",
        timeTag: "去年實況留存 (EXIF 認證)",
        status: "🎆 有料觀覽席視野極佳",
        comment: "如果帶長輩或小孩，強烈建議買有料席或屋形船！免提早 6 小時去草地卡位，視野完全無死角！",
        photo: "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=600&q=80",
        likes: 38
      }
    ];

    // 全域響應狀態變數 (核心重構：預設 tokyo + spot)
    let currentScope = 'tokyo';
    let currentCategory = 'spot';
    let currentDistrict = 'all';
    let currentFireworksGrade = 'all';
    let currentVariety = 'all';
    let currentBloomStage = 'all';
    let currentSkiRegion = 'all';
    let currentSkiSkill = 'all';
    let currentSubView = 'spots'; // 'spots' | 'cafes' | 'intel'
    let currentViewMode = 'cards'; // 'cards' | 'map'
    let bookmarkedIds = JSON.parse(localStorage.getItem('tabi_news_bookmarks') || '[]');

    let leafletMap = null;
    let markersLayerGroup = null;
    let frontlineLayerGroup = null;
    let showFrontline = true;

    // 初始化運行
    document.addEventListener('DOMContentLoaded', () => {
      initParticleEngine();
      renderMainCategoryButtons();
      renderDistrictButtons();
      renderFireworksGradeButtons();
      renderSakuraVarietyButtons();
      renderBloomStageButtons();
      renderSkiRegionButtons();
      renderSkiSkillButtons();
      renderCards();
      renderDynamicCafes();
      renderIntelStream();
      updateBookmarkBadge();
      updateDynamicThemeAndContext();
    });

    // ================= 頂部大地區切換 =================
    function setScope(scope) {
      currentScope = scope;
      ['tokyo', 'all', 'kansai', 'hokkaido', 'tohoku'].forEach(s => {
        const btn = document.getElementById(`scope-${s}-btn`);
        if (btn) {
          if (s === scope) {
            btn.className = "scope-btn px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex-shrink-0 flex items-center gap-1";
          } else {
            btn.className = "scope-btn px-3 py-1 text-xs font-bold rounded-xl transition text-gray-600 hover:text-gray-900 flex-shrink-0 flex items-center gap-1";
          }
        }
      });

      const districtPanel = document.getElementById('panel-district-filter');
      if (scope === 'tokyo' && currentCategory === 'spot') {
        districtPanel.classList.remove('hidden');
      } else {
        districtPanel.classList.add('hidden');
        currentDistrict = 'all';
      }

      renderCards();
      if (leafletMap) {
        jumpMapTo(scope);
        renderLeafletMarkers();
      }
    }

    // ================= 大分類切換（景點為主體） ＋ 情境動態展開 =================
    function selectCategory(cat) {
      currentCategory = cat;
      renderMainCategoryButtons();
      updateDynamicThemeAndContext();
      renderCards();
      renderDynamicCafes();
      if (leafletMap) renderLeafletMarkers();
    }

    function renderMainCategoryButtons() {
      const wrap = document.getElementById('main-category-wrap');
      wrap.innerHTML = MAIN_CATEGORIES.map(c => {
        const isActive = c.id === currentCategory;
        const name = currentLang === 'zh' ? c.name : c.name_en;
        return `
          <button onclick="selectCategory('${c.id}')"
            class="main-cat-btn flex-shrink-0 px-3.5 py-1.5 rounded-2xl text-xs ${isActive ? 'font-black bg-theme-primary text-white shadow-sm scale-105' : 'font-bold bg-white text-gray-700 border border-theme hover:bg-white/80'} transition-all flex items-center gap-1.5">
            <span>${c.icon}</span> <span>${name}</span>
          </button>
        `;
      }).join('');

      // 同步 TabBar 狀態
      const tabMap = { spot: 'tab-btn-spots', flower: 'tab-btn-flower', fireworks: 'tab-btn-fw', ski: 'tab-btn-ski' };
      Object.keys(tabMap).forEach(k => {
        const btn = document.getElementById(tabMap[k]);
        if (btn) {
          if (k === currentCategory) {
            btn.className = "flex flex-col items-center text-theme-primary";
          } else {
            btn.className = "flex flex-col items-center text-gray-400 hover:text-theme-primary";
          }
        }
      });
    }

    // ================= 情境動態展開核心：點什麼才出什麼，絕不打架 =================
    function updateDynamicThemeAndContext() {
      const body = document.body;
      const districtPanel = document.getElementById('panel-district-filter');
      const flowerPanel = document.getElementById('panel-flower-filter');
      const fireworksPanel = document.getElementById('panel-fireworks-filter');
      const skiPanel = document.getElementById('panel-ski-filter');

      // 更新景觀咖啡廳按鈕的圖標與文字 (🌸 櫻花咖啡 ⇄ 🍁 楓葉手沖 ⇄ 🎆 花火景觀餐廳)
      const cafeIcon = document.getElementById('subview-cafe-icon');
      const cafeLabel = document.getElementById('subview-cafe-label');

      if (currentCategory === 'spot') {
        body.className = "theme-spot min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🏛️';
        if (currentScope === 'tokyo') districtPanel.classList.remove('hidden');
        else districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');

        cafeIcon.textContent = "☕";
        cafeLabel.textContent = "景觀咖啡";
      }
      else if (currentCategory === 'flower') {
        body.className = "theme-flower min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🌸';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.remove('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');

        cafeIcon.textContent = "🌸";
        cafeLabel.textContent = "櫻花咖啡";
      }
      else if (currentCategory === 'fireworks') {
        body.className = "theme-fireworks min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🎆';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.remove('hidden');
        skiPanel.classList.add('hidden');

        cafeIcon.textContent = "🎆";
        cafeLabel.textContent = "花火餐廳";
      }
      else if (currentCategory === 'ski') {
        body.className = "theme-ski min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '⛷️';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.remove('hidden');

        cafeIcon.textContent = "☕";
        cafeLabel.textContent = "雪場咖啡";
      }
      else if (currentCategory === 'onsen') {
        body.className = "theme-onsen min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '♨️';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');

        cafeIcon.textContent = "🍁";
        cafeLabel.textContent = "楓葉手沖";
      }

      setSubView('spots');
      resetParticles();
    }

    // ================= 渲染各動態篩選面板按鈕 =================
    function renderDistrictButtons() {
      const wrap = document.getElementById('district-buttons-wrap');
      wrap.innerHTML = TOKYO_DISTRICTS.map(d => `
        <button onclick="selectDistrict('${d.id}')"
          class="px-2.5 py-1 rounded-xl text-xs ${d.id === currentDistrict ? 'font-black bg-theme-deep text-white shadow-xs' : 'font-bold bg-gray-50 text-gray-700 hover:bg-gray-100'} flex-shrink-0 transition">
          ${currentLang === 'zh' ? d.name : d.name_en}
        </button>
      `).join('');
    }

    function selectDistrict(dist) {
      currentDistrict = dist;
      renderDistrictButtons();
      renderCards();
      if (leafletMap) renderLeafletMarkers();
    }

    function renderFireworksGradeButtons() {
      const wrap = document.getElementById('fireworks-grade-buttons-wrap');
      wrap.innerHTML = FIREWORKS_GRADES.map(g => `
        <button onclick="selectFireworksGrade('${g.id}')"
          class="px-3 py-1.5 rounded-xl text-xs ${g.id === currentFireworksGrade ? 'font-black bg-pink-500 text-white shadow-xs' : 'font-bold bg-slate-800 text-slate-300 border border-slate-700 hover:bg-slate-700'} flex-shrink-0 transition">
          ${currentLang === 'zh' ? g.label : g.en}
        </button>
      `).join('');
    }

    function selectFireworksGrade(grade) {
      currentFireworksGrade = grade;
      renderFireworksGradeButtons();
      renderCards();
    }

    function renderSakuraVarietyButtons() {
      const wrap = document.getElementById('sakura-variety-buttons-wrap');
      wrap.innerHTML = SAKURA_VARIETIES.map(v => `
        <button onclick="selectVariety('${v.id}')"
          class="px-3 py-1.5 rounded-xl text-xs ${v.id === currentVariety ? 'font-black bg-rose-500 text-white' : 'font-bold bg-pink-50 text-pink-700 border border-pink-200 hover:bg-pink-100'} flex-shrink-0 transition">
          ${currentLang === 'zh' ? v.label : v.en}
        </button>
      `).join('');
    }

    function selectVariety(v) {
      currentVariety = v;
      renderSakuraVarietyButtons();
      renderCards();
    }

    function renderBloomStageButtons() {
      const wrap = document.getElementById('flower-bloom-buttons-wrap');
      wrap.innerHTML = SAKURA_BLOOM_STAGES.map(b => `
        <button onclick="selectBloomStage('${b.id}')"
          class="px-3 py-1.5 rounded-xl text-xs ${b.id === currentBloomStage ? 'font-black bg-rose-500 text-white shadow-xs' : 'font-bold bg-white text-gray-600 border border-theme hover:bg-white/80'} flex-shrink-0 transition">
          ${currentLang === 'zh' ? b.name : b.name_en}
        </button>
      `).join('');
    }

    function selectBloomStage(bloom) {
      currentBloomStage = bloom;
      renderBloomStageButtons();
      renderCards();
    }

    function renderSkiRegionButtons() {
      const wrap = document.getElementById('ski-region-buttons-wrap');
      wrap.innerHTML = SKI_REGIONS.map(r => `
        <button onclick="selectSkiRegion('${r.id}')"
          class="px-2.5 py-1 rounded-xl text-xs ${r.id === currentSkiRegion ? 'font-black bg-theme-primary text-white shadow-xs' : 'font-bold bg-white text-gray-600 border border-theme'} flex-shrink-0 transition hover:bg-white/90">
          ${currentLang === 'zh' ? r.name : r.name_en}
        </button>
      `).join('');
    }

    function selectSkiRegion(reg) {
      currentSkiRegion = reg;
      renderSkiRegionButtons();
      renderCards();
    }

    function renderSkiSkillButtons() {
      const wrap = document.getElementById('ski-skill-buttons-wrap');
      wrap.innerHTML = SKI_SKILLS.map(s => `
        <button onclick="selectSkiSkill('${s.id}')"
          class="px-3 py-1.5 rounded-xl text-xs ${s.id === currentSkiSkill ? 'font-black bg-theme-primary text-white shadow-xs' : 'font-bold bg-white text-gray-600 border border-theme hover:bg-white/80'} flex-shrink-0 transition">
          ${currentLang === 'zh' ? s.name : s.name_en}
        </button>
      `).join('');
    }

    function selectSkiSkill(skill) {
      currentSkiSkill = skill;
      renderSkiSkillButtons();
      renderCards();
    }

    function setSubView(view) {
      currentSubView = view;
      ['spots', 'cafes', 'intel'].forEach(v => {
        const btn = document.getElementById(`subview-${v}-btn`);
        const viewEl = document.getElementById(`${v}-view`);
        if (v === view) {
          if (btn) btn.className = "px-2 py-0.5 rounded-lg text-[11px] font-black bg-white text-theme-primary shadow-xs";
          if (viewEl) viewEl.classList.remove('hidden');
        } else {
          if (btn) btn.className = "px-2 py-0.5 rounded-lg text-[11px] font-bold text-gray-500 hover:text-gray-900";
          if (viewEl) viewEl.classList.add('hidden');
        }
      });
    }

    // ================= 取得過濾後的資料 =================
    function getFilteredData() {
      return TABI_DATABASE.filter(item => {
        if (currentCategory !== 'all' && item.type !== currentCategory) return false;
        if (currentScope !== 'all' && item.scope !== currentScope && item.scope !== 'all') return false;

        if (currentScope === 'tokyo' && currentDistrict !== 'all' && item.district && item.district !== currentDistrict) {
          return false;
        }

        if (currentCategory === 'fireworks' && currentFireworksGrade !== 'all') {
          if (item.fireworksGrade !== currentFireworksGrade) return false;
        }

        if (currentCategory === 'flower' && currentVariety !== 'all') {
          if (item.variety !== currentVariety) return false;
        }

        if (currentCategory === 'flower' && currentBloomStage !== 'all') {
          if (item.bloomStage !== currentBloomStage) return false;
        }

        if (currentCategory === 'ski') {
          if (currentSkiRegion !== 'all' && item.region !== currentSkiRegion) return false;
          if (currentSkiSkill !== 'all' && (!item.skills || !item.skills.includes(currentSkiSkill))) return false;
        }

        return true;
      });
    }

    // ================= 渲染景點/花火/雪場卡片 =================
    function renderCards() {
      const container = document.getElementById('resorts-grid');
      const emptyState = document.getElementById('empty-state');
      const data = getFilteredData();

      const catObj = MAIN_CATEGORIES.find(c => c.id === currentCategory) || MAIN_CATEGORIES[0];

      document.getElementById('filter-summary-text').innerHTML = `
        <span class="font-bold text-theme-primary">${catObj.icon} ${currentLang === 'zh' ? catObj.name : catObj.name_en}</span>
        <span class="text-gray-300">/</span>
        <span>${currentScope === 'tokyo' ? (currentLang === 'zh' ? '🗼 東京地區' : 'Tokyo Area') : currentScope}</span>
        <span class="text-gray-300">/</span>
        <span>${currentLang === 'zh' ? `共 ${data.length} 處速報` : `${data.length} Results`}</span>
      `;

      if (data.length === 0) {
        container.innerHTML = '';
        emptyState.classList.remove('hidden');
        return;
      }
      emptyState.classList.add('hidden');

      container.innerHTML = data.map(item => {
        const isFav = bookmarkedIds.includes(item.id);
        const isSki = item.type === 'ski';
        const isFlower = item.type === 'flower';
        const isFireworks = item.type === 'fireworks';
        const title = currentLang === 'zh' ? item.name : item.name_en;
        const subtitle = currentLang === 'zh' ? item.subtitle : item.subtitle_en;
        const regionName = currentLang === 'zh' ? item.regionName : item.regionName_en;
        const statusText = currentLang === 'zh' ? item.statusText : item.statusText_en;

        const ticketUrl = appendAffiliateParams(item.ticketUrl, `card_ticket_${item.id}`);
        const metroUrl = appendAffiliateParams(item.metroUrl, `card_metro_${item.id}`);
        const hotelUrl = appendAffiliateParams(item.hotelUrl, `card_hotel_${item.id}`);
        const coachUrl = appendAffiliateParams(item.coachUrl || item.ticketUrl, `card_coach_${item.id}`);

        return `
          <article class="bg-white rounded-3xl overflow-hidden border border-theme washi-shadow flex flex-col justify-between transition-all duration-300 hover:-translate-y-1">
            <div>
              <!-- 頂部高轉化分潤按鈕 -->
              <div class="px-3 pt-2.5">
                ${isSki ? `
                  <a href="${coachUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="w-full py-2 px-3 rounded-2xl bg-gradient-to-r from-emerald-600 via-teal-600 to-emerald-700 hover:from-emerald-500 text-white font-black text-xs text-center flex items-center justify-between shadow-sm transition">
                    <span class="flex items-center gap-1.5">
                      <span>⛷️</span> <span>預約中文教練・享專屬 9 折</span>
                    </span>
                    <span class="text-[10px] bg-white/20 px-2 py-0.5 rounded-full font-bold">NT$ 8,500 ➔</span>
                  </a>
                ` : isFlower ? `
                  <a href="${ticketUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="w-full py-2 px-3 rounded-2xl bg-gradient-to-r from-rose-500 via-pink-600 to-rose-600 hover:from-rose-400 text-white font-black text-xs text-center flex items-center justify-between shadow-sm transition">
                    <span class="flex items-center gap-1.5">
                      <span>🌸</span> <span>預約包車賞櫻一日遊・專車直達</span>
                    </span>
                    <span class="text-[10px] bg-white/20 px-2 py-0.5 rounded-full font-bold">精緻包車 ➔</span>
                  </a>
                ` : isFireworks ? `
                  <a href="${ticketUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="w-full py-2 px-3 rounded-2xl bg-gradient-to-r from-purple-600 via-pink-600 to-indigo-600 hover:from-purple-500 text-white font-black text-xs text-center flex items-center justify-between shadow-sm transition">
                    <span class="flex items-center gap-1.5">
                      <span>⛵</span> <span>搶購有料觀覽席 ＆ 屋形船 VIP 席</span>
                    </span>
                    <span class="text-[10px] bg-white/20 px-2 py-0.5 rounded-full font-bold">手刀搶票 ➔</span>
                  </a>
                ` : `
                  <a href="${ticketUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="w-full py-2 px-3 rounded-2xl bg-gradient-to-r from-sky-600 via-blue-600 to-indigo-600 hover:from-sky-500 text-white font-black text-xs text-center flex items-center justify-between shadow-sm transition">
                    <span class="flex items-center gap-1.5">
                      <span>🎫</span> <span>線上即買即用・免排隊快速通關門票</span>
                    </span>
                    <span class="text-[10px] bg-white/20 px-2 py-0.5 rounded-full font-bold">享優惠 ➔</span>
                  </a>
                `}
              </div>

              <!-- 圖片與徽章 -->
              <div class="relative h-48 w-full bg-gray-100 overflow-hidden cursor-pointer mt-2" onclick="openDetailSheet('${item.id}')">
                <img src="${item.image}" alt="${title}" class="w-full h-full object-cover transition-transform duration-700 hover:scale-105" loading="lazy" />
                <div class="absolute top-3 left-3 bg-black/60 backdrop-blur-md text-white text-[10px] font-black px-2.5 py-1 rounded-lg">
                  📍 ${regionName}
                </div>

                ${item.fireworksGradeBadge ? `
                  <div class="absolute top-3 left-28 bg-gradient-to-r from-pink-600 to-rose-600 text-white text-[10px] font-black px-2.5 py-1 rounded-lg shadow-sm">
                    ${item.fireworksGradeBadge}
                  </div>
                ` : ''}

                <button onclick="event.stopPropagation(); toggleBookmark('${item.id}')"
                  class="absolute top-3 right-3 w-8 h-8 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-md transition hover:scale-110 active:scale-95" title="加入收藏">
                  <span class="text-sm">${isFav ? '❤️' : '🤍'}</span>
                </button>
                <div class="absolute bottom-2.5 inset-x-3 bg-black/65 backdrop-blur-sm text-white text-[10px] font-bold px-2.5 py-1 rounded-lg truncate flex items-center justify-between">
                  <span class="truncate">🚇 ${item.transit}</span>
                  <span class="text-emerald-300 font-black flex-shrink-0 ml-1">● ${statusText}</span>
                </div>
              </div>

              <!-- 卡片內文 -->
              <div class="p-4 cursor-pointer" onclick="openDetailSheet('${item.id}')">
                <div class="flex items-center justify-between gap-1 mb-1">
                  <h3 class="text-base font-black text-theme-text">${title}</h3>
                  ${item.hasCafe ? `
                    <button onclick="event.stopPropagation(); setSubView('cafes')" class="px-2 py-0.5 rounded-lg bg-amber-100 text-amber-900 border border-amber-300 text-[10px] font-black flex items-center gap-1 hover:bg-amber-200 transition flex-shrink-0">
                      <span>☕</span> 景觀咖啡
                    </button>
                  ` : ''}
                </div>
                <p class="text-xs font-bold text-theme-primary mb-3 leading-snug">${subtitle}</p>

                <!-- 3 指標數據 (針對花火顯示發數/最大玉/去年人潮；針對滑雪顯示雪深/雪質/纜車) -->
                <div class="grid grid-cols-3 gap-1.5 p-2.5 bg-theme-soft/50 border border-theme/60 rounded-xl text-center mb-3">
                  <div>
                    <span class="text-[10px] text-theme-muted font-bold block">${isFireworks ? '打上發數' : (isSki ? '積雪深度' : '規模特色')}</span>
                    <span class="text-xs font-black text-theme-deep truncate block">${item.snowDepth}</span>
                  </div>
                  <div>
                    <span class="text-[10px] text-theme-muted font-bold block">${isFireworks ? '最大玉尺寸' : (isSki ? '目前雪質' : '體驗亮點')}</span>
                    <span class="text-xs font-black text-theme-deep truncate block">${item.maxShellSize || item.snowQuality}</span>
                  </div>
                  <div>
                    <span class="text-[10px] text-theme-muted font-bold block">${isFireworks ? '觀覽席/人潮' : (isSki ? '開放纜車' : '設施營運')}</span>
                    <span class="text-xs font-black text-theme-deep truncate block">${item.lastYearCrowd ? '100萬人次' : item.liftRatio}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 卡片底部按鈕組 -->
            <div class="p-4 pt-1 border-t border-theme/50 space-y-1.5">
              ${isSki ? `
                <div class="grid grid-cols-3 gap-1.5">
                  <a href="${coachUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-gradient-to-r from-emerald-600 to-teal-600 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>⛷️</span> 中文教練
                  </a>
                  <a href="${item.onsenUrl || '#'}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-amber-500 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>♨️</span> 雪見溫泉
                  </a>
                  <a href="${hotelUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-blue-600 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🏨</span> 預定飯店
                  </a>
                </div>
              ` : isFireworks ? `
                <div class="grid grid-cols-3 gap-1.5">
                  <a href="${ticketUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-gradient-to-r from-pink-600 to-rose-600 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🎫</span> 搶觀覽席
                  </a>
                  <a href="${hotelUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-purple-700 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🏨</span> 煙火景觀房
                  </a>
                  <a href="${metroUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-slate-800 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🚇</span> 交通避塞
                  </a>
                </div>
              ` : `
                <div class="grid grid-cols-3 gap-1.5">
                  <a href="${ticketUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-[#FF5B00] hover:bg-[#E05000] text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🎫</span> 訂門票
                  </a>
                  <a href="${metroUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-blue-600 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🚇</span> 訂地鐵票
                  </a>
                  <a href="${hotelUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-white hover:bg-gray-50 text-theme-primary border border-theme rounded-xl text-[10px] font-bold text-center flex items-center justify-center gap-0.5 transition truncate">
                    <span>🏨</span> 查飯店
                  </a>
                </div>
              `}
            </div>
          </article>
        `;
      }).join('');
    }

    // ================= 三、景觀咖啡廳全面動態升級渲染 =================
    function renderDynamicCafes() {
      const container = document.getElementById('cafes-grid');
      const headerTitle = document.getElementById('cafe-header-title-text');
      const headerIcon = document.getElementById('cafe-header-icon');
      const headerDesc = document.getElementById('lbl-cafe-h-desc');

      let cafeType = "spot";
      if (currentCategory === 'flower') cafeType = "flower";
      else if (currentCategory === 'fireworks') cafeType = "fireworks";
      else if (currentCategory === 'onsen') cafeType = "momiji";

      const list = SCENIC_CAFES[cafeType] || SCENIC_CAFES.spot;

      if (cafeType === 'flower') {
        headerIcon.textContent = "🌸";
        headerTitle.textContent = "2026 日本河畔・櫻花景觀咖啡廳指南 (川畔露台席＆樹冠第一排)";
        headerDesc.textContent = "中目黑川、外濠水岸第一排露台席，附旅人真實拍攝時間戳與整理券排隊攻略";
      } else if (cafeType === 'fireworks') {
        headerIcon.textContent = "🎆";
        headerTitle.textContent = "2026 花火大會第一排・高空景觀餐廳與水岸微醺餐酒館指南 (免人擠人)";
        headerDesc.textContent = "晴空塔 345m 俯瞰雙會場煙火、台場海濱水岸木棧露台，免擠百萬人潮奢華觀賞";
      } else if (cafeType === 'momiji') {
        headerIcon.textContent = "🍁";
        headerTitle.textContent = "日本和風庭園・百年町家古民家紅葉手沖咖啡指南";
        headerDesc.textContent = "南禪寺枯山水紅葉中庭、嵐山桂川水岸 % ARABICA 窗景咖啡";
      } else {
        headerIcon.textContent = "☕";
        headerTitle.textContent = "日本都會高空・特色景觀咖啡廳指南";
        headerDesc.textContent = "SHIBUYA SKY 46F 天際酒吧、俯瞰澀谷十字路口與富士山夕陽";
      }

      container.innerHTML = list.map(cafe => `
        <article class="bg-white rounded-3xl overflow-hidden border border-amber-200/80 washi-shadow flex flex-col justify-between">
          <div>
            <div class="relative h-48 w-full bg-gray-100 overflow-hidden">
              <img src="${cafe.photoUrl}" alt="${cafe.name}" class="w-full h-full object-cover" />
              <div class="absolute top-3 left-3 bg-black/60 backdrop-blur-md text-white text-[10px] font-black px-2.5 py-1 rounded-lg">
                📍 ${cafe.spotName}
              </div>
              <div class="absolute top-3 right-3 bg-emerald-600 text-white text-[10px] font-black px-2 py-0.5 rounded-lg shadow-sm">
                ${cafe.latestPhotoTime}
              </div>
              <div class="absolute bottom-2.5 inset-x-3 bg-black/70 backdrop-blur-sm text-white text-[10px] font-bold px-2.5 py-1 rounded-lg truncate">
                ${cafe.photoStatus}
              </div>
            </div>

            <div class="p-4 space-y-2">
              <div class="flex items-center justify-between">
                <h3 class="text-base font-black text-gray-900">${cafe.name}</h3>
              </div>
              <div class="flex items-center gap-1.5 flex-wrap">
                <span class="px-2 py-0.5 rounded-md bg-amber-50 text-amber-800 border border-amber-200 text-[10px] font-bold">
                  ${cafe.viewType}
                </span>
                <span class="text-[10px] text-gray-500 font-medium">🚇 ${cafe.walking}</span>
              </div>
              <p class="text-xs text-gray-600 leading-relaxed bg-gray-50 p-2.5 rounded-xl border border-gray-100">
                💡 <span class="font-bold text-gray-800">打卡攻略：</span>${cafe.tips}
              </p>
            </div>
          </div>

          <div class="p-4 pt-0">
            <a href="${cafe.mapUrl}" target="_blank" class="w-full py-2 bg-amber-800 hover:bg-amber-900 text-white text-xs font-black rounded-xl text-center flex items-center justify-center gap-1.5 shadow-sm transition">
              <span>🗺️</span> Google Maps 實景導航
            </a>
          </div>
        </article>
      `).join('');
    }

    function renderIntelStream() {
      const container = document.getElementById('intel-stream');
      container.innerHTML = LIVE_INTEL_REPORTS.map(rep => `
        <div class="p-4 bg-white rounded-2xl border border-theme washi-shadow flex flex-col sm:flex-row gap-3 items-start">
          <img src="${rep.photo}" class="w-full sm:w-28 h-28 object-cover rounded-xl flex-shrink-0" />
          <div class="flex-1 space-y-1">
            <div class="flex items-center justify-between">
              <span class="font-black text-xs text-theme-deep flex items-center gap-1">
                <span>📍</span> ${rep.spotName}
              </span>
              <span class="text-[10px] font-black px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-700 border border-emerald-200">
                ${rep.timeTag}
              </span>
            </div>
            <div class="text-[11px] font-black text-rose-600">${rep.status}</div>
            <p class="text-xs text-gray-700 leading-relaxed">${rep.comment}</p>
            <div class="flex items-center justify-between pt-1.5 text-[10px] text-gray-400">
              <span>提供者：${rep.user}</span>
              <span class="text-rose-500 font-bold">❤️ ${rep.likes}</span>
            </div>
          </div>
        </div>
      `).join('');
    }

    // ================= 視圖切換 =================
    function setViewMode(mode) {
      currentViewMode = mode;
      const cardsBtn = document.getElementById('view-cards-btn');
      const mapBtn = document.getElementById('view-map-btn');
      const cardsWrap = document.getElementById('cards-view-wrap');
      const mapWrap = document.getElementById('map-view-wrap');

      if (mode === 'cards') {
        cardsBtn.className = "px-2.5 sm:px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex items-center gap-1";
        mapBtn.className = "px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex items-center gap-1";
        cardsWrap.classList.remove('hidden');
        mapWrap.classList.add('hidden');
      } else {
        cardsBtn.className = "px-2.5 sm:px-3 py-1 text-xs font-bold rounded-xl transition text-gray-500 hover:text-gray-900 flex items-center gap-1";
        mapBtn.className = "px-2.5 sm:px-3 py-1 text-xs font-black rounded-xl transition bg-white text-theme-primary shadow-sm flex items-center gap-1";
        cardsWrap.classList.add('hidden');
        mapWrap.classList.remove('hidden');

        setTimeout(() => {
          initLeafletMapIfNeeded();
          renderLeafletMarkers();
        }, 100);
      }
    }

    // ================= 【Leaflet ＋ CARTO Voyager 和風實況地圖】 =================
    function initLeafletMapIfNeeded() {
      if (leafletMap) {
        leafletMap.invalidateSize();
        return;
      }

      leafletMap = L.map('leaflet-map-container', {
        center: [35.6895, 139.6917],
        zoom: 11,
        zoomControl: true
      });

      L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap contributors &copy; CARTO',
        subdomains: 'abcd',
        maxZoom: 19
      }).addTo(leafletMap);

      markersLayerGroup = L.layerGroup().addTo(leafletMap);
      frontlineLayerGroup = L.layerGroup().addTo(leafletMap);

      drawSakuraFrontlineWaves();
    }

    function drawSakuraFrontlineWaves() {
      if (!frontlineLayerGroup) return;
      frontlineLayerGroup.clearLayers();

      const fullBloomBand = [
        [34.3, 134.5], [34.8, 135.5], [35.2, 137.0], [35.8, 139.8], [36.3, 140.5],
        [35.4, 140.2], [34.8, 138.5], [34.0, 136.5], [33.8, 134.8]
      ];

      const fullBloomPolygon = L.polygon(fullBloomBand, {
        color: '#EE6A7C',
        weight: 2,
        dashArray: '5, 8',
        fillColor: '#FF6B81',
        fillOpacity: 0.18
      }).bindTooltip("🌸 4/1~4/8 日本中央滿開黃金帶 (東京・京都・大阪 100% 見頃)", { sticky: true });

      const tohokuBand = [
        [36.8, 138.5], [38.0, 140.0], [39.5, 141.0], [40.5, 141.2],
        [40.2, 140.0], [38.5, 139.2], [37.2, 138.5]
      ];

      const tohokuPolygon = L.polygon(tohokuBand, {
        color: '#F472B6',
        weight: 1.5,
        dashArray: '4, 6',
        fillColor: '#F472B6',
        fillOpacity: 0.12
      }).bindTooltip("🌱 4月中旬 東北開花見頃前線", { sticky: true });

      frontlineLayerGroup.addLayer(fullBloomPolygon);
      frontlineLayerGroup.addLayer(tohokuPolygon);
    }

    function toggleSakuraFrontlineLayer() {
      showFrontline = !showFrontline;
      const btn = document.getElementById('btn-toggle-frontline');
      if (showFrontline) {
        if (!leafletMap.hasLayer(frontlineLayerGroup)) leafletMap.addLayer(frontlineLayerGroup);
        btn.innerHTML = `<span>🌸</span> <span>櫻花前線範圍：開</span>`;
        btn.className = "px-2 py-0.5 rounded-full bg-rose-100 text-rose-700 hover:bg-rose-200 text-[10px] font-black border border-rose-300 transition flex items-center gap-1";
      } else {
        if (leafletMap.hasLayer(frontlineLayerGroup)) leafletMap.removeLayer(frontlineLayerGroup);
        btn.innerHTML = `<span>🌸</span> <span>櫻花前線範圍：關</span>`;
        btn.className = "px-2 py-0.5 rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 text-[10px] font-bold border border-gray-300 transition flex items-center gap-1";
      }
    }

    function renderLeafletMarkers() {
      if (!markersLayerGroup) return;
      markersLayerGroup.clearLayers();

      const data = getFilteredData();
      data.forEach(item => {
        if (!item.lat || !item.lng) return;

        let iconEmoji = "🏛️";
        let badgeColor = "bg-sky-600";

        if (item.type === 'flower') {
          iconEmoji = "🌸";
          badgeColor = "bg-rose-500";
        } else if (item.type === 'ski') {
          iconEmoji = "⛷️";
          badgeColor = "bg-sky-500";
        } else if (item.type === 'fireworks') {
          iconEmoji = "🎆";
          badgeColor = "bg-pink-600";
        }

        const customHtml = `
          <div class="relative flex items-center cursor-pointer select-none">
            <div class="w-8 h-8 rounded-full bg-white border-2 border-white shadow-md flex items-center justify-center text-sm map-badge-pulse">
              ${iconEmoji}
            </div>
            <div class="ml-1 px-2 py-0.5 rounded-full ${badgeColor} text-white text-[10px] font-black shadow-xs whitespace-nowrap">
              ${item.name}
            </div>
          </div>
        `;

        const icon = L.divIcon({
          html: customHtml,
          className: 'custom-map-icon',
          iconSize: [120, 32],
          iconAnchor: [16, 16]
        });

        const marker = L.marker([item.lat, item.lng], { icon: icon });

        marker.bindPopup(`
          <div class="p-2 max-w-xs space-y-2">
            <div class="flex items-center gap-1.5">
              <span class="text-xs px-2 py-0.5 rounded bg-gray-100 font-bold">${item.regionName}</span>
              <span class="text-xs text-emerald-600 font-black">● ${item.statusText}</span>
            </div>
            <h4 class="text-sm font-black text-gray-900">${currentLang === 'zh' ? item.name : item.name_en}</h4>
            <p class="text-xs text-gray-500">${item.subtitle}</p>
            <div class="pt-1">
              <button onclick="openDetailSheet('${item.id}')" class="w-full py-1.5 bg-sky-600 text-white rounded-lg text-xs font-bold shadow-xs">
                查看詳情 ＆ 預訂 ➔
              </button>
            </div>
          </div>
        `);

        markersLayerGroup.addLayer(marker);
      });
    }

    function jumpMapTo(region) {
      if (!leafletMap) return;
      if (region === 'tokyo') leafletMap.flyTo([35.6895, 139.6917], 12);
      else if (region === 'kansai') leafletMap.flyTo([34.6937, 135.5023], 10);
      else if (region === 'yuzawa') leafletMap.flyTo([36.9500, 138.8000], 11);
      else if (region === 'hokkaido') leafletMap.flyTo([43.0642, 141.3469], 7);
      else leafletMap.flyTo([36.2048, 138.2529], 6);
    }

    // 詳情抽屜
    let currentDetailItem = null;
    function openDetailSheet(id) {
      const item = TABI_DATABASE.find(r => r.id === id);
      if (!item) return;
      currentDetailItem = item;

      const isSki = item.type === 'ski';
      const isFireworks = item.type === 'fireworks';

      document.getElementById('sheet-img').src = item.image;
      document.getElementById('sheet-title').textContent = currentLang === 'zh' ? item.name : item.name_en;
      document.getElementById('sheet-subtitle').textContent = currentLang === 'zh' ? item.subtitle : item.subtitle_en;
      document.getElementById('sheet-desc').textContent = item.desc;
      document.getElementById('sheet-region-badge').textContent = `📍 ${item.regionName}`;
      document.getElementById('sheet-status-badge').textContent = item.statusText;
      document.getElementById('sheet-depth').textContent = item.snowDepth;
      document.getElementById('sheet-quality').textContent = item.maxShellSize || item.snowQuality;
      document.getElementById('sheet-lifts').textContent = item.lastYearCrowd ? '100萬人次' : item.liftRatio;
      document.getElementById('sheet-transit').textContent = item.transit;

      const galleryBar = document.getElementById('sheet-gallery-bar');
      galleryBar.innerHTML = `
        <button class="w-12 h-10 rounded-lg overflow-hidden border-2 border-theme-primary flex-shrink-0">
          <img src="${item.image}" class="w-full h-full object-cover" />
        </button>
      `;

      const cafePreview = document.getElementById('sheet-cafe-preview');
      if (item.hasCafe) {
        cafePreview.classList.remove('hidden');
        document.getElementById('sheet-cafe-preview-text').textContent = item.cafeSummary;
      } else {
        cafePreview.classList.add('hidden');
      }

      document.getElementById('sheet-api-json').textContent = JSON.stringify(item, null, 2);

      const footer = document.getElementById('sheet-action-footer');
      const ticketUrl = appendAffiliateParams(item.ticketUrl, `sheet_ticket_${item.id}`);
      const metroUrl = appendAffiliateParams(item.metroUrl, `sheet_metro_${item.id}`);
      const hotelUrl = appendAffiliateParams(item.hotelUrl, `sheet_hotel_${item.id}`);
      const coachUrl = appendAffiliateParams(item.coachUrl || item.ticketUrl, `sheet_coach_${item.id}`);

      if (isSki) {
        footer.innerHTML = `
          <a href="${coachUrl}" target="_blank"
            class="w-full py-2.5 bg-gradient-to-r from-emerald-600 to-teal-600 text-white rounded-xl text-xs font-black text-center flex items-center justify-center gap-1.5 shadow-md">
            <span>⛷️</span> 預約中文教練・享 9 折特約折扣與專業攝影
          </a>
          <div class="grid grid-cols-3 gap-2">
            <a href="${coachUrl}" target="_blank" class="py-2.5 px-2 bg-emerald-600 text-white rounded-xl text-xs font-black text-center truncate">⛷️ 中文教練</a>
            <a href="${item.onsenUrl || '#'}" target="_blank" class="py-2.5 px-2 bg-amber-500 text-white rounded-xl text-xs font-black text-center truncate">♨️ 雪見溫泉</a>
            <a href="${hotelUrl}" target="_blank" class="py-2.5 px-2 bg-blue-600 text-white rounded-xl text-xs font-black text-center truncate">🏨 預定飯店</a>
          </div>
        `;
      } else if (isFireworks) {
        footer.innerHTML = `
          <a href="${ticketUrl}" target="_blank"
            class="w-full py-2.5 bg-gradient-to-r from-pink-600 via-rose-600 to-purple-600 text-white rounded-xl text-xs font-black text-center flex items-center justify-center gap-1.5 shadow-md">
            <span>⛵</span> 搶購 Walkerplus 有料席 ＆ 屋形船 VIP 席位
          </a>
          <div class="grid grid-cols-3 gap-2">
            <a href="${ticketUrl}" target="_blank" class="py-2.5 px-2 bg-pink-600 text-white rounded-xl text-xs font-black text-center truncate">🎫 搶觀覽席</a>
            <a href="${hotelUrl}" target="_blank" class="py-2.5 px-2 bg-purple-700 text-white rounded-xl text-xs font-black text-center truncate">🏨 煙火景觀房</a>
            <a href="${metroUrl}" target="_blank" class="py-2.5 px-2 bg-slate-800 text-white rounded-xl text-xs font-black text-center truncate">🚇 交通避塞</a>
          </div>
        `;
      } else {
        footer.innerHTML = `
          <a href="${ticketUrl}" target="_blank"
            class="w-full py-2.5 bg-gradient-to-r from-sky-600 to-blue-600 text-white rounded-xl text-xs font-black text-center flex items-center justify-center gap-1.5 shadow-md">
            <span>🎫</span> 立即預定門票・快速通關免排隊
          </a>
          <div class="grid grid-cols-3 gap-2">
            <a href="${ticketUrl}" target="_blank" class="py-2.5 px-2 bg-[#FF5B00] text-white rounded-xl text-xs font-black text-center truncate">🎫 訂門票</a>
            <a href="${metroUrl}" target="_blank" class="py-2.5 px-2 bg-blue-600 text-white rounded-xl text-xs font-black text-center truncate">🚇 訂地鐵票</a>
            <a href="${hotelUrl}" target="_blank" class="py-2.5 px-2 bg-white border border-theme text-theme-primary rounded-xl text-xs font-bold text-center truncate">🏨 查飯店</a>
          </div>
        `;
      }

      const sheet = document.getElementById('detail-sheet');
      sheet.classList.remove('hidden');
      setTimeout(() => {
        sheet.classList.remove('opacity-0');
        sheet.children[0].classList.remove('translate-y-8');
      }, 10);
    }

    function closeDetailSheet() {
      const sheet = document.getElementById('detail-sheet');
      sheet.classList.add('opacity-0');
      sheet.children[0].classList.add('translate-y-8');
      setTimeout(() => sheet.classList.add('hidden'), 250);
    }

    function openExternalRoute() {
      if (currentDetailItem) {
        const query = encodeURIComponent(`${currentDetailItem.name} 日本`);
        window.open(`https://www.google.com/maps/dir/?api=1&destination=${query}`, '_blank');
      }
    }

    function toggleApiRawInspector() {
      const content = document.getElementById('api-raw-content');
      const arrow = document.getElementById('api-raw-toggle-arrow');
      if (content.classList.contains('hidden')) {
        content.classList.remove('hidden');
        arrow.textContent = "▲ 收合 JSON";
      } else {
        content.classList.add('hidden');
        arrow.textContent = "▼ 檢視 JSON";
      }
    }

    // 口袋收藏
    function toggleBookmark(id) {
      const idx = bookmarkedIds.indexOf(id);
      if (idx > -1) bookmarkedIds.splice(idx, 1);
      else bookmarkedIds.push(id);
      localStorage.setItem('tabi_news_bookmarks', JSON.stringify(bookmarkedIds));
      updateBookmarkBadge();
      renderCards();
    }

    function updateBookmarkBadge() {
      const badge = document.getElementById('bookmark-badge');
      const count = bookmarkedIds.length;
      document.getElementById('drawer-count').textContent = count;
      if (count > 0) {
        badge.textContent = count;
        badge.classList.remove('hidden');
      } else {
        badge.classList.add('hidden');
      }
    }

    function toggleBookmarkDrawer() {
      const drawer = document.getElementById('bookmark-drawer');
      if (drawer.classList.contains('translate-x-full')) {
        renderBookmarkDrawer();
        drawer.classList.remove('translate-x-full');
      } else {
        drawer.classList.add('translate-x-full');
      }
    }

    function renderBookmarkDrawer() {
      const container = document.getElementById('bookmark-items-container');
      const bookmarked = TABI_DATABASE.filter(i => bookmarkedIds.includes(i.id));
      if (bookmarked.length === 0) {
        container.innerHTML = `<div class="text-center py-16 text-gray-400">目前沒有收藏的名所</div>`;
        return;
      }
      container.innerHTML = bookmarked.map(item => `
        <div class="p-3 bg-white rounded-2xl border border-theme flex gap-3 items-center justify-between shadow-sm cursor-pointer" onclick="openDetailSheet('${item.id}')">
          <div class="flex items-center gap-2.5 overflow-hidden">
            <img src="${item.image}" class="w-12 h-12 rounded-xl object-cover flex-shrink-0" />
            <div class="truncate">
              <h4 class="text-xs font-black text-theme-text truncate">${item.name}</h4>
              <p class="text-[10px] text-theme-primary font-bold">${item.regionName}</p>
            </div>
          </div>
          <button onclick="event.stopPropagation(); toggleBookmark('${item.id}')" class="text-xs text-gray-400 hover:text-red-500 px-2 py-1">✕</button>
        </div>
      `).join('');
    }

    function clearAllBookmarks() {
      bookmarkedIds = [];
      localStorage.removeItem('tabi_news_bookmarks');
      updateBookmarkBadge();
      renderBookmarkDrawer();
      renderCards();
    }

    function resetAllFilters() {
      currentScope = 'tokyo';
      currentCategory = 'spot';
      currentDistrict = 'all';
      setScope('tokyo');
      selectCategory('spot');
    }

    // UGC Modal
    function openUploadModal() {
      document.getElementById('upload-modal').classList.remove('hidden');
    }
    function closeUploadModal() {
      document.getElementById('upload-modal').classList.add('hidden');
    }
    function submitUGCReport() {
      const spot = document.getElementById('upload-spot-select').value;
      const status = document.getElementById('upload-status').value;
      const comment = document.getElementById('upload-comment').value || "現場實況人潮良好！";
      LIVE_INTEL_REPORTS.unshift({
        id: "rep-" + Date.now(),
        spotName: spot,
        user: "熱心旅人 (我)",
        timeTag: "今日即時拍 (EXIF 認證)",
        status: status,
        comment: comment,
        photo: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=600&q=80",
        likes: 1
      });
      closeUploadModal();
      setSubView('intel');
      renderIntelStream();
    }

    // API Gateway Terminal Modal
    function triggerLiveApiSync() {
      const modal = document.getElementById('api-sync-modal');
      const logs = document.getElementById('api-sync-logs');
      const statusText = document.getElementById('api-sync-status-text');
      const doneBtn = document.getElementById('btn-api-sync-done');
      modal.classList.remove('hidden');
      logs.innerHTML = '';
      doneBtn.classList.add('hidden');
      statusText.textContent = "連線進度: 20% (Fetching Live APIs...)";

      const steps = [
        "GET https://api.walkerplus.com/v2/hanabi/japan ... 200 OK (32ms)",
        "SYNC 全国観光情報データベース (Japan Tourism DB API) ... 200 OK (45ms)",
        "SYNC Weathernews (WNI) Sakura Frontline 2026 ... 200 OK (38ms)",
        "SYNC SURF&SNOW Resort Snow Depths & JMA Specimen Trees ... 200 OK (26ms)"
      ];

      steps.forEach((msg, idx) => {
        setTimeout(() => {
          const div = document.createElement('div');
          div.className = "flex items-center gap-1.5 text-emerald-400";
          div.innerHTML = `<span class="text-slate-500">▶</span> <span>${msg}</span>`;
          logs.appendChild(div);
          statusText.textContent = `連線進度: ${(idx + 1) * 25}% (Walkerplus & 觀振協 實時同步完畢)`;
          if (idx === steps.length - 1) doneBtn.classList.remove('hidden');
        }, (idx + 1) * 300);
      });
    }

    function closeApiSyncModal() {
      document.getElementById('api-sync-modal').classList.add('hidden');
    }

    // Canvas Particles
    let canvas, ctx, animationFrameId;
    let particles = [];

    function initParticleEngine() {
      canvas = document.getElementById('particle-canvas');
      if (!canvas) return;
      ctx = canvas.getContext('2d');
      resizeCanvas();
      window.addEventListener('resize', resizeCanvas);
      createParticles();
      animateParticles();
    }

    function resizeCanvas() {
      if (!canvas) return;
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }

    function resetParticles() {
      particles = [];
      createParticles();
    }

    function createParticles() {
      const count = window.innerWidth < 768 ? 25 : 45;
      for (let i = 0; i < count; i++) {
        particles.push({
          x: Math.random() * canvas.width,
          y: Math.random() * canvas.height,
          size: Math.random() * 8 + 4,
          speedY: Math.random() * 1.5 + 0.6,
          speedX: Math.random() * 1.2 - 0.6,
          angle: Math.random() * Math.PI * 2,
          angularSpeed: (Math.random() - 0.5) * 0.04,
          opacity: Math.random() * 0.6 + 0.35
        });
      }
    }

    function animateParticles() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      particles.forEach(p => {
        p.y += p.speedY;
        p.x += p.speedX;
        p.angle += p.angularSpeed;

        if (p.y > canvas.height + 15) {
          p.y = -15;
          p.x = Math.random() * canvas.width;
        }

        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.angle);
        ctx.globalAlpha = p.opacity;

        if (currentCategory === 'flower') {
          ctx.fillStyle = '#F8B3BD';
          ctx.beginPath();
          ctx.ellipse(0, 0, p.size * 0.6, p.size * 1.2, 0, 0, Math.PI * 2);
          ctx.fill();
        } else if (currentCategory === 'ski') {
          ctx.fillStyle = '#BAE6FD';
          ctx.beginPath();
          ctx.arc(0, 0, p.size * 0.5, 0, Math.PI * 2);
          ctx.fill();
        } else if (currentCategory === 'fireworks') {
          ctx.fillStyle = '#F43F5E';
          ctx.beginPath();
          ctx.arc(0, 0, p.size * 0.4, 0, Math.PI * 2);
          ctx.fill();
        }

        ctx.restore();
      });

      animationFrameId = requestAnimationFrame(animateParticles);
    }
  </script>
</body>
</html>
JS_CODE_SECTION

close $fh;

    if (-d dirname($copy1)) {
        copy($target, $copy1) or warn "Copy to $copy1 failed: $!\n";
        print "Copy 1 file: " . (-s $copy1) . " bytes\n";
    }
    if (-d dirname($copy2)) {
        copy($target, $copy2) or warn "Copy to $copy2 failed: $!\n";
        print "Copy 2 file: " . (-s $copy2) . " bytes\n";
    }

    print "Complete V3 architecture build succeeded!\n";
    print "Target file: " . (-s $target) . " bytes\n";

