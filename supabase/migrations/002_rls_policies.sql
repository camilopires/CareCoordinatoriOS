-- supabase/migrations/002_rls_policies.sql
-- Enable RLS on ALL tables

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE care_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE key_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE rotation_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pto_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE shift_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE carer_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE care_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE shift_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE join_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Check if current user is the client (owner) of a care group
CREATE OR REPLACE FUNCTION is_care_group_owner(group_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM care_groups
        WHERE id = group_id AND owner_id = auth.uid()
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if current user is a member of a care group
CREATE OR REPLACE FUNCTION is_care_group_member(group_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND care_group_id = group_id
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Get the privacy mode of a care group
CREATE OR REPLACE FUNCTION get_privacy_mode(group_id UUID)
RETURNS privacy_mode AS $$
    SELECT privacy_mode FROM care_groups WHERE id = group_id;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================
-- PROFILES
-- ============================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Clients can read all profiles in their care group
CREATE POLICY "Clients can read care group profiles"
ON profiles FOR SELECT
TO authenticated
USING (
    care_group_id IS NOT NULL
    AND is_care_group_owner(care_group_id)
);

-- Carers can see other profiles based on privacy mode
CREATE POLICY "Carers can read profiles per privacy mode"
ON profiles FOR SELECT
TO authenticated
USING (
    care_group_id IS NOT NULL
    AND is_care_group_member(care_group_id)
    AND get_privacy_mode(care_group_id) = 'open'
);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ============================================
-- CARE GROUPS
-- ============================================

-- Owner has full access
CREATE POLICY "Owner can do anything with care group"
ON care_groups FOR ALL
TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

-- Members can read their care group
CREATE POLICY "Members can read care group"
ON care_groups FOR SELECT
TO authenticated
USING (is_care_group_member(id));

-- ============================================
-- SHIFTS
-- ============================================

-- Client sees all shifts in their care group
CREATE POLICY "Client sees all shifts"
ON shifts FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Carer sees own shifts always
CREATE POLICY "Carer sees own shifts"
ON shifts FOR SELECT
TO authenticated
USING (carer_id = auth.uid());

-- Carer sees all shifts in anonymous/open mode
CREATE POLICY "Carer sees shifts per privacy mode"
ON shifts FOR SELECT
TO authenticated
USING (
    is_care_group_member(care_group_id)
    AND get_privacy_mode(care_group_id) IN ('anonymous', 'open')
);

-- ============================================
-- PTO REQUESTS
-- ============================================

-- Client manages all PTO in their group
CREATE POLICY "Client manages PTO requests"
ON pto_requests FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Carer can create and view own PTO requests
CREATE POLICY "Carer manages own PTO"
ON pto_requests FOR SELECT
TO authenticated
USING (carer_id = auth.uid());

CREATE POLICY "Carer can create PTO"
ON pto_requests FOR INSERT
TO authenticated
WITH CHECK (carer_id = auth.uid());

-- ============================================
-- TASKS
-- ============================================

-- Client manages all tasks
CREATE POLICY "Client manages tasks"
ON tasks FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Carer can read tasks in their care group
CREATE POLICY "Carer reads tasks"
ON tasks FOR SELECT
TO authenticated
USING (is_care_group_member(care_group_id));

-- Carer can update tasks (mark complete)
CREATE POLICY "Carer updates tasks"
ON tasks FOR UPDATE
TO authenticated
USING (is_care_group_member(care_group_id))
WITH CHECK (is_care_group_member(care_group_id));

-- ============================================
-- CARE PLANS
-- ============================================

-- Client manages care plans
CREATE POLICY "Client manages care plans"
ON care_plans FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Members can read care plans
CREATE POLICY "Members read care plans"
ON care_plans FOR SELECT
TO authenticated
USING (is_care_group_member(care_group_id));

-- ============================================
-- INVITATIONS
-- ============================================

-- Client manages invitations
CREATE POLICY "Client manages invitations"
ON invitations FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Anyone authenticated can read invitations by code (for join flow)
CREATE POLICY "Anyone can lookup invitation by code"
ON invitations FOR SELECT
TO authenticated
USING (status = 'active');

-- ============================================
-- JOIN REQUESTS
-- ============================================

-- Client sees join requests for their group
CREATE POLICY "Client manages join requests"
ON join_requests FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM invitations i
        WHERE i.id = join_requests.invitation_id
        AND is_care_group_owner(i.care_group_id)
    )
);

