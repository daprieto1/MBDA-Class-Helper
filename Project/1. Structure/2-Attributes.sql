-- ============================================================
-- 2-Attributes.sql
-- Domain types (attribute-level restrictions).
-- CREATE DOMAIN with CHECK constraints, then apply to columns.
-- ============================================================

-- Domain: race distance
CREATE DOMAIN t_distance AS VARCHAR(20)
    CHECK (VALUE IN ('SPRINT', 'OLYMPIC', 'HALF', 'FULL'));

-- Domain: race type
CREATE DOMAIN t_race_type AS VARCHAR(20)
    CHECK (VALUE IN ('REGULAR', 'QUALIFIER', 'CHAMPIONSHIP'));

-- Domain: biological sex (for age-group classification)
CREATE DOMAIN t_sex AS VARCHAR(10)
    CHECK (VALUE IN ('MALE', 'FEMALE'));

-- Apply domains to existing columns
ALTER TABLE race       ALTER COLUMN distance  TYPE t_distance;
ALTER TABLE race       ALTER COLUMN race_type TYPE t_race_type;
ALTER TABLE athlete    ALTER COLUMN sex       TYPE t_sex;
ALTER TABLE age_group  ALTER COLUMN sex       TYPE t_sex;
