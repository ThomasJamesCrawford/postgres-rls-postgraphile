\connect booking_app;

CREATE TABLE technician (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE CASCADE ON UPDATE CASCADE,
    name varchar(500) NOT NULL,
    description varchar(500) NOT NULL,
    hidden boolean NOT NULL default FALSE
);

CREATE INDEX idx_technician_tenant_id ON technician (tenant_id);