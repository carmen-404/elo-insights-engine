-- ============================================================
-- ELO INSIGHTS ENGINE - CORE SCHEMA
-- Insights only. Ratings come from external sources; nothing
-- here computes a rating.
-- ============================================================


-- ============================================================
-- RESET: clears existing schema, in FK-safe order (children
-- before parents), so this script can be re-run safely.
-- (Uncomment for reset, but not for first-time creation)
-- ============================================================

--DROP TABLE RATING_HISTORY;
--DROP TABLE MATCHES;
--DROP TABLE TOURNAMENT_PARTICIPANTS;
--DROP TABLE TOURNAMENTS;
--DROP TABLE PLAYER_EXTERNAL_REFS;
--DROP TABLE PLAYERS;
--DROP TABLE SOURCE_SYSTEMS;


-- ============================================================
-- SCHEMA CREATION
-- ============================================================

-- Reference table: every external system this engine ingests from.
CREATE TABLE SOURCE_SYSTEMS (
    source_system_id  NUMBER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code              VARCHAR2(50)   NOT NULL,   -- e.g. 'IRL_FED', 'CLUB_PLATFORM_X'
    display_name      VARCHAR2(150)  NOT NULL,
    is_active         CHAR(1)        DEFAULT 'Y' NOT NULL,
    created_at        TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT source_systems_code_uk UNIQUE (code),
    CONSTRAINT source_active_chk CHECK (is_active IN ('Y', 'N'))
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
    source_system_id  NUMBER,
    external_ref      VARCHAR2(50),
    linked_at         TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT player_external_refs_pk PRIMARY KEY (source_system_id, external_ref),
    -- One registration per player, per source - a player can't have
    -- two external identities within the same source.
    CONSTRAINT player_source_uk UNIQUE (player_id, source_system_id),
    CONSTRAINT player_fk FOREIGN KEY (player_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT source_fk FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id)
);

CREATE INDEX player_external_refs_player_idx ON PLAYER_EXTERNAL_REFS(player_id);


CREATE TABLE TOURNAMENTS (
    tournament_id     NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_system_id  NUMBER          NOT NULL,
    external_ref      VARCHAR2(50)    NOT NULL,   -- this source's ID for the tournament
    name              VARCHAR2(200)   NOT NULL,
    start_date        DATE            NOT NULL,
    end_date          DATE,
    created_at        TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT tournaments_source_fk FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id),
    CONSTRAINT tournaments_external_ref_uk UNIQUE (source_system_id, external_ref),
    CONSTRAINT tournament_dates_chk CHECK (end_date IS NULL OR end_date >= start_date)
);


-- Genuine 1-to-N: one tournament, many players. Kept separate
-- from MATCHES (always exactly 2 players) so you
-- can capture registered players even if they played zero
-- games, plus their seed_rating on entry.
CREATE TABLE TOURNAMENT_PARTICIPANTS (
    tournament_id   NUMBER,
    player_id       NUMBER,
    seed_rating     NUMBER(5),               -- player's rating entering the event, as received
    CONSTRAINT tournament_participants_pk PRIMARY KEY (tournament_id, player_id),
    CONSTRAINT tp_tournament_fk FOREIGN KEY (tournament_id)
        REFERENCES TOURNAMENTS(tournament_id),
    CONSTRAINT tp_player_fk FOREIGN KEY (player_id)
        REFERENCES PLAYERS(player_id)
);


-- Modeled as two fixed FK columns (white_id / black_id)
-- instead of a junction table, since chess is always
-- exactly 2 players, not N.
CREATE TABLE MATCHES (
    match_id          NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tournament_id     NUMBER,         -- nullable: not every match belongs to a tournament
    white_id          NUMBER          NOT NULL,
    black_id          NUMBER          NOT NULL,
    result            VARCHAR2(10)    NOT NULL,   -- 'WHITE_WIN', 'BLACK_WIN', 'DRAW'
    played_on         DATE            NOT NULL,
    source_system_id  NUMBER          NOT NULL,
    external_ref      VARCHAR2(50),                -- nullable: not every source IDs individual games
    created_at        TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT matches_tournament_fk FOREIGN KEY (tournament_id)
        REFERENCES TOURNAMENTS(tournament_id),
    CONSTRAINT matches_white_fk FOREIGN KEY (white_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT matches_black_fk FOREIGN KEY (black_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT matches_source_fk FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id),
    CONSTRAINT match_result_chk CHECK (result IN ('WHITE_WIN', 'BLACK_WIN', 'DRAW')),
    CONSTRAINT match_players_differ_chk CHECK (white_id <> black_id)
);


CREATE TABLE RATING_HISTORY (
    rating_history_id NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    player_id         NUMBER        NOT NULL,
    source_system_id  NUMBER        NOT NULL,   -- which source reported this rating
    rating             NUMBER(5)    NOT NULL,   -- as received from source, never computed here
    effective_date     DATE         NOT NULL,
    created_at          TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT rating_history_player_fk FOREIGN KEY (player_id)
        REFERENCES PLAYERS(player_id),
    CONSTRAINT rating_history_source_fk FOREIGN KEY (source_system_id)
        REFERENCES SOURCE_SYSTEMS(source_system_id),
    CONSTRAINT rating_positive_chk CHECK (rating > 0),
    CONSTRAINT rating_history_player_source_date_uk
        UNIQUE (player_id, source_system_id, effective_date)
);

CREATE INDEX rating_history_player_date_idx ON RATING_HISTORY(player_id, effective_date);
CREATE INDEX matches_tournament_idx         ON MATCHES(tournament_id);
CREATE INDEX matches_players_idx            ON MATCHES(white_id, black_id);
CREATE INDEX matches_played_on_idx          ON MATCHES(played_on);


-- ============================================================
-- DESIGN NOTES
-- ============================================================
-- 1. No ON DELETE CASCADE anywhere. Losing historical data
--    because a parent row got deleted is not acceptable for
--    an insights engine.
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