-- Carer can create and view own join requests
CREATE POLICY "Carer manages own join requests"
ON join_requests FOR SELECT
TO authenticated
USING (carer_id = auth.uid());

CREATE POLICY "Carer creates join request"
ON join_requests FOR INSERT
TO authenticated
WITH CHECK (carer_id = auth.uid());

-- ============================================
-- NOTIFICATIONS
-- ============================================

-- Users see only their own notifications
CREATE POLICY "Users see own notifications"
ON notifications FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users update own notifications"
ON notifications FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- System can insert notifications (via service role or triggers)
CREATE POLICY "System inserts notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (TRUE);  -- Controlled by application logic

-- ============================================
-- KEY SHARES
-- ============================================

-- Users see their own key shares
CREATE POLICY "Users see own key shares"
ON key_shares FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Client can manage key shares in their group
CREATE POLICY "Client manages key shares"
ON key_shares FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- ============================================
-- REMAINING TABLES (similar patterns)
-- ============================================

-- Rotation Patterns
CREATE POLICY "Client manages rotation" ON rotation_patterns FOR ALL TO authenticated
USING (is_care_group_owner(care_group_id)) WITH CHECK (is_care_group_owner(care_group_id));
CREATE POLICY "Members read rotation" ON rotation_patterns FOR SELECT TO authenticated
USING (is_care_group_member(care_group_id));

-- Shift Notes
CREATE POLICY "Client reads shift notes" ON shift_notes FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM shifts s WHERE s.id = shift_notes.shift_id AND is_care_group_owner(s.care_group_id)));
CREATE POLICY "Carer manages own notes" ON shift_notes FOR ALL TO authenticated
USING (carer_id = auth.uid()) WITH CHECK (carer_id = auth.uid());

-- Shift Offers
CREATE POLICY "Client manages offers" ON shift_offers FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM shifts s WHERE s.id = shift_offers.shift_id AND is_care_group_owner(s.care_group_id)))
WITH CHECK (EXISTS (SELECT 1 FROM shifts s WHERE s.id = shift_offers.shift_id AND is_care_group_owner(s.care_group_id)));
CREATE POLICY "Carer sees relevant offers" ON shift_offers FOR SELECT TO authenticated
USING (offered_to IS NULL OR offered_to = auth.uid());

-- Carer Availability
CREATE POLICY "Client reads availability" ON carer_availability FOR SELECT TO authenticated
USING (is_care_group_owner(care_group_id));
CREATE POLICY "Carer manages own availability" ON carer_availability FOR ALL TO authenticated
USING (carer_id = auth.uid()) WITH CHECK (carer_id = auth.uid());

-- Reminders
CREATE POLICY "Client manages reminders" ON reminders FOR ALL TO authenticated
USING (is_care_group_owner(care_group_id)) WITH CHECK (is_care_group_owner(care_group_id));
CREATE POLICY "Members read reminders" ON reminders FOR SELECT TO authenticated
USING (is_care_group_member(care_group_id));

-- Emergency Contacts
CREATE POLICY "Client manages contacts" ON emergency_contacts FOR ALL TO authenticated
USING (is_care_group_owner(care_group_id)) WITH CHECK (is_care_group_owner(care_group_id));
CREATE POLICY "Members read contacts" ON emergency_contacts FOR SELECT TO authenticated
USING (is_care_group_member(care_group_id));

-- Audit Log
CREATE POLICY "Client reads audit log" ON audit_log FOR SELECT TO authenticated
USING (is_care_group_owner(care_group_id));
CREATE POLICY "System writes audit log" ON audit_log FOR INSERT TO authenticated
WITH CHECK (is_care_group_member(care_group_id));
