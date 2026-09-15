-- ============================================================
-- 6-PopulateOK.sql
-- Valid mock data for the IRONMAN database.
-- 5 seasons · ~35 races/season · up to 100 athletes/race
-- ============================================================

BEGIN;

-- ============================================================
-- 1. SEASONS (2020–2024)
-- ============================================================
INSERT INTO season (year, start_date, end_date) VALUES
(2020, '2020-01-01', '2020-12-31'),
(2021, '2021-01-01', '2021-12-31'),
(2022, '2022-01-01', '2022-12-31'),
(2023, '2023-01-01', '2023-12-31'),
(2024, '2024-01-01', '2024-12-31');

-- ============================================================
-- 2. AGE GROUPS (12 male + 12 female = 24)
-- ============================================================
INSERT INTO age_group (label, min_age, max_age, sex) VALUES
('M18-24', 18, 24, 'MALE'),
('M25-29', 25, 29, 'MALE'),
('M30-34', 30, 34, 'MALE'),
('M35-39', 35, 39, 'MALE'),
('M40-44', 40, 44, 'MALE'),
('M45-49', 45, 49, 'MALE'),
('M50-54', 50, 54, 'MALE'),
('M55-59', 55, 59, 'MALE'),
('M60-64', 60, 64, 'MALE'),
('M65-69', 65, 69, 'MALE'),
('M70-74', 70, 74, 'MALE'),
('M75-79', 75, 79, 'MALE'),
('F18-24', 18, 24, 'FEMALE'),
('F25-29', 25, 29, 'FEMALE'),
('F30-34', 30, 34, 'FEMALE'),
('F35-39', 35, 39, 'FEMALE'),
('F40-44', 40, 44, 'FEMALE'),
('F45-49', 45, 49, 'FEMALE'),
('F50-54', 50, 54, 'FEMALE'),
('F55-59', 55, 59, 'FEMALE'),
('F60-64', 60, 64, 'FEMALE'),
('F65-69', 65, 69, 'FEMALE'),
('F70-74', 70, 74, 'FEMALE'),
('F75-79', 75, 79, 'FEMALE');

-- ============================================================
-- 3. POINTS SCALE (positions 1–20 for each season)
-- ============================================================
INSERT INTO points_scale (season_id, position, points)
SELECT s.id, p.pos,
    CASE p.pos
        WHEN  1 THEN 100  WHEN  2 THEN 90  WHEN  3 THEN 82
        WHEN  4 THEN 75   WHEN  5 THEN 69  WHEN  6 THEN 64
        WHEN  7 THEN 59   WHEN  8 THEN 55  WHEN  9 THEN 51
        WHEN 10 THEN 48   WHEN 11 THEN 45  WHEN 12 THEN 42
        WHEN 13 THEN 39   WHEN 14 THEN 37  WHEN 15 THEN 35
        WHEN 16 THEN 33   WHEN 17 THEN 31  WHEN 18 THEN 29
        WHEN 19 THEN 27   WHEN 20 THEN 25
    END
FROM season s
CROSS JOIN generate_series(1, 20) AS p(pos);

-- ============================================================
-- 4. ATHLETES (~500: 300 male + 200 female)
-- ============================================================
DO $$
DECLARE
    v_first_m TEXT[] := ARRAY[
        'James','John','Robert','Michael','David','Carlos','Luis','Juan',
        'Pedro','Diego','Marco','Luca','Hans','Erik','Pierre','Yuki',
        'Wei','Raj','Omar','Ivan','Felipe','Andres','Miguel','Sebastian',
        'Daniel','Mateo','Santiago','Bruno','Oscar','Hugo'
    ];
    v_first_f TEXT[] := ARRAY[
        'Mary','Jennifer','Maria','Elena','Ana','Sofia','Isabella','Emma',
        'Olivia','Charlotte','Sakura','Mei','Priya','Aisha','Natalia',
        'Laura','Julia','Valentina','Camila','Lucia','Daniela','Paula',
        'Carolina','Monica','Diana','Teresa','Clara','Victoria','Gabriela','Nicole'
    ];
    v_last TEXT[] := ARRAY[
        'Smith','Johnson','Williams','Brown','Garcia','Martinez','Rodriguez',
        'Lopez','Gonzalez','Hernandez','Perez','Torres','Gomez','Diaz',
        'Cruz','Mueller','Schmidt','Tanaka','Yamamoto','Kim','Chen','Wang',
        'Singh','Kumar','Anderson','Taylor','Thomas','Moore','Martin',
        'Jackson','White','Harris','Clark','Lewis','Young','Walker',
        'Hall','Allen','King','Wright'
    ];
    v_nat TEXT[] := ARRAY[
        'USA','Colombia','Mexico','Brazil','Argentina','Spain','France',
        'Germany','UK','Italy','Japan','Australia','South Korea','India',
        'South Africa','Canada','Chile','Portugal','Sweden','New Zealand'
    ];
    i INT;
