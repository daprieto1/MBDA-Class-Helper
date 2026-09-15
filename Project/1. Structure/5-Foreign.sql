-- ============================================================
-- 5-Foreign.sql
-- Foreign key constraints (referential integrity).
-- ============================================================

-- Race belongs to a Season
ALTER TABLE race
    ADD CONSTRAINT FK_RACE_SEASON
    FOREIGN KEY (season_id) REFERENCES season (id);

-- Registration references Athlete, Race, and AgeGroup
ALTER TABLE registration
    ADD CONSTRAINT FK_REGISTRATION_ATHLETE
    FOREIGN KEY (athlete_id) REFERENCES athlete (id);

ALTER TABLE registration
    ADD CONSTRAINT FK_REGISTRATION_RACE
    FOREIGN KEY (race_id) REFERENCES race (id);

ALTER TABLE registration
    ADD CONSTRAINT FK_REGISTRATION_AGE_GROUP
    FOREIGN KEY (age_group_id) REFERENCES age_group (id);

-- Result references Registration (1:1)
ALTER TABLE result
    ADD CONSTRAINT FK_RESULT_REGISTRATION
    FOREIGN KEY (registration_id) REFERENCES registration (id);

-- PointsScale references Season
ALTER TABLE points_scale
    ADD CONSTRAINT FK_POINTS_SCALE_SEASON
    FOREIGN KEY (season_id) REFERENCES season (id);

-- Ranking references Athlete, AgeGroup, and Season
ALTER TABLE ranking
    ADD CONSTRAINT FK_RANKING_ATHLETE
    FOREIGN KEY (athlete_id) REFERENCES athlete (id);

ALTER TABLE ranking
    ADD CONSTRAINT FK_RANKING_AGE_GROUP
    FOREIGN KEY (age_group_id) REFERENCES age_group (id);

ALTER TABLE ranking
    ADD CONSTRAINT FK_RANKING_SEASON
    FOREIGN KEY (season_id) REFERENCES season (id);

-- QualificationSlot references two Races, AgeGroup, and Athlete
ALTER TABLE qualification_slot
    ADD CONSTRAINT FK_QUALIFICATION_SLOT_QUALIFYING_RACE
    FOREIGN KEY (qualifying_race_id) REFERENCES race (id);

ALTER TABLE qualification_slot
    ADD CONSTRAINT FK_QUALIFICATION_SLOT_TARGET_RACE
    FOREIGN KEY (target_race_id) REFERENCES race (id);

ALTER TABLE qualification_slot
    ADD CONSTRAINT FK_QUALIFICATION_SLOT_AGE_GROUP
    FOREIGN KEY (age_group_id) REFERENCES age_group (id);

ALTER TABLE qualification_slot
    ADD CONSTRAINT FK_QUALIFICATION_SLOT_ATHLETE
    FOREIGN KEY (athlete_id) REFERENCES athlete (id);
