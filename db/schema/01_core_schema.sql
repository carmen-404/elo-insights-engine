-- ============================================================
-- ELO INSIGHTS ENGINE - CORE SCHEMA
-- Analytics only. Ratings come from external sources; nothing
-- here computes a rating.
-- ============================================================

-- Reference table: every external system this engine ingests from.
CREATE TABLE SOURCE_SYSTEMS (
    source_system_id  NUMBER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code              VARCHAR2(50)   NOT NULL,   -- e.g. 'IRL_FED', 'CLUB_PLATFORM_X'
    display_name      VARCHAR2(150)  NOT NULL,
    is_active         CHAR(1)        DEFAULT 'Y' NOT NULL,
    created_at        TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT uk_source_systems_code UNIQUE (code),
    CONSTRAINT chk_source_active CHECK (is_active IN ('Y', 'N'))
);


-- Intended as one row per real person, but can't always
-- guarantee it (see LIMITATION on PLAYER_EXTERNAL_REFS).
CREATE TABLE PLAYERS (
    player_id       NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name       VARCHAR2(150)   NOT NULL,
    date_of_birth   DATE,                        -- optional, useful for future identity-matching
    created_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL
);


-- Maps a source's player ID to an internal player_id.
-- PK is (source_system_id, external_ref) - unique per system.
-- One player_id can link to several systems.
-- LIMITATION: no shared reference means ingestion can't tell
-- someone's registered, so it creates a new PLAYERS row.
CREATE TABLE PLAYER_EXTERNAL_REFS (
    player_id         NUMBER        NOT NULL,
    source_system_id  NUMBER        NOT NULL,
    external_ref      VARCHAR2(50)  NOT NULL,
    linked_at         TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_player_external_refs PRIMARY KEY (source_system_id, external_ref),
    CONSTRAINT fk_per_player FOREIGN KEY (player_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT fk_per_source FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id)
);

CREATE INDEX idx_per_player ON PLAYER_EXTERNAL_REFS(player_id);


CREATE TABLE TOURNAMENTS (
    tournament_id     NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_system_id  NUMBER          NOT NULL,
    external_ref      VARCHAR2(50)    NOT NULL,   -- this source's ID for the tournament
    name              VARCHAR2(200)   NOT NULL,
    start_date        DATE            NOT NULL,
    end_date          DATE,
    created_at        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_tournaments_source FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id),
    CONSTRAINT uk_tournaments_source_ref UNIQUE (source_system_id, external_ref),
    CONSTRAINT chk_tournament_dates CHECK (end_date IS NULL OR end_date >= start_date)
);


-- Genuine 1-to-N: one tournament, many players. Kept separate
-- from MATCHES (always exactly 2 players) so you
-- can capture registered players even if they played zero
-- games, plus their seed_rating on entry.
CREATE TABLE TOURNAMENT_PARTICIPANTS (
    tournament_id   NUMBER      NOT NULL,
    player_id       NUMBER      NOT NULL,
    seed_rating     NUMBER(5),               -- player's rating entering the event, as received
    CONSTRAINT pk_tournament_participants PRIMARY KEY (tournament_id, player_id),
    CONSTRAINT fk_tp_tournament FOREIGN KEY (tournament_id)
        REFERENCES TOURNAMENTS(tournament_id),
    CONSTRAINT fk_tp_player FOREIGN KEY (player_id)
        REFERENCES PLAYERS(player_id)
);


-- Modeled as two fixed FK columns (white_id / black_id)
-- instead of a junction table, since chess is always
-- exactly 2 players, not N.
CREATE TABLE MATCHES (
    match_id          NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tournament_id     NUMBER,                      -- nullable: not every match belongs to a tournament
    white_id          NUMBER          NOT NULL,
    black_id          NUMBER          NOT NULL,
    result            VARCHAR2(10)    NOT NULL,   -- 'WHITE_WIN', 'BLACK_WIN', 'DRAW'
    played_on         DATE            NOT NULL,
    source_system_id  NUMBER          NOT NULL,
    external_ref      VARCHAR2(50),                -- nullable: not every source IDs individual games
    created_at        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_matches_tournament FOREIGN KEY (tournament_id)
        REFERENCES TOURNAMENTS(tournament_id),
    CONSTRAINT fk_matches_white FOREIGN KEY (white_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT fk_matches_black FOREIGN KEY (black_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT fk_matches_source FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id),
    CONSTRAINT chk_match_result CHECK (result IN ('WHITE_WIN', 'BLACK_WIN', 'DRAW')),
    CONSTRAINT chk_match_players_differ CHECK (white_id <> black_id)
);


CREATE TABLE RATING_HISTORY (
    rating_history_id NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    player_id         NUMBER        NOT NULL,
    source_system_id  NUMBER        NOT NULL,   -- which source reported this rating
    rating             NUMBER(5)    NOT NULL,   -- as received from source, never computed here
    effective_date     DATE         NOT NULL,
    source_event_id    NUMBER,                  -- optional link to the match/tournament that triggered this entry
    created_at          TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_rating_history_player FOREIGN KEY (player_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT fk_rating_history_source FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id),
    CONSTRAINT chk_rating_positive CHECK (rating > 0),
    CONSTRAINT uk_rating_history_player_source_date
        UNIQUE (player_id, source_system_id, effective_date)
);

CREATE INDEX idx_rating_history_player_date ON RATING_HISTORY(player_id, effective_date);
CREATE INDEX idx_matches_tournament          ON MATCHES(tournament_id);
CREATE INDEX idx_matches_players             ON MATCHES(white_id, black_id);
CREATE INDEX idx_matches_played_on           ON MATCHES(played_on);


-- ============================================================
-- SCALABILITY NOTES (not executed here - documented decisions)
-- ============================================================
-- 1. No ON DELETE CASCADE anywhere. Losing historical data
--    because a parent row got deleted is not acceptable for
--    an analytics engine. Deactivate with a flag instead.
--
-- 2. SOURCE_SYSTEMS as a lookup table instead of free text.
--    Stops other tables referencing a source that doesn't
--    exist. Doesn't stop two rows here being near-duplicates
--    (e.g. 'IRL_FED' vs 'IRL-FED').
--
-- 3. LIMITATION: RATING_HISTORY's granularity depends on the
--    source (per tournament, per game, or on a fixed period);
--    a source that batches several events into one update
--    can't be split back apart, e.g. gain per tournament or
--    per colour isn't answerable.
-- ============================================================