BEGIN
    -- 300 male athletes
    FOR i IN 1..300 LOOP
        INSERT INTO athlete (first_name, last_name, date_of_birth, nationality, sex)
        VALUES (
            v_first_m[1 + floor(random() * array_length(v_first_m, 1))::INT],
            v_last[1 + floor(random() * array_length(v_last, 1))::INT],
            '1950-01-01'::DATE + floor(random() * 18628)::INT,   -- DOB 1950–2001
            v_nat[1 + floor(random() * array_length(v_nat, 1))::INT],
            'MALE'
        );
    END LOOP;
    -- 200 female athletes
    FOR i IN 1..200 LOOP
        INSERT INTO athlete (first_name, last_name, date_of_birth, nationality, sex)
        VALUES (
            v_first_f[1 + floor(random() * array_length(v_first_f, 1))::INT],
            v_last[1 + floor(random() * array_length(v_last, 1))::INT],
            '1950-01-01'::DATE + floor(random() * 18628)::INT,
            v_nat[1 + floor(random() * array_length(v_nat, 1))::INT],
            'FEMALE'
        );
    END LOOP;
END $$;

-- ============================================================
-- 5. RACES (~35 per season = ~175 total)
-- ============================================================
DO $$
DECLARE
    v_cities TEXT[] := ARRAY[
        'Kona','Nice','Hamburg','Port Elizabeth','Cairns',
        'Barcelona','Copenhagen','Cartagena','Buenos Aires','Auckland',
        'Dubai','Cascais','Zurich','Tallinn','Gdynia',
        'Marbella','Pucón','Fortaleza','Victoria','Chattanooga',
        'Louisville','Lake Placid','Madison','St. George','Tulsa',
        'Boulder','Graz','Lahti','Jönköping','Cervia',
        'Lanzarote','Frankfurt','Edinburgh','Cork','Taupo',
        'Langkawi','Cozumel','Mar del Plata','Florianópolis','Lima',
        'Cape Town','Marrakech','Stockholm','Helsinki','Warsaw'
    ];
    v_countries TEXT[] := ARRAY[
        'USA','France','Germany','South Africa','Australia',
        'Spain','Denmark','Colombia','Argentina','New Zealand',
        'UAE','Portugal','Switzerland','Estonia','Poland',
        'Spain','Chile','Brazil','Canada','USA',
        'USA','USA','USA','USA','USA',
        'USA','Austria','Finland','Sweden','Italy',
        'Spain','Germany','UK','Ireland','New Zealand',
        'Malaysia','Mexico','Argentina','Brazil','Peru',
        'South Africa','Morocco','Sweden','Finland','Poland'
    ];
    v_distances TEXT[] := ARRAY['SPRINT','OLYMPIC','HALF','FULL'];
    v_season   RECORD;
    v_num      INT;
    v_idx      INT;
    v_dist     TEXT;
    v_type     TEXT;
    v_date     DATE;
    i          INT;
