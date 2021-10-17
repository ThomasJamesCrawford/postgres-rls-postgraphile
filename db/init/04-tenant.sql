\connect booking_app;

CREATE TABLE tenant (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    name varchar(500)
);

CREATE INDEX idx_tenant_name ON tenant (name);
