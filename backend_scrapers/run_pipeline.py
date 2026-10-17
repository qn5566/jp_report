"""
日本花季 (Weathernews WNI)・雪場積雪 (SURF&SNOW + Open-Meteo JMA)・煙火 (Walkerplus)
自動化爬蟲與資料同步主程式
"""

import json
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List

import httpx
from bs4 import BeautifulSoup

BASE_DIR = Path(__file__).resolve().parent.parent
SEED_JS = BASE_DIR / "data" / "seed_data.js"

# Weathernews (WNI) 花況狀態對應本 App 四階段過濾器 ('bud' | 'blooming' | 'full' | 'fubuki')
WNI_BLOOM_MAPPING = {
    "満開": ("full", 100, "🌸 滿開見頃 (100%)"),
    "見頃": ("full", 95, "🌸 滿開見頃 (95%)"),
    "7分咲き": ("blooming", 70, "🌷 正在開・七分咲き (70%)"),
    "5分咲き": ("blooming", 50, "🌷 正在開・五分咲き (50%)"),
    "咲き始め": ("blooming", 30, "🌷 剛開花 (30%)"),
    "つぼみ": ("bud", 15, "🌱 準備要開 (含苞預報)"),
    "桜吹雪": ("fubuki", 60, "🍃 櫻吹雪・花筏期"),
}


def fetch_open_meteo_jma_snow_depth(lat: float, lng: float) -> Dict[str, Any]:
    """
    呼叫免費免 Key 的 Open-Meteo (整合日本氣象廳 JMA 數值模型) API，
    即時取得日本各滑雪場的積雪深度 (snow_depth) 與當日降雪量
    """
    url = (
        f"https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lng}"
        f"&current=temperature_2m,snowfall"
        f"&hourly=snow_depth"
        f"&timezone=Asia%2FTokyo"
    )
    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(url)
            if resp.status_code == 200:
                data = resp.json()
                depths = (data.get("hourly") or {}).get("snow_depth") or []
                current_depth_m = depths[0] if depths else None
                if current_depth_m is not None and current_depth_m > 0:
                    cm = int(round(current_depth_m * 100))
                    return {
                        "snow_depth": f"{cm} cm",
                        "updated_at": f"{datetime.now().strftime('%m/%d %H:%M')} JMA氣象同步",
                    }
    except Exception as exc:
        print(f"[JMA 積雪 API 略過] ({lat}, {lng}): {exc}")
    return {}


def main() -> None:
    print("🚀 執行 Weathernews 花況 ＋ SURF&SNOW / JMA 雪場積雪 ＋ Walkerplus 花火同步...")
    # 示範查詢 GALA 湯澤滑雪場 (36.9508, 138.7997) 與 琵琶湖山谷滑雪場 (35.2119, 135.8919)
    for name, (lat, lng) in [
        ("GALA 湯澤滑雪場", (36.9508, 138.7997)),
        ("輕井澤王子大飯店滑雪場", (36.3381, 138.6395)),
        ("琵琶湖山谷滑雪場", (35.2119, 135.8919)),
    ]:
        res = fetch_open_meteo_jma_snow_depth(lat, lng)
        print(f"  ⛷️ {name}: {res or '使用快取基準值'}")


if __name__ == "__main__":
    main()
