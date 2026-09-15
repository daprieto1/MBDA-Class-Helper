-- ============================================================
-- 8-Queries.sql
-- Strategic CEO queries — Business Intelligence for decision-making.
-- Each query extracts actionable insights from the IRONMAN database.
-- ============================================================

-- ============================================================
-- Q1. Year-over-Year Growth by Distance Format
-- Decision: Which race formats are growing? Should we invest
-- in more HALF (70.3) events or double down on FULL distance?
-- ============================================================
SELECT
    s.year,
    r.distance,
    COUNT(DISTINCT r.id)    AS total_races,
    COUNT(reg.id)           AS total_registrations,
    ROUND(COUNT(reg.id) * 1.0 / COUNT(DISTINCT r.id), 1) AS avg_athletes_per_race
FROM season s
JOIN race r ON r.season_id = s.id
LEFT JOIN registration reg ON reg.race_id = r.id
GROUP BY s.year, r.distance
ORDER BY s.year, r.distance;

-- ============================================================
-- Q2. Top 10 Countries by Athlete Volume
-- Decision: Where is our athlete base concentrated? Which
-- emerging markets should we target for new events?
-- ============================================================
SELECT
    a.nationality,
    COUNT(DISTINCT a.id)    AS total_athletes,
    COUNT(reg.id)           AS total_race_participations,
    ROUND(COUNT(reg.id) * 1.0 / COUNT(DISTINCT a.id), 2) AS races_per_athlete
FROM athlete a
JOIN registration reg ON reg.athlete_id = a.id
GROUP BY a.nationality
ORDER BY total_athletes DESC
LIMIT 10;

-- ============================================================
-- Q3. Athlete Retention — Repeat Participation Across Seasons
-- Decision: Are we retaining athletes season over season, or
-- are we dependent on one-time participants?
-- ============================================================
SELECT
    s.year,
    COUNT(DISTINCT reg.athlete_id) AS active_athletes,
    COUNT(DISTINCT CASE
        WHEN reg.athlete_id IN (
            SELECT reg2.athlete_id
            FROM registration reg2
            JOIN race r2 ON r2.id = reg2.race_id
            JOIN season s2 ON s2.id = r2.season_id
            WHERE s2.year = s.year - 1
        ) THEN reg.athlete_id
    END) AS returning_athletes,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN reg.athlete_id IN (
                SELECT reg2.athlete_id
                FROM registration reg2
                JOIN race r2 ON r2.id = reg2.race_id
                JOIN season s2 ON s2.id = r2.season_id
                WHERE s2.year = s.year - 1
            ) THEN reg.athlete_id
        END) * 100.0 / NULLIF(COUNT(DISTINCT reg.athlete_id), 0),
    1) AS retention_rate_pct
FROM season s
JOIN race r ON r.season_id = s.id
JOIN registration reg ON reg.race_id = r.id
GROUP BY s.year
ORDER BY s.year;

-- ============================================================
-- Q4. Qualification Slot Demand vs. Supply
-- Decision: Are there enough qualification slots relative to
-- demand? Which age groups are underserved?
-- ============================================================
SELECT
    ag.label                        AS age_group,
    ag.sex,
    COUNT(DISTINCT reg.athlete_id)  AS athletes_competing_in_qualifiers,
    COUNT(DISTINCT qs.id)           AS slots_awarded,
    ROUND(
        COUNT(DISTINCT reg.athlete_id) * 1.0 / NULLIF(COUNT(DISTINCT qs.id), 0),
    1) AS athletes_per_slot
FROM race r
JOIN registration reg ON reg.race_id = r.id
JOIN age_group ag ON ag.id = reg.age_group_id
LEFT JOIN qualification_slot qs ON qs.qualifying_race_id = r.id AND qs.age_group_id = ag.id
WHERE r.race_type = 'QUALIFIER'
GROUP BY ag.label, ag.sex
ORDER BY athletes_per_slot DESC NULLS LAST;

-- ============================================================
-- Q5. Race Performance by City — Where to Expand or Cut
-- Decision: Which host cities deliver the highest participation?
-- Which events should be discontinued or relocated?
-- ============================================================
SELECT
    r.city,
    r.country,
    COUNT(DISTINCT r.id)    AS editions_held,
    SUM(sub.athlete_count)  AS total_athletes_all_editions,
    ROUND(AVG(sub.athlete_count), 0) AS avg_athletes_per_edition,
    ROUND(AVG(sub.finish_rate), 1)   AS avg_finish_rate_pct
FROM race r
JOIN (
    SELECT
        reg.race_id,
        COUNT(reg.id) AS athlete_count,
        COUNT(res.id) * 100.0 / NULLIF(COUNT(reg.id), 0) AS finish_rate
    FROM registration reg
    LEFT JOIN result res ON res.registration_id = reg.id
    GROUP BY reg.race_id
) sub ON sub.race_id = r.id
GROUP BY r.city, r.country
ORDER BY avg_athletes_per_edition DESC;

