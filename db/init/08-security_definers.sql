\connect booking_app;

GRANT USAGE ON SCHEMA public to anonymous;

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON functions from public;

-- AUTH FUNCTIONS --

CREATE OR REPLACE FUNCTION current_users_id() returns uuid as $$
    SELECT nullif(current_setting('user.id', true), '')::uuid
$$ language sql stable security definer set search_path to pg_catalog, public, pg_temp;

GRANT EXECUTE ON FUNCTION current_users_id() to anonymous;

CREATE OR REPLACE FUNCTION current_users_tenant_id() returns uuid as $$
    SELECT tenant_id FROM users WHERE id = current_users_id()
$$ language sql stable security definer set search_path to pg_catalog, public, pg_temp;

GRANT EXECUTE ON FUNCTION current_users_tenant_id() to anonymous;

CREATE OR REPLACE FUNCTION current_users_technician_ids() returns setof uuid as $$
    SELECT technician_id FROM users_technician WHERE users_id = current_users_id()
$$ language sql stable security definer set search_path to pg_catalog, public, pg_temp;

GRANT EXECUTE ON FUNCTION current_users_technician_ids() to anonymous;


-- TENANT TABLE --

ALTER TABLE tenant ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE tenant TO authenticated_user;

CREATE POLICY tenant_policy ON tenant FOR SELECT TO authenticated_user USING (id = current_users_tenant_id());

-- USERS TABLE --

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE users TO authenticated_user;
GRANT INSERT (email, password_hash) ON TABLE users TO authenticated_user;
GRANT UPDATE (email, password_hash) ON TABLE users TO authenticated_user;

CREATE POLICY users_policy ON users TO authenticated_user USING (id = current_users_id());

-- TECHNICIAN TABLE --

ALTER TABLE technician ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE technician TO anonymous;
GRANT INSERT (name, description, hidden) ON TABLE technician TO authenticated_user;
GRANT UPDATE (name, description, hidden) ON TABLE technician TO authenticated_user;

CREATE POLICY technician_policy ON technician TO authenticated_user USING (tenant_id IN (SELECT tenant_id FROM users WHERE id = current_users_id() AND admin = true));
CREATE POLICY technician_policy_select ON technician FOR SELECT TO authenticated_user USING (id IN (SELECT current_users_technician_ids()));
CREATE POLICY technician_policy_anonymous ON technician FOR SELECT TO anonymous USING (hidden = false);

-- USERS_TECHNICIAN TABLE -- 

ALTER TABLE users_technician ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE users_technician TO authenticated_user;
GRANT INSERT ON TABLE users_technician TO authenticated_user;
GRANT UPDATE ON TABLE users_technician TO authenticated_user;
GRANT DELETE ON TABLE users_technician TO authenticated_user;

CREATE POLICY users_technician_policy ON users_technician TO authenticated_user USING (tenant_id IN (SELECT tenant_id FROM users WHERE id = current_users_id() AND admin = true));
