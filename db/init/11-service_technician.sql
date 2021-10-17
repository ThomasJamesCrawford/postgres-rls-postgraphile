\connect booking_app;

CREATE TABLE service_technician (
    service_id uuid NOT NULL REFERENCES service (id) ON DELETE CASCADE ON UPDATE CASCADE,
    technician_id uuid NOT NULL REFERENCES technician (id) ON DELETE CASCADE ON UPDATE CASCADE,
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (service_id, technician_id, tenant_id)
);

CREATE INDEX idx_service_technician_service_id ON service_technician (service_id);
CREATE INDEX idx_service_technician_technician_id ON service_technician (technician_id);
CREATE INDEX idx_service_technician_tenant_id ON service_technician (tenant_id);

ALTER TABLE service_technician ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE service_technician to anonymous;
GRANT INSERT (service_id, technician_id, tenant_id) ON TABLE service_technician to authenticated_user;
GRANT DELETE ON TABLE service_technician to authenticated_user;

CREATE POLICY service_technician_policy ON service_technician TO authenticated_user USING (tenant_id IN (SELECT tenant_id FROM users WHERE id = current_users_id() AND admin = true));
CREATE POLICY service_technician_policy_anonymous ON service_technician FOR SELECT TO anonymous USING (true);