-- ============================================================
-- Q6. Gender Participation Gap Analysis
-- Decision: How balanced is our gender participation? Where
-- should we invest in women-targeted marketing or programs?
-- ============================================================
SELECT
    s.year,
    r.distance,
    a.sex,
    COUNT(DISTINCT reg.athlete_id) AS athletes,
    ROUND(
        COUNT(DISTINCT reg.athlete_id) * 100.0 /
        SUM(COUNT(DISTINCT reg.athlete_id)) OVER (PARTITION BY s.year, r.distance),
    1) AS percentage
FROM season s
JOIN race r ON r.season_id = s.id
JOIN registration reg ON reg.race_id = r.id
JOIN athlete a ON a.id = reg.athlete_id
GROUP BY s.year, r.distance, a.sex
ORDER BY s.year, r.distance, a.sex;

-- ============================================================
-- Q7. Points Inflation Check — Performance Trends by Age Group
-- Decision: Is the points system working correctly, or is
-- points inflation diluting the ranking's value?
-- ============================================================
SELECT
    s.year,
    ag.label AS age_group,
    ROUND(AVG(res.points_earned), 1)    AS avg_points,
    MAX(res.points_earned)              AS max_points,
    MIN(res.points_earned)              AS min_points,
    ROUND(STDDEV(res.points_earned), 1) AS stddev_points
FROM season s
JOIN race r ON r.season_id = s.id
JOIN registration reg ON reg.race_id = r.id
JOIN age_group ag ON ag.id = reg.age_group_id
JOIN result res ON res.registration_id = reg.id
WHERE res.points_earned > 0
GROUP BY s.year, ag.label
ORDER BY s.year, ag.label;

-- ============================================================
-- Q8. DNF/DNS Rate by Distance — Safety Indicator
-- Decision: Are certain race distances causing too many
-- dropouts? Is there a safety or course-design issue?
-- ============================================================
SELECT
    r.distance,
    COUNT(reg.id) AS total_registrations,
    COUNT(res.id) AS total_finishers,
    COUNT(reg.id) - COUNT(res.id) AS dnf_dns_count,
    ROUND(
        (COUNT(reg.id) - COUNT(res.id)) * 100.0 / NULLIF(COUNT(reg.id), 0),
    1) AS dnf_dns_rate_pct
FROM race r
JOIN registration reg ON reg.race_id = r.id
LEFT JOIN result res ON res.registration_id = reg.id
GROUP BY r.distance
ORDER BY dnf_dns_rate_pct DESC;

-- ============================================================
-- Q9. Championship Qualification Pipeline — Conversion Funnel
-- Decision: Of all athletes who compete in qualifiers, how
-- many actually earn a slot? Is the path motivating or
-- discouraging participation?
-- ============================================================
SELECT
    s.year,
    COUNT(DISTINCT reg.athlete_id)  AS athletes_in_qualifiers,
    COUNT(DISTINCT qs.athlete_id)   AS athletes_who_qualified,
    ROUND(
        COUNT(DISTINCT qs.athlete_id) * 100.0 /
        NULLIF(COUNT(DISTINCT reg.athlete_id), 0),
    1) AS qualification_rate_pct
FROM season s
JOIN race r ON r.season_id = s.id AND r.race_type = 'QUALIFIER'
JOIN registration reg ON reg.race_id = r.id
LEFT JOIN qualification_slot qs ON qs.qualifying_race_id = r.id AND qs.athlete_id = reg.athlete_id
GROUP BY s.year
ORDER BY s.year;

-- ============================================================
-- Q10. Multi-Race Athletes — High-Value Customer Identification
-- Decision: Who are our most engaged athletes? Can we build
-- VIP programs, sponsorship pipelines, or ambassador networks?
-- ============================================================
SELECT
    a.id,
    a.first_name || ' ' || a.last_name AS athlete_name,
    a.nationality,
    COUNT(DISTINCT reg.race_id)         AS races_entered,
    COUNT(DISTINCT r.distance)          AS distances_tried,
    COUNT(DISTINCT qs.id)               AS slots_won,
    COALESCE(MIN(rk.rank_position), 0)  AS best_ranking_position
FROM athlete a
JOIN registration reg ON reg.athlete_id = a.id
JOIN race r ON r.id = reg.race_id
LEFT JOIN qualification_slot qs ON qs.athlete_id = a.id
LEFT JOIN ranking rk ON rk.athlete_id = a.id
GROUP BY a.id, a.first_name, a.last_name, a.nationality
HAVING COUNT(DISTINCT reg.race_id) >= 3
ORDER BY races_entered DESC, slots_won DESC
LIMIT 20;