BEGIN
    FOR v_season IN SELECT id, year FROM season ORDER BY year LOOP
        v_num := 30 + floor(random() * 11)::INT;          -- 30–40 races
        FOR i IN 1..v_num LOOP
            v_idx  := 1 + floor(random() * array_length(v_cities, 1))::INT;
            v_dist := v_distances[1 + floor(random() * 4)::INT];
            v_date := make_date(v_season.year, 1, 1) + floor(random() * 335)::INT + 15;

            -- 1 championship + 4 qualifiers + rest regular per season
            IF i = 1 THEN
                v_type := 'CHAMPIONSHIP';
                v_date := make_date(v_season.year, 10, 1) + floor(random() * 30)::INT;
            ELSIF i <= 5 THEN
                v_type := 'QUALIFIER';
            ELSE
                v_type := 'REGULAR';
            END IF;

            INSERT INTO race (name, date, city, country, distance, race_type, season_id)
            VALUES (
                CASE v_dist
                    WHEN 'FULL'    THEN 'IRONMAN '
                    WHEN 'HALF'    THEN 'IRONMAN 70.3 '
                    WHEN 'OLYMPIC' THEN 'IRONMAN Olympic '
                    WHEN 'SPRINT'  THEN 'IRONMAN Sprint '
                END || v_cities[v_idx] || ' ' || v_season.year,
                v_date,
                v_cities[v_idx],
                v_countries[v_idx],
                v_dist::t_distance,
                v_type::t_race_type,
                v_season.id
            );
        END LOOP;
    END LOOP;
END $$;

-- ============================================================
-- 6. REGISTRATIONS (60–100 random athletes per race)
-- ============================================================
WITH numbered AS (
    SELECT
        a.id   AS athlete_id,
        r.id   AS race_id,
        r.date AS race_date,
        ag.id  AS age_group_id,
        ROW_NUMBER() OVER (PARTITION BY r.id ORDER BY random()) AS rn
    FROM race r
    CROSS JOIN athlete a
    JOIN age_group ag
        ON  ag.sex = a.sex
        AND EXTRACT(YEAR FROM age(r.date, a.date_of_birth))::INT
            BETWEEN ag.min_age AND ag.max_age
)
INSERT INTO registration (athlete_id, race_id, age_group_id, registration_date, bib_number)
SELECT
    athlete_id,
    race_id,
    age_group_id,
    race_date - (1 + (athlete_id % 60)),
    rn::INT
FROM numbered
WHERE rn <= 60 + (race_id * 7 % 41);              -- 60–100 per race

-- ============================================================
-- 7. RESULTS (random realistic times per distance)
-- ============================================================
WITH times AS (
    SELECT
        reg.id AS reg_id,
        -- swim
        CASE r.distance
            WHEN 'SPRINT'  THEN  480 + floor(random() *  720)::INT
            WHEN 'OLYMPIC' THEN 1020 + floor(random() * 1080)::INT
            WHEN 'HALF'    THEN 1320 + floor(random() * 1380)::INT
            WHEN 'FULL'    THEN 2700 + floor(random() * 2700)::INT
        END AS swim_s,
        -- T1
        CASE r.distance
            WHEN 'SPRINT'  THEN  60 + floor(random() * 180)::INT
            WHEN 'OLYMPIC' THEN 120 + floor(random() * 180)::INT
            WHEN 'HALF'    THEN 180 + floor(random() * 300)::INT
            WHEN 'FULL'    THEN 240 + floor(random() * 480)::INT
        END AS t1_s,
        -- bike
        CASE r.distance
            WHEN 'SPRINT'  THEN  1680 + floor(random() *  1020)::INT
            WHEN 'OLYMPIC' THEN  3300 + floor(random() *  2100)::INT
            WHEN 'HALF'    THEN  7800 + floor(random() *  4800)::INT
            WHEN 'FULL'    THEN 16200 + floor(random() * 10800)::INT
        END AS bike_s,
        -- T2
        CASE r.distance
            WHEN 'SPRINT'  THEN  60 + floor(random() * 120)::INT
            WHEN 'OLYMPIC' THEN  60 + floor(random() * 180)::INT
            WHEN 'HALF'    THEN 120 + floor(random() * 240)::INT
            WHEN 'FULL'    THEN 180 + floor(random() * 420)::INT
        END AS t2_s,
        -- run
        CASE r.distance
            WHEN 'SPRINT'  THEN   960 + floor(random() *   840)::INT
            WHEN 'OLYMPIC' THEN  1920 + floor(random() *  1680)::INT
            WHEN 'HALF'    THEN  4800 + floor(random() *  4200)::INT
            WHEN 'FULL'    THEN 10200 + floor(random() * 11400)::INT
        END AS run_s
    FROM registration reg
    JOIN race r ON r.id = reg.race_id
)
INSERT INTO result (registration_id, swim_time, t1_time, bike_time, t2_time,
                    run_time, total_time, overall_position, age_group_position, points_earned)
