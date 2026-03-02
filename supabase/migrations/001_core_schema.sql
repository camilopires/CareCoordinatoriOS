-- supabase/migrations/001_core_schema.sql
-- CareCoordinator Core Schema
-- Run this in Supabase Dashboard → SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE privacy_mode AS ENUM ('full', 'anonymous', 'open');
CREATE TYPE user_role AS ENUM ('client', 'carer');
CREATE TYPE shift_status AS ENUM ('scheduled', 'needing_cover', 'covered', 'completed', 'cancelled');
CREATE TYPE pto_status AS ENUM ('pending', 'approved', 'denied');
CREATE TYPE shift_offer_status AS ENUM ('open', 'accepted', 'declined', 'expired');
CREATE TYPE task_type AS ENUM ('swapover_template', 'swapover_instance', 'general');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE invitation_status AS ENUM ('active', 'revoked', 'expired');
CREATE TYPE join_request_status AS ENUM ('pending', 'approved', 'denied');
CREATE TYPE notification_type AS ENUM (
    'join_request', 'pto_request', 'shift_change', 'task_assigned',
    'open_shift', 'pto_decision', 'reminder', 'care_plan_update'
);

-- ============================================
-- TABLES
-- ============================================

-- Profiles (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    care_group_id UUID,  -- FK added after care_groups created
    display_name TEXT NOT NULL,
    email TEXT NOT NULL,
    public_key BYTEA,  -- Curve25519 public key for E2EE
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Care Groups
CREATE TABLE care_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    privacy_mode privacy_mode NOT NULL DEFAULT 'full',
    default_shift_start TIME NOT NULL DEFAULT '08:00',
    default_shift_end TIME NOT NULL DEFAULT '20:00',
    owner_id UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add FK from profiles to care_groups
ALTER TABLE profiles
    ADD CONSTRAINT fk_profiles_care_group
    FOREIGN KEY (care_group_id) REFERENCES care_groups(id);

-- Key Shares (E2EE group key encrypted per-user)
CREATE TABLE key_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    encrypted_group_key BYTEA NOT NULL,  -- AES group key encrypted with user's public key
    sender_public_key BYTEA NOT NULL,    -- Public key of who encrypted it (for ECDH)
    key_version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(care_group_id, user_id, key_version)
);

-- Rotation Patterns
CREATE TABLE rotation_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    pattern JSONB NOT NULL,  -- ordered array of carer_ids per week
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shifts
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    carer_id UUID REFERENCES profiles(id),
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status shift_status NOT NULL DEFAULT 'scheduled',
    is_manually_edited BOOLEAN NOT NULL DEFAULT FALSE,
    original_carer_id UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shifts_care_group_date ON shifts(care_group_id, date);
CREATE INDEX idx_shifts_carer_date ON shifts(carer_id, date);

-- PTO Requests
CREATE TABLE pto_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    carer_id UUID NOT NULL REFERENCES profiles(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,  -- encrypted client-side
    status pto_status NOT NULL DEFAULT 'pending',
    client_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shift Offers (for broadcasting open shifts)
CREATE TABLE shift_offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    offered_to UUID REFERENCES profiles(id),  -- null = broadcast to all
    status shift_offer_status NOT NULL DEFAULT 'open',
    accepted_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Carer Availability
CREATE TABLE carer_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    carer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME,  -- null = all day
    end_time TIME,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,  -- e.g. "WEEKLY:TUE,THU"
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Care Plans
CREATE TABLE care_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT,
    storage_path TEXT NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    uploaded_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tasks
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    type task_type NOT NULL,
    parent_template_id UUID REFERENCES tasks(id),
    title TEXT NOT NULL,
    description TEXT,  -- encrypted client-side for sensitive content
    priority task_priority NOT NULL DEFAULT 'medium',
    due_date DATE,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_by UUID REFERENCES profiles(id),
    completed_at TIMESTAMPTZ,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shift Notes
CREATE TABLE shift_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    carer_id UUID NOT NULL REFERENCES profiles(id),
    content TEXT NOT NULL,  -- encrypted client-side
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reminders
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    time TIME NOT NULL,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Emergency Contacts
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    relationship TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Invitations
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    created_by UUID NOT NULL REFERENCES profiles(id),
    max_uses INTEGER NOT NULL DEFAULT 1,
    times_used INTEGER NOT NULL DEFAULT 0,
    status invitation_status NOT NULL DEFAULT 'active',
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invitations_code ON invitations(code);

-- Join Requests
CREATE TABLE join_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invitation_id UUID NOT NULL REFERENCES invitations(id),
    carer_id UUID NOT NULL REFERENCES profiles(id),
    status join_request_status NOT NULL DEFAULT 'pending',
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read) WHERE read = FALSE;

-- Audit Log (immutable)
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id),
    user_id UUID NOT NULL REFERENCES profiles(id),
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_care_group ON audit_log(care_group_id, created_at DESC);

-- ============================================
-- AUTO-UPDATE TIMESTAMPS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON care_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON rotation_patterns FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shifts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON pto_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shift_offers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON carer_availability FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON care_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shift_notes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON reminders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON emergency_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- ============================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, role, display_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'role', 'client')::user_role,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
