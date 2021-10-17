\connect booking_app;

CREATE TABLE users_technician (
    technician_id uuid NOT NULL REFERENCES technician (id) ON DELETE CASCADE ON UPDATE CASCADE,
    users_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (technician_id, users_id, tenant_id)
);

CREATE INDEX idx_users_technician_technician_id ON users_technician (tenant_id);
CREATE INDEX idx_users_technician_users_id ON users_technician (users_id);
CREATE INDEX idx_users_technician_tenant_id ON users_technician (tenant_id);
