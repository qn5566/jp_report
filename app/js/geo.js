/**
 * 地理座標與周邊距離計算模組 (Haversine Distance & Nearby Finder)
 * 用於計算某個花季/煙火點與周邊其他景點、Klook 行程、飯店的直線距離与步行/乘車時間
 */
(function () {
  const EARTH_RADIUS_KM = 6371;

  function toRad(deg) {
    return (deg * Math.PI) / 180;
  }

  /**
   * 計算兩組經緯度之間的距離 (單位：公里)
   */
  function getDistanceKm(lat1, lng1, lat2, lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) return 999;
    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return EARTH_RADIUS_KM * c;
  }

  /**
   * 格式化距離文字（小於 1km 顯示公尺，否則顯示小數點後一位公里）
   */
  function formatDistance(km) {
    if (km < 1) {
      return `約 ${Math.max(50, Math.round(km * 1000 / 10) * 10)} 公尺`;
    }
    return `約 ${km.toFixed(1)} km`;
  }

  /**
   * 找出離指定地點 (centerItem) 最近的同城市其他順遊地點與 Klook 行程
   */
  function findNearbyLocations(centerItem, allLocations, maxCount = 3) {
    if (!centerItem || !Array.isArray(allLocations)) return [];
    return allLocations
      .filter((item) => item.id !== centerItem.id && item.city === centerItem.city)
      .map((item) => {
        const distKm = getDistanceKm(centerItem.lat, centerItem.lng, item.lat, item.lng);
        return Object.assign({}, item, {
          distanceKm: distKm,
          distanceText: formatDistance(distKm)
        });
      })
      .sort((a, b) => a.distanceKm - b.distanceKm)
      .slice(0, maxCount);
  }

  window.GeoHelper = {
    getDistanceKm,
    formatDistance,
    findNearbyLocations
  };
})();
