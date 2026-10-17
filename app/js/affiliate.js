/**
 * 聯盟行銷網址自動掛碼器 (Affiliate Link Builder)
 * 預設綁定聯合行銷夥伴 ID (AID): 123436
 */
(function () {
  const DEFAULT_AID = "123436";

  function getPartnerAid() {
    if (window.JAPAN_GO_CONFIG && window.JAPAN_GO_CONFIG.partner_id) {
      return String(window.JAPAN_GO_CONFIG.partner_id);
    }
    return DEFAULT_AID;
  }

  /**
   * 將任何 Klook 商品或搜尋連結自動掛上專屬 AID=123436 追蹤參數
   * @param {string} rawUrl 原始 Klook 網址
   * @param {string} [subId] 選填子追蹤標籤（例如景點 ID，方便後台分析哪個花季/煙火帶來最多轉換）
   */
  function buildKlookUrl(rawUrl, subId) {
    const aid = getPartnerAid();
    try {
      const url = new URL(rawUrl || "https://www.klook.com/zh-TW/");
      url.searchParams.set("aid", aid);
      url.searchParams.set("utm_medium", "affiliate-alwayson");
      url.searchParams.set("utm_source", "non-network");
      url.searchParams.set("utm_campaign", aid);
      if (subId) {
        url.searchParams.set("aff_label1", subId);
      }
      return url.toString();
    } catch (e) {
      const sep = (rawUrl || "").includes("?") ? "&" : "?";
      return `${rawUrl}${sep}aid=${encodeURIComponent(aid)}`;
    }
  }

  /**
   * 產生「附近飯店」聯盟導購連結（支援 Klook 飯店、Agoda 與 Booking.com）
   * @param {Object} options
   * @param {string} options.query 飯店名稱或地區關鍵字
   * @param {number} [options.lat] 緯度
   * @param {number} [options.lng] 經度
   * @param {string} [options.platform] 'klook' | 'agoda' | 'booking'
   */
  function buildHotelAffiliateUrl(options) {
    const aid = getPartnerAid();
    const query = encodeURIComponent(options.query || "Tokyo");
    const platform = options.platform || "klook";

    if (platform === "agoda") {
      return `https://www.agoda.com/zh-tw/search?cid=${encodeURIComponent(aid)}&textToSearch=${query}`;
    }
    if (platform === "booking") {
      return `https://www.booking.com/searchresults.zh-tw.html?aid=${encodeURIComponent(aid)}&ss=${query}`;
    }
    // 預設走 Klook 飯店導購（直接共用同一組 Klook AID=123436 分潤）
    return `https://www.klook.com/zh-TW/hotels/searchresult/?aid=${encodeURIComponent(aid)}&utm_medium=affiliate-alwayson&utm_source=non-network&utm_campaign=${encodeURIComponent(aid)}&keyword=${query}`;
  }

  window.AffiliateBuilder = {
    getPartnerAid,
    buildKlookUrl,
    buildHotelAffiliateUrl
  };
})();
