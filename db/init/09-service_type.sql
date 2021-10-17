\connect booking_app;

CREATE TABLE service_type (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE CASCADE ON UPDATE CASCADE,
    name varchar(500) NOT NULL,
    description varchar(500) NOT NULL,
    hidden boolean NOT NULL default FALSE
);

CREATE INDEX idx_service_type_tenant_id ON service_type (tenant_id);
CREATE INDEX idx_service_type_hidden ON service_type (tenant_id);

ALTER TABLE service_type ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE service_type to anonymous;
GRANT INSERT (name, tenant_id, description, hidden) ON TABLE service_type to authenticated_user;
GRANT UPDATE (name, tenant_id, description, hidden) ON TABLE service_type to authenticated_user;

CREATE POLICY service_type_policy ON service_type TO authenticated_user USING (tenant_id IN (SELECT tenant_id FROM users WHERE id = current_users_id() AND admin = true));
CREATE POLICY service_type_policy_anonymous_select ON service_type FOR SELECT TO anonymous USING (hidden = false);
