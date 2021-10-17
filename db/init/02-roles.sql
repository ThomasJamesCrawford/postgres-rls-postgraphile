\connect booking_app;

CREATE ROLE anonymous;
CREATE ROLE authenticated_user;

GRANT anonymous to admin;
GRANT anonymous to authenticated_user;
GRANT authenticated_user to admin;
