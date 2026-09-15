-- ============================================================
-- 1-Tables.sql
-- Bare table structure: columns and basic SQL types only.
-- No keys, no constraints, no defaults, no NOT NULL.
-- ============================================================

CREATE TABLE season (
    id          SERIAL,
    year        INT,
    start_date  DATE,
    end_date    DATE
);

CREATE TABLE race (
    id          SERIAL,
    name        VARCHAR(200),
    date        DATE,
    city        VARCHAR(100),
    country     VARCHAR(100),
    distance    VARCHAR(20),
    race_type   VARCHAR(20),
    season_id   INT
);

CREATE TABLE athlete (
    id              SERIAL,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    date_of_birth   DATE,
    nationality     VARCHAR(100),
    sex             VARCHAR(10)
);

CREATE TABLE age_group (
    id      SERIAL,
    label   VARCHAR(20),
    min_age INT,
    max_age INT,
    sex     VARCHAR(10)
);

CREATE TABLE registration (
    id                  SERIAL,
    athlete_id          INT,
    race_id             INT,
    age_group_id        INT,
    registration_date   DATE,
    bib_number          INT
);

CREATE TABLE result (
    id                  SERIAL,
    registration_id     INT,
    swim_time           INTERVAL,
    t1_time             INTERVAL,
    bike_time           INTERVAL,
    t2_time             INTERVAL,
    run_time            INTERVAL,
    total_time          INTERVAL,
    overall_position    INT,
    age_group_position  INT,
    points_earned       INT
);

CREATE TABLE points_scale (
    id          SERIAL,
    season_id   INT,
    position    INT,
    points      INT
);

CREATE TABLE ranking (
    id              SERIAL,
    athlete_id      INT,
    age_group_id    INT,
    season_id       INT,
    total_points    INT,
    rank_position   INT
);

CREATE TABLE qualification_slot (
    id                  SERIAL,
    qualifying_race_id  INT,
    target_race_id      INT,
    age_group_id        INT,
    athlete_id          INT,
    slot_number         INT
);
