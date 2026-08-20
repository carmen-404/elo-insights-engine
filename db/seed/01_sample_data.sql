-- ============================================================
-- ELO INSIGHTS ENGINE - SAMPLE SEED DATA
-- Fictional players and games. Federation names are real
-- organisations (public information); all players, ratings,
-- and results are entirely fictional.
--
-- Run after 01_core_schema.sql, connected as elo_insights.
--
-- Covers, deliberately:
--   - multiple European federations + one online platform
--   - cross-federation identities resolved to one player_id,
--     as if manually reviewed and merged (Cian, Lucía)
--   - a cross-federation identity that stays unresolved -
--     the documented LIMITATION - two separate player_id
--     rows for what would be the same real person (Marco)
--   - an isolated match with no tournament, tournament_id NULL
--     (Cian's ChessNet game)
--   - a withdrawn participant, registered with zero matches
--     (Hannah)
--   - an inactive source system (OLDPLATFORM)
--
-- RATING_HISTORY cases, by letter:
--   A - Aoife & Cian, tournament-linked (Dublin)
--   B - Lucía & Javier, tournament-linked (Madrid)
--   C - Lucía, a second independent rating from FIDE
--   D - Marco (RFEA identity), monthly-batched, no
--       source_event_id - the granularity LIMITATION
--   E - Cian, per-game update tied to the ChessNet match
--   F - Lukas & Marco (DSB identity), tournament-linked (Berlin)
--   G - Camille & Antoine, tournament-linked (Paris)
-- ============================================================

SET SERVEROUTPUT ON;

DECLARE
    v_icu        NUMBER;  -- Irish Chess Union
    v_rfea       NUMBER;  -- Real Federación Española de Ajedrez
    v_dsb        NUMBER;  -- Deutscher Schachbund
    v_ffe        NUMBER;  -- Fédération Française des Échecs
    v_fide       NUMBER;  -- FIDE, used only as a shared cross-federation ref
    v_chessnet   NUMBER;  -- fictional online platform, per-game updates
    v_oldplat    NUMBER;  -- fictional retired platform, inactive

    v_aoife      NUMBER;  -- Irish player
    v_cian       NUMBER;  -- Irish player, isolated online game
    v_lucia      NUMBER;  -- Spanish player, correctly linked RFEA + FIDE
    v_javier     NUMBER;  -- Spanish player
    v_lukas      NUMBER;  -- German player
    v_hannah     NUMBER;  -- German player, withdraws from a tournament
    v_camille    NUMBER;  -- French player
    v_antoine    NUMBER;  -- French player
    v_marco_rfea NUMBER;  -- "Marco Rossi" as registered with RFEA
    v_marco_dsb  NUMBER;  -- "Marco Rossi" as registered with DSB
                           -- same real person in the story, but no
                           -- shared ref exists to link them - two
                           -- separate player_id rows, on purpose

    v_dublin     NUMBER;  -- tournament
    v_madrid     NUMBER;  -- tournament
    v_berlin     NUMBER;  -- tournament
    v_paris      NUMBER;  -- tournament

    v_match      NUMBER;  -- scratch var, reused per INSERT
BEGIN

    -- --------------------------------------------------------
    -- SOURCE_SYSTEMS
    -- --------------------------------------------------------
    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('ICU', 'Irish Chess Union') RETURNING source_system_id INTO v_icu;
    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('RFEA', 'Real Federación Española de Ajedrez') RETURNING source_system_id INTO v_rfea;
    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('DSB', 'Deutscher Schachbund') RETURNING source_system_id INTO v_dsb;
    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('FFE', 'Fédération Française des Échecs') RETURNING source_system_id INTO v_ffe;
    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('FIDE', 'FIDE (used here only as a shared cross-federation reference)')
        RETURNING source_system_id INTO v_fide;
    INSERT INTO SOURCE_SYSTEMS (code, display_name)
        VALUES ('CHESSNET', 'ChessNet (fictional online platform)') RETURNING source_system_id INTO v_chessnet;
    INSERT INTO SOURCE_SYSTEMS (code, display_name, is_active)
        VALUES ('OLDPLATFORM', 'Retired Rating Platform (fictional)', 'N') RETURNING source_system_id INTO v_oldplat;


    -- --------------------------------------------------------
    -- PLAYERS
    -- --------------------------------------------------------
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Aoife Byrne', DATE '1998-04-12') RETURNING player_id INTO v_aoife;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Cian Murphy', DATE '2001-11-03') RETURNING player_id INTO v_cian;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Lucía Fernández', DATE '1995-07-22') RETURNING player_id INTO v_lucia;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Javier Torres', DATE '1999-02-17') RETURNING player_id INTO v_javier;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Lukas Weber', DATE '1997-09-30') RETURNING player_id INTO v_lukas;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Hannah Fischer', DATE '2000-05-14') RETURNING player_id INTO v_hannah;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Camille Dubois', DATE '1996-12-08') RETURNING player_id INTO v_camille;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Antoine Laurent', DATE '1994-03-25') RETURNING player_id INTO v_antoine;

    -- "Marco Rossi": deliberately two separate player_id rows.
    -- Same real person in this story, registered independently
    -- with RFEA and DSB, with no shared ref to link them - this
    -- is the identity LIMITATION documented on PLAYER_EXTERNAL_REFS,
    -- shown here as data rather than just a comment.
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Marco Rossi', DATE '1993-06-19') RETURNING player_id INTO v_marco_rfea;
    INSERT INTO PLAYERS (full_name, date_of_birth) VALUES ('Marco Rossi', DATE '1993-06-19') RETURNING player_id INTO v_marco_dsb;


    -- --------------------------------------------------------
    -- PLAYER_EXTERNAL_REFS
    -- --------------------------------------------------------
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_aoife, v_icu, 'ICU-1042');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_cian, v_icu, 'ICU-1107');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_cian, v_chessnet, 'cn_cianm88');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_javier, v_rfea, 'RFEA-3391');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_lukas, v_dsb, 'DSB-5521');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_hannah, v_dsb, 'DSB-5588');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_camille, v_ffe, 'FFE-7710');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_antoine, v_ffe, 'FFE-7744');

    -- Lucía: correctly linked across RFEA and FIDE, because both
    -- sources happen to report the same shared reference. This is
    -- the ONE case where cross-federation identity resolution
    -- actually works, per the schema's documented mechanism.
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_lucia, v_rfea, 'RFEA-2205');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_lucia, v_fide, 'FIDE-1234567');

    -- Marco Rossi: two unlinked identities, on purpose (see PLAYERS above).
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_marco_rfea, v_rfea, 'RFEA-4410');
    INSERT INTO PLAYER_EXTERNAL_REFS (player_id, source_system_id, external_ref) VALUES (v_marco_dsb, v_dsb, 'DSB-6602');


    -- --------------------------------------------------------
    -- TOURNAMENTS
    -- --------------------------------------------------------
    INSERT INTO TOURNAMENTS (source_system_id, external_ref, name, start_date, end_date)
        VALUES (v_icu, 'ICU-T-2026-01', 'Dublin Spring Open 2026', DATE '2026-03-14', DATE '2026-03-16')
        RETURNING tournament_id INTO v_dublin;

    INSERT INTO TOURNAMENTS (source_system_id, external_ref, name, start_date, end_date)
        VALUES (v_rfea, 'RFEA-T-2026-02', 'Copa de Madrid 2026', DATE '2026-04-04', DATE '2026-04-06')
        RETURNING tournament_id INTO v_madrid;

    INSERT INTO TOURNAMENTS (source_system_id, external_ref, name, start_date, end_date)
        VALUES (v_dsb, 'DSB-T-2025-11', 'Berlin Winter Cup 2025', DATE '2025-12-06', DATE '2025-12-08')
        RETURNING tournament_id INTO v_berlin;

    INSERT INTO TOURNAMENTS (source_system_id, external_ref, name, start_date, end_date)
        VALUES (v_ffe, 'FFE-T-2026-03', 'Paris Rapid Masters 2026', DATE '2026-05-09', DATE '2026-05-09')
        RETURNING tournament_id INTO v_paris;


    -- --------------------------------------------------------
    -- TOURNAMENT_PARTICIPANTS
    -- --------------------------------------------------------
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_dublin, v_aoife, 1742);
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_dublin, v_cian, 1588);

    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_madrid, v_javier, 1810);
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_madrid, v_lucia, 2044);
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_madrid, v_marco_rfea, 1655);

    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_berlin, v_lukas, 1922);
    -- Hannah registers for Berlin but withdraws: no MATCHES row for her here at all.
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_berlin, v_hannah, 1877);
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_berlin, v_marco_dsb, 1660);

    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_paris, v_camille, 1699);
    INSERT INTO TOURNAMENT_PARTICIPANTS (tournament_id, player_id, seed_rating) VALUES (v_paris, v_antoine, 1733);


    -- --------------------------------------------------------
    -- MATCHES
    -- --------------------------------------------------------
    -- Dublin Spring Open: Aoife (white) beats Cian
    INSERT INTO MATCHES (tournament_id, white_id, black_id, result, played_on, source_system_id, external_ref)
        VALUES (v_dublin, v_aoife, v_cian, 'WHITE_WIN', DATE '2026-03-14', v_icu, 'ICU-T-2026-01-R1-B1');

    -- Copa de Madrid: Lucía (black) beats Javier
    INSERT INTO MATCHES (tournament_id, white_id, black_id, result, played_on, source_system_id, external_ref)
        VALUES (v_madrid, v_javier, v_lucia, 'BLACK_WIN', DATE '2026-04-04', v_rfea, 'RFEA-T-2026-02-R1-B1');

    -- Copa de Madrid: Lucía (white) draws Marco (RFEA identity)
    INSERT INTO MATCHES (tournament_id, white_id, black_id, result, played_on, source_system_id, external_ref)
        VALUES (v_madrid, v_lucia, v_marco_rfea, 'DRAW', DATE '2026-04-05', v_rfea, 'RFEA-T-2026-02-R2-B1');

    -- Berlin Winter Cup: Lukas (white) beats Marco (DSB identity)
    INSERT INTO MATCHES (tournament_id, white_id, black_id, result, played_on, source_system_id, external_ref)
        VALUES (v_berlin, v_lukas, v_marco_dsb, 'WHITE_WIN', DATE '2025-12-06', v_dsb, 'DSB-T-2025-11-R1-B1');
    -- (Hannah withdrew - correctly has zero rows here, despite being a TOURNAMENT_PARTICIPANTS row above.)

    -- Paris Rapid Masters: Camille (black) beats Antoine
    INSERT INTO MATCHES (tournament_id, white_id, black_id, result, played_on, source_system_id, external_ref)
        VALUES (v_paris, v_antoine, v_camille, 'BLACK_WIN', DATE '2026-05-09', v_ffe, 'FFE-T-2026-03-R1-B1');

    -- Isolated online game: Cian vs a ChessNet-only opponent
    -- (using Aoife's player_id here for simplicity - in reality
    -- would usually be someone with no federation ties at all).
    -- tournament_id is NULL: this game belongs to no tournament.
    INSERT INTO MATCHES (tournament_id, white_id, black_id, result, played_on, source_system_id, external_ref)
        VALUES (NULL, v_cian, v_aoife, 'WHITE_WIN', DATE '2026-02-20', v_chessnet, 'cn_game_88213');


    -- --------------------------------------------------------
    -- RATING_HISTORY
    -- --------------------------------------------------------
    -- Case A: tournament-linked update. ICU reports Aoife's new
    -- rating tied directly to the Dublin tournament - precise
    -- attribution is possible here.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_aoife, v_icu, 1758, DATE '2026-03-16', v_dublin);
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_cian, v_icu, 1571, DATE '2026-03-16', v_dublin);

    -- Case B: another tournament-linked update, different federation.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_lucia, v_rfea, 2061, DATE '2026-04-06', v_madrid);
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_javier, v_rfea, 1794, DATE '2026-04-06', v_madrid);

    -- Case C: Lucía also has a FIDE-reported rating, same real
    -- person, different source, independent number - demonstrates
    -- one player legitimately having more than one rating history.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_lucia, v_fide, 2058, DATE '2026-04-30', NULL);

    -- Case D: monthly-batched update, no source_event_id. RFEA
    -- publishes Marco's (RFEA identity) new rating for the month
    -- as a whole, after he played BOTH the Madrid tournament and
    -- another event not modelled here. This single number cannot
    -- be split back apart to attribute a gain to Madrid specifically
    -- - the granularity LIMITATION, shown as real data.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_marco_rfea, v_rfea, 1649, DATE '2026-04-30', NULL);

    -- Case E: per-game update from an online platform, tied to
    -- the isolated match above via source_event_id pointing at
    -- the match itself rather than a tournament.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_cian, v_chessnet, 1595, DATE '2026-02-20', NULL);

    -- Case F: Berlin, tournament-linked as normal.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_lukas, v_dsb, 1935, DATE '2025-12-08', v_berlin);
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_marco_dsb, v_dsb, 1650, DATE '2025-12-08', v_berlin);
    -- Hannah withdrew, so no RATING_HISTORY row follows from Berlin for her.

    -- Case G: Paris, tournament-linked.
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_camille, v_ffe, 1714, DATE '2026-05-09', v_paris);
    INSERT INTO RATING_HISTORY (player_id, source_system_id, rating, effective_date, source_event_id)
        VALUES (v_antoine, v_ffe, 1719, DATE '2026-05-09', v_paris);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Seed data inserted successfully.');
END;
/
