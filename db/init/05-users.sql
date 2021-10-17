\connect booking_app;

CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE CASCADE ON UPDATE CASCADE,
    email email NOT NULL UNIQUE,
    password_hash text NOT NULL,
    admin boolean NOT NULL DEFAULT FALSE
);

COMMENT on COLUMN users.password_hash is E'@omit';

CREATE INDEX idx_user_tenant_id ON users (tenant_id);