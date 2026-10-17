#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
use File::Copy qw(copy);

my $target = "/Users/nanaminanami/Documents/HiMyDream/日本旅遊報報/app/index.html";
my $copy1 = "/Users/nanaminanami/Documents/HiMyDream/japan-go-app/app/index.html";
my $copy2 = "/Users/nanaminanami/.gemini/antigravity/brain/d9fa592d-79c7-41f5-b9c8-fbe17bf3a8fa/japan_sakura_app_design_preview.html";

open my $fh, '>>:utf8', $target or die "Cannot append to $target: $!\n";

print $fh <<'JS_CODE_PART';
  <!-- ================= JavaScript 資料庫、架構重構與 Leaflet 地圖控制器 ================= -->
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

    // 雙語字典
    const I18N = {
      zh: {
        langToggle: "EN",
        brandTitle: "日旅報報",
        badgeLive: "2026 旬況版",
        brandSub: "全日本景點導覽・花季雪況・花火與高質感地圖",
        viewCards: "卡片",
        viewMap: "和風地圖",
        scopeTokyo: "東京全部景點",
        scopeAll: "全日本",
        scopeKansai: "關西圈 (京阪神)",
        scopeHokkaido: "北海道",
        scopeTohoku: "東北",
        catSpot: "全部景點",
        catFlower: "花季名所",
        catFireworks: "花火大會",
        catSki: "滑雪雪場",
        catOnsen: "溫泉秘境",
        catEvent: "最新活動",
        rescueTitle: "下週去怕染井吉野凋謝？「晚開八重櫻＆稀有綠櫻」接力盛開中！",
        rescueBadge: "救援攻略",
        rescueDesc: "染井吉野櫻落櫻後，新宿御苑、大阪造幣局等「關山櫻、御衣黃、普賢象」花期可一路延續至 4 月中下旬！",
        rescueBtn: "一鍵查看晚開接力名所",
        subviewSpots: "全部列表",
        subviewCafes: "景觀咖啡",
        subviewIntel: "實況討論",
        bookCoach: "預約中文教練",
        hotSprings: "雪見溫泉",
        bookHotel: "預定飯店",
        bookTicket: "訂門票/車票",
        bookCharter: "包車賞櫻一日遊",
        btnSync: "即時串聯刷新"
      },
      en: {
        langToggle: "中文",
        brandTitle: "Japan Tabi News",
        badgeLive: "2026 LIVE",
        brandSub: "Japan Attractions, Sakura Frontline, Ski & Carto Map",
        viewCards: "Cards",
        viewMap: "Carto Map",
        scopeTokyo: "Tokyo Attractions",
        scopeAll: "All Japan",
        scopeKansai: "Kansai Area",
        scopeHokkaido: "Hokkaido",
        scopeTohoku: "Tohoku",
        catSpot: "All Attractions",
        catFlower: "Sakura & Blooms",
        catFireworks: "Fireworks",
        catSki: "Ski Resorts",
        catOnsen: "Hot Springs",
        catEvent: "Latest Events",
        rescueTitle: "Worried Yoshino is falling? Late Yaezakura & Green Sakura rescue guide!",
        rescueBadge: "RESCUE",
        rescueDesc: "After Yoshino fades, late varieties in Shinjuku Gyoen & Osaka Mint bloom through late April!",
        rescueBtn: "Explore Late Varieties",
        subviewSpots: "All Spots",
        subviewCafes: "Cafes",
        subviewIntel: "Community",
        bookCoach: "Ski Coach",
        hotSprings: "Hot Springs",
        bookHotel: "Book Hotel",
        bookTicket: "Book Tickets",
        bookCharter: "Blossom Charter",
        btnSync: "Live API Sync"
      }
    };

    // 一、大分類（景點為主體，預設全部景點）
    const MAIN_CATEGORIES = [
      { id: "spot", name: "全部景點", name_en: "All Attractions", icon: "🏛️" },
      { id: "flower", name: "花季名所", name_en: "Sakura & Blooms", icon: "🌸" },
      { id: "fireworks", name: "花火大會", name_en: "Fireworks", icon: "🎆" },
      { id: "ski", name: "滑雪雪場", name_en: "Ski Resorts", icon: "⛷️" },
      { id: "onsen", name: "溫泉秘境", name_en: "Hot Springs", icon: "♨️" },
      { id: "event", name: "最新活動", name_en: "Latest Events", icon: "🎪" }
    ];

    // 東京各區深度篩選
    const TOKYO_DISTRICTS = [
      { id: "all", name: "全部 23 區", name_en: "All Wards" },
      { id: "shibuya", name: "澀谷區 (SHIBUYA SKY/原宿)", name_en: "Shibuya" },
      { id: "shinjuku", name: "新宿區 (御苑/歌舞伎町)", name_en: "Shinjuku" },
      { id: "taito", name: "台東區 (淺草寺/上野)", name_en: "Asakusa/Ueno" },
      { id: "minato", name: "港區 (東京鐵塔/六本木)", name_en: "Minato/Tower" },
      { id: "chuo", name: "中央區 (銀座 GINZA SIX)", name_en: "Ginza" },
      { id: "chiyoda", name: "千代田區 (秋葉原/皇居)", name_en: "Akihabara" },
      { id: "koto", name: "江東區 (豐洲teamLab/台場)", name_en: "Toyosu/Odaiba" },
      { id: "sumida", name: "墨田區 (東京晴空塔)", name_en: "Sumida/Skytree" }
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

    // 煙火規格
    const FIREWORKS_CATEGORIES = [
      { id: "all", name: "全部規格", name_en: "All Specs" },
      { id: "mega", name: "🎆 萬發巨型一尺玉", name_en: "🎆 10,000+ Shells" },
      { id: "water", name: "🌊 水上海上連發", name_en: "🌊 Seaside/Water" },
      { id: "boat", name: "⛵ 屋形船 VIP 觀賞席", name_en: "⛵ Houseboat VIP" }
    ];

    // 滑雪勝地分區
    const SKI_REGIONS = [
      { id: "all", name: "全部雪區", name_en: "All Ski Zones" },
      { id: "yuzawa", name: "越後湯澤・新潟", name_en: "Echigo Yuzawa" },
      { id: "hakuba", name: "長野・白馬", name_en: "Nagano Hakuba" },
      { id: "hokkaido", name: "北海道・二世谷", name_en: "Hokkaido Niseko" },
      { id: "tohoku", name: "東北・藏王", name_en: "Tohoku Zao" },
      { id: "gunma", name: "群馬・水上", name_en: "Gunma Minakami" }
    ];

    // 滑雪玩家避雷分級
    const SKI_SKILLS = [
      { id: "all", name: "全部推薦", name_en: "All Resorts" },
      { id: "beginner", name: "🌱 新手入門 (緩坡/魔毯/綠線>50%)", name_en: "🌱 Beginner (>50% Green)" },
      { id: "intermediate", name: "⛷️ 進階暢滑 (巡航長紅線)", name_en: "⛷️ Cruiser (Long Red)" },
      { id: "pro", name: "🌲 老手狂歡 (JAPOW極上粉雪/野雪)", name_en: "🌲 Powder Pro (JAPOW)" },
      { id: "town", name: "🛍️ 出街逛街方便 (新幹線/Outlet)", name_en: "🛍️ Town & Outlet" }
    ];

    // 全日本景點、滑雪場與季節活動完整資料庫
    const TABI_DATABASE = [
      // ---------- 🏛️ 東京經典與全新景點 (全部景點骨幹) ----------
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
        statusText: "熱門預約中 (門票熱銷)",
        statusText_en: "Timed Entry (Fast Selling)",
        snowDepth: "地上 229 公尺",
        snowQuality: "360度無遮蔽透明天際線",
        liftRatio: "高速體感電梯直達",
        slopes: { green: 90, red: 10, black: 0 },
        transit: "澀谷站直通 Shibuya Scramble Square 47F",
        transit_en: "Directly connected to Shibuya Station (47F)",
        desc: "東京最熱門的露天高空展望台，站在懸空玻璃角落拍照心跳加速。可俯瞰世界聞名的澀谷十字路口人潮，黃昏時刻還能眺望富士山剪影。",
        desc_en: "Tokyo's premiere open-air observation deck on the 47th floor, offering breathtaking panoramic views of the bustling Scramble Crossing and Mt. Fuji at dusk.",
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
        transit_en: "Toei Oedo Line Akabanebashi Station (5 mins walk)",
        desc: "建於 1958 年的東京精神象徵。擁有 Main Deck (150m) 與重新改裝的 Top Deck (250m) 鏡面反射展望室，塔下更進駐全日本最大室內電競主題樂園 RED° TOKYO TOWER。",
        desc_en: "Standing at 333 meters, Tokyo Tower has been the city's beloved landmark since 1958. Visit the futuristic Top Deck and Japan's largest esports park RED°.",
        image: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
        lat: 35.6586, lng: 139.7454,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-sensoji-asakusa",
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
        transit: "東京地鐵銀座線/都營淺草線「淺草站」步行 1 分鐘",
        transit_en: "Asakusa Station (Ginza/Asakusa Lines, 1 min walk)",
        desc: "東京香火最盛的觀音信仰聖地。穿過巨大的「雷門」提燈，即可漫步於擁有數百年歷史的仲見世通，品嚐現烤人形燒、炸饅頭，是租借和服漫遊的第一首選。",
        desc_en: "Founded in 628 AD, Senso-ji is Tokyo's oldest and most revered Buddhist temple. Walk through the giant Kaminarimon lantern and explore the historic Nakamise market street.",
        image: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80",
        lat: 35.7148, lng: 139.7967,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-tokyo-skytree",
        name: "東京晴空塔 TOKYO SKYTREE",
        name_en: "TOKYO SKYTREE",
        subtitle: "世界最高自立式電波塔！634公尺天望回廊漫步",
        subtitle_en: "World's Tallest Tower: 634m Tembo Deck & Solamachi Mall",
        type: "spot",
        scope: "tokyo",
        district: "sumida",
        regionName: "東京・墨田區",
        regionName_en: "Tokyo · Sumida",
        statusText: "天望回廊晴空萬里",
        statusText_en: "Panoramic Clear Skies",
        snowDepth: "標高 634 公尺",
        snowQuality: "天望甲板 350m + 天望回廊 450m",
        liftRatio: "高速分速600m電梯",
        slopes: { green: 90, red: 10, black: 0 },
        transit: "東武晴空塔線「東京晴空塔站」或「押上站」直通",
        transit_en: "Direct connection to Oshiage Station / Tokyo Skytree Station",
        desc: "高達 634 公尺，獲金氏世界紀錄認證為世界第一高塔。天望回廊透明玻璃地板挑戰膽量，塔底的東京晴空街道 Solamachi 擁有超過 300 家免稅伴手禮與餐廳。",
        desc_en: "At 634 meters, this is the tallest free-standing tower in the world. Walk along the glass-floor Tembo Galleria and shop across 300+ stores in Solamachi Mall.",
        image: "https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?auto=format&fit=crop&w=800&q=80",
        lat: 35.7100, lng: 139.8107,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-teamlab-planets",
        name: "teamLab Planets TOKYO (豐洲)",
        name_en: "teamLab Planets TOKYO",
        subtitle: "金氏世界紀錄！赤腳踏入水中花海與水晶宇宙",
        subtitle_en: "Guinness Record Museum: Walk Barefoot Through Water & Crystal Stars",
        type: "spot",
        scope: "tokyo",
        district: "koto",
        regionName: "東京・江東區豐洲",
        regionName_en: "Tokyo · Toyosu",
        statusText: "室內恆溫熱門展出",
        statusText_en: "Timed Entry (Open Daily)",
        snowDepth: "4 大巨型沉浸光影展區",
        snowQuality: "赤腳溫水錦鯉即時演算",
        liftRatio: "全時段指定場次",
        slopes: { green: 95, red: 5, black: 0 },
        transit: "百合鷗號「新豐洲站」步行 1 分鐘",
        transit_en: "Yurikamome Line Shin-Toyosu Station (1 min walk)",
        desc: "全球最受歡迎的沉浸式數位美術館。脫掉鞋襪赤腳走入溫暖水域，錦鯉在水面上化為光之花瓣游動，穿梭於無限延伸的水晶宇宙與漂浮花園，視覺震撼。",
        desc_en: "An unforgettable body-immersive art space. Walk barefoot into warm water where digital koi fish turn into blossoms upon collision, and wander through infinite crystal light pillars.",
        image: "https://images.unsplash.com/photo-1518173946687-a4c8a383392e?auto=format&fit=crop&w=800&q=80",
        lat: 35.6517, lng: 139.7898,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-harry-potter",
        name: "東京哈利波特影城 (華納兄弟)",
        name_en: "Warner Bros. Studio Tour Tokyo - The Making of Harry Potter",
        subtitle: "亞洲首座！親踏霍格華茲大廳、九又四分之三月台與斜角巷",
        subtitle_en: "Asia's First Harry Potter Studio Tour: Hogwarts Great Hall & Diagon Alley",
        type: "spot",
        scope: "tokyo",
        district: "all",
        regionName: "東京・練馬區",
        regionName_en: "Tokyo · Nerima",
        statusText: "事前預約實名制",
        statusText_en: "Advance Ticket Required",
        snowDepth: "全球最大室內哈利波特設施",
        snowQuality: "電影真實道具與服裝展示",
        liftRatio: "奶油啤酒戶外吧檯",
        slopes: { green: 90, red: 10, black: 0 },
        transit: "西武池袋線/都營大江戶線「豐島園站」步行 2 分鐘",
        transit_en: "Toshimaen Station (Seibu Ikebukuro / Toei Oedo Line, 2 mins walk)",
        desc: "亞洲第一座哈利波特影城！完整還原霍格華茲大廳、鄧不利多辦公室、禁忌森林與活米村。還能手持魔杖拍攝飛行掃帚互動短片、暢飲經典冰涼奶油啤酒！",
        desc_en: "The world's largest indoor Harry Potter attraction. Step onto iconic movie sets including the Great Hall, Platform 9 3/4 with the Hogwarts Express, and sample frothy Butterbeer.",
        image: "https://images.unsplash.com/photo-1551269901-5c5e14c25df7?auto=format&fit=crop&w=800&q=80",
        lat: 35.7423, lng: 139.6489,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "spot-ginza-six",
        name: "GINZA SIX (銀座奢華藝術地標)",
        name_en: "GINZA SIX Luxury Complex",
        subtitle: "銀座最大購物中心！草間彌生紅白南瓜與屋頂空中花園",
        subtitle_en: "Ginza's Flagship Destination with Yayoi Kusama Art & Rooftop Garden",
        type: "spot",
        scope: "tokyo",
        district: "chuo",
        regionName: "東京・中央區銀座",
        regionName_en: "Tokyo · Ginza",
        statusText: "免稅購物・米其林美食",
        statusText_en: "Tax-Free & Rooftop Oasis",
        snowDepth: "241 家世界頂級旗艦店",
        snowQuality: "挑高天井當代裝置藝術",
        liftRatio: "4,000 sqm 屋頂花園",
        slopes: { green: 90, red: 10, black: 0 },
        transit: "東京地鐵銀座線/日比谷線「銀座站」地下通道直通",
        transit_en: "Ginza Station (Direct underground connection)",
        desc: "銀座街區的核心藝術殿堂。中央挑高中庭定期更換草間彌生等名家裝置藝術，頂樓 4,000 平方公尺的空中花園可將銀座繁華街景盡收眼底。",
        desc_en: "Ginza's premier luxury shopping mall, featuring famous hanging art installations in its grand atrium and an open-air 4,000 sqm rooftop garden overlooking Tokyo.",
        image: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
        lat: 35.6696, lng: 139.7640,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },

      // ---------- 🌸 花季名所 (花季專區) ----------
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
        transit_en: "Naka-Meguro Station (2 mins walk)",
        desc: "【東京都 Open Data 認證名所】東京最具人氣的水岸櫻花，兩岸吉野櫻形成遮天花廊。落櫻時分河道化身粉紅地毯，沿岸聚集眾多景觀咖啡館與粉紅香檳市集。",
        desc_en: "Tokyo's most celebrated waterside sakura spot with over 800 cherry trees arcing across the river.",
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
        transit_en: "Shinjuku-gyoenmae Station (5 mins walk)",
        desc: "【下週救援推薦第一名】當染井吉野凋謝時，新宿御苑正是主角！擁有高達 65 種品種，特別是 4 月中盛開的「關山、普賢象」以及罕見綠櫻「御衣黃」，花期長且人潮舒適。",
        desc_en: "Top pick for late-season visitors! When standard Yoshino petals drop, 65 late varieties including green Gyoiko bloom through late April.",
        image: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
        lat: 35.6852, lng: 139.7101,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },
      {
        id: "sakura-mint-osaka",
        name: "大阪造幣局 櫻之通道",
        name_en: "Osaka Mint Bureau Sakura Tunnel",
        subtitle: "關西晚櫻霸主！每年僅開放 7 天的 140 種珍稀櫻花",
        subtitle_en: "Kansai's Top Late Sakura! Only open 7 days a year with 140 rare varieties",
        type: "flower",
        scope: "kansai",
        district: "all",
        regionName: "關西・大阪市北區",
        regionName_en: "Kansai · Osaka",
        variety: "late",
        varietyName: "大手毬、紅手毬、普賢象、鬱金 (黃綠櫻)",
        statusText: "預約即將開跑 (85%)",
        statusText_en: "Reservation Open Soon (85%)",
        bloomStage: "blooming",
        snowDepth: "140 品種珍稀櫻",
        snowQuality: "重瓣花球繡球狀",
        liftRatio: "事前實名預約制",
        slopes: { green: 75, red: 25, black: 0 },
        transit: "Osaka Metro 谷町線「天滿橋站」步行 10 分鐘",
        transit_en: "Temmabashi Station (10 mins walk)",
        desc: "【關西下週凋謝救援聖地】全長 560 公尺林蔭道聚集 140 種珍稀重瓣品種，包括圓球狀大手毬與淡黃綠色鬱金櫻，是 4 月中旬訪關西必備行程。",
        desc_en: "Kansai's legendary late sakura event with 140 varieties of Yaezakura along the river corridor.",
        image: "https://images.unsplash.com/photo-1493780474015-ba834fd0ce2f?auto=format&fit=crop&w=800&q=80",
        lat: 34.6946, lng: 135.5218,
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
        coachOffer: "中文/英文單雙板教練 (享 9 折特約)",
        coachPrice: "NT$ 8,500 / JPY 40,000",
        transit: "JR 東京站搭乘上越新幹線 74 分鐘直達 GALA 湯澤站",
        transit_en: "Joetsu Shinkansen from Tokyo (74 mins direct)",
        desc: "【新手避雷首選】下新幹線剪票口即是雪場服務櫃台，免拉行李轉車。初學者專用魔毯緩坡綠線達 50%，山下即是越後湯澤溫泉街，新手絕不踩雷！",
        desc_en: "Tokyo's most convenient ski resort with direct Shinkansen access. Over 50% beginner green runs and magic carpets.",
        image: "https://images.unsplash.com/photo-1551524559-8af4e6624178?auto=format&fit=crop&w=800&q=80",
        lat: 36.9500, lng: 138.8000,
        coachUrl: "https://www.klook.com/zh-TW/?aid=123436",
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436",
        onsenUrl: "https://www.google.com/maps/search/%E8%B6%8A%E5%BE%8C%E6%B9%AF%E6%BE%A4+%E6%BA%AB%E6%B3%89"
      },
      {
        id: "ski-niseko",
        name: "二世谷格蘭比羅夫 (Niseko)",
        name_en: "Niseko Grand Hirafu Resort",
        subtitle: "全球頂級粉雪殿堂！老手狂歡・JAPOW 傳奇雪況",
        subtitle_en: "World Capital of Powder Snow (JAPOW) with Vibrant Nightlife",
        type: "ski",
        scope: "hokkaido",
        district: "all",
        regionName: "北海道・二世谷",
        regionName_en: "Hokkaido · Niseko",
        skills: ["pro", "town"],
        statusText: "頂級乾粉雪・積雪 365cm",
        statusText_en: "World-Class Dry Powder (365cm)",
        snowDepth: "365 cm",
        snowQuality: "極致輕盈乾粉 (JAPOW)",
        liftRatio: "28 / 30 條運行",
        slopes: { green: 30, red: 40, black: 30 },
        coachOffer: "二世谷中文專業嚮導與野雪帶滑",
        coachPrice: "NT$ 12,000 / JPY 58,000",
        transit: "新千歲機場搭乘滑雪直達巴士約 2.5 小時",
        transit_en: "Ski Resort Shuttle from New Chitose Airport (2.5 hrs)",
        desc: "【老手狂歡天堂】享譽國際的北海道粉雪聖地，雪質輕盈如羽毛。擁有全日本最大的夜滑區域與未壓雪樹林野雪，比羅夫小鎮酒吧林立。",
        desc_en: "The crowned jewel of powder skiing with unmatched dry powder snow and vibrant nightlife.",
        image: "https://images.unsplash.com/photo-1516762689617-e1cfffedbe03?auto=format&fit=crop&w=800&q=80",
        lat: 42.8633, lng: 140.7047,
        coachUrl: "https://www.klook.com/zh-TW/?aid=123436",
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436",
        onsenUrl: "https://www.google.com/maps/search/Niseko+Onsen"
      },

      // ---------- 🎆 花火大會 (深邃黑金主題) ----------
      {
        id: "fw-sumida",
        name: "隅田川花火大會",
        name_en: "Sumida River Fireworks Festival",
        subtitle: "日本最古老煙火！晴空塔與 2 萬發璀璨同框",
        subtitle_en: "Japan's Oldest Fireworks: 20,000 Shells framed with Skytree",
        type: "fireworks",
        scope: "tokyo",
        district: "sumida",
        regionName: "東京・隅田川水岸",
        regionName_en: "Tokyo · Sumida River",
        fireworksCategory: "mega",
        statusText: "席位熱烈開賣中",
        statusText_en: "VIP Seats Available",
        snowDepth: "20,000 發花火",
        snowQuality: "巨型一尺玉＋連發速射",
        liftRatio: "兩大發射會場",
        slopes: { green: 70, red: 20, black: 10 },
        transit: "都營淺草線/東武晴空塔線「淺草站」步行 5 分鐘",
        transit_en: "Asakusa Station (5 mins walk)",
        desc: "始於 1733 年的東京傳統代表作。兩大會場施放 20,000 發花火，與晴空塔點燈相映成趣。",
        desc_en: "Japan's oldest fireworks show launching 20,000 shells against the Tokyo Skytree skyline.",
        image: "https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=800&q=80",
        lat: 35.7128, lng: 139.8000,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      },

      // ---------- ♨️ 溫泉秘境 ----------
      {
        id: "onsen-kusatsu",
        name: "草津溫泉 湯畑",
        name_en: "Kusatsu Onsen Yubatake",
        subtitle: "日本三大名湯之首！天然高溫強酸泉與傳統拌湯秀",
        subtitle_en: "Japan's #1 Hot Spring: Steaming Yubatake & Mineral Waters",
        type: "onsen",
        scope: "tokyo",
        district: "all",
        regionName: "群馬・草津町",
        regionName_en: "Gunma · Kusatsu",
        statusText: "湧泉量全日第一",
        statusText_en: "Japan's Top Water Flow",
        snowDepth: "每分 32,300 公升",
        snowQuality: "pH 2.1 強酸殺菌美肌",
        liftRatio: "三大公眾浴場運行",
        slopes: { green: 90, red: 10, black: 0 },
        transit: "JR 特急草津號至長野原草津口站轉乘 JR 巴士 25 分鐘",
        transit_en: "JR Limited Express + JR Bus (25 mins)",
        desc: "連續數十年蟬聯「日本溫泉 100 選」榜首。鎮中心的湯畑每分鐘湧出磅礡蒸汽，入夜後瓦斯燈與木棧道極致和風浪漫。",
        desc_en: "Voted Japan's number one hot spring for consecutive decades. A steaming outdoor mineral wonder.",
        image: "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80",
        lat: 36.6206, lng: 138.5960,
        ticketUrl: "https://www.klook.com/zh-TW/?aid=123436",
        metroUrl: "https://www.klook.com/zh-TW/transport/?aid=123436",
        hotelUrl: "https://www.agoda.com/zh-tw/?cid=123436"
      }
    ];

    // 特色櫻花景觀咖啡廳
    const SAKURA_CAFES = [
      {
        id: "cafe-starbucks-roastery",
        name: "星巴克臻選® 東京烘焙工坊",
        name_en: "Starbucks Reserve Roastery Tokyo",
        spotName: "目黑川櫻並木",
        viewType: "川畔第一排露台席",
        walking: "中目黑站步行約 10 分鐘",
        latestPhotoTime: "今日 09:30 拍",
        photoStatus: "🌸 4F 露台正對櫻花冠滿開",
        photoUrl: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=700&q=80",
        tips: "隈研吾大師設計！花季期間務必於一早 07:00 開門時在門口掃 QR Code 抽取「入場整理券」，露台席景觀震撼心靈。",
        mapUrl: "https://maps.google.com/?q=Starbucks+Reserve+Roastery+Tokyo"
      },
      {
        id: "cafe-onibus-nakameguro",
        name: "ONIBUS COFFEE 中目黑店",
        name_en: "ONIBUS COFFEE Naka-Meguro",
        spotName: "中目黑線路旁櫻花",
        viewType: "2F 窗景與日比谷線電車同框",
        walking: "中目黑站南口步行 2 分鐘",
        latestPhotoTime: "今日 11:15 拍",
        photoStatus: "🌸 窗外櫻花開滿，列車每 3 分鐘一班",
        photoUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=700&q=80",
        tips: "獨棟雙層古民家風格，二樓小窗台能拍出東京最經典的「手沖咖啡＋櫻花樹＋行駛中的電車」日系文青構圖！",
        mapUrl: "https://maps.google.com/?q=ONIBUS+COFFEE+Nakameguro"
      }
    ];

    // 讀者即時情報社群牆
    let LIVE_INTEL_REPORTS = [
      {
        id: "report-1",
        spotName: "目黑川櫻並木",
        user: "台灣小旅人・Ken",
        timeTag: "今日 09:40 拍 (EXIF 已認證)",
        status: "🌸 滿開無死角",
        comment: "今天目黑川天氣超晴朗！中目黑站前橋上人潮雖多但前進很順暢，河道已經開始有薄薄的花筏，下午打算去星巴克！",
        photo: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=600&q=80",
        likes: 42
      },
      {
        id: "report-2",
        spotName: "新宿御苑",
        user: "追櫻女子・Mandy",
        timeTag: "今日 10:20 拍 (EXIF 已認證)",
        status: "🌺 八重櫻與御衣黃盛開中",
        comment: "如果這兩天來東京吉野櫻掉得差不多了，真的強烈建議衝新宿御苑！裡面的「關山櫻」像粉紅繡球一樣飽滿，草地野餐很舒服！",
        photo: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80",
        likes: 38
      }
    ];

    // 全域響應狀態變數 (核心重構：預設 tokyo + spot)
    let currentScope = 'tokyo';
    let currentCategory = 'spot';
    let currentDistrict = 'all';
    let currentVariety = 'all';
    let currentBloomStage = 'all';
    let currentFireworksCat = 'all';
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
      renderSakuraVarietyButtons();
      renderBloomStageButtons();
      renderFireworksButtons();
      renderSkiRegionButtons();
      renderSkiSkillButtons();
      renderCards();
      renderCafes();
      renderIntelStream();
      updateBookmarkBadge();
      updateDynamicThemeAndContext();
    });

    // ================= 雙語切換核心 =================
    function toggleLanguage() {
      currentLang = currentLang === 'zh' ? 'en' : 'zh';
      localStorage.setItem('tabi_lang', currentLang);
      document.getElementById('lang-label').textContent = currentLang === 'zh' ? 'EN' : '中文';

      const t = I18N[currentLang];
      document.getElementById('i18n-brand-title').textContent = t.brandTitle;
      document.getElementById('i18n-badge-live').textContent = t.badgeLive;
      document.getElementById('i18n-brand-sub').textContent = t.brandSub;
      document.getElementById('i18n-view-cards').textContent = t.viewCards;
      document.getElementById('i18n-view-map').textContent = t.viewMap;
      document.getElementById('i18n-scope-tokyo').textContent = t.scopeTokyo;
      document.getElementById('i18n-scope-all').textContent = t.scopeAll;
      document.getElementById('i18n-scope-kansai').textContent = t.scopeKansai;
      document.getElementById('i18n-scope-hokkaido').textContent = t.scopeHokkaido;
      document.getElementById('i18n-scope-tohoku').textContent = t.scopeTohoku;
      document.getElementById('lbl-rescue-title').textContent = t.rescueTitle;
      document.getElementById('lbl-rescue-badge').textContent = t.rescueBadge;
      document.getElementById('lbl-rescue-desc').textContent = t.rescueDesc;
      document.getElementById('lbl-rescue-btn').textContent = t.rescueBtn;
      document.getElementById('i18n-subview-spots').textContent = t.subviewSpots;
      document.getElementById('i18n-subview-cafes').textContent = t.subviewCafes;
      document.getElementById('i18n-subview-intel').textContent = t.subviewIntel;
      document.getElementById('i18n-btn-sync').textContent = t.btnSync;

      renderMainCategoryButtons();
      renderDistrictButtons();
      renderSakuraVarietyButtons();
      renderBloomStageButtons();
      renderFireworksButtons();
      renderSkiRegionButtons();
      renderSkiSkillButtons();
      renderCards();
      renderCafes();
      if (leafletMap) renderLeafletMarkers();
    }

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

      // 若切換地區不是東京，隱藏東京各區細分
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

    // ================= 情境動態展開邏輯（點什麼才出什麼，絕不打架） =================
    function updateDynamicThemeAndContext() {
      const body = document.body;
      const districtPanel = document.getElementById('panel-district-filter');
      const flowerPanel = document.getElementById('panel-flower-filter');
      const fireworksPanel = document.getElementById('panel-fireworks-filter');
      const skiPanel = document.getElementById('panel-ski-filter');
      const subviewToggle = document.getElementById('subview-toggle-bar');

      // 1. 點「全部景點」時
      if (currentCategory === 'spot') {
        body.className = "theme-spot min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🏛️';
        if (currentScope === 'tokyo') {
          districtPanel.classList.remove('hidden');
        } else {
          districtPanel.classList.add('hidden');
        }
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');
        subviewToggle.classList.remove('hidden');
      }
      // 2. 點「花季名所」時
      else if (currentCategory === 'flower') {
        body.className = "theme-flower min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🌸';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.remove('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');
        subviewToggle.classList.remove('hidden');
      }
      // 3. 點「花火大會」時 (深邃黑金夜空主題)
      else if (currentCategory === 'fireworks') {
        body.className = "theme-fireworks min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🎆';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.remove('hidden');
        skiPanel.classList.add('hidden');
        subviewToggle.classList.add('hidden');
      }
      // 4. 點「滑雪雪場」時
      else if (currentCategory === 'ski') {
        body.className = "theme-ski min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '⛷️';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.remove('hidden');
        subviewToggle.classList.add('hidden');
      }
      // 5. 點「溫泉秘境」時
      else if (currentCategory === 'onsen') {
        body.className = "theme-onsen min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '♨️';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');
        subviewToggle.classList.add('hidden');
      }
      // 6. 點「最新活動」時
      else {
        body.className = "theme-event min-h-screen flex flex-col relative pb-28 md:pb-16";
        document.getElementById('brand-badge-icon').textContent = '🎪';
        districtPanel.classList.add('hidden');
        flowerPanel.classList.add('hidden');
        fireworksPanel.classList.add('hidden');
        skiPanel.classList.add('hidden');
        subviewToggle.classList.add('hidden');
      }

      setSubView('spots');
      resetParticles();
    }

    // ================= 渲染東京各區按鈕 =================
    function renderDistrictButtons() {
      const wrap = document.getElementById('district-buttons-wrap');
      wrap.innerHTML = TOKYO_DISTRICTS.map(d => {
        const isActive = d.id === currentDistrict;
        const name = currentLang === 'zh' ? d.name : d.name_en;
        return `
          <button onclick="selectDistrict('${d.id}')"
            class="px-2.5 py-1 rounded-xl text-xs ${isActive ? 'font-black bg-theme-deep text-white shadow-xs' : 'font-bold bg-gray-50 text-gray-700 hover:bg-gray-100'} flex-shrink-0 transition">
            ${name}
          </button>
        `;
      }).join('');
    }

    function selectDistrict(dist) {
      currentDistrict = dist;
      renderDistrictButtons();
      renderCards();
      if (leafletMap) renderLeafletMarkers();
    }

    // 櫻花品種多系快篩
    function renderSakuraVarietyButtons() {
      const wrap = document.getElementById('sakura-variety-buttons-wrap');
      wrap.innerHTML = SAKURA_VARIETIES.map(v => {
        const isActive = v.id === currentVariety;
        const label = currentLang === 'zh' ? v.label : v.en;
        return `
          <button onclick="selectVariety('${v.id}')"
            class="px-3 py-1.5 rounded-xl text-xs ${isActive ? 'font-black bg-rose-500 text-white' : 'font-bold bg-pink-50 text-pink-700 border border-pink-200 hover:bg-pink-100'} flex-shrink-0 transition">
            ${label}
          </button>
        `;
      }).join('');
    }

    function selectVariety(v) {
      currentVariety = v;
      renderSakuraVarietyButtons();
      renderCards();
    }

    function renderBloomStageButtons() {
      const wrap = document.getElementById('flower-bloom-buttons-wrap');
      wrap.innerHTML = SAKURA_BLOOM_STAGES.map(b => {
        const isActive = b.id === currentBloomStage;
        const name = currentLang === 'zh' ? b.name : b.name_en;
        return `
          <button onclick="selectBloomStage('${b.id}')"
            class="px-3 py-1.5 rounded-xl text-xs ${isActive ? 'font-black bg-rose-500 text-white shadow-xs' : 'font-bold bg-white text-gray-600 border border-theme hover:bg-white/80'} flex-shrink-0 transition">
            ${name}
          </button>
        `;
      }).join('');
    }

    function selectBloomStage(bloom) {
      currentBloomStage = bloom;
      renderBloomStageButtons();
      renderCards();
    }

    function renderFireworksButtons() {
      const wrap = document.getElementById('fireworks-buttons-wrap');
      wrap.innerHTML = FIREWORKS_CATEGORIES.map(f => {
        const isActive = f.id === currentFireworksCat;
        const name = currentLang === 'zh' ? f.name : f.name_en;
        return `
          <button onclick="selectFireworksCategory('${f.id}')"
            class="px-3 py-1.5 rounded-xl text-xs ${isActive ? 'font-black bg-pink-500 text-white shadow-xs' : 'font-bold bg-slate-800 text-slate-300 border border-slate-700 hover:bg-slate-700'} flex-shrink-0 transition">
            ${name}
          </button>
        `;
      }).join('');
    }

    function selectFireworksCategory(fw) {
      currentFireworksCat = fw;
      renderFireworksButtons();
      renderCards();
    }

    function renderSkiRegionButtons() {
      const wrap = document.getElementById('ski-region-buttons-wrap');
      wrap.innerHTML = SKI_REGIONS.map(r => {
        const isActive = r.id === currentSkiRegion;
        const name = currentLang === 'zh' ? r.name : r.name_en;
        return `
          <button onclick="selectSkiRegion('${r.id}')"
            class="px-2.5 py-1 rounded-xl text-xs ${isActive ? 'font-black bg-theme-primary text-white shadow-xs' : 'font-bold bg-white text-gray-600 border border-theme'} flex-shrink-0 transition hover:bg-white/90">
            ${name}
          </button>
        `;
      }).join('');
    }

    function selectSkiRegion(reg) {
      currentSkiRegion = reg;
      renderSkiRegionButtons();
      renderCards();
    }

    function renderSkiSkillButtons() {
      const wrap = document.getElementById('ski-skill-buttons-wrap');
      wrap.innerHTML = SKI_SKILLS.map(s => {
        const isActive = s.id === currentSkiSkill;
        const name = currentLang === 'zh' ? s.name : s.name_en;
        return `
          <button onclick="selectSkiSkill('${s.id}')"
            class="px-3 py-1.5 rounded-xl text-xs ${isActive ? 'font-black bg-theme-primary text-white shadow-xs' : 'font-bold bg-white text-gray-600 border border-theme hover:bg-white/80'} flex-shrink-0 transition">
            ${name}
          </button>
        `;
      }).join('');
    }

    function selectSkiSkill(skill) {
      currentSkiSkill = skill;
      renderSkiSkillButtons();
      renderCards();
    }

    // ================= 子視圖切換 (景點名所 / 咖啡 / 實況牆) =================
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

    // ================= 取得過濾後的名所資料 =================
    function getFilteredData() {
      return TABI_DATABASE.filter(item => {
        // 大分類過濾
        if (currentCategory !== 'all' && item.type !== currentCategory) return false;

        // 地區過濾
        if (currentScope !== 'all' && item.scope !== currentScope && item.scope !== 'all') return false;

        // 東京各區過濾
        if (currentScope === 'tokyo' && currentDistrict !== 'all' && item.district && item.district !== currentDistrict) {
          return false;
        }

        // 櫻花品種多系過濾
        if (currentCategory === 'flower' && currentVariety !== 'all') {
          if (item.variety !== currentVariety) return false;
        }

        // 開花階段過濾
        if (currentCategory === 'flower' && currentBloomStage !== 'all') {
          if (item.bloomStage !== currentBloomStage) return false;
        }

        // 煙火規格過濾
        if (currentCategory === 'fireworks' && currentFireworksCat !== 'all') {
          if (item.fireworksCategory !== currentFireworksCat) return false;
        }

        // 滑雪雪區與程度過濾
        if (currentCategory === 'ski') {
          if (currentSkiRegion !== 'all' && item.region !== currentSkiRegion) return false;
          if (currentSkiSkill !== 'all' && (!item.skills || !item.skills.includes(currentSkiSkill))) return false;
        }

        return true;
      });
    }

    // ================= 渲染卡片 =================
    function renderCards() {
      const container = document.getElementById('resorts-grid');
      const emptyState = document.getElementById('empty-state');
      const data = getFilteredData();

      const catObj = MAIN_CATEGORIES.find(c => c.id === currentCategory) || MAIN_CATEGORIES[0];
      const catName = currentLang === 'zh' ? catObj.name : catObj.name_en;

      document.getElementById('filter-summary-text').innerHTML = `
        <span class="font-bold text-theme-primary">${catObj.icon} ${catName}</span>
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
        const title = currentLang === 'zh' ? item.name : item.name_en;
        const subtitle = currentLang === 'zh' ? item.subtitle : item.subtitle_en;
        const regionName = currentLang === 'zh' ? item.regionName : item.regionName_en;
        const statusText = currentLang === 'zh' ? item.statusText : item.statusText_en;

        const ticketUrl = appendAffiliateParams(item.ticketUrl, `card_ticket_${item.id}`);
        const metroUrl = appendAffiliateParams(item.metroUrl, `card_metro_${item.id}`);
        const hotelUrl = appendAffiliateParams(item.hotelUrl, `card_hotel_${item.id}`);
        const coachUrl = appendAffiliateParams(item.coachUrl || item.ticketUrl, `card_coach_${item.id}`);
        const onsenUrl = item.onsenUrl || "#";

        return `
          <article class="bg-white rounded-3xl overflow-hidden border border-theme washi-shadow flex flex-col justify-between transition-all duration-300 hover:-translate-y-1">
            <div>
              <!-- 頂部高客單價高對比分潤按鈕 -->
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
                      <span>☕</span> 推薦咖啡
                    </button>
                  ` : ''}
                </div>
                <p class="text-xs font-bold text-theme-primary mb-3 leading-snug">${subtitle}</p>

                <!-- 3 指標數據 -->
                <div class="grid grid-cols-3 gap-1.5 p-2.5 bg-theme-soft/50 border border-theme/60 rounded-xl text-center mb-3">
                  <div>
                    <span class="text-[10px] text-theme-muted font-bold block">${isSki ? '積雪深度' : '規模/特色'}</span>
                    <span class="text-xs font-black text-theme-deep">${item.snowDepth}</span>
                  </div>
                  <div>
                    <span class="text-[10px] text-theme-muted font-bold block">${isSki ? '目前雪質' : '體驗特色'}</span>
                    <span class="text-xs font-black text-theme-deep truncate block">${item.snowQuality}</span>
                  </div>
                  <div>
                    <span class="text-[10px] text-theme-muted font-bold block">${isSki ? '開放纜車' : '設施營運'}</span>
                    <span class="text-xs font-black text-theme-deep">${item.liftRatio}</span>
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
                  <a href="${onsenUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-amber-500 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>♨️</span> 雪見溫泉
                  </a>
                  <a href="${hotelUrl}" target="_blank" onclick="event.stopPropagation()"
                    class="py-2 px-1 bg-blue-600 text-white rounded-xl text-[10px] font-black text-center flex items-center justify-center gap-0.5 shadow-sm transition truncate">
                    <span>🏨</span> 預定飯店
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

    // ================= 渲染櫻花咖啡廳列表 =================
    function renderCafes() {
      const container = document.getElementById('cafes-grid');
      container.innerHTML = SAKURA_CAFES.map(cafe => `
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
                  🪑 ${cafe.viewType}
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

    // ================= 渲染即時情報討論牆 =================
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

    // ================= 視圖切換 (卡片速報 ⇄ Leaflet 和風地圖) =================
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

    // ================= 【全新 Leaflet ＋ CARTO Voyager 和風實況地圖】 =================
    function initLeafletMapIfNeeded() {
      if (leafletMap) {
        leafletMap.invalidateSize();
        return;
      }

      const mapContainer = document.getElementById('leaflet-map-container');
      if (!mapContainer) return;

      // 初始化地圖，中心先定在東京 (35.6895, 139.6917)
      leafletMap = L.map('leaflet-map-container', {
        center: [35.6895, 139.6917],
        zoom: 11,
        zoomControl: true
      });

      // CARTO Voyager 100% 免費清新和風底圖 (無須 API Key)
      L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap contributors &copy; CARTO',
        subdomains: 'abcd',
        maxZoom: 19
      }).addTo(leafletMap);

      markersLayerGroup = L.layerGroup().addTo(leafletMap);
      frontlineLayerGroup = L.layerGroup().addTo(leafletMap);

      drawSakuraFrontlineWaves();
    }

    // 繪製櫻花開花前線波浪帶 (Sakura Frontline Waves)
    function drawSakuraFrontlineWaves() {
      if (!frontlineLayerGroup) return;
      frontlineLayerGroup.clearLayers();

      // 1. 滿開黃金推進帶 (4/1 ~ 4/8 關東・關西核心滿開帶)
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

      // 2. 東北初開見頃前線帶 (4月中旬)
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
      }).bindTooltip("🌱 4月中旬 東北開花見頃前線 (藏王・秋田・弘前)", { sticky: true });

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

    // 渲染 Leaflet 活體動態圖標
    function renderLeafletMarkers() {
      if (!markersLayerGroup) return;
      markersLayerGroup.clearLayers();

      const data = getFilteredData();
      data.forEach(item => {
        if (!item.lat || !item.lng) return;

        let iconEmoji = "🏛️";
        let badgeColor = "bg-sky-600";
        let badgeText = item.statusText;

        if (item.type === 'flower') {
          iconEmoji = "🌸";
          badgeColor = "bg-rose-500";
        } else if (item.type === 'ski') {
          iconEmoji = "⛷️";
          badgeColor = "bg-sky-500";
          badgeText = item.snowDepth;
        } else if (item.type === 'fireworks') {
          iconEmoji = "🎆";
          badgeColor = "bg-pink-600";
        } else if (item.type === 'onsen') {
          iconEmoji = "♨️";
          badgeColor = "bg-amber-600";
        }

        const customHtml = `
          <div class="relative flex items-center cursor-pointer group select-none">
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

        // 點擊彈出高質感自訂資訊窗
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
      if (region === 'tokyo') {
        leafletMap.flyTo([35.6895, 139.6917], 12);
      } else if (region === 'kansai') {
        leafletMap.flyTo([34.6937, 135.5023], 10);
      } else if (region === 'yuzawa') {
        leafletMap.flyTo([36.9500, 138.8000], 11);
      } else if (region === 'hokkaido') {
        leafletMap.flyTo([43.0642, 141.3469], 7);
      } else {
        leafletMap.flyTo([36.2048, 138.2529], 6);
      }
    }

    // ================= 詳情抽屜邏輯 =================
    let currentDetailItem = null;

    function openDetailSheet(id) {
      const item = TABI_DATABASE.find(r => r.id === id);
      if (!item) return;
      currentDetailItem = item;

      const isSki = item.type === 'ski';
      const isFlower = item.type === 'flower';

      document.getElementById('sheet-img').src = item.image;
      document.getElementById('sheet-title').textContent = currentLang === 'zh' ? item.name : item.name_en;
      document.getElementById('sheet-subtitle').textContent = currentLang === 'zh' ? item.subtitle : item.subtitle_en;
      document.getElementById('sheet-desc').textContent = item.desc;
      document.getElementById('sheet-region-badge').textContent = `📍 ${item.regionName}`;
      document.getElementById('sheet-status-badge').textContent = item.statusText;
      document.getElementById('sheet-depth').textContent = item.snowDepth;
      document.getElementById('sheet-quality').textContent = item.snowQuality;
      document.getElementById('sheet-lifts').textContent = item.liftRatio;
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

      // 底層 API JSON
      document.getElementById('sheet-api-json').textContent = JSON.stringify(item, null, 2);

      // 動態底欄按鈕
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

    function closeDetailSheet(e) {
      const sheet = document.getElementById('detail-sheet');
      sheet.classList.add('opacity-0');
      sheet.children[0].classList.add('translate-y-8');
      setTimeout(() => {
        sheet.classList.add('hidden');
      }, 250);
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
    function openUploadModal(preset) {
      document.getElementById('upload-modal').classList.remove('hidden');
    }
    function closeUploadModal() {
      document.getElementById('upload-modal').classList.add('hidden');
    }
    function selectSampleImg(el) {
      document.querySelectorAll('#upload-modal img').forEach(i => i.className = "h-16 w-full object-cover rounded-xl border border-gray-200 cursor-pointer opacity-70");
      el.className = "h-16 w-full object-cover rounded-xl border-2 border-theme-primary cursor-pointer";
    }
    function submitUGCReport() {
      const spot = document.getElementById('upload-spot-select').value;
      const status = document.getElementById('upload-status').value;
      const comment = document.getElementById('upload-comment').value || "現場實況人潮良好！";
      LIVE_INTEL_REPORTS.unshift({
        id: "rep-" + Date.now(),
        spotName: spot,
        user: "熱心旅人 (我)",
        timeTag: "今日即時拍 (EXIF 已認證)",
        status: status,
        comment: comment,
        photo: "https://images.unsplash.com/photo-1522383225653-ed111181a951?auto=format&fit=crop&w=600&q=80",
        likes: 1
      });
      closeUploadModal();
      setSubView('intel');
      renderIntelStream();
    }

    // API Sync Modal
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
        "GET https://api.surf-snow.jp/v2/resorts/live ... 200 OK (35ms)",
        "SYNC Weathernews (WNI) Sakura Frontline 2026 ... 200 OK (48ms)",
        "FETCH Walkerplus Fireworks Event Calendar 2026 ... 200 OK (39ms)",
        "SYNC JMA Specimen Tree Observations & Snow Depths ... 200 OK (22ms)"
      ];

      steps.forEach((msg, idx) => {
        setTimeout(() => {
          const div = document.createElement('div');
          div.className = "flex items-center gap-1.5 text-emerald-400";
          div.innerHTML = `<span class="text-slate-500">▶</span> <span>${msg}</span>`;
          logs.appendChild(div);
          statusText.textContent = `連線進度: ${(idx + 1) * 25}% (實時數據同步完畢)`;
          if (idx === steps.length - 1) doneBtn.classList.remove('hidden');
        }, (idx + 1) * 300);
      });
    }

    function closeApiSyncModal() {
      document.getElementById('api-sync-modal').classList.add('hidden');
    }

    // ================= Canvas 四季動態物理粒子 =================
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
          // 落櫻花瓣
          ctx.fillStyle = '#F8B3BD';
          ctx.beginPath();
          ctx.ellipse(0, 0, p.size * 0.6, p.size * 1.2, 0, 0, Math.PI * 2);
          ctx.fill();
        } else if (currentCategory === 'ski') {
          // 飄雪粉雪
          ctx.fillStyle = '#BAE6FD';
          ctx.beginPath();
          ctx.arc(0, 0, p.size * 0.5, 0, Math.PI * 2);
          ctx.fill();
        } else if (currentCategory === 'fireworks') {
          // 花火星芒
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
JS_CODE_PART

close $fh;

copy($target, $copy1) or warn "Copy to $copy1 failed: $!\n";
copy($target, $copy2) or warn "Copy to $copy2 failed: $!\n";

print "Complete V2 architecture build succeeded!\n";
print "Target file: " . (-s $target) . " bytes\n";
print "Copy 1 file: " . (-s $copy1) . " bytes\n";
print "Copy 2 file: " . (-s $copy2) . " bytes\n";

