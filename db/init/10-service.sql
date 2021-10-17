\connect booking_app;

CREATE TABLE service (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    service_type_id uuid NOT NULL REFERENCES service_type (id) ON DELETE CASCADE ON UPDATE CASCADE,
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE CASCADE ON UPDATE CASCADE,
    name varchar(500) NOT NULL,
    description varchar(500) NOT NULL,
    price bigint NOT NULL CHECK (price >= 0),
    length bigint NOT NULL CHECK (length > 0),
    hidden boolean NOT NULL default false
);

CREATE INDEX idx_service_service_type_id ON service (service_type_id);
CREATE INDEX idx_service_tenant_id ON service (tenant_id);

ALTER TABLE service ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE service to anonymous;
GRANT INSERT (service_type_id, tenant_id, name, description, price, length, hidden) ON TABLE service to authenticated_user;
GRANT UPDATE (service_type_id, tenant_id, name, description, price, length, hidden) ON TABLE service to authenticated_user;

CREATE POLICY service_policy ON service TO authenticated_user USING (tenant_id IN (SELECT tenant_id FROM users WHERE id = current_users_id() AND admin = true));
CREATE POLICY service_policy_anonymous_select ON service FOR SELECT TO anonymous USING (hidden = false);