SELECT
    reg_id,
    make_interval(secs => swim_s),
    make_interval(secs => t1_s),
    make_interval(secs => bike_s),
    make_interval(secs => t2_s),
    make_interval(secs => run_s),
    make_interval(secs => swim_s + t1_s + bike_s + t2_s + run_s),
    0, 0, 0
FROM times;

-- ============================================================
-- 8. COMPUTE POSITIONS
-- ============================================================

-- Overall position per race (by total_time)
WITH ranked AS (
    SELECT res.id AS result_id,
           ROW_NUMBER() OVER (
               PARTITION BY reg.race_id ORDER BY res.total_time
           )::INT AS pos
    FROM result res
    JOIN registration reg ON reg.id = res.registration_id
)
UPDATE result
SET overall_position = ranked.pos
FROM ranked
WHERE result.id = ranked.result_id;

-- Age-group position per race (by total_time within age group)
WITH ranked AS (
    SELECT res.id AS result_id,
           ROW_NUMBER() OVER (
               PARTITION BY reg.race_id, reg.age_group_id ORDER BY res.total_time
           )::INT AS pos
    FROM result res
    JOIN registration reg ON reg.id = res.registration_id
)
UPDATE result
SET age_group_position = ranked.pos
FROM ranked
WHERE result.id = ranked.result_id;

-- ============================================================
-- 9. ASSIGN POINTS (based on age-group position + season scale)
-- ============================================================
WITH pts AS (
    SELECT res.id AS result_id,
           COALESCE(ps.points, 0) AS earned
    FROM result res
    JOIN registration reg ON reg.id = res.registration_id
    JOIN race r           ON r.id  = reg.race_id
    LEFT JOIN points_scale ps
        ON  ps.season_id = r.season_id
        AND ps.position  = res.age_group_position
)
UPDATE result
SET points_earned = pts.earned
FROM pts
WHERE result.id = pts.result_id;

-- ============================================================
-- 10. RANKINGS (aggregate points per athlete/age-group/season)
-- ============================================================
INSERT INTO ranking (athlete_id, age_group_id, season_id, total_points, rank_position)
SELECT
    reg.athlete_id,
    reg.age_group_id,
    r.season_id,
    SUM(res.points_earned),
    0
FROM result res
JOIN registration reg ON reg.id = res.registration_id
JOIN race r           ON r.id  = reg.race_id
WHERE res.points_earned > 0
GROUP BY reg.athlete_id, reg.age_group_id, r.season_id;

-- Rank position within each age-group + season
WITH ranked AS (
    SELECT rk.id AS ranking_id,
           ROW_NUMBER() OVER (
               PARTITION BY rk.age_group_id, rk.season_id
               ORDER BY rk.total_points DESC
           )::INT AS pos
    FROM ranking rk
)
UPDATE ranking
SET rank_position = ranked.pos
FROM ranked
WHERE ranking.id = ranked.ranking_id;

-- ============================================================
-- 11. QUALIFICATION SLOTS (top 3 per age-group in QUALIFIER races)
-- ============================================================
WITH champ AS (
    SELECT DISTINCT ON (season_id) id AS champ_id, season_id
    FROM race
    WHERE race_type = 'CHAMPIONSHIP'
    ORDER BY season_id, id
)
INSERT INTO qualification_slot (qualifying_race_id, target_race_id, age_group_id, athlete_id, slot_number)
SELECT
    qr.id,
    c.champ_id,
    reg.age_group_id,
    reg.athlete_id,
    res.age_group_position
FROM race qr
JOIN champ c            ON c.season_id = qr.season_id
JOIN registration reg   ON reg.race_id = qr.id
JOIN result res         ON res.registration_id = reg.id
WHERE qr.race_type = 'QUALIFIER'
  AND res.age_group_position <= 3;

COMMIT;
