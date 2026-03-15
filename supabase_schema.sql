-- Таблица для хранения данных трекера интервального голодания
-- Выполни этот SQL в Supabase → SQL Editor → New Query → Run

-- Основная таблица: один пользователь, все данные в JSON
CREATE TABLE IF NOT EXISTS tracker_data (
  id TEXT PRIMARY KEY DEFAULT 'default_user',
  start_ts BIGINT NOT NULL DEFAULT (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT,
  checks JSONB NOT NULL DEFAULT '{}'::JSONB,
  week_days JSONB NOT NULL DEFAULT '{}'::JSONB,
  measurements JSONB NOT NULL DEFAULT '{}'::JSONB,
  last_check_date TEXT DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Вставляем начальную запись
INSERT INTO tracker_data (id) VALUES ('default_user') ON CONFLICT DO NOTHING;

-- RLS (Row Level Security) — разрешаем всё для anon (приложение только для тебя)
ALTER TABLE tracker_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for anon" ON tracker_data
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Автообновление updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON tracker_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
