-- ============================================================
-- 3-Primaries.sql
-- Primary key constraints for all tables.
-- ============================================================

ALTER TABLE season              ADD CONSTRAINT PK_SEASON              PRIMARY KEY (id);
ALTER TABLE race                ADD CONSTRAINT PK_RACE                PRIMARY KEY (id);
ALTER TABLE athlete             ADD CONSTRAINT PK_ATHLETE             PRIMARY KEY (id);
ALTER TABLE age_group           ADD CONSTRAINT PK_AGE_GROUP           PRIMARY KEY (id);
ALTER TABLE registration        ADD CONSTRAINT PK_REGISTRATION        PRIMARY KEY (id);
ALTER TABLE result              ADD CONSTRAINT PK_RESULT              PRIMARY KEY (id);
ALTER TABLE points_scale        ADD CONSTRAINT PK_POINTS_SCALE        PRIMARY KEY (id);
ALTER TABLE ranking             ADD CONSTRAINT PK_RANKING             PRIMARY KEY (id);
ALTER TABLE qualification_slot  ADD CONSTRAINT PK_QUALIFICATION_SLOT  PRIMARY KEY (id);
