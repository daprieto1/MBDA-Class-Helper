-- ============================================================
-- 4-Uniques.sql
-- Unique constraints (candidate keys / natural keys).
-- ============================================================

-- A season is uniquely identified by its year
ALTER TABLE season
    ADD CONSTRAINT UK_SEASON_YEAR
    UNIQUE (year);

-- An age-group label is unique (e.g., "M25-29")
ALTER TABLE age_group
    ADD CONSTRAINT UK_AGE_GROUP_LABEL
    UNIQUE (label);

-- An athlete can only register once per race
ALTER TABLE registration
    ADD CONSTRAINT UK_REGISTRATION_ATHLETE_RACE
    UNIQUE (athlete_id, race_id);

-- A registration produces at most one result (1:1)
ALTER TABLE result
    ADD CONSTRAINT UK_RESULT_REGISTRATION
    UNIQUE (registration_id);

-- Each season has one point value per position
ALTER TABLE points_scale
    ADD CONSTRAINT UK_POINTS_SCALE_SEASON_POSITION
    UNIQUE (season_id, position);

-- An athlete has one ranking per age-group per season
ALTER TABLE ranking
    ADD CONSTRAINT UK_RANKING_ATHLETE_AGE_GROUP_SEASON
    UNIQUE (athlete_id, age_group_id, season_id);
