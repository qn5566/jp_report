#!/usr/bin/env python3
"""每日更新靜態雪況數據 -> data/snow_today.json

資料來源：Open-Meteo 免費預報 API（免 API Key）。
只使用 Python 標準函式庫，無需安裝任何套件。

注意：Open-Meteo 的 snow_depth 是氣象模型在該座標網格的「預估積雪深度」，
並非雪場官方量測的山頂積雪，僅供參考。
"""
import json
import os
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone

JST = timezone(timedelta(hours=9))

# name 為前端顯示名稱。富士天神山座標為近似值，可自行修正。
LOCATIONS = [
    {"key": "niseko",  "name": "二世谷",     "lat": 42.8048, "lon": 140.6874},
    {"key": "rusutsu", "name": "留壽都",     "lat": 42.7525, "lon": 140.9069},
    {"key": "kiroro",  "name": "喜樂樂",     "lat": 43.0762, "lon": 140.9839},
    {"key": "fujiten", "name": "富士天神山", "lat": 35.4800, "lon": 138.7300},
]

API = "https://api.open-meteo.com/v1/forecast"
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "snow_today.json")
OUT_APP = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "app", "data", "snow_today.json")


def fetch(loc):
    params = {
        "latitude": loc["lat"],
        "longitude": loc["lon"],
        "daily": "snowfall_sum,sunshine_duration,daylight_duration",
        "hourly": "snow_depth",
        "timezone": "Asia/Tokyo",
        "forecast_days": 1,
    }
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": "japan-tabi-report-snow-bot/1.0"})
    with urllib.request.urlopen(req, timeout=30) as r:
        d = json.load(r)

    snowfall = (d["daily"]["snowfall_sum"] or [0])[0] or 0          # cm
    sun = (d["daily"]["sunshine_duration"] or [0])[0] or 0           # 秒
    daylight = (d["daily"]["daylight_duration"] or [0])[0] or 0      # 秒
    depths = [x for x in d["hourly"]["snow_depth"] if x is not None]  # 公尺
    depth_cm = (max(depths) * 100) if depths else 0
    sunny = round(sun / daylight * 100) if daylight else 0
    return {
        "name": loc["name"],
        "snowfall_cm": round(snowfall),
        "depth_cm": round(depth_cm),
        "sunny_pct": max(0, min(100, sunny)),
    }


def main():
    results = []
    for loc in LOCATIONS:
        try:
            results.append(fetch(loc))
        except Exception as e:  # 單一地點失敗不影響其他地點
            print("WARN: %s failed: %s" % (loc["name"], e), file=sys.stderr)

    if not results:
        print("ERROR: all requests failed, keep previous snow_today.json", file=sys.stderr)
        sys.exit(1)

    snow = max(results, key=lambda r: r["snowfall_cm"])
    depth = max(results, key=lambda r: r["depth_cm"])
    sunny = max(results, key=lambda r: r["sunny_pct"])

    out = {
        "updated_at": datetime.now(JST).strftime("%Y-%m-%d %H:%M:%S"),
        "snow_king": {
            "name": snow["name"],
            "stat": "24h 新雪 +%dcm" % snow["snowfall_cm"] if snow["snowfall_cm"] > 0 else "今日無明顯降雪",
        },
        "depth_king": {
            "name": depth["name"],
            "stat": "預估積雪 %dcm" % depth["depth_cm"] if depth["depth_cm"] > 0 else "目前尚無積雪",
        },
        "sunny_pick": {
            "name": sunny["name"],
            "stat": "晴天率 %d%%" % sunny["sunny_pct"],
        },
    }

    for path in (OUT, OUT_APP):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

