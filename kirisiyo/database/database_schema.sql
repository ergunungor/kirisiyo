-- =============================================================================
-- Kırışıyo Veritabanı Şeması
-- Supabase (PostgreSQL) için
--
-- Developer 5 (Backend & Balance Engine) bu dosyayı yönetir.
--
-- Çalıştırma: Supabase Dashboard > SQL Editor
-- =============================================================================

-- UUID extension (Supabase'de varsayılan olarak aktif)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- ROOMS tablosu
-- Her oda benzersiz bir 6 karakterli kodla tanımlanır.
-- =============================================================================
CREATE TABLE IF NOT EXISTS rooms (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(6) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index: Oda koduna göre hızlı arama
CREATE INDEX IF NOT EXISTS idx_rooms_code ON rooms (code);

-- =============================================================================
-- ROOM_MEMBERS tablosu
-- Her üye bir odaya bağlıdır. Authentication yoktur (Sprint 1).
-- =============================================================================
CREATE TABLE IF NOT EXISTS room_members (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id     UUID NOT NULL REFERENCES rooms (id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    joined_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index: Oda üyelerini hızlı getirme
CREATE INDEX IF NOT EXISTS idx_room_members_room_id ON room_members (room_id);

-- Constraint: Aynı odada aynı isimde iki üye olamaz
-- TODO [Developer 5]: Bu kısıtlamayı gerektiğinde kaldırabilirsiniz.
-- ALTER TABLE room_members ADD CONSTRAINT uq_room_member_name UNIQUE (room_id, name);

-- =============================================================================
-- EXPENSES tablosu
-- Bir odadaki harcamalar.
-- =============================================================================
CREATE TABLE IF NOT EXISTS expenses (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id             UUID NOT NULL REFERENCES rooms (id) ON DELETE CASCADE,
    title               VARCHAR(100) NOT NULL,
    amount              DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    paid_by_member_id   UUID NOT NULL REFERENCES room_members (id) ON DELETE RESTRICT,
    date                DATE NOT NULL DEFAULT CURRENT_DATE,
    emoji               VARCHAR(10),
    photo_url           TEXT,
    split_type          VARCHAR(20) NOT NULL DEFAULT 'equal'
                            CHECK (split_type IN ('equal', 'custom')),
    is_from_receipt     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index: Odadaki harcamaları tarihe göre sıralama
CREATE INDEX IF NOT EXISTS idx_expenses_room_id_date
    ON expenses (room_id, date DESC);

-- Index: Ödeyene göre harcama arama
CREATE INDEX IF NOT EXISTS idx_expenses_paid_by
    ON expenses (paid_by_member_id);

-- =============================================================================
-- EXPENSE_SPLITS tablosu
-- Her harcamanın üyeler arasında nasıl bölüştürüldüğü.
-- =============================================================================
CREATE TABLE IF NOT EXISTS expense_splits (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id  UUID NOT NULL REFERENCES expenses (id) ON DELETE CASCADE,
    member_id   UUID NOT NULL REFERENCES room_members (id) ON DELETE RESTRICT,
    amount      DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    is_paid     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Bir üye bir harcamada yalnızca bir kez yer alabilir
    CONSTRAINT uq_expense_split UNIQUE (expense_id, member_id)
);

-- Index: Üyenin tüm split'leri (bakiye hesabı için)
CREATE INDEX IF NOT EXISTS idx_expense_splits_member_id
    ON expense_splits (member_id);

-- Index: Harcamanın split'leri
CREATE INDEX IF NOT EXISTS idx_expense_splits_expense_id
    ON expense_splits (expense_id);

-- =============================================================================
-- SUPABASE RLS (Row Level Security) POLİTİKALARI
-- Sprint 1: Authentication yoktur, tüm işlemler herkese açıktır.
-- Sprint 2+: TODO [Developer 5]: Auth tabanlı RLS politikaları ekleyin.
-- =============================================================================

ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_splits ENABLE ROW LEVEL SECURITY;

-- Sprint 1: Herkese okuma ve yazma izni
-- TODO [Developer 5]: Authentication eklendiğinde bu politikaları güncelleyin.
CREATE POLICY "Sprint 1 - Herkese açık okuma" ON rooms
    FOR SELECT USING (true);

CREATE POLICY "Sprint 1 - Herkese açık yazma" ON rooms
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Sprint 1 - Herkese açık okuma" ON room_members
    FOR SELECT USING (true);

CREATE POLICY "Sprint 1 - Herkese açık yazma" ON room_members
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Sprint 1 - Herkese açık okuma" ON expenses
    FOR SELECT USING (true);

CREATE POLICY "Sprint 1 - Herkese açık yazma" ON expenses
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Sprint 1 - Herkese açık okuma" ON expense_splits
    FOR SELECT USING (true);

CREATE POLICY "Sprint 1 - Herkese açık yazma" ON expense_splits
    FOR ALL USING (true) WITH CHECK (true);

-- =============================================================================
-- SUPABASE STORAGE BUCKET
-- Fiş fotoğrafları için
-- TODO [Developer 4 + Developer 5]: Dashboard'dan veya aşağıdaki SQL ile oluşturun.
-- =============================================================================

-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('receipts', 'receipts', true);

-- =============================================================================
-- ÖRNEK VERİ (Development için — production'da çalıştırmayın)
-- =============================================================================

-- TODO [Developer 5]: Gerekirse örnek veri ekleyin.
-- INSERT INTO rooms (code, name) VALUES ('ABC123', 'Test Odası');
