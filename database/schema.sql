-- ============================================================================
-- 日本四季玩樂地圖 App (東京・大阪 MVP) - Supabase / PostgreSQL + PostGIS Schema
-- ============================================================================

-- 1. 啟用 PostGIS 地理空間擴充套件（用於毫秒級計算「方圓 X 公里內的花季/活動/飯店」）
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. 核心景點與地標表 (locations)
CREATE TABLE IF NOT EXISTS public.locations (
  id VARCHAR(100) PRIMARY KEY,
  city VARCHAR(32) NOT NULL CHECK (city IN ('tokyo', 'osaka', 'kyoto', 'hokkaido', 'fukuoka')),
  area_zh VARCHAR(100) NOT NULL,
  name_zh VARCHAR(200) NOT NULL,
  name_ja VARCHAR(200) NOT NULL,
  type VARCHAR(32) NOT NULL CHECK (type IN ('flower', 'fireworks', 'event', 'attraction')),
  sub_type VARCHAR(50),
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  geom GEOGRAPHY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography) STORED,
  station_zh TEXT,
  status_badge VARCHAR(120),
  status_level VARCHAR(50),
  progress_pct INT DEFAULT 0 CHECK (progress_pct >= 0 AND progress_pct <= 100),
  event_date_iso TIMESTAMPTZ,
  fireworks_count VARCHAR(100),
  season_period VARCHAR(200),
  summary_zh TEXT,
  tips_zh TEXT,
  source_url TEXT,
  hotel_area_keyword VARCHAR(200),
  nearby_hotels JSONB DEFAULT '[]'::jsonb,
  klook_tickets JSONB DEFAULT '[]'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 建立空間索引與城市分類索引
CREATE INDEX IF NOT EXISTS idx_locations_geom ON public.locations USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_locations_city_type ON public.locations (city, type);

-- 3. 查詢「方圓 N 公里內所有花季、煙火、活動與 Klook 景點」的 RPC 函數
CREATE OR REPLACE FUNCTION public.get_nearby_locations(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_meters DOUBLE PRECISION DEFAULT 5000
)
RETURNS TABLE (
  id VARCHAR,
  city VARCHAR,
  name_zh VARCHAR,
  type VARCHAR,
  status_badge VARCHAR,
  distance_meters DOUBLE PRECISION,
  klook_tickets JSONB,
  nearby_hotels JSONB
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    l.id,
    l.city,
    l.name_zh,
    l.type,
    l.status_badge,
    ROUND(ST_Distance(
      l.geom,
      ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
    )::numeric, 0)::double precision AS distance_meters,
    l.klook_tickets,
    l.nearby_hotels
  FROM public.locations l
  WHERE ST_DWithin(
    l.geom,
    ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
    radius_meters
  )
  ORDER BY distance_meters ASC;
$$;
