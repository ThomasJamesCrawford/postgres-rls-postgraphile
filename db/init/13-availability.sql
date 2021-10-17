\connect booking_app;

CREATE TABLE availability (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    technician_id uuid NOT NULL REFERENCES technician (id) ON DELETE CASCADE,

    duration tstzrange NOT NULL,
    CONSTRAINT duration_enforce_bounds CHECK (lower_inc(duration) AND NOT upper_inc(duration)),
    CONSTRAINT duration_no_adjacent EXCLUDE USING gist (duration WITH -|-, technician_id WITH =),
    CONSTRAINT duration_no_overlap EXCLUDE USING gist (duration WITH &&, technician_id WITH =)
);

CREATE INDEX idx_availability_technician_id ON availability (technician_id);

ALTER TABLE availability ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE availability to anonymous;
GRANT INSERT (technician_id, duration) ON TABLE availability to authenticated_user;
GRANT DELETE ON TABLE availability to authenticated_user;

CREATE POLICY availability_policy_anonymous ON availability FOR SELECT TO anonymous USING (true);
CREATE POLICY availability_policy_authenticated ON availability TO authenticated_user USING (technician_id IN (SELECT current_users_technician_ids()));
