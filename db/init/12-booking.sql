\connect booking_app;

CREATE TABLE booking (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),

    technician_id uuid NOT NULL REFERENCES technician (id) ON DELETE RESTRICT,
    tenant_id uuid NOT NULL REFERENCES tenant (id) ON DELETE RESTRICT,
    service_id uuid NOT NULL REFERENCES service (id) ON DELETE RESTRICT,

    duration tstzrange,
    CONSTRAINT duration_enforce_bounds CHECK (lower_inc(duration) AND NOT upper_inc(duration)),

    reserved_duration tstzrange,
    CONSTRAINT reserved_duration_no_overlap EXCLUDE USING gist (reserved_duration WITH &&, technician_id WITH =, tenant_id WITH =),
    CONSTRAINT reserved_duration_enforce_bounds CHECK (lower_inc(reserved_duration) AND NOT upper_inc(reserved_duration)),

    client_name varchar(200) NOT NULL CHECK (length(client_name) > 0), 
    client_mobile varchar(20) NOT NULL CHECK (client_mobile NOT LIKE '%[^0-9]%' AND length(client_mobile) > 0),
    client_email email NOT NULL,

    client_tsvector tsvector GENERATED ALWAYS AS (to_tsvector('english', client_name || ' ' || client_mobile || ' ' || client_email)) STORED,

    price bigint NOT NULL CHECK (price >= 0)
);

CREATE INDEX idx_booking_client_tsvector ON booking USING gin (client_tsvector, tenant_id);
CREATE INDEX idx_booking_duration ON booking USING gist (duration, technician_id, tenant_id);

CREATE INDEX idx_booking_technician_id ON booking (technician_id);
CREATE INDEX idx_booking_tenant_id ON booking (tenant_id);
CREATE INDEX idx_booking_service_id ON booking (service_id);

ALTER TABLE booking ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE booking to authenticated_user;
GRANT INSERT (technician_id, tenant_id, service_id, reserved_duration, client_name, client_mobile, client_email, price) ON TABLE booking to anonymous;

CREATE POLICY booking_policy_select ON booking FOR SELECT TO authenticated_user USING (tenant_id = current_users_tenant_id());
CREATE POLICY booking_policy_write ON booking TO authenticated_user USING (technician_id IN (SELECT current_users_technician_ids()));
